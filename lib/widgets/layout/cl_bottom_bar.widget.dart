import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_destination.dart';

/// Bottom bar mobile: mostra le foglie principali (per `priority`).
/// L'overflow + il menu completo vivono nel drawer (hamburger), niente "Altro".
class CLBottomBar extends StatelessWidget {
  const CLBottomBar({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    required this.maxItems,
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;
  final int maxItems;

  /// Appiattisce l'albero a sole foglie visibili.
  static List<CLDestination> _leaves(List<CLDestination> roots) {
    final out = <CLDestination>[];
    void walk(CLDestination d) {
      if (!d.isVisible) return;
      if (d.isLeaf) {
        out.add(d);
      } else {
        for (final c in d.children) {
          walk(c);
        }
      }
    }
    for (final d in roots) {
      walk(d);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final leaves = _leaves(destinations)..sort((a, b) => b.priority.compareTo(a.priority));
    final items = leaves.take(maxItems).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final d in items)
                Expanded(
                  child: _BottomItem(
                    destination: d,
                    selected: d.key == selectedKey,
                    onTap: () => onSelect(d),
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
  const _BottomItem({required this.destination, required this.selected, required this.onTap});

  final CLDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final color = selected ? theme.primary : theme.secondaryText;
    final iconWidget = destination.buildIcon(color, 22);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null) iconWidget,
          const SizedBox(height: 2),
          Text(
            destination.label,
            style: theme.smallText.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
