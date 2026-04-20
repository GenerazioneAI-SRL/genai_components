import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../theme/context_extensions.dart';
import '../inputs/genai_select.dart';
import '../inputs/genai_text_field.dart';
import 'genai_survey_builder_state.dart';
import 'models/genai_survey_option.dart';
import 'models/genai_survey_question.dart';

/// Visual builder for surveys (admin authoring tool).
class GenaiSurveyBuilder extends StatefulWidget {
  const GenaiSurveyBuilder({
    super.key,
    this.surveyJson,
    required this.onSurveyChange,
    this.questions,
  });

  final String? surveyJson;
  final List<GenaiSurveyQuestion>? questions;
  final void Function(List<GenaiSurveyQuestion>) onSurveyChange;

  factory GenaiSurveyBuilder.fromJson({
    required String surveyJson,
    required void Function(List<GenaiSurveyQuestion>) onSurveyChange,
  }) =>
      GenaiSurveyBuilder(surveyJson: surveyJson, onSurveyChange: onSurveyChange);

  factory GenaiSurveyBuilder.fromArray({
    required List<GenaiSurveyQuestion> questions,
    required void Function(List<GenaiSurveyQuestion>) onSurveyChange,
  }) =>
      GenaiSurveyBuilder(questions: questions, onSurveyChange: onSurveyChange);

  @override
  State<GenaiSurveyBuilder> createState() => _GenaiSurveyBuilderState();
}

class _GenaiSurveyBuilderState extends State<GenaiSurveyBuilder> {
  List<GenaiSurveyQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.surveyJson != null) {
      final decoded = jsonDecode(widget.surveyJson!) as List<dynamic>;
      _questions = decoded.map((j) => GenaiSurveyQuestion.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      _questions = widget.questions ?? [];
    }
    widget.onSurveyChange(_questions);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ChangeNotifierProvider<GenaiSurveyBuilderState>(
      create: (_) => GenaiSurveyBuilderState(
        questions: _questions,
        onSurveyChange: widget.onSurveyChange,
      ),
      builder: (context, _) {
        final state = context.watch<GenaiSurveyBuilderState>();
        final c = context.colors;
        final ty = context.typography;
        final radius = context.radius;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...state.questions.asMap().entries.map((entry) => _QuestionEditor(
                  key: ValueKey(entry.key),
                  questionIndex: entry.key,
                  question: entry.value,
                  title: 'Domanda ${entry.key + 1}',
                  onUpdate: (q) => state.updateQuestion(entry.key, q),
                  onDelete: () => state.deleteQuestion(entry.key),
                )),
            InkWell(
              onTap: state.addNewQuestion,
              borderRadius: BorderRadius.circular(radius.sm),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: spacing.s4, vertical: spacing.s2),
                decoration: BoxDecoration(
                  color: c.surfacePage,
                  border: Border.all(color: c.borderDefault),
                  borderRadius: BorderRadius.circular(radius.sm),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.plus, size: 20, color: c.textPrimary),
                  SizedBox(width: spacing.s2),
                  Text('Aggiungi domanda', style: ty.bodyMd.copyWith(color: c.textPrimary)),
                ]),
              ),
            ),
            SizedBox(height: spacing.s4),
          ],
        );
      },
    );
  }
}

const _kQuestionTypes = [
  'Testo',
  'Numerico',
  'Rating Numerico',
  'Rating Testuale',
  'Rating a Stella',
  'SI/NO',
  'Scelta Singola',
  'Scelta Multipla',
];

class _QuestionEditor extends StatefulWidget {
  final int questionIndex;
  final GenaiSurveyQuestion question;
  final ValueChanged<GenaiSurveyQuestion> onUpdate;
  final VoidCallback onDelete;
  final String title;

