import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

/// Nodi d'esempio dell'editor del flusso: inizio → SE (sì/no) → due fini.
const flowNodes = [
  CLGraphNode(
    id: 'start',
    type: 'TRIGGER_PLAN_ENTRY',
    title: 'Entra nel piano',
    outputPorts: [CLGraphPort(id: 'out', label: 'avvio')],
  ),
  CLGraphNode(
    id: 'if',
    type: 'IF',
    title: 'Ha superato il test?',
    inputPorts: [CLGraphPort(id: 'in', label: 'ingresso')],
    outputPorts: [CLGraphPort(id: 'yes', label: 'sì'), CLGraphPort(id: 'no', label: 'no')],
  ),
  CLGraphNode(
    id: 'end1',
    type: 'END',
    title: 'Fine A',
    inputPorts: [CLGraphPort(id: 'in', label: 'entra A', maxConnections: 1)],
  ),
  CLGraphNode(
    id: 'end2',
    type: 'END',
    title: 'Fine B',
    inputPorts: [CLGraphPort(id: 'a', label: 'primo'), CLGraphPort(id: 'b', label: 'secondo')],
  ),
];

const flowPositions = {
  'start': Offset(0, 0),
  'if': Offset(320, 0),
  'end1': Offset(640, 0),
  'end2': Offset(640, 200),
};

void setFlowView(WidgetTester tester, {Size size = const Size(1400, 800)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> pumpGraph(WidgetTester tester, Widget graph) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: graph)));
  await tester.pumpAndSettle();
}

/// Rettangolo (globale) della card col titolo [title].
Rect cardRect(WidgetTester tester, String title) =>
    tester.getRect(find.ancestor(of: find.text(title), matching: find.byType(Positioned)).first);

/// Positioned della card (coordinate canvas: left/top).
Positioned cardPositioned(WidgetTester tester, String title) {
  final all = find.ancestor(of: find.text(title), matching: find.byType(Positioned)).evaluate().toList();
  // Il più esterno sotto lo Stack del canvas è quello con width == kCardW.
  for (final e in all) {
    final w = e.widget as Positioned;
    if (w.width == kCardW) return w;
  }
  throw StateError('card $title non trovata');
}

/// Centro (globale) del pallino della porta con tooltip [tooltip].
Offset portCenter(WidgetTester tester, String tooltip) => tester.getCenter(find.byTooltip(tooltip));

Future<void> dragFromTo(WidgetTester tester, Offset from, Offset to) async {
  final gesture = await tester.startGesture(from);
  await gesture.moveTo(Offset.lerp(from, to, 0.5)!);
  await tester.pump();
  await gesture.moveTo(to);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}
