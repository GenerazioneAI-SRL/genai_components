import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'cl_popup_surface.widget.dart';

/// Elemento di un [CLPopupMenu].
class CLPopupMenuItem {
  /// Contenuto completo della riga (es. ListTile con icona e testo).
  final Widget content;

  /// Callback al tap.
  final VoidCallback onTap;

  const CLPopupMenuItem({required this.content, required this.onTap});
}

/// Popup menu riusabile con lo stesso stile delle tableActions della PagedDataTable.
///
/// Uso:
/// ```dart
/// CLPopupMenu.show(
///   context: context,
///   anchorKey: _myGlobalKey,
///   title: 'Azioni',
///   items: [ CLPopupMenuItem(...) ],
/// );
/// ```
///
/// Oppure come trigger widget:
/// ```dart
/// CLPopupMenu(
///   title: 'Azioni',
///   items: [...],
///   builder: (context, open) => IconButton(onPressed: open, icon: ...),
/// );
/// ```
class CLPopupMenu extends StatefulWidget {
  /// Titolo opzionale nell'header del popup.
  final String? title;

  /// Widget personalizzato per l'header (alternativo a [title]).
  final Widget? titleWidget;

  /// Lista di voci del menu.
  final List<CLPopupMenuItem> items;

  /// Builder per il widget trigger. Riceve la callback per aprire il menu.
  final Widget Function(BuildContext context, VoidCallback open) builder;

  /// Allineamento orizzontale del popup rispetto all'anchor.
  /// Default: [CLPopupAlignment.end] (allineato a destra).
  final CLPopupAlignment alignment;

  /// Larghezza minima del popup.
  final double minWidth;

  /// Larghezza massima del popup.
  final double maxWidth;

  const CLPopupMenu({
    super.key,
    this.title,
    this.titleWidget,
    required this.items,
    required this.builder,
    this.alignment = CLPopupAlignment.end,
    this.minWidth = 0,
    this.maxWidth = 280,
  });

  /// Mostra il popup in modo imperativo dato un [GlobalKey] come anchor.
  static Future<void> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required List<CLPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
    CLPopupAlignment alignment = CLPopupAlignment.end,
    double minWidth = 0,
    double maxWidth = 280,
  }) async {
    // Mobile (<600): bottom sheet full-width invece del popover ancorato.
    if (MediaQuery.of(context).size.width < 600) {
      return _showSheet(context: context, items: items, title: title, titleWidget: titleWidget);
    }

    final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    await _showPopup(
      context: context,
      position: position,
      anchorSize: anchorSize,
      screenSize: screenSize,
      items: items,
      title: title,
      titleWidget: titleWidget,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Mobile: stesse voci in un bottom sheet full-width (handle + header opzionale
  /// + righe). Tap voce → pop sheet + onTap (gestito da [_CLPopupMenuItemWidget]).
  static Future<void> _showSheet({
    required BuildContext context,
    required List<CLPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = CLTheme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusSurface)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle drag.
                  const SizedBox(height: Sizes.gapMd),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.gapSm),
                  if (title != null || titleWidget != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg, vertical: Sizes.gapLg * 0.75),
                      child:
                          titleWidget ?? Text(title!, style: theme.title.override(fontWeight: FontWeight.w600)),
                    ),
                  for (int i = 0; i < items.length; i++)
                    _CLPopupMenuItemWidget(item: items[i], isLast: i == items.length - 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _showPopup({
    required BuildContext context,
    required Offset position,
    required Size anchorSize,
    required Size screenSize,
    required List<CLPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
    required CLPopupAlignment alignment,
    required double minWidth,
    required double maxWidth,
  }) async {
    final theme = CLTheme.of(context);
    final gap = theme.gapIconText;

    final openUpwards = position.dy + anchorSize.height + gap + 250 > screenSize.height;

    // Posizionamento orizzontale con auto-flip: l'allineamento richiesto viene
    // ribaltato se il popup uscirebbe dallo schermo (es. anchor sul bordo
    // sinistro + .end → flip a .start). Stima worst-case con maxWidth.
    const edge = 8.0;
    final anchorRight = position.dx + anchorSize.width;
    final endOverflowsLeft = anchorRight - maxWidth < edge;
    final startOverflowsRight = position.dx + maxWidth > screenSize.width - edge;
    final wantEnd = alignment == CLPopupAlignment.end;
    final useEnd = wantEnd ? !endOverflowsLeft : startOverflowsRight;

    double? left;
    double? right;
    if (useEnd) {
      right = (screenSize.width - anchorRight).clamp(edge, double.infinity);
    } else {
      left = position.dx.clamp(edge, double.infinity);
    }

    await showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent, // popover ancorato: nessuno scurire lo sfondo
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (context, animation, secondaryAnimation, child) => child,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: left,
              right: right,
              top: !openUpwards ? position.dy + anchorSize.height + gap : null,
              bottom: openUpwards ? screenSize.height - position.dy + gap : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
                // IntrinsicWidth: il popup si dimensiona al contenuto più largo
                // (capped da min/max), invece di prendere sempre maxWidth.
                child: IntrinsicWidth(
                  child: CLPopupSurface(
                  animateUpward: openUpwards,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header con gradient
                      if (title != null || titleWidget != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg, vertical: Sizes.gapLg * 0.75),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primary.withValues(alpha: theme.opacitySoft),
                                theme.secondary.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
                          ),
                          child: titleWidget ??
                              Text(
                                title!,
                                style: theme.title.override(fontWeight: FontWeight.w600),
                              ),
                        ),
                      // Items — righe alte come un button default; divider
                      // full-width (border-bottom) tra una opzione e l'altra.
                      // stretch: le righe occupano tutta la larghezza → hover e
                      // divider full-width (senza stretch si restringevano al testo).
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < items.length; i++)
                            _CLPopupMenuItemWidget(
                              item: items[i],
                              isLast: i == items.length - 1,
                            ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<CLPopupMenu> createState() => _CLPopupMenuState();
}

class _CLPopupMenuState extends State<CLPopupMenu> {
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _anchorKey,
      child: widget.builder(
        context,
        () => CLPopupMenu.show(
          context: context,
          anchorKey: _anchorKey,
          items: widget.items,
          title: widget.title,
          titleWidget: widget.titleWidget,
          alignment: widget.alignment,
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
        ),
      ),
    );
  }
}

/// Allineamento orizzontale del popup rispetto all'anchor.
enum CLPopupAlignment { start, end }

/// Singola voce: alta come un button default, hover nativo InkWell (Material
/// fornito da CLPopupSurface), divider full-width come border-bottom.
class _CLPopupMenuItemWidget extends StatelessWidget {
  final CLPopupMenuItem item;
  final bool isLast;

  const _CLPopupMenuItemWidget({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return SizedBox(
      height: theme.buttonHeightDefault,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          item.onTap();
        },
        // accent = token "hover/interactive surface". Splash trasparente +
        // highlight = accent → il press combacia con l'hover (niente ripple tinto).
        hoverColor: theme.accent,
        highlightColor: theme.accent,
        splashColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg),
          alignment: Alignment.centerLeft,
          decoration: isLast
              ? null
              : BoxDecoration(border: Border(bottom: BorderSide(color: theme.borderColor, width: 1))),
          child: item.content,
        ),
      ),
    );
  }
}
