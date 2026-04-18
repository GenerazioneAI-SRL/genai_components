import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// Wrapper tooltip con delay di 500ms e stile coerente con il tema.
class CLTooltipWrapper extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipTriggerMode triggerMode;

  const CLTooltipWrapper({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = TooltipTriggerMode.longPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 500),
      triggerMode: triggerMode,
      decoration: BoxDecoration(
        color: isDark ? theme.secondaryBackground : const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.cardBorder),
      ),
      textStyle: theme.smallText.copyWith(
        color: isDark ? theme.primaryText : Colors.white,
      ),
      child: child,
    );
  }
}
