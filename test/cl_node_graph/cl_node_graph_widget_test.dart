import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  testWidgets('mounts without exceptions and reports no tap initially', (tester) async {
    String? tapped;
    final nodes = const [
      CLGraphNode(id: 'm', type: 'module', title: 'Modulo'),
      CLGraphNode(id: 'c1', type: 'course', title: 'Corso 1'),
    ];
    final edges = const [
      CLGraphEdge(id: 'c:m>c1', fromNodeId: 'm', toNodeId: 'c1', kind: CLGraphEdgeKind.containment),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: CLNodeGraph(nodes: nodes, edges: edges, onNodeTap: (id) => tapped = id),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100)); // postFrame rebuild
    await tester.pump(const Duration(milliseconds: 100));

    // Il canvas di fl_nodes usa RenderObject/shader custom: in ambiente headless
    // (`flutter test`) l'asset dello shader `grid.frag` non è caricabile, quindi il
    // canvas non dipinge i `Text` dei nodi. Verifichiamo l'unica cosa affidabile:
    // il widget si costruisce e monta (nessuna eccezione del NOSTRO codice), è
    // presente in albero, e non emette tap spontanei.
    // Drena l'eventuale eccezione dello shader (asset del motore, non del wrapper).
    final ex = tester.takeException();
    if (ex != null) {
      expect(ex.toString(), contains('grid.frag'));
    }
    expect(find.byType(CLNodeGraph), findsOneWidget);
    expect(tapped, isNull);
  });
}
