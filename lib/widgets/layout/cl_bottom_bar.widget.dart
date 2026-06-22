import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_destination.dart';

/// Bottom bar mobile: mostra le prime `maxItems` voci top-level (per `priority`)
/// e, se ce ne sono altre, una voce "Altro" che apre il drawer (menu completo).
/// Tap su foglia → `onSelect`; su gruppo/sezione → `onOpenGroup` (drawer).
class CLBottomBar extends StatelessWidget {
  const CLBottomBar({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    required this.onOpenGroup,
    required this.onOverflow,
    required this.maxItems,
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
    final tops = destinations.where((d) => d.isVisible).toList()..sort((a, b) => b.priority.compareTo(a.priority));
    final overflow = tops.length > maxItems;
    final visibleCount = overflow ? maxItems - 1 : tops.length;
    final items = tops.take(visibleCount).toList();

    // Icona = iconSizeDefault (token, 20). Altezza barra = bottone + gapLg + gapSm.
    // Gap icona/label e padding interno in _BottomItem.
    final iconSize = theme.iconSizeDefault;

    final content = Padding(
      // Inset Lg. Top a 0 quando sopra c'è l'area contestuale (il suo bottom
      // padding dà già il gap Lg) → evita doppio Lg; Lg quando la nav è da sola.
      padding: EdgeInsets.fromLTRB(theme.gapLg, topBorder ? theme.gapLg : 0, theme.gapLg, theme.gapLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final d in items)
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
          ],
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
