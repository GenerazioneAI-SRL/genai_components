import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../buttons/cl_ghost_button.widget.dart';
import '../buttons/cl_icon_button.widget.dart';
import '../buttons/cl_outline_button.widget.dart';
import '../cl_checkbox.widget.dart';
import '../cl_container.widget.dart';
import '../cl_dropdown/cl_dropdown.dart';
import '../cl_empty_state.widget.dart';
import '../cl_view_toggle.widget.dart';
import './survey.state.dart';
import '../cl_text_field.widget.dart';
import '../buttons/cl_button.widget.dart';
import 'cl_survey_viewer.widget.dart';
import 'models/cl_survey.model.dart';
import 'models/option.dart';
import 'models/question.dart';

/// Editor del sondaggio (lato autore).
///
/// **Modello v2** (consigliato): passa [survey] (per un sondaggio nuovo
/// `const CLSurvey()`) e [onChanged]. L'editor permette di aggiungere,
/// riordinare (trascinando o con Su/Giù), duplicare ed eliminare domande,
/// cambiarne il tipo, modificare opzioni/scala/lunghezza massima, aggiungere
/// domande collegate a un'opzione (un livello, [CLSurvey.maxDepth]) e vedere
/// l'anteprima. Gli errori ([CLSurvey.validate]) compaiono sulla domanda appena
/// toccata, o su tutte con [showValidation] (es. dopo un tentativo di
/// pubblicazione fallito).
///
/// **Legacy** (schema 1): senza [survey] usa [questions]/[surveyJson] e
/// [onSurveyChange] con l'editor storico; comportamento invariato.
class CLSurveyBuilder extends StatefulWidget {
  const CLSurveyBuilder({
    super.key,
    this.surveyJson,
    this.onSurveyChange,
    this.questions,
    this.survey,
    this.onChanged,
    this.showValidation = false,
  });

  /// Legacy: domande schema 1 in JSON (stringa).
  final String? surveyJson;

  /// Legacy: domande schema 1.
  final List<Question>? questions;

  /// Legacy: notifica del template schema 1. Obbligatorio nell'uso legacy.
  final Function(List<Question>)? onSurveyChange;

  /// v2: schema di partenza. Se cambia (oggetto diverso da quello appena
  /// notificato con [onChanged]) l'editor riparte da lì.
  final CLSurvey? survey;

  /// v2: chiamato a ogni modifica con lo schema aggiornato.
  final ValueChanged<CLSurvey>? onChanged;

  /// v2: mostra subito gli errori di tutte le domande.
  final bool showValidation;

  @override
  CLSurveyBuilderState createState() => CLSurveyBuilderState();

  factory CLSurveyBuilder.fromJson({required String surveyJson, required Function(List<Question>) onSurveyChange}) {
    return CLSurveyBuilder(surveyJson: surveyJson, onSurveyChange: onSurveyChange);
  }

  factory CLSurveyBuilder.fromArray({required List<Question> questions, required Function(List<Question>) onSurveyChange}) {
    return CLSurveyBuilder(questions: questions, onSurveyChange: onSurveyChange);
  }
}

class CLSurveyBuilderState extends State<CLSurveyBuilder> {
  List<Question> questions = [];

  // ── Stato v2 ───────────────────────────────────────────────────────────
  CLSurvey _survey = const CLSurvey();
  CLSurvey? _lastEmitted;
  bool _preview = false;

  /// v2: schema corrente.
  CLSurvey get currentSurvey => _survey;

