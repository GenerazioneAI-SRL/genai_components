part of '../cl_text_field.widget.dart';

/// UI rendering: build, decoration, suffix dispatch, small widgets, formatters.
class _TextFieldUiHelper extends _Helper {
  _TextFieldUiHelper(super.s);

  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final bool isInline = w.dateFieldType != null;

    final VoidCallback? gestureTap = w.onColorPicked != null
        ? () => s._colorHelper.pick(context)
        : (!isInline && (w.onDateTimeSelected != null || w.onTimeSelected != null))
            ? () => s._dateHelper.selectDate(context)
            : w.onFilePicked != null
                ? () => s._fileHelper.pick(context)
                : null;

    final bool absorb = (!isInline &&
            (w.onDateTimeSelected != null || w.onTimeSelected != null) &&
            !s.isDatePicked) ||
        w.onColorPicked != null ||
        (w.onFilePicked != null && !s.isFilePicked);

    final bool readOnly = isInline
        ? w.isReadOnly
        : w.onFilePicked != null
            ? s.isFilePicked
            : w.onDateTimeSelected != null
                ? s.isDatePicked
                : w.isReadOnly;

    return MouseRegion(
      cursor: !w.isEnabled
          ? SystemMouseCursors.forbidden
          : gestureTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.text,
      child: GestureDetector(
        onTap: gestureTap,
        child: AbsorbPointer(
          absorbing: absorb,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            textCapitalization:
                w.capitalize ? TextCapitalization.sentences : TextCapitalization.none,
            cursorColor: theme.primary,
            cursorWidth: 1.5,
            cursorRadius: const Radius.circular(1),
            readOnly: readOnly,
            onTap: w.onTap,
            controller: s.controllerRef,
            focusNode: s.focusNodeRef,
            maxLines: w.isTextArea ? w.maxLines : 1,
            keyboardType: isInline ? TextInputType.number : w.inputType,
            obscureText: w.isObscured && !s.isPasswordVisibleRef,
            enabled: w.isEnabled,
            onChanged: isInline
                ? (value) {
                    // ignore: invalid_use_of_protected_member
                    s.setState(() {});
                    _handleDateFieldParsing(value);
                    w.onChanged?.call(value);
                  }
                : w.onChanged,
            inputFormatters: isInline
                ? [DateMaskFormatter(w.dateFieldType!)]
                : (w.inputFormatters ?? _defaultInputFormatters()),
            style: theme.bodyText.copyWith(fontWeight: FontWeight.w400, height: 1.4),
            decoration: _decoration(context, theme),
            validator: _combineValidators(_effectiveValidators),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, CLTheme theme) {
    OutlineInputBorder b(Color c, double bw) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusSm),
          borderSide: BorderSide(color: c, width: bw),
        );
    return InputDecoration(
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: theme.smallText.copyWith(
        color: s.isFocusedRef ? theme.primary : theme.secondaryText,
        fontWeight: s.isFocusedRef ? FontWeight.w500 : FontWeight.w400,
        height: 1,
      ),
      labelStyle: theme.bodyLabel,
      alignLabelWithHint: w.isTextArea,
      errorMaxLines: 200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelText: s.shouldShowRequired ? '${w.labelText}*' : w.labelText,
      hintText: w.dateFieldType?.hint,
      hintStyle: theme.bodyText.copyWith(color: theme.mutedForeground),
      prefixIcon: w.prefixIcon != null
          ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: w.prefixIcon)
          : null,
      prefixIconConstraints: w.prefixIconConstraints ??
          (w.prefixIcon != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null),
      suffixIcon: _suffixIcon(context, theme),
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      hoverColor: Colors.transparent,
      filled: true,
      fillColor: w.fillColor ?? theme.secondaryBackground,
      enabledBorder: b(theme.cardBorder, 1.0),
      focusedBorder: b(theme.ring, 2.0),
      errorBorder: b(theme.danger, 1.0),
      focusedErrorBorder: b(theme.danger, 2.0),
      disabledBorder: b(theme.cardBorder.withValues(alpha: 0.5), 1.0),
      errorStyle: theme.smallLabel.copyWith(color: theme.danger, fontSize: 11, height: 1.3),
    );
  }

  Widget? _suffixIcon(BuildContext context, CLTheme theme) {
    if (w.dateFieldType != null) {
      return s.controllerRef.text.isNotEmpty
          ? _clearButton(theme, () {
              // ignore: invalid_use_of_protected_member
              s.setState(() {
                s.controllerRef.clear();
                w.onDateTimeSelected?.call(null);
                w.onTimeSelected?.call(null);
              });
            })
          : _dateFieldTypeIcon(theme);
    }
    if (w.onColorPicked != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: s._colorHelper.hexToColor(w.controller.text),
            border: Border.all(color: theme.borderColor, width: 0.5),
          ),
        ),
      );
    }
    if (w.onFilePicked != null) {
      return s.isFilePicked
          ? _clearButton(theme, () {
              // ignore: invalid_use_of_protected_member
              s.setState(() => s.isFilePicked = false);
              w.onFilePicked!(null);
              s.controllerRef.text = '';
            })
          : Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CLSoftButton.primary(
                icon: FontAwesomeIcons.file,
                text: 'Seleziona file',
                onTap: () {},
                context: context,
                isCompact: true,
              ),
            );
    }
    if (w.onDateTimeSelected != null || w.onTimeSelected != null) {
      return s.isDatePicked
          ? _clearButton(theme, () {
              // ignore: invalid_use_of_protected_member
              s.setState(() => s.isDatePicked = false);
              w.onDateTimeSelected?.call(null);
              w.onTimeSelected?.call(null);
              s.controllerRef.text = '';
            })
          : _calendarIcon(theme);
    }
    if (w.isObscured) return _passwordToggle(theme);
    if (w.inputType == TextInputType.datetime) return _calendarIcon(theme);
    if (w.suffixIcon != null) {
      return Padding(padding: const EdgeInsets.only(right: 10), child: w.suffixIcon);
    }
    return null;
  }

  void _handleDateFieldParsing(String value) {
    final type = w.dateFieldType;
    if (type == null) return;
    if (value.isEmpty) {
      w.onDateTimeSelected?.call(null);
      w.onTimeSelected?.call(null);
      return;
    }
    if (value.length == type.expectedLength) {
      if (type == CLDateFieldType.time && w.onTimeSelected != null) {
        w.onTimeSelected?.call(type.parseTime(value));
      }
      w.onDateTimeSelected?.call(type.parse(value));
    }
  }

  List<FormFieldValidator<String>>? get _effectiveValidators {
    if (w.dateFieldType == null) return w.validators;
    return [
      CLDateFieldValidators.forType(w.dateFieldType!),
      if (w.validators != null) ...w.validators!,
    ];
  }

  List<TextInputFormatter> _defaultInputFormatters() {
    if (w.inputType.decimal != null) {
      return w.inputType.decimal == true
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$'))]
          : [FilteringTextInputFormatter.digitsOnly];
    }
    return [];
  }

  Widget _dateFieldTypeIcon(CLTheme theme) {
    final isTime = w.dateFieldType == CLDateFieldType.time;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: HugeIcon(
        icon: isTime ? HugeIcons.strokeRoundedClock01 : HugeIcons.strokeRoundedCalendar03,
        size: CLTextFieldState.kIconSize,
        color: s.isFocusedRef ? theme.primary : theme.secondaryText,
      ),
    );
  }

  Widget _clearButton(CLTheme theme, VoidCallback onPressed) => GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.close_rounded, size: 18, color: theme.danger.withValues(alpha: 0.8)),
        ),
      );

  Widget _calendarIcon(CLTheme theme) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedCalendar03,
          size: CLTextFieldState.kIconSize,
          color: s.isFocusedRef ? theme.primary : theme.secondaryText,
        ),
      );

  Widget _passwordToggle(CLTheme theme) => GestureDetector(
        onTap: s.togglePasswordVisibility,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(
            s.isPasswordVisibleRef ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            size: CLTextFieldState.kIconSize,
            color: s.isFocusedRef ? theme.primary : theme.secondaryText,
          ),
        ),
      );

  static FormFieldValidator<String>? _combineValidators(
      List<FormFieldValidator<String>>? vs) {
    if (vs == null || vs.isEmpty) return null;
    return (String? value) {
      final errors = <String>[];
      for (final v in vs) {
        final r = v(value);
        if (r != null) errors.add(r);
      }
      return errors.isEmpty ? null : errors.join('\n');
    };
  }
}
