import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

class GenaiBreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const GenaiBreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}

/// Breadcrumb (§6.6.2). Last item rendered as current/inactive.
class GenaiBreadcrumb extends StatelessWidget {
  final List<GenaiBreadcrumbItem> items;
  final IconData separator;
  final int? maxVisible;

  const GenaiBreadcrumb({
    super.key,
    required this.items,
    this.separator = LucideIcons.chevronRight,
    this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final visible = (maxVisible != null && items.length > maxVisible!) ? [items.first, items[items.length - 2], items.last] : items;
    final collapsed = maxVisible != null && items.length > maxVisible! && visible.length < items.length;

    final children = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      if (i > 0) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(separator, size: 14, color: colors.textSecondary),
        ));
        if (collapsed && i == 1) {
          children.add(Text('...', style: ty.bodySm.copyWith(color: colors.textSecondary)));
          children.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(separator, size: 14, color: colors.textSecondary),
          ));
        }
      }
      final item = visible[i];
      final isLast = i == visible.length - 1;
      final color = isLast ? colors.textPrimary : colors.textSecondary;
      Widget label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(item.label,
              style: ty.bodySm.copyWith(
                color: color,
                fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              )),
        ],
      );
      if (!isLast && item.onTap != null) {
        label = MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: item.onTap, child: label),
        );
      }
      children.add(label);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
