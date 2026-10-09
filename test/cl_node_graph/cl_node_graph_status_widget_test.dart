import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import 'flow_test_utils.dart';

const _nodes = [
  CLGraphNode(id: 'a', type: 't', title: 'Fatto'),
  CLGraphNode(id: 'b', type: 't', title: 'Attesa'),
  CLGraphNode(id: 'c', type: 't', title: 'Rotto'),
  CLGraphNode(id: 'd', type: 't', title: 'Saltato'),
  CLGraphNode(id: 'e', type: 't', title: 'Invalido'),
];

Future<void> _pump(WidgetTester tester, {String? selected, VoidCallback? onBackgroundTap}) async {
  setFlowView(tester);
  await pumpGraph(
    tester,
    CLNodeGraph(
      nodes: _nodes,
      edges: const [],
      selectedNodeId: selected,
      onBackgroundTap: onBackgroundTap,
      nodePositions: const {
        'a': Offset(0, 0),
        'b': Offset(300, 0),
        'c': Offset(600, 0),
        'd': Offset(0, 200),
        'e': Offset(300, 200),
      },
      nodeStatuses: const {
        'a': CLGraphNodeStatus.done,
        'b': CLGraphNodeStatus.waiting,
        'c': CLGraphNodeStatus.error,
        'd': CLGraphNodeStatus.skipped,
      },
      nodeErrors: const {
        'e': ['Manca il destinatario', 'Testo vuoto'],
      },
    ),
  );
}

Color? _borderColor(WidgetTester tester, String title) {
  final box = tester.widget<Container>(find.ancestor(of: find.text(title), matching: find.byType(Container)).first);
  return ((box.decoration as BoxDecoration).border as Border).top.color;
}

void main() {
  testWidgets('stati: bollino con tooltip e bordo del colore dello stato', (tester) async {
    await _pump(tester);
    final theme = CLTheme.of(tester.element(find.byType(CLNodeGraph)));
    for (final t in ['Fatto', 'In attesa', 'Errore', 'Saltato']) {
      expect(find.byTooltip(t), findsOneWidget, reason: t);
    }
    expect(_borderColor(tester, 'Fatto'), theme.success);
    expect(_borderColor(tester, 'Attesa'), theme.warning);
    expect(_borderColor(tester, 'Rotto'), theme.danger);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
  });

  testWidgets('saltato: card attenuata', (tester) async {
    await _pump(tester);
    final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Saltato'), matching: find.byType(Opacity)).first);
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('errori di validazione: bordo danger e messaggi nel tooltip', (tester) async {
    await _pump(tester);
    final theme = CLTheme.of(tester.element(find.byType(CLNodeGraph)));
    expect(_borderColor(tester, 'Invalido'), theme.danger);
    expect(find.byTooltip('Manca il destinatario\nTesto vuoto'), findsOneWidget);
  });

  testWidgets('lettore di schermo: titolo, stato ed errori', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    expect(find.bySemanticsLabel(RegExp(r'^Rotto, Errore')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Invalido, 2 errori')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('selezione: il bordo della selezione vince sullo stato', (tester) async {
    await _pump(tester, selected: 'a');
    final theme = CLTheme.of(tester.element(find.byType(CLNodeGraph)));
    expect(_borderColor(tester, 'Fatto'), theme.primary);
  });

  testWidgets('tocco nel vuoto: onBackgroundTap', (tester) async {
    var taps = 0;
    await _pump(tester, onBackgroundTap: () => taps++);
    await tester.tapAt(const Offset(1350, 20));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
