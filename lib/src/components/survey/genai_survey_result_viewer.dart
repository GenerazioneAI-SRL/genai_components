import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/context_extensions.dart';
import 'models/genai_survey_result.dart';

/// Read-only viewer for survey results.
class GenaiSurveyResultViewer extends StatefulWidget {
  const GenaiSurveyResultViewer({
    super.key,
    this.surveyJson,
    this.result = const [],
    this.showHeader = true,
  });

  final List<Map<String, dynamic>>? surveyJson;
  final List<GenaiSurveyResult> result;
  final bool showHeader;

  factory GenaiSurveyResultViewer.fromArray({
    required List<GenaiSurveyResult> questions,
    bool showHeader = true,
  }) =>
      GenaiSurveyResultViewer(result: questions, showHeader: showHeader);

  factory GenaiSurveyResultViewer.fromJson({
    required List<Map<String, dynamic>> surveyJson,
    bool showHeader = true,
  }) =>
      GenaiSurveyResultViewer(surveyJson: surveyJson, showHeader: showHeader);

  @override
  State<GenaiSurveyResultViewer> createState() => _GenaiSurveyResultViewerState();
}

class _GenaiSurveyResultViewerState extends State<GenaiSurveyResultViewer> {
  late List<GenaiSurveyResult> _result;

  @override
  void initState() {
    super.initState();
    _result = widget.surveyJson != null ? widget.surveyJson!.map((j) => GenaiSurveyResult.fromJson(j)).toList() : widget.result;
  }

  @override
  Widget build(BuildContext context) {
    if (_result.isEmpty) return _empty(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _result.asMap().entries.map((e) => _question(context, e.value, e.key + 1)).toList(),
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
          Text('Nessuna risposta disponibile', style: ty.bodyMd.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Il questionario non contiene risposte', style: ty.caption.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }

  Widget _question(BuildContext context, GenaiSurveyResult q, int index, {bool isNested = false}) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final hasAnswer = q.answers.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.s4, left: isNested ? spacing.s6 : 0),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: c.borderDefault),
        boxShadow: [
          BoxShadow(
            color: c.borderDefault.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.s4),
            decoration: BoxDecoration(
              color: c.surfacePage,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius.md),
                topRight: Radius.circular(radius.md),
              ),
              border: Border(
                bottom: BorderSide(
                  color: c.borderDefault.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNested) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.borderDefault.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.arrowRight, size: 20, color: c.colorPrimary),
                  ),
                  SizedBox(width: spacing.s4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(q.question, style: ty.bodyMd.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600, height: 1.4)),
                      const SizedBox(height: 4),
                      Text(
                        hasAnswer ? 'Risposta compilata' : 'Nessuna risposta',
                        style: ty.caption.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(spacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: spacing.s4),
                  child: Icon(
                    hasAnswer ? LucideIcons.pencil : LucideIcons.fileX,
                    size: 20,
                    color: c.textSecondary,
                  ),
                ),
                SizedBox(width: spacing.s4),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(spacing.s4),
                    decoration: BoxDecoration(
                      color: c.surfacePage,
                      borderRadius: BorderRadius.circular(radius.sm),
                      border: Border.all(color: c.borderDefault),
                    ),
                    child: Text(
                      hasAnswer ? q.answers.map((a) => a.values.first).join(', ') : 'Nessuna risposta fornita',
                      style: ty.bodyMd.copyWith(
                        color: hasAnswer ? c.textPrimary : c.textSecondary,
                        fontStyle: hasAnswer ? FontStyle.normal : FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (q.children.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: spacing.s4, right: spacing.s4, bottom: spacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: spacing.s4),
                    height: 1,
                    color: c.borderDefault.withValues(alpha: 0.5),
                  ),
                  Row(children: [
                    Icon(LucideIcons.workflow, size: 16, color: c.textSecondary),
                    SizedBox(width: spacing.s2),
                    Text('Domande correlate', style: ty.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
                  ]),
                  SizedBox(height: spacing.s2),
                  ...q.children.asMap().entries.map((e) => _question(context, e.value, e.key + 1, isNested: true)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
