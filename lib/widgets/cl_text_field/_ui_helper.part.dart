part of '../cl_text_field.widget.dart';

/// UI rendering: build, decoration, suffix dispatch, small widgets, formatters.
class _TextFieldUiHelper extends _Helper {
  _TextFieldUiHelper(super.s);

  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final bool isInline = w.dateFieldType != null;
    final String? semanticLabelText = w.isTextArea
        ? null
        : (s.shouldShowRequired ? '${w.labelText}*' : w.labelText);

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

    // ─── textArea path: untouched (uses Material InputDecorator) ────────
    if (w.isTextArea) {
      final formField = TextFormField(
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
        maxLines: w.maxLines,
        keyboardType: w.inputType,
        obscureText: false,
        enabled: w.isEnabled,
        onChanged: w.onChanged,
        inputFormatters: w.inputFormatters ?? _defaultInputFormatters(),
        style: theme.bodyText.copyWith(fontWeight: FontWeight.w400, height: 1.0),
        decoration: _decoration(context, theme),
        validator: _combineValidators(_effectiveValidators),
      );
      return MouseRegion(
        cursor: !w.isEnabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
        child: formField,
      );
    }

    // ─── non-textArea: custom Container chrome — exact 40px ─────────────
    // Bypass InputDecorator entirely. Material's InputDecorator reserves
    // vertical space for label + helper + error + tap-target floor that
    // forces the field above 40px even with isDense, hintText, and
    // shrinkWrap. By rendering chrome ourselves we get pixel-perfect 40.
    final hintText = w.dateFieldType?.hint ??
        (s.shouldShowRequired ? '${w.labelText}*' : w.labelText);

    final innerField = TextFormField(
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
      maxLines: 1,
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
      style: theme.bodyText.copyWith(fontWeight: FontWeight.w400),
      // Full InputDecoration with border.none + isDense + symmetric vertical
      // padding tuned to center text in the 40px Container.
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        hintText: hintText,
        hintStyle: theme.bodyText.copyWith(color: theme.mutedForeground),
      ),
      validator: _combineValidators(_effectiveValidators),
    );

    final hasPrefix = w.prefixIcon != null;
    final suffix = _suffixIcon(context, theme);

    final Widget chrome = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: CLSizes.inputHeight,
      decoration: BoxDecoration(
        color: w.isEnabled
            ? (w.fillColor ?? theme.secondaryBackground)
            : (w.fillColor ?? theme.secondaryBackground)
                .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(
            w.isRounded ? CLSizes.inputHeight / 2 : CLSizes.radiusControl),
        border: Border.all(
          color: s.isFocusedRef
              ? theme.ring
              : (w.isEnabled
                  ? theme.cardBorder
                  : theme.cardBorder.withValues(alpha: 0.5)),
          width: 1,
        ),
        boxShadow: s.isFocusedRef
            ? [BoxShadow(color: theme.ring, spreadRadius: 1, blurRadius: 0)]
            : null,
      ),
      child: Row(
        children: [
          if (hasPrefix)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: w.prefixIcon,
            )
          else
            const SizedBox(width: 12),
          Expanded(child: innerField),
          if (suffix != null) suffix else const SizedBox(width: 12),
        ],
      ),
    );

    // Material ancestor still required for TextFormField internals
    // (selection, IME, ripple). Force shrinkWrap to neutralize any
    // residual tap-target floor inherited from app theme.
    final themedChrome = Theme(
      data: Theme.of(context).copyWith(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: chrome,
      ),
    );

    final field = MouseRegion(
      cursor: !w.isEnabled
          ? SystemMouseCursors.forbidden
          : gestureTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.text,
      child: GestureDetector(
        onTap: gestureTap,
        child: AbsorbPointer(
          absorbing: absorb,
          child: themedChrome,
        ),
      ),
    );

    return semanticLabelText == null
        ? field
        : Semantics(label: semanticLabelText, textField: true, child: field);
  }

  InputDecoration _decoration(BuildContext context, CLTheme theme) {
    OutlineInputBorder b(Color c, double bw) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(CLSizes.radiusControl),
          borderSide: BorderSide(color: c, width: bw),
        );
    final String labelOrHint =
        s.shouldShowRequired ? '${w.labelText}*' : w.labelText;
    // For non-textArea fields we render the label as hintText (placeholder)
    // instead of labelText. labelText reserves vertical space above the input
    // for floating-label position, pushing intrinsic height to ~48 even with
    // isDense:true. hintText does NOT reserve that space, so the field
    // collapses to ~36-38 intrinsic and fits CLSizes.inputHeight (40) cleanly.
    // Accessibility: an outer Semantics(label:...) preserves screen-reader
    // announcement of the field name.
    final bool useHintForLabel = !w.isTextArea;
    return InputDecoration(
      isDense: true,
      floatingLabelBehavior:
          w.isTextArea ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
      floatingLabelStyle: w.isTextArea
          ? theme.smallText.copyWith(
              color: s.isFocusedRef ? theme.primary : theme.secondaryText,
              fontWeight: s.isFocusedRef ? FontWeight.w500 : FontWeight.w400,
              height: 1,
            )
          : null,
      labelStyle: w.isTextArea ? theme.bodyLabel : null,
      alignLabelWithHint: w.isTextArea,
      errorMaxLines: 200,
      // Vertical padding tuned so that border(1+1) + text(~14 @ fs13/h1.0) +
      // pad(10+10) ≈ 36 ≤ CLSizes.inputHeight (40). InputDecorator centers the
      // content vertically inside the SizedBox(40) outer wrap → exact 40px slot
      // matching CLButton.primary.
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelText: w.isTextArea ? labelOrHint : null,
      hintText: useHintForLabel ? (w.dateFieldType?.hint ?? labelOrHint) : w.dateFieldType?.hint,
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
