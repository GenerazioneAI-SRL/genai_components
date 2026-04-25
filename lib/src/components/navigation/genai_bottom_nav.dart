import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Single destination in a [GenaiBottomNav].
@immutable
class GenaiBottomNavItem {
  /// Default icon.
  final IconData icon;

  /// Icon shown when selected. Defaults to [icon].
  final IconData? selectedIcon;

  /// Visible label below the icon.
  final String label;

  /// Optional red badge.
  final int? badgeCount;

  /// Accessibility override — defaults to [label].
  final String? semanticLabel;

  const GenaiBottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.semanticLabel,
  });
}

/// Mobile bottom navigation — v3 design system.
///
/// Renders 2–5 equally-spaced destinations. Uses `surfaceCard` with a top
/// border and SafeArea-aware bottom inset.
class GenaiBottomNav extends StatelessWidget {
  /// Destinations.
  final List<GenaiBottomNavItem> items;

  /// Selected index.
  final int selectedIndex;

  /// Fires when a user activates a different destination.
  final ValueChanged<int>? onChanged;

  /// Accessibility override.
  final String? semanticLabel;

  const GenaiBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final sizing = context.sizing;
    final spacing = context.spacing;

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Bottom navigation',
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border(
            top: BorderSide(
              color: colors.borderSubtle,
              width: sizing.dividerThickness,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: sizing.minTouchTarget + spacing.s8,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _BottomNavCell(
                      item: items[i],
                      selected: i == selectedIndex,
                      onTap: () => onChanged?.call(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavCell extends StatefulWidget {
  final GenaiBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_BottomNavCell> createState() => _BottomNavCellState();
}

class _BottomNavCellState extends State<_BottomNavCell> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final color = widget.selected
        ? colors.colorPrimary
        : (_hover ? colors.textPrimary : colors.textSecondary);
    final bg =
        _hover && !widget.selected ? colors.surfaceHover : Colors.transparent;

    final icon = widget.selected
        ? (widget.item.selectedIcon ?? widget.item.icon)
        : widget.item.icon;

    return Semantics(
      button: true,
      selected: widget.selected,
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
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(color: bg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(icon, size: sizing.iconSidebar, color: color),
                            if (widget.item.badgeCount != null)
                              Positioned(
                                right: -4,
                                top: -2,
                                child: _BottomNavBadge(
                                  count: widget.item.badgeCount!,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: spacing.s2),
                        Text(
                          widget.item.label,
                          style: ty.labelSm.copyWith(color: color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_focused)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
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
    );
  }
}

class _BottomNavBadge extends StatelessWidget {
  final int count;
  const _BottomNavBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: EdgeInsets.symmetric(horizontal: spacing.s4),
      decoration: BoxDecoration(
        color: colors.colorDanger,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: ty.labelSm.copyWith(
          color: colors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
