import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'buttons/cl_soft_button.widget.dart';
import 'formatters/date_mask_formatter.dart';
import 'textfield_validator.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CLTextField
// ═══════════════════════════════════════════════════════════════════════════

class CLTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final FocusNode? focusNode;
  final int? maxLines;
  final TextInputType inputType;
  final bool isObscured;
  final bool isEnabled;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final Widget? suffixIcon;
  final bool isTextArea;
  final bool isRequired;
  final bool isRounded;
  final bool isReadOnly;
  final Future Function(String value)? onChanged;
  final List<FormFieldValidator<String>>? validators;
  final GestureTapCallback? onTap;
  final Function(String)? onColorPicked;
  final Function(File?)? onFilePicked;
  final Function(DateTime?)? onDateTimeSelected;
  final Function(TimeOfDay?)? onTimeSelected;
  final bool withTime;
  final bool onlyTime;
  final bool withoutDay;
  final TimeOfDay? initialSelectedTime;
  final DateTime? initialSelectedDateTime;
  final String? initValue;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final CLDateFieldType? dateFieldType;
  final bool capitalize;

  const CLTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.focusNode,
    this.maxLines = 1,
    this.inputType = TextInputType.text,
    this.isObscured = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.suffixIcon,
    this.isTextArea = false,
    this.isRequired = false,
    this.isRounded = false,
    this.isReadOnly = false,
    this.onTap,
    this.onChanged,
    this.validators,
    this.onColorPicked,
    this.onFilePicked,
    this.onDateTimeSelected,
    this.onTimeSelected,
    this.initialSelectedTime,
    this.initialSelectedDateTime,
    this.withTime = false,
    this.withoutDay = false,
    this.initValue,
    this.inputFormatters,
    this.onlyTime = false,
    this.fillColor,
    this.dateFieldType,
    this.capitalize = false,
  });

  @override
  CLTextFieldState createState() => CLTextFieldState();

  // ─── Factory methods ────────────────────────────────────────────────

  factory CLTextField.disabled({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: false,
      validators: validators,
    );
  }

  factory CLTextField.password({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    dynamic prefix,
    dynamic suffix,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isObscured: true,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      prefixIcon: prefix,
      suffixIcon: suffix,
    );
  }

  factory CLTextField.time({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    TimeOfDay? initialSelectedTime,
    required Function(TimeOfDay?) onTimeSelected,
    Function(DateTime?)? onDateTimeSelected,
    Color? fillColor,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.number,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      initialSelectedTime: initialSelectedTime,
      onTimeSelected: onTimeSelected,
      onDateTimeSelected: onDateTimeSelected,
      fillColor: fillColor,
      validators: validators,
      dateFieldType: CLDateFieldType.time,
    );
  }

  factory CLTextField.date({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    bool withTime = false,
    DateTime? initialSelectedDateTime,
    required Function(DateTime?) onDateTimeSelected,
    Color? fillColor,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.number,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      withTime: withTime,
      initialSelectedDateTime: initialSelectedDateTime,
      onDateTimeSelected: onDateTimeSelected,
      fillColor: fillColor,
      validators: validators,
      dateFieldType: withTime ? CLDateFieldType.dateTime : CLDateFieldType.date,
    );
  }

  factory CLTextField.dateTime({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    DateTime? initialSelectedDateTime,
    required Function(DateTime?) onDateTimeSelected,
    Color? fillColor,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.number,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      initialSelectedDateTime: initialSelectedDateTime,
      onDateTimeSelected: onDateTimeSelected,
      fillColor: fillColor,
      validators: validators,
      dateFieldType: CLDateFieldType.dateTime,
    );
  }

  factory CLTextField.month({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    DateTime? initialSelectedDateTime,
    required Function(DateTime?) onDateTimeSelected,
    Color? fillColor,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.number,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      initialSelectedDateTime: initialSelectedDateTime,
      onDateTimeSelected: onDateTimeSelected,
      fillColor: fillColor,
      validators: validators,
      dateFieldType: CLDateFieldType.month,
    );
  }

  factory CLTextField.year({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    DateTime? initialSelectedDateTime,
    required Function(DateTime?) onDateTimeSelected,
    Color? fillColor,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.number,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      initialSelectedDateTime: initialSelectedDateTime,
      onDateTimeSelected: onDateTimeSelected,
      fillColor: fillColor,
      validators: validators,
      dateFieldType: CLDateFieldType.year,
    );
  }

  factory CLTextField.filePicker({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    required Function(File?) onFilePicked,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      onFilePicked: onFilePicked,
    );
  }

  factory CLTextField.colorPicker({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required Function(String) onColorPicked,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      onColorPicked: onColorPicked,
      onTap: onTap,
      isReadOnly: true,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
    );
  }

  factory CLTextField.textArea({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    Future Function(String value)? onChanged,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      maxLines: 5,
      isTextArea: true,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
      onChanged: onChanged,
    );
  }

  factory CLTextField.currency({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    bool isReadOnly = false,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isRequired: isRequired,
      prefixIcon: iconAlignment == IconAlignment.start ? const Icon(FontAwesomeIcons.moneyCheck, size: 14, color: Colors.grey) : null,
      inputType: const TextInputType.numberWithOptions(decimal: true),
      suffixIcon: iconAlignment == IconAlignment.end ? const Icon(FontAwesomeIcons.moneyCheck, size: 14, color: Colors.grey) : null,
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
    );
  }

  factory CLTextField.number({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    bool isReadOnly = false,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isRounded = false,
    bool isEnabled = true,
    List<FormFieldValidator<String>>? validators,
    String? initValue,
    bool withDecimal = false,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isRequired: isRequired,
      inputType: TextInputType.numberWithOptions(decimal: withDecimal),
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      initValue: initValue,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
    );
  }

  factory CLTextField.icon({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required dynamic icon,
    bool isReadOnly = false,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    List<FormFieldValidator<String>>? validators,
  }) {
    Widget? toIconWidget(dynamic ic) {
      if (ic == null) return null;
      if (ic is IconData) return Icon(ic, size: 16, color: Colors.grey);
      return ic as Widget;
    }

    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isRequired: isRequired,
      initValue: initValue,
      prefixIcon: iconAlignment == IconAlignment.start ? toIconWidget(icon) : null,
      suffixIcon: iconAlignment == IconAlignment.end ? toIconWidget(icon) : null,
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
    );
  }

  factory CLTextField.rightLeftIcon({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required dynamic leftIcon,
    required dynamic rightIcon,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    bool isReadOnly = false,
    List<FormFieldValidator<String>>? validators,
  }) {
    Widget? toIconWidget(dynamic ic) {
      if (ic is IconData) return Icon(ic, size: 16, color: Colors.grey);
      return ic as Widget;
    }

    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      prefixIcon: toIconWidget(leftIcon),
      suffixIcon: toIconWidget(rightIcon),
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
    );
  }

  factory CLTextField.rounded({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    bool isEnabled = true,
    bool isReadOnly = false,
    String? initValue,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      suffixIcon: null,
      onTap: onTap,
      onChanged: onChanged,
      focusNode: focusNode,
      isReadOnly: isReadOnly,
      isRounded: true,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// State
// ═══════════════════════════════════════════════════════════════════════════

class CLTextFieldState extends State<CLTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _isPasswordVisible = false;
  bool _isFocused = false;
  bool isFilePicked = false;
  bool isDatePicked = false;
  bool isPicking = false;

  // ─── Costanti di design ─────────────────────────────────────────────
  static const _kIconSize = 16.0;

  /// Mostra l'asterisco se [isRequired] è true oppure se [Validators.required]
  /// è presente nella lista dei validators.
  bool get _shouldShowRequired {
    if (widget.isRequired) return true;
    if (widget.validators != null) {
      for (final v in widget.validators!) {
        if (v == Validators.required) return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_onFocusChanged);

    if (widget.initValue != null) {
      _controller.text = widget.initValue!;
    }

    // ── Valore iniziale per campi data/ora inline ──
    if (widget.dateFieldType != null) {
      if (widget.initialSelectedDateTime != null) {
        _controller.text = widget.dateFieldType!.format(widget.initialSelectedDateTime!);
      } else if (widget.initialSelectedTime != null && widget.dateFieldType == CLDateFieldType.time) {
        _controller.text = widget.dateFieldType!.formatTimeOfDay(widget.initialSelectedTime!);
      }
    } else {
      // ── Valore iniziale per campi con picker (legacy) ──
      if (widget.initialSelectedDateTime != null) {
        isDatePicked = true;
        _controller.text = _formatDateTime(widget.initialSelectedDateTime!);
      }
      if (widget.initialSelectedTime != null) {
        isDatePicked = true;
        _controller.text = _formatTime(widget.initialSelectedTime!);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  // ─── Date/Time helpers ──────────────────────────────────────────────

  String _formatDateTime(DateTime dt) {
    if (widget.withTime) {
      return DateFormat(widget.withoutDay ? 'MM-yyyy HH:mm' : 'dd-MM-yyyy HH:mm').format(dt);
    }
    return DateFormat(widget.withoutDay ? 'MM-yyyy' : 'dd-MM-yyyy').format(dt);
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ─── Pickers ────────────────────────────────────────────────────────

  Future<void> _selectDate(BuildContext context) async {
    final theme = CLTheme.of(context);

    if (!widget.onlyTime) {
      final DateTime? pickedDate;

      if (widget.withoutDay) {
        pickedDate = await _showMonthPicker(context, theme);
      } else {
        pickedDate = await _showDatePicker(context, theme);
      }

      if (pickedDate != null) {
        DateTime finalDateTime = pickedDate;

        if (widget.withTime) {
          final TimeOfDay? pickedTime = await _showTimePicker(context, theme);
          if (pickedTime == null) {
            setState(() {
              isDatePicked = false;
              _controller.clear();
            });
            return;
          }
          finalDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        }

        setState(() {
          isDatePicked = true;
          widget.onDateTimeSelected!(finalDateTime);
          _controller.text = _formatDateTime(finalDateTime);
        });
      }
    } else {
      final TimeOfDay? pickedTime = await _showTimePicker(context, theme, inputOnly: true);
      if (pickedTime != null) {
        setState(() {
          widget.onTimeSelected!(pickedTime);
          isDatePicked = true;
          _controller.text = _formatTime(pickedTime);
        });
      }
    }
  }

  Future<DateTime?> _showMonthPicker(BuildContext context, CLTheme theme) {
    return showMonthPicker(
      context: context,
      initialDate: widget.initialSelectedDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 100),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: _pickerActionButton('Conferma', theme.primary, Colors.white),
          cancelWidget: _pickerActionButton('Annulla', theme.danger.withAlpha(26), theme.danger),
        ),
        headerSettings: PickerHeaderSettings(headerBackgroundColor: theme.primary, headerCurrentPageTextStyle: theme.heading6.override(color: Colors.white)),
        dateButtonsSettings: PickerDateButtonsSettings(
          buttonBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
          selectedMonthBackgroundColor: theme.primary,
          unselectedMonthsTextColor: theme.primaryText,
          currentMonthTextColor: theme.primary,
        ),
        dialogSettings: PickerDialogSettings(
          scrollAnimationMilliseconds: 0,
          dialogBackgroundColor: theme.secondaryBackground,
          locale: const Locale('it', 'IT'),
          dialogRoundedCornersRadius: Sizes.borderRadius,
        ),
      ),
    );
  }

  Future<DateTime?> _showDatePicker(BuildContext context, CLTheme theme) {
    return showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: widget.initialSelectedDateTime ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 100),
      builder: (ctx, child) => Theme(data: _datePickerTheme(ctx, theme), child: child!),
    );
  }

  Future<TimeOfDay?> _showTimePicker(BuildContext context, CLTheme theme, {bool inputOnly = false}) {
    return showTimePicker(
      context: context,
      initialEntryMode: inputOnly ? TimePickerEntryMode.inputOnly : TimePickerEntryMode.dial,
      initialTime:
          widget.initialSelectedTime ??
          (widget.initialSelectedDateTime != null
              ? TimeOfDay(hour: widget.initialSelectedDateTime!.hour, minute: widget.initialSelectedDateTime!.minute)
              : TimeOfDay.now()),
      builder: (ctx, child) => Theme(data: _timePickerTheme(ctx, theme), child: child!),
    );
  }

  // ─── Picker themes ─────────────────────────────────────────────────

  ThemeData _datePickerTheme(BuildContext ctx, CLTheme theme) {
    return Theme.of(ctx).copyWith(
      colorScheme: ColorScheme.light(primary: theme.primary, onPrimary: Colors.white, onSurface: theme.primaryText, surface: theme.secondaryBackground),
      dialogBackgroundColor: theme.secondaryBackground,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        headerBackgroundColor: theme.primary,
        headerForegroundColor: Colors.white,
        dayStyle: theme.bodyText,
        yearStyle: theme.bodyText,
        dayForegroundColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : theme.primaryText),
        dayBackgroundColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? theme.primary : Colors.transparent),
        todayBackgroundColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? theme.primary : theme.primary.withAlpha(26)),
        todayForegroundColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : theme.primary),
        cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.danger)),
        confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.primary)),
      ),
    );
  }

  ThemeData _timePickerTheme(BuildContext ctx, CLTheme theme) {
    return Theme.of(ctx).copyWith(
      colorScheme: ColorScheme.light(primary: theme.primary, onPrimary: Colors.white, onSurface: theme.primaryText, surface: theme.secondaryBackground),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
        dialBackgroundColor: theme.primary.withAlpha(26),
        dialHandColor: theme.primary,
        dialTextColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : theme.primaryText),
        hourMinuteTextColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : theme.primaryText),
        dayPeriodTextColor: theme.primaryText,
        dayPeriodColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? theme.primary.withAlpha(50) : Colors.transparent),
        cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.danger)),
        confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.primary)),
      ),
    );
  }

  Widget _pickerActionButton(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.small),
      margin: const EdgeInsets.symmetric(vertical: Sizes.small / 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
      child: Text(label, style: CLTheme.of(context).bodyText.copyWith(color: fg, fontWeight: FontWeight.w500)),
    );
  }

  // ─── Color picker ──────────────────────────────────────────────────

  Future<void> _selectColor(BuildContext context) async {
    final result = await showColorPickerDialog(context, CLTheme.of(context).primary);
    setState(() {
      widget.onColorPicked!(result.hex);
      _controller.text = result.hex;
    });
  }

  // ─── File picker ───────────────────────────────────────────────────

  Future<void> _pickFile(BuildContext context) async {
    if (isPicking) return;
    setState(() => isPicking = true);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    setState(() => isPicking = false);

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      File file = File(platformFile.path!);
      widget.onFilePicked!(file);
      setState(() => isFilePicked = true);
      _controller.text = platformFile.name;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    // Callback per GestureDetector (date/color/file picker) — solo picker legacy
    final bool isInlineDateField = widget.dateFieldType != null;
    final VoidCallback? gestureTapCallback =
        widget.onColorPicked != null
            ? () => _selectColor(context)
            : (!isInlineDateField && (widget.onDateTimeSelected != null || widget.onTimeSelected != null))
            ? () => _selectDate(context)
            : widget.onFilePicked != null
            ? () => _pickFile(context)
            : null;

    // Assorbire i pointer quando servono i picker (non per inline)
    final bool shouldAbsorbPointer =
        (!isInlineDateField && (widget.onDateTimeSelected != null || widget.onTimeSelected != null) && !isDatePicked) ||
        widget.onColorPicked != null ||
        (widget.onFilePicked != null && !isFilePicked);

    // ReadOnly state (inline date fields sono sempre editabili)
    final bool isReadOnly =
        isInlineDateField
            ? widget.isReadOnly
            : widget.onFilePicked != null
            ? isFilePicked
            : widget.onDateTimeSelected != null
            ? isDatePicked
            : widget.isReadOnly;

    return MouseRegion(
      cursor:
          !widget.isEnabled
              ? SystemMouseCursors.forbidden
              : gestureTapCallback != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.text,
      child: GestureDetector(
        onTap: gestureTapCallback,
        child: AbsorbPointer(
          absorbing: shouldAbsorbPointer,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            textCapitalization: widget.capitalize ? TextCapitalization.sentences : TextCapitalization.none,
            cursorColor: theme.primary,
            cursorWidth: 1.5,
            cursorRadius: const Radius.circular(1),
            readOnly: isReadOnly,
            onTap: widget.onTap,
            controller: _controller,
            focusNode: _focusNode,
            maxLines: widget.isTextArea ? widget.maxLines : 1,
            keyboardType: isInlineDateField ? TextInputType.number : widget.inputType,
            obscureText: widget.isObscured && !_isPasswordVisible,
            enabled: widget.isEnabled,
            onChanged:
                isInlineDateField
                    ? (value) {
                      setState(() {}); // Rebuild per aggiornare suffix icon
                      _handleDateFieldParsing(value);
                      widget.onChanged?.call(value);
                    }
                    : widget.onChanged,
            inputFormatters: isInlineDateField ? [DateMaskFormatter(widget.dateFieldType!)] : (widget.inputFormatters ?? _getDefaultInputFormatters()),
            style: theme.bodyText.copyWith(fontWeight: FontWeight.w400, height: 1.4),
            decoration: InputDecoration(
              isDense: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              floatingLabelStyle: theme.smallText.copyWith(
                color: _isFocused ? theme.primary : theme.secondaryText,
                fontWeight: _isFocused ? FontWeight.w500 : FontWeight.w400,
                height: 1,
              ),
              labelStyle: CLTheme.of(context).bodyLabel,
              alignLabelWithHint: widget.isTextArea,
              errorMaxLines: 200,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              labelText: _shouldShowRequired ? '${widget.labelText}*' : widget.labelText,
              hintText: widget.dateFieldType?.hint,
              hintStyle: CLTheme.of(context).bodyText.copyWith(color: CLTheme.of(context).mutedForeground),

              // ── Prefix ──
              prefixIcon: widget.prefixIcon != null ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: widget.prefixIcon) : null,
              prefixIconConstraints: widget.prefixIconConstraints ?? (widget.prefixIcon != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null),

              // ── Suffix ──
              suffixIcon: _buildSuffixIconWidget(theme),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

              // ── Colori ──
              hoverColor: Colors.transparent,
              filled: true,
              fillColor: widget.fillColor ?? CLTheme.of(context).secondaryBackground,

              // ── Bordi ──
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusSm),
                borderSide: BorderSide(color: CLTheme.of(context).cardBorder, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusSm),
                borderSide: BorderSide(color: CLTheme.of(context).ring, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusSm),
                borderSide: BorderSide(color: CLTheme.of(context).danger, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusSm),
                borderSide: BorderSide(color: CLTheme.of(context).danger, width: 2.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusSm),
                borderSide: BorderSide(color: CLTheme.of(context).cardBorder.withValues(alpha: 0.5), width: 1.0),
              ),
              errorStyle: theme.smallLabel.copyWith(color: theme.danger, fontSize: 11, height: 1.3),
            ),
            validator: _combineValidators(_effectiveValidators),
          ),
        ),
      ),
    );
  }

  // ─── Input formatters ──────────────────────────────────────────────

  /// Unisce i validatori custom con il validatore automatico per [dateFieldType].
  List<FormFieldValidator<String>>? get _effectiveValidators {
    if (widget.dateFieldType == null) return widget.validators;
    return [CLDateFieldValidators.forType(widget.dateFieldType!), if (widget.validators != null) ...widget.validators!];
  }

  List<TextInputFormatter> _getDefaultInputFormatters() {
    if (widget.inputType.decimal != null) {
      return widget.inputType.decimal == true ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$'))] : [FilteringTextInputFormatter.digitsOnly];
    }
    return [];
  }

  // ─── Suffix icon builder ───────────────────────────────────────────

  Widget? _buildSuffixIconWidget(CLTheme theme) {
    // Inline date/time field → clear button o icona tipo
    if (widget.dateFieldType != null) {
      return _controller.text.isNotEmpty
          ? _clearButton(
            theme: theme,
            onPressed: () {
              setState(() {
                _controller.clear();
                widget.onDateTimeSelected?.call(null);
                widget.onTimeSelected?.call(null);
              });
            },
          )
          : _dateFieldTypeIcon(theme);
    }

    // Color picker → preview swatch
    if (widget.onColorPicked != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: _hexToColor(widget.controller.text),
            border: Border.all(color: theme.borderColor, width: 0.5),
          ),
        ),
      );
    }

    // File picker
    if (widget.onFilePicked != null) {
      return isFilePicked
          ? _clearButton(
            theme: theme,
            onPressed: () {
              setState(() => isFilePicked = false);
              widget.onFilePicked!(null);
              _controller.text = '';
            },
          )
          : Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CLSoftButton.primary(icon: FontAwesomeIcons.file, text: 'Seleziona file', onTap: () {}, context: context, isCompact: true),
          );
    }

    // Date/time picker
    if (widget.onDateTimeSelected != null || widget.onTimeSelected != null) {
      return isDatePicked
          ? _clearButton(
            theme: theme,
            onPressed: () {
              setState(() => isDatePicked = false);
              widget.onDateTimeSelected?.call(null);
              widget.onTimeSelected?.call(null);
              _controller.text = '';
            },
          )
          : _calendarIcon(theme);
    }

    // Password toggle
    if (widget.isObscured) {
      return _passwordToggle(theme);
    }

    // DateTime type → calendar icon
    if (widget.inputType == TextInputType.datetime) {
      return _calendarIcon(theme);
    }

    // Custom suffix
    if (widget.suffixIcon != null) {
      return Padding(padding: const EdgeInsets.only(right: 10), child: widget.suffixIcon);
    }

    return null;
  }

  // ─── Inline date field parsing ───────────────────────────────────────

  void _handleDateFieldParsing(String value) {
    final type = widget.dateFieldType;
    if (type == null) return;

    if (value.isEmpty) {
      widget.onDateTimeSelected?.call(null);
      widget.onTimeSelected?.call(null);
      return;
    }

    // Parse solo quando l'input è completo (tutte le cifre inserite)
    if (value.length == type.expectedLength) {
      if (type == CLDateFieldType.time && widget.onTimeSelected != null) {
        widget.onTimeSelected?.call(type.parseTime(value));
      }
      widget.onDateTimeSelected?.call(type.parse(value));
    }
  }

  Widget _dateFieldTypeIcon(CLTheme theme) {
    final isTimeType = widget.dateFieldType == CLDateFieldType.time;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: HugeIcon(
        icon: isTimeType ? HugeIcons.strokeRoundedClock01 : HugeIcons.strokeRoundedCalendar03,
        size: _kIconSize,
        color: _isFocused ? theme.primary : theme.secondaryText,
      ),
    );
  }

  // ─── Piccoli widget helper ─────────────────────────────────────────

  Widget _clearButton({required CLTheme theme, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(padding: const EdgeInsets.only(right: 10), child: Icon(Icons.close_rounded, size: 18, color: theme.danger.withValues(alpha: 0.8))),
    );
  }

  Widget _calendarIcon(CLTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: _kIconSize, color: _isFocused ? theme.primary : theme.secondaryText),
    );
  }

  Widget _passwordToggle(CLTheme theme) {
    return GestureDetector(
      onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Icon(
          _isPasswordVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
          size: _kIconSize,
          color: _isFocused ? theme.primary : theme.secondaryText,
        ),
      ),
    );
  }

  // ─── Utils ─────────────────────────────────────────────────────────

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return CLTheme.of(context).primary;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static FormFieldValidator<String>? _combineValidators(List<FormFieldValidator<String>>? validators) {
    if (validators == null || validators.isEmpty) return null;
    return (String? value) {
      final errors = <String>[];
      for (final v in validators) {
        final result = v(value);
        if (result != null) errors.add(result);
      }
      return errors.isEmpty ? null : errors.join('\n');
    };
  }
}
