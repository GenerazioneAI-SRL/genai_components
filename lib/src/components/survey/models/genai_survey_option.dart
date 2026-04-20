import 'genai_survey_question.dart';

class GenaiSurveyOption {
  final String id;
  String text;
  List<GenaiSurveyQuestion>? nested;

  GenaiSurveyOption({
    required this.id,
    required this.text,
    this.nested,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'nested': nested?.map((q) => q.toJson()).toList(),
      };

  factory GenaiSurveyOption.fromJson(Map<String, dynamic> json) => GenaiSurveyOption(
        id: json['id'] as String,
        text: json['text'] as String,
        nested: json['nested'] != null ? (json['nested'] as List).map((q) => GenaiSurveyQuestion.fromJson(q as Map<String, dynamic>)).toList() : null,
      );
}
