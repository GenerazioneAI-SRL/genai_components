import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

part 'cl_text_field/_helper_base.part.dart';
part 'cl_text_field/_ui_helper.part.dart';
part 'cl_text_field/_date_helper.part.dart';
part 'cl_text_field/_time_helper.part.dart';
part 'cl_text_field/_color_helper.part.dart';
part 'cl_text_field/_file_helper.part.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CLTextField — public API (unchanged)
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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        onTap: onTap, isReadOnly: isReadOnly, isRequired: isRequired,
        isRounded: isRounded, isEnabled: false, validators: validators,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        isObscured: true, isReadOnly: isReadOnly, isRequired: isRequired,
        isRounded: isRounded, isEnabled: isEnabled, validators: validators,
        prefixIcon: prefix, suffixIcon: suffix,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        inputType: TextInputType.number, onTap: onTap, isReadOnly: isReadOnly,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        initialSelectedTime: initialSelectedTime, onTimeSelected: onTimeSelected,
        onDateTimeSelected: onDateTimeSelected, fillColor: fillColor,
        validators: validators, dateFieldType: CLDateFieldType.time,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        inputType: TextInputType.number, onTap: onTap, isReadOnly: isReadOnly,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        withTime: withTime, initialSelectedDateTime: initialSelectedDateTime,
        onDateTimeSelected: onDateTimeSelected, fillColor: fillColor,
        validators: validators,
        dateFieldType: withTime ? CLDateFieldType.dateTime : CLDateFieldType.date,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        inputType: TextInputType.number, onTap: onTap, isReadOnly: isReadOnly,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        initialSelectedDateTime: initialSelectedDateTime,
        onDateTimeSelected: onDateTimeSelected, fillColor: fillColor,
        validators: validators, dateFieldType: CLDateFieldType.dateTime,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        inputType: TextInputType.number, onTap: onTap, isReadOnly: isReadOnly,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        initialSelectedDateTime: initialSelectedDateTime,
        onDateTimeSelected: onDateTimeSelected, fillColor: fillColor,
        validators: validators, dateFieldType: CLDateFieldType.month,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        inputType: TextInputType.number, onTap: onTap, isReadOnly: isReadOnly,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        initialSelectedDateTime: initialSelectedDateTime,
        onDateTimeSelected: onDateTimeSelected, fillColor: fillColor,
        validators: validators, dateFieldType: CLDateFieldType.year,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        onTap: onTap, isReadOnly: isReadOnly, isRequired: isRequired,
        isRounded: isRounded, isEnabled: isEnabled, validators: validators,
        onFilePicked: onFilePicked,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        onColorPicked: onColorPicked, onTap: onTap, isReadOnly: true,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        validators: validators,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        maxLines: 5, isTextArea: true, onTap: onTap, isReadOnly: isReadOnly,
        isRequired: isRequired, isRounded: isRounded, isEnabled: isEnabled,
        validators: validators, initValue: initValue, onChanged: onChanged,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        isRequired: isRequired,
        prefixIcon: iconAlignment == IconAlignment.start
            ? const Icon(FontAwesomeIcons.moneyCheck, size: 14, color: Colors.grey)
            : null,
        inputType: const TextInputType.numberWithOptions(decimal: true),
        suffixIcon: iconAlignment == IconAlignment.end
            ? const Icon(FontAwesomeIcons.moneyCheck, size: 14, color: Colors.grey)
            : null,
        onChanged: onChanged, focusNode: focusNode, onTap: onTap,
        isReadOnly: isReadOnly, isRounded: isRounded, isEnabled: isEnabled,
        validators: validators, initValue: initValue,
      );

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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        isRequired: isRequired,
        inputType: TextInputType.numberWithOptions(decimal: withDecimal),
        onChanged: onChanged, focusNode: focusNode, onTap: onTap,
        initValue: initValue, isReadOnly: isReadOnly, isRounded: isRounded,
        isEnabled: isEnabled, validators: validators,
      );

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
      key: key, controller: controller, labelText: labelText,
      isRequired: isRequired, initValue: initValue,
      prefixIcon: iconAlignment == IconAlignment.start ? toIconWidget(icon) : null,
      suffixIcon: iconAlignment == IconAlignment.end ? toIconWidget(icon) : null,
      onChanged: onChanged, focusNode: focusNode, onTap: onTap,
      isReadOnly: isReadOnly, isRounded: isRounded, isEnabled: isEnabled,
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
      key: key, controller: controller, labelText: labelText,
      prefixIcon: toIconWidget(leftIcon), suffixIcon: toIconWidget(rightIcon),
      onChanged: onChanged, focusNode: focusNode, onTap: onTap,
      isReadOnly: isReadOnly, isRounded: isRounded, isEnabled: isEnabled,
      validators: validators, initValue: initValue,
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
  }) => CLTextField(
        key: key, controller: controller, labelText: labelText,
        suffixIcon: null, onTap: onTap, onChanged: onChanged,
        focusNode: focusNode, isReadOnly: isReadOnly, isRounded: true,
        isEnabled: isEnabled, validators: validators, initValue: initValue,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// State (slim — delegates to private helpers in part files)
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

  late final _TextFieldDateHelper _dateHelper;
  late final _TextFieldTimeHelper _timeHelper;
  late final _TextFieldColorHelper _colorHelper;
  late final _TextFieldFileHelper _fileHelper;
  late final _TextFieldUiHelper _uiHelper;

  static const double kIconSize = 16.0;

  bool get shouldShowRequired {
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

    _dateHelper = _TextFieldDateHelper(this);
    _timeHelper = _TextFieldTimeHelper(this);
    _colorHelper = _TextFieldColorHelper(this);
    _fileHelper = _TextFieldFileHelper(this);
    _uiHelper = _TextFieldUiHelper(this);

    if (widget.initValue != null) _controller.text = widget.initValue!;

    if (widget.dateFieldType != null) {
      if (widget.initialSelectedDateTime != null) {
        _controller.text = widget.dateFieldType!.format(widget.initialSelectedDateTime!);
      } else if (widget.initialSelectedTime != null && widget.dateFieldType == CLDateFieldType.time) {
        _controller.text = widget.dateFieldType!.formatTimeOfDay(widget.initialSelectedTime!);
      }
    } else {
      if (widget.initialSelectedDateTime != null) {
        isDatePicked = true;
        _controller.text = _dateHelper.formatDateTime(widget.initialSelectedDateTime!);
      }
      if (widget.initialSelectedTime != null) {
        isDatePicked = true;
        _controller.text = _dateHelper.formatTime(widget.initialSelectedTime!);
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

  // Bridges to helpers (same library scope).
  TextEditingController get controllerRef => _controller;
  FocusNode get focusNodeRef => _focusNode;
  bool get isFocusedRef => _isFocused;
  bool get isPasswordVisibleRef => _isPasswordVisible;
  void togglePasswordVisibility() => setState(() => _isPasswordVisible = !_isPasswordVisible);

  @override
  Widget build(BuildContext context) => _uiHelper.build(context);
}
