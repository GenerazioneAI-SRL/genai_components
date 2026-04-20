import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

class GenaiNavigationRailItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int? badgeCount;

  const GenaiNavigationRailItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
  });
}

/// Compact icon-only navigation rail for medium window sizes (§6.6.7).
class GenaiNavigationRail extends StatelessWidget {
  final List<GenaiNavigationRailItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final Widget? leading;
  final Widget? trailing;

  const GenaiNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: colors.surfaceSidebar,
        border: Border(right: BorderSide(color: colors.borderDefault)),
      ),
      child: Column(
        children: [
          if (leading != null) Padding(padding: const EdgeInsets.all(12), child: leading!),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onChanged?.call(i),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? colors.colorPrimarySubtle : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        i == selectedIndex ? (items[i].selectedIcon ?? items[i].icon) : items[i].icon,
                        size: 22,
                        color: i == selectedIndex ? colors.colorPrimary : colors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(items[i].label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ty.caption.copyWith(
                            color: i == selectedIndex ? colors.colorPrimary : colors.textSecondary,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          const Spacer(),
          if (trailing != null) Padding(padding: const EdgeInsets.all(12), child: trailing!),
        ],
      ),
    );
  }
}
