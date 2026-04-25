import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Generic bar chart — v3 design system.
///
/// Monochromatic by default — bars use `context.colors.textPrimary` (ink)
/// unless overridden via [barColor]. Multi-series variants (future work) must
/// use alpha steps of the same hue to preserve chart discipline. Axis labels
/// are always rendered — hiding axes violates the Forma LMS chart guidelines.
///
/// {@tool snippet}
/// ```dart
/// GenaiBarChart<SalesData>(
///   data: monthlySales,
///   xValueMapper: (s, _) => s.month,
///   yValueMapper: (s, _) => s.amount,
///   yAxisLabel: 'EUR',
/// );
/// ```
/// {@end-tool}
class GenaiBarChart<T> extends StatelessWidget {
  /// Data series rendered as bars.
  final List<T> data;

  /// Extracts the x-axis label (category) from an item.
  final String Function(T item, int index) xValueMapper;

  /// Extracts the numeric y-value from an item.
  final double Function(T item, int index) yValueMapper;

  /// Bar color override. Defaults to `context.colors.textPrimary` (ink).
  final Color? barColor;

  /// Bar width in logical px.
  final double barWidth;

  /// Y-axis upper bound. Auto-scaled from [data] when null.
  final double? maxY;

  /// Y-axis lower bound. Auto-scaled when null.
  final double? minY;

  /// Whether to draw horizontal gridlines.
  final bool showGrid;

  /// Y-axis tick interval. Auto-computed when null.
  final double? leftAxisInterval;

  /// Y-axis unit suffix (e.g. "€", "ms"). Highly encouraged — labels alone
  /// don't disambiguate semantics.
  final String? yAxisLabel;

  /// Optional accessible label override.
  final String? semanticLabel;

  /// Rotate x-axis labels at a narrow chart width.
  final bool rotateLabels;

  /// Chart width in px below which labels auto-rotate.
  final double rotateThreshold;

  const GenaiBarChart({
    super.key,
    required this.data,
    required this.xValueMapper,
    required this.yValueMapper,
    this.barColor,
    this.barWidth = 18,
    this.maxY,
    this.minY,
    this.showGrid = true,
    this.leftAxisInterval,
    this.yAxisLabel,
    this.semanticLabel,
    this.rotateLabels = true,
    this.rotateThreshold = 400,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final color = barColor ?? colors.textPrimary;

    final values = List<double>.generate(
      data.length,
      (i) {
        final v = yValueMapper(data[i], i);
        return v.isFinite ? v : 0;
      },
      growable: false,
    );

    double computedMinY = (minY != null && minY!.isFinite) ? minY! : 0;
    double computedMaxY;
    if (maxY != null && maxY!.isFinite) {
      computedMaxY = maxY!;
    } else if (values.isEmpty) {
      computedMaxY = computedMinY + 1;
    } else {
      final dataMin = values.reduce(min);
      final dataMax = values.reduce(max);
      if (minY == null) {
        computedMinY = min(0, dataMin);
      }
      final span = (dataMax - computedMinY).abs();
      computedMaxY = span == 0 ? computedMinY + 1 : dataMax + (span * 0.1);
    }
    if (!computedMaxY.isFinite) computedMaxY = computedMinY + 1;
    if (computedMaxY <= computedMinY) computedMaxY = computedMinY + 1;

    final effectiveLeftAxisInterval = (leftAxisInterval != null &&
            leftAxisInterval!.isFinite &&
            leftAxisInterval! > 0)
        ? leftAxisInterval
        : null;

    final smallLabel = ty.monoSm.copyWith(color: colors.textSecondary);

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
        final chartHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
        final narrow = chartWidth < rotateThreshold;

        return Semantics(
          container: true,
          label: semanticLabel ??
              'Grafico a barre con ${data.length} valori${yAxisLabel != null ? ' (unità: $yAxisLabel)' : ''}',
          child: SizedBox(
            width: chartWidth,
            height: chartHeight,
            child: BarChart(
              BarChartData(
                minY: computedMinY,
                maxY: computedMaxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  drawHorizontalLine: showGrid,
                  horizontalInterval: effectiveLeftAxisInterval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colors.borderSubtle,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    maxContentWidth: 240,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = xValueMapper(data[groupIndex], groupIndex);
                      final unit = yAxisLabel == null ? '' : ' $yAxisLabel';
                      return BarTooltipItem(
                        '$label\n${_formatTooltipValue(rod.toY)}$unit',
                        ty.labelSm.copyWith(
                          color: colors.textOnInverse,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                    getTooltipColor: (_) => colors.surfaceInverse,
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  final value = values[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: color,
                        width: barWidth,
                        borderRadius: BorderRadius.circular(radius.xs),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    axisNameWidget: yAxisLabel == null
                        ? null
                        : Padding(
                            padding: EdgeInsets.only(bottom: spacing.s4),
                            child: Text(
                              yAxisLabel!.toUpperCase(),
                              style:
                                  ty.tiny.copyWith(color: colors.textTertiary),
                            ),
                          ),
                    axisNameSize: yAxisLabel == null ? 0 : spacing.s16,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: effectiveLeftAxisInterval,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: EdgeInsets.only(right: spacing.s6),
                        child: Text(
                          _formatAxisValue(value),
                          style: smallLabel,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (!value.isFinite) return const SizedBox.shrink();
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final label = xValueMapper(data[idx], idx);
                        return Padding(
                          padding: EdgeInsets.only(top: spacing.s8),
                          child: Transform.rotate(
                            angle: (rotateLabels && narrow)
                                ? (-45 * (pi / 180))
                                : 0,
                            child: Text(label,
                                style: ty.labelSm
                                    .copyWith(color: colors.textSecondary)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatAxisValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  String _formatTooltipValue(double value) =>
      value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}
