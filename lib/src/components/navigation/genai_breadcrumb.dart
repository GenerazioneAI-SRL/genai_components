import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single segment of a [GenaiBreadcrumb] trail — v3.
@immutable
class GenaiBreadcrumbItem {
  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Fires when the segment is tapped. When null the segment is rendered as
  /// static text. The final segment is always non-interactive regardless.
  final VoidCallback? onTap;

  /// Accessibility override; falls back to [label].
  final String? semanticLabel;

  const GenaiBreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
    this.semanticLabel,
  });
}

/// Breadcrumb trail — v3 design system (§4.1 / `.crumbs`).
///
/// Flex row, gap 8, font 13 (bodySm). Separator is a chevron icon sized 11
/// in `ink-3` (textTertiary). The last item renders in ink 600 weight; all
/// preceding items render in ink-2.
class GenaiBreadcrumb extends StatelessWidget {
  /// Ordered segment list, root first.
  final List<GenaiBreadcrumbItem> items;

  /// Separator icon rendered between segments.
  final IconData separator;

  /// If non-null and `items.length > maxVisible`, the middle collapses to an
  /// ellipsis preserving the first and last two items.
  final int? maxVisible;

  /// Accessible label for the whole trail.
  final String? semanticLabel;

  const GenaiBreadcrumb({
    super.key,
    required this.items,
    this.separator = LucideIcons.chevronRight,
    this.maxVisible,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final collapse = maxVisible != null && items.length > maxVisible!;
    final visible =
        collapse ? [items.first, items[items.length - 2], items.last] : items;

    final children = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: spacing.s8));
        children.add(
          ExcludeSemantics(
            child: Icon(
              separator,
              size: 11,
              color: colors.textTertiary,
            ),
          ),
        );
        children.add(SizedBox(width: spacing.s8));
        if (collapse && i == 1) {
          children.add(
            ExcludeSemantics(
              child: Text(
                '...',
                style: ty.bodySm.copyWith(color: colors.textTertiary),
              ),
            ),
          );
          children.add(SizedBox(width: spacing.s8));
          children.add(
            ExcludeSemantics(
              child: Icon(
                separator,
                size: 11,
                color: colors.textTertiary,
              ),
            ),
          );
          children.add(SizedBox(width: spacing.s8));
        }
      }
      final item = visible[i];
      final isLast = i == visible.length - 1;
      children.add(_BreadcrumbSegment(item: item, isCurrent: isLast));
    }

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Breadcrumb',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _BreadcrumbSegment extends StatefulWidget {
  final GenaiBreadcrumbItem item;
  final bool isCurrent;

  const _BreadcrumbSegment({required this.item, required this.isCurrent});

  @override
  State<_BreadcrumbSegment> createState() => _BreadcrumbSegmentState();
}

class _BreadcrumbSegmentState extends State<_BreadcrumbSegment> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final interactive = !widget.isCurrent && widget.item.onTap != null;
    final baseColor = widget.isCurrent
        ? colors.textPrimary
        : (_hover && interactive ? colors.textPrimary : colors.textSecondary);

    final textStyle = widget.isCurrent
        ? ty.bodySm.copyWith(
            color: baseColor,
            fontWeight: FontWeight.w600,
          )
        : ty.bodySm.copyWith(
            color: baseColor,
            decoration: _hover && interactive
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: baseColor,
          );

    final body = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: 13, color: baseColor),
          SizedBox(width: spacing.s4),
        ],
        Text(widget.item.label, style: textStyle),
      ],
    );

    Widget wrapped = body;
    if (_focused && interactive) {
      wrapped = Stack(
        clipBehavior: Clip.none,
        children: [
          wrapped,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.xs),
                  border: Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!interactive) {
      return Semantics(
        label: widget.item.semanticLabel ?? widget.item.label,
        header: widget.isCurrent,
        child: wrapped,
      );
    }

    return Semantics(
      link: true,
      label: widget.item.semanticLabel ?? widget.item.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hover) setState(() => _hover = true);
        },
        onExit: (_) {
          if (_hover) setState(() => _hover = false);
        },
        child: Focus(
          onFocusChange: (v) {
            if (_focused != v) setState(() => _focused = v);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.item.onTap,
            child: wrapped,
          ),
        ),
      ),
    );
  }
}
