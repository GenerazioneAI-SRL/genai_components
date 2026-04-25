import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Sidebar navigation entry — v3 design system.
@immutable
class GenaiSidebarItem {
  /// Stable id used by [GenaiSidebar.selectedId] and `onSelected`.
  final String id;

  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Colored leading dot used by training-type items (§v3 rule 1). When
  /// provided the dot is rendered instead of (or alongside) the icon.
  final Color? leadingDotColor;

  /// Optional numeric badge displayed trailing (red pill).
  final int? badgeCount;

  /// When true the entry is non-interactive and rendered muted.
  final bool isDisabled;

  /// Child items for nested levels.
  final List<GenaiSidebarItem> children;

  /// Accessibility override; falls back to [label].
  final String? semanticLabel;

  const GenaiSidebarItem({
    required this.id,
    required this.label,
    this.icon,
    this.leadingDotColor,
    this.badgeCount,
    this.isDisabled = false,
    this.children = const [],
    this.semanticLabel,
  });
}

/// A logical group of sidebar items — rendered with a 11/500 uppercase
/// section label per §v3 rule 1.
@immutable
class GenaiSidebarGroup {
  /// Optional uppercase tiny section header rendered above the items.
  final String? title;
  final List<GenaiSidebarItem> items;

  const GenaiSidebarGroup({this.title, required this.items});
}

/// Top-of-rail brand block (mark + name + subtitle) — rendered at the very
/// top of [GenaiSidebar] when supplied via [GenaiSidebar.brand].
@immutable
class GenaiSidebarBrand {
  /// Single-letter mark drawn inside the 28 px ink square.
  final String mark;

  /// Product / workspace name — 14/600.
  final String name;

  /// Smaller subtitle — 11.5/500.
  final String? subtitle;

  const GenaiSidebarBrand({
    required this.mark,
    required this.name,
    this.subtitle,
  });
}

/// Bottom-of-rail user footer (avatar + name + company).
@immutable
class GenaiSidebarFooter {
  /// Initials or short string rendered inside the avatar circle.
  final String avatarInitials;

  /// Full user name.
  final String name;

  /// Secondary line (company / role).
  final String? company;

  /// Fires when the footer row is tapped (profile / settings).
  final VoidCallback? onTap;

  const GenaiSidebarFooter({
    required this.avatarInitials,
    required this.name,
    this.company,
    this.onTap,
  });
}

/// Sidebar / rail navigation — v3 design system (§v3 rule 1, `.rail`).
///
/// Fixed width 240, padding 20/14, right hairline border. Brand block at the
/// top, footer (user + company) at the bottom. Active item renders with a
/// solid ink bg + white text; hover renders with `neutralSoft` bg + ink
/// text; rest renders `ink-2` text.
class GenaiSidebar extends StatefulWidget {
  /// Grouped sidebar entries.
  final List<GenaiSidebarGroup> groups;

  /// Currently selected leaf id.
  final String? selectedId;

  /// Fires when a leaf item is activated.
  final ValueChanged<String>? onSelected;

  /// Top brand block (mark + name + subtitle).
  final GenaiSidebarBrand? brand;

  /// Bottom user footer.
  final GenaiSidebarFooter? footer;

  /// Optional override — use a fully custom header widget instead of [brand].
  final Widget? header;

  /// Optional override — use a fully custom footer widget instead of [footer].
  final Widget? footerOverride;

  /// Accessible label.
  final String? semanticLabel;

  const GenaiSidebar({
    super.key,
    required this.groups,
    this.selectedId,
    this.onSelected,
    this.brand,
    this.footer,
    this.header,
    this.footerOverride,
    this.semanticLabel,
  });

  @override
  State<GenaiSidebar> createState() => _GenaiSidebarState();
}

