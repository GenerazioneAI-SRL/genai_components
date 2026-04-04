import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A single cell/item inside a [CLResponsiveGrid].
///
/// Width is expressed as a percentage (0–100) per breakpoint:
/// - [xs]: always applied (mobile-first fallback)
/// - [sm]: applied when width > 600 px
/// - [md]: applied when width > 900 px
/// - [lg]: applied when width > 1200 px
///
/// Breakpoints that are not provided fall back to the next smaller value.
class CLResponsiveGridItem extends StatelessWidget {
  final Widget child;

  /// Width as percentage 0-100 for the xs (mobile) breakpoint.
  final int xs;

  /// Width as percentage 0-100 for the sm breakpoint (> 600 px).
  final int? sm;

  /// Width as percentage 0-100 for the md breakpoint (> 900 px).
  final int? md;

  /// Width as percentage 0-100 for the lg breakpoint (> 1200 px).
  final int? lg;

  const CLResponsiveGridItem({
    super.key,
    required this.child,
    this.xs = 100,
    this.sm,
    this.md,
    this.lg,
  });

  /// Returns the effective width percentage for the given breakpoint.
  int _effectiveWidth(_CLBreakpoint bp) {
    switch (bp) {
      case _CLBreakpoint.xs:
        return xs;
      case _CLBreakpoint.sm:
        return sm ?? xs;
      case _CLBreakpoint.md:
        return md ?? sm ?? xs;
      case _CLBreakpoint.lg:
        return lg ?? md ?? sm ?? xs;
    }
  }

  @override
  Widget build(BuildContext context) => child;
}

/// A responsive grid layout that arranges [CLResponsiveGridItem] children
/// into rows based on the available width.
///
/// ```dart
/// CLResponsiveGrid(
///   spacing: 16,
///   showDivider: true,
///   children: [
///     CLResponsiveGridItem(xs: 100, md: 50, child: WidgetA()),
///     CLResponsiveGridItem(xs: 100, md: 50, child: WidgetB()),
///   ],
/// )
/// ```
class CLResponsiveGrid extends StatelessWidget {
  final List<CLResponsiveGridItem> children;

  /// Space between columns and rows (defaults to [CLThemeData.lg]).
  final double? spacing;

  /// Whether to render a divider between rows instead of blank space.
  final bool showDivider;

  const CLResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final gap = spacing ?? theme.lg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = _breakpointFromWidth(constraints.maxWidth);
        final rows = _distributeItems(children, bp);

        final List<Widget> rowWidgets = [];

        for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
          final row = rows[rowIndex];
          final List<Widget> rowChildren = [];

          for (int i = 0; i < row.length; i++) {
            if (i > 0) {
              rowChildren.add(SizedBox(width: gap));
            }
            rowChildren.add(
              Expanded(
                flex: row[i]._effectiveWidth(bp),
                child: row[i],
              ),
            );
          }

          if (rowIndex > 0) {
            if (showDivider) {
              rowWidgets.add(Divider(
                thickness: 1,
                height: gap * 2,
                color: theme.border,
              ));
            } else {
              rowWidgets.add(SizedBox(height: gap));
            }
          }

          rowWidgets.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: rowWidgets,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

enum _CLBreakpoint { xs, sm, md, lg }

_CLBreakpoint _breakpointFromWidth(double width) {
  if (width >= 1200) return _CLBreakpoint.lg;
  if (width >= 900) return _CLBreakpoint.md;
  if (width >= 600) return _CLBreakpoint.sm;
  return _CLBreakpoint.xs;
}

List<List<CLResponsiveGridItem>> _distributeItems(
  List<CLResponsiveGridItem> items,
  _CLBreakpoint bp,
) {
  final List<List<CLResponsiveGridItem>> rows = [];
  List<CLResponsiveGridItem> current = [];
  int usedWidth = 0;

  for (final item in items) {
    final w = item._effectiveWidth(bp).clamp(0, 100);
    if (usedWidth + w > 100 && current.isNotEmpty) {
      rows.add(current);
      current = [];
      usedWidth = 0;
    }
    current.add(item);
    usedWidth += w;
  }

  if (current.isNotEmpty) rows.add(current);
  return rows;
}
