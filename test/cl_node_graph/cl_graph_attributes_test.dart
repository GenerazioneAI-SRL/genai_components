import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_attributes.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_node_graph.widget.dart';

const _price = CLGraphNodeAttribute.numeric(name: 'prezzo', defaultValue: 10);
const _note = CLGraphNodeAttribute.string(name: 'note', nullable: true);
const _channel = CLGraphNodeAttribute.enumeration(name: 'canale', options: ['Email', 'WhatsApp']);
const _active = CLGraphNodeAttribute.boolean(name: 'attivo', defaultValue: true);

void main() {
  group('CLGraphNodeAttribute.accepts', () {
    test('valori ammessi per tipo', () {
      expect(_price.accepts(3), isTrue);
      expect(_price.accepts(3.5), isTrue);
      expect(_price.accepts(double.nan), isFalse);
      expect(_price.accepts('3'), isFalse);
      expect(_note.accepts('x'), isTrue);
      expect(_channel.accepts('Email'), isTrue);
      expect(_channel.accepts('SMS'), isFalse);
      expect(_active.accepts(false), isTrue);
      expect(_active.accepts(0), isFalse);
    });

    test('null solo se nullable', () {
      expect(_note.accepts(null), isTrue);
      expect(_price.accepts(null), isFalse);
    });
  });

  group('definitionProblem', () {
    test('definizioni coerenti', () {
      for (final a in [_price, _note, _channel, _active]) {
        expect(a.definitionProblem, isNull, reason: a.name);
      }
    });

    test('enumeration senza alternative o con duplicati', () {
      expect(const CLGraphNodeAttribute.enumeration(name: 'x', options: []).definitionProblem, isNotNull);
      expect(const CLGraphNodeAttribute.enumeration(name: 'x', options: ['a', 'a']).definitionProblem, isNotNull);
    });

    test('default fuori dalle alternative o del tipo sbagliato', () {
      expect(const CLGraphNodeAttribute.enumeration(name: 'x', options: ['a'], defaultValue: 'b').definitionProblem, isNotNull);
      expect(
        const CLGraphNodeAttribute(name: 'x', type: CLGraphAttributeType.numeric, defaultValue: 'dieci').definitionProblem,
        isNotNull,
      );
      expect(const CLGraphNodeAttribute(name: 'x', type: CLGraphAttributeType.string, options: ['a']).definitionProblem, isNotNull);
    });
  });

  group('valori del nodo', () {
    const node = CLGraphNode(
      id: 'n',
      type: 't',
      title: 'N',
      attributes: [_price, _note, _channel, _active],
      attributeValues: {'prezzo': 25, 'canale': 'SMS'},
    );

    test('valore presente e valido, altrimenti default', () {
      expect(node.attributeValue('prezzo'), 25);
      expect(node.attributeValue('note'), isNull);
      expect(node.attributeValue('canale'), isNull); // 'SMS' non è un'alternativa, nessun default
      expect(node.attributeValue('attivo'), isTrue); // default
      expect(node.attributeValue('inesistente'), isNull);
    });

    test('resolvedAttributeValues segue l\'ordine degli attributi', () {
      expect(node.resolvedAttributeValues.keys, ['prezzo', 'note', 'canale', 'attivo']);
    });

    test('missingAttributes: non nullable senza valore né default', () {
      expect(node.missingAttributes.map((a) => a.name), ['canale']);
    });

    test('withAttributeValue sostituisce solo il valore', () {
      final updated = node.withAttributeValue('canale', 'Email');
      expect(updated.attributeValue('canale'), 'Email');
      expect(updated.attributeValue('prezzo'), 25);
      expect(updated.attributes, same(node.attributes));
      expect(updated.id, node.id);
      expect(updated.missingAttributes, isEmpty);
    });

    test('attributesProblem segnala nomi duplicati', () {
      const dup = CLGraphNode(id: 'd', type: 't', title: 'D', attributes: [_price, _price]);
      expect(dup.attributesProblem, contains('duplicato'));
      expect(node.attributesProblem, isNull);
    });
  });

  group('separazione delle card alte', () {
    test('se nessuna card supera kCardH le posizioni restano identiche', () {
      final positions = {'a': Offset.zero, 'b': const Offset(0, 130), 'c': const Offset(300, 0)};
      final out = clSeparateTallNodes(positions, {'a': kCardH, 'b': kCardH, 'c': kCardH});
      expect(out, same(positions));
    });

    test('una riga con una card alta spinge giù tutte le righe sotto, anche nelle altre colonne', () {
      final positions = {
        'a': Offset.zero,
        'b': const Offset(300, 0),
        'c': const Offset(0, 130),
        'd': const Offset(300, 130),
        'e': const Offset(300, 260),
      };
      final out = clSeparateTallNodes(positions, {'a': kCardH + 90, 'b': kCardH, 'c': kCardH + 30, 'd': kCardH, 'e': kCardH});
      expect(out['a'], Offset.zero);
      expect(out['b'], const Offset(300, 0)); // stessa riga: non si muove
      expect(out['c'], const Offset(0, 130 + 90));
      expect(out['d'], const Offset(300, 130 + 90)); // riga allineata
      expect(out['e'], const Offset(300, 260 + 90 + 30));
    });
  });
}
