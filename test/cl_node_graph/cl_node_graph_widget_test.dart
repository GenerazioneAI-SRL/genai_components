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

  testWidgets('rebuild on data change empties the graph (no duplicate nodes) and does not fire consumer callbacks', (tester) async {
    // Contatori dei callback consumer: NESSUNO deve scattare durante un rebuild
    // programmatico (né tap, né create/delete link, né reparent).
    var linkCreated = 0;
    var linkDeleted = 0;
    var reparented = 0;
    var tapped = 0;

    final graphKey = GlobalKey<State<CLNodeGraph>>();

    // Prima configurazione: 2 nodi + 1 arco di contenimento.
    const initialNodes = [
      CLGraphNode(id: 'm', type: 'module', title: 'Modulo'),
      CLGraphNode(id: 'c1', type: 'course', title: 'Corso 1'),
    ];
    const initialEdges = [
      CLGraphEdge(id: 'e:m>c1', fromNodeId: 'm', toNodeId: 'c1', kind: CLGraphEdgeKind.containment),
    ];

    // Seconda configurazione: insieme DIVERSO — 3 nodi + 2 archi — così
    // `_graphChanged` scatta e `didUpdateWidget` invoca `_rebuildGraph`.
    const nextNodes = [
      CLGraphNode(id: 'a', type: 'module', title: 'A'),
      CLGraphNode(id: 'b', type: 'course', title: 'B'),
      CLGraphNode(id: 'c', type: 'course', title: 'C'),
    ];
    const nextEdges = [
      CLGraphEdge(id: 'e:a>b', fromNodeId: 'a', toNodeId: 'b', kind: CLGraphEdgeKind.containment),
      CLGraphEdge(id: 'e:a>c', fromNodeId: 'a', toNodeId: 'c', kind: CLGraphEdgeKind.containment),
    ];

    Widget buildGraph(List<CLGraphNode> nodes, List<CLGraphEdge> edges) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: CLNodeGraph(
              key: graphKey,
              nodes: nodes,
              edges: edges,
              onNodeTap: (_) => tapped++,
              onLinkCreate: (_, __) async {
                linkCreated++;
                return true;
              },
              onLinkDelete: (_) => linkDeleted++,
              onReparent: (_, __) async {
                reparented++;
                return true;
              },
            ),
          ),
        ),
      );
    }

    // Primo mount (config iniziale).
    await tester.pumpWidget(buildGraph(initialNodes, initialEdges));
    await tester.pump(const Duration(milliseconds: 100)); // postFrame rebuild
    await tester.pump(const Duration(milliseconds: 100)); // drena eventi async del bus

    final ex1 = tester.takeException();
    if (ex1 != null) expect(ex1.toString(), contains('grid.frag'));

    final state = graphKey.currentState! as dynamic;
    expect(state.debugNodeCount, 2, reason: 'primo mount: 2 nodi');

    // Azzera i contatori dopo il primo mount: ci interessa solo il rebuild.
    linkCreated = 0;
    linkDeleted = 0;
    reparented = 0;
    tapped = 0;

    // Rebuild con dati diversi → didUpdateWidget → _rebuildGraph.
    await tester.pumpWidget(buildGraph(nextNodes, nextEdges));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100)); // drena eventi async del bus

    final ex2 = tester.takeException();
    if (ex2 != null) expect(ex2.toString(), contains('grid.frag'));

    // Il CUORE del bug: dopo un rebuild devono esserci 3 nodi (i nuovi), NON 5
    // (3 nuovi appesi ai 2 vecchi mai rimossi).
    expect(state.debugNodeCount, 3, reason: 'rebuild deve SVUOTARE il grafo, non appendere');

    // La cascata di rimozione link è programmatica: nessun callback consumer
    // deve essere scattato durante il rebuild.
    expect(linkDeleted, 0, reason: 'la cascata di rimozione non deve chiamare onLinkDelete');
    expect(linkCreated, 0, reason: 'i link ricreati da noi non devono chiamare onLinkCreate');
    expect(reparented, 0, reason: 'nessun reparent durante un rebuild');
    expect(tapped, 0, reason: 'nessun tap durante un rebuild');
  });

  testWidgets('rebuild diff-based: i nodi persistiti mantengono lo stesso id motore', (tester) async {
    // Regression del bug di reconciliation: con lo stesso insieme di clId, un
    // rebuild (innescato da un cambio di title) NON deve rigenerare gli id motore
    // dei nodi persistiti. Il vecchio codice rimuoveva/riaggiungeva tutto → id
    // sempre nuovi → churn di reconciliation → crash del RenderBox.
    final graphKey = GlobalKey<State<CLNodeGraph>>();

    const firstNodes = [
      CLGraphNode(id: 'a', type: 'module', title: 'A'),
      CLGraphNode(id: 'b', type: 'course', title: 'B'),
    ];
    const secondNodes = [
      CLGraphNode(id: 'a', type: 'module', title: 'A modificato'), // stesso clId, title diverso
      CLGraphNode(id: 'b', type: 'course', title: 'B'),
    ];
    const edges = [
      CLGraphEdge(id: 'e:a>b', fromNodeId: 'a', toNodeId: 'b', kind: CLGraphEdgeKind.containment),
    ];

    Widget buildGraph(List<CLGraphNode> nodes) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CLNodeGraph(key: graphKey, nodes: nodes, edges: edges),
            ),
          ),
        );

    await tester.pumpWidget(buildGraph(firstNodes));
    await tester.pump(const Duration(milliseconds: 100)); // postFrame rebuild
    await tester.pump(const Duration(milliseconds: 100)); // drena eventi async del bus
    final ex1 = tester.takeException();
    if (ex1 != null) expect(ex1.toString(), contains('grid.frag'));

    final state = graphKey.currentState! as dynamic;
    final flA = state.debugFlIdFor('a') as String?;
    final flB = state.debugFlIdFor('b') as String?;
    expect(flA, isNotNull);
    expect(flB, isNotNull);
    expect(state.debugNodeCount, 2);

    // Rebuild con stesso insieme di clId (solo title cambiato).
    await tester.pumpWidget(buildGraph(secondNodes));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    final ex2 = tester.takeException();
    if (ex2 != null) expect(ex2.toString(), contains('grid.frag'));

    // Il CUORE del fix: gli id motore dei nodi persistiti sono INVARIATI.
    expect(state.debugFlIdFor('a'), flA, reason: 'nodo persistito: id motore stabile');
    expect(state.debugFlIdFor('b'), flB, reason: 'nodo persistito: id motore stabile');
    expect(state.debugNodeCount, 2, reason: 'nessun duplicato dopo il rebuild');
  });
}
