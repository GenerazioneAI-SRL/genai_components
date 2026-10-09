import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/cl_survey/cl_survey_builder.widget.dart';
import 'package:genai_components/widgets/cl_survey/cl_survey_result_viewer.widget.dart';
import 'package:genai_components/widgets/cl_survey/cl_survey_viewer.widget.dart';
import 'package:genai_components/widgets/cl_survey/models/cl_survey.model.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Domande collegate e tipo `select` nei widget.
final _survey = CLSurvey(questions: [
  CLSurveyQuestion(
    id: 'figura',
    type: CLSurveyQuestionType.select,
    text: 'Quale figura professionale occupi?',
    required: true,
    options: [
      for (var i = 0; i < 40; i++) CLSurveyOption(id: 'f$i', label: 'Figura numero $i'),
      const CLSurveyOption(id: 'contabile', label: 'Contabile / addetto contabilità'),
      const CLSurveyOption(id: 'altro', label: 'Altro / non trovo la mia figura', nested: [
        CLSurveyQuestion(id: 'figura_altro', type: CLSurveyQuestionType.text, text: 'Indica la tua figura', required: true, maxLength: 200),
      ]),
    ],
  ),
  const CLSurveyQuestion(
    id: 'q1',
    type: CLSurveyQuestionType.singleChoice,
    text: 'Usi ChatGPT?',
    required: true,
    options: [CLSurveyOption(id: 'si', label: 'Sì'), CLSurveyOption(id: 'no', label: 'No')],
  ),
]);

