import 'package:flutter/material.dart';

import 'models/genai_survey_question.dart';

/// FormField wrapper used by GenaiSurvey to integrate validation.
class GenaiSurveyFormField extends StatelessWidget {
  final GenaiSurveyQuestion question;
  final FormFieldSetter<List<Map<String, String>>>? onSaved;
  final FormFieldValidator<List<Map<String, String>>>? validator;
  final AutovalidateMode? autovalidateMode;
  final String defaultErrorText;
  final Widget Function(FormFieldState<List<Map<String, String>>> state) builder;

  const GenaiSurveyFormField({
    super.key,
    required this.question,
    required this.builder,
    required this.defaultErrorText,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<Map<String, String>>>(
      onSaved: onSaved,
      validator: (validator == null && question.isMandatory)
          ? (answer) {
              if (answer == null || answer.isEmpty) return defaultErrorText;
              return null;
            }
          : validator,
      initialValue: question.answers,
      autovalidateMode: autovalidateMode,
      builder: builder,
    );
  }
}
