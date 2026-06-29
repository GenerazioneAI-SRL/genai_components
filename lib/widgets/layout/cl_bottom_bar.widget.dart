import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
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
  const CLBottomBarItem(
      {required this.icon, required this.label, required this.onTap, this.selectedKey, this.iconGradient});
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
    final theme = CLTheme.of(context);
    // Icona = iconSizeDefault (token, 20). Altezza barra = bottone + gapLg + gapSm.
    final iconSize = theme.iconSizeDefault;

    // Riga voci: custom (items) oppure destination-driven.
    final List<Widget> rowChildren;
    if (items != null) {
      rowChildren = [
        for (final it in items!)
          Expanded(
            child: _BottomItem(
              icon: (c) {
                final icon = Icon(it.icon, color: c, size: iconSize);
                if (it.iconGradient == null) return icon;
                // Gradiente icona (AI): ShaderMask su icona bianca.
                return ShaderMask(
                  shaderCallback: (b) => it.iconGradient!.createShader(Offset.zero & b.size),
                  blendMode: BlendMode.srcIn,
                  child: Icon(it.icon, color: Colors.white, size: iconSize),
                );
              },
              label: it.label,
              selected: it.selectedKey != null && it.selectedKey == selectedKey,
              onTap: it.onTap,
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
      // Inset Md. Top a 0 quando sopra c'è l'area contestuale (il suo bottom
      // padding dà già il gap Md) → evita doppio Md; Md quando la nav è da sola.
      padding: EdgeInsets.fromLTRB(theme.gapMd, topBorder ? theme.gapMd : 0, theme.gapMd, theme.gapMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: rowChildren,
      ),
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
    final theme = CLTheme.of(context);
    // Icone e testi sempre neri (primaryText); la selezione resta nel peso (w600).
    final iconWidget = icon(theme.primaryText);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.gapXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null) iconWidget,
            SizedBox(height: theme.gapXs),
            Text(
              label,
              style: theme.smallText.copyWith(
                color: theme.primaryText,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
