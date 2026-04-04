import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// A time picker field.
///
/// Tapping the field opens the system time picker.
///
/// ```dart
/// CLTimeField(
///   label: 'Start Time',
///   value: _time,
///   onChanged: (t) => setState(() => _time = t),
/// )
/// ```
class CLTimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?>? onChanged;
  final bool isRequired;
  final bool isEnabled;

  const CLTimeField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final displayText = value != null
        ? '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label${isRequired ? ' *' : ''}', style: theme.smallLabel),
        SizedBox(height: theme.xs),
        GestureDetector(
          onTap: isEnabled ? () => _pickTime(context) : null,
          child: MouseRegion(
            cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(color: theme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText.isEmpty ? 'Seleziona ora' : displayText,
                      style: displayText.isEmpty
                          ? theme.bodyText.copyWith(color: theme.textSecondary)
                          : theme.bodyText,
                    ),
                  ),
                  FaIcon(FontAwesomeIcons.clock, size: 14, color: theme.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final theme = CLThemeProvider.of(context);
    final time = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: theme.primary),
        ),
        child: child!,
      ),
    );
    if (time != null) onChanged?.call(time);
  }
}