  List<Question> rebuildQuestions(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => Question.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.survey != null) {
      _survey = widget.survey!;
      return;
    }
    if (widget.surveyJson != null) {
      questions = rebuildQuestions(jsonDecode(widget.surveyJson!));
    } else {
      if (widget.questions != null) {
        questions = widget.questions!;
      }
    }
    widget.onSurveyChange?.call(questions);
  }

  @override
  void didUpdateWidget(covariant CLSurveyBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.survey;
    if (incoming != null &&
        !identical(incoming, oldWidget.survey) &&
        !identical(incoming, _lastEmitted) &&
        incoming != _survey) {
      _survey = incoming;
    }
  }

  void _update(List<CLSurveyQuestion> questions) {
    final next = CLSurvey(questions: questions);
    setState(() => _survey = next);
    _lastEmitted = next;
    widget.onChanged?.call(next);
  }

  void _move(int from, int to) {
    if (to < 0 || to >= _survey.questions.length || from == to) return;
    final list = List.of(_survey.questions);
    final item = list.removeAt(from);
    list.insert(to, item);
    _update(list);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.survey != null) return _buildV2(context);
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

  Widget _buildV2(BuildContext context) {
    final theme = CLTheme.of(context);
    final qs = _survey.questions;
    final issueCount = _survey.validate().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.gapMd),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${qs.length} ${qs.length == 1 ? 'domanda' : 'domande'}',
                  style: theme.bodyLabel.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w600),
                ),
              ),
              CLViewToggle<bool>(
                compact: false,
                selected: _preview,
                onChanged: (v) => setState(() => _preview = v),
                items: const [
                  CLViewToggleItem(icon: LucideIcons.pencil, label: 'Modifica', tooltip: 'Modifica le domande', value: false),
                  CLViewToggleItem(icon: LucideIcons.eye, label: 'Anteprima', tooltip: 'Come lo vedrà chi risponde', value: true),
                ],
              ),
            ],
          ),
        ),
        if (_preview)
          CLSurveyViewer(survey: _survey)
        else ...[
          if (qs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: Sizes.gapMd),
              child: CLEmptyState(
                title: 'Nessuna domanda',
                message: 'Aggiungi la prima domanda del sondaggio.',
                icon: LucideIcons.listChecks,
                compact: true,
              ),
            ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: qs.length,
            proxyDecorator: (child, index, animation) => Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Sizes.radiusCard), boxShadow: theme.popoverShadow),
                child: child,
              ),
            ),
            // onReorder resta (non onReorderItem) per compilare anche con Flutter < 3.41.
            // ignore: deprecated_member_use
            onReorder: (from, to) => _move(from, to > from ? to - 1 : to),
            itemBuilder: (context, i) => Padding(
              key: ValueKey(qs[i].id),
              padding: const EdgeInsets.only(bottom: Sizes.gapMd),
              child: _QuestionEditorCard(
                question: qs[i],
                index: i,
                total: qs.length,
                showValidation: widget.showValidation,
                onChanged: (q) => _update([for (final x in qs) x.id == q.id ? q : x]),
                onMove: (to) => _move(i, to),
                onDuplicate: () => _update([...qs.sublist(0, i + 1), qs[i].duplicate(), ...qs.sublist(i + 1)]),
                onDelete: () => _update([for (final x in qs) if (x.id != qs[i].id) x]),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: Sizes.buttonHeightLarge,
              child: CLOutlineButton.primary(
                text: 'Aggiungi domanda',
                icon: LucideIcons.plus,
                onTap: () => _update([...qs, CLSurveyQuestion.create(type: qs.isEmpty ? CLSurveyQuestionType.singleChoice : qs.last.type)]),
                context: context,
              ),
            ),
          ),
          if (widget.showValidation && issueCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: Sizes.gapMd),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  issueCount == 1 ? '1 problema da correggere prima di pubblicare.' : '$issueCount problemi da correggere prima di pubblicare.',
                  style: theme.smallText.copyWith(color: theme.danger),
                ),
              ),
            ),
        ],
      ],
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
  QuestionEditorState createState() => QuestionEditorState();
}

class QuestionEditorState extends State<QuestionEditor> {
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
    final theme = CLTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.padding),
      decoration: BoxDecoration(
        color: CLTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Sizes.radiusCard), topRight: Radius.circular(Sizes.radiusCard)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Sizes.gapMd, vertical: theme.gapIconText),
                  decoration: BoxDecoration(color: theme.primary.withValues(alpha: theme.opacitySoft), borderRadius: BorderRadius.circular(Sizes.radiusPill)),
                  child: Text(widget.title, style: CLTheme.of(context).bodyText.override(color: CLTheme.of(context).primary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: Sizes.padding / 2),
                if (selectedType.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Sizes.gapMd, vertical: theme.gapIconText),
                    decoration: BoxDecoration(color: theme.secondary.withValues(alpha: theme.opacitySoft), borderRadius: BorderRadius.circular(Sizes.radiusPill)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(icon: _getIconForType(selectedType), size: Sizes.iconSizeCompact, color: CLTheme.of(context).secondary),
                        SizedBox(width: Sizes.gapXs),
                        Text(selectedType, style: CLTheme.of(context).bodyLabel.override(color: CLTheme.of(context).secondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: Sizes.iconSizeDefault, color: CLTheme.of(context).danger),
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
                    padding: EdgeInsets.symmetric(vertical: Sizes.gapXs),
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
                        SizedBox(width: Sizes.gapSm),
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
                      HugeIcon(icon: HugeIcons.strokeRoundedMenuSquare, size: Sizes.iconSizeCompact, color: CLTheme.of(context).secondaryText),
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
                            HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: Sizes.iconSizeCompact, color: CLTheme.of(context).primary),
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
  OptionEditorState createState() => OptionEditorState();
}

class OptionEditorState extends State<OptionEditor> {
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
    final theme = CLTheme.of(context);
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
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: Sizes.iconSizeDefault, color: CLTheme.of(context).primary),
                  onPressed: widget.onAddSubQuestion,
                  tooltip: "Aggiungi domanda subordinata",
                ),
              if (widget.onDeleteOption != null)
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: Sizes.iconSizeDefault, color: CLTheme.of(context).danger),
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
                    padding: EdgeInsets.all(theme.gapIconText),
                    decoration: BoxDecoration(color: theme.secondary.withValues(alpha: theme.opacitySoft), borderRadius: BorderRadius.circular(Sizes.radiusChip)),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedHierarchySquare08, size: Sizes.iconSizeCompact, color: CLTheme.of(context).secondary),
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
                            HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: Sizes.iconSizeCompact, color: CLTheme.of(context).primary),
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

