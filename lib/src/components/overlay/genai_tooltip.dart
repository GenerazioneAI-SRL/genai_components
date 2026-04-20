import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';

/// Tooltip (§6.5.2). Always uses a 400ms wait duration per spec.
class GenaiTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipTriggerMode triggerMode;

  const GenaiTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = TooltipTriggerMode.longPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final isDark = context.isDark;

    return Tooltip(
      message: message,
      waitDuration: GenaiDurations.tooltipDelay,
      showDuration: const Duration(milliseconds: 1500),
      preferBelow: true,
      verticalOffset: 12,
      triggerMode: triggerMode,
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceCard : const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: ty.bodySm.copyWith(
        color: isDark ? colors.textPrimary : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: child,
    );
  }
}
