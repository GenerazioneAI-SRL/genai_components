import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../cl_theme.dart';
import '../buttons/cl_button.widget.dart';
import '../buttons/cl_outline_button.widget.dart';
import '../cl_container.widget.dart';
import '../cl_empty_state.widget.dart';
import '../cl_progress.widget.dart';
import '../cl_text_field.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import './survey.dart';
import '../../layout/constants/sizes.constant.dart';
import 'models/cl_survey.model.dart';
import 'models/question.dart';
import 'models/question_result.dart';

/// Come [CLSurveyViewer] dispone le domande (solo modello v2, con `survey`).
enum CLSurveyViewerMode {
  /// Una domanda per schermata sotto [CLSurveyViewer.pagedBreakpoint] di
  /// larghezza (telefono), tutte in una pagina sopra (desktop).
  auto,

  /// Una domanda per schermata, con Indietro/Avanti.
  paged,

  /// Tutte le domande in una pagina.
  all,
}

/// Compilazione di un sondaggio.
///
/// **Modello v2** (consigliato): passa [survey] ([CLSurvey]). Il viewer
/// gestisce modalità una-per-schermata o tutte-in-pagina ([mode]), barra di
/// avanzamento, validazione delle obbligatorie, bozza ([onDraftChanged]),
/// invio ([onSubmit]) e sola lettura ([readOnly]).
///
/// Con altezza vincolata (es. `Expanded`) il viewer scorre da sé e, in
/// modalità una-per-schermata, tiene i bottoni fermi in basso; con altezza
/// libera (dentro uno scroll) si dimensiona sul contenuto.
///
/// **Legacy** (schema 1): senza [survey] usa [questions]/[surveyJson] e
/// [onSave], con il motore storico ([SurveyWidget]); comportamento invariato.
class CLSurveyViewer extends StatefulWidget {
  const CLSurveyViewer({
    super.key,
    this.surveyJson,
    this.questions,
    this.onSave,
    this.saveText,
    this.showHeader = true,
    this.survey,
    this.initialResponse,
    this.onDraftChanged,
    this.onSubmit,
    this.mode = CLSurveyViewerMode.auto,
    this.readOnly = false,
    this.draftDebounce = const Duration(milliseconds: 600),
    this.nextText,
    this.backText,
  });

  /// Legacy: domande in JSON schema 1.
  final List<Map<String, dynamic>>? surveyJson;

  /// Legacy: domande schema 1.
  final List<Question>? questions;

  /// Legacy: risultati schema 1 al tap su Salva.
  final void Function(List<QuestionResult> questionResults)? onSave;

  /// Testo del bottone finale (legacy: «Salva»; v2: «Invia»).
  final String? saveText;

  /// Mostra l'intestazione (legacy: conteggio; v2: avanzamento).
  final bool showHeader;

  /// v2: schema del sondaggio. Se presente, il viewer usa il modello v2 e
  /// ignora [questions], [surveyJson] e [onSave].
  final CLSurvey? survey;

  /// v2: risposte di partenza (bozza salvata o risposte già inviate). Se il
  /// valore cambia e differisce dallo stato corrente, lo sostituisce.
  final CLSurveyResponse? initialResponse;

  /// v2: chiamato a ogni modifica con la risposta corrente (non ripulita),
  /// per salvare la bozza. Le scelte arrivano subito, il testo dopo
  /// [draftDebounce]; cambio pagina e invio svuotano l'attesa.
  final ValueChanged<CLSurveyResponse>? onDraftChanged;

  /// v2: invio. Riceve la risposta ripulita ([CLSurvey.sanitizeResponse]) solo
  /// se tutte le obbligatorie hanno risposta. Se ritorna un `Future`, il
  /// bottone resta in caricamento fino al completamento. Senza [onSubmit] il
  /// bottone di invio non c'è (anteprima).
  final FutureOr<void> Function(CLSurveyResponse response)? onSubmit;

  /// v2: disposizione delle domande.
  final CLSurveyViewerMode mode;

  /// v2: sola lettura (risposte già inviate). Mostra sempre tutte le domande
  /// in una pagina, senza bottoni.
  final bool readOnly;

