import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:genai_components/cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'answer_choice_widget.dart';
import 'models/question.dart';
import 'survey_form_field.dart';

class QuestionCard extends StatelessWidget {
  ///The parameter that contains the data pertaining to a question.
  final Question question;

  ///A callback function that must be called with answers to rebuild the survey elements.
  final void Function(List<Map<String,String>>) update;

  ///An optional method to call with the final value when the form is saved via FormState.save.
  final FormFieldSetter<List<Map<String,String>>>? onSaved;

  ///An optional method that validates an input. Returns an error string to display if the input is invalid, or null otherwise.
  final FormFieldValidator<List<Map<String,String>>>? validator;

  ///Used to configure the auto validation of FormField and Form widgets.
  final AutovalidateMode? autovalidateMode;

  ///Used to configure the default errorText for the validator.
  final String defaultErrorText;
  final bool isNumeric;

  const QuestionCard({
    super.key,
    required this.question,
    required this.update,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    required this.defaultErrorText,
    required this.isNumeric,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyFormField(
      defaultErrorText: defaultErrorText,
      question: question,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      builder: (FormFieldState<List<Map<String,String>>> state) {
        final bool hasAnswer = question.answers.isNotEmpty;
        final bool hasError = state.hasError;

        return Container(
          margin: const EdgeInsets.only(bottom: Sizes.padding),
          decoration: BoxDecoration(
            color: CLTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            border: Border.all(
              color: hasError
                  ? CLTheme.of(context).danger
                  : hasAnswer
                      ? CLTheme.of(context).primary.withOpacity(0.4)
                      : CLTheme.of(context).borderColor,
              width: hasAnswer || hasError ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CLTheme.of(context).borderColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header della domanda
              _buildQuestionHeader(context, hasAnswer),

              // Contenuto risposte
              Padding(
                padding: const EdgeInsets.all(Sizes.padding),
                child: AnswerChoiceWidget(
                  question: question,
                  isNumeric: isNumeric,
                  onChange: (value) {
                    state.didChange(value);
                    update(value);
                  },
                ),
              ),

              // Errore
              if (hasError) _buildErrorMessage(context, state.errorText!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader(BuildContext context, bool hasAnswer) {
    return Container(
      padding: const EdgeInsets.all(Sizes.padding),
      decoration: BoxDecoration(
        color: hasAnswer
            ? CLTheme.of(context).primary.withOpacity(0.05)
            : CLTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Sizes.borderRadius),
          topRight: Radius.circular(Sizes.borderRadius),
        ),
        border: Border(
          bottom: BorderSide(
            color: CLTheme.of(context).borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icona stato
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasAnswer
                  ? CLTheme.of(context).primary.withOpacity(0.1)
                  : CLTheme.of(context).borderColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(
              icon: hasAnswer
                  ? HugeIcons.strokeRoundedCheckmarkCircle02
                  : HugeIcons.strokeRoundedHelpCircle,
              size: 20,
              color: hasAnswer
                  ? CLTheme.of(context).primary
                  : CLTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(width: Sizes.padding),
          // Testo domanda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: question.question,
                    style: CLTheme.of(context).bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    children: question.isMandatory
                        ? [
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                color: CLTheme.of(context).danger,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                // Sottotitolo o spazio equivalente per mantenere allineamento
                question.options.isNotEmpty
                    ? Text(
                        question.singleChoice
                            ? "Seleziona un'opzione"
                            : "Seleziona una o più opzioni",
                        style: CLTheme.of(context).bodyLabel.copyWith(
                          fontSize: 12,
                          color: CLTheme.of(context).secondaryText,
                        ),
                      )
                    : Text(
                        question.isStarRating
                            ? "Valuta da 1 a 5 stelle"
                            : "Inserisci la tua risposta",
                        style: CLTheme.of(context).bodyLabel.copyWith(
                          fontSize: 12,
                          color: CLTheme.of(context).secondaryText,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String errorText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.padding,
        vertical: Sizes.padding * 0.75,
      ),
      decoration: BoxDecoration(
        color: CLTheme.of(context).danger.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Sizes.borderRadius),
          bottomRight: Radius.circular(Sizes.borderRadius),
        ),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlert02,
            size: 16,
            color: CLTheme.of(context).danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorText,
              style: CLTheme.of(context).bodyText.copyWith(
                color: CLTheme.of(context).danger,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
