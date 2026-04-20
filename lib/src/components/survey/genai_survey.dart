import 'package:collection/collection.dart';
import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../actions/genai_button.dart';
import 'genai_survey_question_card.dart';
import 'models/genai_survey_question.dart';
import 'models/genai_survey_result.dart';

/// Inline survey form widget. Used by [GenaiSurveyViewer].
class GenaiSurvey extends StatefulWidget {
  final List<GenaiSurveyQuestion> initialData;
  final Widget Function(BuildContext context, GenaiSurveyQuestion question, void Function(List<String>) update)? builder;
  final void Function(List<GenaiSurveyResult> questionResults)? onSave;
  final String? defaultErrorText;
  final String? saveText;

  const GenaiSurvey({
    super.key,
    required this.initialData,
    this.builder,
    this.defaultErrorText,
    this.onSave,
    this.saveText,
  });

  @override
  State<GenaiSurvey> createState() => _GenaiSurveyState();
}

class _GenaiSurveyState extends State<GenaiSurvey> {
  late List<GenaiSurveyQuestion> _state;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _state = widget.initialData.map((q) => q.clone()).toList();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    if (widget.initialData.isEmpty) {
      return Center(
        child: Text(
          'Nessuna domanda disponibile nel sondaggio',
          style: ty.bodyMd.copyWith(color: c.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scroll,
      padding: EdgeInsets.only(bottom: widget.onSave != null ? (kBottomNavigationBarHeight + 50) : 0),
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          CustomScrollView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              DiffUtilSliverList.fromKeyedWidgetList(
                children: _buildChildren(_state),
                insertAnimationBuilder: (context, animation, child) => FadeTransition(opacity: animation, child: child),
                removeAnimationBuilder: (context, animation, child) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: 0,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
          if (widget.onSave != null) SizedBox(height: spacing.s4),
          if (widget.onSave != null)
            GenaiButton.primary(
              label: widget.saveText ?? 'Salva',
              onPressed: () => widget.onSave?.call(_mapResults(_state)),
            ),
        ],
      ),
    );
  }

  List<GenaiSurveyResult> _mapResults(List<GenaiSurveyQuestion> nodes) {
    final list = <GenaiSurveyResult>[];
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i].answers.isNotEmpty) {
        final child = GenaiSurveyResult(
          question: nodes[i].question,
          answers: nodes[i].answers.map(Map<String, dynamic>.from).toList(),
        );
        list.add(child);
        for (final answer in nodes[i].answers) {
          final option = nodes[i].options.firstWhereOrNull((o) => o.id == answer.keys.first);
          if (option?.nested != null && option!.nested!.isNotEmpty) {
            child.children.addAll(_mapResults(option.nested!));
          }
        }
      }
    }
    return list;
  }

  List<Widget> _buildChildren(List<GenaiSurveyQuestion> nodes) {
    final list = <Widget>[];
    for (var i = 0; i < nodes.length; i++) {
      list.add(GenaiSurveyQuestionCard(
        key: ObjectKey(nodes[i]),
        question: nodes[i],
        update: (value) {
          nodes[i].answers
            ..clear()
            ..addAll(value);
          setState(() {});
        },
        defaultErrorText: nodes[i].errorText ?? widget.defaultErrorText ?? 'Campo obbligatorio*',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        isNumeric: nodes[i].isNumeric,
      ));
      for (final answer in nodes[i].answers) {
        final option = nodes[i].options.firstWhereOrNull((o) => o.id == answer.keys.first);
        if (option?.nested != null && option!.nested!.isNotEmpty) {
          list.addAll(_buildChildren(option.nested!));
        }
      }
    }
    return list;
  }
}