  /// v2: attesa prima di notificare la bozza mentre si scrive.
  final Duration draftDebounce;

  /// v2: testo del bottone «Avanti».
  final String? nextText;

  /// v2: testo del bottone «Indietro».
  final String? backText;

  /// Larghezza sotto cui [CLSurveyViewerMode.auto] passa a una domanda per
  /// schermata.
  static const double pagedBreakpoint = 600;

  @override
  CLSurveyViewerState createState() => CLSurveyViewerState();

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

class CLSurveyViewerState extends State<CLSurveyViewer> {
  List<Question> questions = [];

  // ── Stato v2 ───────────────────────────────────────────────────────────
  CLSurveyResponse _response = const CLSurveyResponse();
  int _page = 0;
  final Set<String> _errorsVisible = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, GlobalKey> _questionKeys = {};
  Timer? _draftTimer;
  bool _submitAttempted = false;

  /// v2: risposta corrente (non ripulita), comprese le modifiche non ancora
  /// notificate da [CLSurveyViewer.onDraftChanged].
  CLSurveyResponse get currentResponse => _response;

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
    _response = widget.initialResponse ?? const CLSurveyResponse();
  }

  @override
  void didUpdateWidget(covariant CLSurveyViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.initialResponse;
    if (!identical(incoming, oldWidget.initialResponse) && incoming != null && incoming != _response) {
      _response = incoming;
      _textControllers.forEach((id, c) {
        final t = incoming.answers[id]?.text ?? '';
        if (c.text != t) c.text = t;
      });
    }
    final survey = widget.survey;
    if (survey != null) {
      final ids = survey.questions.map((q) => q.id).toSet();
      _textControllers.removeWhere((id, c) {
        if (ids.contains(id)) return false;
        c.dispose();
        return true;
      });
      _questionKeys.removeWhere((id, _) => !ids.contains(id));
      if (_page >= survey.questions.length) _page = survey.questions.isEmpty ? 0 : survey.questions.length - 1;
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _emitDraft({bool debounce = false}) {
    _draftTimer?.cancel();
    final cb = widget.onDraftChanged;
    if (cb == null) return;
    if (debounce && widget.draftDebounce > Duration.zero) {
      _draftTimer = Timer(widget.draftDebounce, () => cb(_response));
    } else {
      cb(_response);
    }
  }

  void _flushDraft() {
    if (_draftTimer?.isActive ?? false) _emitDraft();
  }

  void _setAnswer(CLSurveyQuestion question, CLSurveyAnswer? Function(CLSurveyAnswer? current) update, {bool debounce = false}) {
    // La nuova risposta si calcola sullo stato corrente, non su quello del
    // build: due tocchi prima del frame successivo non si perdono.
    setState(() => _response = _response.withAnswer(question.id, update(_response.answers[question.id])));
    _emitDraft(debounce: debounce);
  }

  TextEditingController _controllerFor(CLSurveyQuestion q) =>
      _textControllers.putIfAbsent(q.id, () => TextEditingController(text: _response.answers[q.id]?.text ?? ''));

  void _goTo(int page) {
    _flushDraft();
    FocusScope.of(context).unfocus();
    setState(() => _page = page);
  }

  void _next(CLSurvey survey) {
    final q = survey.questions[_page];
    if (q.validateAnswer(_response.answers[q.id]) != null) {
      setState(() => _errorsVisible.add(q.id));
      return;
    }
    _goTo(_page + 1);
  }

  Future<void> _submit(CLSurvey survey, bool paged) async {
    _flushDraft();
    final errors = survey.validateResponse(_response);
    if (errors.isNotEmpty) {
      setState(() {
        _submitAttempted = true;
        _errorsVisible.addAll(errors.keys);
        if (paged) _page = survey.questions.indexWhere((q) => errors.containsKey(q.id));
      });
      if (!paged) {
        final firstId = survey.questions.firstWhere((q) => errors.containsKey(q.id)).id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _questionKeys[firstId]?.currentContext;
          if (ctx != null && ctx.mounted) {
            Scrollable.ensureVisible(ctx, duration: CLTheme.of(ctx).durationBase, alignment: 0.1);
          }
        });
      }
      return;
    }
    await widget.onSubmit?.call(survey.sanitizeResponse(_response));
  }

