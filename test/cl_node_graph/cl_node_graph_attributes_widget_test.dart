import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_attributes.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_node_graph.widget.dart';

const _attrs = [
  CLGraphNodeAttribute.string(name: 'note', nullable: true),
  CLGraphNodeAttribute.numeric(name: 'prezzo', defaultValue: 10),
  CLGraphNodeAttribute.enumeration(name: 'canale', options: ['Email', 'WhatsApp'], nullable: true),
  CLGraphNodeAttribute.boolean(name: 'attivo', nullable: true),
  CLGraphNodeAttribute.boolean(name: 'confermato'),
];

/// Host minimo: tiene i nodi in stato e applica ogni modifica come farebbe un'app.
class _Host extends StatefulWidget {
  const _Host({required this.editable, required this.calls, required this.taps});
  final bool editable;
  final List<(String, String, Object?)> calls;
  final List<String> taps;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<CLGraphNode> nodes = const [
    CLGraphNode(id: 'A', type: 't', title: 'AAA'),
    CLGraphNode(id: 'B', type: 't', title: 'BBB', attributes: _attrs),
  ];

  @override
  Widget build(BuildContext context) => CLNodeGraph(
        nodes: nodes,
        edges: const [CLGraphEdge(id: 'A>B', fromNodeId: 'A', toNodeId: 'B', kind: CLGraphEdgeKind.prerequisite)],
        layout: (nodes, _) => {'A': Offset.zero, 'B': const Offset(300, 0)},
        onNodeTap: widget.taps.add,
        onAttributeChanged: !widget.editable
            ? null
            : (nodeId, name, value) {
                widget.calls.add((nodeId, name, value));
                setState(() {
                  nodes = [for (final n in nodes) n.id == nodeId ? n.withAttributeValue(name, value) : n];
                });
              },
      );
}

Future<(List<(String, String, Object?)>, List<String>)> _pump(WidgetTester tester, {bool editable = true}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final calls = <(String, String, Object?)>[];
  final taps = <String>[];
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: _Host(editable: editable, calls: calls, taps: taps))));
  await tester.pumpAndSettle();
  return (calls, taps);
}

Finder _cardOf(String title) => find.ancestor(of: find.text(title), matching: find.byType(Positioned)).first;

void main() {
  testWidgets('la card senza attributi resta 220×96, quella con attributi si allunga', (tester) async {
    await _pump(tester);
    expect(tester.getSize(_cardOf('AAA')), const Size(kCardW, kCardH));
    expect(tester.getSize(_cardOf('BBB')), const Size(kCardW, kCardH + 5 * kGraphAttributeRowH));
  });

  testWidgets('string: il testo viene emesso, il campo vuoto diventa null se nullable', (tester) async {
    final (calls, _) = await _pump(tester);
    final note = find.byType(TextField).at(0);
    await tester.enterText(note, 'ciao');
    await tester.pump();
    expect(calls.last, ('B', 'note', 'ciao'));
    await tester.enterText(note, '');
    await tester.pump();
    expect(calls.last, ('B', 'note', null));
  });

  testWidgets('numeric: virgola decimale accettata, testo non numerico non emesso', (tester) async {
    final (calls, _) = await _pump(tester);
    final price = find.byType(TextField).at(1);
    expect(tester.widget<TextField>(price).controller!.text, '10'); // default
    await tester.enterText(price, '3,5');
    await tester.pump();
    expect(calls.last, ('B', 'prezzo', 3.5));
    final before = calls.length;
    await tester.enterText(price, '-');
    await tester.pump();
    expect(calls.length, before); // numero non valido: nessuna emissione
    await tester.enterText(price, '');
    await tester.pump();
    expect(calls.length, before); // non nullable: vuoto non emesso
  });

  testWidgets('enumeration: scelta dal menu e voce "—" per azzerare', (tester) async {
    final (calls, _) = await _pump(tester);
    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('WhatsApp').last);
    await tester.pumpAndSettle();
    expect(calls.last, ('B', 'canale', 'WhatsApp'));
    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('—').last);
    await tester.pumpAndSettle();
    expect(calls.last, ('B', 'canale', null));
  });

  testWidgets('boolean: tre stati se nullable, non nullable senza valore diventa false', (tester) async {
    final (calls, _) = await _pump(tester);
    final attivo = find.byType(Checkbox).at(0);
    await tester.tap(attivo);
    await tester.pump();
    expect(calls.last, ('B', 'attivo', false)); // null → false
    await tester.tap(attivo);
    await tester.pump();
    expect(calls.last, ('B', 'attivo', true));
    await tester.tap(attivo);
    await tester.pump();
    expect(calls.last, ('B', 'attivo', null)); // nullable: torna a null
    final confermato = find.byType(Checkbox).at(1);
    await tester.tap(confermato);
    await tester.pump();
    expect(calls.last, ('B', 'confermato', false)); // missing → false
    await tester.tap(confermato);
    await tester.pump();
    expect(calls.last, ('B', 'confermato', true));
    await tester.tap(confermato);
    await tester.pump();
    expect(calls.last, ('B', 'confermato', false)); // non nullable: mai null
  });

  testWidgets('il drag dentro la sezione attributi non sposta il nodo, quello sull\'intestazione sì', (tester) async {
    final (_, taps) = await _pump(tester);
    final start = tester.getTopLeft(find.text('BBB'));
    await tester.drag(find.byType(TextField).at(0), const Offset(120, 60));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('BBB')), start);
    expect(taps, contains('B')); // interagire con un input seleziona il nodo
    await tester.drag(find.text('BBB'), const Offset(120, 60));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('BBB')), isNot(start));
  });

  testWidgets('i campi si toccano anche su una card oltre la misura della viewport', (tester) async {
    tester.view.physicalSize = const Size(600, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final taps = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CLNodeGraph(
          nodes: const [
            CLGraphNode(id: 'A', type: 't', title: 'AAA'),
            CLGraphNode(id: 'B', type: 't', title: 'BBB', attributes: _attrs),
          ],
          edges: const [],
          // B cade oltre i 600 px della viewport in coordinate canvas: il fit riduce lo zoom.
          layout: (nodes, _) => {'A': Offset.zero, 'B': const Offset(1500, 0)},
          onNodeTap: taps.add,
          onAttributeChanged: (_, __, ___) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final field = find.byType(TextField).first;
    await tester.tap(field);
    await tester.pump();
    expect(taps, contains('B'));
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
  });

  testWidgets('senza onAttributeChanged i valori sono in sola lettura', (tester) async {
    await _pump(tester, editable: false);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('10'), findsOneWidget); // default del prezzo
    expect(find.text('note'), findsOneWidget);
  });
}
