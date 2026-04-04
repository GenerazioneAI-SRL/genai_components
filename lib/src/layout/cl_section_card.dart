import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// A section card with a colored header containing icon, title and optional
/// subtitle, followed by content below.
///
/// ```dart
/// CLSectionCard(
///   title: 'Shift Plans',
///   icon: FontAwesomeIcons.calendarDays,
///   color: Colors.indigo,
///   child: Text('Content'),
/// )
/// ```
class CLSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Widget? trailing;

  const CLSectionCard({
    super.key,
    required this.title,
    required this.child,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.surface : Colors.white,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(theme.lg),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.08 : 0.04),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(theme.radiusLg),
                topRight: Radius.circular(theme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                  ),
                  child: FaIcon(icon, color: color, size: 20),
                ),
                SizedBox(width: theme.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.heading5,
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle!, style: theme.bodyLabel),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(theme.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}
