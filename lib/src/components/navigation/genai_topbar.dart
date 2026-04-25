import 'package:flutter/material.dart';
import 'dart:ui';

import '../../theme/context_extensions.dart';

/// v3 sticky topbar — `.topbar` per §v3 rule 2.
///
/// Layout: crumbs on the left (flex), [GenaiAskBar] (or any widget) in the
/// center, icon buttons on the right. Padding 12/28, gap 14. Hairline bottom
/// border. Background: `color-mix(srgb, surfacePage 88%, transparent)` with
/// `backdrop-filter: saturate(1.4) blur(12px)`.
///
/// The widget is deliberately typed as `PreferredSizeWidget` so it can be
/// handed off to hosts expecting an `AppBar` shape.
class GenaiTopbar extends StatelessWidget implements PreferredSizeWidget {
  /// Leading widget — typically a [GenaiBreadcrumb].
  final Widget? leading;

  /// Center widget — typically a [GenaiAskBar].
  final Widget? center;

  /// Trailing icon buttons.
  final List<Widget> actions;

  /// Override bar height. Defaults to 56.
  final double? height;

  /// When true a blurred translucent background is applied (web-friendly).
  /// Some render targets ignore the backdrop filter; disable to fall back to
  /// a solid tinted surface.
  final bool useBlur;

  /// Accessible label.
  final String? semanticLabel;

  const GenaiTopbar({
    super.key,
    this.leading,
    this.center,
    this.actions = const [],
    this.height,
    this.useBlur = true,
    this.semanticLabel,
  });

  static const double _defaultHeight = 56;

  @override
  Size get preferredSize => Size.fromHeight(height ?? _defaultHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final h = height ?? _defaultHeight;

    // Translucent bg — 88% surface + 12% transparent, mirroring CSS
    // color-mix(srgb, bg 88%, transparent).
    final translucent = colors.surfacePage.withValues(alpha: 0.88);

    Widget content = Container(
      height: h,
      decoration: BoxDecoration(
        color: translucent,
        border: Border(
          bottom: BorderSide(
            color: colors.borderSubtle,
            width: sizing.dividerThickness,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.topbarPaddingH,
        vertical: spacing.topbarPaddingV,
      ),
      child: Row(
        children: [
          if (leading != null) Flexible(child: leading!),
          SizedBox(width: spacing.s14),
          if (center != null) center!,
          SizedBox(width: spacing.s14),
          const Spacer(),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: spacing.s8),
            actions[i],
          ],
        ],
      ),
    );

    if (useBlur) {
      content = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    return Semantics(
      container: true,
      header: true,
      label: semanticLabel ?? 'Top bar',
      child: Material(
        color: Colors.transparent,
        child: content,
      ),
    );
  }
}
