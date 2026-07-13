import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// Linea divisoria semantica, orizzontale o verticale.
class CLSeparator extends StatelessWidget {
  final Axis axis;
  final double thickness;

  const CLSeparator({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = CLTheme.of(context).cardBorder;
    if (axis == Axis.horizontal) {
      return Divider(height: thickness, thickness: thickness, color: color);
    }
    return VerticalDivider(width: thickness, thickness: thickness, color: color);
  }
}
