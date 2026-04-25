import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Semantic intent of a [GenaiChip] — v3 design system (Forma LMS §2.2).
///
/// Maps 1:1 to the `.chip[data-s=...]` pairs in Dashboard v3.html. The chip
/// ALWAYS renders a leading dot so color is never the sole signal (§1
/// "Fixed semantic pairing" + §5 accessibility).
enum GenaiChipTone {
  /// `ok-soft` bg + `ok` text — completato / successo.
  ok,

  /// `warn-soft` bg + `warn` text — disponibile / warning.
  warn,

  /// `danger-soft` bg + `danger` text — rischio / urgente.
  danger,

  /// `info-soft` bg + `info` text — in-corso / info.
  info,

  /// `neutral-soft` bg + `ink-2` text — bloccato / non-iniziato.
  neutral,
}

/// Size scale for [GenaiChip] — v3 Forma LMS.
enum GenaiChipSize {
  /// Matches `.chip` in the reference — labelSm (11.5/500).
  sm,

  /// Slightly larger — 13/500 for dense rows that still want a pill.
  md,
}

/// Pill chip with a mandatory leading dot — v3 design system (Forma LMS §2.2).
///
/// Mirrors the `.chip` rule: `border-radius: 999; padding: 2px 8px 2px 6px;
/// gap: 6px;` with a 6 px currentColor dot via `::before`.
///
/// Per v3 accessibility rules the dot is ALWAYS rendered — color alone is
/// never a status signal. Supply a [leadingIcon] to upgrade the dot to a
/// Lucide glyph when the context demands more than a hue.
///
/// Three interaction modes via named constructors:
/// - [GenaiChip.readonly] — informational tag.
/// - [GenaiChip.removable] — close `×` icon and [onRemove] callback.
/// - [GenaiChip.selectable] — toggles [isSelected] via [onTap].
class GenaiChip extends StatefulWidget {
  /// Visible label.
  final String label;

  /// Semantic tone — drives dot + text colors from the theme.
  final GenaiChipTone tone;

  /// Optional Lucide glyph that replaces the default 6 px dot.
  final IconData? leadingIcon;

  /// Size scale.
  final GenaiChipSize size;

  // Behavior flags (set by named constructors).
  final bool isRemovable;
  final bool isSelectable;
  final bool isSelected;

  /// Called when the user clicks the removal `×`.
  final VoidCallback? onRemove;

  /// Called when the user taps the chip body.
  final VoidCallback? onTap;

  /// Screen-reader label override. Defaults to [label].
  final String? semanticLabel;

  const GenaiChip.readonly({
    super.key,
    required this.label,
    this.tone = GenaiChipTone.neutral,
    this.leadingIcon,
    this.size = GenaiChipSize.sm,
    this.semanticLabel,
  })  : isRemovable = false,
        isSelectable = false,
        isSelected = false,
        onRemove = null,
        onTap = null;

  const GenaiChip.removable({
    super.key,
    required this.label,
    this.tone = GenaiChipTone.neutral,
    this.onRemove,
    this.leadingIcon,
    this.size = GenaiChipSize.sm,
    this.semanticLabel,
  })  : isRemovable = true,
        isSelectable = false,
        isSelected = false,
        onTap = null;

  const GenaiChip.selectable({
    super.key,
    required this.label,
    required this.isSelected,
    this.tone = GenaiChipTone.neutral,
    this.onTap,
    this.leadingIcon,
    this.size = GenaiChipSize.sm,
    this.semanticLabel,
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
    final spacing = context.spacing;
    final radius = context.radius.pill;
    final sizing = context.sizing;
    final motion = context.motion;

    final (bg, fg) = _resolveColors();
    final dotSize = spacing.s6;
    final textStyle = (widget.size == GenaiChipSize.sm ? ty.labelSm : ty.label)
        .copyWith(color: fg, height: 1.2);

    Widget leading = widget.leadingIcon != null
        ? Icon(widget.leadingIcon, size: dotSize + spacing.s4, color: fg)
        : Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
          );

    final children = <Widget>[
      leading,
      SizedBox(width: spacing.s6),
      Flexible(
        child: Text(widget.label,
            style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      if (widget.isRemovable) ...[
        SizedBox(width: spacing.s4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Icon(LucideIcons.x, size: dotSize + spacing.s4, color: fg),
          ),
        ),
      ],
    ];

    Widget chip = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      padding: EdgeInsets.fromLTRB(
        spacing.s6, // 6 leading matches the v3 `.chip` left padding.
        spacing.s2,
        spacing.s8, // 8 trailing matches right padding.
        spacing.s2,
      ),
      decoration: BoxDecoration(
        color:
            widget.isSelectable && widget.isSelected ? colors.colorPrimary : bg,
        borderRadius: BorderRadius.circular(radius),
        border: widget.isSelectable && widget.isSelected
            ? Border.all(
                color: colors.colorPrimary, width: sizing.dividerThickness)
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );

    if (widget.isSelectable && widget.isSelected) {
      // Selected chip ignores the tonal palette in favor of the ink CTA
      // treatment — matches v3 selected filter rows.
      chip = DefaultTextStyle.merge(
        style: textStyle.copyWith(color: colors.textOnPrimary),
        child: chip,
      );
    }

    if (widget.onTap != null || widget.isSelectable) {
      chip = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(onTap: widget.onTap, child: chip),
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      button: widget.onTap != null,
      selected: widget.isSelected,
      child: chip,
    );
  }

  (Color bg, Color fg) _resolveColors() {
    final colors = context.colors;
    final hovered = _hovered && widget.onTap != null;
    switch (widget.tone) {
      case GenaiChipTone.ok:
        return (colors.colorSuccessSubtle, colors.colorSuccessText);
      case GenaiChipTone.warn:
        return (colors.colorWarningSubtle, colors.colorWarningText);
      case GenaiChipTone.danger:
        return (colors.colorDangerSubtle, colors.colorDangerText);
      case GenaiChipTone.info:
        return (
          hovered ? colors.colorInfoSubtle : colors.colorInfoSubtle,
          colors.colorInfoText,
        );
      case GenaiChipTone.neutral:
        return (colors.colorNeutralSubtle, colors.textSecondary);
    }
  }
}
