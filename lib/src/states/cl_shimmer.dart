import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// Animated shimmer loading skeleton.
class CLShimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const CLShimmer({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius = 4,
    this.margin,
  });

  const CLShimmer.box({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
    this.margin,
  });

  @override
  State<CLShimmer> createState() => _CLShimmerState();
}

class _CLShimmerState extends State<CLShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
              colors: [
                theme.border,
                theme.borderLight,
                theme.border,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Multiple shimmer rows for table loading state.
class CLShimmerTableRows extends StatelessWidget {
  final int rowCount;
  final double rowHeight;
  final int columnsCount;

  const CLShimmerTableRows({
    super.key,
    required this.rowCount,
    this.rowHeight = 48,
    this.columnsCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rowCount, (index) {
        return Container(
          height: rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: List.generate(columnsCount, (col) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CLShimmer(
                    height: 14,
                    borderRadius: 4,
                    width: col == 0 ? null : null,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
