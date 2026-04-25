import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Entry inside a [showGenaiContextMenu] invocation.
///
/// The generic [T] is the value returned when this item is selected.
class GenaiContextMenuItem<T> {
  /// Value returned when this item is selected.
  final T value;

  /// Row label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// When true, renders in the danger color and announces as destructive.
  final bool isDestructive;

  /// Disabled rows are still rendered but non-interactive.
  final bool isDisabled;

  /// Optional keyboard shortcut hint rendered on the right.
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

/// Shows a context menu near [position] — v3 design system.
///
/// Panel bg, hairline border, `radius.md` (8) corners, layer 2 shadow. Rows
/// use `bodySm` copy; shortcuts render in `monoSm`. Returns the selected
/// item's `value`, or null if dismissed.
Future<T?> showGenaiContextMenu<T>(
  BuildContext context, {
  required Offset position,
  required List<GenaiContextMenuItem<T>> items,
  double width = 220,
}) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final colors = context.colors;
  final radius = context.radius;
  final sizing = context.sizing;

  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    color: colors.surfaceOverlay,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.md),
      side: BorderSide(color: colors.borderDefault),
    ),
    constraints: BoxConstraints(minWidth: width, maxWidth: width),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          enabled: !item.isDisabled,
          padding: EdgeInsets.zero,
          child: Builder(
            builder: (ctx) {
              final c = ctx.colors;
              final ty = ctx.typography;
              final s = ctx.spacing;
              final fg = item.isDisabled
                  ? c.textDisabled
                  : item.isDestructive
                      ? c.colorDangerText
                      : c.textPrimary;
              return Semantics(
                button: true,
                enabled: !item.isDisabled,
                label: item.label,
                hint: item.shortcut,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: s.s12,
                      vertical: s.s8,
                    ),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(item.icon, size: ctx.sizing.iconSize, color: fg),
                          SizedBox(width: s.s8),
                        ],
                        Expanded(
                          child: Text(
                            item.label,
                            style: ty.bodySm.copyWith(color: fg),
                          ),
                        ),
                        if (item.shortcut != null)
                          Text(
                            item.shortcut!,
                            style: ty.monoSm.copyWith(color: c.textTertiary),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );
}
