import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_attributes.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_connections.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_json.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_layout.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';

// Gli esempi di NODE_GRAPH_JSON_SPEC.md (§11) sono l'output dell'encoder per i
// documenti qui sotto, salvato in test/cl_node_graph/fixtures/.
// Rigenera i file con: CL_GRAPH_JSON_UPDATE=1 flutter test test/cl_node_graph/cl_graph_json_test.dart
String _fixture(String name) => 'test/cl_node_graph/fixtures/$name.json';

String? _daytime(Object value) {
  final t = value as String;
  return t.compareTo('08:00') < 0 || t.compareTo('21:00') > 0 ? 'Solo tra le 08:00 e le 21:00' : null;
}

const _codec = CLGraphJson(
  icons: [Icons.bolt, Icons.chat_bubble_outline, Icons.flag_outlined, Icons.close],
  validators: {'daytime': _daytime},
);

final _example = CLGraphDocument(
  exportedAt: DateTime.utc(2026, 9, 30, 10),
  view: const CLGraphView(layout: 'prereqFlow', selectedNodeId: 'whatsapp'),
  nodes: const [
    CLGraphNode(
      id: 'trigger',
      type: 'trigger',
      title: 'Nuovo lead',
      subtitle: 'Form sito o DM Instagram',
      icon: Icons.bolt,
      accent: Color(0xFFF59E0B),
      badge: 'Trigger',
      data: {'evento': 'lead.created', 'canali': ['Sito', 'Instagram']},
      attributes: [
        CLGraphNodeAttribute.enumeration(name: 'canale', options: ['Sito', 'Instagram', 'Fiera'], defaultValue: 'Sito'),
        CLGraphNodeAttribute.boolean(name: 'solo nuovi contatti', defaultValue: true),
      ],
      connectionRules: CLGraphConnectionRules(inputTypes: {}, outputTypes: {'action'}, minOutputs: 1, maxOutputs: 1),
    ),
    CLGraphNode(
      id: 'whatsapp',
      type: 'action',
      title: 'Reminder WhatsApp',
      icon: Icons.chat_bubble_outline,
      accent: Color(0xFF5B9BD5),
      badge: 'No',
      badgeColor: Color(0xFFDC2626),
      actions: [CLGraphNodeAction(id: 'remove', icon: Icons.close, tooltip: 'Rimuovi step')],
      attributes: [
        CLGraphNodeAttribute.string(name: 'messaggio', maxLength: 300),
        CLGraphNodeAttribute.time(name: 'invia alle', defaultValue: '18:30', validator: _daytime),
        CLGraphNodeAttribute.url(name: 'link', nullable: true),
        CLGraphNodeAttribute.numeric(name: 'tentativi', min: 1, max: 5, integer: true, defaultValue: 1),
        CLGraphNodeAttribute.boolean(name: 'solo se non ha risposto', nullable: true),
      ],
      attributeValues: {'messaggio': 'Ciao! Ti aspettiamo in atelier.', 'link': 'https://www.atelier.it/prenota', 'tentativi': 2},
      connectionRules: CLGraphConnectionRules(inputTypes: {'trigger', 'action'}, minInputs: 1),
    ),
    CLGraphNode(
      id: 'done',
      type: 'end',
      title: 'Fine',
      icon: Icons.flag_outlined,
      actions: [CLGraphNodeAction(id: 'count', label: '12', tooltip: '12 lead arrivati qui', interactive: false)],
      connectionRules: CLGraphConnectionRules(outputTypes: {}, minInputs: 1),
    ),
  ],
  edges: const [
    CLGraphEdge(id: 'trigger>whatsapp', fromNodeId: 'trigger', toNodeId: 'whatsapp', kind: CLGraphEdgeKind.prerequisite),
    CLGraphEdge(id: 'whatsapp>done', fromNodeId: 'whatsapp', toNodeId: 'done', kind: CLGraphEdgeKind.prerequisite),
  ],
);

// §11.2 — flusso lineare, nessun extra: la forma più semplice.
const _linear = CLGraphDocument(
  nodes: [
    CLGraphNode(id: 'lead', type: 'trigger', title: 'Nuovo lead'),
    CLGraphNode(id: 'welcome', type: 'action', title: 'Email di benvenuto'),
    CLGraphNode(id: 'assign', type: 'action', title: 'Assegna consulente'),
  ],
  edges: [
    CLGraphEdge(id: 'lead>welcome', fromNodeId: 'lead', toNodeId: 'welcome', kind: CLGraphEdgeKind.prerequisite),
    CLGraphEdge(id: 'welcome>assign', fromNodeId: 'welcome', toNodeId: 'assign', kind: CLGraphEdgeKind.prerequisite),
  ],
);

