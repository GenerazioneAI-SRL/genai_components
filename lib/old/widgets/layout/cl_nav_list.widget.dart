import 'package:flutter/material.dart';
import 'package:genai_components/old/cl_theme.dart';
import 'package:genai_components/old/layout/constants/sizes.constant.dart';
import 'cl_destination.dart';

/// Larghezza del rail verticale dei gruppi; il nudge di mezzo pixel lo centra.
const double _kRailWidth = 1.5;

/// Indentazione delle voci foglia sotto un gruppo: allineate appena oltre il
/// rail (centro icona parent + mezzo rail + un gap).
const double _kGroupIndent = Sizes.gapMd + Sizes.iconSizeDefault / 2 + _kRailWidth / 2 + Sizes.gapLg;

/// Voci menu compatte (unico punto di tuning): pill = `buttonHeightCompact` (32),
/// spazio tra voci = `gapSm` (8) → riga alta 40 (prima 40+8=48). Icone/geometria
/// gruppi invariate → nessun disallineamento del rail.
const double _kNavRowBox = Sizes.buttonHeightCompact;
const double _kNavRowGap = Sizes.gapSm;

/// Lista navigazione condivisa da sidebar (desktop) e drawer (tablet/mobile).
/// Scrollabile, rende l'albero `CLDestination` con gruppi/sezioni espandibili.
class CLNavList extends StatelessWidget {
  const CLNavList({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    this.isCompact = false,
    this.forceExpandedKey,
    this.padding = const EdgeInsets.all(Sizes.gapLg),
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;

  /// Padding interno della lista. Default Lg su tutti i lati; lo shell lo
  /// sovrascrive con top/bottom = altezza barre frosted per far scorrere le
  /// voci sotto il vetro smerigliato di header/footer.
  final EdgeInsets padding;

  /// True su drawer mobile/tablet (variazioni minori di dimensione testo).
  final bool isCompact;

  /// Gruppo da forzare aperto oltre a quello della rotta selezionata. Serve al
  /// drawer aperto da un tap su gruppo del rail: si apre già espanso su quel
  /// gruppo (es. "Impostazioni HR") anche se non è la rotta corrente.
  final String? forceExpandedKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: padding,
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
                    forceExpandedKey: forceExpandedKey,
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
          forceExpandedKey: forceExpandedKey,
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
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    final iconWidget = widget.destination.buildIcon(
      widget.selected ? theme.primary : theme.primaryText,
      Sizes.iconSizeDefault,
    );

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
                          ? theme.secondaryText.withValues(alpha: theme.opacityMuted)
                          : _hovered
                              ? theme.secondaryText.withValues(alpha: theme.opacitySoft)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.radiusControl),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: Sizes.gapMd),
                  child: Row(
                    children: [
                      SizedBox(
                        width: Sizes.iconSizeDefault,
                        child: iconWidget != null ? Center(child: iconWidget) : null,
                      ),
                      const SizedBox(width: Sizes.gapMd),
                      Expanded(
                        child: Text(
                          widget.destination.label,
                          style: theme.title.copyWith(
                            fontSize: theme.bodyText.fontSize,
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
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    const double boxLeftMargin = _kGroupIndent;

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
                      ? theme.secondaryText.withValues(alpha: theme.opacityMuted)
                      : _hovered
                          ? theme.secondaryText.withValues(alpha: theme.opacitySoft)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(Sizes.radiusControl),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.destination.label,
                  style: theme.title.copyWith(
                    fontSize: theme.bodyText.fontSize,
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
    this.forceExpandedKey,
  });

  final CLDestination destination;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;
  final bool isCompact;
  final int depth;
  final String? forceExpandedKey;

  @override
  State<_CLNavGroup> createState() => _CLNavGroupState();
}

class _CLNavGroupState extends State<_CLNavGroup> with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _rotationCtrl;
  bool _hovered = false;

  bool get _isSelected => widget.destination.containsKey(widget.selectedKey);

  /// Espandi se contiene la rotta selezionata OPPURE se è il gruppo forzato
  /// (drawer aperto da tap su gruppo del rail).
  bool get _shouldExpand =>
      _isSelected ||
      (widget.forceExpandedKey != null &&
          (widget.destination.key == widget.forceExpandedKey ||
              widget.destination.containsKey(widget.forceExpandedKey)));

  @override
  void initState() {
    super.initState();
    _expanded = _shouldExpand;
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
    final opening = !_expanded;
    setState(() => _expanded = opening);
    opening ? _rotationCtrl.forward() : _rotationCtrl.reverse();
  }

  @override
  void didUpdateWidget(_CLNavGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Navigazione esterna (deep-link/command palette) verso un figlio di un
    // gruppo collassato, o richiesta di apertura forzata (tap gruppo rail) →
    // espandi così la voce attiva/forzata resta visibile.
    if (_shouldExpand && !_expanded) {
      _expanded = true;
      _rotationCtrl.forward();
    }
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
          forceExpandedKey: widget.forceExpandedKey,
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
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    final iconWidget = widget.destination.buildIcon(
      _isSelected ? theme.primary : theme.primaryText,
      Sizes.iconSizeDefault,
    );

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
                        color: _hovered ? theme.secondaryText.withValues(alpha: theme.opacitySoft) : Colors.transparent,
                        borderRadius: BorderRadius.circular(Sizes.radiusControl),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Sizes.gapMd),
                    child: Row(
                      children: [
                        SizedBox(
                          width: Sizes.iconSizeDefault,
                          child: Center(child: iconWidget ?? const SizedBox.shrink()),
                        ),
                        const SizedBox(width: Sizes.gapMd),
                        Expanded(
                          child: Text(
                            widget.destination.label,
                            style: theme.title.copyWith(
                              fontSize: theme.bodyText.fontSize,
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
                        left: Sizes.gapMd + Sizes.iconSizeDefault / 2 - _kRailWidth / 2,
                        top: 0,
                        bottom: 0,
                        child: Container(width: _kRailWidth, color: theme.borderColor),
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
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    // 38 ≈ _kGroupIndent arrotondato (indent 1° livello); poi +16 per livello.
    final nestedPadding = widget.depth == 1 ? 38.0 : Sizes.gapLg;

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
                      color: _hovered ? theme.secondaryText.withValues(alpha: theme.opacitySoft) : Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.radiusControl),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: Sizes.gapMd),
                        SizedBox(
                          width: Sizes.iconSizeDefault,
                          child: Center(
                            child: Icon(Icons.folder_outlined,
                                size: Sizes.iconSizeCompact, color: _isSelected ? theme.primary : theme.primaryText),
                          ),
                        ),
                        const SizedBox(width: Sizes.gapMd),
                        Expanded(
                          child: Text(
                            widget.destination.label,
                            style: theme.title.copyWith(
                              color: _isSelected ? theme.primary : theme.primaryText,
                              fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: theme.bodyText.fontSize,
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
    final opening = !_expanded;
    setState(() => _expanded = opening);
    opening ? _rotationCtrl.forward() : _rotationCtrl.reverse();
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
                      style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: theme.bodyText.fontSize),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.25)
                        .animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                    child: Icon(Icons.chevron_right, size: 15, color: theme.secondaryText),
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