Future<void> _pump(WidgetTester tester, Widget child, {Size size = const Size(360, 740), bool scroll = false}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    builder: (context, c) => ResponsiveBreakpoints.builder(
      child: c!,
      breakpoints: const [
        Breakpoint(start: 0, end: 800, name: MOBILE),
        Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
      ],
    ),
    home: ShadTheme(
      data: CLTheme.light.toShadTheme(),
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

Future<void> _pick(WidgetTester tester, String search, String label) async {
  await tester.tap(find.byWidgetPredicate((w) => w is ShadSelect<CLSurveyOption>));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(EditableText).last, search);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('select con ricerca e collegata: compare con «Altro», obbligatoria solo se visibile', (tester) async {
    CLSurveyResponse? submitted;
    await _pump(tester, CLSurveyViewer(survey: _survey, onSubmit: (r) => submitted = r, draftDebounce: Duration.zero));
    expect(find.text('Domanda 1 di 2'), findsOneWidget);
    expect(find.textContaining('Indica la tua figura'), findsNothing);

    // La ricerca ignora maiuscole e accenti.
    await _pick(tester, 'CONTABILITA', 'Contabile / addetto contabilità');
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Indica la tua figura'), findsNothing);

    await _pick(tester, 'altro', 'Altro / non trovo la mia figura');
    expect(find.textContaining('Indica la tua figura'), findsOneWidget);
    expect(find.text('0/1 risposte'), findsNothing);
    expect(find.text('1/3 risposte'), findsOneWidget);

    // Avanti con la collegata vuota: errore sulla collegata, resta qui.
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
    expect(find.text('Questa domanda è obbligatoria.'), findsOneWidget);
    expect(find.text('Domanda 1 di 2'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'Grafico');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sì'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invia'));
    await tester.pumpAndSettle();
    expect(submitted!.answers.keys, ['figura', 'figura_altro', 'q1']);
    expect(submitted!.answers['figura_altro']!.text, 'Grafico');
    expect(tester.takeException(), isNull);
  });

  testWidgets('collegata nascosta: la risposta resta in bozza ma non viene inviata', (tester) async {
    CLSurveyResponse? submitted;
    await _pump(
      tester,
      CLSurveyViewer(
        survey: _survey,
        mode: CLSurveyViewerMode.all,
        onSubmit: (r) => submitted = r,
        initialResponse: const CLSurveyResponse(answers: {
          'figura': CLSurveyAnswer(optionIds: ['contabile']),
          'figura_altro': CLSurveyAnswer(text: 'Vecchia'),
          'q1': CLSurveyAnswer(optionIds: ['no']),
        }),
      ),
      size: const Size(1200, 900),
    );
    expect(find.textContaining('Indica la tua figura'), findsNothing);
    await tester.tap(find.text('Invia'));
    await tester.pumpAndSettle();
    expect(submitted!.answers.keys, ['figura', 'q1']);
  });

  testWidgets('la schermata successiva si apre dall\'inizio (non già scrollata)', (tester) async {
    final long = CLSurvey(questions: [
      for (var i = 0; i < 2; i++)
        CLSurveyQuestion(
          id: 'q$i',
          type: CLSurveyQuestionType.singleChoice,
          text: 'Domanda lunga $i',
          options: [for (var k = 0; k < 15; k++) CLSurveyOption(id: 'o$k', label: 'Opzione $i.$k')],
        ),
    ]);
    await _pump(tester, CLSurveyViewer(survey: long, onSubmit: (_) {}));
    final scrollable = find.descendant(of: find.byType(CLSurveyViewer), matching: find.byType(Scrollable)).first;
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, greaterThan(0));
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
    expect(find.text('Domanda 2 di 2'), findsOneWidget);
    expect(tester.state<ScrollableState>(scrollable).position.pixels, 0);
  });

  testWidgets('dentro uno scroll del genitore: la cima della schermata nuova torna in vista', (tester) async {
    final long = CLSurvey(questions: [
      for (var i = 0; i < 2; i++)
        CLSurveyQuestion(
          id: 'q$i',
          type: CLSurveyQuestionType.singleChoice,
          text: 'Domanda lunga $i',
          options: [for (var k = 0; k < 15; k++) CLSurveyOption(id: 'o$k', label: 'Opzione $i.$k')],
        ),
    ]);
    await _pump(tester, CLSurveyViewer(survey: long, onSubmit: (_) {}), scroll: true);
    await tester.ensureVisible(find.text('Avanti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(find.text('Domanda 2 di 2'));
    expect(top.dy, greaterThanOrEqualTo(0));
    expect(top.dy, lessThan(740));
  });

  testWidgets('sola lettura: select e collegata visibili', (tester) async {
    await _pump(
      tester,
      CLSurveyViewer(
        survey: _survey,
        readOnly: true,
        initialResponse: const CLSurveyResponse(answers: {
          'figura': CLSurveyAnswer(optionIds: ['altro']),
          'figura_altro': CLSurveyAnswer(text: 'Grafico'),
        }),
      ),
      scroll: true,
    );
    expect(find.text('Altro / non trovo la mia figura'), findsOneWidget);
    expect(find.text('Grafico'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('builder: aggiunge una domanda collegata a un\'opzione e il tipo select', (tester) async {
    CLSurvey? last;
    await _pump(
      tester,
      CLSurveyBuilder(
        survey: const CLSurvey(questions: [
          CLSurveyQuestion(
            id: 'a',
            type: CLSurveyQuestionType.select,
            text: 'Figura',
            options: [CLSurveyOption(id: 'x', label: 'X'), CLSurveyOption(id: 'y', label: 'Altro')],
          ),
        ]),
        onChanged: (s) => last = s,
      ),
      size: const Size(390, 2400),
      scroll: true,
    );
    expect(find.text('Opzioni (2/200)'), findsOneWidget);
    await tester.tap(find.text('Domanda se scelta').last);
    await tester.pumpAndSettle();
    expect(last!.questions.single.options[1].nested, hasLength(1));
    expect(find.text('Domanda collegata 1'), findsOneWidget);
    expect(last!.allQuestions, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('risultati: collegata rientrata, select con le sole opzioni scelte', (tester) async {
    await _pump(
      tester,
      CLSurveyResultViewer.summary(survey: _survey, responses: const [
        CLSurveyResponse(answers: {
          'figura': CLSurveyAnswer(optionIds: ['altro']),
          'figura_altro': CLSurveyAnswer(text: 'Grafico'),
          'q1': CLSurveyAnswer(optionIds: ['si']),
        }),
        CLSurveyResponse(answers: {
          'figura': CLSurveyAnswer(optionIds: ['contabile']),
          'q1': CLSurveyAnswer(optionIds: ['no']),
        }),
      ]),
      scroll: true,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Domanda 1 · se «Altro / non trovo la mia figura»'), findsOneWidget);
    expect(find.text('Grafico'), findsOneWidget);
    expect(find.text('Figura numero 3'), findsNothing);
    expect(find.text('Elenco a tendina: sono mostrate solo le 2 opzioni scelte su 42.'), findsOneWidget);
  });
}