  @override
  Widget build(BuildContext context) {
    final survey = widget.survey;
    if (survey != null) return _buildV2(context, survey);

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

  Widget _buildV2(BuildContext context, CLSurvey survey) {
    final theme = CLTheme.of(context);
    if (survey.questions.isEmpty) {
      return const CLEmptyState(
        title: 'Nessuna domanda',
        message: 'Il sondaggio non contiene domande.',
        icon: LucideIcons.listChecks,
        compact: true,
      );
    }
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final total = survey.questions.length;
    final answered = survey.questions.where((q) {
      final a = _response.answers[q.id];
      return a != null && !q.isAnswerEmpty(a);
    }).length;

    return LayoutBuilder(builder: (context, constraints) {
      final paged = !widget.readOnly &&
          (widget.mode == CLSurveyViewerMode.paged ||
              (widget.mode == CLSurveyViewerMode.auto && constraints.maxWidth < CLSurveyViewer.pagedBreakpoint));
      final bounded = constraints.hasBoundedHeight;
      final narrow = constraints.maxWidth < CLSurveyViewer.pagedBreakpoint;

      Widget card(CLSurveyQuestion q, int index) => _SurveyQuestionCard(
            key: _questionKeys.putIfAbsent(q.id, GlobalKey.new),
            question: q,
            index: index,
            total: total,
            showIndex: !paged,
            large: paged,
            answer: _response.answers[q.id],
            error: _errorsVisible.contains(q.id) ? q.validateAnswer(_response.answers[q.id]) : null,
            readOnly: widget.readOnly,
            textController: q.type == CLSurveyQuestionType.text && !widget.readOnly ? _controllerFor(q) : null,
            onChanged: (update, {bool debounce = false}) => _setAnswer(q, update, debounce: debounce),
          );

      final header = widget.showHeader
          ? Padding(
              padding: const EdgeInsets.only(bottom: Sizes.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          liveRegion: paged,
                          child: Text(
                            paged
                                ? 'Domanda ${_page + 1} di $total'
                                : widget.readOnly
                                    ? '$total ${total == 1 ? 'domanda' : 'domande'}'
                                    : '$answered di $total risposte',
                            style: theme.bodyLabel.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (paged)
                        Text('$answered/$total risposte', style: theme.smallLabel.copyWith(color: theme.mutedForeground)),
                    ],
                  ),
                  if (!widget.readOnly) ...[
                    const SizedBox(height: Sizes.gapSm),
                    Semantics(
                      label: 'Avanzamento',
                      value: paged ? '${_page + 1} di $total' : '$answered di $total',
                      child: ExcludeSemantics(
                        child: CLProgress(
                          value: paged ? (_page + 1) / total : answered / total,
                          variant: answered == total ? CLProgressVariant.success : CLProgressVariant.primary,
                          height: Sizes.gapSm,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink();

      final submitText = widget.saveText ?? 'Invia';

      if (paged) {
        final isLast = _page == total - 1;
        final q = survey.questions[_page];
        final body = AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : theme.durationBase,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, if (current != null) current],
          ),
          child: KeyedSubtree(key: ValueKey(q.id), child: card(q, _page)),
        );
        final nav = Padding(
          padding: const EdgeInsets.only(top: Sizes.gapLg),
          child: Row(
            children: [
              if (_page > 0)
                Expanded(
                  child: SizedBox(
                    height: Sizes.buttonHeightLarge,
                    child: CLOutlineButton.secondary(
                      text: widget.backText ?? 'Indietro',
                      onTap: () => _goTo(_page - 1),
                      context: context,
                    ),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: Sizes.gapMd),
              Expanded(
                child: SizedBox(
                  height: Sizes.buttonHeightLarge,
                  child: !isLast
                      ? CLButton.primary(
                          text: widget.nextText ?? 'Avanti',
                          icon: LucideIcons.chevronRight,
                          iconAlignment: IconAlignment.end,
                          fullWidth: true,
                          onTap: () => _next(survey),
                          context: context,
                        )
                      : widget.onSubmit != null
                          ? CLButton.primary(
                              text: submitText,
                              icon: LucideIcons.check,
                              fullWidth: true,
                              onTap: () => _submit(survey, true),
                              context: context,
                            )
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
        if (bounded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(child: SingleChildScrollView(child: body)),
              nav,
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, body, nav],
        );
      }

      final missing = _submitAttempted ? survey.validateResponse(_response).length : 0;
      final column = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          for (var i = 0; i < total; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == total - 1 ? 0 : Sizes.gapMd),
              child: card(survey.questions[i], i),
            ),
          if (!widget.readOnly && widget.onSubmit != null) ...[
            if (missing > 0)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.gapLg),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    missing == 1
                        ? 'Manca 1 risposta: controlla la domanda segnata.'
                        : 'Mancano $missing risposte: controlla le domande segnate.',
                    style: theme.smallText.copyWith(color: theme.danger),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: Sizes.gapLg),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: Sizes.buttonHeightLarge,
                  width: narrow ? double.infinity : null,
                  child: CLButton.primary(
                    text: submitText,
                    icon: LucideIcons.check,
                    fullWidth: narrow,
                    onTap: () => _submit(survey, false),
                    context: context,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
      return bounded ? SingleChildScrollView(child: column) : column;
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.padding * 2),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
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
              color: CLTheme.of(context).secondaryText.withValues(alpha: CLTheme.of(context).opacitySoft),
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
            style: CLTheme.of(context).heading5,
          ),
          const SizedBox(height: Sizes.padding / 2),
          Text(
            "Il questionario non contiene domande",
            style: CLTheme.of(context).smallText,
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
              color: CLTheme.of(context).primary.withValues(alpha: CLTheme.of(context).opacitySoft),
              borderRadius: BorderRadius.circular(Sizes.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedHelpCircle,
                  size: Sizes.iconSizeCompact,
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

typedef _AnswerChanged = void Function(CLSurveyAnswer? Function(CLSurveyAnswer? current) update, {bool debounce});

/// Card di una domanda v2: intestazione, controllo di risposta, errore.
class _SurveyQuestionCard extends StatelessWidget {
  const _SurveyQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.showIndex,
    required this.large,
    required this.answer,
    required this.error,
    required this.readOnly,
    required this.textController,
    required this.onChanged,
  });

  final CLSurveyQuestion question;
  final int index;
  final int total;
  final bool showIndex;
  final bool large;
  final CLSurveyAnswer? answer;
  final String? error;
  final bool readOnly;
  final TextEditingController? textController;
  final _AnswerChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final q = question;
    final selected = answer?.optionIds ?? const <String>[];
    final hasError = error != null;
    final answerText = answer?.text ?? '';

    final Widget control = switch (q.type) {
      CLSurveyQuestionType.singleChoice || CLSurveyQuestionType.multipleChoice => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == q.options.length - 1 ? 0 : Sizes.gapSm),
                child: _SurveyOptionTile(
                  label: q.options[i].label,
                  selected: selected.contains(q.options[i].id),
                  multiple: q.type == CLSurveyQuestionType.multipleChoice,
                  large: large,
                  onTap: readOnly
                      ? null
                      : () {
                          final id = q.options[i].id;
                          onChanged((current) {
                            final sel = current?.optionIds ?? const <String>[];
                            if (q.type == CLSurveyQuestionType.singleChoice) {
                              // Ritoccare la scelta la toglie, solo se la domanda è facoltativa.
                              return sel.contains(id) && !q.required ? null : CLSurveyAnswer(optionIds: [id]);
                            }
                            final next = sel.contains(id) ? (List.of(sel)..remove(id)) : [...sel, id];
                            return next.isEmpty ? null : CLSurveyAnswer(optionIds: next);
                          });
                        },
                ),
              ),
          ],
        ),
      CLSurveyQuestionType.scale => _SurveyScaleSelector(
          scale: q.scale,
          value: answer?.value,
          onChanged: readOnly ? null : (v) => onChanged((_) => CLSurveyAnswer(value: v)),
        ),
      CLSurveyQuestionType.text => readOnly
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Sizes.gapMd),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(Sizes.radiusControl),
                border: Border.all(color: theme.borderColor),
              ),
              child: Text(
                answerText.isEmpty ? 'Nessuna risposta' : answerText,
                style: theme.bodyText.copyWith(
                  color: answerText.isEmpty ? theme.secondaryText : theme.primaryText,
                  fontStyle: answerText.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CLTextField(
                  controller: textController!,
                  labelText: '',
                  hintText: 'Scrivi la tua risposta',
                  isTextArea: true,
                  inputType: TextInputType.multiline,
                  inputFormatters: q.maxLength != null ? [LengthLimitingTextInputFormatter(q.maxLength)] : null,
                  onChanged: (v) async => onChanged((_) => CLSurveyAnswer(text: v), debounce: true),
                ),
                if (q.maxLength != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Sizes.gapXs),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: textController!,
                      builder: (context, value, _) => Text(
                        '${value.text.length}/${q.maxLength}',
                        textAlign: TextAlign.end,
                        style: theme.smallLabel.copyWith(
                          color: value.text.length >= q.maxLength! ? theme.warning : theme.mutedForeground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    };

    return CLContainer(
      contentPadding: const EdgeInsets.all(Sizes.gapLg),
      backgroundColor:
          hasError ? Color.alphaBlend(theme.danger.withValues(alpha: theme.opacityFaint), theme.secondaryBackground) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showIndex)
            Padding(
              padding: const EdgeInsets.only(bottom: Sizes.gapXs),
              child: Text('Domanda ${index + 1} di $total', style: theme.smallLabel.copyWith(color: theme.mutedForeground)),
            ),
          Semantics(
            header: true,
            label: '${q.text}${q.required ? ' (obbligatoria)' : ''}',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: q.text),
                if (q.required) TextSpan(text: ' *', style: TextStyle(color: theme.danger)),
              ]),
              style: (large ? theme.heading4 : theme.title).copyWith(color: theme.primaryText, fontWeight: FontWeight.w600),
            ),
          ),
          if (q.help != null) ...[
            const SizedBox(height: Sizes.gapXs),
            Text(q.help!, style: theme.smallText.copyWith(color: theme.secondaryText)),
          ],
          if (q.type == CLSurveyQuestionType.multipleChoice && !readOnly) ...[
            const SizedBox(height: Sizes.gapXs),
            Text('Puoi scegliere più risposte', style: theme.smallLabel.copyWith(color: theme.mutedForeground)),
          ],
          const SizedBox(height: Sizes.gapMd),
          control,
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: Sizes.gapSm),
              child: Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.circleAlert, size: Sizes.iconSizeCompact, color: theme.danger),
                    const SizedBox(width: Sizes.gapSm),
                    Expanded(child: Text(error!, style: theme.smallText.copyWith(color: theme.danger))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Riga grande da toccare per un'opzione (radio o checkbox), ≥ 48 px.
class _SurveyOptionTile extends StatelessWidget {
  const _SurveyOptionTile({
    required this.label,
    required this.selected,
    required this.multiple,
    required this.large,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiple;
  final bool large;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final fast = reduceMotion ? Duration.zero : theme.durationFast;
    final enabled = onTap != null;

    return Semantics(
      checked: multiple ? selected : null,
      selected: multiple ? null : selected,
      inMutuallyExclusiveGroup: multiple ? null : true,
      button: enabled,
      enabled: enabled,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: CLPressable(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        enabled: enabled,
        semanticButton: false,
        builder: (context, state) => AnimatedContainer(
          duration: fast,
          constraints: const BoxConstraints(minHeight: Sizes.gap4Xl),
          padding: const EdgeInsets.all(Sizes.gapMd),
          decoration: BoxDecoration(
            color: selected
                ? theme.primary.withValues(alpha: theme.opacitySoft)
                : state.pressed
                    ? theme.controlFill
                    : state.hovered
                        ? theme.accent
                        : theme.primaryBackground,
            borderRadius: BorderRadius.circular(Sizes.radiusControl),
            border: Border.all(
              color: state.focused ? theme.ring : (selected ? theme.primary : theme.borderColor),
              width: selected || state.focused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: fast,
                width: Sizes.iconSizeDefault,
                height: Sizes.iconSizeDefault,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: multiple ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: multiple ? BorderRadius.circular(Sizes.radiusChip) : null,
                  color: selected ? theme.primary : Colors.transparent,
                  border: Border.all(color: selected ? theme.primary : theme.mutedForeground, width: 2),
                ),
                child: selected
                    ? (multiple
                        ? Icon(LucideIcons.check, size: Sizes.iconSizeCompact - Sizes.gapXs, color: theme.primaryForeground)
                        : Container(
                            width: Sizes.gapSm,
                            height: Sizes.gapSm,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primaryForeground),
                          ))
                    : null,
              ),
              const SizedBox(width: Sizes.gapMd),
              Expanded(
                child: Text(
                  label,
                  style: (large ? theme.title : theme.bodyText).copyWith(
                    color: enabled || selected ? theme.primaryText : theme.secondaryText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selettore della scala: un bottone per valore (48 px), in riga se c'è
/// spazio, altrimenti a capo; etichette degli estremi sotto.
class _SurveyScaleSelector extends StatelessWidget {
  const _SurveyScaleSelector({required this.scale, required this.value, required this.onChanged});

  final CLSurveyScale scale;
  final int? value;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final values = scale.values;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final enabled = onChanged != null;

    return LayoutBuilder(builder: (context, constraints) {
      const cell = Sizes.gap4Xl;
      const gap = Sizes.gapSm;
      final fitsRow = values.length * cell + (values.length - 1) * gap <= constraints.maxWidth;

      final buttons = [
        for (final v in values)
          Semantics(
            selected: v == value,
            inMutuallyExclusiveGroup: true,
            button: enabled,
            enabled: enabled,
            label: '$v su ${scale.max}${v == scale.min && scale.minLabel != null ? ', ${scale.minLabel}' : ''}'
                '${v == scale.max && scale.maxLabel != null ? ', ${scale.maxLabel}' : ''}',
            onTap: enabled ? () => onChanged!(v) : null,
            excludeSemantics: true,
            child: CLPressable(
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      onChanged!(v);
                    }
                  : null,
              enabled: enabled,
              semanticButton: false,
              builder: (context, state) => AnimatedContainer(
                duration: reduceMotion ? Duration.zero : theme.durationFast,
                height: cell,
                width: fitsRow ? null : cell,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v == value
                      ? theme.primary
                      : state.pressed
                          ? theme.controlFill
                          : state.hovered
                              ? theme.accent
                              : theme.primaryBackground,
                  borderRadius: BorderRadius.circular(Sizes.radiusControl),
                  border: Border.all(
                    color: state.focused ? theme.ring : (v == value ? theme.primary : theme.borderColor),
                    width: state.focused ? 2 : 1,
                  ),
                ),
                child: Text(
                  '$v',
                  style: theme.title.copyWith(
                    fontWeight: FontWeight.w600,
                    color: v == value ? theme.primaryForeground : (enabled ? theme.primaryText : theme.secondaryText),
                  ),
                ),
              ),
            ),
          ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fitsRow)
            Row(
              children: [
                for (var i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(child: buttons[i]),
                ],
              ],
            )
          else
            Wrap(spacing: gap, runSpacing: gap, children: buttons),
          if (scale.minLabel != null || scale.maxLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: Sizes.gapSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      scale.minLabel != null ? '${scale.min} = ${scale.minLabel}' : '',
                      style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                    ),
                  ),
                  const SizedBox(width: Sizes.gapMd),
                  Expanded(
                    child: Text(
                      scale.maxLabel != null ? '${scale.max} = ${scale.maxLabel}' : '',
                      textAlign: TextAlign.end,
                      style: theme.smallLabel.copyWith(color: theme.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
