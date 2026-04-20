import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_icon_button.dart';
import '../feedback/genai_spinner.dart';

/// When validation runs.
enum GenaiValidateOn { blur, type, submit }

/// Text input for the Genai design system (§6.1.1).
///
/// Named constructors:
/// - [GenaiTextField.password]
/// - [GenaiTextField.search]
/// - [GenaiTextField.numeric]
/// - [GenaiTextField.multiline]
class GenaiTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;

  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final GenaiValidateOn validateOn;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool isDisabled;
  final bool isReadOnly;
  final bool isLoading;

  final int? maxLength;
  final bool showCounter;
  final bool clearable;
  final int? maxLines;
  final int? minLines;

  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;

  final GenaiSize size;
  final String? semanticLabel;

  const GenaiTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.validateOn = GenaiValidateOn.blur,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isLoading = false,
    this.maxLength,
    this.showCounter = false,
    this.clearable = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  });

  const GenaiTextField.password({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.validateOn = GenaiValidateOn.blur,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isLoading = false,
    this.maxLength,
    this.showCounter = false,
    this.focusNode,
    this.autofocus = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : prefix = null,
        suffix = null,
        prefixText = null,
        suffixText = null,
        keyboardType = TextInputType.visiblePassword,
        textInputAction = TextInputAction.done,
        obscureText = true,
        clearable = false,
        maxLines = 1,
        minLines = null,
        inputFormatters = null;

  const GenaiTextField.search({
    super.key,
    this.hint = 'Cerca...',
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.isDisabled = false,
    this.isLoading = false,
    this.focusNode,
    this.autofocus = false,
    this.size = GenaiSize.sm,
    this.semanticLabel,
  })  : label = null,
        helperText = null,
        errorText = null,
        prefix = null,
        suffix = null,
        prefixText = null,
        suffixText = null,
        validator = null,
        validateOn = GenaiValidateOn.blur,
        keyboardType = TextInputType.text,
        textInputAction = TextInputAction.search,
        obscureText = false,
        isReadOnly = false,
        maxLength = null,
        showCounter = false,
        clearable = true,
        maxLines = 1,
        minLines = null,
        inputFormatters = null;

  const GenaiTextField.numeric({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.validateOn = GenaiValidateOn.blur,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isLoading = false,
    this.maxLength,
    this.showCounter = false,
    this.clearable = false,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : keyboardType = const TextInputType.numberWithOptions(decimal: true),
        textInputAction = TextInputAction.done,
        obscureText = false,
        maxLines = 1,
        minLines = null;

  const GenaiTextField.multiline({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.validateOn = GenaiValidateOn.blur,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isLoading = false,
    this.maxLength,
    this.showCounter = true,
    this.minLines = 3,
    this.maxLines = 8,
    this.focusNode,
    this.autofocus = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : prefix = null,
        suffix = null,
        prefixText = null,
        suffixText = null,
        keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        obscureText = false,
        clearable = false,
        inputFormatters = null;

  @override
  State<GenaiTextField> createState() => _GenaiTextFieldState();
}

class _GenaiTextFieldState extends State<GenaiTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownController = false;
  bool _ownFocus = false;

  bool _focused = false;
  bool _obscured = true;
  String? _internalError;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _ownController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownFocus = widget.focusNode == null;

    _focusNode.addListener(_handleFocus);
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(covariant GenaiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownController = widget.controller == null;
      _controller.addListener(_handleChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _controller.removeListener(_handleChanged);
    if (_ownFocus) _focusNode.dispose();
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() => _focused = _focusNode.hasFocus);
    if (!_focused && widget.validateOn == GenaiValidateOn.blur) {
      _runValidation();
    }
  }

  void _handleChanged() {
    if (widget.validateOn == GenaiValidateOn.type) {
      _runValidation();
    } else if (_internalError != null) {
      // Clear stale error while typing.
      setState(() => _internalError = null);
    }
    setState(() {}); // refresh for clear-button visibility / counter
  }

  void _runValidation() {
    final v = widget.validator;
    if (v == null) return;
    final error = v(_controller.text);
    if (error != _internalError) {
      setState(() => _internalError = error);
    }
  }

  String? get _resolvedError => widget.errorText ?? _internalError;
  bool get _hasError => _resolvedError != null && _resolvedError!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final isCompact = context.isCompact;
    final h = widget.maxLines != null && widget.maxLines! > 1 ? null : widget.size.resolveHeight(isCompact: isCompact);

    final borderColor = _hasError ? colors.borderError : (_focused ? colors.borderFocus : colors.borderDefault);
    final borderWidth = _focused || _hasError ? 2.0 : 1.0;

    final bg = widget.isDisabled ? colors.surfaceHover : (widget.isReadOnly ? colors.surfacePage : colors.surfaceInput);

    final inputStyle = ty.bodyMd.copyWith(
      color: widget.isDisabled ? colors.textDisabled : colors.textPrimary,
      fontSize: widget.size.fontSize,
    );

    final isPassword = widget.obscureText;
    final isSearch = widget.keyboardType == TextInputType.text && widget.hint == 'Cerca...' && widget.clearable;
    final hasValue = _controller.text.isNotEmpty;

    final prefixWidget = widget.prefix ??
        (isSearch
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Icon(LucideIcons.search, size: widget.size.iconSize, color: colors.textSecondary),
              )
            : (widget.prefixText != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Text(widget.prefixText!, style: inputStyle.copyWith(color: colors.textSecondary)),
                  )
                : null));

    final suffixActions = <Widget>[];
    if (widget.isLoading) {
      suffixActions.add(GenaiSpinner(size: widget.size, color: colors.textSecondary));
    } else {
      if (widget.clearable && hasValue && !widget.isDisabled && !widget.isReadOnly) {
        suffixActions.add(GenaiIconButton(
          icon: LucideIcons.x,
          size: GenaiSize.xs,
          semanticLabel: 'Cancella',
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
        ));
      }
      if (isPassword) {
        suffixActions.add(GenaiIconButton(
          icon: _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
          size: GenaiSize.xs,
          semanticLabel: _obscured ? 'Mostra password' : 'Nascondi password',
          onPressed: () => setState(() => _obscured = !_obscured),
        ));
      }
    }

    if (widget.suffixText != null) {
      suffixActions.insert(
        0,
        Text(widget.suffixText!, style: inputStyle.copyWith(color: colors.textSecondary)),
      );
    }
    if (widget.suffix != null) suffixActions.insert(0, widget.suffix!);

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      obscureText: isPassword && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: !widget.isDisabled,
      readOnly: widget.isReadOnly,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      inputFormatters: widget.inputFormatters,
      style: inputStyle,
      cursorColor: colors.colorPrimary,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.isDisabled ? null : widget.hint,
        hintStyle: inputStyle.copyWith(color: colors.textSecondary),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixWidget == null ? widget.size.paddingH : 0,
          vertical: widget.size.paddingV,
        ),
      ),
    );

    Widget container = AnimatedContainer(
      duration: GenaiDurations.hover,
      height: h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.size.borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        crossAxisAlignment: widget.maxLines != null && widget.maxLines! > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (prefixWidget != null) prefixWidget,
          Expanded(child: field),
          if (suffixActions.isNotEmpty) ...[
            ...suffixActions.map((w) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: w,
                )),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );

    final children = <Widget>[];
    if (widget.label != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(widget.label!, style: ty.label.copyWith(color: colors.textPrimary)),
      ));
    }
    children.add(container);

    final showHelper = widget.helperText != null || _hasError;
    final showCounter = widget.showCounter && widget.maxLength != null;
    if (showHelper || showCounter) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            if (showHelper)
              Expanded(
                child: Row(
                  children: [
                    if (_hasError) ...[
                      Icon(LucideIcons.circleAlert, size: 14, color: colors.textError),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        _resolvedError ?? widget.helperText ?? '',
                        style: ty.caption.copyWith(
                          color: _hasError ? colors.textError : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Spacer(),
            if (showCounter)
              Text(
                '${_controller.text.characters.length} / ${widget.maxLength}',
                style: ty.caption.copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ));
    }

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: !widget.isDisabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