// §11.3 — condizione con due rami che si ricongiungono, con le regole di collegamento.
const _branchAction = CLGraphConnectionRules(inputTypes: {'condition'}, outputTypes: {'end'}, minInputs: 1);
const _branch = CLGraphDocument(
  nodes: [
    CLGraphNode(
      id: 'lead',
      type: 'trigger',
      title: 'Nuovo lead',
      connectionRules: CLGraphConnectionRules(inputTypes: {}, outputTypes: {'condition'}, minOutputs: 1, maxOutputs: 1),
    ),
    CLGraphNode(
      id: 'opened',
      type: 'condition',
      title: 'Ha aperto l\'email?',
      connectionRules: CLGraphConnectionRules(
        inputTypes: {'trigger'},
        outputTypes: {'action'},
        minInputs: 1,
        maxInputs: 1,
        minOutputs: 2,
        maxOutputs: 2,
      ),
    ),
    CLGraphNode(
      id: 'booking',
      type: 'action',
      title: 'Proponi appuntamento',
      badge: 'Sì',
      badgeColor: Color(0xFF16A34A),
      connectionRules: _branchAction,
    ),
    CLGraphNode(
      id: 'whatsapp',
      type: 'action',
      title: 'Reminder WhatsApp',
      badge: 'No',
      badgeColor: Color(0xFFDC2626),
      connectionRules: _branchAction,
    ),
    CLGraphNode(
      id: 'done',
      type: 'end',
      title: 'Fine',
      connectionRules: CLGraphConnectionRules(inputTypes: {'action'}, outputTypes: {}, minInputs: 1),
    ),
  ],
  edges: [
    CLGraphEdge(id: 'lead>opened', fromNodeId: 'lead', toNodeId: 'opened', kind: CLGraphEdgeKind.prerequisite),
    CLGraphEdge(id: 'opened>booking', fromNodeId: 'opened', toNodeId: 'booking', kind: CLGraphEdgeKind.prerequisite),
    CLGraphEdge(id: 'opened>whatsapp', fromNodeId: 'opened', toNodeId: 'whatsapp', kind: CLGraphEdgeKind.prerequisite),
    CLGraphEdge(id: 'booking>done', fromNodeId: 'booking', toNodeId: 'done', kind: CLGraphEdgeKind.prerequisite),
    CLGraphEdge(id: 'whatsapp>done', fromNodeId: 'whatsapp', toNodeId: 'done', kind: CLGraphEdgeKind.prerequisite),
  ],
);

// §11.4 — una fase che contiene due task, con un arco di contenimento nascosto e la vista.
const _containment = CLGraphDocument(
  view: CLGraphView(layout: 'moduleFlow', collapsedNodeIds: ['p1']),
  nodes: [
    CLGraphNode(id: 'p1', type: 'phase', title: '12–9 mesi prima', subtitle: 'Le fondamenta'),
    CLGraphNode(id: 'budget', type: 'task', title: 'Definire il budget', badge: 'Sposi'),
    CLGraphNode(id: 'location', type: 'task', title: 'Scegliere la location', badge: 'Wedding planner'),
  ],
  edges: [
    CLGraphEdge(id: 'p1/budget', fromNodeId: 'p1', toNodeId: 'budget', kind: CLGraphEdgeKind.containment),
    CLGraphEdge(id: 'p1/location', fromNodeId: 'p1', toNodeId: 'location', kind: CLGraphEdgeKind.containment, hidden: true),
    CLGraphEdge(id: 'budget>location', fromNodeId: 'budget', toNodeId: 'location', kind: CLGraphEdgeKind.prerequisite),
  ],
);

/// Nome della fixture → documento.
final _examples = {
  'cl_graph_example': _example,
  'cl_graph_example_linear': _linear,
  'cl_graph_example_branch': _branch,
  'cl_graph_example_containment': _containment,
};

Map<String, Object?> _minimal() => {
      'format': 'cl_node_graph',
      'version': 1,
      'nodes': <Object?>[
        <String, Object?>{'id': 'a', 'type': 't', 'title': 'A'},
        <String, Object?>{'id': 'b', 'type': 't', 'title': 'B'},
      ],
      'edges': <Object?>[
        <String, Object?>{'id': 'a>b', 'fromNodeId': 'a', 'toNodeId': 'b', 'kind': 'prerequisite'},
      ],
    };

