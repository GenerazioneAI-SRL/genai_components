import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import 'flow_test_utils.dart';

class _Calls {
  final flow = <(CLGraphPortRef, CLGraphPortRef)>[];
  final legacy = <(String, String, CLGraphEdgeKind)>[];
  final rejected = <(String, String, String)>[];
}

Future<_Calls> _pump(
  WidgetTester tester, {
  List<CLGraphEdge> edges = const [],
  bool flowCallback = true,
  String? Function(CLGraphPortRef, CLGraphPortRef)? canConnectPorts,
}) async {
  setFlowView(tester);
  final calls = _Calls();
  await pumpGraph(
    tester,
    CLNodeGraph(
      nodes: flowNodes,
      edges: edges,
      nodePositions: flowPositions,
      onFlowEdgeCreate: flowCallback ? (from, to) => calls.flow.add((from, to)) : null,
      onEdgeCreate: (from, to, kind) => calls.legacy.add((from, to, kind)),
      onConnectionRejected: (from, to, reason) => calls.rejected.add((from, to, reason)),
      canConnectPorts: canConnectPorts,
    ),
  );
  return calls;
}

void main() {
  testWidgets('porte con nome: pallini con tooltip ed etichette sul bordo', (tester) async {
    await _pump(tester);
    for (final label in ['avvio', 'ingresso', 'sì', 'no', 'entra A', 'primo', 'secondo']) {
      expect(find.byTooltip(label), findsOneWidget, reason: label);
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Ingresso sul bordo sinistro, uscite sul destro, «sì» sopra «no».
    final ifCard = cardRect(tester, 'Ha superato il test?');
    expect(portCenter(tester, 'ingresso').dx, closeTo(ifCard.left, 1));
    expect(portCenter(tester, 'sì').dx, closeTo(ifCard.right, 1));
    expect(portCenter(tester, 'sì').dy, lessThan(portCenter(tester, 'no').dy));
    // Le righe di porte allungano la card oltre kCardH.
    expect(ifCard.height / (ifCard.width / kCardW), greaterThan(kCardH));
  });

  testWidgets('drag da «no» alla card: onFlowEdgeCreate con le porte', (tester) async {
    final calls = await _pump(tester);
    await dragFromTo(tester, portCenter(tester, 'no'), cardRect(tester, 'Fine A').center);
    expect(calls.flow, [(const CLGraphPortRef('if', 'no'), const CLGraphPortRef('end1', 'in'))]);
    expect(calls.legacy, isEmpty);
  });

  testWidgets('più ingressi: vale quello più vicino al cursore', (tester) async {
    final calls = await _pump(tester);
    await dragFromTo(tester, portCenter(tester, 'sì'), portCenter(tester, 'secondo'));
    expect(calls.flow.single.$2, const CLGraphPortRef('end2', 'b'));
  });

  testWidgets('rilascio sul pallino d\'ingresso fuori dalla card: arco creato', (tester) async {
    final calls = await _pump(tester);
    final dot = portCenter(tester, 'primo');
    await dragFromTo(tester, portCenter(tester, 'sì'), dot.translate(-4, 0));
    expect(calls.flow.single.$2, const CLGraphPortRef('end2', 'a'));
  });

  testWidgets('senza onFlowEdgeCreate: onEdgeCreate con CLGraphEdgeKind.flow', (tester) async {
    final calls = await _pump(tester, flowCallback: false);
    await dragFromTo(tester, portCenter(tester, 'avvio'), cardRect(tester, 'Ha superato il test?').center);
    expect(calls.legacy, [('start', 'if', CLGraphEdgeKind.flow)]);
  });

  testWidgets('canConnectPorts: fumetto col motivo, poi onConnectionRejected', (tester) async {
    final calls = await _pump(
      tester,
      canConnectPorts: (from, to) => from.portId == 'yes' && to.nodeId == 'end1' ? 'Il ramo «sì» non può finire qui' : null,
    );
    final gesture = await tester.startGesture(portCenter(tester, 'sì'));
    await gesture.moveTo(cardRect(tester, 'Fine A').center);
    await tester.pump();
    expect(find.text('Il ramo «sì» non può finire qui'), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls.flow, isEmpty);
    expect(calls.rejected, [('if', 'end1', 'Il ramo «sì» non può finire qui')]);
  });

  testWidgets('maxConnections dell\'ingresso e arco già presente: rifiutati', (tester) async {
    final calls = await _pump(tester, edges: const [
      CLGraphEdge(id: 'e1', fromNodeId: 'if', toNodeId: 'end1', kind: CLGraphEdgeKind.flow, fromPortId: 'yes', toPortId: 'in'),
    ]);
    await dragFromTo(tester, portCenter(tester, 'no'), cardRect(tester, 'Fine A').center);
    await dragFromTo(tester, portCenter(tester, 'sì'), cardRect(tester, 'Fine A').center);
    expect(calls.flow, isEmpty);
    expect(calls.rejected.map((r) => r.$3), [
      contains('è già collegato'),
      contains('è già collegato'),
    ]);
  });

  testWidgets('verso un nodo senza ingressi: rifiutato', (tester) async {
    final calls = await _pump(tester);
    await dragFromTo(tester, portCenter(tester, 'sì'), cardRect(tester, 'Entra nel piano').center);
    expect(calls.flow, isEmpty);
    expect(calls.rejected.single.$3, contains('non ha ingressi'));
  });

  testWidgets('senza callback di creazione le porte sono decorative', (tester) async {
    setFlowView(tester);
    final rejected = <String>[];
    await pumpGraph(
      tester,
      CLNodeGraph(
        nodes: flowNodes,
        edges: const [],
        nodePositions: flowPositions,
        onConnectionRejected: (_, __, reason) => rejected.add(reason),
      ),
    );
    final gesture = await tester.startGesture(portCenter(tester, 'sì'));
    await gesture.moveTo(cardRect(tester, 'Fine B').center);
    await tester.pump();
    // Nessun collegamento in corso: nessun bersaglio attenuato.
    expect(find.byWidgetPredicate((w) => w is Opacity && w.opacity < 0.5), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(rejected, isEmpty);
  });
}