class _GenaiSidebarState extends State<GenaiSidebar> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    if (widget.selectedId != null) {
      for (final g in widget.groups) {
        for (final i in g.items) {
          if (_containsId(i, widget.selectedId!)) _expanded.add(i.id);
        }
      }
    }
  }

  bool _containsId(GenaiSidebarItem item, String id) {
    if (item.id == id) return false;
    for (final c in item.children) {
      if (c.id == id || _containsId(c, id)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? 'Sidebar',
      child: Container(
        width: sizing.sidebarWidth,
        decoration: BoxDecoration(
          color: colors.surfaceSidebar,
          border: Border(
            right: BorderSide(
              color: colors.borderSubtle,
              width: sizing.dividerThickness,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.railPaddingV,
            horizontal: spacing.railPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null)
                widget.header!
              else if (widget.brand != null)
                _SidebarBrand(brand: widget.brand!),
              SizedBox(height: spacing.s18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var gi = 0; gi < widget.groups.length; gi++) ...[
                        if (gi > 0) SizedBox(height: spacing.s14),
                        _buildGroup(context, widget.groups[gi]),
                      ],
                    ],
                  ),
                ),
              ),
              if (widget.footerOverride != null)
                widget.footerOverride!
              else if (widget.footer != null) ...[
                SizedBox(height: spacing.s12),
                _SidebarFooter(footer: widget.footer!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, GenaiSidebarGroup group) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s8,
              spacing.s4,
              spacing.s8,
              spacing.s6,
            ),
            child: Text(
              group.title!.toUpperCase(),
              style: ty.tiny.copyWith(color: colors.textTertiary),
            ),
          ),
        for (final item in group.items)
          _SidebarEntry(
            item: item,
            level: 0,
            selectedId: widget.selectedId,
            expanded: _expanded,
            onSelect: (id) => widget.onSelected?.call(id),
            onToggleExpand: (id) {
              setState(() {
                if (_expanded.contains(id)) {
                  _expanded.remove(id);
                } else {
                  _expanded.add(id);
                }
              });
            },
          ),
      ],
    );
  }
}

/// Brand block — 28 px ink square + name / subtitle.
class _SidebarBrand extends StatelessWidget {
  final GenaiSidebarBrand brand;
  const _SidebarBrand({required this.brand});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.textPrimary,
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Text(
            brand.mark,
            style: ty.cardTitle.copyWith(
              color: colors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: spacing.s10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand.name,
                style: ty.cardTitle.copyWith(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (brand.subtitle != null)
                Text(
                  brand.subtitle!,
                  style: ty.labelSm.copyWith(color: colors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom user footer — avatar + name/company with a top hairline border.
class _SidebarFooter extends StatefulWidget {
  final GenaiSidebarFooter footer;
  const _SidebarFooter({required this.footer});

  @override
  State<_SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends State<_SidebarFooter> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final interactive = widget.footer.onTap != null;
    final bg = interactive && _hover ? colors.surfaceHover : Colors.transparent;

    final innerRow = Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.colorNeutralSubtle,
            borderRadius: BorderRadius.circular(radius.pill),
          ),
          child: Text(
            widget.footer.avatarInitials,
            style: ty.labelSm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.footer.name,
                style: ty.label.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.footer.company != null)
                Text(
                  widget.footer.company!,
                  style: ty.labelSm.copyWith(color: colors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );

    final inner = Container(
      padding: EdgeInsets.all(spacing.s6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.md),
      ),
      child: innerRow,
    );

    // Focus ring overlaid via Stack so toggling never resizes the inner box.
    final inkBlock = Stack(
      children: [
        inner,
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
    );

    final row = Container(
      padding: EdgeInsets.fromLTRB(
        spacing.s8,
        spacing.s10,
        spacing.s8,
        spacing.s4,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle,
            width: sizing.dividerThickness,
          ),
        ),
      ),
      child: inkBlock,
    );

    if (!interactive) {
      return Semantics(
        label: widget.footer.name,
        child: row,
      );
    }

    return Semantics(
      button: true,
      label: widget.footer.name,
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
            onTap: widget.footer.onTap,
            child: row,
          ),
        ),
      ),
    );
  }
}

