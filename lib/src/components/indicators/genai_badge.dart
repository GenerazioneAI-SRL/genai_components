import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

enum GenaiBadgeVariant { filled, subtle, outlined }

enum GenaiBadgeKind { dot, count, text }

/// Compact label/indicator (§6.7.1).
///
/// Usually constructed via:
/// - [GenaiBadge.dot] — colored 8px dot.
/// - [GenaiBadge.count] — numeric count, with `9+` overflow.
/// - [GenaiBadge.text] — short string.
class GenaiBadge extends StatelessWidget {
  final GenaiBadgeKind kind;
  final GenaiBadgeVariant variant;

  /// Required for [GenaiBadgeKind.count].
  final int? count;

  /// Maximum value before showing `N+` (default 9 for count).
  final int max;

  /// Required for [GenaiBadgeKind.text].
  final String? text;

  /// Optional explicit color override. Defaults to `colorError`.
  final Color? color;

  const GenaiBadge.dot({
    super.key,
    this.color,
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
  })  : kind = GenaiBadgeKind.count,
        text = null;

  const GenaiBadge.text({
    super.key,
    required String this.text,
    this.color,
    this.variant = GenaiBadgeVariant.filled,
  })  : kind = GenaiBadgeKind.text,
        count = null,
        max = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final base = color ?? colors.colorError;

    if (kind == GenaiBadgeKind.dot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: base, shape: BoxShape.circle),
      );
    }

    final label = switch (kind) {
      GenaiBadgeKind.count => (count ?? 0) > max ? '$max+' : '${count ?? 0}',
      GenaiBadgeKind.text => text ?? '',
      GenaiBadgeKind.dot => '',
    };

    final colorset = _resolveStyle(base, colors);

    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorset.bg,
        borderRadius: BorderRadius.circular(999),
        border: colorset.border != null ? Border.all(color: colorset.border!, width: 1) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: ty.labelSm.copyWith(
            color: colorset.fg,
            fontSize: 10,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  ({Color bg, Color fg, Color? border}) _resolveStyle(Color base, dynamic colors) {
    switch (variant) {
      case GenaiBadgeVariant.filled:
        return (bg: base, fg: Colors.white, border: null);
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
