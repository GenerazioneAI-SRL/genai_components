import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'cl_destination.dart';

/// Lista navigazione condivisa da sidebar (desktop) e drawer (tablet/mobile).
/// Scrollabile, rende l'albero `CLDestination` con gruppi/sezioni espandibili.
class CLNavList extends StatelessWidget {
  const CLNavList({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    this.isCompact = false,
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;

  /// True su drawer mobile/tablet (variazioni minori di dimensione testo).
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.gapLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in destinations)
              if (d.isVisible) ..._renderTop(d),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderTop(CLDestination d) {
    if (d.isSectionHeader) {
      return [
        _CLNavSection(
          title: d.label,
          children: [
            for (final c in d.children)
              if (c.isVisible)
                if (c.hasChildren)
                  _CLNavGroup(
                    destination: c,
                    selectedKey: selectedKey,
                    onSelect: onSelect,
                    isCompact: isCompact,
                    depth: 0,
                  )
                else
                  _CLNavTile(
                    destination: c,
                    selected: c.key == selectedKey,
                    onTap: () => onSelect(c),
                  ),
          ],
        ),
      ];
    }
    if (d.hasChildren) {
      return [
        _CLNavGroup(
          destination: d,
          selectedKey: selectedKey,
          onSelect: onSelect,
          isCompact: isCompact,
          depth: 0,
        ),
      ];
    }
    return [
      _CLNavTile(destination: d, selected: d.key == selectedKey, onTap: () => onSelect(d)),
    ];
  }
}

/// Voce foglia con icona + label.
class _CLNavTile extends StatefulWidget {
  const _CLNavTile({required this.destination, required this.selected, required this.onTap});

