import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Bar chart generico basato su `fl_chart`, integrato con i token Genai.
///
/// ```dart
/// GenaiBarChart<SalesData>(
///   data: salesList,
///   xValueMapper: (item, _) => item.month,
///   yValueMapper: (item, _) => item.amount,
/// )
/// ```
class GenaiBarChart<T> extends StatelessWidget {
  const GenaiBarChart({
    super.key,
    required this.data,
    required this.xValueMapper,
    required this.yValueMapper,
    this.barColor,
    this.barWidth = 18,
    this.maxY,
    this.minY,
    this.showGrid = false,
    this.leftAxisInterval,
    this.leftTitleBuilder,
    this.bottomTitleBuilder,
    this.tooltipBuilder,
    this.borderRadius,
    this.rotateLabels = true,
    this.rotateThreshold = 400,
  });

  final List<T> data;
  final String Function(T item, int index) xValueMapper;
  final double Function(T item, int index) yValueMapper;

  /// Colore delle barre. Default: `context.colors.colorPrimary`.
  final Color? barColor;
  final double barWidth;
  final double? maxY;
  final double? minY;
  final bool showGrid;
  final double? leftAxisInterval;
  final Widget Function(double value, TitleMeta meta)? leftTitleBuilder;
  final Widget Function(double value, TitleMeta meta)? bottomTitleBuilder;
  final BarTooltipItem? Function(T item, int index, BarChartRodData rod)? tooltipBuilder;
  final BorderRadius? borderRadius;
  final bool rotateLabels;
  final double rotateThreshold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final color = barColor ?? colors.colorPrimary;

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

    if (!computedMaxY.isFinite) {
      computedMaxY = computedMinY + 1;
    }
    if (computedMaxY <= computedMinY) {
      computedMaxY = computedMinY + 1;
    }

    final effectiveLeftAxisInterval = (leftAxisInterval != null && leftAxisInterval!.isFinite && leftAxisInterval! > 0) ? leftAxisInterval : null;

    final smallLabel = ty.caption.copyWith(color: colors.textSecondary);

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
        final chartHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
        final narrow = chartWidth < rotateThreshold;

        return SizedBox(
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
                  color: colors.borderDefault.withValues(alpha: 0.5),
                  strokeWidth: 0.8,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  maxContentWidth: 240,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (tooltipBuilder != null) {
                      return tooltipBuilder!(data[groupIndex], groupIndex, rod);
                    }
                    final label = xValueMapper(data[groupIndex], groupIndex);
                    return BarTooltipItem(
                      '$label\n${rod.toY.toStringAsFixed(rod.toY.truncateToDouble() == rod.toY ? 0 : 1)}',
                      ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                    );
                  },
                  getTooltipColor: (_) => colors.surfaceCard,
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
                      borderRadius: borderRadius ?? BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: effectiveLeftAxisInterval,
                    getTitlesWidget: leftTitleBuilder ??
                        (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                _formatNumber(value),
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
                    getTitlesWidget: bottomTitleBuilder ??
                        (value, meta) {
                          if (!value.isFinite) {
                            return const SizedBox.shrink();
                          }
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final label = xValueMapper(data[idx], idx);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Transform.rotate(
                              angle: (rotateLabels && narrow) ? (-45 * (pi / 180)) : 0,
                              child: Text(label, style: smallLabel),
                            ),
                          );
                        },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }
}
