import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Circular progress with optional center label — v3 design system
/// (Forma LMS).
///
/// Pairs with KPI cards and sparklines as a dashboard primitive. Value is
/// clamped to `[0.0, 1.0]`.
class GenaiProgressRing extends StatelessWidget {
  /// Progress fraction, `0.0`–`1.0` (clamped).
  final double value;

  /// Outer diameter in logical pixels. Defaults to 48 (dashboard-friendly
  /// medium) when null.
  final double? size;

  /// Stroke width. Defaults to ~10% of [size], clamped to 3–10 px.
  final double? strokeWidth;

  /// Foreground stroke color. Defaults to `colors.colorPrimary` (ink).
  final Color? color;

  /// Plain-text content for the ring center.
  final String? centerText;

  /// Custom widget for the ring center. Takes precedence over [centerText].
  final Widget? centerChild;

  /// Screen-reader label. Value is announced as a percentage.
  final String? semanticLabel;

  const GenaiProgressRing({
    super.key,
    required this.value,
    this.size,
    this.strokeWidth,
    this.color,
    this.centerText,
    this.centerChild,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final fg = color ?? colors.colorPrimary;
    final clamped = value.clamp(0.0, 1.0);
    final dim = size ?? 48.0;
    final stroke = strokeWidth ?? (dim * 0.1).clamp(3.0, 10.0);

    Widget? center = centerChild;
    if (center == null && centerText != null) {
      center = Text(
        centerText!,
        style: ty.label.copyWith(color: colors.textPrimary),
      );
    }

    return Semantics(
      label: semanticLabel,
      value: '${(clamped * 100).round()}%',
      child: SizedBox(
        width: dim,
        height: dim,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: dim,
              height: dim,
              child: CircularProgressIndicator(
                value: clamped,
                strokeWidth: stroke,
                valueColor: AlwaysStoppedAnimation(fg),
                backgroundColor: colors.borderDefault,
              ),
            ),
            if (center != null) center,
          ],
        ),
      ),
    );
  }
}
