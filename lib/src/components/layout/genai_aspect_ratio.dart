import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Constrains a child to a fixed aspect ratio inside a themed placeholder —
/// v3 design system.
///
/// Unlike Flutter's [AspectRatio], this widget paints a subtle border + v3
/// `xl` radius matching the card aesthetic, and exposes slots for
/// loading/error fallbacks.
class GenaiAspectRatio extends StatelessWidget {
  /// Required width/height ratio (e.g. 16/9 = 1.777…).
  final double ratio;

  /// Main child — typically an image or video.
  final Widget? child;

  /// Optional placeholder shown when [child] is null.
  final Widget? placeholder;

  /// When true, wraps the child in a themed border + `xl` radius.
  final bool bordered;

  /// When true, clips the child to the border radius (images).
  final bool clip;

  const GenaiAspectRatio({
    super.key,
    required this.ratio,
    this.child,
    this.placeholder,
    this.bordered = true,
    this.clip = true,
  }) : assert(ratio > 0, 'ratio must be positive');

  /// 16:9 shortcut.
  const GenaiAspectRatio.video({
    super.key,
    this.child,
    this.placeholder,
    this.bordered = true,
    this.clip = true,
  }) : ratio = 16 / 9;

  /// 1:1 shortcut.
  const GenaiAspectRatio.square({
    super.key,
    this.child,
    this.placeholder,
    this.bordered = true,
    this.clip = true,
  }) : ratio = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    Widget inner = child ??
        placeholder ??
        Container(
          color: colors.surfaceHover,
        );

    if (clip) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(radius.xl),
        child: inner,
      );
    }

    if (bordered) {
      inner = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.xl),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: inner,
      );
    }

    return AspectRatio(
      aspectRatio: ratio,
      child: inner,
    );
  }
}
