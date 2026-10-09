import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import '../cl_empty_state.widget.dart';
import '../cl_pagination.widget.dart';
import '../cl_pill.widget.dart';
import '../cl_progress.widget.dart';
import 'models/cl_survey.model.dart';
import 'models/question_result.dart';

/// Risultati di un sondaggio.
///
/// **Modello v2** (consigliato), due viste:
/// - riepilogo: [survey] + [responses] → per domanda distribuzione delle
///   scelte (conteggi e percentuali), media e distribuzione della scala,
///   elenco paginato dei testi liberi ([CLSurveyResultViewer.summary]);
/// - singola risposta: [survey] + [response] → domanda per domanda la
///   risposta data ([CLSurveyResultViewer.response]).
///
/// **Legacy** (schema 1): senza [survey] mostra [result]/[surveyJson]
/// (`List<QuestionResult>`) come prima.
class CLSurveyResultViewer extends StatefulWidget {
  const CLSurveyResultViewer({
    super.key,
    this.surveyJson,
    this.result = const [],
    this.showHeader = true,
    this.survey,
    this.responses,
    this.response,
    this.textPageSize = 5,
  });

  /// Legacy: risultati schema 1 in JSON.
  final List<Map<String, dynamic>>? surveyJson;

  /// Legacy: risultati schema 1.
  final List<QuestionResult> result;

  /// v2: mostra l'intestazione con il numero di risposte (solo riepilogo).
  final bool showHeader;

  /// v2: schema del sondaggio. Se presente, il widget usa il modello v2.
  final CLSurvey? survey;

  /// v2: tutte le risposte → riepilogo. Ignorato se c'è [response].
  final List<CLSurveyResponse>? responses;

  /// v2: una risposta → vista della singola risposta.
  final CLSurveyResponse? response;

  /// v2: testi liberi per pagina nel riepilogo.
  final int textPageSize;

  @override
  CLSurveyResultViewerState createState() => CLSurveyResultViewerState();

  factory CLSurveyResultViewer.fromArray({required List<QuestionResult> questions, bool showHeader = true}) {
    return CLSurveyResultViewer(result: questions, showHeader: showHeader);
  }

  factory CLSurveyResultViewer.fromJson({required List<Map<String, dynamic>> surveyJson, bool showHeader = true}) {
    return CLSurveyResultViewer(surveyJson: surveyJson, showHeader: showHeader);
  }

  /// v2: riepilogo di tutte le risposte.
  factory CLSurveyResultViewer.summary({
    Key? key,
    required CLSurvey survey,
    required List<CLSurveyResponse> responses,
    bool showHeader = true,
    int textPageSize = 5,
  }) =>
      CLSurveyResultViewer(key: key, survey: survey, responses: responses, showHeader: showHeader, textPageSize: textPageSize);

  /// v2: una singola risposta.
  factory CLSurveyResultViewer.response({Key? key, required CLSurvey survey, required CLSurveyResponse response}) =>
      CLSurveyResultViewer(key: key, survey: survey, response: response);
}

class CLSurveyResultViewerState extends State<CLSurveyResultViewer> {
  List<QuestionResult> result = [];

