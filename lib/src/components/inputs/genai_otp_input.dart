import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// One-time password / verification code input (§6.1.13).
class GenaiOTPInput extends StatefulWidget {
  final int length;
  final String? value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool isDisabled;
  final bool hasError;
  final bool autofocus;

  const GenaiOTPInput({
    super.key,
    this.length = 6,
    this.value,
    this.onChanged,
    this.onCompleted,
    this.isDisabled = false,
    this.hasError = false,
    this.autofocus = true,
  });

  @override
  State<GenaiOTPInput> createState() => _GenaiOTPInputState();
}

class _GenaiOTPInputState extends State<GenaiOTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    if (widget.value != null) _applyValue(widget.value!);
  }

  @override
  void didUpdateWidget(covariant GenaiOTPInput old) {
    super.didUpdateWidget(old);
    if (widget.value != null && widget.value != _currentValue()) {
      _applyValue(widget.value!);
    }
  }

  void _applyValue(String v) {
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < v.length ? v[i] : '';
    }
  }

  String _currentValue() => _controllers.map((c) => c.text).join();

  void _onChanged(int idx, String v) {
    if (v.length > 1) {
      // Pasted multi-char.
      final chars = v.split('');
      for (var i = 0; i < chars.length && idx + i < widget.length; i++) {
        _controllers[idx + i].text = chars[i];
      }
      final next = (idx + chars.length).clamp(0, widget.length - 1);
      _focusNodes[next].requestFocus();
    } else if (v.isNotEmpty && idx < widget.length - 1) {
      _focusNodes[idx + 1].requestFocus();
    }
    final value = _currentValue();
    widget.onChanged?.call(value);
    if (value.length == widget.length && !value.contains('')) {
      widget.onCompleted?.call(value);
    }
  }

  KeyEventResult _onKey(int idx, FocusNode _, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && _controllers[idx].text.isEmpty && idx > 0) {
      _focusNodes[idx - 1].requestFocus();
      _controllers[idx - 1].clear();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 52,
            child: Focus(
              onKeyEvent: (n, e) => _onKey(i, n, e),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                autofocus: widget.autofocus && i == 0,
                enabled: !widget.isDisabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: ty.headingSm.copyWith(color: colors.textPrimary),
                cursorColor: colors.colorPrimary,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: colors.surfaceInput,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.hasError ? colors.borderError : colors.borderDefault),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.hasError ? colors.borderError : colors.borderDefault),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.hasError ? colors.borderError : colors.borderFocus, width: 2),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Suppress unused field warning during single-state design.
