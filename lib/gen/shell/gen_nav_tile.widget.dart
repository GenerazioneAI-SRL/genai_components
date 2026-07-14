import 'package:flutter/material.dart';
import 'package:genai_components/gen/theme/gen_tokens.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';

/// Flag "scroll in corso" propagato ai tile discendenti: mentre è true i tooltip
/// del rail restano soppressi. Serve perché il tooltip istantaneo, mostrandosi
/// mentre le icone scorrono sotto il cursore, disturba la ScrollPosition (reset
/// a metà drag → "scatto"). Vedi [GenNavScrollTooltipGate].
class _NavScrolling extends InheritedWidget {
  const _NavScrolling({required this.scrolling, required super.child});

  final bool scrolling;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_NavScrolling>()?.scrolling ?? false;

  @override
  bool updateShouldNotify(_NavScrolling oldWidget) => oldWidget.scrolling != scrolling;
}

/// Avvolge un'area scrollabile di navigazione: ascolta le notifiche di scroll e,
/// mentre il gesto è attivo, propaga `scrolling=true` ai [GenNavRailTile]
/// discendenti così sopprimono il tooltip (che altrimenti farebbe scattare lo
/// scroll). Non tocca la ScrollPosition: rebuilda solo i tile (start/end).
class GenNavScrollTooltipGate extends StatefulWidget {
  const GenNavScrollTooltipGate({super.key, required this.child});

  final Widget child;

  @override
  State<GenNavScrollTooltipGate> createState() => _GenNavScrollTooltipGateState();
}

class _GenNavScrollTooltipGateState extends State<GenNavScrollTooltipGate> {
  bool _scrolling = false;

  void _set(bool v) {
    if (_scrolling != v && mounted) setState(() => _scrolling = v);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollStartNotification) {
          _set(true);
        } else if (n is ScrollEndNotification) {
          _set(false);
        }
        return false;
      },
      child: _NavScrolling(scrolling: _scrolling, child: widget.child),
    );
  }
}

/// Altezza della "pill" cliccabile di una voce di menu desktop.
const double _kTileHeight = GenSizes.buttonHeightCompact; // 32
/// Gap verticale sopra/sotto ogni voce → riga effettiva = 32 + 2×4 = 40.
const double _kTileVGap = GenSizes.gapXs; // 4

/// Opacità del `primary` per l'hover "soft" (voci a riposo, dropdown chiusi).
const double _kHoverPrimaryAlpha = 0.12;

/// Colori risolti di una voce nei suoi stati (rest/hover), condivisi da tile
/// desktop e icona rail così la logica vive in un posto solo.
///
/// Modello:
/// - [selected] (È la rotta corrente) → sfondo `primary` PIENO + contenuto
///   bianco, persistente (anche in hover).
/// - [strongHover] (header di un dropdown APERTO) → in hover diventa `primary`
///   pieno + bianco; a riposo resta neutro.
/// - altrimenti → a riposo trasparente/neutro; in hover `primary` opacizzato,
///   contenuto neutro.
class _NavTileColors {
  const _NavTileColors({
    required this.restBackground,
    required this.hoverBackground,
    required this.restForeground,
    required this.hoverForeground,
  });

  final Color restBackground;
  final Color hoverBackground;
  final Color restForeground;
  final Color hoverForeground;

  factory _NavTileColors.resolve(GenTokens t, {required bool selected, required bool strongHover}) {
    final onPrimary = t.primaryForeground;
    if (selected) {
      return _NavTileColors(
        restBackground: t.primary,
        hoverBackground: t.primary,
        restForeground: onPrimary,
        hoverForeground: onPrimary,
      );
    }
    return _NavTileColors(
      restBackground: Colors.transparent,
      hoverBackground: strongHover ? t.primary : t.primary.withValues(alpha: _kHoverPrimaryAlpha),
      restForeground: t.primaryText,
      hoverForeground: strongHover ? onPrimary : t.primaryText,
    );
  }

