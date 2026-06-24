import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import 'cl_tab_item.model.dart';

/// Tab view in stile editoriale: nessun chrome a bottone, label sottolineata
/// quando attiva. Divider 1px continuo sotto la riga delle tab; l'indicatore
/// 3px del tab attivo sovrascrive il divider creando l'effetto "active rail".
///
/// API pubblica:
/// - [clTabItems] elenco tab
/// - [title] titolo testo opzionale sopra la tab bar
/// - [titleWidget] header ricco opzionale (ha precedenza su [title])
/// - [showDivider] mostra/nasconde un secondo divider sotto la tab bar
class CLTabView extends StatefulWidget {
  final List<CLTabItem> clTabItems;
  final String? title;

  /// Header persistente reso sopra la tab bar, al posto di [title], quando
  /// fornito (es. nome entità + sottotitolo). Resta visibile al cambio tab.
  final Widget? titleWidget;
  final bool showDivider;

  /// Colore dell'indicator (sottolineato 3px) del tab attivo.
  /// Default: `theme.primary`.
  final Color? indicatorColor;

  /// Notificato quando cambia la tab attiva (indice), a transizione conclusa,
  /// e una volta dopo il primo frame per sincronizzare la tab iniziale. Utile
  /// per contenuti renderizzati FUORI da CLTabView ma scoped alla tab attiva.
  final ValueChanged<int>? onTabChanged;

  const CLTabView({
    super.key,
    required this.clTabItems,
    this.title,
    this.titleWidget,
    this.showDivider = false,
    this.indicatorColor,
    this.onTabChanged,
  });

  @override
  State<CLTabView> createState() => _CLTabViewState();
}

class _CLTabViewState extends State<CLTabView> with SingleTickerProviderStateMixin {
  late TabController _controller;

  // Tracks which tab indexes have been visited at least once. Inactive,
  // never-visited tabs render as `SizedBox.shrink()` so their (potentially
  // expensive) subtree — e.g. PagedDataTable — isn't built on first paint.
  // Once a tab is visited it stays mounted thanks to maintainState: true.
  final Set<int> _builtIndexes = {0};

  static const Duration _kAnimDuration = Duration(milliseconds: 200);
  static const Curve _kAnimCurve = Curves.easeOutCubic;
  static const double _kActiveUnderline = 3.0;
  static const double _kTabHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.clTabItems.length, vsync: this);
    _controller.addListener(_onTabChanged);
    // Sincronizza la tab iniziale col chiamante (per contenuti scoped esterni).
    if (widget.onTabChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTabChanged!(_controller.index);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CLTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clTabItems.length != widget.clTabItems.length) {
      _controller.removeListener(_onTabChanged);
      _controller.dispose();
      _controller = TabController(length: widget.clTabItems.length, vsync: this);
      _controller.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!_controller.indexIsChanging) {
      _builtIndexes.add(_controller.index);
      setState(() {});
      widget.onTabChanged?.call(_controller.index);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  void _selectIndex(int index) {
    if (_controller.index == index) return;
    _controller.animateTo(index, duration: Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header persistente: titleWidget ricco se fornito, altrimenti title testo.
        if (widget.titleWidget != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: theme.gapSm),
            child: widget.titleWidget!,
          ),
        ] else if (widget.title != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: theme.gapSm),
            child: Text(widget.title!, style: theme.heading6),
          ),
        ],

        // Tab row — solo underline del tab attivo, nessun rail continuo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.clTabItems.length, (index) {
            final item = widget.clTabItems[index];
            final isActive = _controller.index == index;
            return Padding(
              padding: EdgeInsets.only(
                right: index == widget.clTabItems.length - 1 ? 0 : theme.gapLg,
              ),
              child: _CLTabUnderlineItem(
                item: item,
                isActive: isActive,
                onTap: () => _selectIndex(index),
                theme: theme,
                animDuration: _kAnimDuration,
                animCurve: _kAnimCurve,
                activeUnderline: _kActiveUnderline,
                height: _kTabHeight,
                showRail: widget.showDivider,
                indicatorColor: widget.indicatorColor,
              ),
            );
          }),
        ),

        // Divider opzionale sotto la tab bar (oltre a quello di default)
        if (widget.showDivider) ...[
          SizedBox(height: theme.gapSm),
          Divider(color: theme.borderColor, height: 1),
        ],

        SizedBox(height: theme.gapLg),

        // Contenuto: lazy-mount per evitare di costruire tutti i tab al primo
        // paint. Tabs non ancora visitati renderizzano come SizedBox.shrink()
        // — una volta visitati restano in memoria via maintainState: true.
        IndexedStack(
          index: _controller.index,
          children: List.generate(widget.clTabItems.length, (index) {
            if (!_builtIndexes.contains(index)) {
              return const SizedBox.shrink();
            }
            return Visibility(
              visible: _controller.index == index,
              maintainState: true,
              child: widget.clTabItems[index].tabContent,
            );
          }),
        ),
      ],
    );
  }
}

/// Singolo tab in stile underline. Stateful per gestire l'hover senza
/// rebuildare l'intera tab bar.
class _CLTabUnderlineItem extends StatefulWidget {
  final CLTabItem item;
  final bool isActive;
  final VoidCallback onTap;
  final CLTheme theme;
  final Duration animDuration;
  final Curve animCurve;
  final double activeUnderline;
  final double height;
  final bool showRail;
  final Color? indicatorColor;

  const _CLTabUnderlineItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.theme,
    required this.animDuration,
    required this.animCurve,
    required this.activeUnderline,
    required this.height,
    required this.showRail,
    this.indicatorColor,
  });

  @override
  State<_CLTabUnderlineItem> createState() => _CLTabUnderlineItemState();
}

class _CLTabUnderlineItemState extends State<_CLTabUnderlineItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    final Color textColor = widget.isActive ? theme.primaryText : (_hovered ? theme.primaryText : theme.mutedForeground);

    // Underline:
    // - active: 3px primary
    // - inactive + hover: 1px borderColor SOLO se showRail (divider attivo)
    // - inactive: trasparente
    // Quando showRail=false: ZERO linee tranne tab attivo.
    final Color activeUnderlineColor = widget.indicatorColor ?? theme.primary;
    final Color underlineColor = widget.isActive ? activeUnderlineColor : (widget.showRail && _hovered ? theme.borderColor : Colors.transparent);
    final double underlineThickness = widget.isActive ? widget.activeUnderline : 1.0;

    final TextStyle baseStyle = theme.title.override(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textColor,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.animDuration,
          curve: widget.animCurve,
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: theme.gapLg),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: underlineColor,
                width: underlineThickness,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.icon != null) ...[
                AnimatedSwitcher(
                  duration: widget.animDuration,
                  child: Icon(
                    widget.item.icon,
                    key: ValueKey<Color>(textColor),
                    size: theme.iconSizeCompact,
                    color: textColor,
                  ),
                ),
                SizedBox(width: theme.gapIconText),
              ],
              AnimatedDefaultTextStyle(
                duration: widget.animDuration,
                curve: widget.animCurve,
                style: baseStyle,
                child: Text(widget.item.tabName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
