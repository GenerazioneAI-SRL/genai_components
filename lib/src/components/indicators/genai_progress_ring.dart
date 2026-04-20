import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Circular progress with optional center label (§6.7.7).
class GenaiProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? centerText;
  final Widget? centerChild;

  const GenaiProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.strokeWidth = 6,
    this.color,
    this.centerText,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final fg = color ?? colors.colorPrimary;
    final clamped = value.clamp(0.0, 1.0);

    Widget? center = centerChild;
    if (center == null && centerText != null) {
      center = Text(
        centerText!,
        style: ty.label.copyWith(color: colors.textPrimary),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation(fg),
              backgroundColor: colors.borderDefault,
            ),
          ),
          if (center != null) center,
        ],
      ),
    );
  }
}
