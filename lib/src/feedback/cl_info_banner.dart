import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// Contextual information banner with icon, text and optional action.
///
/// Useful for guiding users by explaining the context of a page or section.
///
/// ```dart
/// CLInfoBanner(
///   text: 'Fill in all required fields before submitting.',
///   actionText: 'Learn more',
///   onAction: () => launchUrl(...),
///   color: Colors.blue,
///   icon: FontAwesomeIcons.circleInfo,
/// )
/// ```
class CLInfoBanner extends StatelessWidget {
  final String text;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? color;
  final IconData? icon;

  const CLInfoBanner({
    super.key,
    required this.text,
    this.actionText,
    this.onAction,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? theme.info;

    return Container(
      padding: EdgeInsets.all(theme.lg),
      decoration: BoxDecoration(
        color: c.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border(left: BorderSide(color: c, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(theme.sm - 2),
            decoration: BoxDecoration(
              color: c.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(theme.radiusSm),
            ),
            child: FaIcon(
              icon ?? FontAwesomeIcons.circleInfo,
              color: c,
              size: 14,
            ),
          ),
          SizedBox(width: theme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.bodyText.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? theme.text
                        : theme.text.withValues(alpha: 0.85),
                  ),
                ),
                if (actionText != null && onAction != null) ...[
                  SizedBox(height: theme.sm - 2),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionText!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c,
                        decoration: TextDecoration.underline,
                        decorationColor: c.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
