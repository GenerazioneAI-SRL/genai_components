import 'package:flutter/material.dart';

/// Mixin that wires a shared [GlobalKey<FormState>] with helper methods.
///
/// Usage:
/// ```dart
/// class _MyState extends State<MyWidget> with FormValidationMixin {
///   @override
///   Widget build(BuildContext context) => Form(
///     key: formKey,
///     child: ...,
///   );
///
///   void _submit() {
///     if (!validateForm()) return;
///     saveForm();
///     // ...
///   }
/// }
/// ```
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  /// Form key shared with the [Form] widget in `build`.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Runs all field validators. Returns `true` when the form is valid.
  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Resets all fields to their initial state.
  void resetForm() => formKey.currentState?.reset();

  /// Calls `onSaved` on every form field.
  void saveForm() => formKey.currentState?.save();
}
