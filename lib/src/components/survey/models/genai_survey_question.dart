import 'genai_survey_option.dart';

class GenaiSurveyQuestion {
  final String question;
  final bool singleChoice;
  final bool isMandatory;
  final String? errorText;
  final Map<String, dynamic>? properties;
  late final List<Map<String, String>> answers;
  final List<GenaiSurveyOption> options;
  final bool isNumeric;
  final bool isRating;
  final bool isStarRating;

  GenaiSurveyQuestion({
    required this.question,
    this.singleChoice = true,
    this.isMandatory = false,
    this.errorText,
    this.properties,
    this.isNumeric = false,
    this.isRating = false,
    this.isStarRating = false,
    this.options = const [],
    List<Map<String, String>>? answers,
  }) : answers = answers ?? [];

  factory GenaiSurveyQuestion.fromJson(Map<String, dynamic> json) => GenaiSurveyQuestion(
        question: json['question'] as String,
        singleChoice: json['single_choice'] as bool? ?? true,
        isMandatory: json['is_mandatory'] as bool? ?? false,
        isNumeric: json['isNumeric'] as bool? ?? false,
        isRating: json['isRating'] as bool? ?? false,
        isStarRating: json['isStarRating'] as bool? ?? false,
        errorText: json['error_text'] as String?,
        properties: json['properties'] as Map<String, dynamic>?,
        answers: (json['answers'] as List<dynamic>?)?.map((e) => Map<String, String>.from(e as Map)).toList(),
        options: (json['options'] as List<dynamic>? ?? const []).map((e) => GenaiSurveyOption.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'single_choice': singleChoice,
        'is_mandatory': isMandatory,
        'isNumeric': isNumeric,
        'isRating': isRating,
        'error_text': errorText,
        'isStarRating': isStarRating,
        'properties': properties,
        'answers': answers,
        'options': options.map((o) => o.toJson()).toList(),
      };

  GenaiSurveyQuestion clone() => GenaiSurveyQuestion.fromJson(toJson());
}