  const _QuestionEditor({
    super.key,
    required this.questionIndex,
    required this.question,
    required this.onUpdate,
    required this.onDelete,
    required this.title,
  });

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  late TextEditingController _qCtrl;
  late bool _isMandatory;
  List<GenaiSurveyOption> _options = [];
  bool _isSingleChoice = false;
  bool _isNumeric = false;
  bool _canAddOption = false;
  bool _canDeleteOption = false;
  bool _isRating = false;
  bool _isStarRating = false;
  String _selectedType = _kQuestionTypes.first;

  @override
  void initState() {
    super.initState();
    _qCtrl = TextEditingController(text: widget.question.question.isEmpty ? 'Testo della ${widget.title}' : widget.question.question);
    _isMandatory = widget.question.isMandatory;
    _options = List.from(widget.question.options);
  }

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  void _push() {
    widget.onUpdate(GenaiSurveyQuestion(
      question: _qCtrl.text,
      isMandatory: _isMandatory,
      singleChoice: _isSingleChoice,
      isNumeric: _isNumeric,
      isRating: _isRating,
      isStarRating: _isStarRating,
      options: List.from(_options),
      errorText: widget.question.errorText,
      properties: widget.question.properties,
      answers: widget.question.answers,
    ));
  }

  void _addOption() {
    setState(() {
      final id = 'option_${widget.questionIndex}_${_options.length + 1}';
      _options.add(GenaiSurveyOption(id: id, text: 'Opzione ${_options.length + 1}'));
      _push();
    });
  }

