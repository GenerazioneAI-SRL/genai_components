import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

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
      return Divider(
        thickness: 1,
        indent: 0,
        endIndent: 0,
        height: height,
        color: lineColor,
      );
    }

    final TextStyle effectiveLabelStyle =
        labelStyle ?? theme.smallLabel.override(color: theme.mutedForeground);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Divider(thickness: 1, height: 1, color: lineColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CLSizes.gapMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CLSizes.gapSm,
                vertical: CLSizes.gapXs / 2,
              ),
              decoration: BoxDecoration(
                color: theme.muted,
                borderRadius: BorderRadius.circular(CLSizes.radiusChip),
              ),
              child: Text(label!, style: effectiveLabelStyle),
            ),
          ),
          Expanded(child: Divider(thickness: 1, height: 1, color: lineColor)),
        ],
      ),
    );
  }
}
