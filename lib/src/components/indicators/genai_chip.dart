import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Compact tag/chip (§6.7.2).
///
/// Use the named constructors:
/// - [GenaiChip.readonly] — informational tag, no interaction.
/// - [GenaiChip.removable] — has a close `×` icon and [onRemove] callback.
/// - [GenaiChip.selectable] — toggles selection state.
class GenaiChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final GenaiSize size;

  // Behavior flags — set internally by named constructors.
  final bool isRemovable;
  final bool isSelectable;
  final bool isSelected;

  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const GenaiChip.readonly({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.size = GenaiSize.xs,
  })  : isRemovable = false,
        isSelectable = false,
        isSelected = false,
        onRemove = null,
        onTap = null;

  const GenaiChip.removable({
    super.key,
    required this.label,
    this.onRemove,
    this.icon,
    this.color,
    this.size = GenaiSize.xs,
  })  : isRemovable = true,
        isSelectable = false,
        isSelected = false,
        onTap = null;

  const GenaiChip.selectable({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.icon,
    this.color,
    this.size = GenaiSize.xs,
  })  : isRemovable = false,
        isSelectable = true,
        onRemove = null;

  @override
  State<GenaiChip> createState() => _GenaiChipState();
}

class _GenaiChipState extends State<GenaiChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final h = widget.size.resolveHeight(isCompact: context.isCompact);

    final tagColor = widget.color;
    final Color bg;
    final Color fg;
    final Color border;

    if (widget.isSelectable && widget.isSelected) {
      bg = colors.colorPrimarySubtle;
      fg = colors.colorPrimary;
      border = colors.colorPrimary;
    } else if (tagColor != null) {
      bg = tagColor.withValues(alpha: 0.15);
      fg = tagColor;
      border = tagColor.withValues(alpha: 0.30);
    } else {
      bg = _hovered && widget.onTap != null ? colors.surfaceHover : colors.surfaceCard;
      fg = colors.textPrimary;
      border = colors.borderDefault;
    }

    final children = <Widget>[
      if (widget.isSelectable && widget.isSelected) ...[
        Icon(LucideIcons.check, size: 12, color: fg),
        const SizedBox(width: 4),
      ],
      if (widget.icon != null) ...[
        Icon(widget.icon, size: 12, color: fg),
        const SizedBox(width: 4),
      ],
      Flexible(
        child: Text(
          widget.label,
          style: ty.labelSm.copyWith(color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (widget.isRemovable) ...[
        const SizedBox(width: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Icon(LucideIcons.x, size: 12, color: fg),
          ),
        ),
      ],
    ];

    Widget chip = AnimatedContainer(
      duration: GenaiDurations.hover,
      height: h,
      constraints: const BoxConstraints(maxWidth: 200),
      padding: EdgeInsets.symmetric(horizontal: widget.size.paddingH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(h / 2),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    if (widget.onTap != null || widget.isSelectable) {
      chip = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(onTap: widget.onTap, child: chip),
      );
    }

    return Semantics(
      label: widget.label,
      button: widget.onTap != null,
      selected: widget.isSelected,
      child: chip,
    );
  }
}
