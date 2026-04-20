import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

enum GenaiSkeletonShape { rect, circle }

/// Animated placeholder used during loading (§6.6.4).
///
/// Shape and dimensions should mirror the real content to avoid layout shift.
/// Use the named constructors for common cases:
/// - [GenaiSkeleton.text]
/// - [GenaiSkeleton.rect]
/// - [GenaiSkeleton.circle]
/// - [GenaiSkeleton.card]
///
/// For a multi-cell row use [GenaiSkeletonRow].
class GenaiSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final GenaiSkeletonShape shape;
  final BorderRadius? borderRadius;

  const GenaiSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.shape = GenaiSkeletonShape.rect,
    this.borderRadius,
  });

  const GenaiSkeleton.text({
    super.key,
    this.width,
    this.height = 16,
  })  : shape = GenaiSkeletonShape.rect,
        borderRadius = const BorderRadius.all(Radius.circular(4));

  const GenaiSkeleton.rect({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : shape = GenaiSkeletonShape.rect;

  const GenaiSkeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        shape = GenaiSkeletonShape.circle,
        borderRadius = null;

  const GenaiSkeleton.card({
    super.key,
    this.width,
    this.height = 120,
  })  : shape = GenaiSkeletonShape.rect,
        borderRadius = const BorderRadius.all(Radius.circular(12));

  @override
  State<GenaiSkeleton> createState() => _GenaiSkeletonState();
}

class _GenaiSkeletonState extends State<GenaiSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: GenaiDurations.skeletonShimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.isDark ? colors.surfaceHover : colors.borderDefault;
    final highlight = context.isDark ? colors.borderDefault : colors.surfaceHover;

    final reduced = GenaiResponsive.reducedMotion(context);

    final br = widget.shape == GenaiSkeletonShape.circle
        ? BorderRadius.circular((widget.width ?? widget.height ?? 0) / 2)
        : (widget.borderRadius ?? BorderRadius.circular(6));

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          if (reduced) {
            return DecoratedBox(
              decoration: BoxDecoration(color: base, borderRadius: br),
            );
          }
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) {
              final t = _ctrl.value;
              return LinearGradient(
                begin: Alignment(-1 + 2 * t - 1, 0),
                end: Alignment(-1 + 2 * t + 1, 0),
                colors: [base, highlight, base],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(rect);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(color: base, borderRadius: br),
            ),
          );
        },
      ),
    );
  }
}

/// Row of evenly-spaced skeleton cells. Mirrors a table row structure.
class GenaiSkeletonRow extends StatelessWidget {
  final int columns;
  final double cellHeight;
  final double gap;

  const GenaiSkeletonRow({
    super.key,
    this.columns = 4,
    this.cellHeight = 24,
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(columns, (i) {
        final last = i == columns - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: last ? 0 : gap),
            child: GenaiSkeleton.text(height: cellHeight),
          ),
        );
      }),
    );
  }
}
