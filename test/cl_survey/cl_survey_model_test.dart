import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/cl_survey/models/cl_survey.model.dart';
import 'package:genai_components/widgets/cl_survey/models/option.dart';
import 'package:genai_components/widgets/cl_survey/models/question.dart';

const _single = CLSurveyQuestion(
  id: 'q1',
  type: CLSurveyQuestionType.singleChoice,
  text: 'Utile?',
  required: true,
  options: [CLSurveyOption(id: 'o1', label: 'Sì'), CLSurveyOption(id: 'o2', label: 'No')],
);
const _multi = CLSurveyQuestion(
  id: 'q2',
  type: CLSurveyQuestionType.multipleChoice,
  text: 'Cosa ti è piaciuto?',
  options: [
    CLSurveyOption(id: 'a', label: 'Docente'),
    CLSurveyOption(id: 'b', label: 'Materiali'),
    CLSurveyOption(id: 'c', label: 'Aula'),
  ],
);
const _scale = CLSurveyQuestion(
  id: 'q3',
  type: CLSurveyQuestionType.scale,
  text: 'Voto',
  help: 'Da 1 a 5',
  scale: CLSurveyScale(min: 1, max: 5, minLabel: 'Male', maxLabel: 'Bene'),
);
const _text = CLSurveyQuestion(id: 'q4', type: CLSurveyQuestionType.text, text: 'Note', maxLength: 10);
const _survey = CLSurvey(questions: [_single, _multi, _scale, _text]);

