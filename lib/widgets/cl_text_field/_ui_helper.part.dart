part of '../cl_text_field.widget.dart';

/// Altezza min/max della textArea ridimensionabile via grip (shadcn: 80/500).
const double _kTextAreaMinHeight = 88.0;
const double _kTextAreaMaxHeight = 320.0;

/// UI rendering: build, decoration, suffix dispatch, small widgets, formatters.
class _TextFieldUiHelper extends _Helper {
  _TextFieldUiHelper(super.s);

  /// Altezza cursore in compact: deve stare nel box testo da 18px
  /// (32 − 2 bordo − 12 padding verticale). Senza override il cursore segue
  /// fontSize × lineHeight (≈22px con bodyText 14/1.6) e sforerebbe.
  static const double _kCompactCursorHeight = 16.0;

  /// Altezza cursore default (box 40). Il testo forza `height: 1.0` → la riga
  /// vale solo il fontSize (14px) e un cursore `null` risulterebbe corto nel box
  /// alto. 18px = cursore normale per font 14, proporzionato al compact (16/32).
  static const double _kCursorHeight = 18.0;

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

    final bool absorb = (!isInline && (w.onDateTimeSelected != null || w.onTimeSelected != null) && !s.isDatePicked) ||
        w.onColorPicked != null ||
        (w.onFilePicked != null && !s.isFilePicked);

    final bool readOnly = isInline
        ? w.isReadOnly
        : w.onFilePicked != null
            ? s.isFilePicked
            : w.onDateTimeSelected != null
                ? s.isDatePicked
                : w.isReadOnly;

    final double inputH = w.isCompact ? theme.inputHeightCompact : theme.inputHeight;
    final double radius =
        w.isRounded ? (w.isTextArea ? theme.radiusControl : inputH / 2) : theme.radiusControl;

    // Recessed (search/toolbar) = campo inline: NESSUNA label sopra, `labelText`
    // resta placeholder interno (comportamento storico). Altrimenti stack shadcn:
    // label sopra + placeholder interno da `hintText`.
    final bool showLabel = w.labelText.isNotEmpty && !w.recessed;
    final String? placeholder =
        w.hintText ?? w.dateFieldType?.hint ?? (w.recessed ? w.labelText : null);
    final String labelStr = s.shouldShowRequired ? '${w.labelText} *' : w.labelText;

