class GenaiSurveyResult {
  final String question;
  late final List<GenaiSurveyResult> children;
  late final List<Map<String, dynamic>> answers;

  GenaiSurveyResult({
    required this.question,
    List<Map<String, dynamic>>? answers,
    List<GenaiSurveyResult>? children,
  })  : answers = answers ?? [],
        children = children ?? [];

  factory GenaiSurveyResult.fromJson(Map<String, dynamic> json) => GenaiSurveyResult(
        question: json['question'] as String,
        answers: (json['answers'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        children: (json['children'] as List<dynamic>? ?? const []).map((e) => GenaiSurveyResult.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'children': children.map((e) => e.toJson()).toList(),
        'answers': answers,
      };
}
