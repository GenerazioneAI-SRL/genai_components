import 'package:flutter/material.dart';
import 'package:genai_components/gen/theme/gen_tokens.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'gen_destination.dart';

/// Larghezza del rail verticale dei gruppi; il nudge di mezzo pixel lo centra.
const double _kRailWidth = 1.5;

/// Indentazione delle voci foglia sotto un gruppo: allineate appena oltre il
/// rail (centro icona parent + mezzo rail + un gap).
const double _kGroupIndent = GenSizes.gapMd + GenSizes.iconSizeDefault / 2 + _kRailWidth / 2 + GenSizes.gapLg;

/// Voci menu compatte (unico punto di tuning): pill = `buttonHeightCompact` (32),
/// spazio tra voci = `gapSm` (8) → riga alta 40 (prima 40+8=48). Icone/geometria
/// gruppi invariate → nessun disallineamento del rail.
const double _kNavRowBox = GenSizes.buttonHeightCompact;
const double _kNavRowGap = GenSizes.gapSm;

/// Lista navigazione condivisa da sidebar (desktop) e drawer (tablet/mobile).
/// Scrollabile, rende l'albero `GenDestination` con gruppi/sezioni espandibili.
class GenNavList extends StatelessWidget {
  const GenNavList({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    this.isCompact = false,
    this.forceExpandedKey,
    this.padding = const EdgeInsets.all(GenSizes.gapLg),
    this.collapsed = false,
    this.onExpandRequest,
  });

  final List<GenDestination> destinations;
  final String? selectedKey;
  final ValueChanged<GenDestination> onSelect;

