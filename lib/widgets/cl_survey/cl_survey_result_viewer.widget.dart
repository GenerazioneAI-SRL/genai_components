import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'models/question_result.dart';

class CLSurveyResultViewer extends StatefulWidget {
  const CLSurveyResultViewer({super.key, this.surveyJson, this.result = const [], this.showHeader = true});

  final List<Map<String, dynamic>>? surveyJson;
  final List<QuestionResult> result;
  final bool showHeader;

  @override
  CLSurveyResultViewerState createState() => CLSurveyResultViewerState();

  factory CLSurveyResultViewer.fromArray({required List<QuestionResult> questions, bool showHeader = true}) {
    return CLSurveyResultViewer(result: questions, showHeader: showHeader);
  }

  factory CLSurveyResultViewer.fromJson({required List<Map<String, dynamic>> surveyJson, bool showHeader = true}) {
    return CLSurveyResultViewer(surveyJson: surveyJson, showHeader: showHeader);
  }
}

class CLSurveyResultViewerState extends State<CLSurveyResultViewer> {
  List<QuestionResult> result = [];

  List<QuestionResult> rebuildQuestions(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => QuestionResult.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.surveyJson != null) {
      result = rebuildQuestions(widget.surveyJson!);
    } else {
      result = widget.result;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.result.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return _buildQuestionAnswer(question, context, index + 1);
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.padding * 2),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border.all(color: CLTheme.of(context).borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(color: CLTheme.of(context).secondaryText.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: HugeIcon(icon: HugeIcons.strokeRoundedHelpCircle, size: 32, color: CLTheme.of(context).secondaryText),
          ),
          const SizedBox(height: Sizes.padding),
          Text(
            "Nessuna risposta disponibile",
            style: CLTheme.of(context).bodyText.copyWith(color: CLTheme.of(context).secondaryText, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: Sizes.padding / 2),
          Text("Il questionario non contiene risposte", style: CLTheme.of(context).bodyLabel.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuestionAnswer(QuestionResult question, BuildContext context, int index, {bool isNested = false}) {
    final hasAnswer = question.answers.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: Sizes.padding, left: isNested ? Sizes.padding * 1.5 : 0),
      decoration: BoxDecoration(
        color: CLTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border.all(color: CLTheme.of(context).borderColor, width: 1),
        boxShadow: [BoxShadow(color: CLTheme.of(context).borderColor.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header della domanda
          _buildQuestionHeader(context, question, index, hasAnswer, isNested),

          // Risposta
          _buildAnswerContent(context, question, hasAnswer),

          // Domande annidate
          if (question.children.isNotEmpty) _buildNestedQuestions(context, question),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(BuildContext context, QuestionResult question, int index, bool hasAnswer, bool isNested) {
    return Container(
      padding: const EdgeInsets.all(Sizes.padding),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius)),
        border: Border(bottom: BorderSide(color: CLTheme.of(context).borderColor.withValues(alpha: 0.5), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icona solo per nested
          if (isNested) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CLTheme.of(context).borderColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 20,
                color: CLTheme.of(context).primary,
              ),
            ),
            const SizedBox(width: Sizes.padding),
          ],
          // Testo domanda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(question.question, style: CLTheme.of(context).bodyText.copyWith(fontWeight: FontWeight.w600, height: 1.4)),
                const SizedBox(height: 4),
                Text(
                  hasAnswer ? "Risposta compilata" : "Nessuna risposta",
                  style: CLTheme.of(context).bodyLabel.copyWith(fontSize: 12, color: CLTheme.of(context).secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerContent(BuildContext context, QuestionResult question, bool hasAnswer) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: Sizes.padding),
            child: HugeIcon(
              icon: hasAnswer ? HugeIcons.strokeRoundedEdit02 : HugeIcons.strokeRoundedFileRemove,
              size: Sizes.medium,
              color: CLTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(width: Sizes.padding),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(Sizes.padding),
              decoration: BoxDecoration(
                color: CLTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                border: Border.all(color: CLTheme.of(context).borderColor, width: 1),
              ),
              child: Text(
                hasAnswer ? question.answers.map((a) => a.values.first).join(", ") : "Nessuna risposta fornita",
                style: CLTheme.of(context).bodyText.copyWith(
                  color: hasAnswer ? CLTheme.of(context).primaryText : CLTheme.of(context).secondaryText,
                  fontStyle: hasAnswer ? FontStyle.normal : FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNestedQuestions(BuildContext context, QuestionResult question) {
    return Padding(
      padding: const EdgeInsets.only(left: Sizes.padding, right: Sizes.padding, bottom: Sizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(margin: const EdgeInsets.only(bottom: Sizes.padding), height: 1, color: CLTheme.of(context).borderColor.withValues(alpha: 0.5)),
          // Label domande correlate
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedHierarchySquare08, size: 16, color: CLTheme.of(context).secondaryText),
              const SizedBox(width: Sizes.padding / 2),
              Text(
                "Domande correlate",
                style: CLTheme.of(context).bodyLabel.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: CLTheme.of(context).secondaryText),
              ),
            ],
          ),
          const SizedBox(height: Sizes.padding / 2),
          // Domande nested
          ...question.children.asMap().entries.map((entry) {
            return _buildQuestionAnswer(entry.value, context, entry.key + 1, isNested: true);
          }),
        ],
      ),
    );
  }
}