class _SidebarEntry extends StatefulWidget {
  final GenaiSidebarItem item;
  final int level;
  final String? selectedId;
  final Set<String> expanded;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onToggleExpand;

  const _SidebarEntry({
    required this.item,
    required this.level,
    required this.selectedId,
    required this.expanded,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  State<_SidebarEntry> createState() => _SidebarEntryState();
}

class _SidebarEntryState extends State<_SidebarEntry> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final disabled = widget.item.isDisabled;
    final selected = widget.item.id == widget.selectedId;
    final hasChildren = widget.item.children.isNotEmpty;
    final isExpanded = widget.expanded.contains(widget.item.id);

    Color bg = Colors.transparent;
    Color fg;
    if (disabled) {
      fg = colors.textDisabled;
    } else if (selected) {
      bg = colors.textPrimary;
      fg = colors.textOnPrimary;
    } else if (_hover) {
      bg = colors.surfaceHover;
      fg = colors.textPrimary;
    } else {
      fg = colors.textSecondary;
    }

    final indent = widget.level * spacing.s12;

    final leading = <Widget>[];
    if (widget.item.leadingDotColor != null) {
      leading.add(_ColoredDot(color: widget.item.leadingDotColor!));
      leading.add(SizedBox(width: spacing.s8));
    } else if (widget.item.icon != null) {
      leading.add(Icon(
        widget.item.icon,
        size: sizing.iconSidebar,
        color: fg,
      ));
      leading.add(SizedBox(width: spacing.s8));
    }

    final row = Row(
      children: [
        SizedBox(width: indent),
        ...leading,
        Expanded(
          child: Text(
            widget.item.label,
            style: ty.label.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.item.badgeCount != null) ...[
          SizedBox(width: spacing.s6),
          _SidebarBadge(count: widget.item.badgeCount!),
        ],
        if (hasChildren) ...[
          SizedBox(width: spacing.s4),
          Icon(
            isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
            size: 14,
            color: fg,
          ),
        ],
      ],
    );

    final container = Container(
      margin: EdgeInsets.symmetric(vertical: spacing.s2),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s10,
        vertical: spacing.s8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.md),
      ),
      child: row,
    );

    // Focus ring as non-layout overlay — bounds remain stable on focus.
    Widget visual = container;
    if (_focused && !disabled) {
      visual = Stack(
        clipBehavior: Clip.none,
        children: [
          container,
          Positioned(
            left: 0,
            top: spacing.s2,
            right: 0,
            bottom: spacing.s2,
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: !disabled,
          selected: selected,
          enabled: !disabled,
          label: widget.item.semanticLabel ?? widget.item.label,
          child: MouseRegion(
            cursor: disabled
                ? SystemMouseCursors.forbidden
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
              canRequestFocus: !disabled,
              onFocusChange: (v) {
                if (_focused != v) setState(() => _focused = v);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: disabled
                    ? null
                    : () {
                        if (hasChildren) {
                          widget.onToggleExpand(widget.item.id);
                        } else {
                          widget.onSelect(widget.item.id);
                        }
                      },
                child: visual,
              ),
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          for (final child in widget.item.children)
            _SidebarEntry(
              item: child,
              level: widget.level + 1,
              selectedId: widget.selectedId,
              expanded: widget.expanded,
              onSelect: widget.onSelect,
              onToggleExpand: widget.onToggleExpand,
            ),
      ],
    );
  }
}

/// 8 px colored dot for training-type items.
class _ColoredDot extends StatelessWidget {
  final Color color;
  const _ColoredDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Red trailing count pill — mono 11/600 danger bg, white text.
class _SidebarBadge extends StatelessWidget {
  final int count;
  const _SidebarBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s6 + 1, // ~7
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: colors.colorDanger,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: ty.monoSm.copyWith(
          color: colors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
