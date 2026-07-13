import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<ResponsiveGridItem> children;
  final double? gridSpacing;
  final bool showHorizontalDivider;
  final bool showMargin;
  final bool showTopSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  /// Wraps the grid in a [SingleChildScrollView]. Defaults to `true` for
  /// backward compatibility. Set to `false` when the grid is placed inside
  /// another scrollable (e.g. `CustomScrollView`, `ListView`) to avoid
  /// nested scroll conflicts.
  final bool scrollable;

  const ResponsiveGrid({
    super.key,
    this.children = const <ResponsiveGridItem>[],
    this.gridSpacing,
    this.showHorizontalDivider = false,
    this.showMargin = true,
    this.showTopSpacing = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: showMargin
          ? EdgeInsets.only(
              left: gridSpacing ?? 0,
              right: gridSpacing ?? 0,
              top: showTopSpacing ? (gridSpacing ?? 0) : 0,
              bottom: gridSpacing ?? 0,
            )
          : EdgeInsets.zero,
      child: LayoutBuilder(builder: (context, constraints) {
        final breakpoint = _currentBreakPoint(constraints);
        final distributedLists = _getDistributedWidgetList(children, breakpoint);
        final List<Widget> rows = [];

        for (int rowIndex = 0; rowIndex < distributedLists.length; rowIndex++) {
          final rowItems = distributedLists[rowIndex];
          final List<Widget> rowChildren = [];
          for (int i = 0; i < rowItems.length; i++) {
            if (i > 0 && gridSpacing != null) {
              rowChildren.add(SizedBox(width: gridSpacing));
            }
            rowChildren.add(
              Expanded(
                flex: (rowItems[i]._getWidthSpan(breakpoint) * 100).round(),
                child: rowItems[i],
              ),
            );
          }
          if (rowIndex > 0 && gridSpacing != null && !showHorizontalDivider) {
            rows.add(SizedBox(height: gridSpacing));
          }

          rows.add(
            Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: rowChildren,
            ),
          );

          if (rowIndex != distributedLists.length - 1 && showHorizontalDivider) {
            rows.add(Divider(
              thickness: 1,
              height: Sizes.padding * 2,
              color: CLTheme.of(context).borderColor,
            ));
          }
        }

        final content = SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        );

        return scrollable ? SingleChildScrollView(child: content) : content;
      }),
    );
  }
}

class ResponsiveGridItem extends StatelessWidget {
  final double? xs;
  final double? sm;
  final double? md;
  final double? lg;
  final double? xl;
  final Widget? child;

  const ResponsiveGridItem({
    super.key,
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.child,
  });

  double _getWidthSpan(_BreakPoints breakPoint) {
    switch (breakPoint) {
      case _BreakPoints.xs:
        return xs ?? 100;
      case _BreakPoints.sm:
        return sm ?? xs ?? 100;
      case _BreakPoints.md:
        return md ?? sm ?? xs ?? 100;
      case _BreakPoints.lg:
        return lg ?? 25;
      case _BreakPoints.xl:
        return xl ?? lg ?? 25;
    }
  }

  @override
  Widget build(BuildContext context) => child ?? const SizedBox();
}

enum _BreakPoints { xs, sm, md, lg, xl }

_BreakPoints _currentBreakPoint(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  if (width < 600) return _BreakPoints.xs;
  if (width < 900) return _BreakPoints.sm;
  if (width < 1080) return _BreakPoints.md;
  if (width < 1440) return _BreakPoints.lg;
  return _BreakPoints.xl;
}

List<List<ResponsiveGridItem>> _getDistributedWidgetList(
  List<ResponsiveGridItem> items,
  _BreakPoints breakPoint,
) {
  final List<List<ResponsiveGridItem>> finalList = [];
  List<ResponsiveGridItem> currentRow = [];
  double currentFlex = 0;

  for (final item in items) {
    final span = item._getWidthSpan(breakPoint);
    if ((currentFlex + span).roundToDouble() <= 100) {
      currentRow.add(item);
      currentFlex += span;
    } else {
      finalList.add(currentRow);
      currentRow = [item];
      currentFlex = span;
    }
  }
  finalList.add(currentRow);
  return finalList;
}
