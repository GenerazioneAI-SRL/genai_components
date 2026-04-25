import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// Multiline text input — v3 Forma LMS (§2 field rules).
///
/// Shares the [GenaiTextField] chrome (same `surfaceCard` fill, 1 px
/// `borderStrong` at rest flipping to `textPrimary` / `borderFocus` /
/// `colorDanger`, radius `md`). When [autoGrow] is true the textarea expands
/// between [minLines] and [maxLines] as the user types; otherwise it scrolls
/// internally after [minLines] is reached.
class GenaiTextarea extends StatefulWidget {
  /// Field label above the textarea.
  final String? label;

  /// Placeholder when empty.
  final String? hintText;

  /// Helper copy below.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// Read-only — focus & select but no edit.
  final bool isReadOnly;

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Minimum visible lines. Defaults to 3.
  final int minLines;

  /// Maximum visible lines (null = unbounded).
  final int? maxLines;

  /// When true, the box grows between [minLines] and [maxLines] as the user
  /// types. When false, it scrolls internally at [minLines].
  final bool autoGrow;

  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiTextarea({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.minLines = 3,
    this.maxLines = 8,
    this.autoGrow = true,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  @override
  State<GenaiTextarea> createState() => _GenaiTextareaState();
}

class _GenaiTextareaState extends State<GenaiTextarea> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownController = false;
  bool _ownFocus = false;
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _ownController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownFocus = widget.focusNode == null;
    _focusNode.addListener(_onFocus);
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _controller.removeListener(_onChanged);
    if (_ownFocus) _focusNode.dispose();
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() => _focused = _focusNode.hasFocus);
  void _onChanged() => setState(() {});

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : (_focused || _hovered)
                ? colors.textPrimary
                : colors.borderStrong;
    final borderWidth = (_focused || _hasError) ? sizing.focusRingWidth : 1.0;

    final bg = widget.isDisabled
        ? colors.surfaceHover
        : (widget.isReadOnly ? colors.surfacePage : colors.surfaceCard);

    final inputStyle = ty.bodySm.copyWith(
      color: widget.isDisabled ? colors.textDisabled : colors.textPrimary,
    );

    final control = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      padding:
          EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: !widget.isDisabled,
        readOnly: widget.isReadOnly,
        style: inputStyle,
        cursorColor: colors.colorPrimary,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: widget.minLines,
        maxLines: widget.autoGrow ? widget.maxLines : widget.minLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        buildCounter: (_,
                {required currentLength, required isFocused, maxLength}) =>
            null,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.isDisabled ? null : widget.hintText,
          hintStyle: inputStyle.copyWith(color: colors.textTertiary),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );

    final counter = widget.maxLength == null
        ? null
        : ExcludeSemantics(
            child: Text(
              '${_controller.text.characters.length} / ${widget.maxLength}',
              style: ty.labelSm.copyWith(color: colors.textTertiary),
            ),
          );

    return Semantics(
      textField: true,
      multiline: true,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText,
      value: _controller.text,
      enabled: !widget.isDisabled,
      readOnly: widget.isReadOnly,
      focused: _focused,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: FieldFrame(
          label: widget.label,
          isRequired: widget.isRequired,
          isDisabled: widget.isDisabled,
          helperText: widget.helperText,
          errorText: widget.errorText,
          trailingHelper: counter,
          control: control,
        ),
      ),
    );
  }
}
