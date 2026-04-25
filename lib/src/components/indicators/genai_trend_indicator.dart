import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Direction of a trend shown by [GenaiTrendIndicator]. Leave `null` on the
/// widget to auto-derive from the sign of `percentage`.
enum GenaiTrendDirection {
  /// Positive — green arrow up.
  up,

  /// Negative — red arrow down.
  down,

  /// No change — neutral dash icon.
  neutral,
}

/// Size scale for [GenaiTrendIndicator] — v3 Forma LMS.
enum GenaiTrendIndicatorSize {
  /// Compact — paired with `labelSm`.
  sm,

  /// Default — paired with `label` (12/500).
  md,
}

/// Trend pill: arrow + percentage + optional comparison label —
/// v3 design system (Forma LMS).
///
/// Matches the `.delta / .delta-up / .delta-down / .delta-flat` rules in
/// Dashboard v3.html: semantic-soft fill, semantic-base foreground, mono
/// figures for tabular alignment.
///
/// Semantic color mapping (success up / danger down / neutral) is never the
/// only signal — the arrow icon carries the same meaning per §5.
class GenaiTrendIndicator extends StatelessWidget {
  /// Numeric delta (percentage value). Sign drives default direction.
  final double percentage;

  /// Optional comparison context ("vs last week").
  final String? compareLabel;

  /// Explicit direction. When `null`, derived from the sign of [percentage].
  final GenaiTrendDirection? direction;

  /// Size scale.
  final GenaiTrendIndicatorSize size;

  /// When `true`, renders the v3 pill chrome (`delta-up` et al.) instead of
  /// the icon-plus-text inline treatment.
  final bool isPill;

  const GenaiTrendIndicator({
    super.key,
    required this.percentage,
    this.compareLabel,
    this.direction,
    this.size = GenaiTrendIndicatorSize.md,
    this.isPill = true,
  });

  GenaiTrendDirection get _resolvedDirection {
    if (direction != null) return direction!;
    if (percentage > 0) return GenaiTrendDirection.up;
    if (percentage < 0) return GenaiTrendDirection.down;
    return GenaiTrendDirection.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final dir = _resolvedDirection;
    final (fg, bg) = _resolvePair(colors, dir);
    final icon = switch (dir) {
      GenaiTrendDirection.up => LucideIcons.arrowUp,
      GenaiTrendDirection.down => LucideIcons.arrowDown,
      GenaiTrendDirection.neutral => LucideIcons.minus,
    };

    final sign = percentage > 0 ? '+' : '';
    final formatted = '$sign${percentage.toStringAsFixed(1)}%';
    final numberStyle =
        (size == GenaiTrendIndicatorSize.sm ? ty.monoSm : ty.monoSm)
            .copyWith(color: fg, fontWeight: FontWeight.w600, height: 1);
    final iconSize = size == GenaiTrendIndicatorSize.sm ? 12.0 : 14.0;

    final pill = Container(
      padding: isPill
          ? EdgeInsets.symmetric(horizontal: spacing.s6, vertical: spacing.s2)
          : EdgeInsets.zero,
      decoration: isPill
          ? BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius.pill),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          SizedBox(width: spacing.s4),
          Text(formatted, style: numberStyle),
        ],
      ),
    );

    return Semantics(
      label: '$formatted ${compareLabel ?? ''}'.trim(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pill,
          if (compareLabel != null) ...[
            SizedBox(width: spacing.iconLabelGap),
            Text(
              compareLabel!,
              style: ty.bodySm.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  (Color fg, Color bg) _resolvePair(dynamic colors, GenaiTrendDirection dir) {
    switch (dir) {
      case GenaiTrendDirection.up:
        return (colors.colorSuccessText, colors.colorSuccessSubtle);
      case GenaiTrendDirection.down:
        return (colors.colorDangerText, colors.colorDangerSubtle);
      case GenaiTrendDirection.neutral:
        return (colors.textSecondary, colors.colorNeutralSubtle);
    }
  }
}
