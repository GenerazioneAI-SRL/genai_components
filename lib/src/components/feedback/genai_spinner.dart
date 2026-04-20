import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Indeterminate spinner. Use inside buttons or when a structured skeleton
/// is not appropriate (§6.6.5).
class GenaiSpinner extends StatelessWidget {
  final GenaiSize size;
  final Color? color;
  final double strokeWidth;

  const GenaiSpinner({
    super.key,
    this.size = GenaiSize.md,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final dim = size.iconSize;
    return SizedBox(
      width: dim,
      height: dim,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color ?? context.colors.colorPrimary),
      ),
    );
  }
}
