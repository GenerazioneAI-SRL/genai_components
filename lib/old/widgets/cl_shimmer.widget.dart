import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Widget che mostra un effetto shimmer (loading skeleton)
class CLShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const CLShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
    this.margin,
  });

  /// Crea un contenitore rettangolare con shimmer
  const CLShimmer.box({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
    this.margin,
  });

  /// Crea una riga della tabella con shimmer
  factory CLShimmer.tableRow({
    Key? key,
    double height = 48,
    int columnsCount = 4,
    EdgeInsets? margin,
  }) {
    return CLShimmer._tableRow(
      key: key,
      height: height,
      columnsCount: columnsCount,
      margin: margin,
    );
  }

  const CLShimmer._tableRow({
    super.key,
    required this.height,
    int columnsCount = 4,
    this.margin,
  })  : width = double.infinity,
        borderRadius = 0;

  @override
  State<CLShimmer> createState() => _CLShimmerState();
}

class _CLShimmerState extends State<CLShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = CLTheme.of(context).muted;
    final highlightColor = CLTheme.of(context).secondaryBackground;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value + 1, 0),
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget per mostrare shimmer loading nelle righe della tabella
class CLShimmerTableRows extends StatelessWidget {
  final int rowCount;
  final double rowHeight;
  final int columnsCount;
  final List<double>? columnWidths;
  final bool hasCheckboxColumn;

  const CLShimmerTableRows({
    super.key,
    required this.rowCount,
    this.rowHeight = 48,
    this.columnsCount = 4,
    this.columnWidths,
    this.hasCheckboxColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: rowCount,
      separatorBuilder: (_, __) => Divider(
        height: 0,
        color: CLTheme.of(context).borderColor,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        return _ShimmerRow(
          height: rowHeight,
          columnsCount: columnsCount,
          columnWidths: columnWidths,
          hasCheckboxColumn: hasCheckboxColumn,
        );
      },
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  final double height;
  final int columnsCount;
  final List<double>? columnWidths;
  final bool hasCheckboxColumn;

  const _ShimmerRow({
    required this.height,
    required this.columnsCount,
    this.columnWidths,
    this.hasCheckboxColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Se ha la colonna checkbox, usa la stessa struttura delle righe normali
          if (hasCheckboxColumn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
              child: SizedBox(
                width: Sizes.padding,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CLShimmer(
                    width: 18,
                    height: 18,
                    borderRadius: 4,
                  ),
                ),
              ),
            ),
          // Genera le colonne normali
          ...List.generate(hasCheckboxColumn ? columnsCount - 1 : columnsCount, (index) {
            final actualIndex = hasCheckboxColumn ? index + 1 : index;
            final width =
                columnWidths != null && actualIndex < columnWidths!.length ? columnWidths![actualIndex] : null;
            return Expanded(
              flex: width != null ? 0 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.verticalPadding),
                child: CLShimmer(
                  width: width ?? double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
