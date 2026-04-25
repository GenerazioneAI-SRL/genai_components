import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Switch-style on/off toggle — v3 Forma LMS (§6 field rules).
///
/// Distinct from `GenaiToggleButton` in `actions/` (which is a button-shaped
/// two-state selector). This is the pill-switch you'd use in a settings row
/// for booleans.
///
/// Task spec §6: track 36×20, radius 999, bg `line-2` (borderStrong) off /
/// `colorPrimary` on. Thumb 16 px white.
class GenaiToggle extends StatefulWidget {
  /// Current state.
  final bool value;

  /// Fired with the next state. `null` disables the control.
  final ValueChanged<bool>? onChanged;

  /// Inline label left of the track.
  final String? label;

  /// Secondary description below [label].
  final String? description;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isDisabled = false,
    this.semanticLabel,
  });

  @override
  State<GenaiToggle> createState() => _GenaiToggleState();
}

class _GenaiToggleState extends State<GenaiToggle> {
  bool _focused = false;

  static const double _trackW = 36;
  static const double _trackH = 20;
  static const double _thumb = 16;

  void _toggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    HapticFeedback.lightImpact();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;

    final trackColor = widget.value ? colors.colorPrimary : colors.borderStrong;

    Widget toggle = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      width: _trackW,
      height: _trackH,
      padding: EdgeInsets.all((_trackH - _thumb) / 2),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(_trackH / 2),
      ),
      alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: motion.press.duration,
        curve: motion.press.curve,
        width: _thumb,
        height: _thumb,
        decoration: BoxDecoration(
          color: colors.textOnPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );

    if (_focused && !widget.isDisabled) {
      toggle = Container(
        padding: EdgeInsets.all(sizing.focusRingOffset),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(_trackH / 2 + sizing.focusRingOffset),
          border: Border.all(
            color: colors.borderFocus,
            width: sizing.focusRingWidth,
          ),
        ),
        child: toggle,
      );
    }

    final hasText = widget.label != null || widget.description != null;
    Widget content = toggle;
    if (hasText) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          SizedBox(width: spacing.s12),
          toggle,
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Semantics(
              button: true,
              toggled: widget.value,
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
