import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A rounded badge displaying a role icon and label.
///
/// ```dart
/// CLRoleBadge(
///   label: 'Metodologo',
///   color: Colors.indigo,
///   icon: Icons.school,
/// )
/// ```
class CLRoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const CLRoleBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.sm,
            vertical: theme.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: theme.xs),
              Flexible(
                child: Text(
                  label,
                  style: theme.bodyText.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A circular icon avatar for a role, with a tooltip on hover/long-press.
///
/// ```dart
/// CLRoleIcon(
///   tooltip: 'Metodologo',
///   color: Colors.indigo,
///   icon: Icons.school,
/// )
/// ```
class CLRoleIcon extends StatelessWidget {
  final String tooltip;
  final Color color;
  final IconData icon;
  final double radius;
  final double iconSize;

  const CLRoleIcon({
    super.key,
    required this.tooltip,
    required this.color,
    required this.icon,
    this.radius = 16,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
