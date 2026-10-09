import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/cl_survey/models/cl_survey.model.dart';
import 'package:genai_components/widgets/cl_survey/models/option.dart';
import 'package:genai_components/widgets/cl_survey/models/question.dart';

// Domande collegate (options[].nested) e tipo `select`.
const _figura = CLSurveyQuestion(
  id: 'figura',
  type: CLSurveyQuestionType.select,
  text: 'Quale figura?',
  required: true,
  options: [
    CLSurveyOption(id: 'p1_contabile', label: 'Contabile'),
    CLSurveyOption(id: 'p4_sviluppatore', label: 'Sviluppatore'),
    CLSurveyOption(id: 'altro', label: 'Altro', nested: [
      CLSurveyQuestion(id: 'figura_altro', type: CLSurveyQuestionType.text, text: 'Indica la tua figura', required: true, maxLength: 20),
    ]),
  ],
);
const _q1 = CLSurveyQuestion(
  id: 'q1',
  type: CLSurveyQuestionType.singleChoice,
  text: 'Usi ChatGPT?',
  required: true,
  options: [CLSurveyOption(id: 'si', label: 'Sì'), CLSurveyOption(id: 'no', label: 'No')],
);
const _survey = CLSurvey(questions: [_figura, _q1]);

void main() {
  group('JSON', () {
    test('round-trip con nested e select; nested solo dove serve', () {
      final json = _survey.toJson();
      final opts = (json['questions'] as List)[0]['options'] as List;
      expect(opts[0].containsKey('nested'), isFalse);
      expect((opts[2]['nested'] as List).single['id'], 'figura_altro');
      expect((opts[2]['nested'] as List).single['order'], 0);
      expect((json['questions'] as List)[0]['type'], 'select');
      final back = CLSurvey.fromJson(jsonDecode(jsonEncode(json)));
      expect(back, _survey);
      expect(jsonEncode(back.toJson()), jsonEncode(json));
    });

    test('schema v2 senza nested: JSON identico a prima', () {
      const plain = CLSurvey(questions: [_q1]);
      expect(jsonEncode(plain.toJson()),
          '{"schemaVersion":2,"questions":[{"id":"q1","type":"singleChoice","order":0,"text":"Usi ChatGPT?","help":null,"required":true,"options":[{"id":"si","label":"Sì"},{"id":"no","label":"No"}]}]}');
    });

    test('id duplicati fra principale e collegata vengono rigenerati', () {
      final s = CLSurvey.fromJson({
        'schemaVersion': 2,
        'questions': [
          {
            'id': 'a',
            'type': 'singleChoice',
            'text': 'A',
            'options': [
              {'id': 'x', 'label': 'X', 'nested': [
                {'id': 'a', 'type': 'text', 'text': 'figlia'},
              ]},
              {'id': 'y', 'label': 'Y'},
            ],
          },
        ],
      });
      final ids = s.allQuestions.map((q) => q.id).toList();
      expect(ids.first, 'a');
      expect(ids.toSet().length, 2);
      expect(s.nodes[1].depth, 1);
      expect(s.nodes[1].parentOption!.id, 'x');
    });

    test('legacy: le subordinate diventano collegate (un livello)', () {
      final legacy = [
        Question(question: 'Ti piace?', isStarRating: false, options: [
          Option(id: 'y', text: 'Sì'),
          Option(id: 'n', text: 'No', nested: [Question(question: 'Perché?', isStarRating: false)]),
        ]),
      ];
      final s = CLSurvey.fromJson(legacy.map((q) => q.toJson()).toList());
      expect(s.questions.single.options[1].nested.single.id, 'legacy_q1_2_1');
      expect(s.questions.single.options[1].nested.single.type, CLSurveyQuestionType.text);
    });

    test('duplicate rigenera anche gli id delle collegate', () {
      final d = _figura.duplicate();
      expect(d.options[2].nested.single.id, isNot('figura_altro'));
      expect(d.options[2].nested.single.text, 'Indica la tua figura');
    });
  });

  group('validazione dello schema', () {
    test('le collegate si validano; niente collegate sotto le collegate', () {
      const s = CLSurvey(questions: [
        CLSurveyQuestion(id: 'a', type: CLSurveyQuestionType.singleChoice, text: 'A', options: [
          CLSurveyOption(id: 'x', label: 'X', nested: [
            CLSurveyQuestion(id: 'b', type: CLSurveyQuestionType.singleChoice, text: '', options: [
              CLSurveyOption(id: 'k', label: 'K', nested: [CLSurveyQuestion(id: 'c', type: CLSurveyQuestionType.text, text: 'C')]),
              CLSurveyOption(id: 'j', label: 'J'),
            ]),
          ]),
          CLSurveyOption(id: 'y', label: 'Y'),
        ]),
      ]);
      final issues = s.validate();
      expect(issues.where((i) => i.questionId == 'b' && i.field == CLSurveyIssueField.text), hasLength(1));
      expect(issues.where((i) => i.questionId == 'b' && i.optionId == 'k'), hasLength(1));
      expect(s.isValid, isFalse);
      expect(_survey.isValid, isTrue);
    });

    test('limiti di opzioni: 50 per le scelte, 200 per il select', () {
      List<CLSurveyOption> opts(int n) => [for (var i = 0; i < n; i++) CLSurveyOption(id: 'o$i', label: 'O$i')];
      expect(CLSurveyQuestion(id: 'a', type: CLSurveyQuestionType.singleChoice, text: 'A', options: opts(51)).validate(), isNotEmpty);
      expect(CLSurveyQuestion(id: 'a', type: CLSurveyQuestionType.select, text: 'A', options: opts(200)).validate(), isEmpty);
      expect(CLSurveyQuestion(id: 'a', type: CLSurveyQuestionType.select, text: 'A', options: opts(201)).validate(), isNotEmpty);
    });
  });

  group('risposte', () {
    test('la collegata è obbligatoria solo se visibile', () {
      const base = CLSurveyResponse(answers: {
        'figura': CLSurveyAnswer(optionIds: ['p1_contabile']),
        'q1': CLSurveyAnswer(optionIds: ['si']),
      });
      expect(_survey.validateResponse(base), isEmpty);
      expect(_survey.visibleNodes(base).map((n) => n.question.id), ['figura', 'q1']);

      final altro = base.withAnswer('figura', const CLSurveyAnswer(optionIds: ['altro']));
      expect(_survey.visibleNodes(altro).map((n) => n.question.id), ['figura', 'figura_altro', 'q1']);
      expect(_survey.validateResponse(altro).keys, ['figura_altro']);
      expect(_survey.validateResponse(altro.withAnswer('figura_altro', const CLSurveyAnswer(text: 'Grafico'))), isEmpty);
    });

    test('sanitize scarta le risposte alle collegate nascoste', () {
      const r = CLSurveyResponse(answers: {
        'figura': CLSurveyAnswer(optionIds: ['p1_contabile']),
        'figura_altro': CLSurveyAnswer(text: 'Grafico'),
        'q1': CLSurveyAnswer(optionIds: ['si']),
      });
      expect(_survey.sanitizeResponse(r).answers.keys, ['figura', 'q1']);
      final shown = r.withAnswer('figura', const CLSurveyAnswer(optionIds: ['altro']));
      expect(_survey.sanitizeResponse(shown).answers.keys, ['figura', 'figura_altro', 'q1']);
    });

    test('select: una sola opzione', () {
      expect(_figura.validateAnswer(const CLSurveyAnswer(optionIds: ['p1_contabile', 'altro'])), 'Scegli una sola risposta.');
      expect(_figura.sanitizeAnswer(const CLSurveyAnswer(optionIds: ['zzz', 'p1_contabile', 'altro']))!.optionIds, ['p1_contabile']);
    });

    test('riepilogo: collegate dopo la principale, contate solo se visibili', () {
      final s = CLSurveySummary.compute(_survey, const [
        CLSurveyResponse(answers: {
          'figura': CLSurveyAnswer(optionIds: ['altro']),
          'figura_altro': CLSurveyAnswer(text: 'Grafico'),
        }),
        CLSurveyResponse(answers: {
          'figura': CLSurveyAnswer(optionIds: ['p1_contabile']),
          'figura_altro': CLSurveyAnswer(text: 'Nascosta'),
        }),
      ]);
      expect(s.questions.map((q) => q.question.id), ['figura', 'figura_altro', 'q1']);
      expect(s.questions[0].optionCounts, {'p1_contabile': 1, 'p4_sviluppatore': 0, 'altro': 1});
      expect(s.questions[1].depth, 1);
      expect(s.questions[1].parentOption!.id, 'altro');
      expect(s.questions[1].texts, ['Grafico']);
    });
  });
}
