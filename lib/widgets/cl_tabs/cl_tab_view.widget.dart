import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_tab_item.model.dart';

/// Tab view in stile editoriale: nessun chrome a bottone, label sottolineata
/// quando attiva. Divider 1px continuo sotto la riga delle tab; l'indicatore
/// 3px del tab attivo sovrascrive il divider creando l'effetto "active rail".
///
/// API pubblica invariata:
/// - [clTabItems] elenco tab
/// - [title] titolo opzionale sopra la tab bar
/// - [showDivider] mostra/nasconde un secondo divider sotto la tab bar
class CLTabView extends StatefulWidget {
  final List<CLTabItem> clTabItems;
  final String? title;
  final bool showDivider;

  const CLTabView(
      {super.key,
      required this.clTabItems,
      this.title,
      this.showDivider = false});

  @override
  State<CLTabView> createState() => _CLTabViewState();
}

class _CLTabViewState extends State<CLTabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  static const Duration _kAnimDuration = Duration(milliseconds: 200);
  static const Curve _kAnimCurve = Curves.easeOutCubic;
  static const double _kActiveUnderline = 3.0;
  static const double _kTabHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.clTabItems.length, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant CLTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clTabItems.length != widget.clTabItems.length) {
      _controller.removeListener(_onTabChanged);
      _controller.dispose();
      _controller =
          TabController(length: widget.clTabItems.length, vsync: this);
      _controller.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!_controller.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  void _selectIndex(int index) {
    if (_controller.index == index) return;
    _controller.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Titolo opzionale
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: CLSizes.gapSm),
            child: Text(widget.title!, style: theme.bodyLabel),
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
                  right: index == widget.clTabItems.length - 1
                      ? 0
                      : CLSizes.gapMd,
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
                ),
              );
            }),
        ),

        // Divider opzionale sotto la tab bar (oltre a quello di default)
        if (widget.showDivider) ...[
          const SizedBox(height: CLSizes.gapSm),
          Divider(color: theme.borderColor, height: 1),
        ],

        const SizedBox(height: CLSizes.gapSm),

        // Contenuto (IndexedStack per mantenere lo stato)
        IndexedStack(
          index: _controller.index,
          children: List.generate(widget.clTabItems.length, (index) {
            return Visibility(
                visible: _controller.index == index,
                maintainState: true,
                child: widget.clTabItems[index].tabContent);
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

  const _CLTabUnderlineItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.theme,
    required this.animDuration,
    required this.animCurve,
    required this.activeUnderline,
    required this.height,
  });

  @override
  State<_CLTabUnderlineItem> createState() => _CLTabUnderlineItemState();
}

class _CLTabUnderlineItemState extends State<_CLTabUnderlineItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    final Color textColor = widget.isActive
        ? theme.primaryText
        : (_hovered ? theme.primaryText : theme.mutedForeground);

    // Underline:
    // - active: 3px primary
    // - inactive + hover: 1px borderColor
    // - inactive: trasparente (il divider continuo della row gestisce la base)
    final Color underlineColor = widget.isActive
        ? theme.primary
        : (_hovered ? theme.borderColor : Colors.transparent);
    final double underlineThickness =
        widget.isActive ? widget.activeUnderline : 1.0;

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
          padding:
              const EdgeInsets.symmetric(horizontal: CLSizes.gapLg),
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
                    size: CLSizes.iconSizeCompact,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: CLSizes.gapSm),
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
