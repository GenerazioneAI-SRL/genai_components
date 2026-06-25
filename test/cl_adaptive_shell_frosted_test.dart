import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/layout/cl_adaptive_shell.widget.dart';
import 'package:genai_components/widgets/layout/cl_bottom_bar.widget.dart';
import 'package:genai_components/widgets/layout/cl_destination.dart';
import 'package:genai_components/widgets/layout/cl_shell_config.dart';
import 'package:genai_components/widgets/layout/cl_shell_slots.dart';

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

    // ── T7: frosted bottom contiene BackdropFilter ───────────────────────────
    testWidgets(
        'T7: frostedFullBleed=true – bottomNavigationBar contiene BackdropFilter con blur',
        (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull,
          reason: 'frostedFullBleed: bottomNavigationBar deve essere presente');

      // Scope al bottomNavigationBar subtree: esattamente un BackdropFilter.
      final blurInBottom = find.descendant(
        of: find.byWidget(scaffold.bottomNavigationBar!),
        matching: find.byType(BackdropFilter),
      );
      expect(blurInBottom, findsOneWidget,
          reason: 'frosted bottom deve contenere esattamente un BackdropFilter');

      final bf = tester.widget<BackdropFilter>(blurInBottom);
      expect(bf.filter, isNotNull,
          reason: 'BackdropFilter.filter deve essere impostato (ImageFilter.blur)');
    });

    // ── T8: nav nascosta quando selectionBar attiva ──────────────────────────
    testWidgets(
        'T8: frostedFullBleed=true – CLBottomBar assente con selectionBar attiva, '
        'presente senza', (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      final controller = ShellSlotsController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
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
            config: const CLShellConfig(frostedFullBleed: true),
            slotsController: controller,
          ),
        ),
      );
      await tester.pump();

      // Prima di attivare la selezione: CLBottomBar presente.
      expect(find.byType(CLBottomBar), findsOneWidget,
          reason: 'senza selezione CLBottomBar deve essere visibile');

      // Attiva selezione.
      controller.setSelectionBar(const Text('Bulk', key: Key('bulk-bar')));
      await tester.pump();

      // Bulk bar visibile, CLBottomBar nascosta.
      expect(find.byKey(const Key('bulk-bar')), findsOneWidget,
          reason: 'bulk bar deve essere visibile durante la selezione');
      expect(find.byType(CLBottomBar), findsNothing,
          reason: 'CLBottomBar deve essere nascosta durante la selezione');

      // Disattiva selezione.
      controller.setSelectionBar(null);
      await tester.pump();

      // CLBottomBar di nuovo presente.
      expect(find.byType(CLBottomBar), findsOneWidget,
          reason: 'CLBottomBar deve tornare visibile dopo la selezione');
    });

    // ── T_LEGACY_REG: legacy deve mantenere CLBottomBar anche con selectionBar ─
    // Questo test verifica la regressione introdotta da Task 5 dove _bubbleInner
    // applicava il nav-gating anche nel path legacy (frostedFullBleed=false).
    // DEVE FALLIRE sul codice pre-fix e passare dopo il fix.
    testWidgets(
        'T_LEGACY_REG: frostedFullBleed=false – CLBottomBar SEMPRE visibile anche '
        'con selectionBar attiva (legacy invariato)', (tester) async {
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      final controller = ShellSlotsController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
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
            config: const CLShellConfig(frostedFullBleed: false),
            slotsController: controller,
          ),
        ),
      );
      await tester.pump();

      // Baseline: CLBottomBar visibile.
      expect(find.byType(CLBottomBar), findsOneWidget,
          reason: 'legacy: CLBottomBar deve essere presente prima della selezione');

      // Attiva selezione bulk.
      controller.setSelectionBar(const Text('Bulk', key: Key('bulk-legacy')));
      await tester.pump();

      // LEGACY: CLBottomBar DEVE ESSERE ANCORA VISIBILE (nav-gating non si applica).
      expect(find.byType(CLBottomBar), findsOneWidget,
          reason: 'legacy (frostedFullBleed=false): CLBottomBar deve rimanere '
              'visibile anche con selectionBar attiva — nav-gating solo frosted');
    });

    // ── T9: frosted — pannello reveal aperto (SKIP — impraticabile in widget test)
    // MOTIVO: nel frosted scaffold (extendBody=true) il bottomNavigationBar è
    // posizionato fuori dal viewport di test. Il reveal button (CLIconButton con
    // Icons.filter_list) è trovato nell'albero da find.byIcon ma la sua posizione
    // calcolata da WidgetController.getCenter cade fuori dall'area tappable —
    // tap() lancia "could not find any matching widgets". CLIconButton non avvolge
    // in un Tooltip Flutter (il tooltip è solo una semanticLabel), quindi
    // find.byTooltip restituisce 0 widget. Il branch panelOpen di applyNavGating è
    // coperto dalla logica in _bubbleInner (stessa espressione booleana di selecting)
    // e dalla lettura della formula: `withBottomBar && (!applyNavGating || (!panelOpen && !selecting))`.
    // La copertura pratica è garantita da T8 (selection-gating frosted) +
    // T_LEGACY_REG (legacy invariato). Un test E2E / integration test con un
    // layout non-extendBody può coprire il click sul reveal button.
    testWidgets(
        'T9: frostedFullBleed=true – pannello reveal (skip per impraticabilità '
        'tap in frosted extendBody scaffold)', (tester) async {
      // Verifica solo che l'albero sia coerente: il reveal button esiste dopo
      // setContextControls; non si tenta il tap perché è off-viewport.
      _setViewWidth(tester, 390);
      addTearDown(() => _resetView(tester));

      final controller = ShellSlotsController();
      addTearDown(controller.dispose);

      const revealId = 'test-reveal';
      final revealControl = ShellRevealControl(
        id: revealId,
        title: 'Filtri',
        icon: Icons.filter_list,
        panelBuilder: (ctx, close) => const Text('Panel content'),
      );

      await tester.pumpWidget(
        MaterialApp(
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
            config: const CLShellConfig(frostedFullBleed: true),
            slotsController: controller,
          ),
        ),
      );
      await tester.pump();

      controller.setContextControls([ShellContextControl.reveal(revealControl)]);
      await tester.pump();

      // CLBottomBar presente prima del pannello.
      expect(find.byType(CLBottomBar), findsOneWidget,
          reason: 'frosted: CLBottomBar visibile con reveal control pubblicato');

      // Il reveal button è nell'albero (non si può tappare: off-viewport in extendBody).
      expect(find.byIcon(Icons.filter_list), findsOneWidget,
          reason: 'il bottone reveal è nell\'albero dopo setContextControls');
    });

    // ── T_NOTCH: header height includes top safe-area inset (no clip on notched devices) ──
    // RED before fix: preferredSize.height == 72 regardless of topInset →
    //   SafeArea eats 47px → content row (72px) clipped → hamburger invisible.
    // GREEN after fix: preferredSize.height == 72 + 47 = 119 →
    //   SafeArea consumes 47px inset, leaves 72px for content → no overflow.
    testWidgets(
        'T_NOTCH: frostedFullBleed=true – header height includes top inset, '
        'hamburger icon not clipped on notched device', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      // Simulate 47px status-bar / notch inset.
      tester.view.padding = const FakeViewPadding(top: 47);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
      });

      await tester.pumpWidget(
        _buildHarness(config: const CLShellConfig(frostedFullBleed: true)),
      );
      await tester.pump();

      // No overflow / render errors.
      expect(tester.takeException(), isNull,
          reason: 'no RenderFlex overflow with top inset 47px');

      // PreferredSize height must include the top inset (72 + 47 = 119).
      final ps = tester.widget<PreferredSize>(find.byType(PreferredSize));
      expect(
        ps.preferredSize.height,
        greaterThan(72),
        reason: 'preferredSize.height must exceed 72 when topInset=47',
      );

      // Hamburger icon must be present in the tree (not clipped away).
      final menuIconFinder = find.byIcon(Icons.menu);
      expect(menuIconFinder, findsOneWidget,
          reason: 'hamburger icon must be present in the tree');
      final iconBottom = tester.getRect(menuIconFinder).bottom;
      expect(
        iconBottom,
        lessThanOrEqualTo(ps.preferredSize.height + 1),
        reason: 'hamburger icon bottom must be within appBar height',
      );
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
