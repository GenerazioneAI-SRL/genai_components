part of '../cl_text_field.widget.dart';

/// Color picker dispatch + hex parsing.
class _TextFieldColorHelper extends _Helper {
  _TextFieldColorHelper(super.s);

  Future<void> pick(BuildContext context) async {
    final result = await showColorPickerDialog(context, CLTheme.of(context).primary);
    if (!s.mounted) return;
    // ignore: invalid_use_of_protected_member
    s.setState(() {
      w.onColorPicked!(result.hex);
      s.controllerRef.text = result.hex;
    });
  }

  Color hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return CLTheme.of(s.context).primary;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
