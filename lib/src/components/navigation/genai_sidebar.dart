import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

/// Sidebar navigation entry (3 levels supported via [children]).
class GenaiSidebarItem {
  final String id;
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final bool isDisabled;
  final List<GenaiSidebarItem> children;

  const GenaiSidebarItem({
    required this.id,
    required this.label,
    this.icon,
    this.badgeCount,
    this.isDisabled = false,
    this.children = const [],
  });
}

/// A logical group of sidebar items (e.g. "Operations", "Settings").
class GenaiSidebarGroup {
  final String? title;
  final List<GenaiSidebarItem> items;

  const GenaiSidebarGroup({this.title, required this.items});
}

/// Sidebar navigation supporting up to 3 levels (§6.6.7).
class GenaiSidebar extends StatefulWidget {
  final List<GenaiSidebarGroup> groups;
  final String? selectedId;
  final ValueChanged<String>? onSelected;
  final bool isCollapsed;
  final ValueChanged<bool>? onCollapsedChanged;
  final Widget? header;
  final Widget? footer;
  final double width;
  final double collapsedWidth;

  const GenaiSidebar({
    super.key,
    required this.groups,
    this.selectedId,
    this.onSelected,
    this.isCollapsed = false,
    this.onCollapsedChanged,
    this.header,
    this.footer,
    this.width = 260,
    this.collapsedWidth = 64,
  });

  @override
  State<GenaiSidebar> createState() => _GenaiSidebarState();
}

class _GenaiSidebarState extends State<GenaiSidebar> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand the parent of the selected child.
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
    return AnimatedContainer(
      duration: GenaiDurations.sidebarCollapse,
      curve: GenaiCurves.toggle,
      width: widget.isCollapsed ? widget.collapsedWidth : widget.width,
      decoration: BoxDecoration(
        color: colors.surfaceSidebar,
        border: Border(right: BorderSide(color: colors.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) widget.header!,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final g in widget.groups) _buildGroup(g),
                ],
              ),
            ),
          ),
          if (widget.onCollapsedChanged != null) _buildCollapseToggle(colors),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }

  Widget _buildGroup(GenaiSidebarGroup g) {
    final colors = context.colors;
    final ty = context.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (g.title != null && !widget.isCollapsed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(g.title!.toUpperCase(),
                style: ty.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          ),
        for (final i in g.items) _buildItem(i, level: 0),
      ],
    );
  }

  Widget _buildItem(GenaiSidebarItem item, {required int level}) {
    final colors = context.colors;
    final ty = context.typography;
    final selected = widget.selectedId == item.id;
    final hasChildren = item.children.isNotEmpty;
    final expanded = _expanded.contains(item.id);

    final tile = MouseRegion(
      cursor: item.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.isDisabled
            ? null
            : () {
                if (hasChildren) {
                  setState(() {
                    if (expanded) {
                      _expanded.remove(item.id);
                    } else {
                      _expanded.add(item.id);
                    }
                  });
                } else {
                  widget.onSelected?.call(item.id);
                }
              },
        child: AnimatedContainer(
          duration: GenaiDurations.hover,
          padding: EdgeInsets.fromLTRB(widget.isCollapsed ? 12 : (12 + level * 16), 8, 12, 8),
          color: selected ? colors.colorPrimarySubtle : null,
          child: Row(
            children: [
              if (item.icon != null) Icon(item.icon, size: 18, color: selected ? colors.colorPrimary : colors.textSecondary),
              if (!widget.isCollapsed) ...[
                if (item.icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(item.label,
                      style: ty.label.copyWith(
                        color: selected ? colors.colorPrimary : colors.textPrimary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis),
                ),
                if (item.badgeCount != null) GenaiBadge.count(count: item.badgeCount!, variant: GenaiBadgeVariant.subtle),
                if (hasChildren) ...[
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: GenaiDurations.accordionOpen,
                    child: Icon(LucideIcons.chevronRight, size: 14, color: colors.textSecondary),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );

    if (!hasChildren) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        if (expanded && !widget.isCollapsed)
          for (final c in item.children) _buildItem(c, level: level + 1),
      ],
    );
  }

  Widget _buildCollapseToggle(dynamic colors) {
    return InkWell(
      onTap: () => widget.onCollapsedChanged?.call(!widget.isCollapsed),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: Icon(
          widget.isCollapsed ? LucideIcons.chevronRight : LucideIcons.chevronLeft,
          size: 16,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
