import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import 'flow_test_utils.dart';

const _items = [CLNodePaletteItem(type: 'IF', label: 'Se', category: 'Logica')];

Widget _layout({Widget? panel, VoidCallback? onClose}) => MaterialApp(
      home: Scaffold(
        body: CLNodeEditorLayout(
          palette: const CLNodePalette(items: _items),
          canvas: const CLNodeGraph(nodes: [CLGraphNode(id: 'a', type: 't', title: 'Nodo A')], edges: []),
          panel: panel,
          panelTitle: 'Configura «Se»',
          onPanelClose: onClose,
        ),
      ),
    );

void main() {
  testWidgets('schermo largo: palette | canvas | pannello affiancati', (tester) async {
    setFlowView(tester);
    var closed = 0;
    await tester.pumpWidget(_layout(panel: const Text('Condizione'), onClose: () => closed++));
    await tester.pumpAndSettle();
    final palette = tester.getRect(find.byType(CLNodePalette));
    final canvas = tester.getRect(find.byType(CLNodeGraph));
    final panel = tester.getRect(find.text('Configura «Se»'));
    expect(palette.width, closeTo(kCLNodePaletteWidth, 1)); // meno il bordo
    expect(palette.right, lessThanOrEqualTo(canvas.left));
    expect(canvas.right, lessThanOrEqualTo(panel.left));
    expect(find.text('Se'), findsOneWidget); // palette estesa
    await tester.tap(find.byTooltip('Chiudi'));
    expect(closed, 1);
  });

  testWidgets('senza pannello: il canvas prende lo spazio', (tester) async {
    setFlowView(tester);
    await tester.pumpWidget(_layout());
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(CLNodeGraph)).right, 1400);
  });

  testWidgets('schermo stretto: palette a menu e pannello come foglio dal basso', (tester) async {
    setFlowView(tester, size: const Size(390, 800));
    await tester.pumpWidget(_layout(panel: const Text('Condizione'), onClose: () {}));
    await tester.pumpAndSettle();
    expect(find.text('Aggiungi blocco'), findsOneWidget); // palette compatta
    expect(find.text('Se'), findsNothing);
    final sheet = tester.getRect(find.text('Condizione'));
    expect(sheet.bottom, greaterThan(800 * (1 - kCLNodeSheetMaxHeightFactor)));
    expect(tester.getRect(find.byType(CLNodeGraph)).width, 390); // canvas a tutta larghezza
  });
}
