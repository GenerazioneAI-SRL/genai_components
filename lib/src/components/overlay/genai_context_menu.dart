import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

class GenaiContextMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final bool isDisabled;
  final String? shortcut;

  const GenaiContextMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
    this.shortcut,
  });
}

/// Show a context menu near the given [position] (§6.5.7).
Future<T?> showGenaiContextMenu<T>(
  BuildContext context, {
  required Offset position,
  required List<GenaiContextMenuItem<T>> items,
  double width = 220,
}) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    color: Theme.of(context).cardColor,
    elevation: 8,
    constraints: BoxConstraints(minWidth: width, maxWidth: width),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          enabled: !item.isDisabled,
          padding: EdgeInsets.zero,
          child: Builder(builder: (ctx) {
            final colors = ctx.colors;
            final ty = ctx.typography;
            final fg = item.isDestructive ? colors.colorError : colors.textPrimary;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 16, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(item.label, style: ty.bodyMd.copyWith(color: fg)),
                  ),
                  if (item.shortcut != null) Text(item.shortcut!, style: ty.caption.copyWith(color: colors.textSecondary)),
                ],
              ),
            );
          }),
        ),
    ],
  );
}
