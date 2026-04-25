import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Horizontal bullet bar row — v3 design system (§4.3).
///
/// Dashboard primitive: a compact 3-column grid (`100 / 1fr / 60`) that
/// renders a labelled bar with a right-aligned tabular value. Mirrors the
/// `.bar-row` component in the Forma LMS reference HTML.
///
/// - Label column is 100 px wide, uses `context.typography.bodySm` with
///   primary text.
/// - Bar is a rounded track (`borderDefault`) with a filled segment sized by
///   [value] (0..1) in [barColor] (defaults to `textPrimary` — ink).
/// - Value column is 60 px wide, right-aligned, tabular-figure mono/bodySm
///   depending on format.
///
/// Callers build color semantics via [barColor] — pass `colorInfo`,
/// `colorSuccess`, `colorWarning`, or `colorDanger` when a semantic tone is
/// meaningful; leave null for the neutral ink default.
class GenaiBarRow extends StatelessWidget {
  /// Row label text (left column).
  final String label;

  /// Fill ratio 0..1.
  final double value;

  /// Optional pre-formatted value label (right column). Defaults to
  /// `${(value*100).round()}%` when null.
  final String? valueLabel;

  /// Bar fill color. Defaults to `context.colors.textPrimary`.
  final Color? barColor;

  /// Accessible label. Defaults to `"$label — ${valueLabel ?? percent}"`.
  final String? semanticLabel;

  const GenaiBarRow({
    super.key,
    required this.label,
    required this.value,
    this.valueLabel,
    this.barColor,
    this.semanticLabel,
  }) : assert(value >= 0 && value <= 1, 'value must be in [0, 1]');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final fill = barColor ?? colors.textPrimary;
    final computedValueLabel = valueLabel ?? '${(value * 100).round()}%';
    final a11yLabel = semanticLabel ?? '$label $computedValueLabel';

    return Semantics(
      container: true,
      label: a11yLabel,
      value: '${(value * 100).round()}%',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: ty.bodySm.copyWith(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius.pill),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: colors.borderDefault),
                      FractionallySizedBox(
                        widthFactor: value.clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: Container(color: fill),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing.s12),
            SizedBox(
              width: 60,
              child: Text(
                computedValueLabel,
                style: ty.monoSm.copyWith(color: colors.textPrimary),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