    // FormField avvolge il campo: espone hasError/errorText allo stack.
    return FormField<String>(
      key: s.fieldKey,
      initialValue: s.controllerRef.text,
      validator: _combineValidators(_effectiveValidators),
      builder: (fieldState) {
        final bool hasError = fieldState.hasError;
        final String? errorText = fieldState.errorText;

        // Nucleo = ShadInput (budella Shad), NUDO: `ShadDecoration.none` toglie
        // bordo/fill/ring di Shad — quel chrome resta disegnato dal chrome CL
        // esterno (BoxDecoration + CLFocusRingPainter), così zero doppio-chrome e
        // zero regressione visiva. Padding orizzontale 0: prefix/suffix + gapMd li
        // gestisce la Row esterna. `constraints` azzera il minHeight globale (40
        // da inputTheme): l'altezza la fissa il chrome CL (32/40/textArea).
        // (didChange sul FormField è gestito dal listener del controller in State.)
        final Widget innerField = ShadInput(
          controller: s.controllerRef,
          focusNode: s.focusNodeRef,
          textCapitalization: w.capitalize ? TextCapitalization.sentences : TextCapitalization.none,
          cursorColor: theme.primary,
          cursorWidth: 1.5,
          cursorHeight: w.isTextArea
              ? null
              : (w.isCompact ? _kCompactCursorHeight : _kCursorHeight),
          cursorRadius: const Radius.circular(1),
          readOnly: readOnly,
          onPressed: w.onTap,
          maxLines: w.isTextArea ? null : 1,
          minLines: null,
          expands: w.isTextArea,
          keyboardType: isInline ? TextInputType.number : w.inputType,
          obscureText: w.isObscured && !s.isPasswordVisibleRef,
          enabled: w.isEnabled,
          onChanged: (value) {
            if (isInline) {
              // ignore: invalid_use_of_protected_member
              s.setState(() {});
              _handleDateFieldParsing(value);
            }
            w.onChanged?.call(value);
          },
          inputFormatters:
              isInline ? [DateMaskFormatter(w.dateFieldType!)] : (w.inputFormatters ?? _defaultInputFormatters()),
          style: theme.bodyText.copyWith(fontWeight: FontWeight.w400, height: 1.0),
          placeholder: placeholder != null ? Text(placeholder) : null,
          placeholderStyle: theme.bodyText.copyWith(color: theme.mutedForeground, height: 1.0),
          decoration: ShadDecoration.none,
          padding: EdgeInsets.symmetric(
              vertical: w.isTextArea ? theme.gapMd : (w.isCompact ? theme.gapSm * 0.75 : theme.gapMd)),
          constraints: const BoxConstraints(),
        );

        final bool hasPrefix = w.prefixIcon != null;
        final Widget? suffix = _suffixIcon(context, theme);

        // Icone uniformi: colore focus-aware + size da token. Prefix/suffix
        // (anche quelli passati dai factory, ora senza colore) ereditano via
        // IconTheme e reagiscono al focus come le icone interne.
        final IconThemeData iconTheme = IconThemeData(
          color: !w.isEnabled
              ? theme.secondaryText.withValues(alpha: 0.5)
              : (s.isFocusedRef ? theme.primary : theme.secondaryText),
          size: w.isCompact ? theme.iconSizeCompact : CLTextFieldState.kIconSize,
        );

        // Altezza textArea: gestita da stato (resize via grip), clamp min/max.
        final double taHeight = (s.textAreaHeight ?? _kTextAreaMinHeight)
            .clamp(_kTextAreaMinHeight, _kTextAreaMaxHeight);

        final Widget rowContent = Row(
          crossAxisAlignment:
              w.isTextArea ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (hasPrefix)
              Padding(
                padding: EdgeInsets.only(left: theme.gapMd, right: theme.gapSm),
                child: IconTheme.merge(data: iconTheme, child: w.prefixIcon!),
              )
            else
              SizedBox(width: theme.gapMd),
            Expanded(child: innerField),
            if (suffix != null)
              IconTheme.merge(data: iconTheme, child: suffix)
            else
              SizedBox(width: theme.gapMd),
          ],
        );

        // Chrome: bordo NEUTRO sempre (shadcn: nessun bordo rosso in errore; il
        // focus è dato dal ring esterno). TextArea: altezza fissa (resize grip),
        // niente animazione sull'altezza (drag istantaneo).
        final Widget chrome = AnimatedContainer(
          duration: w.isTextArea ? Duration.zero : const Duration(milliseconds: 120),
          height: w.isTextArea ? taHeight : inputH,
          decoration: BoxDecoration(
            color: w.isEnabled
                ? (w.fillColor ?? (w.recessed ? theme.tertiaryBackground : theme.secondaryBackground))
                : (w.fillColor ?? (w.recessed ? theme.tertiaryBackground : theme.secondaryBackground))
                    .withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(radius),
            border: w.recessed
                ? null
                : Border.all(
                    color: w.isEnabled ? theme.cardBorder : theme.cardBorder.withValues(alpha: 0.5),
                    width: 1,
                  ),
          ),
          child: w.isTextArea
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    rowContent,
                    if (w.isEnabled)
                      Positioned(
                        right: 3,
                        bottom: 3,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeUpDown,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanUpdate: (d) =>
                                s.setTextAreaHeight(taHeight + d.delta.dy),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CustomPaint(
                                painter: _ResizeGripPainter(theme.borderColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : rowContent,
        );

        // Focus ring shadcn: anello esterno offset (theme.ring), fuori dal
        // layout → nessun salto. CustomPaint SEMPRE presente (painter null
        // off-focus): togglarne la presenza cambierebbe l'albero e rimonterebbe
        // l'EditableText → perdita del focus/gesto al primo click.
        // Ring esterno shadcn (halo offset). Sborda ~4px: se il campo è a filo
        // dentro un pannello che SCROLLA, il viewport lo ritaglia a sinistra.
        // Fix a monte: il contenitore scrollabile dà respiro ai campi mettendo
        // il proprio padding DENTRO lo scroll (vedi pagine playground).
        final Widget ringed = CustomPaint(
          foregroundPainter: s.isFocusedRef
              ? CLFocusRingPainter(color: theme.ring, radius: radius)
              : null,
          child: chrome,
        );

        // Material ancestor per gli internal di TextField (selezione, IME).
        final Widget themedChrome = Theme(
          data: Theme.of(context).copyWith(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Material(type: MaterialType.transparency, child: ringed),
        );

        Widget field = MouseRegion(
          cursor: !w.isEnabled
              ? SystemMouseCursors.forbidden
              : gestureTap != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.text,
          child: GestureDetector(
            onTap: gestureTap,
            child: AbsorbPointer(absorbing: absorb, child: themedChrome),
          ),
        );

        // A11y: nome del campo sempre (anche quando la label non è mostrata sopra,
        // es. recessed → labelText è il placeholder ma serve comunque a SR).
        if (w.labelText.isNotEmpty) {
          field = Semantics(label: labelStr, textField: true, child: field);
        }

        // Stack shadcn: label sopra · campo · error sotto (danger, no bordo rosso).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Text(
                labelStr,
                style: theme.smallText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: hasError ? theme.danger : theme.secondaryText,
                ),
              ),
              SizedBox(height: theme.gapSm),
            ],
            field,
            if (hasError && errorText != null && errorText.isNotEmpty) ...[
              SizedBox(height: theme.gapSm),
              Text(
                errorText,
                style: theme.smallLabel.copyWith(color: theme.danger, height: 1.3),
              ),
            ],
          ],
        );
      },
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
      // Swatch 20px in compact (gapXl): 24px lascerebbe solo 4px di aria nel box da 32.
      final double swatchSide = w.isCompact ? theme.gapXl : Sizes.iconSizeLarge;
      return Padding(
        padding: EdgeInsets.only(right: theme.gapMd),
        child: Container(
          width: swatchSide,
          height: swatchSide,
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
                icon: Icons.description,
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
      return Padding(padding: EdgeInsets.only(right: theme.gapMd), child: w.suffixIcon);
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
      padding: EdgeInsets.only(right: theme.gapMd),
      child: HugeIcon(
        icon: isTime ? HugeIcons.strokeRoundedClock01 : HugeIcons.strokeRoundedCalendar03,
        size: w.isCompact ? theme.iconSizeCompact : CLTextFieldState.kIconSize,
        color: s.isFocusedRef ? theme.primary : theme.secondaryText,
      ),
    );
  }

  Widget _clearButton(CLTheme theme, VoidCallback onPressed) => GestureDetector(
        onTap: onPressed,
        // Hit-test opaco + padding verticale gapSm: porta il tap target a
        // tutta l'altezza del campo (16 icona + 8+8 = 32 in compact).
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(right: theme.gapMd, top: theme.gapSm, bottom: theme.gapSm),
          child: Icon(Icons.close_rounded,
              size: w.isCompact ? theme.iconSizeCompact : 18, color: theme.danger.withValues(alpha: 0.8)),
        ),
      );

  Widget _calendarIcon(CLTheme theme) => Padding(
        padding: EdgeInsets.only(right: theme.gapMd),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedCalendar03,
          size: w.isCompact ? theme.iconSizeCompact : CLTextFieldState.kIconSize,
          color: s.isFocusedRef ? theme.primary : theme.secondaryText,
        ),
      );

  Widget _passwordToggle(CLTheme theme) => GestureDetector(
        onTap: s.togglePasswordVisibility,
        child: Padding(
          padding: EdgeInsets.only(right: theme.gapMd),
          child: Icon(
            s.isPasswordVisibleRef ? Icons.visibility : Icons.visibility_off,
            size: w.isCompact ? theme.iconSizeCompact : CLTextFieldState.kIconSize,
            color: s.isFocusedRef ? theme.primary : theme.secondaryText,
          ),
        ),
      );

  static FormFieldValidator<String>? _combineValidators(List<FormFieldValidator<String>>? vs) {
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

/// Grip di resize (angolo basso-destra) della textArea: due linee diagonali,
/// stile shadcn.
class _ResizeGripPainter extends CustomPainter {
  const _ResizeGripPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width, size.height * 0.35),
        Offset(size.width * 0.35, size.height), p);
    canvas.drawLine(Offset(size.width, size.height * 0.7),
        Offset(size.width * 0.7, size.height), p);
  }

  @override
  bool shouldRepaint(_ResizeGripPainter old) => old.color != color;
}
