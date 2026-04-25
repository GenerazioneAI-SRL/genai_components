import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// One-time-password input — v3 Forma LMS.
///
/// Renders [length] separate square slots styled like [GenaiTextField].
/// Typing auto-advances focus; backspace on an empty box walks back.
/// [onCompleted] fires when all [length] slots are filled.
class GenaiOtpInput extends StatefulWidget {
  /// Number of digit slots. Usually 4 or 6.
  final int length;

  /// Current value. If null, the widget manages its own state.
  final String? value;

  /// Fired on every keystroke with the combined value.
  final ValueChanged<String>? onChanged;

  /// Fired when the value reaches [length] characters.
  final ValueChanged<String>? onCompleted;

  /// Field label above the slots.
  final String? label;

  /// Helper copy below the slots.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colour, no interaction.
  final bool isDisabled;

  /// When true, accept digits only; when false, any character.
  final bool digitsOnly;

  /// Autofocus the first slot.
  final bool autofocus;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiOtpInput({
    super.key,
    this.length = 6,
    this.value,
    this.onChanged,
    this.onCompleted,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.digitsOnly = true,
    this.autofocus = false,
    this.semanticLabel,
  }) : assert(length > 0, 'OTP length must be positive.');

  @override
  State<GenaiOtpInput> createState() => _GenaiOtpInputState();
}

class _GenaiOtpInputState extends State<GenaiOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<bool> _focusedFlags;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (i) => TextEditingController(
          text: i < (widget.value?.length ?? 0) ? widget.value![i] : ''),
    );
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _focusedFlags = List.filled(widget.length, false);
    for (var i = 0; i < widget.length; i++) {
      final idx = i;
      _focusNodes[i].addListener(() {
        setState(() => _focusedFlags[idx] = _focusNodes[idx].hasFocus);
      });
    }
  }

  @override
  void didUpdateWidget(covariant GenaiOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _currentValue()) {
      for (var i = 0; i < widget.length; i++) {
        final c = i < widget.value!.length ? widget.value![i] : '';
        if (_controllers[i].text != c) _controllers[i].text = c;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _currentValue() => _controllers.map((c) => c.text).join();

  void _onSlotChanged(int index, String raw) {
    String v = raw;
    if (widget.digitsOnly) {
      v = v.replaceAll(RegExp(r'[^0-9]'), '');
    }
    if (v.length > 1) {
      for (var i = index; i < widget.length && i - index < v.length; i++) {
        _controllers[i].text = v[i - index];
      }
      final nextIndex = (index + v.length).clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
    } else {
      _controllers[index].text = v;
      if (v.isNotEmpty && index + 1 < widget.length) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    final combined = _currentValue();
    widget.onChanged?.call(combined);
    if (combined.length == widget.length &&
        !combined.contains('') &&
        combined.runes.length == widget.length) {
      widget.onCompleted?.call(combined);
    }
  }

  KeyEventResult _onKey(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].text = '';
        widget.onChanged?.call(_currentValue());
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    Widget buildSlot(int index) {
      final focused = _focusedFlags[index];
      final borderColor = widget.isDisabled
          ? colors.borderSubtle
          : hasError
              ? colors.colorDanger
              : focused
                  ? colors.borderFocus
                  : colors.borderStrong;
      final borderWidth = (focused || hasError) ? sizing.focusRingWidth : 1.0;

      return AnimatedContainer(
        duration: motion.hover.duration,
        curve: motion.hover.curve,
        width: 40,
        height: 44,
        decoration: BoxDecoration(
          color: widget.isDisabled ? colors.surfaceHover : colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        alignment: Alignment.center,
        child: Focus(
          onKeyEvent: (node, e) => _onKey(index, node, e),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            autofocus: widget.autofocus && index == 0,
            enabled: !widget.isDisabled,
            keyboardType:
                widget.digitsOnly ? TextInputType.number : TextInputType.text,
            inputFormatters: widget.digitsOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: ty.focusTitle.copyWith(
                color: widget.isDisabled
                    ? colors.textDisabled
                    : colors.textPrimary),
            cursorColor: colors.colorPrimary,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => _onSlotChanged(index, v),
          ),
        ),
      );
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) SizedBox(width: spacing.s8),
          buildSlot(i),
        ],
      ],
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.label ?? 'Codice monouso',
      textField: true,
      enabled: !widget.isDisabled,
      child: FieldFrame(
        label: widget.label,
        isRequired: widget.isRequired,
        isDisabled: widget.isDisabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        control: row,
      ),
    );
  }
}