  /// Rail icon-only: voci senza label, con tooltip; il tap su un gruppo chiede
  /// la riespansione ([onExpandRequest]) invece di espandere inline.
  final bool collapsed;
  final VoidCallback? onExpandRequest;

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
              if (d.isVisible) ...(collapsed ? _renderCollapsed(d) : _renderTop(d)),
          ],
        ),
      ),
    );
  }

  /// Rendering rail icon-only: sezioni/gruppi appiattiti a icone. Un gruppo, se
  /// toccato, chiede la riespansione della sidebar; una foglia naviga.
  List<Widget> _renderCollapsed(GenDestination d) {
    if (d.isSectionHeader) {
      return [
        for (final c in d.children)
          if (c.isVisible) ..._renderCollapsed(c),
      ];
    }
    if (d.hasChildren) {
      return [
        _GenNavIconTile(
          destination: d,
          selected: d.containsKey(selectedKey),
          onTap: onExpandRequest ?? () => onSelect(d),
        ),
      ];
    }
    return [
      _GenNavIconTile(destination: d, selected: d.key == selectedKey, onTap: () => onSelect(d)),
    ];
  }

  List<Widget> _renderTop(GenDestination d) {
    if (d.isSectionHeader) {
      return [
        _GenNavSection(
          title: d.label,
          children: [
            for (final c in d.children)
              if (c.isVisible)
                if (c.hasChildren)
                  _GenNavGroup(
                    destination: c,
                    selectedKey: selectedKey,
                    onSelect: onSelect,
                    isCompact: isCompact,
                    depth: 0,
                    forceExpandedKey: forceExpandedKey,
                  )
                else
                  _GenNavTile(
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
        _GenNavGroup(
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
      _GenNavTile(destination: d, selected: d.key == selectedKey, onTap: () => onSelect(d)),
    ];
  }
}

/// Voce foglia con icona + label.
class _GenNavTile extends StatefulWidget {
  const _GenNavTile({required this.destination, required this.selected, required this.onTap});

  final GenDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_GenNavTile> createState() => _GenNavTileState();
}

class _GenNavTileState extends State<_GenNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    final iconWidget = widget.destination.buildIcon(
      widget.selected ? theme.primary : theme.primaryText,
      GenSizes.iconSizeDefault,
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
                      borderRadius: BorderRadius.circular(GenSizes.radiusControl),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: GenSizes.gapMd),
                  child: Row(
                    children: [
                      SizedBox(
                        width: GenSizes.iconSizeDefault,
                        child: iconWidget != null ? Center(child: iconWidget) : null,
                      ),
                      const SizedBox(width: GenSizes.gapMd),
                      Expanded(
                        child: Text(
                          widget.destination.label,
                          style: theme.smallText.copyWith(
                            color: widget.selected ? theme.primary : theme.primaryText,
                            fontWeight: widget.selected ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: GenSizes.gapMd),
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

/// Voce rail icon-only (sidebar collassata): `GenIconButton.ghost` (hover +
/// tooltip nativi, compatibili con ShadMouseArea), selezione via backgroundColor.
/// Tooltip = label, esce a destra dell'icona.
class _GenNavIconTile extends StatelessWidget {
  const _GenNavIconTile({required this.destination, required this.selected, required this.onTap});

  final GenDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    final iconWidget = destination.buildIcon(
      selected ? theme.primary : theme.primaryText,
      GenSizes.iconSizeCompact,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GenSizes.gapXs),
      // Center: la Column della lista è stretch → senza Center il bottone si
      // allargherebbe a tutta la rail. Il GenTooltip avvolge SOLO il bottone
      // (compatto) così l'anchor lo misura e il tooltip esce accanto.
      child: Center(
        child: GenTooltip(
          waitDuration: const Duration(milliseconds: 350),
          // Esce a DESTRA dell'icona (rail a sinistra). ShadAnchor ha i nomi
          // invertiti → childAlignment=left / overlayAlignment=right per destra.
          anchor: const GenAnchor(
            childAlignment: Alignment.centerLeft,
            overlayAlignment: Alignment.centerRight,
            offset: Offset(8, 0),
          ),
          builder: (_) => Text(destination.label),
          child: GenIconButton.ghost(
            onPressed: onTap,
            width: GenSizes.buttonHeightCompact,
            height: GenSizes.buttonHeightCompact,
            iconSize: GenSizes.iconSizeCompact,
            backgroundColor: selected ? theme.secondaryText.withValues(alpha: theme.opacityMuted) : null,
            icon: iconWidget ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// Voce foglia dentro un gruppo: senza icona, indentata sotto il rail.
class _GenNavSubTile extends StatefulWidget {
  const _GenNavSubTile({required this.destination, required this.selected, required this.onTap});

  final GenDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_GenNavSubTile> createState() => _GenNavSubTileState();
}

class _GenNavSubTileState extends State<_GenNavSubTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
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
                padding: const EdgeInsets.only(left: GenSizes.gapMd),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? theme.secondaryText.withValues(alpha: theme.opacityMuted)
                      : _hovered
                          ? theme.secondaryText.withValues(alpha: theme.opacitySoft)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(GenSizes.radiusControl),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.destination.label,
                  style: theme.smallText.copyWith(
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
class _GenNavGroup extends StatefulWidget {
  const _GenNavGroup({
    required this.destination,
    required this.selectedKey,
    required this.onSelect,
    required this.isCompact,
    required this.depth,
    this.forceExpandedKey,
  });

  final GenDestination destination;
  final String? selectedKey;
  final ValueChanged<GenDestination> onSelect;
  final bool isCompact;
  final int depth;
  final String? forceExpandedKey;

  @override
  State<_GenNavGroup> createState() => _GenNavGroupState();
}

class _GenNavGroupState extends State<_GenNavGroup> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(_GenNavGroup oldWidget) {
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
        out.add(_GenNavGroup(
          destination: c,
          selectedKey: widget.selectedKey,
          onSelect: widget.onSelect,
          isCompact: widget.isCompact,
          depth: widget.depth + 1,
          forceExpandedKey: widget.forceExpandedKey,
        ));
      } else {
        out.add(_GenNavSubTile(
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
    final theme = GenTokens.of(context);
    return widget.depth > 0 ? _buildNested(theme) : _buildTopLevel(theme);
  }

  Widget _buildTopLevel(GenTokens theme) {
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    final iconWidget = widget.destination.buildIcon(
      _isSelected ? theme.primary : theme.primaryText,
      GenSizes.iconSizeDefault,
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
                        borderRadius: BorderRadius.circular(GenSizes.radiusControl),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: GenSizes.gapMd),
                    child: Row(
                      children: [
                        SizedBox(
                          width: GenSizes.iconSizeDefault,
                          child: Center(child: iconWidget ?? const SizedBox.shrink()),
                        ),
                        const SizedBox(width: GenSizes.gapMd),
                        Expanded(
                          child: Text(
                            widget.destination.label,
                            style: theme.smallText.copyWith(
                              color: _isSelected ? theme.primary : theme.primaryText,
                              fontWeight: _isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: GenSizes.gapMd),
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
                  padding: const EdgeInsets.only(bottom: GenSizes.gapXs),
                  child: Stack(
                    children: [
                      Positioned(
                        left: GenSizes.gapMd + GenSizes.iconSizeDefault / 2 - _kRailWidth / 2,
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

  Widget _buildNested(GenTokens theme) {
    // Riga compatta: vedi _kNavRowBox/_kNavRowGap (pill 32 + gap 4 = 36).
    final h = _kNavRowBox + _kNavRowGap;
    final box = _kNavRowBox;
    // 38 ≈ _kGroupIndent arrotondato (indent 1° livello); poi +16 per livello.
    final nestedPadding = widget.depth == 1 ? 38.0 : GenSizes.gapLg;

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
                      borderRadius: BorderRadius.circular(GenSizes.radiusControl),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: GenSizes.gapMd),
                        SizedBox(
                          width: GenSizes.iconSizeDefault,
                          child: Center(
                            child: Icon(Icons.folder_outlined,
                                size: GenSizes.iconSizeCompact, color: _isSelected ? theme.primary : theme.primaryText),
                          ),
                        ),
                        const SizedBox(width: GenSizes.gapMd),
                        Expanded(
                          child: Text(
                            widget.destination.label,
                            style: theme.smallText.copyWith(
                              color: _isSelected ? theme.primary : theme.primaryText,
                              fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: GenSizes.gapSm),
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
class _GenNavSection extends StatefulWidget {
  const _GenNavSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  State<_GenNavSection> createState() => _GenNavSectionState();
}

class _GenNavSectionState extends State<_GenNavSection> with SingleTickerProviderStateMixin {
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
    final theme = GenTokens.of(context);
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
                  left: GenSizes.gapMd, right: GenSizes.gapMd, top: GenSizes.gapLg, bottom: GenSizes.gapSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t,
                      style: theme.smallLabel.copyWith(fontWeight: FontWeight.w600),
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
