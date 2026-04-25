import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';
import 'genai_button.dart';

/// Visual variant of a [GenaiToggleButton] — v3 design system (Forma LMS).
enum GenaiToggleButtonVariant {
  /// No border; background fills when pressed.
  solid,

  /// 1-px border; accent-tinted background when pressed.
  outline,
}

/// Single pressable toggle — v3 design system (Forma LMS).
///
/// Controlled component: the caller owns [pressed] state and rebuilds on
/// [onChanged]. Renders as a button that holds its "down" state when
/// `pressed == true`. Typical uses: bold / italic / mute / pin.
///
/// When pressed, uses `colorPrimarySubtle` (info-soft) background with
/// `colorPrimaryText` (info) label — matches the `.seg button[data-on="1"]`
/// segmented-control pattern in Dashboard v3.html.
class GenaiToggleButton extends StatefulWidget {
  /// Current pressed state.
  final bool pressed;

  /// Called when the user toggles the button. `null` disables the control.
  final ValueChanged<bool>? onChanged;

  /// Optional text label. Pair with [icon] for icon + label layout.
  final String? label;

  /// Optional icon. Rendered before the label, or alone when [label] is null.
  final IconData? icon;

  /// Size scale.
  final GenaiButtonSize size;

  /// Visual variant.
  final GenaiToggleButtonVariant variant;

  /// When `true`, the button is disabled independently of [onChanged].
  final bool isDisabled;

  /// Tooltip on hover.
  final String? tooltip;

  /// Screen-reader label. Falls back to [label].
  final String? semanticLabel;

  const GenaiToggleButton({
    super.key,
    required this.pressed,
    this.onChanged,
    this.label,
    this.icon,
    this.size = GenaiButtonSize.md,
    this.variant = GenaiToggleButtonVariant.solid,
    this.isDisabled = false,
    this.tooltip,
    this.semanticLabel,
  });

  @override
  State<GenaiToggleButton> createState() => _GenaiToggleButtonState();
}

class _GenaiToggleButtonState extends State<GenaiToggleButton> {
  bool _hovered = false;
  bool _pressing = false;
  bool _focused = false;

  bool get _disabled => widget.isDisabled || widget.onChanged == null;

  void _handleTap() {
    if (_disabled) return;
    HapticFeedback.selectionClick();
    widget.onChanged?.call(!widget.pressed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius.md;
    final spec = GenaiButtonSpec.resolve(context, widget.size);
    final hasLabel = widget.label != null;

    Color bg;
    Color fg;
    Color? borderColor;

    if (widget.pressed) {
      bg = colors.colorPrimarySubtle;
      fg = colors.colorPrimaryText;
      if (widget.variant == GenaiToggleButtonVariant.outline) {
        borderColor = colors.colorPrimary;
      }
    } else {
      bg = Colors.transparent;
      fg = colors.textPrimary;
      if (widget.variant == GenaiToggleButtonVariant.outline) {
        borderColor = colors.borderStrong;
      }
    }

    if (!_disabled) {
      if (_pressing) {
        bg = widget.pressed ? colors.colorPrimarySubtle : colors.surfacePressed;
      } else if (_hovered) {
        bg = widget.pressed ? colors.colorPrimarySubtle : colors.surfaceHover;
      }
    }

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: spec.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: spec.gap));
      children.add(
        Text(
          widget.label!,
          style: spec.labelStyleFor(context).copyWith(color: fg),
        ),
      );
    }

    Widget button = Container(
      height: spec.height,
      constraints: BoxConstraints(minWidth: spec.height),
      padding: EdgeInsets.symmetric(
        horizontal: hasLabel ? spec.paddingH : 0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor, width: sizing.dividerThickness)
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );

    Widget result = Opacity(opacity: _disabled ? 0.5 : 1.0, child: button);

    // Focus ring as non-layout overlay (no bounds shift on focus toggle).
    if (_focused && !_disabled) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            left: -sizing.focusRingOffset,
            top: -sizing.focusRingOffset,
            right: -sizing.focusRingOffset,
            bottom: -sizing.focusRingOffset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.radius.xs + sizing.focusRingOffset,
                  ),
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

    result = MouseRegion(
      cursor:
          _disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      opaque: false,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered || _pressing) {
          setState(() {
            _hovered = false;
            _pressing = false;
          });
        }
      },
      child: Focus(
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _disabled ? null : (_) => setState(() => _pressing = true),
          onTapCancel:
              _disabled ? null : () => setState(() => _pressing = false),
          onTapUp: _disabled ? null : (_) => setState(() => _pressing = false),
          onTap: _disabled ? null : _handleTap,
          child: result,
        ),
      ),
    );

    if (spec.height < sizing.minTouchTarget) {
      result = ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
        child: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: result,
        ),
      );
    }

    result = Semantics(
      button: true,
      toggled: widget.pressed,
      enabled: !_disabled,
      focused: _focused,
      label: widget.semanticLabel ?? widget.label,
      child: result,
    );

    if (widget.tooltip != null) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }

    return result;
  }
}