  final CLDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CLNavTile> createState() => _CLNavTileState();
}

class _CLNavTileState extends State<_CLNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = Sizes.buttonHeightLarge;
    final box = Sizes.buttonHeightDefault;
    final icon = widget.selected ? (widget.destination.selectedIcon ?? widget.destination.icon) : widget.destination.icon;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  top: (h - box) / 2,
                  bottom: (h - box) / 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: widget.selected
                          ? theme.secondaryText.withValues(alpha: 0.14)
                          : _hovered
                              ? theme.secondaryText.withValues(alpha: 0.08)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.radiusSurface),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: Sizes.gapMd),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Sizes.iconSizeDefault,
                        child: icon != null
                            ? Center(
                                child: Icon(
                                  icon,
                                  size: Sizes.iconSizeDefault,
                                  color: widget.selected ? theme.primary : theme.primaryText,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: Sizes.gapMd),
                      Expanded(
                        child: Text(
                          widget.destination.label,
                          style: theme.bodyText.copyWith(
                            color: widget.selected ? theme.primary : theme.primaryText,
                            fontWeight: widget.selected ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: Sizes.gapMd),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Voce foglia dentro un gruppo: senza icona, indentata sotto il rail.
class _CLNavSubTile extends StatefulWidget {
  const _CLNavSubTile({required this.destination, required this.selected, required this.onTap});

  final CLDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CLNavSubTile> createState() => _CLNavSubTileState();
}

class _CLNavSubTileState extends State<_CLNavSubTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = Sizes.buttonHeightLarge;
    final box = Sizes.buttonHeightDefault;
    const double boxLeftMargin = Sizes.gapMd + Sizes.iconSizeDefault / 2 + 0.75 + Sizes.gapLg;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            height: h,
            child: Padding(
              padding: EdgeInsets.only(left: boxLeftMargin, top: (h - box) / 2, bottom: (h - box) / 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.only(left: Sizes.gapMd),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? theme.secondaryText.withValues(alpha: 0.14)
                      : _hovered
                          ? theme.secondaryText.withValues(alpha: 0.08)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(Sizes.radiusControl),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.destination.label,
                  style: theme.bodyText.copyWith(
                    color: widget.selected ? theme.primary : theme.primaryText,
                    fontWeight: widget.selected ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gruppo espandibile (icona + chevron). depth 0 = rail verticale; depth>0 = indentato.
class _CLNavGroup extends StatefulWidget {
  const _CLNavGroup({
    required this.destination,
    required this.selectedKey,
    required this.onSelect,
    required this.isCompact,
    required this.depth,
  });

  final CLDestination destination;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;
  final bool isCompact;
  final int depth;

  @override
  State<_CLNavGroup> createState() => _CLNavGroupState();
}

class _CLNavGroupState extends State<_CLNavGroup> with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _rotationCtrl;
  bool _hovered = false;

  bool get _isSelected => widget.destination.containsKey(widget.selectedKey);

  @override
  void initState() {
    super.initState();
    _expanded = _isSelected;
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _rotationCtrl.forward() : _rotationCtrl.reverse();
  }

  List<Widget> _renderChildren() {
    final out = <Widget>[];
    for (final c in widget.destination.children) {
      if (!c.isVisible) continue;
      if (c.hasChildren) {
        out.add(_CLNavGroup(
          destination: c,
          selectedKey: widget.selectedKey,
          onSelect: widget.onSelect,
          isCompact: widget.isCompact,
          depth: widget.depth + 1,
        ));
      } else {
        out.add(_CLNavSubTile(
          destination: c,
          selected: c.key == widget.selectedKey,
          onTap: () => widget.onSelect(c),
        ));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return widget.depth > 0 ? _buildNested(theme) : _buildTopLevel(theme);
  }

  Widget _buildTopLevel(CLTheme theme) {
    final h = Sizes.buttonHeightLarge;
    final box = Sizes.buttonHeightDefault;
    final icon = widget.destination.icon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: SizedBox(
              height: h,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: (h - box) / 2,
                    bottom: (h - box) / 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: _hovered ? theme.secondaryText.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(Sizes.radiusSurface),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Sizes.gapMd),
                    child: Row(
                      children: [
                        SizedBox(
                          width: Sizes.iconSizeDefault,
                          child: Center(
                            child: icon != null
                                ? Icon(icon,
                                    size: Sizes.iconSizeDefault,
                                    color: _isSelected ? theme.primary : theme.primaryText)
                                : const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: Sizes.gapMd),
                        Expanded(
                          child: Text(
                            widget.destination.label,
                            style: theme.bodyText.copyWith(
                              color: _isSelected ? theme.primary : theme.primaryText,
                              fontWeight: _isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: Sizes.gapMd),
                          child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 0.25)
                                .animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                            child: Icon(Icons.chevron_right,
                                size: 15, color: _isSelected ? theme.primary : theme.primaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: Sizes.gapXs),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Sizes.gapMd + Sizes.iconSizeDefault / 2 - 0.75,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 1.5, color: theme.borderColor),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _renderChildren()),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildNested(CLTheme theme) {
    final h = Sizes.buttonHeightLarge;
    final box = Sizes.buttonHeightDefault;
    final nestedPadding = widget.depth == 1 ? 38.0 : 16.0;

    return Padding(
      padding: EdgeInsets.only(left: nestedPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: SizedBox(
                height: h,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: box,
                    decoration: BoxDecoration(
                      color: _hovered ? theme.secondaryText.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.radiusControl),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: Sizes.gapMd),
                        SizedBox(
                          width: Sizes.iconSizeDefault,
                          child: Center(
                            child: Icon(Icons.folder_outlined,
                                size: 16, color: _isSelected ? theme.primary : theme.primaryText),
                          ),
                        ),
                        const SizedBox(width: Sizes.gapMd),
                        Expanded(
                          child: Text(
                            widget.destination.label,
                            style: theme.bodyLabel.copyWith(
                              color: _isSelected ? theme.primary : theme.primaryText,
                              fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: widget.isCompact ? 14 : 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: Sizes.gapSm),
                          child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 0.25)
                                .animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                            child: Icon(Icons.chevron_right,
                                size: 14, color: _isSelected ? theme.primary : theme.primaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _renderChildren()),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Sezione: titolo collassabile (uppercase iniziale) con figli sotto.
class _CLNavSection extends StatefulWidget {
  const _CLNavSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  State<_CLNavSection> createState() => _CLNavSectionState();
}

class _CLNavSectionState extends State<_CLNavSection> with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: 1);
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _rotationCtrl.forward() : _rotationCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final t = widget.title.isEmpty
        ? widget.title
        : '${widget.title[0].toUpperCase()}${widget.title.substring(1).toLowerCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: Sizes.gapMd, right: Sizes.gapMd, top: Sizes.gapLg, bottom: Sizes.gapSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t,
                      style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.25)
                        .animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                    child: Icon(Icons.chevron_right, size: 13, color: theme.secondaryText),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: widget.children,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
