import 'package:flutter/material.dart';

/// Grid responsiva con colonne configurabili per breakpoint.
/// Default shadcn: 1 col <600, 2 col <1024, 3 col <1440, 4 col ≥1440.
class CLResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final int smColumns;   // < 600
  final int mdColumns;   // < 1024
  final int lgColumns;   // < 1440
  final int xlColumns;   // >= 1440

  const CLResponsiveGrid({
    super.key,
    required this.children,
    this.gap = 16.0,
    this.smColumns = 1,
    this.mdColumns = 2,
    this.lgColumns = 3,
    this.xlColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width < 600
        ? smColumns
        : width < 1024
            ? mdColumns
            : width < 1440
                ? lgColumns
                : xlColumns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
