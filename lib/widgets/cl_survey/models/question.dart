import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'option.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Question extends Equatable {
  /// Il testo della domanda.
  final String question;

  /// Indica se la domanda è a scelta singola o multipla.
  final bool singleChoice;

  /// Se true, la validazione fallisce se la domanda viene lasciata vuota o non soddisfa una condizione.
  final bool isMandatory;

  /// Testo di errore da mostrare in caso di validazione fallita.
  final String? errorText;

  /// Proprietà personalizzate per la domanda/campo.
  final Map<String, dynamic>? properties;

  /// La lista delle risposte selezionate dall'utente.
  late final List<Map<String,String>> answers;

  /// La lista delle opzioni disponibili per la domanda.
  final List<Option> options;
  final bool isNumeric;
  final bool isRating;
  final bool isStarRating;

  Question({
    required this.question,
    this.singleChoice = true,
    this.isMandatory = false,
    this.errorText,
    this.properties,
    this.isNumeric = false,
    this.isRating = false,
    required this.isStarRating,
    this.options = const [],
    List<Map<String,String>>? answers,
  }) : answers = answers ?? [];

  static Question fromJson(Map<String, dynamic> json) => Question(
        question: json['question'] as String? ?? '',
        singleChoice: json['single_choice'] as bool? ?? true,
        isMandatory: json['is_mandatory'] as bool? ?? false,
        isNumeric: json['isNumeric'] as bool? ?? false,
        isRating: json['isRating'] as bool? ?? false,
        isStarRating: json['isStarRating'] as bool? ?? false,
        errorText: json['error_text'] as String?,
        properties: json['properties'] as Map<String, dynamic>?,
        answers: (json['answers'] as List<dynamic>?)
            ?.map((e) => Map<String, String>.from(e as Map))
            .toList(),
        options: (json['options'] as List<dynamic>? ?? const [])
            .map((e) => Option.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'single_choice': singleChoice,
      'is_mandatory': isMandatory,
      'isNumeric': isNumeric,
      'isRating': isRating,
      'error_text': errorText,
      'isStarRating': isStarRating,
      'properties': properties,
      'answers': answers,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [question, singleChoice, isMandatory];
}
