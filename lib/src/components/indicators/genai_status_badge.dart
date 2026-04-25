import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Semantic status carried by a [GenaiStatusBadge] — v3 design system
/// (Forma LMS §2.2). Drives the dot + label colors from the current color
/// tokens.
enum GenaiStatusType {
  /// In progress / online — maps to `colorSuccess`.
  active,

  /// Pending / waiting — maps to `colorWarning`.
  pending,

  /// Failure — maps to `colorDanger`.
  error,

  /// Done / positive — maps to `colorSuccess`.
  success,

  /// Attention — maps to `colorWarning`.
  warning,

  /// Informational — maps to `colorInfo`.
  info,

  /// No specific status — maps to `textSecondary`.
  neutral,
}

/// Status pill with optional leading dot — v3 design system (Forma LMS).
///
/// Mirrors the `.chip` base rule (pill radius, `*Subtle` tinted fill,
/// `*Text` matched foreground). Kept distinct from [GenaiChip] because
/// status badges never offer interactive affordances (no close, no toggle).
class GenaiStatusBadge extends StatelessWidget {
  /// Visible label.
  final String label;

  /// Semantic status — drives dot/label color.
  final GenaiStatusType status;

  /// When `true`, renders a leading circle the same color as the label.
  final bool hasDot;

  /// Optional override for the dot/label color, bypassing [status].
  final Color? colorOverride;

  /// Screen-reader label override. Defaults to [label].
  final String? semanticLabel;

  const GenaiStatusBadge({
    super.key,
    required this.label,
    this.status = GenaiStatusType.neutral,
    this.hasDot = true,
    this.colorOverride,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final (fg, bg) = _resolvePair(colors);
    final dotColor = colorOverride ?? fg;
    final dotSize = spacing.s6;

    return Semantics(
      label: semanticLabel ?? label,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          spacing.s6,
          spacing.s2,
          spacing.s8,
          spacing.s2,
        ),
        decoration: BoxDecoration(
          color: colorOverride != null
              ? colorOverride!.withValues(alpha: 0.12)
              : bg,
          borderRadius: BorderRadius.circular(radius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDot) ...[
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: spacing.s6),
            ],
            Text(
              label,
              style:
                  ty.labelSm.copyWith(color: colorOverride ?? fg, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  (Color fg, Color bg) _resolvePair(dynamic colors) {
    switch (status) {
      case GenaiStatusType.active:
      case GenaiStatusType.success:
        return (colors.colorSuccessText, colors.colorSuccessSubtle);
      case GenaiStatusType.pending:
      case GenaiStatusType.warning:
        return (colors.colorWarningText, colors.colorWarningSubtle);
      case GenaiStatusType.error:
        return (colors.colorDangerText, colors.colorDangerSubtle);
      case GenaiStatusType.info:
        return (colors.colorInfoText, colors.colorInfoSubtle);
      case GenaiStatusType.neutral:
        return (colors.textSecondary, colors.colorNeutralSubtle);
    }
  }
}
