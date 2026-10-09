// Modello v2 del sondaggio CL: schema delle domande (CLSurvey), risposte di un
// compilatore (CLSurveyResponse) e riepilogo aggregato (CLSurveySummary).
//
// Formato JSON (schemaVersion 2), stabile: chiavi camelCase, id stabili per
// domande e opzioni (mai indici), campi specifici del tipo presenti solo per
// quel tipo. Esempio:
//
// {
//   "schemaVersion": 2,
//   "questions": [
//     {"id": "q_7k2m9x4a1c", "type": "singleChoice", "order": 0,
//      "text": "Il corso ti è stato utile?", "help": null, "required": true,
//      "options": [{"id": "o_a8d2k1m0zq", "label": "Sì"},
//                  {"id": "o_b3n7c2x9we", "label": "No"}]},
//     {"id": "q_p0s8d7f6g5", "type": "scale", "order": 1,
//      "text": "Quanto lo consiglieresti?", "required": false,
//      "scale": {"min": 1, "max": 5, "minLabel": "Per niente", "maxLabel": "Moltissimo"}},
//     {"id": "q_z1x2c3v4b5", "type": "text", "order": 2,
//      "text": "Suggerimenti", "required": false, "maxLength": 500}
//   ]
// }
//
// Risposta:
//
// {
//   "schemaVersion": 2,
//   "answers": {
//     "q_7k2m9x4a1c": {"optionIds": ["o_a8d2k1m0zq"]},
//     "q_p0s8d7f6g5": {"value": 4},
//     "q_z1x2c3v4b5": {"text": "Più esercizi pratici"}
//   }
// }
//
// Il formato legacy (lista di `Question`, schema 1) si legge con
// [CLSurvey.fromJson] (riconosce la lista) o [CLSurvey.fromLegacyQuestions].

import 'dart:math';

import 'package:equatable/equatable.dart';

import 'question.dart';

/// Tipo di domanda del sondaggio v2. Il valore JSON è [jsonValue].
enum CLSurveyQuestionType {
  /// Una sola scelta fra le opzioni.
  singleChoice('singleChoice', 'Scelta singola'),

  /// Una o più scelte fra le opzioni.
  multipleChoice('multipleChoice', 'Scelta multipla'),

  /// Valore intero fra `scale.min` e `scale.max`, con etichette agli estremi.
  scale('scale', 'Scala'),

  /// Testo libero, lungo al massimo `maxLength` caratteri.
  text('text', 'Testo libero');

  const CLSurveyQuestionType(this.jsonValue, this.label);

  /// Valore stabile scritto nel JSON.
  final String jsonValue;

  /// Etichetta italiana per la UI.
  final String label;

  /// Vero per i tipi che hanno opzioni.
  bool get isChoice => this == singleChoice || this == multipleChoice;

  /// Tipo dal valore JSON; `null` se sconosciuto.
  static CLSurveyQuestionType? fromJsonValue(Object? value) {
    for (final t in values) {
      if (t.jsonValue == value) return t;
    }
    return null;
  }
}

/// Generatore di id brevi e stabili (`q_…` per le domande, `o_…` per le
/// opzioni). L'id si genera una volta, alla creazione, e non cambia più.
class CLSurveyIds {
  CLSurveyIds._();

  static final Random _random = Random.secure();
  static const String _alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';

