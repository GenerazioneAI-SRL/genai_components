import 'package:flutter/material.dart';
import 'package:genai_components/gen/theme/gen_tokens.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'gen_destination.dart';
import 'gen_nav_tile.widget.dart';

/// Larghezza del rail verticale dei gruppi; il nudge di mezzo pixel lo centra.
const double _kRailWidth = 1.5;

/// Indentazione delle voci foglia sotto un gruppo: allineate appena oltre il
/// rail (centro icona parent + mezzo rail + un gap). Geometria dell'altezza
/// riga/pill ora vive in [GenNavTile] (buttonHeightCompact + gapXs).
const double _kGroupIndent = GenSizes.gapMd + GenSizes.iconSizeDefault / 2 + _kRailWidth / 2 + GenSizes.gapLg;

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
  });

  final List<GenDestination> destinations;
  final String? selectedKey;
  final ValueChanged<GenDestination> onSelect;

  /// Rail icon-only: voci senza label, con tooltip; il tap su un gruppo apre un
  /// flyout ([GenContextMenu]) di lato con le voci interne (invece di espandere
  /// inline). La riespansione completa resta sul toggle dello shell.
  final bool collapsed;

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
    // Gate: sopprime i tooltip del rail durante lo scroll (evita il reset della
    // ScrollPosition causato dal tooltip che compare mentre le icone scorrono).
    return GenNavScrollTooltipGate(
      child: SingleChildScrollView(
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
      ),
    );
  }

  /// Rendering rail icon-only: sezioni/gruppi appiattiti a icone. Un gruppo, se
  /// toccato, apre un flyout laterale con le voci interne; una foglia naviga.
  List<Widget> _renderCollapsed(GenDestination d) {
    if (d.isSectionHeader) {
      return [
        for (final c in d.children)
          if (c.isVisible) ..._renderCollapsed(c),
      ];
    }
    if (d.hasChildren) {
      return [
        _GenNavRailGroup(destination: d, selectedKey: selectedKey, onSelect: onSelect),
      ];
    }
    return [
      _railTile(d, selected: d.key == selectedKey, onTap: () => onSelect(d)),
    ];
  }

  /// Voce rail icon-only: [GenNavRailTile] (ghost + tooltip a destra).
  Widget _railTile(GenDestination d, {required bool selected, required VoidCallback onTap}) => GenNavRailTile(
        tooltip: d.label,
        selected: selected,
        onTap: onTap,
        iconBuilder: (color, size) => d.buildIcon(color, size) ?? const SizedBox.shrink(),
      );

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
                  _leafTile(c),
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
    return [_leafTile(d)];
  }

  /// Voce foglia top-level: [GenNavTile] con slot icona sempre riservato (le
  /// foglie senza icona restano allineate a quelle con icona).
  Widget _leafTile(GenDestination d) => GenNavTile(
        label: d.label,
        selected: d.key == selectedKey,
        onTap: () => onSelect(d),
        iconBuilder: (color, size) => d.buildIcon(color, size) ?? const SizedBox.shrink(),
      );
}

/// Voce foglia dentro un gruppo: [GenNavTile] senza icona, indentata di
/// [_kGroupIndent] così si allinea appena oltre il rail verticale del gruppo.
GenNavTile _subTile(GenDestination d, {required bool selected, required VoidCallback onTap}) => GenNavTile(
      label: d.label,
      selected: selected,
      onTap: onTap,
      indent: _kGroupIndent,
    );

/// Gruppo nel RAIL (sidebar collassata): icona [GenNavRailTile] che al tap apre
/// un [GenContextMenu] di lato (a destra) con le voci interne. I sotto-gruppi
/// diventano submenu annidati; le foglie navigano e chiudono il flyout. Sostituisce
/// l'espansione inline, impossibile quando la sidebar è a sole icone.
class _GenNavRailGroup extends StatefulWidget {
  const _GenNavRailGroup({required this.destination, required this.selectedKey, required this.onSelect});

  final GenDestination destination;
  final String? selectedKey;
  final ValueChanged<GenDestination> onSelect;

  @override
  State<_GenNavRailGroup> createState() => _GenNavRailGroupState();
}

