import 'package:flutter/material.dart';
// Budella Shad: le linee sono ShadSeparator.horizontal. Solo il simbolo usato
// (show). Firma pubblica CLDivider invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadSeparator;
import '../cl_theme.dart';

/// CLDivider — divider con stile standard del design system.
///
/// Linguaggio Skillera Refined Editorial:
/// - 1px di `CLTheme.borderColor`
/// - opzionale label centrata su sfondo `muted` (separatore semantico)
///
/// API retrocompatibile: il costruttore di default richiede solo `height`.
/// I parametri `label`, `labelStyle`, `color` sono additivi e opzionali.
class CLDivider extends StatelessWidget {
  final double? height;
  final String? label;
  final TextStyle? labelStyle;
  final Color? color;

  const CLDivider({
    super.key,
    this.height,
    this.label,
    this.labelStyle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final Color lineColor = color ?? theme.borderColor;

    if (label == null) {
      final line = ShadSeparator.horizontal(
          thickness: 1, color: lineColor, margin: EdgeInsets.zero);
      // `height` riserva lo spazio verticale con la linea centrata (come
      // `Divider(height:)`); se null la linea è alta 1px.
      return height == null
          ? line
          : SizedBox(height: height, child: Center(child: line));
    }

    final TextStyle effectiveLabelStyle =
        labelStyle ?? theme.smallLabel.override(color: theme.mutedForeground);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ShadSeparator.horizontal(
                thickness: 1, color: lineColor, margin: EdgeInsets.zero),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.gapSm,
                vertical: theme.gapXs / 2,
              ),
              decoration: BoxDecoration(
                color: theme.muted,
                borderRadius: BorderRadius.circular(theme.radiusChip),
              ),
              child: Text(label!, style: effectiveLabelStyle),
            ),
          ),
          Expanded(
            child: ShadSeparator.horizontal(
                thickness: 1, color: lineColor, margin: EdgeInsets.zero),
          ),
        ],
      ),
    );
  }
}
