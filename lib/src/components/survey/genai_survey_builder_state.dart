import 'package:flutter/material.dart';

import 'models/genai_survey_question.dart';

/// State container used by [GenaiSurveyBuilder].
class GenaiSurveyBuilderState extends ChangeNotifier {
  List<GenaiSurveyQuestion> questions = [];
  void Function(List<GenaiSurveyQuestion>)? onSurveyChange;

  GenaiSurveyBuilderState({
    this.questions = const [],
    this.onSurveyChange,
  });

  void addNewQuestion() {
    final n = questions.length + 1;
    questions.add(GenaiSurveyQuestion(
      question: 'Testo della domanda $n',
      options: const [],
    ));
    onSurveyChange?.call(questions);
    notifyListeners();
  }

  void updateQuestion(int index, GenaiSurveyQuestion updated) {
    questions[index] = updated;
    onSurveyChange?.call(questions);
    notifyListeners();
  }

  void deleteQuestion(int index) {
    questions.removeAt(index);
    onSurveyChange?.call(questions);
    notifyListeners();
  }
}