  /// v2: pagina corrente dei testi liberi, per id di domanda.
  final Map<String, int> _textPages = {};

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
  void didUpdateWidget(covariant CLSurveyResultViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surveyJson == null && !identical(widget.result, oldWidget.result)) result = widget.result;
  }

  @override
  Widget build(BuildContext context) {
    final survey = widget.survey;
    if (survey != null) {
      final single = widget.response;
      return single != null ? _buildSingle(context, survey, single) : _buildSummary(context, survey, widget.responses ?? const []);
    }

    // Legacy. Prima leggeva `widget.result` e ignorava `surveyJson`
    // (fromJson mostrava sempre lo stato vuoto): ora legge lo stato.
    if (result.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...result.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return _buildQuestionAnswer(question, context, index + 1);
        }),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, CLSurvey survey, List<CLSurveyResponse> responses) {
    final theme = CLTheme.of(context);
    if (survey.questions.isEmpty) {
      return const CLEmptyState(title: 'Nessuna domanda', message: 'Il sondaggio non contiene domande.', icon: LucideIcons.listChecks, compact: true);
    }
    if (responses.isEmpty) {
      return const CLEmptyState(
        title: 'Ancora nessuna risposta',
        message: 'Il riepilogo comparirà quando qualcuno avrà risposto.',
        icon: LucideIcons.inbox,
        compact: true,
      );
    }
    final summary = CLSurveySummary.compute(survey, responses);
    final total = summary.responseCount;
    // Numero della domanda principale di ogni voce (le collegate prendono
    // quello della principale da cui dipendono).
    final rootNumbers = <int>[];
    var root = 0;
    for (final s in summary.questions) {
      if (s.depth == 0) root++;
      rootNumbers.add(root);
    }
    final barLabel = theme.smallLabel.copyWith(color: theme.secondaryText, fontFeatures: const [FontFeature.tabularFigures()]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: Sizes.gapLg),
            child: Text(
              '$total ${total == 1 ? 'risposta' : 'risposte'} · ${survey.questions.length} ${survey.questions.length == 1 ? 'domanda' : 'domande'}',
              style: theme.bodyLabel.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w600),
            ),
          ),
        for (var i = 0; i < summary.questions.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == summary.questions.length - 1 ? 0 : Sizes.gapMd),
            child: Builder(builder: (context) {
              final s = summary.questions[i];
              final q = s.question;
              // Elenco a tendina: solo le opzioni scelte almeno una volta, dalla più scelta.
              final shownOptions = q.type == CLSurveyQuestionType.select
                  ? ([for (final o in q.options) if ((s.optionCounts[o.id] ?? 0) > 0) o]
                    ..sort((a, b) => (s.optionCounts[b.id] ?? 0).compareTo(s.optionCounts[a.id] ?? 0)))
                  : q.options;
              final pageCount = (s.texts.length / widget.textPageSize).ceil();
              final page = (_textPages[q.id] ?? 0).clamp(0, pageCount == 0 ? 0 : pageCount - 1);

              final Widget body = switch (q.type) {
                CLSurveyQuestionType.singleChoice ||
                CLSurveyQuestionType.multipleChoice ||
                CLSurveyQuestionType.select =>
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (shownOptions.isEmpty)
                        Text('Nessuna risposta', style: theme.bodyText.copyWith(color: theme.secondaryText, fontStyle: FontStyle.italic)),
                      for (final o in shownOptions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Sizes.gapMd),
                          child: Semantics(
                            label: '${o.label}: ${s.optionCounts[o.id] ?? 0} risposte, ${(s.share(s.optionCounts[o.id] ?? 0) * 100).round()} per cento',
                            excludeSemantics: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: Text(o.label, style: theme.bodyText)),
                                    const SizedBox(width: Sizes.gapMd),
                                    Text(
                                      '${s.optionCounts[o.id] ?? 0} · ${(s.share(s.optionCounts[o.id] ?? 0) * 100).round()}%',
                                      style: barLabel,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Sizes.gapXs),
                                CLProgress(value: s.share(s.optionCounts[o.id] ?? 0), height: Sizes.gapSm),
                              ],
                            ),
                          ),
                        ),
                      if (q.type == CLSurveyQuestionType.multipleChoice)
                        Text(
                          'Scelta multipla: le percentuali sono su chi ha risposto e possono superare il 100%.',
                          style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                        ),
                      if (q.type == CLSurveyQuestionType.select && shownOptions.length < q.options.length)
                        Text(
                          'Elenco a tendina: sono mostrate solo le ${shownOptions.length} opzioni scelte su ${q.options.length}.',
                          style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                        ),
                    ],
                  ),
                CLSurveyQuestionType.scale => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: s.average == null ? 'Nessuna media' : 'Media ${s.average!.toStringAsFixed(1)} su ${q.scale.max}',
                        excludeSemantics: true,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: Sizes.gapSm,
                          children: [
                            Text(
                              s.average == null ? '—' : s.average!.toStringAsFixed(1).replaceAll('.', ','),
                              style: theme.heading2.copyWith(color: theme.primaryText),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: Sizes.gapXs),
                              child: Text('media su ${q.scale.min}–${q.scale.max}', style: theme.smallLabel.copyWith(color: theme.secondaryText)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Sizes.gapMd),
                      for (final v in q.scale.values)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Sizes.gapSm),
                          child: Semantics(
                            label: 'Valore $v: ${s.valueCounts[v] ?? 0} risposte',
                            excludeSemantics: true,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: Sizes.iconSizeLarge,
                                  child: Text('$v', style: barLabel.copyWith(fontWeight: FontWeight.w600, color: theme.primaryText)),
                                ),
                                const SizedBox(width: Sizes.gapSm),
                                Expanded(child: CLProgress(value: s.share(s.valueCounts[v] ?? 0), height: Sizes.gapSm)),
                                const SizedBox(width: Sizes.gapSm),
                                SizedBox(
                                  width: Sizes.gap4Xl,
                                  child: Text('${s.valueCounts[v] ?? 0}', textAlign: TextAlign.end, style: barLabel),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (q.scale.minLabel != null || q.scale.maxLabel != null)
                        Text(
                          [
                            if (q.scale.minLabel != null) '${q.scale.min} = ${q.scale.minLabel}',
                            if (q.scale.maxLabel != null) '${q.scale.max} = ${q.scale.maxLabel}',
                          ].join(' · '),
                          style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                        ),
                    ],
                  ),
                CLSurveyQuestionType.text => s.texts.isEmpty
                    ? Text('Nessuna risposta', style: theme.bodyText.copyWith(color: theme.secondaryText, fontStyle: FontStyle.italic))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final t in s.texts.skip(page * widget.textPageSize).take(widget.textPageSize))
                            Container(
                              margin: const EdgeInsets.only(bottom: Sizes.gapSm),
                              padding: const EdgeInsets.all(Sizes.gapMd),
                              decoration: BoxDecoration(
                                color: theme.primaryBackground,
                                borderRadius: BorderRadius.circular(Sizes.radiusControl),
                                border: Border.all(color: theme.borderColor),
                              ),
                              child: Text(t, style: theme.bodyText),
                            ),
                          if (pageCount > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: Sizes.gapXs),
                              child: CLPagination(
                                currentPage: page,
                                totalPages: pageCount,
                                totalItems: s.texts.length,
                                itemLabel: 'risposte',
                                onPageChanged: (p) => setState(() => _textPages[q.id] = p),
                              ),
                            ),
                        ],
                      ),
              };

              final card = CLContainer(
                contentPadding: const EdgeInsets.all(Sizes.gapLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: Sizes.gapSm,
                      runSpacing: Sizes.gapXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          s.depth == 0
                              ? 'Domanda ${rootNumbers[i]}'
                              : 'Domanda ${rootNumbers[i]} · se «${s.parentOption?.label ?? ''}»',
                          style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                        ),
                        CLPill(pillColor: theme.secondaryText, pillText: q.type.label),
                      ],
                    ),
                    const SizedBox(height: Sizes.gapXs),
                    Text(q.text, style: theme.title.copyWith(fontWeight: FontWeight.w600, color: theme.primaryText)),
                    const SizedBox(height: Sizes.gapXs),
                    Text(
                      '${s.answeredCount} di $total hanno risposto',
                      style: theme.smallLabel.copyWith(color: theme.secondaryText),
                    ),
                    const SizedBox(height: Sizes.gapMd),
                    body,
                  ],
                ),
              );
              // Collegata: rientrata sotto la principale.
              return s.depth == 0 ? card : Padding(padding: EdgeInsets.only(left: Sizes.gapLg * s.depth), child: card);
            }),
          ),
      ],
    );
  }

  Widget _buildSingle(BuildContext context, CLSurvey survey, CLSurveyResponse response) {
    final theme = CLTheme.of(context);
    if (survey.questions.isEmpty) {
      return const CLEmptyState(title: 'Nessuna domanda', message: 'Il sondaggio non contiene domande.', icon: LucideIcons.listChecks, compact: true);
    }
    final clean = survey.sanitizeResponse(response);
    // Le collegate compaiono solo se erano visibili a chi ha risposto.
    final nodes = survey.visibleNodes(clean);

    return CLContainer(
      contentPadding: const EdgeInsets.all(Sizes.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < nodes.length; i++) ...[
            if (i > 0 && nodes[i].isRoot)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Sizes.gapMd),
                child: Divider(height: 1, thickness: 1, color: theme.borderColor),
              )
            else if (i > 0)
              const SizedBox(height: Sizes.gapMd),
            Builder(builder: (context) {
              final node = nodes[i];
              final q = node.question;
              final a = clean.answers[q.id];
              final String? text = a == null
                  ? null
                  : switch (q.type) {
                      CLSurveyQuestionType.singleChoice ||
                      CLSurveyQuestionType.multipleChoice ||
                      CLSurveyQuestionType.select =>
                        a.optionIds.map((id) => q.optionById(id)?.label ?? '').where((l) => l.isNotEmpty).join(' · '),
                      CLSurveyQuestionType.scale => '${a.value} su ${q.scale.max}'
                          '${a.value == q.scale.min && q.scale.minLabel != null ? ' (${q.scale.minLabel})' : ''}'
                          '${a.value == q.scale.max && q.scale.maxLabel != null ? ' (${q.scale.maxLabel})' : ''}',
                      CLSurveyQuestionType.text => a.text,
                    };
              final column = Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      node.isRoot
                          ? 'Domanda ${node.rootIndex + 1}'
                          : 'Domanda ${node.rootIndex + 1} · se «${node.parentOption?.label ?? ''}»',
                      style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                    ),
                    const SizedBox(height: Sizes.gapXs),
                    Text(q.text, style: theme.bodyText.copyWith(fontWeight: FontWeight.w600, color: theme.primaryText)),
                    const SizedBox(height: Sizes.gapXs),
                    Text(
                      text ?? 'Nessuna risposta',
                      style: theme.bodyText.copyWith(
                        color: text == null ? theme.secondaryText : theme.primaryText,
                        fontStyle: text == null ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              );
              if (node.isRoot) return column;
              return Container(
                padding: const EdgeInsets.only(left: Sizes.gapMd),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: theme.borderColor, width: 2))),
                child: column,
              );
            }),
          ],
        ],
      ),
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.padding * 2),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        border: Border.all(color: CLTheme.of(context).borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(color: CLTheme.of(context).secondaryText.withValues(alpha: CLTheme.of(context).opacitySoft), shape: BoxShape.circle),
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
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
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
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Sizes.radiusCard), topRight: Radius.circular(Sizes.radiusCard)),
        border: Border(bottom: BorderSide(color: CLTheme.of(context).borderColor.withValues(alpha: CLTheme.of(context).opacityDisabled), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icona solo per nested
          if (isNested) ...[
            Container(
              padding: const EdgeInsets.all(Sizes.gapSm),
              decoration: BoxDecoration(
                color: CLTheme.of(context).borderColor.withValues(alpha: CLTheme.of(context).opacityMedium),
                borderRadius: BorderRadius.circular(Sizes.radiusControl),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: Sizes.iconSizeDefault,
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
                const SizedBox(height: Sizes.gapXs),
                Text(
                  hasAnswer ? "Risposta compilata" : "Nessuna risposta",
                  style: CLTheme.of(context).smallText.copyWith(color: CLTheme.of(context).secondaryText),
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
          Container(margin: const EdgeInsets.only(bottom: Sizes.padding), height: 1, color: CLTheme.of(context).borderColor.withValues(alpha: CLTheme.of(context).opacityDisabled)),
          // Label domande correlate
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedHierarchySquare08, size: Sizes.iconSizeCompact, color: CLTheme.of(context).secondaryText),
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
