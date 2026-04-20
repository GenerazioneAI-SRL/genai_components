import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Circular determinate/indeterminate progress (§6.6.3).
class GenaiCircularProgress extends StatelessWidget {
  final double? value;
  final GenaiSize size;
  final Color? color;
  final double? strokeWidth;
  final Widget? centerChild;

  const GenaiCircularProgress({
    super.key,
    this.value,
    this.size = GenaiSize.md,
    this.color,
    this.strokeWidth,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final dim = size.height;
    final stroke = strokeWidth ?? (size.iconSize * 0.18);
    final fg = color ?? context.colors.colorPrimary;
    final bg = context.colors.borderDefault;

    return SizedBox(
      width: dim,
      height: dim,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: dim,
            height: dim,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: stroke,
              valueColor: AlwaysStoppedAnimation(fg),
              backgroundColor: bg,
            ),
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}