class _GenNavRailGroupState extends State<_GenNavRailGroup> {
  final GenPopoverController _menu = GenPopoverController();

  @override
  void initState() {
    super.initState();
    // Rebuild all'apertura/chiusura del flyout → l'icona passa a strongHover.
    _menu.addListener(_onMenuChanged);
  }

  void _onMenuChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _menu.removeListener(_onMenuChanged);
    _menu.dispose();
    super.dispose();
  }

  /// Mappa i figli visibili in [GenContextMenuItem] (ricorsivo: i sotto-gruppi
  /// diventano submenu via `items:`). Le foglie navigano e chiudono il flyout.
  List<Widget> _items(GenTokens theme, GenDestination parent) {
    final out = <Widget>[];
    for (final c in parent.children) {
      if (!c.isVisible) continue;
      final selected = c.hasChildren ? c.containsKey(widget.selectedKey) : c.key == widget.selectedKey;
      final fg = selected ? theme.primary : theme.primaryText;
      final leading = c.buildIcon(fg, GenSizes.iconSizeCompact);
      final label = Text(
        c.label,
        style: selected ? TextStyle(color: theme.primary, fontWeight: FontWeight.w500) : null,
      );
      out.add(
        c.hasChildren
            ? GenContextMenuItem(leading: leading, items: _items(theme, c), child: label)
            : GenContextMenuItem(
                leading: leading,
                onPressed: () {
                  _menu.hide();
                  widget.onSelect(c);
                },
                child: label,
              ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    return GenNavRailTile(
      tooltip: widget.destination.label,
      selected: widget.destination.containsKey(widget.selectedKey),
      strongHover: _menu.isOpen, // flyout aperto → hover primary pieno
      enableTooltip: !_menu.isOpen, // flyout aperto → niente tooltip (si sovrappone)
      onTap: _menu.toggle,
      iconBuilder: (color, size) => widget.destination.buildIcon(color, size) ?? const SizedBox.shrink(),
      // Il menu avvolge SOLO il bottone compatto (via wrap) → esce alla stessa
      // distanza del tooltip: bordo destro del bottone + gapSm, non del rail.
      // ShadAnchor ha i nomi invertiti: childAlignment = punto sul follower
      // (menu), overlayAlignment = punto sul target (bottone) → menu.topLeft
      // ancorato a bottone.topRight.
      wrap: (compact) => GenContextMenu(
        controller: _menu,
        anchor: const GenAnchor(
          childAlignment: Alignment.topLeft,
          overlayAlignment: Alignment.topRight,
          offset: Offset(GenSizes.gapSm, 0),
        ),
        items: _items(theme, widget.destination),
        child: compact,
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
        out.add(_subTile(c, selected: c.key == widget.selectedKey, onTap: () => widget.onSelect(c)));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header gruppo: mai "selected" (non si evidenzia se un figlio è attivo).
        // Se aperto, strongHover → hover primary pieno + bianco. Il chevron NON
        // ha colore esplicito: eredita dall'IconTheme del tile (reattivo).
        GenNavTile(
          label: widget.destination.label,
          selected: false,
          strongHover: _expanded,
          onTap: _toggle,
          iconBuilder: (color, size) => widget.destination.buildIcon(color, size) ?? const SizedBox.shrink(),
          trailing: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.25)
                .animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
            child: const Icon(Icons.chevron_right, size: 15),
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
    // 38 ≈ _kGroupIndent arrotondato (indent 1° livello); poi +16 per livello.
    final nestedPadding = widget.depth == 1 ? 38.0 : GenSizes.gapLg;

    return Padding(
      padding: EdgeInsets.only(left: nestedPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header sotto-gruppo: icona cartella (compatta nello slot standard) +
          // chevron. L'indent orizzontale lo dà il Padding esterno. Mai selected;
          // strongHover se aperto. Icona e chevron ricevono/ereditano il colore.
          GenNavTile(
            label: widget.destination.label,
            selected: false,
            strongHover: _expanded,
            onTap: _toggle,
            iconBuilder: (color, size) => Icon(Icons.folder_outlined, size: GenSizes.iconSizeCompact, color: color),
            trailing: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.25)
                  .animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
              child: const Icon(Icons.chevron_right, size: 14),
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
