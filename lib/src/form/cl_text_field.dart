import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// A focused text input widget.
///
/// Supports single-line and multi-line (textarea) modes, optional prefix/suffix
/// icons, helper text, validation, and read-only/disabled states.
///
/// ```dart
/// CLTextField(
///   controller: _controller,
///   label: 'Email',
///   isRequired: true,
///   prefixIcon: FontAwesomeIcons.envelope,
///   validators: [(v) => v!.isEmpty ? 'Required' : null],
/// )
/// ```
class CLTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;

  /// Lines > 1 renders a textarea.
  final int maxLines;
  final TextInputType inputType;
  final bool isEnabled;
  final bool isRequired;
  final bool isReadOnly;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? helperText;
  final List<FormFieldValidator<String>>? validators;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CLTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.maxLines = 1,
    this.inputType = TextInputType.text,
    this.isEnabled = true,
    this.isRequired = false,
    this.isReadOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.validators,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label + (isRequired ? ' *' : ''),
          style: theme.smallLabel,
        ),
        SizedBox(height: theme.xs),
        // Field
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          keyboardType: inputType,
          enabled: isEnabled,
          readOnly: isReadOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          validator: validators != null
              ? (value) {
                  for (final v in validators!) {
                    final result = v(value);
                    if (result != null) return result;
                  }
                  return null;
                }
              : null,
          style: theme.bodyText,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: FaIcon(
                      prefixIcon!,
                      size: 14,
                      color: theme.textSecondary,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FaIcon(
                      suffixIcon!,
                      size: 14,
                      color: theme.textSecondary,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            helperText: helperText,
            helperStyle:
                theme.smallText.copyWith(color: theme.textSecondary),
            errorStyle: theme.smallText.copyWith(color: theme.danger),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              borderSide: BorderSide(color: theme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              borderSide: BorderSide(color: theme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              borderSide: BorderSide(color: theme.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              borderSide: BorderSide(color: theme.danger, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              borderSide: BorderSide(
                color: theme.border.withValues(alpha: 0.5),
              ),
            ),
            filled: true,
            fillColor: isEnabled
                ? theme.surface
                : theme.surface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
