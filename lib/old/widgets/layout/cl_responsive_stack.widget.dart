import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Row su desktop (≥1024px), Column su mobile/tablet.
/// Usa [gap] per lo spazio tra gli elementi.
class CLResponsiveStack extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const CLResponsiveStack({
    super.key,
    required this.children,
    this.gap = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final separator = SizedBox(width: isDesktop ? gap : 0, height: isDesktop ? 0 : gap);

    final childrenWithGap = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      childrenWithGap.add(children[i]);
      if (i < children.length - 1) childrenWithGap.add(separator);
    }

    if (isDesktop) {
      return Row(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: childrenWithGap,
      );
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: childrenWithGap,
    );
  }
}
