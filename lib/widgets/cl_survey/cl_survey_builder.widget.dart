import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/cl_dropdown/cl_dropdown.dart';
import 'package:genai_components/widgets/cl_survey/survey.state.dart';
import 'package:genai_components/widgets/cl_text_field.widget.dart';
import '../buttons/cl_button.widget.dart';
import 'models/option.dart';
import 'models/question.dart';

class CLSurveyBuilder extends StatefulWidget {
  const CLSurveyBuilder({super.key, this.surveyJson, required this.onSurveyChange, this.questions});

  final String? surveyJson;
  final List<Question>? questions;

  final Function(List<Question>) onSurveyChange;

  @override
  _CLSurveyBuilderState createState() => _CLSurveyBuilderState();

  factory CLSurveyBuilder.fromJson({required String surveyJson, required Function(List<Question>) onSurveyChange}) {
    return CLSurveyBuilder(surveyJson: surveyJson, onSurveyChange: onSurveyChange);
  }

  factory CLSurveyBuilder.fromArray({required List<Question> questions, required Function(List<Question>) onSurveyChange}) {
    return CLSurveyBuilder(questions: questions, onSurveyChange: onSurveyChange);
  }
}

class _CLSurveyBuilderState extends State<CLSurveyBuilder> {
  List<Question> questions = [];

  List<Question> rebuildQuestions(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => Question.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.surveyJson != null) {
      questions = rebuildQuestions(jsonDecode(widget.surveyJson!));
    } else {
      if (widget.questions != null) {
        questions = widget.questions!;
      }
    }
    widget.onSurveyChange(questions);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SurveyState>(
      create: (context) => SurveyState(questions: questions, onSurveyChange: widget.onSurveyChange),
      builder: (context, child) {
        var state = context.watch<SurveyState>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...state.questions.asMap().entries.map((entry) {
              int index = entry.key;
              Question question = entry.value;
              return QuestionEditor(
                key: ValueKey(index),
                questionIndex: index,
                question: question,
                onUpdate: (updatedQuestion) {
                  state.updateQuestion(index, updatedQuestion);
                },
                onDelete: () {
                  state.deleteQuestion(index);
                },
                title: "Domanda ${index + 1}",
              );
            }),
            CLButton(
              text: 'Aggiungi domanda',
              textStyle: CLTheme.of(context).bodyText,
              hugeIcon: HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: Sizes.medium, color: CLTheme.of(context).primaryText),
              backgroundColor: CLTheme.of(context).primaryBackground,
              onTap: () {
                state.addNewQuestion();
              },
              context: context,
              iconAlignment: IconAlignment.start,
            ),

            SizedBox(height: Sizes.padding),
          ],
        );
      },
    );
  }
}

/// Widget per editare una singola domanda
class QuestionEditor extends StatefulWidget {
  final int questionIndex;
  final Question question;
  final ValueChanged<Question> onUpdate;
  final VoidCallback onDelete;
  final String title;

  const QuestionEditor({super.key, required this.questionIndex, required this.question, required this.onUpdate, required this.onDelete, required this.title});

  @override
  _QuestionEditorState createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late TextEditingController questionController;
  late bool isMandatory;
  List<Option> options = [];
  bool isSingleChoice = false;
  bool isNumeric = false;
  bool canAddOption = false;
  bool canDeleteOption = false;
  bool isRating = false;
  bool isStarRating = false;
  List<String> questionTypes = ["Testo", "Numerico", "Rating Numerico", "Rating Testuale", "Rating a Stella", "SI/NO", "Scelta Singola", "Scelta Multipla"];
  String selectedType = "";

  @override
  void initState() {
    super.initState();
    selectedType = questionTypes.first;

    questionController = TextEditingController(text: widget.question.question.isEmpty ? "Testo della ${widget.title}" : widget.question.question);
    isMandatory = widget.question.isMandatory;
    options = List<Option>.from(widget.question.options);
  }

