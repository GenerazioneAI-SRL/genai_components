import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'cl_shell_tokens.dart';
import 'cl_destination.dart';

/// Voce fissa custom della bottom bar (es. menu, AI, profilo, ricerca) — non
/// legata alle destinations nav. Usata via [CLBottomBar.items] / shell
/// `bottomBarItems`. [selectedKey] (opzionale) evidenzia la voce quando coincide
/// con la selezione corrente dello shell (es. la voce Dashboard).
class CLBottomBarItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? selectedKey;

  /// Gradiente opzionale per l'icona (es. bottone AI brand). Reso via ShaderMask.
  final Gradient? iconGradient;
  const CLBottomBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selectedKey,
    this.iconGradient,
  });
}

/// Bottom bar mobile. Due modalità:
/// - **destination-driven** (default): prime `maxItems` voci top-level (per
///   `priority`) + "Altro" che apre il drawer.
/// - **custom** ([items] non null): renderizza esattamente le voci fornite
///   (icona+label), nell'ordine dato. Usata per barre fisse [menu, dashboard,
///   AI, profilo, ricerca].
class CLBottomBar extends StatelessWidget {
  const CLBottomBar({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    required this.onOpenGroup,
    required this.onOverflow,
    required this.maxItems,
    this.items,
    this.overflowLabel = 'Altro',
    this.topBorder = true,
    this.floating = false,
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;
  final ValueChanged<CLDestination> onOpenGroup;
  final VoidCallback onOverflow;
  final int maxItems;

  /// Se non null → modalità custom: queste voci sostituiscono la barra nav.
  final List<CLBottomBarItem>? items;
  final String overflowLabel;

  /// Bordo superiore: `true` quando la nav è da sola; `false` quando sopra c'è
  /// l'area contestuale (continuano come un unico blocco, niente divider).
  final bool topBorder;

  /// Bolla frosted: bg/bordo/SafeArea li gestisce il contenitore esterno (shell).
  /// La barra rende solo il contenuto trasparente → il blur sotto resta visibile.
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final theme = CLShellTokens.of(context);
    // Icona compatta (16): con la label sotto sta nel bottone regular (40) senza
    // sforare — niente bisogno di size lg.
    final iconSize = theme.iconSizeCompact;

    // Riga voci: custom (items) oppure destination-driven.
    final List<Widget> rowChildren;
    if (items != null) {
      // Custom mobile: icon-only. Menu/Cerca = ghost neutro; AI (voce con
      // [iconGradient]) = bottone pieno con gradiente brand + glow.
      rowChildren = [
        for (final it in items!)
          Expanded(
            child: Center(
              child: it.iconGradient != null
                  ? ShadIconButton(
                      onPressed: it.onTap,
                      gradient: it.iconGradient,
                      shadows: theme.primaryGlow,
                      iconSize: theme.iconSizeDefault,
                      icon: Icon(it.icon, color: Colors.white),
                    )
                  : ShadIconButton.ghost(
                      onPressed: it.onTap,
                      iconSize: theme.iconSizeDefault,
                      foregroundColor: theme.primaryText,
                      hoverForegroundColor: theme.primaryText,
                      icon: Icon(it.icon),
                    ),
            ),
          ),
      ];
    } else {
      final tops = destinations.where((d) => d.isVisible).toList()..sort((a, b) => b.priority.compareTo(a.priority));
      final overflow = tops.length > maxItems;
      final visibleCount = overflow ? maxItems - 1 : tops.length;
      final visible = tops.take(visibleCount).toList();
      rowChildren = [
        for (final d in visible)
          Expanded(
            child: _BottomItem(
              icon: (c) => d.buildIcon(c, iconSize),
              label: d.label,
              selected: d.key == selectedKey || d.containsKey(selectedKey),
              onTap: () => d.isLeaf ? onSelect(d) : onOpenGroup(d),
            ),
          ),
        if (overflow)
          Expanded(
            child: _BottomItem(
              icon: (c) => Icon(Icons.more_horiz, color: c, size: iconSize),
              label: overflowLabel,
              selected: false,
              onTap: onOverflow,
            ),
          ),
      ];
    }

    final content = Padding(
      // Floating (dentro la bolla frosted): nessun padding proprio — la bolla
      // dà già gapLg attorno e il gap dal context area sopra. Evita il doppio
      // padding (16+12). Standalone (nav da sola): inset Md su tutti i lati.
      padding: floating
          ? EdgeInsets.zero
          : EdgeInsets.fromLTRB(theme.gapMd, topBorder ? theme.gapMd : 0, theme.gapMd, theme.gapMd),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: rowChildren),
    );

    // Floating: nessun bg/bordo/SafeArea propri → li dà la bolla frosted dello shell.
    if (floating) return content;

    return Container(
      // Bottom bar (menu mobile) = L0.
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: topBorder ? Border(top: BorderSide(color: theme.borderColor)) : null,
      ),
      child: SafeArea(top: false, child: content),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final Widget? Function(Color color) icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CLShellTokens.of(context);
    // Voce = ShadButton ghost: hover/press dai primitivi. Icone/testi neutri
    // (primaryText, non il primary di default del ghost); selezione nel peso
    // (w600). Contenuto verticale icona+label come child del bottone.
    final iconWidget = icon(theme.primaryText);

    // Niente height forzata né tipografia custom (default del ghost). Il bottone
    // si dimensiona sul CONTENUTO (niente width infinity) → lo sfondo hover del
    // ghost è una pill attorno a icona+label, non larga tutto lo slot. Il Center
    // lo centra nell'Expanded. Padding verticale azzerato: contenuto verticale.
    // Colore neutro (il ghost di default userebbe primary).
    return Center(
      child: ShadButton.ghost(
        onPressed: onTap,
        // Altezza esplicita: il contenuto (~38px) centrato lascia respiro sopra/
        // sotto → padding interno della pill hover. Le size standard di ShadButton
        // (≤44) sarebbero troppo strette per un item verticale icona+label.
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
        foregroundColor: theme.primaryText,
        hoverForegroundColor: theme.primaryText,
        // Label più piccola via il parametro `textStyle` del bottone (supportato).
        textStyle: theme.smallText.copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null) iconWidget,
            SizedBox(height: theme.gapXs),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
