import 'package:flutter/material.dart';
// Budella Shad: nucleo interno del separatore. Solo il simbolo usato (show).
// Firma pubblica CLSeparator invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadSeparator;
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
    // Colore da CLTheme.cardBorder: identità CL preservata. margin zero per
    // riprodurre `Divider(height: thickness)` (nessuno spazio extra attorno).
    final color = CLTheme.of(context).cardBorder;
    return axis == Axis.horizontal
        ? ShadSeparator.horizontal(
            thickness: thickness, color: color, margin: EdgeInsets.zero)
        : ShadSeparator.vertical(
            thickness: thickness, color: color, margin: EdgeInsets.zero);
  }
}
