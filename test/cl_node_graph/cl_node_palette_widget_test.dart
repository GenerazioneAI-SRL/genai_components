import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import 'flow_test_utils.dart';

const _items = [
  CLNodePaletteItem(type: 'TRIGGER_PLAN_ENTRY', label: 'Entra nel piano', category: 'Inneschi', icon: Icons.login),
  CLNodePaletteItem(type: 'IF', label: 'Se', category: 'Logica', icon: Icons.call_split, description: 'Due rami: sì e no'),
  CLNodePaletteItem(type: 'SWITCH', label: 'Più casi', category: 'Logica', icon: Icons.alt_route),
  CLNodePaletteItem(type: 'EMAIL', label: 'Invia email', category: 'Azioni', icon: Icons.mail_outline),
  CLNodePaletteItem(type: 'CERTIFICATE', label: 'Attestato', category: 'Azioni', description: 'Qualità verificata'),
];

void main() {
  test('filterAndGroup: per categoria nell\'ordine di comparsa, ricerca senza accenti', () {
    final all = CLNodePalette.filterAndGroup(_items, '');
    expect(all.keys, ['Inneschi', 'Logica', 'Azioni']);
    expect(all['Logica']!.map((i) => i.type), ['IF', 'SWITCH']);
    expect(CLNodePalette.filterAndGroup(_items, 'QUALITA').values.expand((x) => x).single.type, 'CERTIFICATE');
    expect(CLNodePalette.filterAndGroup(_items, 'email').keys, ['Azioni']);
    expect(CLNodePalette.filterAndGroup(_items, 'zzz'), isEmpty);
  });

  testWidgets('forma estesa: gruppi, ricerca e tocco', (tester) async {
    setFlowView(tester);
    final picked = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 260, child: CLNodePalette(items: _items, onItemSelected: (i) => picked.add(i.type))),
      ),
    ));
    expect(find.text('LOGICA'), findsOneWidget);
    expect(find.text('Invia email'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'se');
    await tester.pump();
    expect(find.text('Invia email'), findsNothing);
    expect(find.text('Se'), findsOneWidget);
    await tester.tap(find.text('Se'));
    expect(picked, ['IF']);
    await tester.enterText(find.byType(TextField), 'nulla di simile');
    await tester.pump();
    expect(find.text('Nessun blocco trovato'), findsOneWidget);
  });

  testWidgets('trascinata sul canvas: onNodeDrop(type, posizione con la card centrata)', (tester) async {
    setFlowView(tester);
    final drops = <(String, Offset)>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(children: [
          const SizedBox(width: 260, child: CLNodePalette(items: _items, compact: false)),
          Expanded(
            child: CLNodeGraph(
              nodes: const [CLGraphNode(id: 'a', type: 't', title: 'Nodo A')],
              edges: const [],
              nodePositions: const {'a': Offset(0, 0)},
              onNodeDrop: (type, pos) => drops.add((type, pos)),
            ),
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
    final card = cardRect(tester, 'Nodo A');
    final s = card.width / kCardW;
    // Rilascio 400 px (canvas) a destra e 200 sotto l'angolo della card A.
    final target = card.topLeft + Offset(400 * s, 200 * s);
    final gesture = await tester.startGesture(tester.getCenter(find.text('Invia email')));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveTo(target);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(drops.single.$1, 'EMAIL');
    expect(drops.single.$2.dx, closeTo(400 - kCardW / 2, 1));
    expect(drops.single.$2.dy, closeTo(200 - kCardH / 2, 1));
  });

  testWidgets('forma compatta: pulsante-menu, foglio dal basso, scelta', (tester) async {
    setFlowView(tester, size: const Size(390, 800));
    final picked = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: CLNodePalette(items: _items, onItemSelected: (i) => picked.add(i.type)),
        ),
      ),
    ));
    expect(find.text('Invia email'), findsNothing);
    await tester.tap(find.text('Aggiungi blocco'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'attestato');
    await tester.pump();
    await tester.tap(find.text('Attestato'));
    await tester.pumpAndSettle();
    expect(picked, ['CERTIFICATE']);
    expect(find.text('Attestato'), findsNothing); // foglio chiuso
  });
}
