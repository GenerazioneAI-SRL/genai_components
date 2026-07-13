import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/gen/gen.dart';

/// Wrappa lo shell nel tema Gen + forza una larghezza desktop (>= 1079) così il
/// tier risolto è `sidebar` (dove il resize è attivo).
Widget _harness({required bool resizable, bool bubbleBody = false}) {
  return GenApp(
    debugShowCheckedModeBanner: false,
    theme: GenThemeData.light().toShad(),
    home: GenTheme(
      data: GenThemeData.light(),
      child: GenAdaptiveShell(
        config: GenShellConfig(resizableNavHeader: resizable, bubbleBody: bubbleBody),
        destinations: const [
          GenDestination(key: 'a', label: 'Alpha', icon: Icons.circle),
          GenDestination(key: 'b', label: 'Beta', icon: Icons.square),
        ],
        selectedKey: 'a',
        onSelect: (_) {},
        header: const SizedBox.shrink(),
        navHeader: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Azienda'),
        ),
        body: const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  // Forza viewport desktop per tutti i test del file.
  setUp(() {
    // no-op: la size si imposta per-test via tester.view sotto.
  });

  testWidgets('flag ON in sidebar espansa → mostra il panel group resizable',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(resizable: true));
    await tester.pump();

    expect(find.byType(GenResizablePanelGroup), findsOneWidget);
  });

  testWidgets('flag OFF → nessun panel group (layout odierno)', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(resizable: false));
    await tester.pump();

    expect(find.byType(GenResizablePanelGroup), findsNothing);
  });

  testWidgets('flag ON + bubbleBody (path shipping) → panel group senza errori di layout',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // bubbleBody: true è il path realmente usato dall'esempio (_bubbleDesktop →
    // AnimatedContainer/OverflowBox). Se il gruppo verticale ricevesse altezza
    // unbounded, pumpWidget lancerebbe l'assertion di layout → il test fallirebbe.
    await tester.pumpWidget(_harness(resizable: true, bubbleBody: true));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(GenResizablePanelGroup), findsOneWidget);
  });
}
