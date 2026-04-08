import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/buttons/cl_button.widget.dart';
import 'package:collection/collection.dart';
import 'package:genai_components/widgets/cl_survey/question_card.dart';

import '../../layout/constants/sizes.constant.dart';
import 'models/question.dart';
import 'models/question_result.dart';

/// Crea un form Survey
class SurveyWidget extends StatefulWidget {
  /// La lista delle domande che definiscono il flusso del sondaggio.
  final List<Question> initialData;

  /// Funzione che ritorna un widget personalizzato da usare come campo, preferibilmente un FormField.
  final Widget Function(BuildContext context, Question question, void Function(List<String>) update)? builder;

  /// Metodo opzionale da chiamare con le domande compilate finora.
  final void Function(List<QuestionResult> questionResults)? onSave;

  /// Parametro per configurare il messaggio di errore di default in caso di validazione fallita.
  final String? defaultErrorText;

  final String? saveText;

  const SurveyWidget({super.key, required this.initialData, this.builder, this.defaultErrorText, this.onSave, this.saveText});

  @override
  State<SurveyWidget> createState() => _SurveyState();
}

class _SurveyState extends State<SurveyWidget> {
  late List<Question> _surveyState;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _surveyState = widget.initialData.map((question) => question.clone()).toList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return widget.initialData.isEmpty
        ? Center(child: Text("Nessuna domanda disponibile nel sondaggio", style: CLTheme.of(context).bodyLabel))
        : SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: widget.onSave != null ? (kBottomNavigationBarHeight + 50) : 0),
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              CustomScrollView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                slivers: [
                  DiffUtilSliverList.fromKeyedWidgetList(
                    children: _buildChildren(_surveyState),
                    insertAnimationBuilder: (context, animation, child) => FadeTransition(opacity: animation, child: child),
                    removeAnimationBuilder:
                        (context, animation, child) =>
                            FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, axisAlignment: 0, child: child)),
                  ),
                ],
              ),
              if (widget.onSave != null) SizedBox(height: Sizes.padding),
              if (widget.onSave != null)
                CLButton.primary(
                  text: widget.saveText ?? "Salva",
                  onTap: () {
                    widget.onSave?.call(_mapCompletionData(_surveyState));
                  },
                  context: context,
                ),
            ],
          ),
        );
  }

  List<QuestionResult> _mapCompletionData(List<Question> questionNodes) {
    List<QuestionResult> list = [];

    for (int i = 0; i < questionNodes.length; i++) {
      if (_isAnswered(questionNodes[i])) {
        // Crea un oggetto QuestionResult per la domanda principale
        var child = QuestionResult(question: questionNodes[i].question, answers: questionNodes[i].answers);
        list.add(child);

        // Ciclo attraverso le risposte per trovare quelle che potrebbero avere domande subordinate (nested)
        for (var answer in questionNodes[i].answers) {
          // Trovo l'opzione corrispondente alla risposta
          final option = questionNodes[i].options.firstWhereOrNull((o) => o.id == answer.keys.first);

          // Se l'opzione ha domande subordinate (nested), le aggiungo ai children
          if (option != null && option.nested != null && option.nested!.isNotEmpty) {
            // Aggiungi tutte le domande subordinate (nested) come children della domanda principale
            child.children.addAll(_mapCompletionData(option.nested!));
          }
        }
      }
    }
    return list;
  }

  List<Widget> _buildChildren(List<Question> questionNodes) {
    List<Widget> list = [];
    for (int i = 0; i < questionNodes.length; i++) {
      var child = QuestionCard(
        key: ObjectKey(questionNodes[i]),
        question: questionNodes[i],
        update: (List<Map<String, String>> value) {
          questionNodes[i].answers.clear();
          questionNodes[i].answers.addAll(value);
          setState(() {});
        },
        defaultErrorText: questionNodes[i].errorText ?? (widget.defaultErrorText ?? "This field is mandatory*"),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        isNumeric: questionNodes[i].isNumeric,
      );

      list.add(child);
      for (var answer in questionNodes[i].answers) {
        final selectedId = answer.keys.first;
        final option = questionNodes[i].options.firstWhereOrNull((o) => o.id == selectedId);
        if (option != null && option.nested != null && option.nested!.isNotEmpty) {
          list.addAll(_buildChildren(option.nested!));
        }
      }
    }
    return list;
  }

  bool _isAnswered(Question question) {
    return question.answers.isNotEmpty;
  }

  // Una domanda non è considerata "sentenza" se ha opzioni.
  bool _isNotSentenceQuestion(Question question) {
    return question.options.isNotEmpty;
  }
}

extension DeepCopy on Question {
  /// Ritorna una copia della domanda (clone).
  Question clone() {
    return Question.fromJson(toJson());
  }
}
