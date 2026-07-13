import 'package:flutter/material.dart';
import 'models/question.dart';

class SurveyState extends ChangeNotifier {
  List<Question> questions = [];
  Function(List<Question>)? onSurveyChange;

  SurveyState({this.questions = const [], this.onSurveyChange}) {
    questions = questions;
  }


  void addNewQuestion() {
    int numeroDomanda = questions.length + 1;

    questions.add(Question(
      question: "Testo della domanda $numeroDomanda",
      isMandatory: false,
      isNumeric: false,
      isRating: false,
      isStarRating: false,
      options: [], // domanda di tipo testo
    ));
    if (onSurveyChange != null) {
      onSurveyChange!(questions);
    }
    notifyListeners();
  }

  void updateQuestion(int index, Question updated) {
    questions[index] = updated;
    if (onSurveyChange != null) {
      onSurveyChange!(questions);
    }
    notifyListeners();
  }

  void deleteQuestion(int index) {
    questions.removeAt(index);
    notifyListeners();
  }
}
