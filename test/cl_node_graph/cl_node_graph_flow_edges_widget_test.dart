import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_edge_painter.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_geometry.dart';

import 'flow_test_utils.dart';

const _edges = [
  CLGraphEdge(id: 'e0', fromNodeId: 'start', toNodeId: 'if', kind: CLGraphEdgeKind.flow, fromPortId: 'out', toPortId: 'in'),
  CLGraphEdge(
    id: 'e1',
    fromNodeId: 'if',
    toNodeId: 'end2',
    kind: CLGraphEdgeKind.flow,
    fromPortId: 'no',
    toPortId: 'b',
    label: 'altrimenti',
  ),
];

Future<List<(String, CLGraphEdgeKind)>> _pump(WidgetTester tester, {Set<String>? highlighted}) async {
  setFlowView(tester);
  final deleted = <(String, CLGraphEdgeKind)>[];
  await pumpGraph(
    tester,
    CLNodeGraph(
      nodes: flowNodes,
      edges: _edges,
      nodePositions: flowPositions,
      onEdgeDelete: (id, kind) => deleted.add((id, kind)),
      highlightedEdgeIds: highlighted,
    ),
  );
  return deleted;
}

CLGraphEdgePainter _painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((c) => c.painter)
    .whereType<CLGraphEdgePainter>()
    .single;

/// Punto medio (globale) dell'arco tra i pallini [fromTip] e [toTip].
Offset _mid(WidgetTester tester, String fromTip, String toTip) =>
    Offset.lerp(portCenter(tester, fromTip), portCenter(tester, toTip), 0.5)!;

void main() {
  testWidgets('arco flow: estremi sulle porte dichiarate, etichetta a metà arco', (tester) async {
    await _pump(tester);
    final p = _painter(tester);
    expect(p.flowEnds.keys, containsAll(['e0', 'e1']));
    expect(find.text('altrimenti'), findsOneWidget);
    final label = tester.getCenter(find.text('altrimenti'));
    final mid = _mid(tester, 'no', 'secondo');
    expect((label - mid).distance, lessThan(4));
  });

  testWidgets('tap sull\'arco, poi sul cestino: onEdgeDelete con kind flow', (tester) async {
    final deleted = await _pump(tester);
    final mid = _mid(tester, 'no', 'secondo');
    await tester.tapAt(mid);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.text('altrimenti'), findsNothing); // il cestino prende il posto dell'etichetta
    await tester.tapAt(mid);
    await tester.pumpAndSettle();
    expect(deleted, [('e1', CLGraphEdgeKind.flow)]);
  });

  testWidgets('hover del mouse sulla curva: cestino visibile', (tester) async {
    await _pump(tester);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    // Un quarto della curva «no» → «secondo» (porte a righe diverse): lontano
    // dal segmento retto, vicino alla curva campionata.
    final a = portCenter(tester, 'no'), b = portCenter(tester, 'secondo');
    final onCurve = clSampledLinkSegments('e1', a, b, steps: 4)[0].b;
    expect(distanceToSegment(onCurve, a, b), greaterThan(16));
    await gesture.moveTo(onCurve);
    await tester.pump();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('Canc elimina l\'arco flow selezionato, Esc deseleziona', (tester) async {
    final deleted = await _pump(tester);
    final mid = _mid(tester, 'avvio', 'ingresso');
    await tester.tapAt(mid);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    await tester.tapAt(mid);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(deleted, [('e0', CLGraphEdgeKind.flow)]);
  });

  testWidgets('cammino percorso: archi passati al painter col colore success', (tester) async {
    await _pump(tester, highlighted: {'e0'});
    final p = _painter(tester);
    expect(p.highlightedEdgeIds, {'e0'});
    expect(p.highlightColor, CLTheme.of(tester.element(find.byType(CLNodeGraph))).success);
  });

  test('clFlowLayout: colonne per profondità, il primo ramo resta sulla riga del padre', () {
    final pos = clFlowLayout(flowNodes, const [
      CLGraphEdge(id: 'a', fromNodeId: 'start', toNodeId: 'if', kind: CLGraphEdgeKind.flow),
      CLGraphEdge(id: 'b', fromNodeId: 'if', toNodeId: 'end2', kind: CLGraphEdgeKind.flow, fromPortId: 'no'),
      CLGraphEdge(id: 'c', fromNodeId: 'if', toNodeId: 'end1', kind: CLGraphEdgeKind.flow, fromPortId: 'yes'),
    ]);
    expect(pos['start']!.dx, 0);
    expect(pos['if']!.dx, greaterThan(pos['start']!.dx));
    expect(pos['end1']!.dx, pos['end2']!.dx);
    expect(pos['end1']!.dy, pos['if']!.dy); // «sì» è la prima porta
    expect(pos['end2']!.dy, greaterThan(pos['end1']!.dy));
  });

  test('CLGraphJson: porte, porte degli archi ed etichetta fanno il giro; senza porte nessuna chiave nuova', () {
    const codec = CLGraphJson();
    final doc = CLGraphDocument(nodes: flowNodes, edges: _edges, view: const CLGraphView(layout: 'flow'));
    final back = codec.decode(codec.encode(doc));
    final ifNode = back.nodes.firstWhere((n) => n.id == 'if');
    expect(ifNode.outputPorts.map((p) => (p.id, p.label)), [('yes', 'sì'), ('no', 'no')]);
    expect(back.nodes.firstWhere((n) => n.id == 'end1').inputPorts.single.maxConnections, 1);
    final e1 = back.edges.firstWhere((e) => e.id == 'e1');
    expect((e1.kind, e1.fromPortId, e1.toPortId, e1.label), (CLGraphEdgeKind.flow, 'no', 'b', 'altrimenti'));
    expect(CLGraphJson.builtInLayouts['flow'], clFlowLayout);
    final plain = codec.encode(CLGraphDocument(
      nodes: const [CLGraphNode(id: 'x', type: 't', title: 'X')],
      edges: const [CLGraphEdge(id: 'y', fromNodeId: 'x', toNodeId: 'x', kind: CLGraphEdgeKind.prerequisite)],
    ));
    final text = jsonEncode(plain);
    for (final k in ['inputPorts', 'outputPorts', 'fromPortId', 'toPortId', '"label"']) {
      expect(text.contains(k), isFalse, reason: k);
    }
  });

  test('clFlowLayout: un ciclo non blocca il layout', () {
    final pos = clFlowLayout(flowNodes.sublist(1, 3), const [
      CLGraphEdge(id: 'a', fromNodeId: 'if', toNodeId: 'end1', kind: CLGraphEdgeKind.flow),
      CLGraphEdge(id: 'b', fromNodeId: 'end1', toNodeId: 'if', kind: CLGraphEdgeKind.flow),
    ]);
    expect(pos.keys, containsAll(['if', 'end1']));
  });
}
