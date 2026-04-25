import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Shape variants for [GenaiSkeleton].
enum GenaiSkeletonShape {
  /// Rectangular with default radius `md`.
  rectangle,

  /// Pill — fully rounded.
  pill,

  /// Circle — equal width/height.
  circle,

  /// Single line of text (height derived from the body line-height).
  text,
}

/// Loading placeholder — v3 design system.
///
/// Uses a subtle shimmer tween between `surfaceHover` (`--neutral-soft`) and
/// `surfacePressed`. Respects reduced-motion by rendering a static tinted
/// rectangle.
class GenaiSkeleton extends StatefulWidget {
  /// Desired width. When null, fills parent width.
  final double? width;

  /// Desired height. When null, inferred from [shape] (text → line height,
  /// circle → width).
  final double? height;

  /// Geometry.
  final GenaiSkeletonShape shape;

  /// Override border radius (rectangular only).
  final BorderRadius? borderRadius;

  const GenaiSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = GenaiSkeletonShape.rectangle,
    this.borderRadius,
  });

  /// Named helper for a text-line skeleton. [lines] renders N stacked bars
  /// with a `s6` vertical gap; the last line is 60 % of the width to suggest
  /// a paragraph end.
  static Widget text(
    BuildContext context, {
    int lines = 1,
    double? width,
  }) {
    return _SkeletonTextBlock(lines: lines, width: width);
  }

  @override
  State<GenaiSkeleton> createState() => _GenaiSkeletonState();
}

class _GenaiSkeletonState extends State<GenaiSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Start after first frame so we can read reduced-motion from context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduced = context.motion.hover.duration == Duration.zero;
      if (!reduced) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final ty = context.typography;

    final double resolvedHeight = widget.height ??
        switch (widget.shape) {
          GenaiSkeletonShape.text => ty.body.fontSize ?? 14,
          GenaiSkeletonShape.circle => widget.width ?? 24,
          _ => 16,
        };
    final double? resolvedWidth = widget.shape == GenaiSkeletonShape.circle
        ? resolvedHeight
        : widget.width;

    final BorderRadius resolvedRadius = switch (widget.shape) {
      GenaiSkeletonShape.pill => BorderRadius.circular(radius.pill),
      GenaiSkeletonShape.circle => BorderRadius.circular(resolvedHeight / 2),
      GenaiSkeletonShape.text => BorderRadius.circular(radius.xs),
      GenaiSkeletonShape.rectangle =>
        widget.borderRadius ?? BorderRadius.circular(radius.md),
    };

    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final color =
              Color.lerp(colors.surfaceHover, colors.surfacePressed, t)!;
          return Container(
            width: resolvedWidth,
            height: resolvedHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: resolvedRadius,
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonTextBlock extends StatelessWidget {
  final int lines;
  final double? width;

  const _SkeletonTextBlock({required this.lines, this.width});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final children = <Widget>[];
    for (var i = 0; i < lines; i++) {
      // Last line gets a reduced width to suggest paragraph end.
      final isLast = i == lines - 1 && lines > 1;
      children.add(GenaiSkeleton(
        width: isLast ? (width ?? 200) * 0.6 : width,
        shape: GenaiSkeletonShape.text,
      ));
      if (i != lines - 1) {
        children.add(SizedBox(height: spacing.s6));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
