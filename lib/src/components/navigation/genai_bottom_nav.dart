import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

class GenaiBottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int? badgeCount;

  const GenaiBottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
  });
}

/// Mobile bottom navigation (§6.6.5).
class GenaiBottomNav extends StatelessWidget {
  final List<GenaiBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const GenaiBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged?.call(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              i == selectedIndex ? (items[i].selectedIcon ?? items[i].icon) : items[i].icon,
                              size: 22,
                              color: i == selectedIndex ? colors.colorPrimary : colors.textSecondary,
                            ),
                            if (items[i].badgeCount != null)
                              Positioned(
                                top: -6,
                                right: -8,
                                child: GenaiBadge.count(
                                  count: items[i].badgeCount!,
                                  variant: GenaiBadgeVariant.filled,
                                  color: colors.colorError,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(items[i].label,
                            style: ty.caption.copyWith(
                              color: i == selectedIndex ? colors.colorPrimary : colors.textSecondary,
                              fontWeight: i == selectedIndex ? FontWeight.w600 : FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
