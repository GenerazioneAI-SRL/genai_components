import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/context_extensions.dart';
import 'genai_survey.dart';
import 'models/genai_survey_question.dart';
import 'models/genai_survey_result.dart';

/// Public viewer for surveys. Accepts JSON or in-memory questions.
class GenaiSurveyViewer extends StatefulWidget {
  const GenaiSurveyViewer({
    super.key,
    this.surveyJson,
    this.questions,
    this.onSave,
    this.saveText,
    this.showHeader = true,
  });

  final List<Map<String, dynamic>>? surveyJson;
  final List<GenaiSurveyQuestion>? questions;
  final void Function(List<GenaiSurveyResult> results)? onSave;
  final String? saveText;
  final bool showHeader;

  factory GenaiSurveyViewer.fromArray({
    required List<GenaiSurveyQuestion> questions,
    bool showHeader = true,
    void Function(List<GenaiSurveyResult>)? onSave,
    String? saveText,
  }) =>
      GenaiSurveyViewer(
        questions: questions,
        showHeader: showHeader,
        onSave: onSave,
        saveText: saveText,
      );

  factory GenaiSurveyViewer.fromJson({
    required List<Map<String, dynamic>> surveyJson,
    bool showHeader = true,
    void Function(List<GenaiSurveyResult>)? onSave,
    String? saveText,
  }) =>
      GenaiSurveyViewer(
        surveyJson: surveyJson,
        showHeader: showHeader,
        onSave: onSave,
        saveText: saveText,
      );

  @override
  State<GenaiSurveyViewer> createState() => _GenaiSurveyViewerState();
}

class _GenaiSurveyViewerState extends State<GenaiSurveyViewer> {
  late List<GenaiSurveyQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.surveyJson != null ? widget.surveyJson!.map((j) => GenaiSurveyQuestion.fromJson(j)).toList() : (widget.questions ?? []);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return _empty(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) _header(context),
        GenaiSurvey(
          initialData: _questions,
          onSave: widget.onSave,
          saveText: widget.saveText,
        ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    return Container(
      padding: EdgeInsets.all(spacing.s8),
      decoration: BoxDecoration(
        color: c.surfacePage,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.s4),
            decoration: BoxDecoration(
              color: c.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.circleQuestionMark, size: 32, color: c.textSecondary),
          ),
          SizedBox(height: spacing.s4),
          Text('Nessuna domanda disponibile', style: ty.bodyMd.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Il questionario non contiene domande', style: ty.caption.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.s4),
      child: Row(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.s4, vertical: spacing.s2),
          decoration: BoxDecoration(
            color: c.colorPrimarySubtle,
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.circleQuestionMark, size: 18, color: c.colorPrimary),
            SizedBox(width: spacing.s2),
            Text(
              '${_questions.length} ${_questions.length == 1 ? 'domanda' : 'domande'}',
              style: ty.bodyMd.copyWith(color: c.colorPrimary, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ]),
    );
  }
}
