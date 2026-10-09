import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';
import 'package:genai_components/widgets/cl_survey/cl_survey_builder.widget.dart';
import 'package:genai_components/widgets/cl_survey/cl_survey_result_viewer.widget.dart';
import 'package:genai_components/widgets/cl_survey/cl_survey_viewer.widget.dart';
import 'package:genai_components/widgets/cl_survey/models/cl_survey.model.dart';
import 'package:genai_components/widgets/cl_survey/models/option.dart';
import 'package:genai_components/widgets/cl_survey/models/question.dart';
import 'package:genai_components/widgets/cl_survey/models/question_result.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _survey = CLSurvey(questions: [
  CLSurveyQuestion(
    id: 'q1',
    type: CLSurveyQuestionType.singleChoice,
    text: 'Il corso ti è stato utile per il tuo lavoro di tutti i giorni in azienda?',
    help: 'Pensa alle ultime settimane',
    required: true,
    options: [
      CLSurveyOption(id: 'si', label: 'Sì, molto: lo uso già e lo consiglierei ai colleghi del reparto'),
      CLSurveyOption(id: 'no', label: 'No'),
    ],
  ),
  CLSurveyQuestion(
    id: 'q2',
    type: CLSurveyQuestionType.multipleChoice,
    text: 'Cosa ti è piaciuto?',
    options: [CLSurveyOption(id: 'a', label: 'Docente'), CLSurveyOption(id: 'b', label: 'Materiali')],
  ),
  CLSurveyQuestion(
    id: 'q3',
    type: CLSurveyQuestionType.scale,
    text: 'Quanto lo consiglieresti?',
    required: true,
    scale: CLSurveyScale(min: 0, max: 10, minLabel: 'Per niente', maxLabel: 'Moltissimo'),
  ),
  CLSurveyQuestion(id: 'q4', type: CLSurveyQuestionType.text, text: 'Suggerimenti', maxLength: 200),
]);

Finder _iconButton(String tooltip) => find.byWidgetPredicate((w) => w is CLIconButton && w.tooltip == tooltip);

