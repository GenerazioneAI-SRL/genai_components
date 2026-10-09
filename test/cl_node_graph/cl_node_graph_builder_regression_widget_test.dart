import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_edge_painter.dart';

import 'flow_test_utils.dart';

// Configurazione del Builder del piano formativo (skillera_hr,
// training_plan_builder_canvas.widget.dart): moduli, sequenze (corso/esame) e
// lezioni, clModuleFlowLayout, pallino solo sulle sequenze, rombo su sequenze e
// lezioni, triangolino sui corsi, azioni ▲▼. Nessuno dei parametri nuovi.
const _nodes = [
  CLGraphNode(id: 'm1', type: 'module', title: 'Modulo 1', actions: [
    CLGraphNodeAction(id: 'up', icon: Icons.arrow_upward),
    CLGraphNodeAction(id: 'down', icon: Icons.arrow_downward),
  ]),
  CLGraphNode(id: 's1', type: 'sequence', title: 'Corso 1'),
  CLGraphNode(id: 's2', type: 'sequence', title: 'Esame 1'),
  CLGraphNode(id: 'l1', type: 'lesson', title: 'Lezione 1'),
];

const _edges = [
  CLGraphEdge(id: 'c1', fromNodeId: 'm1', toNodeId: 's1', kind: CLGraphEdgeKind.containment),
  CLGraphEdge(id: 'c2', fromNodeId: 'm1', toNodeId: 's2', kind: CLGraphEdgeKind.containment),
  CLGraphEdge(id: 'k1', fromNodeId: 's1', toNodeId: 'l1', kind: CLGraphEdgeKind.lessonLink),
];

class _Calls {
  final created = <(String, String, CLGraphEdgeKind)>[];
  final actions = <(String, String)>[];
  final taps = <String>[];
}

Future<_Calls> _pump(WidgetTester tester) async {
  setFlowView(tester);
  final calls = _Calls();
  await pumpGraph(
    tester,
    CLNodeGraph(
      nodes: _nodes,
      edges: _edges,
      layout: clModuleFlowLayout,
      showArrangeButton: true,
      canConnect: (n) => n.type == 'sequence',
      canConnectPropaedeutic: (n) => n.type == 'sequence' || n.type == 'lesson',
      propaedeuticTooltip: 'Propedeuticità: trascina sull\'elemento che la richiede',
      showOutPort: (n) => n.type == 'module',
      showLessonPort: (n) => n.id == 's1',
      onNodeTap: calls.taps.add,
      onNodeAction: (id, action, _) => calls.actions.add((id, action)),
      onEdgeCreate: (from, to, kind) => calls.created.add((from, to, kind)),
    ),
  );
  return calls;
}

Offset _pos(WidgetTester tester, String title) {
  final p = cardPositioned(tester, title);
  return Offset(p.left!, p.top!);
}

void main() {
  testWidgets('Builder: posizioni = clModuleFlowLayout, nessun elemento delle novità', (tester) async {
    await _pump(tester);
    final layout = clModuleFlowLayout(_nodes, _edges);
    for (final n in _nodes) {
      expect(_pos(tester, n.title), layout[n.id], reason: n.id);
    }
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<CLGraphEdgePainter>()
        .single;
    expect(painter.flowEnds, isEmpty);
    expect(painter.highlightedEdgeIds, isEmpty);
    // Card della misura di sempre (nessuna riga di porte) e nessun bollino.
    expect(cardPositioned(tester, 'Corso 1').height, kCardH);
    expect(find.byIcon(Icons.priority_high), findsNothing);
    expect(find.byType(DragTarget<CLNodePaletteItem>), findsNothing);
    expect(find.byTooltip('Propedeuticità: trascina sull\'elemento che la richiede'), findsNWidgets(3));
  });

  testWidgets('Builder: pallino → prerequisite, rombo → propaedeutic, azioni e tap', (tester) async {
    final calls = await _pump(tester);
    final s1 = cardRect(tester, 'Corso 1');
    final s = s1.width / kCardW;
    await dragFromTo(tester, Offset(s1.right - 2, s1.center.dy), cardRect(tester, 'Esame 1').center);
    await dragFromTo(tester, Offset(s1.right - 2, s1.center.dy - kPropDy * s), cardRect(tester, 'Lezione 1').center);
    expect(calls.created, [
      ('s1', 's2', CLGraphEdgeKind.prerequisite),
      ('s1', 'l1', CLGraphEdgeKind.propaedeutic),
    ]);
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();
    expect(calls.actions, [('m1', 'down')]);
    await tester.tap(find.text('Esame 1'));
    expect(calls.taps.last, 's2');
  });

  testWidgets('Builder: drag effimero senza limiti, «Ordina» riporta al layout', (tester) async {
    await _pump(tester);
    final before = _pos(tester, 'Modulo 1');
    final r = cardRect(tester, 'Modulo 1');
    final s = r.width / kCardW;
    await dragFromTo(tester, r.center, r.center - Offset(80 * s, 0));
    // Come prima: il nodo può uscire a sinistra (nessun clamp senza posizioni salvate).
    expect(_pos(tester, 'Modulo 1').dx, closeTo(before.dx - 80, 1));
    await tester.tap(find.text('Ordina'));
    await tester.pumpAndSettle();
    expect(_pos(tester, 'Modulo 1'), before);
  });
}
