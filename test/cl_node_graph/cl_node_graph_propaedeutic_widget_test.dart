import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_node_graph.widget.dart';

const _nodes = [
  CLGraphNode(id: 'A', type: 'lesson', title: 'Lezione A'),
  CLGraphNode(id: 'B', type: 'lesson', title: 'Lezione B'),
  CLGraphNode(id: 'X', type: 'lesson', title: 'Lezione X'),
];

class _Calls {
  final created = <(String, String, CLGraphEdgeKind)>[];
  final rejected = <(String, String, String)>[];
  final deleted = <(String, CLGraphEdgeKind)>[];
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
        layout: (nodes, _) => {'A': Offset.zero, 'B': const Offset(320, 0), 'X': const Offset(640, 0)},
        canConnect: (_) => true,
        canConnectPropaedeutic: (_) => true,
        propaedeuticProblem: (from, to) => to.id == 'X' ? 'Solo lezioni dello stesso corso' : null,
        onEdgeCreate: (from, to, kind) => calls.created.add((from, to, kind)),
        onEdgeDelete: (id, kind) => calls.deleted.add((id, kind)),
        onConnectionRejected: (from, to, reason) => calls.rejected.add((from, to, reason)),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return calls;
}

Finder _cardOf(String title) => find.ancestor(of: find.text(title), matching: find.byType(Positioned)).first;

/// Rombo OUT: bordo destro, kPropDy sopra il centro.
Offset _propPort(WidgetTester tester, String title) {
  final r = tester.getRect(_cardOf(title));
  return Offset(r.right - 2, r.center.dy - kPropDy);
}

Offset _flowPort(WidgetTester tester, String title) {
  final r = tester.getRect(_cardOf(title));
  return Offset(r.right - 2, r.center.dy);
}

Future<void> _drag(WidgetTester tester, Offset from, String to) async {
  final gesture = await tester.startGesture(from);
  await gesture.moveTo(tester.getCenter(_cardOf(to)));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dal rombo nasce un arco propaedeutic, dal pallino un prerequisite', (tester) async {
    final calls = await _pump(tester);
    await _drag(tester, _propPort(tester, 'Lezione A'), 'Lezione B');
    await _drag(tester, _flowPort(tester, 'Lezione A'), 'Lezione B');
    expect(calls.created, [
      ('A', 'B', CLGraphEdgeKind.propaedeutic),
      ('A', 'B', CLGraphEdgeKind.prerequisite),
    ]);
  });

  testWidgets('la porta a rombo ha il tooltip «Propedeuticità»', (tester) async {
    await _pump(tester);
    expect(find.byTooltip('Propedeuticità'), findsNWidgets(3));
  });

  testWidgets('propaedeuticProblem: fumetto col motivo e onConnectionRejected', (tester) async {
    final calls = await _pump(tester);
    final gesture = await tester.startGesture(_propPort(tester, 'Lezione A'));
    await gesture.moveTo(tester.getCenter(_cardOf('Lezione X')));
    await tester.pump();
    expect(find.text('Solo lezioni dello stesso corso'), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls.created, isEmpty);
    expect(calls.rejected, [('A', 'X', 'Solo lezioni dello stesso corso')]);
  });

  testWidgets('propedeuticità già presente: rifiutata', (tester) async {
    final calls = await _pump(tester, edges: const [
      CLGraphEdge(id: 'p1', fromNodeId: 'A', toNodeId: 'B', kind: CLGraphEdgeKind.propaedeutic),
    ]);
    await _drag(tester, _propPort(tester, 'Lezione A'), 'Lezione B');
    expect(calls.created, isEmpty);
    expect(calls.rejected.single.$3, contains('già propedeutico'));
  });

  testWidgets('cestino sull\'arco di propedeuticità: onEdgeDelete col suo tipo', (tester) async {
    final calls = await _pump(tester, edges: const [
      CLGraphEdge(id: 'p1', fromNodeId: 'A', toNodeId: 'B', kind: CLGraphEdgeKind.propaedeutic),
    ]);
    final a = tester.getRect(_cardOf('Lezione A'));
    final b = tester.getRect(_cardOf('Lezione B'));
    final mid = Offset((a.right + b.left) / 2, a.center.dy - kPropDy);
    await tester.tapAt(mid); // seleziona l'arco ⇒ compare il cestino
    await tester.pumpAndSettle();
    await tester.tapAt(mid); // tap sul cestino
    await tester.pumpAndSettle();
    expect(calls.deleted, [('p1', CLGraphEdgeKind.propaedeutic)]);
  });

  testWidgets('arco non eliminabile: nessun cestino', (tester) async {
    final calls = await _pump(tester, edges: const [
      CLGraphEdge(id: 's1', fromNodeId: 'A', toNodeId: 'B', kind: CLGraphEdgeKind.prerequisite, deletable: false),
    ]);
    final a = tester.getRect(_cardOf('Lezione A'));
    final b = tester.getRect(_cardOf('Lezione B'));
    final mid = Offset((a.right + b.left) / 2, a.center.dy);
    await tester.tapAt(mid);
    await tester.pumpAndSettle();
    await tester.tapAt(mid);
    await tester.pumpAndSettle();
    expect(calls.deleted, isEmpty);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
