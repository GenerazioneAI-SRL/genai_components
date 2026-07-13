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
        // navSecondary presente → il resize si attiva (parte scrollabile).
        navSecondary: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Voci cliente'),
        ),
        // railSecondary → resize attivo anche nel rail (tablet).
        railHeader: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.business)),
        railSecondary: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.folder)),
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

  testWidgets('flag ON in sidebar espansa → mostra la maniglia di resize',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(resizable: true));
    await tester.pump();

    expect(find.byKey(const Key('gen-nav-header-resize-handle')), findsOneWidget);
  });

  testWidgets('flag OFF → nessuna maniglia (layout odierno)', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(resizable: false));
    await tester.pump();

    expect(find.byKey(const Key('gen-nav-header-resize-handle')), findsNothing);
  });

  testWidgets('flag ON + bubbleBody (path shipping) → maniglia senza errori di layout',
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
    expect(find.byKey(const Key('gen-nav-header-resize-handle')), findsOneWidget);
  });

  testWidgets('flag ON + bubbleBody a larghezza tablet (rail) → maniglia presente',
      (tester) async {
    // 800px ∈ [600, 1079) → tier rail (collassato di default). Con bubbleBody +
    // railSecondary la bolla header rail è resizable → maniglia presente.
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(resizable: true, bubbleBody: true));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('gen-nav-header-resize-handle')), findsOneWidget);
  });
}
