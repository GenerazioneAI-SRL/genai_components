import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

enum GenaiTrendDirection { up, down, neutral }

/// Trend pill with arrow + percentage + optional comparison label (§6.7.6).
class GenaiTrendIndicator extends StatelessWidget {
  final double percentage;
  final String? compareLabel;
  final GenaiTrendDirection? direction;
  final GenaiSize size;

  const GenaiTrendIndicator({
    super.key,
    required this.percentage,
    this.compareLabel,
    this.direction,
    this.size = GenaiSize.sm,
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

    final dir = _resolvedDirection;
    final color = switch (dir) {
      GenaiTrendDirection.up => colors.colorSuccess,
      GenaiTrendDirection.down => colors.colorError,
      GenaiTrendDirection.neutral => colors.textSecondary,
    };
    final icon = switch (dir) {
      GenaiTrendDirection.up => LucideIcons.arrowUp,
      GenaiTrendDirection.down => LucideIcons.arrowDown,
      GenaiTrendDirection.neutral => LucideIcons.minus,
    };

    final sign = percentage > 0 ? '+' : '';
    final formatted = '$sign${percentage.toStringAsFixed(1)}%'.replaceAll('.', ',');
    final base = size == GenaiSize.xs ? ty.labelSm : ty.label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size.iconSize, color: color),
        const SizedBox(width: 4),
        Text(formatted, style: base.copyWith(color: color)),
        if (compareLabel != null) ...[
          const SizedBox(width: 6),
          Text(
            compareLabel!,
            style: ty.bodySm.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
