import 'package:flutter/material.dart';
import 'package:genai_components/gen/theme/gen_tokens.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';
import 'gen_popup_surface.dart';

/// Elemento di un [GenPopupMenu].
class GenPopupMenuItem {
  /// Contenuto completo della riga (es. ListTile con icona e testo).
  final Widget content;

  /// Callback al tap.
  final VoidCallback onTap;

  const GenPopupMenuItem({required this.content, required this.onTap});
}

/// Popup menu riusabile con lo stesso stile delle tableActions della PagedDataTable.
///
/// Uso:
/// ```dart
/// GenPopupMenu.show(
///   context: context,
///   anchorKey: _myGlobalKey,
///   title: 'Azioni',
///   items: [ GenPopupMenuItem(...) ],
/// );
/// ```
///
/// Oppure come trigger widget:
/// ```dart
/// GenPopupMenu(
///   title: 'Azioni',
///   items: [...],
///   builder: (context, open) => IconButton(onPressed: open, icon: ...),
/// );
/// ```
class GenPopupMenu extends StatefulWidget {
  /// Titolo opzionale nell'header del popup.
  final String? title;

  /// Widget personalizzato per l'header (alternativo a [title]).
  final Widget? titleWidget;

  /// Lista di voci del menu.
  final List<GenPopupMenuItem> items;

  /// Builder per il widget trigger. Riceve la callback per aprire il menu.
  final Widget Function(BuildContext context, VoidCallback open) builder;

  /// Allineamento orizzontale del popup rispetto all'anchor.
  /// Default: [GenPopupAlignment.end] (allineato a destra).
  final GenPopupAlignment alignment;

  /// Larghezza minima del popup.
  final double minWidth;

  /// Larghezza massima del popup.
  final double maxWidth;

  const GenPopupMenu({
    super.key,
    this.title,
    this.titleWidget,
    required this.items,
    required this.builder,
    this.alignment = GenPopupAlignment.end,
    this.minWidth = 0,
    this.maxWidth = 280,
  });

  /// Mostra il popup in modo imperativo dato un [GlobalKey] come anchor.
  static Future<void> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required List<GenPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
    GenPopupAlignment alignment = GenPopupAlignment.end,
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

  /// Mostra il popup a una posizione GLOBALE arbitraria (cursore), non ancorato
  /// a un widget. Usato dai menu contestuali (tasto destro). Riusa `_showPopup`
  /// con `anchorSize: Size.zero`; su mobile (<600) resta il bottom sheet.
  static Future<void> showAt({
    required BuildContext context,
    required Offset globalPosition,
    required List<GenPopupMenuItem> items,
    String? title,
    double minWidth = 0,
    double maxWidth = 280,
  }) async {
    if (MediaQuery.of(context).size.width < 600) {
      return _showSheet(context: context, items: items, title: title, titleWidget: null);
    }
    await _showPopup(
      context: context,
      position: globalPosition,
      anchorSize: Size.zero,
      screenSize: MediaQuery.of(context).size,
      items: items,
      title: title,
      titleWidget: null,
      alignment: GenPopupAlignment.start, // apre verso destra/basso dal cursore
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Mobile: stesse voci in un bottom sheet full-width (handle + header opzionale
  /// + righe). Tap voce → pop sheet + onTap (gestito da [_GenPopupMenuItemWidget]).
  static Future<void> _showSheet({
    required BuildContext context,
    required List<GenPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = GenTokens.of(ctx);
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
                  const SizedBox(height: GenSizes.gapMd),
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
                  const SizedBox(height: GenSizes.gapSm),
                  if (title != null || titleWidget != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GenSizes.gapLg, vertical: GenSizes.gapLg * 0.75),
                      child:
                          titleWidget ?? Text(title!, style: theme.title.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  for (int i = 0; i < items.length; i++)
                    _GenPopupMenuItemWidget(item: items[i], isLast: i == items.length - 1),
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
    required List<GenPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
    required GenPopupAlignment alignment,
    required double minWidth,
    required double maxWidth,
  }) async {
    final theme = GenTokens.of(context);
    final gap = theme.gapIconText;

    final openUpwards = position.dy + anchorSize.height + gap + 250 > screenSize.height;

    // Posizionamento orizzontale con auto-flip: l'allineamento richiesto viene
    // ribaltato se il popup uscirebbe dallo schermo (es. anchor sul bordo
    // sinistro + .end → flip a .start). Stima worst-case con maxWidth.
    const edge = 8.0;
    final anchorRight = position.dx + anchorSize.width;
    final endOverflowsLeft = anchorRight - maxWidth < edge;
    final startOverflowsRight = position.dx + maxWidth > screenSize.width - edge;
    final wantEnd = alignment == GenPopupAlignment.end;
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
                  child: GenPopupSurface(
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
                          padding: const EdgeInsets.symmetric(horizontal: GenSizes.gapLg, vertical: GenSizes.gapLg * 0.75),
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
                                style: theme.title.copyWith(fontWeight: FontWeight.w600),
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
                            _GenPopupMenuItemWidget(
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
  State<GenPopupMenu> createState() => _GenPopupMenuState();
}

class _GenPopupMenuState extends State<GenPopupMenu> {
  final GlobalKey _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _anchorKey,
      child: widget.builder(
        context,
        () => GenPopupMenu.show(
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
enum GenPopupAlignment { start, end }

/// Singola voce: alta come un button default, hover nativo InkWell (Material
/// fornito da GenPopupSurface), divider full-width come border-bottom.
class _GenPopupMenuItemWidget extends StatelessWidget {
  final GenPopupMenuItem item;
  final bool isLast;

  const _GenPopupMenuItemWidget({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);

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
          padding: const EdgeInsets.symmetric(horizontal: GenSizes.gapLg),
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