  Color foreground(bool hovered) => hovered ? hoverForeground : restForeground;
}

/// Voce di menu DESKTOP condivisa da sidebar/drawer (voci azienda) e dai menu
/// contestuali (voci cliente): un [GenButton] ghost full-width con icona
/// opzionale, label ed eventuale trailing (es. chevron dei gruppi).
///
/// Stati (vedi [_NavTileColors]): [selected] = rotta corrente (primary pieno +
/// bianco), [strongHover] = header di dropdown aperto (hover primary pieno +
/// bianco). Gli header dei gruppi NON usano [selected]: non si evidenziano
/// quando un figlio è attivo.
class GenNavTile extends StatefulWidget {
  const GenNavTile({
    super.key,
    required this.label,
    required this.onTap,
    this.iconBuilder,
    this.trailing,
    this.selected = false,
    this.strongHover = false,
    this.indent = 0,
  });

  final String label;
  final VoidCallback onTap;

  /// Costruttore dell'icona leading; riceve il colore già risolto (reattivo
  /// all'hover) e la size di default. Null = nessuna icona (voce foglia
  /// indentata sotto un gruppo).
  final Widget Function(Color color, double size)? iconBuilder;

  /// Widget di coda (es. chevron rotante di un gruppo). NON passare un colore
  /// esplicito: eredita dall'IconTheme del bottone → reagisce a hover/stato.
  final Widget? trailing;

  /// La voce È la rotta corrente → primary pieno + contenuto bianco.
  final bool selected;

  /// Header di un dropdown aperto → in hover primary pieno + bianco.
  final bool strongHover;

  /// Padding sinistro esterno (indentazione sotto un gruppo).
  final double indent;

  @override
  State<GenNavTile> createState() => _GenNavTileState();
}