void main() {
  group('JSON schema v2', () {
    test('round-trip stabile, chiavi del solo tipo, order e schemaVersion', () {
      final json = _survey.toJson();
      expect(json['schemaVersion'], 2);
      final qs = json['questions'] as List;
      expect(qs.map((q) => q['order']), [0, 1, 2, 3]);
      expect(qs[0].containsKey('scale'), isFalse);
      expect(qs[0].containsKey('maxLength'), isFalse);
      expect(qs[2]['scale'], {'min': 1, 'max': 5, 'minLabel': 'Male', 'maxLabel': 'Bene'});
      expect(qs[2].containsKey('options'), isFalse);
      expect(qs[3]['maxLength'], 10);

      final back = CLSurvey.fromJson(jsonDecode(jsonEncode(json)));
      expect(back, _survey);
      expect(jsonEncode(back.toJson()), jsonEncode(json));
    });

    test('ordina per order e rigenera id mancanti o duplicati', () {
      final s = CLSurvey.fromJson({
        'schemaVersion': 2,
        'questions': [
          {'id': 'x', 'type': 'text', 'order': 1, 'text': 'B'},
          {'id': 'x', 'type': 'singleChoice', 'order': 0, 'text': 'A', 'options': [
            {'id': 'o', 'label': '1'},
            {'id': 'o', 'label': '2'},
          ]},
          {'type': 'boh', 'text': 'C'},
        ],
      });
      expect(s.questions.map((q) => q.text), ['A', 'B', 'C']);
      expect(s.questions.map((q) => q.id).toSet().length, 3);
      expect(s.questions[0].id, 'x');
      expect(s.questions[0].options.map((o) => o.id).toSet().length, 2);
      expect(s.questions[2].type, CLSurveyQuestionType.text);
    });

    test('legge il formato legacy (lista di Question)', () {
      final legacy = [
        Question(question: 'Scelta', isStarRating: false, options: [Option(id: 'l1', text: 'A'), Option(id: 'l2', text: 'B')]),
        Question(question: 'Multipla', singleChoice: false, isStarRating: false, options: [Option(id: 'm1', text: 'X'), Option(id: 'm2', text: 'Y')]),
        Question(question: 'Stelle', isStarRating: true, isMandatory: true),
        Question(question: 'Testo', isStarRating: false),
      ];
      final s = CLSurvey.fromJson(legacy.map((q) => q.toJson()).toList());
      expect(s.questions.map((q) => q.type), [
        CLSurveyQuestionType.singleChoice,
        CLSurveyQuestionType.multipleChoice,
        CLSurveyQuestionType.scale,
        CLSurveyQuestionType.text,
      ]);
      expect(s.questions.map((q) => q.id), ['legacy_q1', 'legacy_q2', 'legacy_q3', 'legacy_q4']);
      expect(s.questions[0].options.map((o) => o.id), ['l1', 'l2']);
      expect(s.questions[2].required, isTrue);
    });

    test('risposta: solo risposte non vuote', () {
      final r = const CLSurveyResponse()
          .withAnswer('q1', const CLSurveyAnswer(optionIds: ['o1']))
          .withAnswer('q3', const CLSurveyAnswer(value: 4))
          .withAnswer('q4', const CLSurveyAnswer(text: ''));
      expect(r.toJson(), {
        'schemaVersion': 2,
        'answers': {
          'q1': {'optionIds': ['o1']},
          'q3': {'value': 4},
        },
      });
      expect(CLSurveyResponse.fromJson(jsonDecode(jsonEncode(r.toJson()))), r);
    });
  });

  group('validazione', () {
    test('schema: testo vuoto, opzioni, scala, maxLength', () {
      final issues = const CLSurvey(questions: [
        CLSurveyQuestion(id: 'a', type: CLSurveyQuestionType.singleChoice, text: ' ', options: [CLSurveyOption(id: 'o', label: '')]),
        CLSurveyQuestion(id: 'b', type: CLSurveyQuestionType.scale, text: 'S', scale: CLSurveyScale(min: 5, max: 5)),
        CLSurveyQuestion(id: 'c', type: CLSurveyQuestionType.scale, text: 'S', scale: CLSurveyScale(min: 0, max: 20)),
        CLSurveyQuestion(id: 'd', type: CLSurveyQuestionType.text, text: 'T', maxLength: 0),
      ]).validate();
      expect(issues.where((i) => i.questionId == 'a').map((i) => i.field),
          containsAll([CLSurveyIssueField.text, CLSurveyIssueField.options]));
      expect(issues.where((i) => i.questionId == 'a' && i.optionId == 'o'), hasLength(1));
      expect(issues.singleWhere((i) => i.questionId == 'b').field, CLSurveyIssueField.scale);
      expect(issues.singleWhere((i) => i.questionId == 'c').field, CLSurveyIssueField.scale);
      expect(issues.singleWhere((i) => i.questionId == 'd').field, CLSurveyIssueField.maxLength);
      expect(_survey.isValid, isTrue);
      expect(const CLSurvey().isValid, isFalse);
    });

    test('risposte: obbligatorie, scala, lunghezza; sanitize', () {
      expect(_survey.validateResponse(const CLSurveyResponse()).keys, ['q1']);
      final r = CLSurveyResponse(answers: {
        'q1': const CLSurveyAnswer(optionIds: ['o1', 'o2']),
        'q2': const CLSurveyAnswer(optionIds: ['a', 'zzz']),
        'q3': const CLSurveyAnswer(value: 9),
        'q4': const CLSurveyAnswer(text: '  abcdefghijkl  '),
        'ghost': const CLSurveyAnswer(text: 'x'),
      });
      final errors = _survey.validateResponse(r);
      expect(errors.keys, containsAll(['q1', 'q3', 'q4']));
      final clean = _survey.sanitizeResponse(r);
      expect(clean.answers.keys, ['q1', 'q2', 'q4']);
      expect(clean.answers['q1']!.optionIds, ['o1']);
      expect(clean.answers['q2']!.optionIds, ['a']);
      expect(clean.answers['q4']!.text, 'abcdefghij');
    });

    test('duplicate dà id nuovi a domanda e opzioni', () {
      final d = _single.duplicate();
      expect(d.id, isNot(_single.id));
      expect(d.options.map((o) => o.label), ['Sì', 'No']);
      expect(d.options.map((o) => o.id).toSet().intersection({'o1', 'o2'}), isEmpty);
    });
  });

  test('riepilogo: conteggi, quote, media, testi', () {
    final responses = [
      const CLSurveyResponse(answers: {
        'q1': CLSurveyAnswer(optionIds: ['o1']),
        'q2': CLSurveyAnswer(optionIds: ['a', 'b']),
        'q3': CLSurveyAnswer(value: 5),
        'q4': CLSurveyAnswer(text: 'ok'),
      }),
      const CLSurveyResponse(answers: {
        'q1': CLSurveyAnswer(optionIds: ['o2']),
        'q2': CLSurveyAnswer(optionIds: ['a']),
        'q3': CLSurveyAnswer(value: 2),
      }),
      const CLSurveyResponse(answers: {'q1': CLSurveyAnswer(optionIds: ['o1'])}),
    ];
    final s = CLSurveySummary.compute(_survey, responses);
    expect(s.responseCount, 3);
    expect(s.questions[0].optionCounts, {'o1': 2, 'o2': 1});
    expect(s.questions[0].share(2), closeTo(2 / 3, 1e-9));
    expect(s.questions[1].answeredCount, 2);
    expect(s.questions[1].optionCounts, {'a': 2, 'b': 1, 'c': 0});
    expect(s.questions[2].valueCounts, {1: 0, 2: 1, 3: 0, 4: 0, 5: 1});
    expect(s.questions[2].average, 3.5);
    expect(s.questions[3].texts, ['ok']);
  });
}
