import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Top app bar — v3 design system (§v3 rule 5).
///
/// Fixed 56 px primary row with a hairline bottom border and no shadow.
/// Title renders in `cardTitle` (14/600). Supports an optional [bottom]
/// sub-bar (tabs, filter row) that adds to the preferred height.
///
/// Note: v3's main navigation chrome is [GenaiTopbar] (sticky, blurred). Use
/// [GenaiAppBar] inside routes that want a conventional Material-style
/// top bar instead.
class GenaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Leading widget — typically a menu / back button or logo.
  final Widget? leading;

  /// Page/section title. Rendered in `cardTitle`.
  final Widget? title;

  /// Optional subtitle in `bodySm` below the title.
  final Widget? subtitle;

  /// Trailing actions — usually a short horizontal row of icon buttons.
  final List<Widget> actions;

  /// Optional sub-bar widget (tabs, filter row).
  final Widget? bottom;

  /// Override primary bar height. Defaults to 56.
  final double? height;

  /// Override sub-bar height. Defaults to `minTouchTarget`.
  final double? bottomHeight;

  /// Accessible label.
  final String? semanticLabel;

  const GenaiAppBar({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.height,
    this.bottomHeight,
    this.semanticLabel,
  });

  static const double _defaultHeight = 56;

  double _primaryHeight() => height ?? _defaultHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        _primaryHeight() + (bottom == null ? 0 : (bottomHeight ?? 48)),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final h = _primaryHeight();
    final bh = bottomHeight ?? sizing.minTouchTarget;

    return Semantics(
      container: true,
      header: true,
      label: semanticLabel,
      child: Material(
        color: colors.surfaceCard,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: h,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.borderSubtle,
                    width: sizing.dividerThickness,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: spacing.s16),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: spacing.s12),
                  ],
                  if (title != null || subtitle != null)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            DefaultTextStyle.merge(
                              style: ty.cardTitle.copyWith(
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: title!,
                            ),
                          if (subtitle != null)
                            DefaultTextStyle.merge(
                              style: ty.bodySm.copyWith(
                                color: colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: subtitle!,
                            ),
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) SizedBox(width: spacing.s4),
                    actions[i],
                  ],
                ],
              ),
            ),
            if (bottom != null) SizedBox(height: bh, child: bottom!),
          ],
        ),
      ),
    );
  }
}
