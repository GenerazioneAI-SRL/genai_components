import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputField extends StatefulWidget {
  const TimeInputField({super.key});

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  final TextEditingController _txtTimeController = TextEditingController();

  @override
  void dispose() {
    _txtTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _txtTimeController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: 'hh:mm:ss'),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
        TimeTextInputFormatter(),
      ],
    );
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 4) digits = digits.substring(0, 4);

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) {
        formatted += ':';
      }
      formatted += digits[i];
    }

    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
