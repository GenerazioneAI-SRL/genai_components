import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';

// ResponsiveGrid
class ResponsiveGrid extends StatefulWidget {
  final List<ResponsiveGridItem> children;
  final double? gridSpacing;
  final bool showHorizontalDivider;
  final bool showMargin;
  final bool showTopSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveGrid(
      {super.key,
      this.children = const <ResponsiveGridItem>[],
      this.gridSpacing,
      this.showHorizontalDivider = false,
      this.showMargin = true,
      this.showTopSpacing = true,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.start
      });

  @override
  _ResponsiveGridState createState() => _ResponsiveGridState();
}

// ResponsiveGrid
class _ResponsiveGridState extends State<ResponsiveGrid> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.showMargin
          ? EdgeInsets.only(
              left: widget.gridSpacing ?? 0,
              right: widget.gridSpacing ?? 0,
              top: widget.showTopSpacing ? (widget.gridSpacing ?? 0) : 0,
              bottom: widget.gridSpacing ?? 0,
            )
          : EdgeInsets.zero,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        final breakpoint = _currentBreakPointFromConstraint(constraints);
        final distributedLists = _getDistributedWidgetList(widget.children, breakpoint);
        final List<Widget> rows = [];
        for (int rowIndex = 0; rowIndex < distributedLists.length; rowIndex++) {
          final rowItems = distributedLists[rowIndex];
          final List<Widget> rowChildren = [];
          for (int i = 0; i < rowItems.length; i++) {
            if (i > 0 && (widget.gridSpacing != null)) {
              rowChildren.add(SizedBox(width: widget.gridSpacing));
            }
            rowChildren.add(
              Expanded(
                flex: (rowItems[i].getWidthSpan(breakpoint) * 100).round(),
                child: rowItems[i],
              ),
            );
          }
          if (rowIndex > 0 && (widget.gridSpacing != null) && widget.showHorizontalDivider == false) {
            rows.add(SizedBox(height: widget.gridSpacing));
          }

          rows.add(
            Row(
              mainAxisAlignment: widget.mainAxisAlignment,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: rowChildren,
            ),
          );
          if (rowIndex != distributedLists.length - 1 && widget.showHorizontalDivider) {
            rows.add(Divider(
              thickness: 1,
              height: Sizes.padding*2,
              color: CLTheme.of(context).borderColor,
            ));
          }
        }

        return SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        );
      }),
    );
  }
}

// ResponsiveGridItem
class ResponsiveGridItem extends StatefulWidget {
  final double? xs;
  final double? lg;
  final Widget? child;

  const ResponsiveGridItem({super.key, this.xs, this.lg, this.child});

  // Ottieni la larghezza basata sul breakpoint
  double getWidthSpan(_BreakPoints breakPoint) {
    switch (breakPoint) {
      case _BreakPoints.xs:
        return (xs ?? 100);
      case _BreakPoints.lg:
        return (lg ?? 25);
    }
  }

  @override
  _ResponsiveGridItemState createState() => _ResponsiveGridItemState();
}

// ResponsiveGridItemState
class _ResponsiveGridItemState extends State<ResponsiveGridItem> {
  @override
  Widget build(BuildContext context) {
    return widget.child ?? SizedBox();
  }
}


// Breakpoints
enum _BreakPoints { xs, lg }

// Calcola il breakpoint attuale in base alla larghezza della finestra
_BreakPoints _currentBreakPointFromConstraint(BoxConstraints constraints) {
  double width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  //double height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
  //double rate = width / height;
  if (width <= 1079) {
    return _BreakPoints.xs;
  } else if (width > 1080)
    return _BreakPoints.lg;
  else
    return _BreakPoints.lg;
}

// Distribuisci i widget nella griglia
List<List<ResponsiveGridItem>> _getDistributedWidgetList(List<ResponsiveGridItem> items, _BreakPoints breakPoint) {
  var tempTotalFlex = 0.0;
  List<List<ResponsiveGridItem>> finalList = [];
  List<ResponsiveGridItem> itemList = [];

  for (var item in items) {
    tempTotalFlex += item.getWidthSpan(breakPoint);
    if (tempTotalFlex.roundToDouble() <= 100) {
      itemList.add(item);
    } else {
      finalList.add(itemList);
      tempTotalFlex = item.getWidthSpan(breakPoint);
      itemList = [item];
    }
  }
  finalList.add(itemList);
  return finalList;
}
