import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Tri-state checkbox — v3 Forma LMS (§4 field rules).
///
/// Value semantics:
/// * `true`  — checked (filled `colorPrimary`, check glyph).
/// * `false` — unchecked (ink border, transparent fill).
/// * `null`  — indeterminate (filled `colorPrimary`, minus glyph).
///
/// The default tap cycle flips `null` → `true` → `false` → `true` → …
/// Callers driving the indeterminate state externally should supply their
/// own [onChanged] handler that cycles values as required.
class GenaiCheckbox extends StatefulWidget {
  /// `null` = indeterminate.
  final bool? value;

  /// Fired with the next value. `null` disables the control.
  final ValueChanged<bool?>? onChanged;

  /// Inline label on the right.
  final String? label;

  /// Secondary description below [label].
  final String? description;

  /// Muted colour, no interaction.
  final bool isDisabled;

  /// Error state — danger border, danger focus override.
  final bool hasError;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isDisabled = false,
    this.hasError = false,
    this.semanticLabel,
  });

  @override
  State<GenaiCheckbox> createState() => _GenaiCheckboxState();
}

class _GenaiCheckboxState extends State<GenaiCheckbox> {
  bool _focused = false;
  bool _hovered = false;

  /// Task spec §4: 18 px box, radius 4, ink border default, fill `colorPrimary`
  /// when checked.
  static const double _box = 18;

  void _toggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    final next = widget.value == true ? false : true;
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final isChecked = widget.value == true;
    final isIndeterminate = widget.value == null;
    final filled = isChecked || isIndeterminate;

    final fillColor =
        widget.hasError ? colors.colorDanger : colors.colorPrimary;
    final restingBorder =
        widget.hasError ? colors.colorDanger : colors.textPrimary;
    final hoverBorder =
        widget.hasError ? colors.colorDanger : colors.colorPrimaryHover;

    Widget box = AnimatedContainer(
      duration: motion.press.duration,
      curve: motion.press.curve,
      width: _box,
      height: _box,
      decoration: BoxDecoration(
        color: filled ? fillColor : Colors.transparent,
        borderRadius: BorderRadius.circular(radius.xs),
        border: Border.all(
          color: filled
              ? fillColor
              : (_hovered && !widget.isDisabled ? hoverBorder : restingBorder),
          width: 1.5,
        ),
      ),
      child: filled
          ? Icon(
              isIndeterminate ? LucideIcons.minus : LucideIcons.check,
              size: _box - 4,
              color: colors.textOnPrimary,
            )
          : null,
    );

    if (_focused && !widget.isDisabled) {
      box = Container(
        padding: EdgeInsets.all(sizing.focusRingOffset),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(radius.xs + sizing.focusRingOffset),
          border: Border.all(
            color: widget.hasError ? colors.colorDanger : colors.borderFocus,
            width: sizing.focusRingWidth,
          ),
        ),
        child: box,
      );
    }

    final hasText = widget.label != null || widget.description != null;
    Widget content = box;
    if (hasText) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          SizedBox(width: spacing.iconLabelGap),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null)
                  Text(widget.label!,
                      style: ty.label.copyWith(
                        color: widget.isDisabled
                            ? colors.textDisabled
                            : colors.textPrimary,
                      )),
                if (widget.description != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s2),
                    child: Text(widget.description!,
                        style: ty.bodySm.copyWith(color: colors.textTertiary)),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Opacity(
      opacity: widget.isDisabled ? 0.5 : 1.0,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: widget.isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Semantics(
              checked: isChecked,
              mixed: isIndeterminate,
              enabled: !widget.isDisabled,
              focused: _focused,
              label: widget.semanticLabel ?? widget.label,
              hint: widget.description,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: hasText ? 0 : sizing.minTouchTarget,
                  minWidth: hasText ? 0 : sizing.minTouchTarget,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
