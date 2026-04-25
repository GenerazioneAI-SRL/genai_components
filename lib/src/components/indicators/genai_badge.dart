import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual style of a [GenaiBadge] — v3 design system (Forma LMS).
enum GenaiBadgeVariant {
  /// Solid fill with high-contrast foreground.
  filled,

  /// Tinted fill (`*Subtle`) with color-matched foreground.
  subtle,

  /// Transparent fill with a 1-px border and color-matched foreground.
  outlined,
}

/// Shape/content type of a [GenaiBadge]. Prefer the named constructors
/// ([GenaiBadge.dot], [GenaiBadge.count], [GenaiBadge.text]) over setting
/// this directly.
enum GenaiBadgeKind {
  /// Small colored circle, no label.
  dot,

  /// Numeric count with `N+` overflow (mono figures per v3 spec).
  count,

  /// Short string (label).
  text,
}

/// Compact label / notification indicator — v3 design system (Forma LMS).
///
/// Three shapes, selected via named constructors:
/// - [GenaiBadge.dot] — colored 8-px dot (the rail trailing count in v3).
/// - [GenaiBadge.count] — numeric count pill with `N+` overflow (default 9+).
///   Renders with `monoSm` (Geist Mono 11/…) and danger red fill by default,
///   matching the sidebar rail pills in Dashboard v3.html.
/// - [GenaiBadge.text] — short string.
class GenaiBadge extends StatelessWidget {
  /// Shape/kind of this badge.
  final GenaiBadgeKind kind;

  /// Visual variant (filled/subtle/outlined).
  final GenaiBadgeVariant variant;

  /// Count value for [GenaiBadgeKind.count].
  final int? count;

  /// Maximum count before showing `N+`. Default 9.
  final int max;

  /// Text payload for [GenaiBadgeKind.text].
  final String? text;

  /// Optional explicit color override. Defaults to `colors.colorDanger`.
  final Color? color;

  /// Screen-reader label override. Defaults to a sensible localized string.
  final String? semanticLabel;

  const GenaiBadge.dot({
    super.key,
    this.color,
    this.semanticLabel,
  })  : kind = GenaiBadgeKind.dot,
        variant = GenaiBadgeVariant.filled,
        count = null,
        max = 0,
        text = null;

  const GenaiBadge.count({
    super.key,
    required int this.count,
    this.max = 9,
    this.color,
    this.variant = GenaiBadgeVariant.filled,
    this.semanticLabel,
  })  : kind = GenaiBadgeKind.count,
        text = null;

  const GenaiBadge.text({
    super.key,
    required String this.text,
    this.color,
    this.variant = GenaiBadgeVariant.filled,
    this.semanticLabel,
  })  : kind = GenaiBadgeKind.text,
        count = null,
        max = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final base = color ?? colors.colorDanger;

    if (kind == GenaiBadgeKind.dot) {
      return Semantics(
        label: semanticLabel ?? 'Indicator',
        child: Container(
          width: spacing.s8,
          height: spacing.s8,
          decoration: BoxDecoration(color: base, shape: BoxShape.circle),
        ),
      );
    }

    final label = switch (kind) {
      GenaiBadgeKind.count => (count ?? 0) > max ? '$max+' : '${count ?? 0}',
      GenaiBadgeKind.text => text ?? '',
      GenaiBadgeKind.dot => '',
    };

    final colorset = _resolveStyle(base, colors);
    final textStyle = kind == GenaiBadgeKind.count
        ? ty.monoSm.copyWith(
            color: colorset.fg,
            height: 1,
            fontWeight: FontWeight.w600,
          )
        : ty.labelSm.copyWith(color: colorset.fg, height: 1);

    return Semantics(
      label: semanticLabel ??
          (kind == GenaiBadgeKind.count ? '$label notifications' : label),
      child: Container(
        constraints: BoxConstraints(
          minWidth: spacing.s16,
          minHeight: spacing.s16,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s6,
          vertical: spacing.s2,
        ),
        decoration: BoxDecoration(
          color: colorset.bg,
          borderRadius: BorderRadius.circular(radius.pill),
          border: colorset.border != null
              ? Border.all(
                  color: colorset.border!, width: sizing.dividerThickness)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(label, style: textStyle, textAlign: TextAlign.center),
      ),
    );
  }

  ({Color bg, Color fg, Color? border}) _resolveStyle(
      Color base, dynamic colors) {
    switch (variant) {
      case GenaiBadgeVariant.filled:
        return (bg: base, fg: colors.textOnPrimary as Color, border: null);
      case GenaiBadgeVariant.subtle:
        return (
          bg: base.withValues(alpha: 0.15),
          fg: base,
          border: null,
        );
      case GenaiBadgeVariant.outlined:
        return (bg: Colors.transparent, fg: base, border: base);
    }
  }
}
