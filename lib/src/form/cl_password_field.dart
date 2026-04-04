import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// A password input field with an eye-icon toggle to show/hide the text.
///
/// ```dart
/// CLPasswordField(
///   controller: _passwordController,
///   label: 'Password',
///   isRequired: true,
///   validators: [(v) => v!.length < 8 ? 'Min 8 characters' : null],
/// )
/// ```
class CLPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final List<FormFieldValidator<String>>? validators;

  const CLPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.validators,
  });

  @override
  State<CLPasswordField> createState() => _CLPasswordFieldState();
}

class _CLPasswordFieldState extends State<CLPasswordField> {
  bool _obscure = true;

  void _toggleVisibility() => setState(() => _obscure = !_obscure);

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label + (widget.isRequired ? ' *' : ''),
          style: theme.smallLabel,
        ),
        SizedBox(height: theme.xs),
        // Field
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          validator: widget.validators != null
              ? (value) {
                  for (final v in widget.validators!) {
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
            suffixIcon: GestureDetector(
              onTap: _toggleVisibility,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FaIcon(
                  _obscure ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                  size: 14,
                  color: theme.textSecondary,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
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
            filled: true,
            fillColor: theme.surface,
          ),
        ),
      ],
    );
  }
}
