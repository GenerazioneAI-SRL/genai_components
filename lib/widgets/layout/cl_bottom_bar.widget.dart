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
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;
  final ValueChanged<CLDestination> onOpenGroup;
  final VoidCallback onOverflow;
  final int maxItems;
  final String overflowLabel;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final tops = destinations.where((d) => d.isVisible).toList()..sort((a, b) => b.priority.compareTo(a.priority));
    final overflow = tops.length > maxItems;
    final visibleCount = overflow ? maxItems - 1 : tops.length;
    final items = tops.take(visibleCount).toList();

    // Spaziature da token: icona = iconSizeDefault + gapXs (24); altezza barra =
    // bottone + gapLg + gapSm. Gap icona/label e padding interno in _BottomItem.
    final iconSize = theme.iconSizeDefault + theme.gapXs;

    return Container(
      decoration: BoxDecoration(
        // Bottom bar (menu mobile) = L0.
        color: theme.primaryBackground,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: theme.buttonHeightDefault + theme.gapLg + theme.gapSm,
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
        ),
      ),
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
    final color = selected ? theme.primary : theme.secondaryText;
    final iconWidget = icon(color);

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
                color: color,
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