class _GenNavTileState extends State<GenNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final c = _NavTileColors.resolve(t, selected: widget.selected, strongHover: widget.strongHover);
    // L'icona cambia colore in hover SOLO se rest≠hover fg (caso strongHover).
    // Altrimenti niente tracking hover: eviterebbe rebuild inutili che, durante
    // lo scroll (enter/exit a raffica), fanno scattare la lista. Lo sfondo hover
    // lo gestisce comunque GenButton internamente.
    final reactsToHover = c.restForeground != c.hoverForeground;
    final iconColor = reactsToHover ? c.foreground(_hovered) : c.restForeground;

    return Padding(
      padding: EdgeInsets.only(left: widget.indent, top: _kTileVGap, bottom: _kTileVGap),
      child: GenButton.ghost(
        onPressed: widget.onTap,
        onHoverChange: reactsToHover ? (v) => setState(() => _hovered = v) : null,
        width: double.infinity,
        height: _kTileHeight,
        expands: true, // la label riempie la riga → trailing a destra + ellipsis
        mainAxisAlignment: MainAxisAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: GenSizes.gapMd),
        gap: GenSizes.gapMd,
        backgroundColor: c.restBackground,
        hoverBackgroundColor: c.hoverBackground,
        foregroundColor: c.restForeground,
        hoverForegroundColor: c.hoverForeground,
        // Label pinnata a smallText (12): il default button è small (14).
        textStyle: t.smallText.copyWith(fontWeight: widget.selected ? FontWeight.w500 : FontWeight.normal),
        leading: widget.iconBuilder == null
            ? null
            : SizedBox(
                width: GenSizes.iconSizeDefault,
                child: Center(child: widget.iconBuilder!(iconColor, GenSizes.iconSizeDefault)),
              ),
        trailing: widget.trailing,
        child: Text(
          widget.label,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

/// Voce di menu RAIL (sidebar collassata) condivisa: un [GenIconButton] ghost
/// icon-only con tooltip che esce a destra. Stessi stati di [GenNavTile]:
/// [selected] = primary pieno + icona bianca; [strongHover] (flyout aperto) =
/// hover primary pieno; altrimenti hover primary opacizzato.
class GenNavRailTile extends StatefulWidget {
  const GenNavRailTile({
    super.key,
    required this.iconBuilder,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
    this.strongHover = false,
    this.tooltipOffset = const Offset(8, 0),
    this.enableTooltip = true,
    this.wrap,
  });

  /// Costruttore icona; riceve colore risolto (reattivo all'hover) e size
  /// compatta. Un builder (non un Widget) così il colore resta centralizzato.
  final Widget Function(Color color, double size) iconBuilder;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;

  /// Icona del gruppo col flyout aperto → in hover primary pieno + bianco.
  final bool strongHover;

  /// Offset del tooltip rispetto all'icona (esce a destra del rail).
  final Offset tooltipOffset;

  /// Mostra il tooltip all'hover. Va messo a false quando un overlay (es. il
  /// flyout del gruppo) è aperto: tooltip e flyout escono nello stesso punto e
  /// il tooltip coprirebbe le voci.
  final bool enableTooltip;

  /// Avvolge il nodo COMPATTO (bottone, 32px) prima del centraggio nel rail.
  /// Serve per ancorare un overlay (es. [GenContextMenu] del gruppo) al bottone
  /// da 32px e non al tile full-width → stessa distanza del tooltip.
  final Widget Function(Widget compact)? wrap;

  @override
  State<GenNavRailTile> createState() => _GenNavRailTileState();
}

class _GenNavRailTileState extends State<GenNavRailTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final c = _NavTileColors.resolve(t, selected: widget.selected, strongHover: widget.strongHover);
    // Traccia l'hover SOLO se l'icona cambia colore (caso strongHover); così le
    // voci normali non fanno rebuild a ogni enter/exit → niente scatto in scroll.
    final reactsToHover = c.restForeground != c.hoverForeground;
    final iconColor = reactsToHover ? c.foreground(_hovered) : c.restForeground;

    // Nodo COMPATTO da 32px: è questo che [wrap] (flyout) e il tooltip misurano
    // → gli overlay escono accanto al bottone, non al rail full-width.
    Widget compact = GenIconButton.ghost(
      onPressed: widget.onTap,
      onHoverChange: reactsToHover ? (v) => setState(() => _hovered = v) : null,
      width: GenSizes.buttonHeightCompact,
      height: GenSizes.buttonHeightCompact,
      iconSize: GenSizes.iconSizeCompact,
      backgroundColor: c.restBackground,
      hoverBackgroundColor: c.hoverBackground,
      icon: widget.iconBuilder(iconColor, GenSizes.iconSizeCompact),
    );
    // Niente tooltip durante lo scroll: mostrarlo mentre le icone scorrono sotto
    // il cursore resetta la ScrollPosition (scatto). [_NavScrolling] arriva dal
    // [GenNavScrollTooltipGate] che avvolge l'area scrollabile.
    if (widget.enableTooltip && !_NavScrolling.of(context)) {
      compact = GenTooltip(
        waitDuration: Duration.zero, // tooltip istantaneo sulle voci di menu
        // Esce a DESTRA (rail a sinistra). ShadAnchor ha i nomi invertiti →
        // childAlignment=left / overlayAlignment=right per uscire a destra.
        anchor: GenAnchor(
          childAlignment: Alignment.centerLeft,
          overlayAlignment: Alignment.centerRight,
          offset: widget.tooltipOffset,
        ),
        builder: (_) => Text(widget.tooltip),
        child: compact,
      );
    }
    // Il flyout deve avvolgere solo il bottone (non il tooltip) così l'anchor
    // misura i 32px anche quando il tooltip è soppresso.
    if (widget.wrap != null) compact = widget.wrap!(compact);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GenSizes.gapXs),
      // Center: la Column della lista è stretch → senza Center il bottone si
      // allargherebbe a tutto il rail.
      child: Center(child: compact),
    );
  }
}
