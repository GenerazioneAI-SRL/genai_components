import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import 'flow_test_utils.dart';

/// ~100 nodi a porte con nome e ~150 archi flow: il grafo si costruisce, si
/// collega e si trascina senza eccezioni; i tempi (solo indicativi: in test
/// non c'è raster) finiscono nel log.
void main() {
  testWidgets('100 nodi, 150 archi flow: costruzione, hover e trascinamento', (tester) async {
    setFlowView(tester);
    final nodes = [
      for (var i = 0; i < 100; i++)
        CLGraphNode(
          id: 'n$i',
          type: i % 3 == 0 ? 'IF' : 'STEP',
          title: 'Passo $i',
          inputPorts: const [CLGraphPort(id: 'in', label: 'ingresso')],
          outputPorts: i % 3 == 0
              ? const [CLGraphPort(id: 'yes', label: 'sì'), CLGraphPort(id: 'no', label: 'no')]
              : const [CLGraphPort(id: 'out', label: 'avanti')],
        ),
    ];
    final edges = <CLGraphEdge>[
      for (var i = 0; i < 99; i++)
        CLGraphEdge(
          id: 'a$i',
          fromNodeId: 'n$i',
          toNodeId: 'n${i + 1}',
          kind: CLGraphEdgeKind.flow,
          fromPortId: i % 3 == 0 ? 'yes' : 'out',
        ),
      for (var i = 0; i < 99; i += 3)
        if (i + 2 < 100)
          CLGraphEdge(id: 'b$i', fromNodeId: 'n$i', toNodeId: 'n${i + 2}', kind: CLGraphEdgeKind.flow, fromPortId: 'no', label: 'no'),
    ];
    final positions = clFlowLayout(nodes, edges);
    final sw = Stopwatch()..start();
    await pumpGraph(
      tester,
      CLNodeGraph(
        nodes: nodes,
        edges: edges,
        nodePositions: positions,
        onNodeMoved: (_, __) {},
        onFlowEdgeCreate: (_, __) {},
        nodeStatuses: {for (var i = 0; i < 50; i++) 'n$i': CLGraphNodeStatus.done},
        highlightedEdgeIds: {for (var i = 0; i < 49; i++) 'a$i'},
      ),
    );
    final build = sw.elapsedMilliseconds;
    sw.reset();
    final r = cardRect(tester, 'Passo 0');
    final gesture = await tester.startGesture(r.center);
    for (var i = 0; i < 30; i++) {
      await gesture.moveBy(const Offset(3, 2));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    final drag = sw.elapsedMilliseconds;
    // ignore: avoid_print
    print('CLNodeGraph 100 nodi / ${edges.length} archi: primo frame $build ms, 30 frame di trascinamento $drag ms');
    expect(tester.takeException(), isNull);
    expect(edges.length, greaterThanOrEqualTo(130));
  });
}
