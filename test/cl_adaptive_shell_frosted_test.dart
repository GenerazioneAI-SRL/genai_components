import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/layout/cl_adaptive_shell.widget.dart';
import 'package:genai_components/widgets/layout/cl_destination.dart';
import 'package:genai_components/widgets/layout/cl_shell_config.dart';

// ─── Harness ────────────────────────────────────────────────────────────────

const _kBodyKey = Key('body');

CLDestination _dest(String key) => CLDestination(
      key: key,
      label: key,
      icon: Icons.home,
    );

/// Harness senza Scaffold esterno: l'unico Scaffold nell'albero è quello dello
/// shell. Viewport < 600 px forza CLNavMode.bottomBar.
Widget _buildHarness({required CLShellConfig config}) {
  return MaterialApp(
    home: CLAdaptiveShell(
      destinations: [_dest('home'), _dest('explore')],
      selectedKey: 'home',
      onSelect: (_) {},
      header: const Text('Header'),
      body: ColoredBox(
        key: _kBodyKey,
        color: Colors.red,
        child: const SizedBox.expand(),
      ),
      config: config,
    ),
  );
}

/// Forza larghezza viewport. Width < 600 → CLNavMode.bottomBar.
void _setViewWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1.0;
}

void _resetView(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('CLAdaptiveShell – frostedFullBleed mobile scaffold', () {
    // ── T1: frosted (frostedFullBleed=true) — extendBody + appBar + bottomNav ─
    testWidgets(
        'T1: frostedFullBleed=true – Scaffold extendBody/extendBodyBehindAppBar '
        'con appBar e bottomNavigationBar', (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();

      // Solo lo Scaffold dello shell nell'albero (nessun Scaffold nel harness).
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.extendBody, isTrue,
          reason: 'frostedFullBleed: extendBody deve essere true');
      expect(scaffold.extendBodyBehindAppBar, isTrue,
          reason: 'frostedFullBleed: extendBodyBehindAppBar deve essere true');
      expect(scaffold.appBar, isNotNull,
          reason: 'frostedFullBleed: appBar deve essere presente');
      expect(scaffold.bottomNavigationBar, isNotNull,
          reason: 'frostedFullBleed: bottomNavigationBar deve essere presente');
    });

    // ── T2: legacy (frostedFullBleed=false) — extendBody false, no appBar ────
    testWidgets(
        'T2: frostedFullBleed=false – Scaffold NON usa extendBody né appBar',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: false)),
      );
      await tester.pump();

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.extendBody, isFalse,
          reason: 'legacy: extendBody deve essere false');
      expect(scaffold.appBar, isNull,
          reason: 'legacy: appBar deve essere null (Column in body)');
    });

    // ── T3: default config invariata ─────────────────────────────────────────
    testWidgets(
        'T3: default config (frostedFullBleed=false) – comportamento legacy',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig()),
      );
      await tester.pump();

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.extendBody, isFalse,
          reason: 'default config: legacy path, extendBody false');
      expect(scaffold.appBar, isNull,
          reason: 'default config: legacy path, appBar null');
    });

    // ── T4: frosted — body comunque presente nell'albero ─────────────────────
    testWidgets('T4: frostedFullBleed=true – body widget presente nell\'albero',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();

      expect(find.byKey(_kBodyKey), findsOneWidget);
    });

    // ── T5: legacy — body presente ───────────────────────────────────────────
    testWidgets('T5: frostedFullBleed=false – body widget presente nell\'albero',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: false)),
      );
      await tester.pump();

      expect(find.byKey(_kBodyKey), findsOneWidget);
    });

    // ── T6: frosted header contiene BackdropFilter ────────────────────────────
    testWidgets(
        'T6: frostedFullBleed=true – appBar contiene BackdropFilter con blur',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();

      // Scope al PreferredSize dell'appBar → esattamente un BackdropFilter nell'header.
      // PreferredSize è il tipo restituito da _frostedHeader; è unico nell'albero
      // (il legacy path non usa appBar, e il bottomNav non è un PreferredSize).
      final blurInHeader = find.descendant(
        of: find.byType(PreferredSize),
        matching: find.byType(BackdropFilter),
      );
      expect(blurInHeader, findsOneWidget,
          reason: 'frosted header deve contenere esattamente un BackdropFilter');

      // Il filtro deve essere un blur gaussiano.
      final bf = tester.widget<BackdropFilter>(blurInHeader);
      expect(bf.filter, isNotNull,
          reason: 'BackdropFilter.filter deve essere impostato (ImageFilter.blur)');
    });
  });
}