/// Card di modifica di una domanda v2 (interna a [CLSurveyBuilder]).
class _QuestionEditorCard extends StatefulWidget {
  const _QuestionEditorCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.showValidation,
    required this.onChanged,
    required this.onMove,
    required this.onDuplicate,
    required this.onDelete,
    this.depth = 0,
  });

  final CLSurveyQuestion question;
  final int index;
  final int total;

  /// 0 per le domande principali (trascinabili, in card), 1 per le collegate
  /// a un'opzione (rientrate dentro la card della principale).
  final int depth;
  final bool showValidation;
  final ValueChanged<CLSurveyQuestion> onChanged;
  final ValueChanged<int> onMove;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  State<_QuestionEditorCard> createState() => _QuestionEditorCardState();
}

class _QuestionEditorCardState extends State<_QuestionEditorCard> {
  late final TextEditingController _text;
  late final TextEditingController _help;
  late final TextEditingController _min;
  late final TextEditingController _max;
  late final TextEditingController _minLabel;
  late final TextEditingController _maxLabel;
  late final TextEditingController _maxLength;
  final Map<String, TextEditingController> _options = {};
  bool _touched = false;

  CLSurveyQuestion get q => widget.question;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: q.text);
    _help = TextEditingController(text: q.help ?? '');
    _min = TextEditingController(text: '${q.scale.min}');
    _max = TextEditingController(text: '${q.scale.max}');
    _minLabel = TextEditingController(text: q.scale.minLabel ?? '');
    _maxLabel = TextEditingController(text: q.scale.maxLabel ?? '');
    _maxLength = TextEditingController(text: q.maxLength?.toString() ?? '');
    for (final o in q.options) {
      _options[o.id] = TextEditingController(text: o.label);
    }
  }

  @override
  void didUpdateWidget(covariant _QuestionEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.question, q)) return;
    // Riallinea i campi solo quando il modello arriva diverso da ciò che
    // contengono (cambio esterno): durante la digitazione coincidono.
    void sync(TextEditingController c, String value) {
      if (c.text != value) c.text = value;
    }

    void syncInt(TextEditingController c, int? value) {
      if (int.tryParse(c.text.trim()) != value) c.text = value?.toString() ?? '';
    }

    sync(_text, q.text);
    sync(_help, q.help ?? '');
    syncInt(_min, q.scale.min);
    syncInt(_max, q.scale.max);
    sync(_minLabel, q.scale.minLabel ?? '');
    sync(_maxLabel, q.scale.maxLabel ?? '');
    syncInt(_maxLength, q.maxLength);
    final ids = q.options.map((o) => o.id).toSet();
    _options.removeWhere((id, c) {
      if (ids.contains(id)) return false;
      c.dispose();
      return true;
    });
    for (final o in q.options) {
      final c = _options.putIfAbsent(o.id, () => TextEditingController(text: o.label));
      sync(c, o.label);
    }
  }

  @override
  void dispose() {
    for (final c in [_text, _help, _min, _max, _minLabel, _maxLabel, _maxLength, ..._options.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit(CLSurveyQuestion next) {
    _touched = true;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final showErrors = widget.showValidation || _touched;
    final issues = showErrors ? q.validate() : const <CLSurveyIssue>[];
    String? issueFor(CLSurveyIssueField field, {String? optionId}) {
      for (final i in issues) {
        if (i.field == field && i.optionId == optionId) return i.message;
      }
      return null;
    }

    final errorStyle = theme.smallText.copyWith(color: theme.danger);
    final textError = issueFor(CLSurveyIssueField.text);
    final scaleError = issueFor(CLSurveyIssueField.scale);
    final maxLengthError = issueFor(CLSurveyIssueField.maxLength);
    final hasIssues = issues.isNotEmpty;

    final canNest = widget.depth + 1 < CLSurvey.maxDepth;

    // Sostituisce le collegate dell'opzione [optionId].
    void setNested(String optionId, List<CLSurveyQuestion> nested) => _emit(q.copyWith(options: [
          for (final o in q.options) o.id == optionId ? o.copyWith(nested: nested) : o,
        ]));

    Widget nestedEditors(CLSurveyOption option) {
      final list = option.nested;
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var k = 0; k < list.length; k++)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.gapSm),
                child: _QuestionEditorCard(
                  key: ValueKey(list[k].id),
                  question: list[k],
                  index: k,
                  total: list.length,
                  depth: widget.depth + 1,
                  showValidation: widget.showValidation,
                  onChanged: (n) => setNested(option.id, [for (final x in list) x.id == n.id ? n : x]),
                  onMove: (to) {
                    if (to < 0 || to >= list.length) return;
                    final next = List.of(list);
                    next.insert(to, next.removeAt(k));
                    setNested(option.id, next);
                  },
                  onDuplicate: () => setNested(option.id, [...list.sublist(0, k + 1), list[k].duplicate(), ...list.sublist(k + 1)]),
                  onDelete: () => setNested(option.id, [for (final x in list) if (x.id != list[k].id) x]),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: CLGhostButton.primary(
                text: 'Domanda se scelta',
                icon: LucideIcons.cornerDownRight,
                onTap: () => setNested(option.id, [...list, CLSurveyQuestion.create(type: CLSurveyQuestionType.text)]),
                context: context,
              ),
            ),
          ],
      );
    }

    final Widget typeEditor = switch (q.type) {
      CLSurveyQuestionType.singleChoice || CLSurveyQuestionType.multipleChoice || CLSurveyQuestionType.select => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              q.type == CLSurveyQuestionType.select ? 'Opzioni (${q.options.length}/${q.type.maxOptions})' : 'Opzioni',
              style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600),
            ),
            if (q.type == CLSurveyQuestionType.select)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.gapXs),
                child: Text(
                  'Chi risponde le sceglie da un elenco a tendina con ricerca: adatto alle liste lunghe.',
                  style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                ),
              ),
            if (canNest)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.gapXs),
                child: Text(
                  'Con «Domanda se scelta» aggiungi una domanda che compare solo a chi sceglie quell\'opzione.',
                  style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                ),
              ),
            const SizedBox(height: Sizes.gapSm),
            for (var i = 0; i < q.options.length; i++) ...[
              Row(
                children: [
                  Icon(
                    q.type == CLSurveyQuestionType.multipleChoice
                        ? LucideIcons.square
                        : q.type == CLSurveyQuestionType.select
                            ? LucideIcons.list
                            : LucideIcons.circle,
                    size: Sizes.iconSizeCompact,
                    color: theme.mutedForeground,
                  ),
                  const SizedBox(width: Sizes.gapSm),
                  Expanded(
                    child: CLTextField(
                      controller: _options[q.options[i].id]!,
                      labelText: '',
                      hintText: 'Opzione ${i + 1}',
                      onChanged: (v) async => _emit(q.copyWith(options: [
                        for (final o in q.options) o.id == q.options[i].id ? o.copyWith(label: v) : o,
                      ])),
                    ),
                  ),
                  const SizedBox(width: Sizes.gapXs),
                  CLIconButton(
                    iconData: LucideIcons.x,
                    tooltip: 'Rimuovi opzione',
                    semanticLabel: q.options[i].nested.isEmpty
                        ? 'Rimuovi opzione ${i + 1}'
                        : 'Rimuovi opzione ${i + 1} e le sue domande collegate',
                    iconColor: theme.secondaryText,
                    backgroundColor: Colors.transparent,
                    onTap: () => _emit(q.copyWith(options: [
                      for (final o in q.options)
                        if (o.id != q.options[i].id) o,
                    ])),
                  ),
                ],
              ),
              if (issueFor(CLSurveyIssueField.options, optionId: q.options[i].id) case final String e)
                Padding(
                  padding: const EdgeInsets.only(left: Sizes.iconSizeCompact + Sizes.gapSm, top: Sizes.gapXs),
                  child: Text(e, style: errorStyle),
                ),
              if (canNest) nestedEditors(q.options[i]),
              const SizedBox(height: Sizes.gapSm),
            ],
            if (issueFor(CLSurveyIssueField.options) case final String e)
              Padding(padding: const EdgeInsets.only(bottom: Sizes.gapSm), child: Text(e, style: errorStyle)),
            if (q.options.length < q.type.maxOptions)
              Align(
                alignment: Alignment.centerLeft,
                child: CLGhostButton.primary(
                  text: 'Aggiungi opzione',
                  icon: LucideIcons.plus,
                  onTap: () => _emit(q.copyWith(options: [...q.options, CLSurveyOption.create()])),
                  context: context,
                ),
              ),
          ],
        ),
      CLSurveyQuestionType.scale => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Scala', style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: Sizes.gapSm),
            Wrap(
              spacing: Sizes.gapMd,
              runSpacing: Sizes.gapMd,
              children: [
                SizedBox(
                  width: Sizes.gap4Xl * 2,
                  child: CLTextField.number(
                    controller: _min,
                    labelText: 'Da',
                    onChanged: (v) async {
                      final n = int.tryParse(v.trim());
                      if (n != null) _emit(q.copyWith(scale: q.scale.copyWith(min: n)));
                    },
                  ),
                ),
                SizedBox(
                  width: Sizes.gap4Xl * 2,
                  child: CLTextField.number(
                    controller: _max,
                    labelText: 'A',
                    onChanged: (v) async {
                      final n = int.tryParse(v.trim());
                      if (n != null) _emit(q.copyWith(scale: q.scale.copyWith(max: n)));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.gapMd),
            CLTextField(
              controller: _minLabel,
              labelText: 'Etichetta del minimo (facoltativa)',
              hintText: 'Es. Per niente',
              onChanged: (v) async => _emit(q.copyWith(scale: CLSurveyScale(
                    min: q.scale.min,
                    max: q.scale.max,
                    minLabel: v.trim().isEmpty ? null : v,
                    maxLabel: q.scale.maxLabel,
                  ))),
            ),
            const SizedBox(height: Sizes.gapMd),
            CLTextField(
              controller: _maxLabel,
              labelText: 'Etichetta del massimo (facoltativa)',
              hintText: 'Es. Moltissimo',
              onChanged: (v) async => _emit(q.copyWith(scale: CLSurveyScale(
                    min: q.scale.min,
                    max: q.scale.max,
                    minLabel: q.scale.minLabel,
                    maxLabel: v.trim().isEmpty ? null : v,
                  ))),
            ),
            if (scaleError != null) Padding(padding: const EdgeInsets.only(top: Sizes.gapSm), child: Text(scaleError, style: errorStyle)),
          ],
        ),
      CLSurveyQuestionType.text => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: Sizes.gap4Xl * 4,
                child: CLTextField.number(
                  controller: _maxLength,
                  labelText: 'Lunghezza massima (caratteri)',
                  onChanged: (v) async {
                    final t = v.trim();
                    if (t.isEmpty) {
                      _emit(q.copyWith(clearMaxLength: true));
                    } else if (int.tryParse(t) case final int n) {
                      _emit(q.copyWith(maxLength: n));
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: Sizes.gapXs),
            Text('Vuoto = nessun limite.', style: theme.smallLabel.copyWith(color: theme.mutedForeground)),
            if (maxLengthError != null)
              Padding(padding: const EdgeInsets.only(top: Sizes.gapSm), child: Text(maxLengthError, style: errorStyle)),
          ],
        ),
    };

    final nested = widget.depth > 0;
    final label = nested ? 'Domanda collegata ${widget.index + 1}' : 'Domanda ${widget.index + 1}';
    final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Le collegate si riordinano solo con Su/Giù: la maniglia vale per la lista principale.
              if (nested)
                Icon(LucideIcons.cornerDownRight, size: Sizes.iconSizeCompact, color: theme.mutedForeground)
              else
                ReorderableDragStartListener(
                  index: widget.index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Tooltip(
                      message: 'Trascina per riordinare',
                      child: SizedBox(
                        width: Sizes.iconSizeLarge,
                        height: theme.buttonHeightDefault,
                        child: Icon(LucideIcons.gripVertical, size: Sizes.iconSizeDefault, color: theme.mutedForeground),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: Sizes.gapXs),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, color: theme.primaryText),
                ),
              ),
              CLIconButton(
                iconData: LucideIcons.arrowUp,
                tooltip: 'Sposta su',
                semanticLabel: 'Sposta su ${label.toLowerCase()}',
                enabled: widget.index > 0,
                iconColor: theme.secondaryText,
                backgroundColor: Colors.transparent,
                onTap: () => widget.onMove(widget.index - 1),
              ),
              CLIconButton(
                iconData: LucideIcons.arrowDown,
                tooltip: 'Sposta giù',
                semanticLabel: 'Sposta giù ${label.toLowerCase()}',
                enabled: widget.index < widget.total - 1,
                iconColor: theme.secondaryText,
                backgroundColor: Colors.transparent,
                onTap: () => widget.onMove(widget.index + 1),
              ),
              CLIconButton(
                iconData: LucideIcons.copy,
                tooltip: 'Duplica',
                semanticLabel: 'Duplica ${label.toLowerCase()}',
                iconColor: theme.secondaryText,
                backgroundColor: Colors.transparent,
                onTap: widget.onDuplicate,
              ),
              CLIconButton(
                iconData: LucideIcons.trash2,
                tooltip: 'Elimina',
                semanticLabel: 'Elimina ${label.toLowerCase()}',
                iconColor: theme.danger,
                backgroundColor: Colors.transparent,
                onTap: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: Sizes.gapMd),
          CLTextField(
            controller: _text,
            labelText: 'Domanda',
            hintText: 'Es. Il corso ti è stato utile?',
            isRequired: true,
            onChanged: (v) async => _emit(q.copyWith(text: v)),
          ),
          if (textError != null) Padding(padding: const EdgeInsets.only(top: Sizes.gapXs), child: Text(textError, style: errorStyle)),
          const SizedBox(height: Sizes.gapMd),
          CLTextField(
            controller: _help,
            labelText: 'Aiuto (facoltativo)',
            hintText: 'Spiegazione mostrata sotto la domanda',
            onChanged: (v) async => _emit(v.trim().isEmpty ? q.copyWith(clearHelp: true) : q.copyWith(help: v)),
          ),
          const SizedBox(height: Sizes.gapMd),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: Sizes.gapLg,
              runSpacing: Sizes.gapMd,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: constraints.maxWidth < Sizes.gap4Xl * 6 ? constraints.maxWidth : Sizes.gap4Xl * 5,
                  child: CLDropdown<CLSurveyQuestionType>.singleSync(
                    key: ValueKey('type-${q.id}-${q.type.name}'),
                    hint: 'Tipo di domanda',
                    items: CLSurveyQuestionType.values,
                    valueToShow: (t) => t.label,
                    itemBuilder: (context, t) => Text(t.label),
                    selectedValues: q.type,
                    onSelectItem: (t) {
                      if (t == null || t == q.type) return;
                      _emit(q.copyWith(
                        type: t,
                        options: t.isChoice && q.options.isEmpty ? [CLSurveyOption.create(), CLSurveyOption.create()] : null,
                        maxLength: t == CLSurveyQuestionType.text && q.maxLength == null ? CLSurveyQuestion.defaultMaxLength : null,
                      ));
                    },
                  ),
                ),
                MergeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CLCheckbox(value: q.required, onChanged: (v) => _emit(q.copyWith(required: v ?? false))),
                      const SizedBox(width: Sizes.gapSm),
                      GestureDetector(
                        onTap: () => _emit(q.copyWith(required: !q.required)),
                        child: Text('Obbligatoria', style: theme.bodyText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sizes.gapLg),
          typeEditor,
        ],
      );
    if (nested) {
      return Container(
        padding: const EdgeInsets.only(left: Sizes.gapMd, top: Sizes.gapSm, bottom: Sizes.gapSm),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: hasIssues ? theme.danger : theme.primary, width: 2)),
        ),
        child: content,
      );
    }
    return CLContainer(
      contentPadding: const EdgeInsets.all(Sizes.gapLg),
      backgroundColor:
          hasIssues ? Color.alphaBlend(theme.danger.withValues(alpha: theme.opacityFaint), theme.secondaryBackground) : null,
      child: content,
    );
  }
}
