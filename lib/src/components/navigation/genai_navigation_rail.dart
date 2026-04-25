import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Single entry in a [GenaiNavigationRail].
@immutable
class GenaiNavigationRailItem {
  /// Default icon.
  final IconData icon;

  /// Icon rendered when the item is selected. Defaults to [icon].
  final IconData? selectedIcon;

  /// Label shown beneath the icon.
  final String label;

  /// Optional numeric badge.
  final int? badgeCount;

  /// Accessibility override.
  final String? semanticLabel;

  const GenaiNavigationRailItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.semanticLabel,
  });
}

/// Compact icon-only navigation rail for medium window sizes — v3.
///
/// Renders a narrow vertical column of icons with stacked labels. Active
/// entry uses the ink primary ramp, matching the v3 sidebar's active state
/// (solid ink bg + white text).
class GenaiNavigationRail extends StatelessWidget {
  /// Ordered destinations.
  final List<GenaiNavigationRailItem> items;

  /// Currently selected index.
  final int selectedIndex;

  /// Fires when a user activates a new destination.
  final ValueChanged<int>? onChanged;

  /// Optional widget rendered at the top (logo, menu button).
  final Widget? leading;

  /// Optional widget rendered at the bottom (avatar).
  final Widget? trailing;

  /// Accessibility override.
  final String? semanticLabel;

  const GenaiNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.leading,
    this.trailing,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final railWidth = sizing.minTouchTarget + spacing.s24;
    final tileHeight = sizing.minTouchTarget + spacing.s8;

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Navigation rail',
      explicitChildNodes: true,
      child: Container(
        width: railWidth,
        decoration: BoxDecoration(
          color: colors.surfaceSidebar,
          border: Border(
            right: BorderSide(
              color: colors.borderSubtle,
              width: sizing.dividerThickness,
            ),
          ),
        ),
        child: Column(
          children: [
            if (leading != null)
              Padding(
                padding: EdgeInsets.all(spacing.s12),
                child: leading!,
              ),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: spacing.s2,
                  horizontal: spacing.s6,
                ),
                child: _RailTile(
                  item: items[i],
                  selected: i == selectedIndex,
                  height: tileHeight,
                  onTap: () => onChanged?.call(i),
                ),
              ),
            const Spacer(),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.all(spacing.s12),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

class _RailTile extends StatefulWidget {
  final GenaiNavigationRailItem item;
  final bool selected;
  final double height;
  final VoidCallback onTap;

  const _RailTile({
    required this.item,
    required this.selected,
    required this.height,
    required this.onTap,
  });

  @override
  State<_RailTile> createState() => _RailTileState();
}

class _RailTileState extends State<_RailTile> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    Color bg = Colors.transparent;
    Color fg = colors.textSecondary;
    if (widget.selected) {
      bg = colors.textPrimary;
      fg = colors.textOnPrimary;
    } else if (_hover) {
      bg = colors.surfaceHover;
      fg = colors.textPrimary;
    }

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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(radius.md),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(icon, size: sizing.iconSidebar, color: fg),
                          if (widget.item.badgeCount != null)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: _RailBadge(count: widget.item.badgeCount!),
                            ),
                        ],
                      ),
                      SizedBox(height: spacing.s2),
                      Text(
                        widget.item.label,
                        style: ty.labelSm.copyWith(color: fg),
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
                          borderRadius: BorderRadius.circular(radius.md),
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
    );
  }
}

class _RailBadge extends StatelessWidget {
  final int count;
  const _RailBadge({required this.count});

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
