
import './question.dart';

class Option {
  final String id;
  String text;
  List<Question>? nested;

  Option({
    required this.id,
    required this.text,
    this.nested,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'nested': nested?.map((q) => q.toJson()).toList(),
    };
  }

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    id: json['id'] as String,
    text: json['text'] as String,
    nested: json['nested'] != null ? (json['nested'] as List).map((q) => Question.fromJson(q as Map<String, dynamic>)).toList() : null,
  );
}