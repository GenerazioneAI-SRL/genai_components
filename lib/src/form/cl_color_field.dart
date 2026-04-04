import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A color picker field that displays a colored circle and hex value.
///
/// Tapping opens a dialog with a preset color grid.
///
/// ```dart
/// CLColorField(
///   label: 'Brand Color',
///   value: _color,
///   onChanged: (c) => setState(() => _color = c),
/// )
/// ```
class CLColorField extends StatelessWidget {
  final String label;
  final Color? value;
  final ValueChanged<Color?>? onChanged;

  const CLColorField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
  });

  static const _presetColors = [
    Color(0xFF0C8EC7),
    Color(0xFFE8734A),
    Color(0xFF16A34A),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0A7AAD),
    Color(0xFF6527CC),
    Color(0xFF2E2E38),
    Color(0xFF6B7080),
    Color(0xFFE8EBF0),
    Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.smallLabel),
        SizedBox(height: theme.xs),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(color: theme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: value ?? theme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.border),
                    ),
                  ),
                  SizedBox(width: theme.sm),
                  Text(
                    value != null
                        ? '#${value!.toARGB32().toRadixString(16).substring(2).toUpperCase()}'
                        : 'Select color',
                    style: theme.bodyText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radiusXl),
        ),
        title: Text(label, style: theme.heading4),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetColors.map((color) {
            final isSelected = value == color;
            return GestureDetector(
              onTap: () {
                onChanged?.call(color);
                Navigator.of(ctx).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.primary : theme.border,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
