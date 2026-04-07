import 'dart:math';

import 'package:genai_components/cl_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart generico basato su fl_chart.
///
/// Esempio d'uso:
/// ```dart
/// CLBarChart<SalesData>(
///   data: salesList,
///   xValueMapper: (item, _) => item.month,
///   yValueMapper: (item, _) => item.amount,
///   barColor: Colors.teal,
/// )
/// ```
class CLBarChart<T> extends StatefulWidget {
  const CLBarChart({
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

  /// Dati sorgente.
  final List<T> data;

  /// Estrae la label dell'asse X da un elemento.
  final String Function(T item, int index) xValueMapper;

  /// Estrae il valore numerico dell'asse Y da un elemento.
  final double Function(T item, int index) yValueMapper;

  /// Colore delle barre. Default: `CLTheme.of(context).primary`.
  final Color? barColor;

  /// Larghezza di ciascuna barra.
  final double barWidth;

  /// Valore massimo asse Y. Se null, viene calcolato automaticamente.
  final double? maxY;

  /// Valore minimo asse Y. Default 0.
  final double? minY;

  /// Mostra la griglia di sfondo.
  final bool showGrid;

  /// Intervallo tra le label dell'asse sinistro (es. 10000).
  final double? leftAxisInterval;

  /// Builder custom per le label dell'asse sinistro.
  final Widget Function(double value, TitleMeta meta)? leftTitleBuilder;

  /// Builder custom per le label dell'asse inferiore.
  /// Se null, usa il risultato di [xValueMapper].
  final Widget Function(double value, TitleMeta meta)? bottomTitleBuilder;

  /// Builder custom per il tooltip.
  final BarTooltipItem? Function(T item, int index, BarChartRodData rod)? tooltipBuilder;

  /// Border radius delle barre.
  final BorderRadius? borderRadius;

  /// Ruota automaticamente le label quando la larghezza è sotto [rotateThreshold].
  final bool rotateLabels;

  /// Soglia in pixel sotto la quale le label vengono ruotate.
  final double rotateThreshold;

  @override
  State<CLBarChart<T>> createState() => _CLBarChartState<T>();
}

class _CLBarChartState<T> extends State<CLBarChart<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.barColor ?? theme.primary;

    // Calcola maxY automaticamente se non fornito
    double computedMaxY = widget.maxY ?? 0;
    if (widget.maxY == null && widget.data.isNotEmpty) {
      for (int i = 0; i < widget.data.length; i++) {
        computedMaxY = max(computedMaxY, widget.yValueMapper(widget.data[i], i));
      }
      computedMaxY = (computedMaxY * 1.1).ceilToDouble();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < widget.rotateThreshold;

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BarChart(
            BarChartData(
              minY: widget.minY ?? 0,
              maxY: computedMaxY > 0 ? computedMaxY : null,
              gridData: FlGridData(
                drawVerticalLine: false,
                drawHorizontalLine: widget.showGrid,
                horizontalInterval: widget.leftAxisInterval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.borderColor.withValues(alpha: 0.5),
                  strokeWidth: 0.8,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  maxContentWidth: 240,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (widget.tooltipBuilder != null) {
                      return widget.tooltipBuilder!(widget.data[groupIndex], groupIndex, rod);
                    }
                    final label = widget.xValueMapper(widget.data[groupIndex], groupIndex);
                    return BarTooltipItem(
                      '$label\n${rod.toY.toStringAsFixed(rod.toY.truncateToDouble() == rod.toY ? 0 : 1)}',
                      TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    );
                  },
                  getTooltipColor: (_) => isDark ? const Color(0xFF2D2D3A) : Colors.white,
                ),
              ),
              barGroups: List.generate(widget.data.length, (i) {
                final value = widget.yValueMapper(widget.data[i], i);
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: color,
                      width: widget.barWidth,
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
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
                    interval: widget.leftAxisInterval,
                    getTitlesWidget: widget.leftTitleBuilder ??
                        (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                _formatNumber(value),
                                style: theme.smallLabel,
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
                    getTitlesWidget: widget.bottomTitleBuilder ??
                        (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= widget.data.length) return const SizedBox.shrink();
                          final label = widget.xValueMapper(widget.data[idx], idx);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Transform.rotate(
                              angle: (widget.rotateLabels && narrow) ? (-45 * (pi / 180)) : 0,
                              child: Text(label, style: theme.smallLabel),
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
