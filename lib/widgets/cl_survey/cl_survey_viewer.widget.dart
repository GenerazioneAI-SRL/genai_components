import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../cl_theme.dart';
import './survey.dart';
import '../../layout/constants/sizes.constant.dart';
import 'models/question.dart';
import 'models/question_result.dart';

class CLSurveyViewer extends StatefulWidget {
  const CLSurveyViewer({
    super.key,
    this.surveyJson,
    this.questions,
    this.onSave,
    this.saveText,
    this.showHeader = true,
  });

  final List<Map<String, dynamic>>? surveyJson;
  final List<Question>? questions;
  final void Function(List<QuestionResult> questionResults)? onSave;
  final String? saveText;
  final bool showHeader;

  @override
  _CLSurveyViewerState createState() => _CLSurveyViewerState();

  factory CLSurveyViewer.fromArray({
    required List<Question> questions,
    bool showHeader = true,
    void Function(List<QuestionResult>)? onSave,
    String? saveText,
  }) {
    return CLSurveyViewer(
      questions: questions,
      showHeader: showHeader,
      onSave: onSave,
      saveText: saveText,
    );
  }

  factory CLSurveyViewer.fromJson({
    required List<Map<String, dynamic>> surveyJson,
    bool showHeader = true,
    void Function(List<QuestionResult>)? onSave,
    String? saveText,
  }) {
    return CLSurveyViewer(
      surveyJson: surveyJson,
      showHeader: showHeader,
      onSave: onSave,
      saveText: saveText,
    );
  }
}

class _CLSurveyViewerState extends State<CLSurveyViewer> {
  List<Question> questions = [];

  List<Question> rebuildQuestions(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => Question.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.surveyJson != null) {
      questions = rebuildQuestions(widget.surveyJson!);
    } else {
      questions = widget.questions ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) _buildHeader(context),
        SurveyWidget(
          initialData: questions,
          onSave: widget.onSave,
          saveText: widget.saveText,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.padding * 2),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border.all(
          color: CLTheme.of(context).borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: CLTheme.of(context).secondaryText.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedHelpCircle,
              size: 32,
              color: CLTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(height: Sizes.padding),
          Text(
            "Nessuna domanda disponibile",
            style: CLTheme.of(context).bodyText.copyWith(
              color: CLTheme.of(context).secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Sizes.padding / 2),
          Text(
            "Il questionario non contiene domande",
            style: CLTheme.of(context).bodyLabel.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.padding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.padding,
              vertical: Sizes.padding / 2,
            ),
            decoration: BoxDecoration(
              color: CLTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedHelpCircle,
                  size: Sizes.medium,
                  color: CLTheme.of(context).primary,
                ),
                const SizedBox(width: Sizes.padding / 2),
                Text(
                  "${questions.length} ${questions.length == 1 ? 'domanda' : 'domande'}",
                  style: CLTheme.of(context).bodyText.copyWith(
                    color: CLTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
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
