import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A compact pill-shaped label with optional leading icon.
///
/// ```dart
/// CLPill(text: 'Flutter', color: Colors.blue)
/// CLPill(text: 'Admin', color: Colors.purple, icon: Icons.shield)
/// ```
class CLPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const CLPill({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: theme.sm + 2, vertical: theme.xs + 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(theme.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              SizedBox(width: theme.xs),
            ],
            Flexible(
              child: Text(
                text,
                style: theme.bodyText.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
