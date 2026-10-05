import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_node_graph.widget.dart';

const _nodes = [
  CLGraphNode(
    id: 'T',
    type: 'trigger',
    title: 'Trigger',
    connectionRules: CLGraphConnectionRules(inputTypes: {}, outputTypes: {'action'}, minOutputs: 1),
  ),
  CLGraphNode(id: 'A', type: 'action', title: 'Azione', connectionRules: CLGraphConnectionRules(outputTypes: {'end'})),
  CLGraphNode(id: 'E', type: 'end', title: 'Fine', connectionRules: CLGraphConnectionRules(outputTypes: {}, minInputs: 1)),
];

String _label(String t) => switch (t) {
      'action' => 'Azione',
      'end' => 'Fine',
      _ => t,
    };

class _Calls {
  final created = <(String, String)>[];
  final rejected = <(String, String, String)>[];
}

Future<_Calls> _pump(WidgetTester tester, {List<CLGraphEdge> edges = const []}) async {
  tester.view.physicalSize = const Size(1200, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final calls = _Calls();
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: CLNodeGraph(
        nodes: _nodes,
        edges: edges,
        layout: (nodes, _) => {'T': Offset.zero, 'A': const Offset(320, 0), 'E': const Offset(640, 0)},
        canConnect: (_) => true,
        typeLabel: _label,
        onEdgeCreate: (from, to, _) => calls.created.add((from, to)),
        onConnectionRejected: (from, to, reason) => calls.rejected.add((from, to, reason)),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return calls;
}

Finder _cardOf(String title) => find.ancestor(of: find.text(title), matching: find.byType(Positioned)).first;

Offset _outPort(WidgetTester tester, String title) {
  final r = tester.getRect(_cardOf(title));
  return Offset(r.right - 2, r.center.dy);
}

Future<void> _connect(WidgetTester tester, String from, String to) async {
  final gesture = await tester.startGesture(_outPort(tester, from));
  await gesture.moveTo(tester.getCenter(_cardOf(to)));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bersaglio ammesso: onEdgeCreate', (tester) async {
    final calls = await _pump(tester);
    await _connect(tester, 'Trigger', 'Azione');
    expect(calls.created, [('T', 'A')]);
    expect(calls.rejected, isEmpty);
  });

  testWidgets('bersaglio non ammesso: fumetto col motivo durante il trascinamento, poi onConnectionRejected', (tester) async {
    final calls = await _pump(tester);
    final gesture = await tester.startGesture(_outPort(tester, 'Trigger'));
    await gesture.moveTo(tester.getCenter(_cardOf('Fine')));
    await tester.pump();
    expect(find.text('«Trigger» può proseguire solo verso: Azione'), findsOneWidget);
    // I bersagli non ammessi sono attenuati, quello ammesso no.
    expect(find.ancestor(of: find.text('Fine'), matching: find.byType(Opacity)), findsOneWidget);
    expect(find.ancestor(of: find.text('Azione'), matching: find.byType(Opacity)), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls.created, isEmpty);
    expect(calls.rejected, [('T', 'E', '«Trigger» può proseguire solo verso: Azione')]);
    expect(find.textContaining('può proseguire'), findsNothing); // fumetto sparito
  });

  testWidgets('nodo senza uscite: nessuna porta OUT, il trascinamento dal bordo non collega', (tester) async {
    final calls = await _pump(tester);
    await _connect(tester, 'Fine', 'Azione');
    expect(calls.created, isEmpty);
    expect(calls.rejected, isEmpty);
  });

  testWidgets('avvisi dei minimi nella card, spariti quando il collegamento c\'è', (tester) async {
    await _pump(tester);
    expect(find.text('Manca il collegamento in uscita'), findsOneWidget); // Trigger
    expect(find.text('Manca il collegamento in ingresso'), findsOneWidget); // Fine
    await _pump(tester, edges: const [
      CLGraphEdge(id: 'T>A', fromNodeId: 'T', toNodeId: 'A', kind: CLGraphEdgeKind.prerequisite),
      CLGraphEdge(id: 'A>E', fromNodeId: 'A', toNodeId: 'E', kind: CLGraphEdgeKind.prerequisite),
    ]);
    expect(find.textContaining('Manca il collegamento'), findsNothing);
  });

  testWidgets('arco già presente: rifiutato', (tester) async {
    final calls = await _pump(tester, edges: const [
      CLGraphEdge(id: 'T>A', fromNodeId: 'T', toNodeId: 'A', kind: CLGraphEdgeKind.prerequisite),
    ]);
    await _connect(tester, 'Trigger', 'Azione');
    expect(calls.created, isEmpty);
    expect(calls.rejected.single.$3, contains('già collegato'));
  });
}
