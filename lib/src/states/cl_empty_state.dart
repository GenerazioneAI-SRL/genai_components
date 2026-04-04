import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// Placeholder for empty lists — contextual messaging with optional action.
///
/// Two common cases:
/// - List empty (no data created): icon + title + subtitle + CTA
/// - No results (filters active): search icon + title + "clear filters" action
class CLEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const CLEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon ?? FontAwesomeIcons.folderOpen,
              size: 48,
              color: theme.textSecondary.withValues(alpha: 0.3),
            ),
            SizedBox(height: theme.xl),
            Text(
              title,
              style: theme.heading3.copyWith(color: theme.text),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: theme.sm),
              Text(
                subtitle!,
                style: theme.bodyText.copyWith(color: theme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: theme.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
