import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Inverse-chip tooltip — v3 design system.
///
/// Flat ink-chip tooltip styled to Forma LMS: `context.colors.surfaceInverse`
/// bg, `textOnInverse` copy, `radius.xs` corners, positioned below the anchor
/// by default. Waits [waitDuration] before showing and stays visible for
/// [showDuration].
///
/// v3 class signature matches v1 / v2 so consumers can swap libraries by
/// changing the import alias.
class GenaiTooltip extends StatelessWidget {
  /// Tooltip text.
  final String message;

  /// Widget that triggers the tooltip.
  final Widget child;

  /// How the tooltip is triggered on touch platforms.
  final TooltipTriggerMode triggerMode;

  /// How long the tooltip stays visible after showing.
  final Duration showDuration;

  /// How long to wait before showing on hover.
  final Duration waitDuration;

  const GenaiTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = TooltipTriggerMode.longPress,
    this.showDuration = const Duration(milliseconds: 1500),
    this.waitDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      showDuration: showDuration,
      preferBelow: true,
      verticalOffset: spacing.s12,
      triggerMode: triggerMode,
      decoration: BoxDecoration(
        color: colors.surfaceInverse,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      textStyle: ty.labelSm.copyWith(color: colors.textOnInverse),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s8,
        vertical: spacing.s4,
      ),
      child: child,
    );
  }
}
