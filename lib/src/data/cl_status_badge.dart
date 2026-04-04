import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A pill-shaped badge displaying a status with a colored dot or icon and label.
///
/// If [icon] is provided it replaces the dot.
///
/// ```dart
/// CLStatusBadge(label: 'Active', color: Colors.green)
/// CLStatusBadge(label: 'Pending', color: Colors.orange, icon: Icons.hourglass_empty)
/// ```
class CLStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final double dotSize;

  const CLStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dotSize = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: theme.sm, vertical: theme.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: theme.xs),
              child: Icon(icon, size: dotSize + 6, color: color),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: theme.xs),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Flexible(
            child: Text(
              label,
              style: theme.bodyText.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
