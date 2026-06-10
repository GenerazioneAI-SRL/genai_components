import 'package:flutter/material.dart';
import '../cl_theme.dart';
import 'cl_divider.widget.dart';

/// CLTitle — titolo di sezione con divider opzionali sopra/sotto.
///
/// Spaziature on-grid (asimmetriche):
/// - sopra il titolo, quando [dividerTop] è true:
///   `gapLg` → CLDivider → `gapLg` → titolo
/// - sotto il titolo, quando [dividerBottom] è true:
///   titolo → `gapLg` → CLDivider → `gapLg`
/// - sotto il titolo, quando [dividerBottom] è false:
///   titolo → `radiusControl` (8px, gap tight verso il contenuto)
///
/// Lo stile di default è `theme.heading2`. Override via [style].
class CLTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final bool dividerTop;
  final bool dividerBottom;

  const CLTitle(
    this.title, {
    super.key,
    this.style,
    this.dividerTop = false,
    this.dividerBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final effectiveStyle = style ??
        theme.heading2.copyWith(
          color: theme.primaryText,
          height: 1.15,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dividerTop) ...[
          const CLDivider(),
          SizedBox(height: theme.gapLg),
        ],
        Text(
          title,
          style: effectiveStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (dividerBottom) ...[
          SizedBox(height: theme.gapMd),
          const CLDivider(),
        ] else
          SizedBox(height: theme.gapMd),
      ],
    );
  }
}
