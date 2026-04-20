import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Linear progress indicator (§6.6.3).
///
/// Pass `null` to [value] for an indeterminate animation.
class GenaiProgressBar extends StatelessWidget {
  final double? value;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final bool showPercentage;

  const GenaiProgressBar({
    super.key,
    this.value,
    this.height = 4,
    this.color,
    this.backgroundColor,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final fg = color ?? colors.colorPrimary;
    final bg = backgroundColor ?? colors.borderDefault;

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: bg,
          valueColor: AlwaysStoppedAnimation(fg),
          minHeight: height,
        ),
      ),
    );

    if (label == null && !showPercentage) return bar;

    final pct = (value == null) ? null : (value!.clamp(0.0, 1.0) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(label!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                  )
                else
                  const Spacer(),
                if (showPercentage && pct != null) Text('$pct%', style: ty.bodySm.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
        bar,
      ],
    );
  }
}
