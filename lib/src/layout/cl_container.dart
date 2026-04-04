import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A themed container with optional title header, action button, and border.
///
/// ```dart
/// CLContainer(
///   title: 'My Section',
///   child: Text('Content here'),
/// )
/// ```
class CLContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool showBorder;
  final bool showShadow;
  final BoxConstraints? constraints;

  const CLContainer({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.actionText,
    this.onAction,
    this.trailing,
    this.padding,
    this.backgroundColor,
    this.showBorder = true,
    this.showShadow = false,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final hasTitle = title != null || titleWidget != null;
    final br = BorderRadius.circular(theme.radiusLg);
    final borderWidth = showBorder ? 1.0 : 0.0;
    final innerBr = BorderRadius.only(
      topLeft: Radius.circular((br.topLeft.x - borderWidth).clamp(0.0, double.infinity)),
      topRight: Radius.circular((br.topRight.x - borderWidth).clamp(0.0, double.infinity)),
      bottomLeft: Radius.circular((br.bottomLeft.x - borderWidth).clamp(0.0, double.infinity)),
      bottomRight: Radius.circular((br.bottomRight.x - borderWidth).clamp(0.0, double.infinity)),
    );

    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.surface,
        borderRadius: br,
        border: showBorder ? Border.all(color: theme.border, width: 1) : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: theme.text.withValues(alpha: 0.08),
                  blurRadius: 8,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: innerBr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTitle) ...[
              Container(
                decoration: BoxDecoration(
                  color: theme.background,
                  border: Border(
                    bottom: BorderSide(color: theme.border, width: 1),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.lg,
                    vertical: theme.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: titleWidget ??
                            Text(
                              title!,
                              style: theme.heading5,
                            ),
                      ),
                      if (trailing != null) trailing!,
                      if (actionText != null && onAction != null && trailing == null)
                        GestureDetector(
                          onTap: onAction,
                          child: Text(
                            actionText!,
                            style: theme.smallLabel.copyWith(
                              color: theme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            Flexible(
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
