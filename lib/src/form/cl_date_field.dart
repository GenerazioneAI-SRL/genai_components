import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/cl_theme_provider.dart';

/// A date (and optional time) picker field.
///
/// Tapping the field opens the system date picker; if [includeTime] is true,
/// a time picker follows.
///
/// ```dart
/// CLDateField(
///   label: 'Start Date',
///   value: _date,
///   isRequired: true,
///   onChanged: (d) => setState(() => _date = d),
/// )
/// ```
class CLDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final bool isRequired;
  final bool isEnabled;
  final bool includeTime;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CLDateField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.isEnabled = true,
    this.includeTime = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final displayText = value != null
        ? (includeTime
            ? DateFormat('dd/MM/yyyy HH:mm').format(value!)
            : DateFormat('dd/MM/yyyy').format(value!))
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label${isRequired ? ' *' : ''}', style: theme.smallLabel),
        SizedBox(height: theme.xs),
        GestureDetector(
          onTap: isEnabled ? () => _pickDate(context) : null,
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
                      displayText.isEmpty ? 'Seleziona data' : displayText,
                      style: displayText.isEmpty
                          ? theme.bodyText.copyWith(color: theme.textSecondary)
                          : theme.bodyText,
                    ),
                  ),
                  FaIcon(FontAwesomeIcons.calendar, size: 14, color: theme.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final theme = CLThemeProvider.of(context);
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: theme.primary),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    if (includeTime) {
      if (!context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(value ?? now),
      );
      if (time != null) {
        onChanged?.call(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    } else {
      onChanged?.call(date);
    }
  }
}