  void updateQuestion() {
    // Creiamo una nuova lista per forzare il cambiamento
    final updatedOptions = List<Option>.from(options);
    final updated = Question(
      question: questionController.text,
      isMandatory: isMandatory,
      singleChoice: isSingleChoice,
      isNumeric: isNumeric,
      isRating: isRating,
      isStarRating: isStarRating,
      options: updatedOptions,
      errorText: widget.question.errorText,
      properties: widget.question.properties,
      answers: widget.question.answers,
    );
    widget.onUpdate(updated);
  }

  void addOption() {
    setState(() {
      int optionCount = options.length;
      String newId = "option_${widget.questionIndex}_${optionCount + 1}";
      options.add(Option(id: newId, text: "Opzione ${optionCount + 1}"));
      updateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.padding),
      decoration: BoxDecoration(
        color: CLTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border.all(color: CLTheme.of(context).borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header della domanda
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: CLTheme.of(context).primaryBackground,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: CLTheme.of(context).primary.withAlpha(26), borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.title, style: CLTheme.of(context).bodyText.override(color: CLTheme.of(context).primary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: Sizes.padding / 2),
                if (selectedType.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: CLTheme.of(context).secondary.withAlpha(26), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(icon: _getIconForType(selectedType), size: 16, color: CLTheme.of(context).secondary),
                        const SizedBox(width: 4),
                        Text(selectedType, style: CLTheme.of(context).bodyLabel.override(color: CLTheme.of(context).secondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: 20, color: Colors.red),
                  onPressed: widget.onDelete,
                  tooltip: "Elimina domanda",
                ),
              ],
            ),
          ),

          // Contenuto della domanda
          Padding(
            padding: const EdgeInsets.all(Sizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Testo domanda e tipo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CLTextField(controller: questionController, labelText: "Testo della domanda", onChanged: (_) async => updateQuestion()),
                    ),
                    const SizedBox(width: Sizes.padding),
                    Expanded(
                      child: CLDropdown<String>.singleSync(
                        hint: "Tipo domanda",
                        items: questionTypes,
                        valueToShow: (item) => item,
                        itemBuilder: (context, item) => Text(item),
                        selectedValues: selectedType,
                        onSelectItem: (item) {
                          setState(() {
                            selectedType = item ?? "";
                            if (item == null || item == "Testo") {
                              options = [];
                              canAddOption = false;
                              canDeleteOption = false;
                              isNumeric = false;
                              isSingleChoice = false;
                              isRating = false;
                              isStarRating = false;
                            } else if (item == "Numerico") {
                              options = [];
                              canAddOption = false;
                              canDeleteOption = false;
                              isNumeric = true;
                              isSingleChoice = false;
                              isRating = false;
                              isStarRating = false;
                            } else if (item == "SI/NO") {
                              options = [Option(id: "option_booleano_si", text: "Si"), Option(id: "option_booleano_no", text: "No")];
                              isSingleChoice = true;
                              canAddOption = false;
                              canDeleteOption = false;
                              isRating = false;
                              isStarRating = false;
                            } else if (item == "Rating Numerico") {
                              options = [
                                Option(id: "option_rating_1", text: "1"),
                                Option(id: "option_rating_2", text: "2"),
                                Option(id: "option_rating_3", text: "3"),
                                Option(id: "option_rating_4", text: "4"),
                                Option(id: "option_rating_5", text: "5"),
                              ];
                              isSingleChoice = true;
                              isRating = true;
                              isNumeric = true;
                              canAddOption = false;
                              canDeleteOption = false;
                              isStarRating = false;
                            } else if (item == "Rating Testuale") {
                              options = [
                                Option(id: "option_rating_1", text: "Non sono interessato"),
                                Option(id: "option_rating_2", text: "Poco interessato"),
                                Option(id: "option_rating_3", text: "Abbastanza interessato"),
                                Option(id: "option_rating_4", text: "Molto Interessato"),
                              ];
                              isSingleChoice = true;
                              isRating = true;
                              isNumeric = false;
                              canAddOption = false;
                              canDeleteOption = false;
                              isStarRating = false;
                            } else if (item == "Rating a Stella") {
                              options = [];
                              isSingleChoice = false;
                              isRating = true;
                              isNumeric = false;
                              canAddOption = false;
                              canDeleteOption = false;
                              isStarRating = true;
                            } else {
                              if (options.isEmpty) {
                                options.add(Option(id: "option_${widget.questionIndex}_1", text: "Opzione 1"));
                              }
                              isSingleChoice = (item == "Scelta Singola");
                              canAddOption = true;
                              canDeleteOption = true;
                              isRating = false;
                              isStarRating = false;
                            }
                            updateQuestion();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sizes.padding),

                // Checkbox obbligatoria
                InkWell(
                  onTap: () {
                    setState(() {
                      isMandatory = !isMandatory;
                      updateQuestion();
                    });
                  },
                  borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isMandatory,
                          onChanged: (val) {
                            setState(() {
                              isMandatory = val ?? false;
                              updateQuestion();
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          activeColor: CLTheme.of(context).primary,
                          checkColor: Colors.white,
                          side: BorderSide(color: CLTheme.of(context).borderColor, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                        ),
                        const SizedBox(width: 8),
                        Text("Domanda obbligatoria", style: CLTheme.of(context).bodyText),
                      ],
                    ),
                  ),
                ),

                // Opzioni
                if (options.isNotEmpty) ...[
                  const SizedBox(height: Sizes.padding),
                  Row(
                    children: [
                      HugeIcon(icon: HugeIcons.strokeRoundedMenuSquare, size: 18, color: CLTheme.of(context).secondaryText),
                      const SizedBox(width: Sizes.padding / 2),
                      Text("Opzioni di risposta", style: CLTheme.of(context).bodyText.override(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: Sizes.padding / 2),
                  ...options.asMap().entries.map((entry) {
                    int index = entry.key;
                    Option option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Sizes.padding / 2),
                      child: OptionEditor(
                        key: ValueKey(option.id),
                        option: option,
                        isNumericRating: isNumeric && isRating,
                        onTextChanged: (newText) {
                          setState(() {
                            option.text = newText;
                            updateQuestion();
                          });
                        },
                        onAddSubQuestion: () {
                          setState(() {
                            option.nested ??= [];
                            option.nested!.add(
                              Question(
                                question: "Domanda subordinata",
                                isMandatory: false,
                                singleChoice: true,
                                isNumeric: false,
                                isRating: false,
                                isStarRating: false,
                                options: [],
                              ),
                            );
                            updateQuestion();
                          });
                        },
                        onNestedChanged: (updatedSubQuestions) {
                          setState(() {
                            option.nested = updatedSubQuestions;
                            updateQuestion();
                          });
                        },
                        onDeleteOption:
                            canDeleteOption
                                ? () {
                                  setState(() {
                                    options.removeAt(index);
                                    updateQuestion();
                                  });
                                }
                                : null,
                      ),
                    );
                  }),
                ],

                // Aggiungi opzione
                if (canAddOption)
                  Padding(
                    padding: const EdgeInsets.only(top: Sizes.padding / 2),
                    child: InkWell(
                      onTap: addOption,
                      borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding / 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: CLTheme.of(context).primary),
                          borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18, color: CLTheme.of(context).primary),
                            const SizedBox(width: Sizes.padding / 2),
                            Text(
                              "Aggiungi opzione",
                              style: CLTheme.of(context).bodyText.override(color: CLTheme.of(context).primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  dynamic _getIconForType(String type) {
    switch (type) {
      case "Testo":
        return HugeIcons.strokeRoundedTextFont;
      case "Numerico":
        return HugeIcons.strokeRoundedCalculator;
      case "Rating Numerico":
      case "Rating Testuale":
        return HugeIcons.strokeRoundedStar;
      case "Rating a Stella":
        return HugeIcons.strokeRoundedFavourite;
      case "SI/NO":
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case "Scelta Singola":
        return HugeIcons.strokeRoundedCircle;
      case "Scelta Multipla":
        return HugeIcons.strokeRoundedCheckmarkSquare02;
      default:
        return HugeIcons.strokeRoundedTaskEdit01;
    }
  }
}

/// Widget per editare una singola opzione, con possibilità di aggiungere domande subordinate
class OptionEditor extends StatefulWidget {
  final Option option;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onAddSubQuestion;
  final ValueChanged<List<Question>> onNestedChanged;
  final VoidCallback? onDeleteOption;
  final bool isNumericRating;

  const OptionEditor({
    super.key,
    required this.option,
    required this.onTextChanged,
    required this.onAddSubQuestion,
    required this.onNestedChanged,
    required this.isNumericRating,
    this.onDeleteOption,
  });

  @override
  _OptionEditorState createState() => _OptionEditorState();
}

class _OptionEditorState extends State<OptionEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.option.text);
  }

  @override
  void didUpdateWidget(covariant OptionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.option.text != widget.option.text) {
      _controller.text = widget.option.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Question> nestedQuestions = widget.option.nested ?? [];
    return Container(
      padding: const EdgeInsets.all(Sizes.padding),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
        border: Border.all(color: CLTheme.of(context).borderColor.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riga con il campo di testo e pulsanti
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    widget.isNumericRating
                        ? CLTextField.number(
                          controller: _controller,
                          labelText: "Testo opzione",
                          onChanged: (value) async {
                            widget.onTextChanged(value);
                          },
                        )
                        : CLTextField(
                          controller: _controller,
                          labelText: "Testo opzione",
                          onChanged: (value) async {
                            widget.onTextChanged(value);
                          },
                        ),
              ),
              const SizedBox(width: Sizes.padding / 2),
              if (nestedQuestions.isEmpty)
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20, color: CLTheme.of(context).primary),
                  onPressed: widget.onAddSubQuestion,
                  tooltip: "Aggiungi domanda subordinata",
                ),
              if (widget.onDeleteOption != null)
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: 20, color: Colors.red),
                  onPressed: widget.onDeleteOption,
                  tooltip: "Elimina opzione",
                ),
            ],
          ),

          // Se ci sono domande subordinate, le mostriamo in un ExpansionTile
          if (nestedQuestions.isNotEmpty) ...[
            const SizedBox(height: Sizes.padding / 2),
            Container(
              decoration: BoxDecoration(
                color: CLTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                border: Border.all(color: CLTheme.of(context).borderColor.withAlpha(77)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding / 2),
                  childrenPadding: const EdgeInsets.all(Sizes.padding),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: CLTheme.of(context).secondary.withAlpha(26), borderRadius: BorderRadius.circular(6)),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedHierarchySquare08, size: 18, color: CLTheme.of(context).secondary),
                  ),
                  title: Text("Domande subordinate (${nestedQuestions.length})", style: CLTheme.of(context).bodyText.override(fontWeight: FontWeight.w600)),
                  children: [
                    ...List.generate(nestedQuestions.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Sizes.padding),
                        child: QuestionEditor(
                          key: ValueKey('sub_${index}_${widget.option.id}'),
                          questionIndex: index,
                          question: nestedQuestions[index],
                          onUpdate: (updatedSubQuestion) {
                            List<Question> updatedList = List.from(nestedQuestions);
                            updatedList[index] = updatedSubQuestion;
                            widget.onNestedChanged(updatedList);
                          },
                          onDelete: () {
                            List<Question> updatedList = List.from(nestedQuestions);
                            updatedList.removeAt(index);
                            widget.onNestedChanged(updatedList);
                          },
                          title: "Domanda subordinata ${index + 1}",
                        ),
                      );
                    }),
                    InkWell(
                      onTap: widget.onAddSubQuestion,
                      borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding / 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: CLTheme.of(context).primary),
                          borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18, color: CLTheme.of(context).primary),
                            const SizedBox(width: Sizes.padding / 2),
                            Text(
                              "Aggiungi domanda subordinata",
                              style: CLTheme.of(context).bodyText.override(color: CLTheme.of(context).primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
