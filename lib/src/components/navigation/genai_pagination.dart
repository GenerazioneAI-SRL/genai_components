import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Pagination control — v3 design system.
///
/// Renders: `< 1 ... 4 [5] 6 ... 20 >`. Page cells use mono digits, ink text
/// for the current cell (ink bg + white text), hover `surfaceHover`.
class GenaiPagination extends StatelessWidget {
  /// Currently active page (1-based).
  final int currentPage;

  /// Total number of pages. Values < 1 render nothing.
  final int totalPages;

  /// Fires with the new page index (1-based).
  final ValueChanged<int>? onPageChanged;

  /// Number of neighbours rendered on each side of [currentPage].
  final int siblings;

  /// Number of pages always rendered at each end (before ellipsis).
  final int boundaries;

  /// Accessibility override.
  final String? semanticLabel;

  const GenaiPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
    this.siblings = 1,
    this.boundaries = 1,
    this.semanticLabel,
  });

  List<Object> _range() {
    final pages = <Object>[];
    if (totalPages <= 0) return pages;
    final start = (currentPage - siblings).clamp(boundaries + 1, totalPages);
    final end = (currentPage + siblings).clamp(1, totalPages - boundaries);

    for (var i = 1; i <= boundaries && i <= totalPages; i++) {
      pages.add(i);
    }
    if (start > boundaries + 1) pages.add('...');
    for (var i = start; i <= end; i++) {
      if (i > boundaries && i < totalPages - boundaries + 1) pages.add(i);
    }
    if (end < totalPages - boundaries) pages.add('...');
    for (var i = totalPages - boundaries + 1; i <= totalPages; i++) {
      if (i > boundaries) pages.add(i);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages < 1) return const SizedBox.shrink();
    final spacing = context.spacing;
    final pages = _range();

    final children = <Widget>[];
    children.add(
      _PaginationNav(
        icon: LucideIcons.chevronLeft,
        label: 'Previous page',
        enabled: currentPage > 1,
        onPressed:
            currentPage > 1 ? () => onPageChanged?.call(currentPage - 1) : null,
      ),
    );

    for (final p in pages) {
      children.add(SizedBox(width: spacing.s2));
      if (p is int) {
        children.add(
          _PaginationCell(
            page: p,
            selected: p == currentPage,
            onTap: p == currentPage ? null : () => onPageChanged?.call(p),
          ),
        );
      } else {
        children.add(const _PaginationEllipsis());
      }
    }

    children.add(SizedBox(width: spacing.s2));
    children.add(
      _PaginationNav(
        icon: LucideIcons.chevronRight,
        label: 'Next page',
        enabled: currentPage < totalPages,
        onPressed: currentPage < totalPages
            ? () => onPageChanged?.call(currentPage + 1)
            : null,
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Pagination',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _PaginationCell extends StatefulWidget {
  final int page;
  final bool selected;
  final VoidCallback? onTap;

  const _PaginationCell({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_PaginationCell> createState() => _PaginationCellState();
}

class _PaginationCellState extends State<_PaginationCell> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final sizing = context.sizing;
    final radius = context.radius;

    final cell = sizing.minTouchTarget - 12;
    Color bg = Colors.transparent;
    Color fg = colors.textSecondary;

    if (widget.selected) {
      bg = colors.colorPrimary;
      fg = colors.textOnPrimary;
    } else if (_hover && widget.onTap != null) {
      bg = colors.surfaceHover;
      fg = colors.textPrimary;
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: 'Page ${widget.page}${widget.selected ? ' (current)' : ''}',
      child: MouseRegion(
        cursor: widget.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
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
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: sizing.minTouchTarget,
                minHeight: sizing.minTouchTarget,
              ),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: cell,
                      height: cell,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      child: Text(
                        '${widget.page}',
                        style: ty.monoMd.copyWith(color: fg),
                      ),
                    ),
                    if (_focused)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius.sm),
                              border: Border.all(
                                color: colors.borderFocus,
                                width: sizing.focusRingWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationNav extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  const _PaginationNav({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  State<_PaginationNav> createState() => _PaginationNavState();
}

class _PaginationNavState extends State<_PaginationNav> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;

    final cell = sizing.minTouchTarget - 12;
    final fg = widget.enabled
        ? (_hover ? colors.textPrimary : colors.textSecondary)
        : colors.textDisabled;
    final bg =
        widget.enabled && _hover ? colors.surfaceHover : Colors.transparent;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hover) setState(() => _hover = true);
        },
        onExit: (_) {
          if (_hover) setState(() => _hover = false);
        },
        child: Focus(
          canRequestFocus: widget.enabled,
          onFocusChange: (v) {
            if (_focused != v) setState(() => _focused = v);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: sizing.minTouchTarget,
                minHeight: sizing.minTouchTarget,
              ),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: cell,
                      height: cell,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      alignment: Alignment.center,
                      child:
                          Icon(widget.icon, size: sizing.iconSize, color: fg),
                    ),
                    if (_focused && widget.enabled)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius.sm),
                              border: Border.all(
                                color: colors.borderFocus,
                                width: sizing.focusRingWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationEllipsis extends StatelessWidget {
  const _PaginationEllipsis();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final sizing = context.sizing;
    return ExcludeSemantics(
      child: SizedBox(
        width: sizing.minTouchTarget,
        height: sizing.minTouchTarget,
        child: Center(
          child: Text(
            '...',
            style: ty.bodySm.copyWith(color: colors.textTertiary),
          ),
        ),
      ),
    );
  }
}
