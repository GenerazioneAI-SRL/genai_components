import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_data.dart';
import '../theme/cl_theme_provider.dart';

enum _CLAlertVariant { soft, solid, outline }

/// An alert / notification banner with three visual variants.
///
/// Use named constructors to pick the variant:
///
/// ```dart
/// CLAlert.soft(
///   title: 'Heads up',
///   message: 'Your plan expires soon.',
///   color: Colors.orange,
///   icon: FontAwesomeIcons.triangleExclamation,
/// )
///
/// CLAlert.solid(
///   title: 'Success',
///   message: 'Changes saved.',
///   color: Colors.green,
/// )
///
/// CLAlert.outline(
///   title: 'Info',
///   message: 'Read the docs before continuing.',
///   color: Colors.blue,
///   dismissible: true,
///   onDismiss: () => setState(() => _showAlert = false),
/// )
/// ```
class CLAlert extends StatelessWidget {
  final String? title;
  final String message;
  final Color? color;
  final IconData? icon;
  final bool dismissible;
  final VoidCallback? onDismiss;
  final _CLAlertVariant _variant;

  const CLAlert._({
    super.key,
    this.title,
    required this.message,
    this.color,
    this.icon,
    this.dismissible = false,
    this.onDismiss,
    required _CLAlertVariant variant,
  }) : _variant = variant;

  /// Soft (tinted background + left accent border) variant.
  const CLAlert.soft({
    Key? key,
    String? title,
    required String message,
    Color? color,
    IconData? icon,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) : this._(
          key: key,
          title: title,
          message: message,
          color: color,
          icon: icon,
          dismissible: dismissible,
          onDismiss: onDismiss,
          variant: _CLAlertVariant.soft,
        );

  /// Solid (filled background) variant.
  const CLAlert.solid({
    Key? key,
    String? title,
    required String message,
    Color? color,
    IconData? icon,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) : this._(
          key: key,
          title: title,
          message: message,
          color: color,
          icon: icon,
          dismissible: dismissible,
          onDismiss: onDismiss,
          variant: _CLAlertVariant.solid,
        );

  /// Outline (transparent background, full border) variant.
  const CLAlert.outline({
    Key? key,
    String? title,
    required String message,
    Color? color,
    IconData? icon,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) : this._(
          key: key,
          title: title,
          message: message,
          color: color,
          icon: icon,
          dismissible: dismissible,
          onDismiss: onDismiss,
          variant: _CLAlertVariant.outline,
        );

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? theme.info;

    final decoration = _buildDecoration(c, isDark, theme);
    final foreground = _foregroundColor(c);

    return Container(
      decoration: decoration,
      padding: EdgeInsets.symmetric(horizontal: theme.lg, vertical: theme.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 2, right: theme.md),
              child: FaIcon(icon, size: 16, color: foreground),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.heading5.copyWith(color: foreground),
                  ),
                if (title != null) SizedBox(height: theme.xs),
                Text(
                  message,
                  style: theme.smallText.copyWith(color: foreground),
                ),
              ],
            ),
          ),
          if (dismissible) ...[
            SizedBox(width: theme.sm),
            GestureDetector(
              onTap: onDismiss,
              child: FaIcon(FontAwesomeIcons.xmark, size: 14, color: foreground),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(
    Color c,
    bool isDark,
    CLThemeData theme,
  ) {
    switch (_variant) {
      case _CLAlertVariant.soft:
        return BoxDecoration(
          color: c.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border(
            left: BorderSide(color: c, width: 3),
          ),
        );
      case _CLAlertVariant.solid:
        return BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(theme.radiusMd),
        );
      case _CLAlertVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: c),
        );
    }
  }

  Color _foregroundColor(Color c) {
    switch (_variant) {
      case _CLAlertVariant.solid:
        return Colors.white;
      case _CLAlertVariant.soft:
      case _CLAlertVariant.outline:
        return c;
    }
  }
}
