import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_attributes.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_values.dart';

String? _daytime(Object v) {
  final t = v as String;
  return t.compareTo('08:00') < 0 || t.compareTo('21:00') > 0 ? 'Solo tra 08:00 e 21:00' : null;
}

const _days = CLGraphNodeAttribute.numeric(name: 'giorni', min: 1, max: 30, integer: true, defaultValue: 2);
const _subject = CLGraphNodeAttribute.string(name: 'oggetto', maxLength: 10);
const _optionalNote = CLGraphNodeAttribute.string(name: 'nota', nullable: true);
const _sendAt = CLGraphNodeAttribute.time(name: 'invia alle', validator: _daytime);
const _link = CLGraphNodeAttribute.url(name: 'link', nullable: true);

/// Simula la digitazione carattere per carattere attraverso la maschera orario.
String _type(String keys, {String from = ''}) {
  const f = CLGraphTimeInputFormatter();
  var value = TextEditingValue(text: from, selection: TextSelection.collapsed(offset: from.length));
  for (final k in keys.split('')) {
    final typed = value.text + k;
    value = f.formatEditUpdate(value, TextEditingValue(text: typed, selection: TextSelection.collapsed(offset: typed.length)));
  }
  return value.text;
}

String _backspace(String from) {
  const f = CLGraphTimeInputFormatter();
  final old = TextEditingValue(text: from, selection: TextSelection.collapsed(offset: from.length));
  final cut = from.substring(0, from.length - 1);
  return f.formatEditUpdate(old, TextEditingValue(text: cut, selection: TextSelection.collapsed(offset: cut.length))).text;
}

