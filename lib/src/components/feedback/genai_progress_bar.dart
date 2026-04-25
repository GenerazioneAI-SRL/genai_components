import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Tone variants for [GenaiProgressBar] — v3 design system (§4.3).
///
/// Maps to the CSS `.pbar[data-tone="..."]` token set. Default (`ink`) is used
/// when no semantic meaning is attached (raw completion). Info/ok/warn/danger
/// pair with the standard v3 semantic palette.
enum GenaiProgressBarTone {
  /// `--ink` — neutral default (no semantic meaning).
  ink,

  /// `--info` — in-progress / selected.
  info,

  /// `--ok` — complete / healthy.
  ok,

  /// `--warn` — behind target, partial completion.
  warn,

  /// `--danger` — critical / blocked.
  danger,

  /// `--neutral` — quiet, inactive track (zero progress).
  neutral,
}

/// Linear progress bar — v3 design system (§4.3).
///
/// Spec: 6 px height, rounded pill corners, bg = `--line`, fill is
/// tone-aware. Supports determinate ([value] 0..1) and indeterminate modes.
class GenaiProgressBar extends StatelessWidget {
  /// 0..1 progress value. `null` renders an indeterminate animation.
  final double? value;

  /// Track height in logical px. Defaults to 6 per spec.
  final double height;

  /// Semantic tone of the fill. Defaults to [GenaiProgressBarTone.ink].
  final GenaiProgressBarTone tone;

  /// Override fill color. Takes precedence over [tone] when set.
  final Color? color;

  /// Override track background. Defaults to `context.colors.borderDefault`
  /// (i.e. `--line`).
  final Color? trackColor;

  /// Accessible label for assistive tech.
  final String semanticLabel;

  const GenaiProgressBar({
    super.key,
    this.value,
    this.height = 6,
    this.tone = GenaiProgressBarTone.ink,
    this.color,
    this.trackColor,
    this.semanticLabel = 'Progress',
  }) : assert(value == null || (value >= 0 && value <= 1),
            'value must be in [0, 1] or null');

  Color _toneColor(BuildContext context) {
    final c = context.colors;
    switch (tone) {
      case GenaiProgressBarTone.ink:
        return c.colorPrimary;
      case GenaiProgressBarTone.info:
        return c.colorInfo;
      case GenaiProgressBarTone.ok:
        return c.colorSuccess;
      case GenaiProgressBarTone.warn:
        return c.colorWarning;
      case GenaiProgressBarTone.danger:
        return c.colorDanger;
      case GenaiProgressBarTone.neutral:
        return c.colorNeutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final fill = color ?? _toneColor(context);
    final bg = trackColor ?? colors.borderDefault;
    final reduced = context.motion.hover.duration == Duration.zero;

    // In reduced-motion mode, indeterminate progress becomes a static 10% bar.
    final effectiveValue = (value == null && reduced) ? 0.1 : value;

    return Semantics(
      label: semanticLabel,
      value: value == null ? null : '${(value! * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.pill),
        child: SizedBox(
          height: height,
          child: LinearProgressIndicator(
            value: effectiveValue,
            minHeight: height,
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation(fill),
          ),
        ),
      ),
    );
  }
}