  void _onTypeChanged(String? item) {
    setState(() {
      _selectedType = item ?? '';
      switch (item) {
        case null:
        case 'Testo':
          _options = [];
          _canAddOption = false;
          _canDeleteOption = false;
          _isNumeric = false;
          _isSingleChoice = false;
          _isRating = false;
          _isStarRating = false;
          break;
        case 'Numerico':
          _options = [];
          _canAddOption = false;
          _canDeleteOption = false;
          _isNumeric = true;
          _isSingleChoice = false;
          _isRating = false;
          _isStarRating = false;
          break;
        case 'SI/NO':
          _options = [
            GenaiSurveyOption(id: 'option_booleano_si', text: 'Si'),
            GenaiSurveyOption(id: 'option_booleano_no', text: 'No'),
          ];
          _isSingleChoice = true;
          _canAddOption = false;
          _canDeleteOption = false;
          _isRating = false;
          _isStarRating = false;
          break;
        case 'Rating Numerico':
          _options = [
            for (var i = 1; i <= 5; i++) GenaiSurveyOption(id: 'option_rating_$i', text: '$i'),
          ];
          _isSingleChoice = true;
          _isRating = true;
          _isNumeric = true;
          _canAddOption = false;
          _canDeleteOption = false;
          _isStarRating = false;
          break;
        case 'Rating Testuale':
          _options = [
            GenaiSurveyOption(id: 'option_rating_1', text: 'Non sono interessato'),
            GenaiSurveyOption(id: 'option_rating_2', text: 'Poco interessato'),
            GenaiSurveyOption(id: 'option_rating_3', text: 'Abbastanza interessato'),
            GenaiSurveyOption(id: 'option_rating_4', text: 'Molto Interessato'),
          ];
          _isSingleChoice = true;
          _isRating = true;
          _isNumeric = false;
          _canAddOption = false;
          _canDeleteOption = false;
          _isStarRating = false;
          break;
        case 'Rating a Stella':
          _options = [];
          _isSingleChoice = false;
          _isRating = true;
          _isNumeric = false;
          _canAddOption = false;
          _canDeleteOption = false;
          _isStarRating = true;
          break;
        default:
          if (_options.isEmpty) {
            _options.add(GenaiSurveyOption(id: 'option_${widget.questionIndex}_1', text: 'Opzione 1'));
          }
          _isSingleChoice = (item == 'Scelta Singola');
          _canAddOption = true;
          _canDeleteOption = true;
          _isRating = false;
          _isStarRating = false;
      }
      _push();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Testo':
        return LucideIcons.type;
      case 'Numerico':
        return LucideIcons.calculator;
      case 'Rating Numerico':
      case 'Rating Testuale':
        return LucideIcons.star;
      case 'Rating a Stella':
        return LucideIcons.heart;
      case 'SI/NO':
        return LucideIcons.circleCheck;
      case 'Scelta Singola':
        return LucideIcons.circle;
      case 'Scelta Multipla':
        return LucideIcons.squareCheck;
      default:
        return LucideIcons.fileText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.s4),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(spacing.s4),
            decoration: BoxDecoration(
              color: c.surfacePage,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius.md),
                topRight: Radius.circular(radius.md),
              ),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.colorPrimarySubtle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(widget.title, style: ty.bodyMd.copyWith(color: c.colorPrimary, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: spacing.s2),
              if (_selectedType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.colorInfoSubtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_iconForType(_selectedType), size: 16, color: c.colorInfo),
                    const SizedBox(width: 4),
                    Text(_selectedType, style: ty.caption.copyWith(color: c.colorInfo, fontWeight: FontWeight.w600)),
                  ]),
                ),
              const Spacer(),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 20, color: c.colorError),
                onPressed: widget.onDelete,
                tooltip: 'Elimina domanda',
              ),
            ]),
          ),
          // Body
          Padding(
            padding: EdgeInsets.all(spacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: GenaiTextField(
                        controller: _qCtrl,
                        label: 'Testo della domanda',
                        onChanged: (_) => _push(),
                      ),
                    ),
                    SizedBox(width: spacing.s4),
                    Expanded(
                      child: GenaiSelect<String>(
                        label: 'Tipo domanda',
                        value: _selectedType,
                        options: [
                          for (final t in _kQuestionTypes) GenaiSelectOption(value: t, label: t),
                        ],
                        onChanged: _onTypeChanged,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.s4),
                InkWell(
                  onTap: () => setState(() {
                    _isMandatory = !_isMandatory;
                    _push();
                  }),
                  borderRadius: BorderRadius.circular(radius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Checkbox(
                        value: _isMandatory,
                        onChanged: (v) => setState(() {
                          _isMandatory = v ?? false;
                          _push();
                        }),
                        activeColor: c.colorPrimary,
                        checkColor: c.textOnPrimary,
                        side: BorderSide(color: c.borderDefault),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.sm)),
                      ),
                      const SizedBox(width: 8),
                      Text('Domanda obbligatoria', style: ty.bodyMd.copyWith(color: c.textPrimary)),
                    ]),
                  ),
                ),
                if (_options.isNotEmpty) ...[
                  SizedBox(height: spacing.s4),
                  Row(children: [
                    Icon(LucideIcons.menu, size: 18, color: c.textSecondary),
                    SizedBox(width: spacing.s2),
                    Text('Opzioni di risposta', style: ty.bodyMd.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                  ]),
                  SizedBox(height: spacing.s2),
                  ..._options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing.s2),
                      child: _OptionEditor(
                        key: ValueKey(option.id),
                        option: option,
                        isNumericRating: _isNumeric && _isRating,
                        onTextChanged: (newText) => setState(() {
                          option.text = newText;
                          _push();
                        }),
                        onAddSubQuestion: () => setState(() {
                          option.nested ??= [];
                          option.nested!.add(GenaiSurveyQuestion(
                            question: 'Domanda subordinata',
                            singleChoice: true,
                            options: const [],
                          ));
                          _push();
                        }),
                        onNestedChanged: (updated) => setState(() {
                          option.nested = updated;
                          _push();
                        }),
                        onDeleteOption: _canDeleteOption
                            ? () => setState(() {
                                  _options.removeAt(i);
                                  _push();
                                })
                            : null,
                      ),
                    );
                  }),
                ],
                if (_canAddOption)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s2),
                    child: InkWell(
                      onTap: _addOption,
                      borderRadius: BorderRadius.circular(radius.sm),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: spacing.s4, vertical: spacing.s2),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.colorPrimary),
                          borderRadius: BorderRadius.circular(radius.sm),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.plus, size: 18, color: c.colorPrimary),
                          SizedBox(width: spacing.s2),
                          Text('Aggiungi opzione', style: ty.bodyMd.copyWith(color: c.colorPrimary, fontWeight: FontWeight.w600)),
                        ]),
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
}