Matcher _formatError(String text) =>
    throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(text)));

void main() {
  for (final e in _examples.entries) {
    test('${e.key}: l\'esempio della specifica è l\'output dell\'encoder', () {
      final json = '${_codec.encodeString(e.value)}\n';
      if (Platform.environment['CL_GRAPH_JSON_UPDATE'] != null) {
        File(_fixture(e.key))
          ..createSync(recursive: true)
          ..writeAsStringSync(json);
      }
      expect(json, File(_fixture(e.key)).readAsStringSync());
    });

    test('${e.key}: andata e ritorno, encode(decode(json)) dà lo stesso JSON', () {
      final json = _codec.encodeString(e.value);
      final doc = _codec.decodeString(json);
      expect(doc.warnings, isEmpty);
      expect(_codec.encodeString(doc), json);
    });
  }

  test('forma compatta della specifica (solo chiavi obbligatorie) = esempio lineare completo', () {
    final compact = File(_fixture('cl_graph_example_linear_compact')).readAsStringSync();
    expect('${_codec.encodeString(_codec.decodeString(compact))}\n', File(_fixture('cl_graph_example_linear')).readAsStringSync());
  });

  test('gli esempi a rami e a fasi rispettano le loro regole: nessun avviso sui collegamenti', () {
    for (final doc in [_branch, _containment]) {
      expect(clGraphConnectionWarnings(doc.nodes, doc.edges), isEmpty);
    }
  });

  test('la lettura ricostruisce icone, colori, controlli, regole e vista', () {
    final doc = _codec.decodeString(_codec.encodeString(_example));
    final whatsapp = doc.nodes[1];
    expect(whatsapp.icon, same(Icons.chat_bubble_outline));
    expect(whatsapp.badgeColor, const Color(0xFFDC2626));
    expect(whatsapp.attribute('invia alle')!.validator, same(_daytime));
    expect(whatsapp.attribute('invia alle')!.validate('22:00'), 'Solo tra le 08:00 e le 21:00');
    expect(whatsapp.attribute('tentativi')!.integer, isTrue);
    expect(whatsapp.attributeValue('tentativi'), 2);
    expect(whatsapp.attributeValue('invia alle'), '18:30'); // default
    expect(whatsapp.connectionRules.inputTypes, {'trigger', 'action'});
    expect(doc.nodes[0].connectionRules.inputTypes, isEmpty);
    expect(doc.nodes[0].connectionRules.outputTypes, {'action'});
    expect(doc.nodes[2].connectionRules.inputTypes, isNull); // nessun vincolo
    expect(doc.nodes[2].actions.single.interactive, isFalse);
    expect(doc.nodes[0].data, {'evento': 'lead.created', 'canali': ['Sito', 'Instagram']});
    expect(doc.edges.map((e) => e.kind), everyElement(CLGraphEdgeKind.prerequisite));
    expect(doc.view!.layout, 'prereqFlow');
    expect(doc.view!.selectedNodeId, 'whatsapp');
    expect(doc.exportedAt, DateTime.utc(2026, 9, 30, 10));
  });

  test('documento minimo: le chiavi facoltative prendono i default, quelle sconosciute si ignorano', () {
    final json = _minimal()..['futura'] = {'x': 1};
    final doc = const CLGraphJson().decode(json);
    expect(doc.nodes.map((n) => n.id), ['a', 'b']);
    expect(doc.nodes.first.attributes, isEmpty);
    expect(doc.nodes.first.connectionRules.acceptsInputs, isTrue);
    expect(doc.edges.single.hidden, isFalse);
    expect(doc.view, isNull);
    expect(doc.warnings, isEmpty);
  });

  test('layout della libreria per nome', () {
    expect(CLGraphJson.layoutName(clPrereqFlowLayout), 'prereqFlow');
    expect(CLGraphJson.layoutName((_, __) => const {}), isNull);
    expect(CLGraphJson.builtInLayouts['moduleFlow'], same(clModuleFlowLayout));
  });

  group('errori in scrittura', () {
    test('data non JSON', () {
      final doc = CLGraphDocument(nodes: [CLGraphNode(id: 'a', type: 't', title: 'A', data: {'quando': DateTime(2026)})], edges: const []);
      expect(
        () => const CLGraphJson().encode(doc),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('nodes[0].data.quando'))),
      );
    });

    test('controllo personalizzato non registrato', () {
      expect(
        () => const CLGraphJson().encode(_example),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('nodes[1].attributes[1].validator'))),
      );
    });
  });

  group('errori in lettura (documento rifiutato)', () {
    const codec = CLGraphJson();

    test('formato, versione e chiavi obbligatorie', () {
      expect(() => codec.decode(_minimal()..['format'] = 'altro'), _formatError('format: atteso "cl_node_graph"'));
      expect(() => codec.decode(_minimal()..['version'] = 2), _formatError('version: versione 2 non supportata'));
      expect(() => codec.decode(_minimal()..remove('nodes')), _formatError('nodes: obbligatorio'));
      expect(() => codec.decode([1, 2]), _formatError('atteso un oggetto'));
      expect(() => codec.decodeString('{'), _formatError('JSON non valido'));
    });

    test('id duplicati e archi verso nodi inesistenti', () {
      final dupNode = _minimal();
      (dupNode['nodes'] as List).add({'id': 'a', 'type': 't', 'title': 'A2'});
      expect(() => codec.decode(dupNode), _formatError('nodes[2].id: id "a" duplicato'));
      final ghost = _minimal();
      (ghost['edges'] as List).add({'id': 'a>z', 'fromNodeId': 'a', 'toNodeId': 'z', 'kind': 'prerequisite'});
      expect(() => codec.decode(ghost), _formatError('edges[1].toNodeId: nodo "z" inesistente'));
    });

    test('enum sconosciuti, tipi sbagliati, colori', () {
      final kind = _minimal();
      ((kind['edges'] as List).first as Map)['kind'] = 'link';
      expect(() => codec.decode(kind), _formatError('edges[0].kind: valore "link" sconosciuto'));
      final type = _minimal();
      ((type['nodes'] as List).first as Map)['attributes'] = [
        {'name': 'x', 'type': 'date'},
      ];
      expect(() => codec.decode(type), _formatError('nodes[0].attributes[0].type: valore "date" sconosciuto'));
      final title = _minimal();
      ((title['nodes'] as List).first as Map)['title'] = 3;
      expect(() => codec.decode(title), _formatError('nodes[0].title: atteso una stringa'));
      final color = _minimal();
      ((color['nodes'] as List).first as Map)['accent'] = 'red';
      expect(() => codec.decode(color), _formatError('nodes[0].accent: colore atteso come #AARRGGBB'));
    });

    test('definizioni incoerenti e controlli non registrati', () {
      final range = _minimal();
      ((range['nodes'] as List).first as Map)['attributes'] = [
        {'name': 'x', 'type': 'numeric', 'min': 5, 'max': 1},
      ];
      expect(() => codec.decode(range), _formatError('nodes[0]: nodo "a": "x": min maggiore di max'));
      final rules = _minimal();
      ((rules['nodes'] as List).first as Map)['connectionRules'] = {'inputTypes': [], 'minInputs': 1};
      expect(() => codec.decode(rules), _formatError('regole di collegamento'));
      expect(
        () => codec.decode(jsonDecode(_codec.encodeString(_example))),
        _formatError('nodes[1].attributes[1].validator: controllo "daytime" non registrato'),
      );
    });
  });

  group('avvisi in lettura (documento accettato)', () {
    test('icone fuori registro: omesse, azione senza label con segnaposto', () {
      const noIcons = CLGraphJson(validators: {'daytime': _daytime});
      final doc = noIcons.decodeString(_codec.encodeString(_example));
      expect(doc.nodes.first.icon, isNull);
      expect(doc.nodes[1].actions.single.label, '?');
      expect(doc.warnings, contains(startsWith('nodes[0].icon: icona 0x')));
    });

    test('valore di attributo non valido e vista con nodi inesistenti', () {
      final json = _minimal();
      final node = (json['nodes'] as List).first as Map;
      node['attributes'] = [
        {'name': 'ora', 'type': 'time'},
      ];
      node['attributeValues'] = {'ora': '25:00'};
      json['view'] = {'selectedNodeId': 'z', 'collapsedNodeIds': ['a']};
      final doc = const CLGraphJson().decode(json);
      expect(doc.nodes.first.attributeValues['ora'], '25:00'); // conservato così com'è
      expect(doc.warnings, [
        'nodes[0].attributeValues.ora: Orario non valido (HH:MM) (vale il default)',
        'view: nodo "z" inesistente',
      ]);
    });
  });
}
