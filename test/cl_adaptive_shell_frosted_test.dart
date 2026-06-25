import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/layout/cl_adaptive_shell.widget.dart';
import 'package:genai_components/widgets/layout/cl_destination.dart';
import 'package:genai_components/widgets/layout/cl_shell_config.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

const _kBodyKey = Key('body');

CLDestination _dest(String key) => CLDestination(
      key: key,
      label: key,
      icon: Icons.home,
    );

Widget _buildHarness({required CLShellConfig config}) {
  return MaterialApp(
    home: Scaffold(
      body: CLAdaptiveShell(
        destinations: [_dest('home'), _dest('explore')],
        selectedKey: 'home',
        onSelect: (_) {},
        header: const Text('Header'),
        body: const ColoredBox(
          key: _kBodyKey,
          color: Colors.red,
          child: SizedBox.expand(),
        ),
        config: config,
      ),
    ),
  );
}

/// Imposta la larghezza del viewport al valore richiesto.
/// Larghezza < 600 → CLNavMode.bottomBar.
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
    // ── T1: legacy (frostedFullBleed=false) — body in Column/Expanded ────────
    testWidgets('T1: legacy branch – body NOT inside a Stack', (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: false)),
      );
      await tester.pump();

      final bodyFinder = find.byKey(_kBodyKey);
      expect(bodyFinder, findsOneWidget);

      final ancestors = tester.widgetList(
        find.ancestor(of: bodyFinder, matching: find.byType(Stack)),
      );
      expect(ancestors.isEmpty, isTrue,
          reason: 'legacy: body non deve essere dentro uno Stack');
    });

    // ── T2: frosted full-bleed (frostedFullBleed=true) — body in Stack ───────
    testWidgets('T2: frostedFullBleed=true – body IS inside a Stack',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();

      final bodyFinder = find.byKey(_kBodyKey);
      expect(bodyFinder, findsOneWidget);

      final stackAncestors = tester.widgetList(
        find.ancestor(of: bodyFinder, matching: find.byType(Stack)),
      );
      expect(stackAncestors.isNotEmpty, isTrue,
          reason: 'frostedFullBleed=true: body deve essere dentro uno Stack');
    });

    // ── T3: Scaffold presente in entrambi i rami ──────────────────────────────
    testWidgets('T3: legacy branch – Scaffold presente', (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: false)),
      );
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('T4: frostedFullBleed=true – Scaffold presente', (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    // ── T5: default config invariata ─────────────────────────────────────────
    testWidgets('T5: default config (frostedFullBleed=false) – body NOT in Stack',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig()),
      );
      await tester.pump();

      final bodyFinder = find.byKey(_kBodyKey);
      expect(bodyFinder, findsOneWidget);

      final ancestors = tester.widgetList(
        find.ancestor(of: bodyFinder, matching: find.byType(Stack)),
      );
      expect(ancestors.isEmpty, isTrue,
          reason: 'default config: legacy path, no Stack');
    });
  });
}