class _OptionEditor extends StatefulWidget {
  final GenaiSurveyOption option;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onAddSubQuestion;
  final ValueChanged<List<GenaiSurveyQuestion>> onNestedChanged;
  final VoidCallback? onDeleteOption;
  final bool isNumericRating;

  const _OptionEditor({
    super.key,
    required this.option,
    required this.onTextChanged,
    required this.onAddSubQuestion,
    required this.onNestedChanged,
    required this.isNumericRating,
    this.onDeleteOption,
  });

  @override
  State<_OptionEditor> createState() => _OptionEditorState();
}

class _OptionEditorState extends State<_OptionEditor> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.option.text);
  }

  @override
  void didUpdateWidget(covariant _OptionEditor old) {
    super.didUpdateWidget(old);
    if (old.option.text != widget.option.text) {
      _ctrl.text = widget.option.text;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final nested = widget.option.nested ?? [];

    return Container(
      padding: EdgeInsets.all(spacing.s4),
      decoration: BoxDecoration(
        color: c.surfacePage,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: widget.isNumericRating
                    ? GenaiTextField.numeric(
                        controller: _ctrl,
                        label: 'Testo opzione',
                        onChanged: widget.onTextChanged,
                      )
                    : GenaiTextField(
                        controller: _ctrl,
                        label: 'Testo opzione',
                        onChanged: widget.onTextChanged,
                      ),
              ),
              SizedBox(width: spacing.s2),
              if (nested.isEmpty)
                IconButton(
                  icon: Icon(LucideIcons.plus, size: 20, color: c.colorPrimary),
                  onPressed: widget.onAddSubQuestion,
                  tooltip: 'Aggiungi domanda subordinata',
                ),
              if (widget.onDeleteOption != null)
                IconButton(
                  icon: Icon(LucideIcons.trash2, size: 20, color: c.colorError),
                  onPressed: widget.onDeleteOption,
                  tooltip: 'Elimina opzione',
                ),
            ],
          ),
          if (nested.isNotEmpty) ...[
            SizedBox(height: spacing.s2),
            Container(
              decoration: BoxDecoration(
                color: c.surfaceCard,
                borderRadius: BorderRadius.circular(radius.sm),
                border: Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
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
                  tilePadding: EdgeInsets.symmetric(horizontal: spacing.s4, vertical: spacing.s2),
                  childrenPadding: EdgeInsets.all(spacing.s4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.sm)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.sm)),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: c.colorInfoSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(LucideIcons.workflow, size: 18, color: c.colorInfo),
                  ),
                  title: Text(
                    'Domande subordinate (${nested.length})',
                    style: ty.bodyMd.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    ...List.generate(nested.length, (i) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.s4),
                        child: _QuestionEditor(
                          key: ValueKey('sub_${i}_${widget.option.id}'),
                          questionIndex: i,
                          question: nested[i],
                          onUpdate: (updated) {
                            final list = List<GenaiSurveyQuestion>.from(nested);
                            list[i] = updated;
                            widget.onNestedChanged(list);
                          },
                          onDelete: () {
                            final list = List<GenaiSurveyQuestion>.from(nested);
                            list.removeAt(i);
                            widget.onNestedChanged(list);
                          },
                          title: 'Domanda subordinata ${i + 1}',
                        ),
                      );
                    }),
                    InkWell(
                      onTap: widget.onAddSubQuestion,
                      borderRadius: BorderRadius.circular(radius.sm),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: spacing.s4, vertical: spacing.s2),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.colorPrimary),
                          borderRadius: BorderRadius.circular(radius.sm),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.plus, size: 18, color: c.colorPrimary),
                          SizedBox(width: spacing.s2),
                          Text('Aggiungi domanda subordinata', style: ty.bodyMd.copyWith(color: c.colorPrimary, fontWeight: FontWeight.w600)),
                        ]),
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
}
