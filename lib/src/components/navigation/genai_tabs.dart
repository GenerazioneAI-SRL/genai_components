import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

class GenaiTabItem {
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final bool isDisabled;

  const GenaiTabItem({
    required this.label,
    this.icon,
    this.badgeCount,
    this.isDisabled = false,
  });
}

enum GenaiTabsVariant { underline, pill, segmented }

/// Tabs (§6.6.1).
class GenaiTabs extends StatefulWidget {
  final List<GenaiTabItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final GenaiTabsVariant variant;
  final bool isFullWidth;

  const GenaiTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.variant = GenaiTabsVariant.underline,
    this.isFullWidth = false,
  });

  @override
  State<GenaiTabs> createState() => _GenaiTabsState();
}

class _GenaiTabsState extends State<GenaiTabs> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final children = <Widget>[
      for (var i = 0; i < widget.items.length; i++) widget.isFullWidth ? Expanded(child: _buildTab(i)) : _buildTab(i),
    ];

    switch (widget.variant) {
      case GenaiTabsVariant.underline:
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderDefault)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        );
      case GenaiTabsVariant.pill:
        return Wrap(spacing: 4, children: children);
      case GenaiTabsVariant.segmented:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceHover,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        );
    }
  }

  Widget _buildTab(int i) {
    final item = widget.items[i];
    final selected = i == widget.selectedIndex;
    final colors = context.colors;
    final ty = context.typography;

    Color fg;
    Color? bg;
    Border? border;
    BorderRadius? radius;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    switch (widget.variant) {
      case GenaiTabsVariant.underline:
        fg = item.isDisabled ? colors.textDisabled : (selected ? colors.colorPrimary : colors.textSecondary);
        border = selected ? Border(bottom: BorderSide(color: colors.colorPrimary, width: 2)) : null;
        break;
      case GenaiTabsVariant.pill:
        fg = item.isDisabled ? colors.textDisabled : (selected ? colors.textOnPrimary : colors.textPrimary);
        bg = selected ? colors.colorPrimary : Colors.transparent;
        radius = BorderRadius.circular(999);
        padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
        break;
      case GenaiTabsVariant.segmented:
        fg = item.isDisabled ? colors.textDisabled : (selected ? colors.textPrimary : colors.textSecondary);
        bg = selected ? colors.surfaceCard : Colors.transparent;
        radius = BorderRadius.circular(6);
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: 16, color: fg),
          const SizedBox(width: 6),
        ],
        Text(item.label, style: ty.label.copyWith(color: fg, fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
        if (item.badgeCount != null) ...[
          const SizedBox(width: 6),
          GenaiBadge.count(
            count: item.badgeCount!,
            variant: GenaiBadgeVariant.subtle,
          ),
        ],
      ],
    );

    return AnimatedContainer(
      duration: GenaiDurations.tabSwitch,
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: radius,
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: item.isDisabled ? null : () => widget.onChanged?.call(i),
        child: Padding(padding: padding, child: content),
      ),
    );
  }
}
