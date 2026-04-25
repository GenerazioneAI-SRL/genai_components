import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// One option inside a [GenaiNativeSelect] — v3 design system (Forma LMS).
///
/// A lightweight twin of `GenaiSelectOption` purpose-built for the native
/// dropdown — no description, no per-option disable state.
class GenaiNativeSelectOption<T> {
  /// Value identifying the option.
  final T value;

  /// Display text shown both inside the menu and on the trigger.
  final String label;

  /// Optional leading icon shown beside [label].
  final IconData? icon;

  const GenaiNativeSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Platform-feeling dropdown styled to v3 tokens.
///
/// Wraps Flutter's [DropdownButton] so consumers get the OS-native menu
/// behaviour (instant open/close, no overlay layer) while inheriting border,
/// focus ring, typography and colours from the v3 theme. Use this when
/// `GenaiSelect`'s richer affordances (search, async, multi) are overkill.
class GenaiNativeSelect<T> extends StatefulWidget {
  /// Available options. Pass an empty list to render a disabled trigger.
  final List<GenaiNativeSelectOption<T>> options;

  /// Currently selected value. Must equal one of [options]' values, or be `null`.
  final T? value;

  /// Called when the user picks a different value. Pass `null` to disable.
  final ValueChanged<T?>? onChanged;

  /// Placeholder shown when [value] is `null`.
  final String? hintText;

  /// Field label rendered above the trigger.
  final String? label;

  /// Helper line below the trigger.
  final String? helperText;

  /// Error line below the trigger; takes precedence over [helperText].
  final String? errorText;

  /// Disables the control regardless of [onChanged].
  final bool isDisabled;

  /// Renders a danger-coloured asterisk after [label].
  final bool isRequired;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiNativeSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.hintText,
    this.label,
    this.helperText,
    this.errorText,
    this.isDisabled = false,
    this.isRequired = false,
    this.semanticLabel,
  });

  @override
  State<GenaiNativeSelect<T>> createState() => _GenaiNativeSelectState<T>();
}

class _GenaiNativeSelectState<T> extends State<GenaiNativeSelect<T>> {
  bool _focused = false;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  bool get _disabled => widget.isDisabled || widget.onChanged == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    // Mirror GenaiSelect's per-density trigger heights for visual parity.
    final height = switch (sizing.density.name) {
      'compact' => 36.0,
      'spacious' => 44.0,
      _ => 40.0,
    };

    final borderColor = _disabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : (_focused ? colors.borderFocus : colors.borderDefault);
    final borderWidth = (_focused || _hasError)
        ? sizing.focusRingWidth
        : sizing.dividerThickness;

    final textStyle = ty.body.copyWith(
      color: _disabled ? colors.textDisabled : colors.textPrimary,
    );
    final hintStyle = textStyle.copyWith(color: colors.textTertiary);

    Widget trigger = AnimatedContainer(
      duration: context.motion.hover.duration,
      curve: context.motion.hover.curve,
      constraints: BoxConstraints(minHeight: height),
      padding: EdgeInsets.symmetric(horizontal: spacing.s12),
      decoration: BoxDecoration(
        color: _disabled ? colors.surfaceHover : colors.surfaceInput,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: DropdownButtonHideUnderline(
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: colors.surfaceOverlay,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: DropdownButton<T>(
            value: widget.value,
            isExpanded: true,
            icon: Icon(
              LucideIcons.chevronDown,
              size: sizing.iconSize,
              color: colors.textTertiary,
            ),
            iconEnabledColor: colors.textTertiary,
            iconDisabledColor: colors.textDisabled,
            style: textStyle,
            hint: widget.hintText == null
                ? null
                : Text(widget.hintText!, style: hintStyle),
            borderRadius: BorderRadius.circular(radius.md),
            dropdownColor: colors.surfaceOverlay,
            focusColor: Colors.transparent,
            elevation: 8,
            menuMaxHeight: 320,
            isDense: false,
            onChanged: _disabled ? null : widget.onChanged,
            items: [
              for (final o in widget.options)
                DropdownMenuItem<T>(
                  value: o.value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (o.icon != null) ...[
                        Icon(
                          o.icon,
                          size: sizing.iconSize,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: spacing.iconLabelGap),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (height < sizing.minTouchTarget) {
      trigger = ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
        child: trigger,
      );
    }

    return Semantics(
      button: true,
      enabled: !_disabled,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText,
      value: widget.options
          .where((o) => o.value == widget.value)
          .map((o) => o.label)
          .firstOrNull,
      child: FieldFrame(
        label: widget.label,
        isRequired: widget.isRequired,
        isDisabled: _disabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        control: Focus(
          onFocusChange: (f) {
            if (_focused != f) setState(() => _focused = f);
          },
          canRequestFocus: !_disabled,
          child: trigger,
        ),
      ),
    );
  }
}