const _phones = [Size(360, 740), Size(390, 844), Size(740, 360)];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(360, 740),
  Brightness brightness = Brightness.light,
  bool scroll = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final theme = brightness == Brightness.dark ? CLTheme.dark : CLTheme.light;
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: brightness),
    builder: (context, c) => ResponsiveBreakpoints.builder(
      child: c!,
      breakpoints: const [
        Breakpoint(start: 0, end: 800, name: MOBILE),
        Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
      ],
    ),
    home: ShadTheme(
      data: theme.toShadTheme(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: scroll ? SingleChildScrollView(child: child) : child,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('CLSurveyViewer v2', () {
    for (final size in _phones) {
      testWidgets('una domanda per schermata a ${size.width.toInt()}×${size.height.toInt()}: niente overflow, flusso completo',
          (tester) async {
        final drafts = <CLSurveyResponse>[];
        CLSurveyResponse? submitted;
        await _pump(
          tester,
          CLSurveyViewer(
            survey: _survey,
            onDraftChanged: drafts.add,
            onSubmit: (r) => submitted = r,
            draftDebounce: Duration.zero,
          ),
          size: size,
        );
        // In orizzontale (740 px) la larghezza supera il breakpoint: tutte in pagina.
        if (size.width >= CLSurveyViewer.pagedBreakpoint) {
          expect(find.text('Domanda 1 di 4'), findsOneWidget);
          expect(find.text('Invia'), findsOneWidget);
          return;
        }
        expect(tester.takeException(), isNull);
        expect(find.text('Domanda 1 di 4'), findsOneWidget);

        // Avanti senza risposta su obbligatoria → errore, resta sulla 1.
        await tester.tap(find.text('Avanti'));
        await tester.pumpAndSettle();
        expect(find.text('Questa domanda è obbligatoria.'), findsOneWidget);
        expect(find.text('Domanda 1 di 4'), findsOneWidget);

        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();
        expect(find.text('Questa domanda è obbligatoria.'), findsNothing);
        expect(drafts.last.answers['q1']!.optionIds, ['no']);

        await tester.tap(find.text('Avanti'));
        await tester.pumpAndSettle();
        expect(find.text('Domanda 2 di 4'), findsOneWidget);
        await tester.tap(find.text('Docente'));
        await tester.tap(find.text('Materiali'));
        await tester.pumpAndSettle();
        expect(drafts.last.answers['q2']!.optionIds, ['a', 'b']);

        await tester.tap(find.text('Avanti'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'scala 0–10 deve andare a capo senza overflow');
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Avanti'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText), 'Più pratica');
        await tester.pumpAndSettle();
        expect(find.text('11/200'), findsOneWidget);

        await tester.tap(find.text('Invia'));
        await tester.pumpAndSettle();
        expect(submitted, isNotNull);
        expect(submitted!.answers['q3']!.value, 8);
        expect(submitted!.answers['q4']!.text, 'Più pratica');

        // Indietro mantiene le risposte.
        await tester.tap(find.text('Indietro'));
        await tester.pumpAndSettle();
        expect(find.text('Domanda 3 di 4'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('aree di tocco ≥ 44 px (iOS) sulla domanda a scelta', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, CLSurveyViewer(survey: _survey, onSubmit: (_) {}), size: const Size(390, 844));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('dentro uno scroll (altezza libera) e in dark mode: niente overflow', (tester) async {
      await _pump(tester, CLSurveyViewer(survey: _survey, onSubmit: (_) {}),
          scroll: true, brightness: Brightness.dark);
      expect(tester.takeException(), isNull);
      expect(find.text('Avanti'), findsOneWidget);
    });

    testWidgets('tutte in una pagina: invio bloccato con errori sulle obbligatorie', (tester) async {
      var calls = 0;
      await _pump(tester, CLSurveyViewer(survey: _survey, onSubmit: (_) => calls++), size: const Size(1200, 900));
      expect(find.text('Domanda 4 di 4'), findsOneWidget);
      await tester.ensureVisible(find.text('Invia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invia'));
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.text('Questa domanda è obbligatoria.'), findsNWidgets(2));
      expect(find.text('Mancano 2 risposte: controlla le domande segnate.'), findsOneWidget);
    });

    testWidgets('bozza del testo con attesa', (tester) async {
      final drafts = <CLSurveyResponse>[];
      await _pump(
        tester,
        CLSurveyViewer(survey: _survey, mode: CLSurveyViewerMode.all, onDraftChanged: drafts.add),
        size: const Size(1200, 900),
      );
      await tester.enterText(find.byType(EditableText), 'ciao');
      await tester.pump(const Duration(milliseconds: 100));
      expect(drafts, isEmpty);
      await tester.pump(const Duration(milliseconds: 600));
      expect(drafts.single.answers['q4']!.text, 'ciao');
    });

    testWidgets('sola lettura: risposte visibili, niente bottoni', (tester) async {
      await _pump(
        tester,
        const CLSurveyViewer(
          survey: _survey,
          readOnly: true,
          initialResponse: CLSurveyResponse(answers: {
            'q1': CLSurveyAnswer(optionIds: ['no']),
            'q4': CLSurveyAnswer(text: 'Tutto bene'),
          }),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Tutto bene'), findsOneWidget);
      expect(find.text('Invia'), findsNothing);
      expect(find.text('Avanti'), findsNothing);
    });
  });

  group('CLSurveyBuilder v2', () {
    for (final size in [const Size(360, 740), const Size(390, 844), const Size(1200, 900)]) {
      testWidgets('a ${size.width.toInt()} px: niente overflow', (tester) async {
        await _pump(tester, CLSurveyBuilder(survey: _survey, onChanged: (_) {}), size: size, scroll: true);
        expect(tester.takeException(), isNull);
        expect(find.text('Domanda 4'), findsOneWidget);
      });
    }

    testWidgets('aggiungi, duplica, sposta, elimina, modifica testo', (tester) async {
      CLSurvey? last;
      await _pump(
        tester,
        CLSurveyBuilder(survey: _survey, onChanged: (s) => last = s),
        size: const Size(1200, 2400),
        scroll: true,
      );
      await tester.tap(find.text('Aggiungi domanda'));
      await tester.pumpAndSettle();
      expect(last!.questions, hasLength(5));
      expect(last!.questions.last.type, CLSurveyQuestionType.text);

      await tester.tap(_iconButton('Duplica').first);
      await tester.pumpAndSettle();
      expect(last!.questions, hasLength(6));
      expect(last!.questions[1].text, last!.questions[0].text);
      expect(last!.questions[1].id, isNot(last!.questions[0].id));

      await tester.tap(_iconButton('Sposta giù').first);
      await tester.pumpAndSettle();
      expect(last!.questions[1].id, 'q1');

      await tester.tap(_iconButton('Elimina').first);
      await tester.pumpAndSettle();
      expect(last!.questions, hasLength(5));
      expect(last!.questions.first.id, 'q1');

      await tester.enterText(find.byWidgetPredicate((w) => w is EditableText && w.controller.text == _survey.questions.first.text).first, 'Nuovo testo');
      await tester.pumpAndSettle();
      expect(last!.questions.first.text, 'Nuovo testo');
      expect(tester.takeException(), isNull);
    });

    testWidgets('validazione visibile con showValidation', (tester) async {
      await _pump(
        tester,
        CLSurveyBuilder(
          survey: const CLSurvey(questions: [
            CLSurveyQuestion(id: 'x', type: CLSurveyQuestionType.scale, scale: CLSurveyScale(min: 5, max: 3)),
          ]),
          showValidation: true,
          onChanged: (_) {},
        ),
        size: const Size(1200, 1200),
        scroll: true,
      );
      expect(find.text('Scrivi il testo della domanda.'), findsOneWidget);
      expect(find.text('Il minimo della scala deve essere minore del massimo.'), findsOneWidget);
      expect(find.text('2 problemi da correggere prima di pubblicare.'), findsOneWidget);
    });

    testWidgets('anteprima', (tester) async {
      await _pump(tester, CLSurveyBuilder(survey: _survey, onChanged: (_) {}), size: const Size(1200, 2400), scroll: true);
      await tester.tap(find.text('Anteprima'));
      await tester.pumpAndSettle();
      expect(find.byType(CLSurveyViewer), findsOneWidget);
      expect(find.text('Invia'), findsNothing);
    });
  });

  group('CLSurveyResultViewer v2', () {
    final responses = [
      for (var i = 0; i < 7; i++)
        CLSurveyResponse(answers: {
          'q1': CLSurveyAnswer(optionIds: [i.isEven ? 'si' : 'no']),
          'q3': CLSurveyAnswer(value: i),
          'q4': CLSurveyAnswer(text: 'Testo $i'),
        }),
    ];

    for (final size in [const Size(360, 740), const Size(390, 844)]) {
      testWidgets('riepilogo a ${size.width.toInt()} px: niente overflow, conteggi e testi paginati', (tester) async {
        await _pump(tester, CLSurveyResultViewer.summary(survey: _survey, responses: responses), size: size, scroll: true);
        expect(tester.takeException(), isNull);
        expect(find.text('7 risposte · 4 domande'), findsOneWidget);
        expect(find.text('4 · 57%'), findsOneWidget);
        expect(find.text('3,0'), findsOneWidget);
        expect(find.text('Testo 4'), findsOneWidget);
        expect(find.text('Testo 5'), findsNothing);
      });
    }

    testWidgets('singola risposta', (tester) async {
      await _pump(tester, CLSurveyResultViewer.response(survey: _survey, response: responses[3]), scroll: true);
      expect(tester.takeException(), isNull);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('3 su 10'), findsOneWidget);
      expect(find.text('Nessuna risposta'), findsOneWidget);
    });

    testWidgets('nessuna risposta: stato vuoto', (tester) async {
      await _pump(tester, CLSurveyResultViewer.summary(survey: _survey, responses: const []));
      expect(find.text('Ancora nessuna risposta'), findsOneWidget);
    });
  });

  group('legacy invariato', () {
    final legacy = [
      Question(question: 'Ti piace?', isStarRating: false, options: [Option(id: 'y', text: 'Sì'), Option(id: 'n', text: 'No')]),
    ];

    testWidgets('CLSurveyViewer.fromArray + onSave', (tester) async {
      List<QuestionResult>? saved;
      await _pump(tester, CLSurveyViewer.fromArray(questions: legacy, onSave: (r) => saved = r), size: const Size(1200, 900));
      expect(find.text('1 domanda'), findsOneWidget);
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();
      expect(saved, isNotNull);
    });

    testWidgets('CLSurveyResultViewer.fromJson ora mostra i risultati', (tester) async {
      await _pump(
        tester,
        CLSurveyResultViewer.fromJson(surveyJson: [
          QuestionResult(question: 'Ti piace?', answers: [
            {'y': 'Sì'},
          ]).toJson(),
        ]),
        size: const Size(1200, 900),
        scroll: true,
      );
      expect(find.text('Ti piace?'), findsOneWidget);
    });

    testWidgets('CLSurveyBuilder.fromArray', (tester) async {
      var calls = 0;
      await _pump(tester, CLSurveyBuilder.fromArray(questions: legacy, onSurveyChange: (_) => calls++),
          size: const Size(1200, 900), scroll: true);
      expect(calls, greaterThan(0));
      expect(find.text('Aggiungi domanda'), findsOneWidget);
    });
  });
}