void main() {
  group('maschera orario', () {
    test('i due punti arrivano da soli', () {
      expect(_type('0930'), '09:30');
      expect(_type('1745'), '17:45');
      expect(_type('093'), '09:3');
    });

    test('ora a una cifra e minuti oltre il 5 prendono lo zero davanti', () {
      expect(_type('9'), '09');
      expect(_type('930'), '09:30');
      expect(_type('237'), '23:07');
    });

    test('ore oltre 23 e quinta cifra rifiutate', () {
      expect(_type('25'), '2');
      expect(_type('2400'), '20:0'); // "24" rifiutato, poi "20", "200" → "20:0"
      expect(_type('09301'), '09:30');
    });

    test('separatore dopo una cifra completa l\'ora, altrimenti ignorato', () {
      expect(_type('1:30'), '01:30');
      expect(_type('12:30'), '12:30');
      expect(_type('9.15'), '09:15');
    });

    test('testo che sostituisce tutto o incollato: stessa formattazione', () {
      expect(_type('9', from: '18:30'), '18:30'); // campo pieno: una cifra in più non entra
      const f = CLGraphTimeInputFormatter();
      TextEditingValue v(String t) => TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
      expect(f.formatEditUpdate(v('18:30'), v('930')).text, '09:30'); // selezione di tutto + incolla
      expect(f.formatEditUpdate(v('18:30'), v('7')).text, '07');
      expect(f.formatEditUpdate(v(''), v('abc')).text, '');
      expect(f.formatEditUpdate(v('09:3'), v('09:3a')).text, '09:3');
    });

    test('la cancellazione toglie anche i due punti', () {
      expect(_backspace('09:30'), '09:3');
      expect(_backspace('09:3'), '09');
      expect(_backspace('09'), '0');
    });

    test('completamento alla perdita del focus', () {
      expect(clGraphCompleteTime('9'), '09:00');
      expect(clGraphCompleteTime('18'), '18:00');
      expect(clGraphCompleteTime('09:3'), '09:3');
      expect(clGraphCompleteTime('25'), '25');
    });
  });

  group('link', () {
    test('schema aggiunto se manca', () {
      expect(clGraphNormalizeUrl('www.sito.it'), 'https://www.sito.it');
      expect(clGraphNormalizeUrl(' http://sito.it '), 'http://sito.it');
      expect(clGraphNormalizeUrl(''), '');
    });

    test('validi solo http/https con un dominio', () {
      expect(clGraphIsValidUrl('https://prenota.atelier.it/milano?utm=1'), isTrue);
      expect(clGraphIsValidUrl('http://sito.it'), isTrue);
      expect(clGraphIsValidUrl('https://sito'), isFalse);
      expect(clGraphIsValidUrl('ftp://sito.it'), isFalse);
      expect(clGraphIsValidUrl('https://si to.it'), isFalse);
      expect(clGraphIsValidUrl('https://mailto:x@y.it'), isFalse);
    });
  });

  group('validate', () {
    test('numeric: intero e intervallo', () {
      expect(_days.validate(5), isNull);
      expect(_days.validate(2.5), 'Serve un numero intero');
      expect(_days.validate(0), 'Valore tra 1 e 30');
      expect(_days.validate(31), 'Valore tra 1 e 30');
      expect(const CLGraphNodeAttribute.numeric(name: 'x', min: 1).validate(0), 'Minimo 1');
      expect(const CLGraphNodeAttribute.numeric(name: 'x', max: 1.5).validate(2), 'Massimo 1.5');
    });

    test('string: obbligatorio non vuoto e lunghezza massima', () {
      expect(_subject.validate('Ciao'), isNull);
      expect(_subject.validate('   '), 'Obbligatorio');
      expect(_subject.validate('Buongiorno a tutti'), 'Massimo 10 caratteri (ora 18)');
      expect(_optionalNote.validate(''), isNull);
    });

    test('time: formato e validator personalizzato', () {
      expect(_sendAt.validate('18:30'), isNull);
      expect(_sendAt.validate('22:00'), 'Solo tra 08:00 e 21:00');
      expect(_sendAt.validate('24:00'), 'Orario non valido (HH:MM)');
      expect(_sendAt.validate(''), 'Obbligatorio');
      expect(_sendAt.validate(null), 'Obbligatorio');
    });

    test('url: facoltativo vuoto ammesso, link senza schema no (lo aggiunge il campo)', () {
      expect(_link.validate(null), isNull);
      expect(_link.validate(''), isNull);
      expect(_link.validate('https://www.sito.it'), isNull);
      expect(_link.validate('www.sito.it'), isNotNull);
    });

    test('un default fuori dai vincoli è un problema di definizione', () {
      expect(const CLGraphNodeAttribute.numeric(name: 'x', min: 1, defaultValue: 0).definitionProblem, contains('default'));
      expect(const CLGraphNodeAttribute.time(name: 'x', defaultValue: '9:00').definitionProblem, contains('default'));
      expect(const CLGraphNodeAttribute.numeric(name: 'x', min: 5, max: 1).definitionProblem, contains('min'));
      expect(const CLGraphNodeAttribute(name: 'x', type: CLGraphAttributeType.string, min: 1).definitionProblem, isNotNull);
      expect(_days.definitionProblem, isNull);
      expect(_sendAt.definitionProblem, isNull);
    });
  });

  group('lettura del testo dei campi', () {
    test('numeric: virgola decimale, interi, testo a metà rimandato', () {
      expect(clGraphParseText(const CLGraphNodeAttribute.numeric(name: 'x'), '3,5').value, 3.5);
      expect(clGraphParseText(_days, '4').value, 4);
      final minus = clGraphParseText(_days, '-');
      expect((minus.error, minus.deferred), ('Numero non valido', true));
      final far = clGraphParseText(_days, '45');
      expect((far.error, far.deferred), ('Valore tra 1 e 30', false)); // completo ma fuori intervallo: subito
    });

    test('time: incompleto rimandato, completo validato subito', () {
      final half = clGraphParseText(_sendAt, '09:3');
      expect((half.error, half.deferred), ('Completa l\'orario (HH:MM)', true));
      expect(clGraphParseText(_sendAt, '09:30').value, '09:30');
      final night = clGraphParseText(_sendAt, '23:00');
      expect((night.error, night.deferred), ('Solo tra 08:00 e 21:00', false));
    });

    test('url: https aggiunto, dominio incompleto rimandato', () {
      expect(clGraphParseText(_link, 'www.atelier.it/prenota').value, 'https://www.atelier.it/prenota');
      expect(clGraphParseText(_link, 'www.atelier').deferred, isTrue);
      expect(clGraphParseText(_link, '').value, isNull); // facoltativo svuotato
    });

    test('obbligatorio vuoto rimandato alla perdita del focus', () {
      final empty = clGraphParseText(_subject, '');
      expect((empty.error, empty.deferred), ('Obbligatorio', true));
    });
  });
}