  /// Nuovo id con [prefix] e 10 caratteri casuali in base 36.
  static String generate(String prefix) {
    final buffer = StringBuffer('${prefix}_');
    for (var i = 0; i < 10; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  /// Nuovo id di domanda.
  static String question() => generate('q');

  /// Nuovo id di opzione.
  static String option() => generate('o');
}

/// Opzione di una domanda a scelta.
class CLSurveyOption extends Equatable {
  const CLSurveyOption({required this.id, required this.label});

  /// Opzione nuova con id generato.
  factory CLSurveyOption.create({String label = ''}) => CLSurveyOption(id: CLSurveyIds.option(), label: label);

  factory CLSurveyOption.fromJson(Map<String, dynamic> json) => CLSurveyOption(
        id: json['id']?.toString() ?? '',
        // `text` è la chiave del formato legacy: accettata in lettura.
        label: (json['label'] ?? json['text'])?.toString() ?? '',
      );

  /// Id stabile, unico nella domanda.
  final String id;

  /// Testo dell'opzione.
  final String label;

  CLSurveyOption copyWith({String? label}) => CLSurveyOption(id: id, label: label ?? this.label);

  Map<String, dynamic> toJson() => {'id': id, 'label': label};

  @override
  List<Object?> get props => [id, label];
}

/// Configurazione di una domanda a scala.
class CLSurveyScale extends Equatable {
  const CLSurveyScale({this.min = 1, this.max = 5, this.minLabel, this.maxLabel});

  factory CLSurveyScale.fromJson(Map<String, dynamic> json) => CLSurveyScale(
        min: _asInt(json['min']) ?? 1,
        max: _asInt(json['max']) ?? 5,
        minLabel: _nonEmpty(json['minLabel']),
        maxLabel: _nonEmpty(json['maxLabel']),
      );

  /// Ampiezza massima: `max - min` non può superare questo valore (11 valori,
  /// cioè una scala 0–10), perché sul telefono i valori devono stare in vista.
  static const int maxSpan = 10;

  final int min;
  final int max;

  /// Etichetta dell'estremo basso (es. «Per niente»).
  final String? minLabel;

  /// Etichetta dell'estremo alto (es. «Moltissimo»).
  final String? maxLabel;

  /// Valori ammessi, dal minimo al massimo. Vuoto se la scala non è valida.
  List<int> get values => max > min && max - min <= maxSpan ? [for (var v = min; v <= max; v++) v] : const [];

  CLSurveyScale copyWith({int? min, int? max, String? minLabel, String? maxLabel}) => CLSurveyScale(
        min: min ?? this.min,
        max: max ?? this.max,
        minLabel: minLabel ?? this.minLabel,
        maxLabel: maxLabel ?? this.maxLabel,
      );

  Map<String, dynamic> toJson() => {'min': min, 'max': max, 'minLabel': minLabel, 'maxLabel': maxLabel};

  @override
  List<Object?> get props => [min, max, minLabel, maxLabel];
}

/// Una domanda del sondaggio v2.
///
/// I campi specifici del tipo restano in memoria anche quando il tipo cambia
/// (così nel builder si può tornare indietro senza perdere le opzioni), ma
/// [toJson] scrive solo quelli del tipo corrente.
class CLSurveyQuestion extends Equatable {
  const CLSurveyQuestion({
    required this.id,
    required this.type,
    this.text = '',
    this.help,
    this.required = false,
    this.options = const [],
    this.scale = const CLSurveyScale(),
    this.maxLength,
  });

  /// Domanda nuova con id generato. Le domande a scelta partono con due
  /// opzioni vuote, il testo libero con [defaultMaxLength] caratteri.
  factory CLSurveyQuestion.create({CLSurveyQuestionType type = CLSurveyQuestionType.singleChoice, String text = ''}) =>
      CLSurveyQuestion(
        id: CLSurveyIds.question(),
        type: type,
        text: text,
        options: type.isChoice ? [CLSurveyOption.create(), CLSurveyOption.create()] : const [],
        maxLength: type == CLSurveyQuestionType.text ? defaultMaxLength : null,
      );

  factory CLSurveyQuestion.fromJson(Map<String, dynamic> json) {
    final type = CLSurveyQuestionType.fromJsonValue(json['type']) ?? CLSurveyQuestionType.text;
    final rawOptions = json['options'];
    final rawScale = json['scale'];
    return CLSurveyQuestion(
      id: json['id']?.toString() ?? '',
      type: type,
      text: json['text']?.toString() ?? '',
      help: _nonEmpty(json['help']),
      required: json['required'] == true,
      options: rawOptions is List
          ? rawOptions.whereType<Map>().map((o) => CLSurveyOption.fromJson(Map<String, dynamic>.from(o))).toList()
          : const [],
      scale: rawScale is Map ? CLSurveyScale.fromJson(Map<String, dynamic>.from(rawScale)) : const CLSurveyScale(),
      maxLength: _asInt(json['maxLength']),
    );
  }

  /// Lunghezza massima proposta per le domande di testo nuove.
  static const int defaultMaxLength = 500;

  /// Id stabile, unico nel sondaggio. Le risposte vi fanno riferimento.
  final String id;
  final CLSurveyQuestionType type;

  /// Testo della domanda.
  final String text;

  /// Aiuto/descrizione mostrato sotto il testo.
  final String? help;

  /// Se vero, il compilatore non può inviare senza rispondere.
  final bool required;

  /// Opzioni (solo [CLSurveyQuestionType.isChoice]).
  final List<CLSurveyOption> options;

  /// Scala (solo [CLSurveyQuestionType.scale]).
  final CLSurveyScale scale;

  /// Lunghezza massima della risposta (solo [CLSurveyQuestionType.text]);
  /// `null` = nessun limite.
  final int? maxLength;

  CLSurveyQuestion copyWith({
    String? id,
    CLSurveyQuestionType? type,
    String? text,
    String? help,
    bool clearHelp = false,
    bool? required,
    List<CLSurveyOption>? options,
    CLSurveyScale? scale,
    int? maxLength,
    bool clearMaxLength = false,
  }) =>
      CLSurveyQuestion(
        id: id ?? this.id,
        type: type ?? this.type,
        text: text ?? this.text,
        help: clearHelp ? null : (help ?? this.help),
        required: required ?? this.required,
        options: options ?? this.options,
        scale: scale ?? this.scale,
        maxLength: clearMaxLength ? null : (maxLength ?? this.maxLength),
      );

  /// Copia con id nuovi (domanda e opzioni): per «Duplica».
  CLSurveyQuestion duplicate() => copyWith(
        id: CLSurveyIds.question(),
        options: [for (final o in options) CLSurveyOption(id: CLSurveyIds.option(), label: o.label)],
      );

  /// Opzione per id, `null` se non c'è.
  CLSurveyOption? optionById(String id) {
    for (final o in options) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Problemi della domanda come la scrive l'autore (vuoto = valida).
  List<CLSurveyIssue> validate() {
    final issues = <CLSurveyIssue>[];
    if (text.trim().isEmpty) {
      issues.add(CLSurveyIssue(questionId: id, field: CLSurveyIssueField.text, message: 'Scrivi il testo della domanda.'));
    }
    switch (type) {
      case CLSurveyQuestionType.singleChoice:
      case CLSurveyQuestionType.multipleChoice:
        if (options.length < 2) {
          issues.add(CLSurveyIssue(questionId: id, field: CLSurveyIssueField.options, message: 'Servono almeno due opzioni.'));
        }
        for (final o in options) {
          if (o.label.trim().isEmpty) {
            issues.add(CLSurveyIssue(
                questionId: id, optionId: o.id, field: CLSurveyIssueField.options, message: 'Scrivi il testo dell\'opzione.'));
          }
        }
        final labels = options.map((o) => o.label.trim().toLowerCase()).where((l) => l.isNotEmpty).toList();
        if (labels.toSet().length != labels.length) {
          issues.add(CLSurveyIssue(questionId: id, field: CLSurveyIssueField.options, message: 'Due opzioni hanno lo stesso testo.'));
        }
      case CLSurveyQuestionType.scale:
        if (scale.min >= scale.max) {
          issues.add(CLSurveyIssue(
              questionId: id, field: CLSurveyIssueField.scale, message: 'Il minimo della scala deve essere minore del massimo.'));
        } else if (scale.max - scale.min > CLSurveyScale.maxSpan) {
          issues.add(CLSurveyIssue(
              questionId: id,
              field: CLSurveyIssueField.scale,
              message: 'La scala può avere al massimo ${CLSurveyScale.maxSpan + 1} valori.'));
        }
      case CLSurveyQuestionType.text:
        if (maxLength != null && maxLength! < 1) {
          issues.add(CLSurveyIssue(
              questionId: id, field: CLSurveyIssueField.maxLength, message: 'La lunghezza massima deve essere almeno 1.'));
        }
    }
    return issues;
  }

  /// Errore della risposta [answer] per il compilatore, `null` se va bene.
  String? validateAnswer(CLSurveyAnswer? answer) {
    final empty = answer == null || isAnswerEmpty(answer);
    if (empty) return required ? 'Questa domanda è obbligatoria.' : null;
    switch (type) {
      case CLSurveyQuestionType.singleChoice:
        if (answer.optionIds.length > 1) return 'Scegli una sola risposta.';
      case CLSurveyQuestionType.multipleChoice:
        break;
      case CLSurveyQuestionType.scale:
        final v = answer.value;
        if (v == null || v < scale.min || v > scale.max) return 'Scegli un valore fra ${scale.min} e ${scale.max}.';
      case CLSurveyQuestionType.text:
        final len = (answer.text ?? '').trim().length;
        if (maxLength != null && len > maxLength!) return 'Massimo $maxLength caratteri (ora $len).';
    }
    return null;
  }

  /// Vero se [answer] non contiene una risposta utile per questo tipo.
  bool isAnswerEmpty(CLSurveyAnswer answer) => switch (type) {
        CLSurveyQuestionType.singleChoice ||
        CLSurveyQuestionType.multipleChoice =>
          !answer.optionIds.any((id) => optionById(id) != null),
        CLSurveyQuestionType.scale => answer.value == null,
        CLSurveyQuestionType.text => (answer.text ?? '').trim().isEmpty,
      };

  Map<String, dynamic> toJson({int? order}) => {
        'id': id,
        'type': type.jsonValue,
        if (order != null) 'order': order,
        'text': text,
        'help': (help?.trim().isEmpty ?? true) ? null : help,
        'required': required,
        if (type.isChoice) 'options': [for (final o in options) o.toJson()],
        if (type == CLSurveyQuestionType.scale) 'scale': scale.toJson(),
        if (type == CLSurveyQuestionType.text) 'maxLength': maxLength,
      };

  @override
  List<Object?> get props => [id, type, text, help, required, options, scale, maxLength];
}

/// Campo a cui si riferisce un [CLSurveyIssue].
enum CLSurveyIssueField { text, options, scale, maxLength }

/// Problema di validazione di una domanda (lato autore).
class CLSurveyIssue extends Equatable {
  const CLSurveyIssue({required this.questionId, required this.field, required this.message, this.optionId});

  final String questionId;
  final CLSurveyIssueField field;

  /// Opzione coinvolta, se il problema riguarda un'opzione precisa.
  final String? optionId;
  final String message;

  @override
  List<Object?> get props => [questionId, field, optionId, message];
}

/// Schema del sondaggio v2: elenco ordinato di domande.
class CLSurvey extends Equatable {
  const CLSurvey({this.questions = const []});

  /// Legge lo schema v2 (`{"schemaVersion": 2, "questions": [...]}`) oppure il
  /// formato legacy (lista di `Question`). Le domande sono ordinate per
  /// `order` (a parità, per posizione); id mancanti o duplicati vengono
  /// rigenerati perché le risposte non collidano.
  factory CLSurvey.fromJson(Object? json) {
    if (json is List) {
      return CLSurvey.fromLegacyQuestions(
          json.whereType<Map>().map((m) => Question.fromJson(Map<String, dynamic>.from(m))).toList());
    }
    if (json is! Map) return const CLSurvey();
    final raw = json['questions'];
    if (raw is! List) return const CLSurvey();
    final indexed = <(int, int, CLSurveyQuestion)>[];
    var i = 0;
    for (final item in raw.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      indexed.add((_asInt(map['order']) ?? i, i, CLSurveyQuestion.fromJson(map)));
      i++;
    }
    indexed.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
    final seen = <String>{};
    final questions = <CLSurveyQuestion>[];
    for (final (_, _, q) in indexed) {
      var question = q.id.isEmpty || seen.contains(q.id) ? q.copyWith(id: CLSurveyIds.question()) : q;
      seen.add(question.id);
      final optionIds = <String>{};
      if (question.options.any((o) => o.id.isEmpty || !optionIds.add(o.id))) {
        final fixed = <String>{};
        question = question.copyWith(options: [
          for (final o in question.options)
            o.id.isEmpty || !fixed.add(o.id) ? CLSurveyOption(id: CLSurveyIds.option(), label: o.label) : o,
        ]);
      }
      questions.add(question);
    }
    return CLSurvey(questions: questions);
  }

  /// Converte il formato legacy (`List<Question>`, schema 1). Le domande con
  /// opzioni diventano scelta singola o multipla (secondo `singleChoice`),
  /// `isRating`/`isStarRating` senza opzioni diventano una scala 1–5, il resto
  /// testo libero. Gli id delle domande sono deterministici (`legacy_q<n>`),
  /// quelli delle opzioni restano quelli legacy. Le domande subordinate
  /// (`Option.nested`) non hanno equivalente e vengono scartate.
  factory CLSurvey.fromLegacyQuestions(List<Question> legacy) {
    final questions = <CLSurveyQuestion>[];
    for (var i = 0; i < legacy.length; i++) {
      final q = legacy[i];
      final id = 'legacy_q${i + 1}';
      if (q.options.isNotEmpty) {
        final seen = <String>{};
        questions.add(CLSurveyQuestion(
          id: id,
          type: q.singleChoice ? CLSurveyQuestionType.singleChoice : CLSurveyQuestionType.multipleChoice,
          text: q.question,
          required: q.isMandatory,
          options: [
            for (var j = 0; j < q.options.length; j++)
              CLSurveyOption(
                id: q.options[j].id.isEmpty || !seen.add(q.options[j].id) ? '${id}_o${j + 1}' : q.options[j].id,
                label: q.options[j].text,
              ),
          ],
        ));
      } else if (q.isRating || q.isStarRating) {
        questions.add(CLSurveyQuestion(id: id, type: CLSurveyQuestionType.scale, text: q.question, required: q.isMandatory));
      } else {
        questions.add(CLSurveyQuestion(id: id, type: CLSurveyQuestionType.text, text: q.question, required: q.isMandatory));
      }
    }
    return CLSurvey(questions: questions);
  }

  /// Versione corrente dello schema JSON.
  static const int currentSchemaVersion = 2;

  final List<CLSurveyQuestion> questions;

  bool get isEmpty => questions.isEmpty;

  /// Domanda per id, `null` se non c'è.
  CLSurveyQuestion? questionById(String id) {
    for (final q in questions) {
      if (q.id == id) return q;
    }
    return null;
  }

  CLSurvey copyWith({List<CLSurveyQuestion>? questions}) => CLSurvey(questions: questions ?? this.questions);

  /// Tutti i problemi dello schema (vuoto = pubblicabile). Un sondaggio senza
  /// domande non è valido.
  List<CLSurveyIssue> validate() => [for (final q in questions) ...q.validate()];

  /// Vero se lo schema è pubblicabile: almeno una domanda e nessun problema.
  bool get isValid => questions.isNotEmpty && validate().isEmpty;

  /// Errori della risposta per domanda (solo le domande con errore).
  Map<String, String> validateResponse(CLSurveyResponse response) => {
        for (final q in questions)
          if (q.validateAnswer(response.answers[q.id]) case final String error) q.id: error,
      };

  /// Toglie dalla risposta ciò che lo schema non conosce: domande e opzioni
  /// inesistenti, risposte vuote, valori fuori scala; taglia il testo a
  /// `maxLength`. È la forma che il viewer passa a `onSubmit`.
  CLSurveyResponse sanitizeResponse(CLSurveyResponse response) {
    final clean = <String, CLSurveyAnswer>{};
    for (final q in questions) {
      final a = response.answers[q.id];
      if (a == null) continue;
      CLSurveyAnswer? kept;
      switch (q.type) {
        case CLSurveyQuestionType.singleChoice:
        case CLSurveyQuestionType.multipleChoice:
          final ids = a.optionIds.where((id) => q.optionById(id) != null).toSet().toList();
          final limited = q.type == CLSurveyQuestionType.singleChoice && ids.length > 1 ? [ids.first] : ids;
          if (limited.isNotEmpty) kept = CLSurveyAnswer(optionIds: limited);
        case CLSurveyQuestionType.scale:
          final v = a.value;
          if (v != null && v >= q.scale.min && v <= q.scale.max) kept = CLSurveyAnswer(value: v);
        case CLSurveyQuestionType.text:
          var t = (a.text ?? '').trim();
          if (q.maxLength != null && t.length > q.maxLength!) t = t.substring(0, q.maxLength!);
          if (t.isNotEmpty) kept = CLSurveyAnswer(text: t);
      }
      if (kept != null) clean[q.id] = kept;
    }
    return CLSurveyResponse(answers: clean);
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': currentSchemaVersion,
        'questions': [for (var i = 0; i < questions.length; i++) questions[i].toJson(order: i)],
      };

  @override
  List<Object?> get props => [questions];
}

/// Risposta a una domanda. Si usa solo il campo del tipo della domanda:
/// [optionIds] per le scelte, [value] per la scala, [text] per il testo.
class CLSurveyAnswer extends Equatable {
  const CLSurveyAnswer({this.optionIds = const [], this.value, this.text});

  factory CLSurveyAnswer.fromJson(Map<String, dynamic> json) {
    final ids = json['optionIds'];
    return CLSurveyAnswer(
      optionIds: ids is List ? ids.map((e) => e.toString()).toList() : const [],
      value: _asInt(json['value']),
      text: json['text']?.toString(),
    );
  }

  /// Id delle opzioni scelte (scelta singola: al massimo uno).
  final List<String> optionIds;

  /// Valore della scala.
  final int? value;

  /// Testo libero.
  final String? text;

  /// Vero se non contiene nulla.
  bool get isEmpty => optionIds.isEmpty && value == null && (text ?? '').trim().isEmpty;

  Map<String, dynamic> toJson() => {
        if (optionIds.isNotEmpty) 'optionIds': optionIds,
        if (value != null) 'value': value,
        if (text != null && text!.isNotEmpty) 'text': text,
      };

  @override
  List<Object?> get props => [optionIds, value, text];
}

/// Risposte di un compilatore, per id di domanda.
class CLSurveyResponse extends Equatable {
  const CLSurveyResponse({this.answers = const {}});

  factory CLSurveyResponse.fromJson(Object? json) {
    if (json is! Map) return const CLSurveyResponse();
    final raw = json['answers'];
    if (raw is! Map) return const CLSurveyResponse();
    return CLSurveyResponse(answers: {
      for (final e in raw.entries)
        if (e.value is Map) e.key.toString(): CLSurveyAnswer.fromJson(Map<String, dynamic>.from(e.value as Map)),
    });
  }

  final Map<String, CLSurveyAnswer> answers;

  /// Copia con la risposta a [questionId] sostituita (rimossa se vuota).
  CLSurveyResponse withAnswer(String questionId, CLSurveyAnswer? answer) {
    final next = Map<String, CLSurveyAnswer>.from(answers);
    if (answer == null || answer.isEmpty) {
      next.remove(questionId);
    } else {
      next[questionId] = answer;
    }
    return CLSurveyResponse(answers: next);
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': CLSurvey.currentSchemaVersion,
        'answers': {
          for (final e in answers.entries)
            if (!e.value.isEmpty) e.key: e.value.toJson(),
        },
      };

  @override
  List<Object?> get props => [answers];
}

/// Riepilogo aggregato di una domanda su più risposte.
class CLSurveyQuestionSummary {
  CLSurveyQuestionSummary({
    required this.question,
    required this.answeredCount,
    required this.optionCounts,
    required this.valueCounts,
    required this.texts,
  });

  final CLSurveyQuestion question;

  /// Quanti compilatori hanno risposto a questa domanda.
  final int answeredCount;

  /// Scelte: conteggio per id di opzione (tutte le opzioni, anche a 0).
  final Map<String, int> optionCounts;

  /// Scala: conteggio per valore (tutti i valori della scala, anche a 0).
  final Map<int, int> valueCounts;

  /// Testo libero: le risposte, nell'ordine delle risposte.
  final List<String> texts;

  /// Media della scala, `null` se nessuno ha risposto.
  double? get average {
    var n = 0;
    var sum = 0;
    valueCounts.forEach((v, c) {
      n += c;
      sum += v * c;
    });
    return n == 0 ? null : sum / n;
  }

  /// Quota (0–1) di [count] sui compilatori che hanno risposto.
  double share(int count) => answeredCount == 0 ? 0 : count / answeredCount;
}

/// Riepilogo di tutte le domande di un sondaggio su un insieme di risposte.
class CLSurveySummary {
  CLSurveySummary._(this.responseCount, this.questions);

  /// Calcola il riepilogo. Le risposte passano da [CLSurvey.sanitizeResponse],
  /// quindi opzioni o valori che lo schema non conosce non vengono contati.
  factory CLSurveySummary.compute(CLSurvey survey, List<CLSurveyResponse> responses) {
    final clean = responses.map(survey.sanitizeResponse).toList();
    final summaries = <CLSurveyQuestionSummary>[];
    for (final q in survey.questions) {
      final optionCounts = {for (final o in q.options) o.id: 0};
      final valueCounts = {for (final v in q.scale.values) v: 0};
      final texts = <String>[];
      var answered = 0;
      for (final r in clean) {
        final a = r.answers[q.id];
        if (a == null) continue;
        answered++;
        switch (q.type) {
          case CLSurveyQuestionType.singleChoice:
          case CLSurveyQuestionType.multipleChoice:
            for (final id in a.optionIds) {
              optionCounts[id] = (optionCounts[id] ?? 0) + 1;
            }
          case CLSurveyQuestionType.scale:
            valueCounts[a.value!] = (valueCounts[a.value!] ?? 0) + 1;
          case CLSurveyQuestionType.text:
            texts.add(a.text!);
        }
      }
      summaries.add(CLSurveyQuestionSummary(
        question: q,
        answeredCount: answered,
        optionCounts: q.type.isChoice ? optionCounts : const {},
        valueCounts: q.type == CLSurveyQuestionType.scale ? valueCounts : const {},
        texts: texts,
      ));
    }
    return CLSurveySummary._(responses.length, summaries);
  }

  /// Numero di risposte (compilatori) considerate.
  final int responseCount;

  /// Riepilogo per domanda, nell'ordine dello schema.
  final List<CLSurveyQuestionSummary> questions;
}

int? _asInt(Object? v) => switch (v) {
      int i => i,
      num n => n.round(),
      String s => int.tryParse(s.trim()),
      _ => null,
    };

String? _nonEmpty(Object? v) {
  final s = v?.toString();
  return s == null || s.trim().isEmpty ? null : s;
}
