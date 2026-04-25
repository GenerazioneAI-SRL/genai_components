import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Determinate circular progress — v3 design system.
///
/// Use [GenaiSpinner] for indeterminate loading. This widget always shows a
/// measurable percentage; optionally renders the numeric label inside using
/// the v3 mono scale.
class GenaiCircularProgress extends StatelessWidget {
  /// 0..1 progress value.
  final double value;

  /// Outer diameter in logical px.
  final double size;

  /// Stroke width. Defaults to `context.sizing.dividerThickness * 3`.
  final double? strokeWidth;

  /// Fill color. Defaults to `context.colors.colorPrimary` (ink).
  final Color? color;

  /// Track background color. Defaults to `context.colors.borderDefault`
  /// (the `--line` hairline).
  final Color? trackColor;

  /// When true, renders `${(value * 100).round()}%` at the center using
  /// `context.typography.monoSm`.
  final bool showLabel;

  /// Accessible label for assistive tech.
  final String semanticLabel;

  const GenaiCircularProgress({
    super.key,
    required this.value,
    this.size = 48,
    this.strokeWidth,
    this.color,
    this.trackColor,
    this.showLabel = false,
    this.semanticLabel = 'Progress',
  }) : assert(value >= 0 && value <= 1, 'value must be in [0, 1]');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final stroke = strokeWidth ?? context.sizing.dividerThickness * 3;
    final fill = color ?? colors.colorPrimary;
    final bg = trackColor ?? colors.borderDefault;
    final percent = (value * 100).round();

    return Semantics(
      label: semanticLabel,
      value: '$percent%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: stroke,
                  backgroundColor: bg,
                  valueColor: AlwaysStoppedAnimation(fill),
                ),
              ),
            ),
            if (showLabel)
              Text(
                '$percent%',
                style: ty.monoSm.copyWith(color: colors.textPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
