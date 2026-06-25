# Shell full-bleed + bolla strumenti (mobile) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rendere lo shell mobile di `CLAdaptiveShell` full-bleed (contenuto edge-to-edge che scorre sotto header e bolla in basso, entrambi in blur), con la barra in basso come "bolla strumenti" configurata per pagina; comportamento opt-in via flag così admin/mentore restano invariati.

**Architecture:** Un flag `frostedFullBleed` su `CLShellConfig` sceglie, dentro `_buildScaffold` (path mobile/bottomBar), un nuovo ramo basato su `Scaffold(extendBody, extendBodyBehindAppBar)`: il body riempie tutto, `appBar` = header blur ad altezza fissa, `bottomNavigationBar` = bolla blur ad altezza variabile. Lo Scaffold misura le barre e inietta gli insets nel `MediaQuery` del body (niente calcolo a mano). La navigazione nella bolla si nasconde quando un pannello (filtri) è aperto o c'è una selezione attiva (bulk).

**Tech Stack:** Flutter (web/CanvasKit), Dart. Widget `genai_components` consumato da `skillera_emp`. Test: `flutter_test` (widget test).

## Global Constraints

- Renderer web target: **CanvasKit** (blur accettabile).
- Compatibilità: il comportamento attuale di `CLAdaptiveShell` NON deve cambiare quando `config.frostedFullBleed == false` (default). admin/mentore non toccati.
- Modifiche solo in `genai_components` (shell) + `skillera_emp` (opt-in + eventuale adeguamento pagine).
- Branch: `feat/shell-fullbleed-bubble` in entrambi i repo.
- Tutti i comandi `flutter` vanno eseguiti **dalla dir del relativo pacchetto** (`FRONTEND/genai_components` o `FRONTEND/skillera_emp`).
- Costanti altezze/spazi: usare i getter di `CLTheme` (`buttonHeightDefault=40`, `gapLg=16`, `gapMd=12`, `radiusBubble=36`, `iconSizeDefault=20`). Mai numeri magici.
- Comportamenti bolla (da spec): filtri+selezione **uno alla volta**; riga navigazione **sparisce** quando un pannello è aperto.

---

## File Structure

- `genai_components/lib/widgets/layout/cl_shell_config.dart` — aggiunge il flag `frostedFullBleed`.
- `genai_components/lib/widgets/layout/cl_adaptive_shell.widget.dart` — nuovo ramo mobile frosted in `_buildScaffold`; nuovi helper privati `_frostedScaffold`, `_frostedHeader`, `_frostedBottom`; gating navigazione.
- `genai_components/test/cl_adaptive_shell_frosted_test.dart` — NUOVO. Widget test del ramo frosted.
- `genai_components/test/_shell_test_harness.dart` — NUOVO. Helper per montare lo shell nei test.
- `skillera_emp/lib/core/layout/app.layout.dart` — opt-in `frostedFullBleed: true` nella `CLShellConfig`.

---

### Task 1: Flag `frostedFullBleed` su CLShellConfig

**Files:**
- Modify: `genai_components/lib/widgets/layout/cl_shell_config.dart:7-29`

**Interfaces:**
- Produces: `CLShellConfig.frostedFullBleed` (bool, default `false`).

- [ ] **Step 1: Aggiungi il campo + parametro**

In `cl_shell_config.dart`, dentro `class CLShellConfig`, aggiungi il campo dopo `drawerWidthFactor` e il parametro nel costruttore (default `false`):

```dart
  final double drawerWidthFactor;

  /// Opt-in: attiva lo shell mobile "full-bleed" (contenuto edge-to-edge sotto
  /// header/bolla in blur). Default false → comportamento legacy invariato.
  final bool frostedFullBleed;

  const CLShellConfig({
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 1079,
    this.sidebarWidth = 268,
    this.railWidth = 72,
    this.trailingWidth = 360,
    this.maxBottomBarItems = 5,
    this.drawerWidthFactor = 0.85,
    this.frostedFullBleed = false,
  });
```

- [ ] **Step 2: Verifica compilazione**

Run (da `FRONTEND/genai_components`): `flutter analyze lib/widgets/layout/cl_shell_config.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/layout/cl_shell_config.dart
git commit -m "feat(shell): flag frostedFullBleed opt-in su CLShellConfig"
```

---

### Task 2: Harness di test + ramo frosted scheletro (full-bleed, no blur)

Introduce il ramo frosted in `_buildScaffold`: `Scaffold` con `extendBody`/`extendBodyBehindAppBar`, header e bolla SENZA blur ancora (solo struttura + insets). Verificabile: il body è full-bleed e lo Scaffold inietta gli insets.

**Files:**
- Create: `genai_components/test/_shell_test_harness.dart`
- Create: `genai_components/test/cl_adaptive_shell_frosted_test.dart`
- Modify: `genai_components/lib/widgets/layout/cl_adaptive_shell.widget.dart` (`_buildScaffold` ~716; nuovi helper)

**Interfaces:**
- Consumes: `CLShellConfig.frostedFullBleed` (Task 1).
- Produces: helper privato `Widget _frostedScaffold(BuildContext, CLTheme, {required bool withBottomBar})`.

- [ ] **Step 1: Scrivi l'harness di test**

Create `genai_components/test/_shell_test_harness.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

/// Monta un CLAdaptiveShell a larghezza forzata (mobile) con un body scrollabile
/// alto, per i test del ramo frosted. width<600 → CLNavMode.bottomBar.
Widget mountShell({
  required CLShellConfig config,
  ShellSlotsController? controller,
  double width = 390,
  double height = 800,
}) {
  final dests = <CLDestination>[
    CLDestination(key: '/a', label: 'A', icon: Icons.home, priority: 1),
    CLDestination(key: '/b', label: 'B', icon: Icons.list, priority: 2),
  ];
  return MaterialApp(
    home: CLTheme(
      data: CLThemeData.light(),
      child: MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: CLAdaptiveShell(
          config: config,
          destinations: dests,
          selectedKey: '/a',
          onSelect: (_) {},
          slotsController: controller,
          header: const SizedBox(key: Key('app-header'), height: 40),
          body: ListView.builder(
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 60, child: Text('row $i')),
          ),
        ),
      ),
    ),
  );
}
```

> Nota: se i nomi `CLTheme`/`CLThemeData.light()` non corrispondono all'API reale del tema (verificare in `genai_components/lib/cl_theme.dart`), adatta il wrapper del tema a come lo montano le app. L'obiettivo dell'harness è solo fornire un `CLTheme.of(context)` valido e una `MediaQuery` mobile.

- [ ] **Step 2: Scrivi il test che fallisce (full-bleed insets)**

Create `genai_components/test/cl_adaptive_shell_frosted_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';
import '_shell_test_harness.dart';

void main() {
  testWidgets('frosted mobile: Scaffold estende il body sotto le barre', (tester) async {
    await tester.pumpWidget(mountShell(
      config: const CLShellConfig(frostedFullBleed: true),
    ));
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.extendBody, isTrue, reason: 'body deve passare sotto la bolla');
    expect(scaffold.extendBodyBehindAppBar, isTrue, reason: 'body deve passare sotto header');
    expect(scaffold.appBar, isNotNull);
    expect(scaffold.bottomNavigationBar, isNotNull);
  });

  testWidgets('legacy mobile: nessun extendBody quando flag off', (tester) async {
    await tester.pumpWidget(mountShell(
      config: const CLShellConfig(frostedFullBleed: false),
    ));
    await tester.pump();
    // Path legacy: Column nello Scaffold, niente appBar/bottomNavigationBar slot.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.extendBody, isFalse);
    expect(scaffold.appBar, isNull);
  });
}
```

- [ ] **Step 3: Esegui il test → deve fallire**

Run (da `FRONTEND/genai_components`): `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: FAIL sul primo test (`extendBody` è false / `appBar` null perché il ramo frosted non esiste ancora).

- [ ] **Step 4: Implementa il ramo frosted (scheletro, no blur)**

In `cl_adaptive_shell.widget.dart`, modifica `_buildScaffold` (riga ~716) per ramificare sul flag. All'inizio del metodo, dopo `final theme = CLTheme.of(context);`:

```dart
    if (widget.config.frostedFullBleed) {
      return _frostedScaffold(context, theme, withBottomBar: withBottomBar);
    }
```

Poi aggiungi i nuovi helper privati nella classe `_CLAdaptiveShellState` (vicino agli altri `_build*`):

```dart
  // ── Mobile full-bleed (opt-in) ─────────────────────────────────────────────
  /// Body edge-to-edge sotto header (appBar) e bolla (bottomNavigationBar). Lo
  /// Scaffold misura le barre e inietta gli insets nel MediaQuery del body.
  Widget _frostedScaffold(BuildContext context, CLTheme theme, {required bool withBottomBar}) {
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.primaryBackground,
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        width: drawerWidth,
        backgroundColor: theme.primaryBackground,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true)),
      ),
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      appBar: _frostedHeader(context, theme),
      bottomNavigationBar: _frostedBottom(context, theme, withBottomBar: withBottomBar),
      body: _scopedBody(),
    );
  }

  /// Header full-bleed ad altezza fissa. Per ora bg solido (blur in Task 3).
  PreferredSizeWidget _frostedHeader(BuildContext context, CLTheme theme) {
    final h = theme.buttonHeightDefault + theme.gapLg * 2; // contenuto + padding
    return PreferredSize(
      preferredSize: Size.fromHeight(h),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: h,
          child: Padding(
            padding: EdgeInsets.all(theme.gapLg),
            child: SizedBox(
              height: theme.buttonHeightDefault,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CLIconButton(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    iconData: Icons.menu,
                    backgroundColor: theme.secondaryBackground,
                    boxShadow: theme.cardShadowSoft,
                    iconColor: theme.primaryText,
                    size: theme.buttonHeightDefault,
                    iconSize: Sizes.iconSizeDefault,
                    tooltip: 'Menu',
                  ),
                  const SizedBox(width: Sizes.gapLg),
                  Expanded(child: _composedHeader(context, mode: CLNavMode.bottomBar)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bolla in basso full-bleed ad altezza variabile. Per ora bg solido (blur in
  /// Task 4). Riusa context area + nav come il path legacy.
  Widget _frostedBottom(BuildContext context, CLTheme theme, {required bool withBottomBar}) {
    return _mobileBottomStrip(context, theme, withBottomBar: withBottomBar);
  }
```

- [ ] **Step 5: Esegui i test → devono passare**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: PASS (entrambi).

- [ ] **Step 6: Verifica nessuna regressione di analisi**

Run: `flutter analyze lib/widgets/layout/cl_adaptive_shell.widget.dart`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/widgets/layout/cl_adaptive_shell.widget.dart test/_shell_test_harness.dart test/cl_adaptive_shell_frosted_test.dart
git commit -m "feat(shell): ramo mobile frosted full-bleed (scheletro, insets via Scaffold)"
```

---

### Task 3: Header in blur (vetro smerigliato)

**Files:**
- Modify: `genai_components/lib/widgets/layout/cl_adaptive_shell.widget.dart` (`_frostedHeader`)
- Modify: `genai_components/test/cl_adaptive_shell_frosted_test.dart` (nuovo test)

**Interfaces:**
- Consumes: `_frostedHeader` (Task 2).

- [ ] **Step 1: Test che fallisce — header contiene un BackdropFilter**

Aggiungi a `cl_adaptive_shell_frosted_test.dart`, dentro `main()`:

```dart
  testWidgets('frosted header: ha blur (BackdropFilter) ad altezza fissa', (tester) async {
    await tester.pumpWidget(mountShell(
      config: const CLShellConfig(frostedFullBleed: true),
    ));
    await tester.pump();

    final appBarFinder = find.byType(PreferredSize);
    expect(appBarFinder, findsWidgets);
    // Almeno un BackdropFilter dentro l'header.
    final blurInHeader = find.descendant(
      of: appBarFinder.first,
      matching: find.byType(BackdropFilter),
    );
    expect(blurInHeader, findsOneWidget, reason: 'header deve avere il blur');
  });
```

- [ ] **Step 2: Esegui → fallisce**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: FAIL (nessun `BackdropFilter` nell'header).

- [ ] **Step 3: Aggiungi il blur all'header**

Aggiungi in cima al file (se non già presente): `import 'dart:ui' show ImageFilter;`

In `_frostedHeader`, avvolgi il contenuto con `ClipRect` + `BackdropFilter` e usa un bg traslucido (così il contenuto si intravede sotto). Sostituisci il `child: SafeArea(...)` del `PreferredSize` con:

```dart
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.primaryBackground.withValues(alpha: 0.72),
              border: Border(bottom: BorderSide(color: theme.borderColor)),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: h,
                child: Padding(
                  padding: EdgeInsets.all(theme.gapLg),
                  child: SizedBox(
                    height: theme.buttonHeightDefault,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CLIconButton(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          iconData: Icons.menu,
                          backgroundColor: theme.secondaryBackground,
                          boxShadow: theme.cardShadowSoft,
                          iconColor: theme.primaryText,
                          size: theme.buttonHeightDefault,
                          iconSize: Sizes.iconSizeDefault,
                          tooltip: 'Menu',
                        ),
                        const SizedBox(width: Sizes.gapLg),
                        Expanded(child: _composedHeader(context, mode: CLNavMode.bottomBar)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
```

- [ ] **Step 4: Esegui → passa**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: PASS (tutti).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/layout/cl_adaptive_shell.widget.dart test/cl_adaptive_shell_frosted_test.dart
git commit -m "feat(shell): header frosted con BackdropFilter + bg traslucido"
```

---

### Task 4: Bolla in basso in blur

**Files:**
- Modify: `genai_components/lib/widgets/layout/cl_adaptive_shell.widget.dart` (`_frostedBottom`)
- Modify: `genai_components/test/cl_adaptive_shell_frosted_test.dart` (nuovo test)

**Interfaces:**
- Consumes: `_frostedBottom`, `_mobileBottomStrip` (esistente).

- [ ] **Step 1: Test che fallisce — la bolla ha blur**

Aggiungi a `cl_adaptive_shell_frosted_test.dart`:

```dart
  testWidgets('frosted bottom: la bolla ha blur (BackdropFilter)', (tester) async {
    final ctrl = ShellSlotsController();
    addTearDown(ctrl.dispose);
    await tester.pumpWidget(mountShell(
      config: const CLShellConfig(frostedFullBleed: true),
      controller: ctrl,
    ));
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNotNull);
    final blurInBottom = find.descendant(
      of: find.byWidget(scaffold.bottomNavigationBar!),
      matching: find.byType(BackdropFilter),
    );
    expect(blurInBottom, findsOneWidget, reason: 'la bolla deve avere il blur');
  });
```

- [ ] **Step 2: Esegui → fallisce**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: FAIL (nessun `BackdropFilter` nella bolla).

- [ ] **Step 3: Implementa la bolla blur**

Sostituisci il corpo di `_frostedBottom` per avvolgere la bolla con `ClipRRect` + `BackdropFilter` e bg traslucido. La struttura interna (context area + nav) resta quella di `_mobileBottomStrip`, ma serve estrarne il contenuto. Aggiungi un parametro `frostedGlass` a `_mobileBottomStrip` per renderlo traslucido invece che card opaca:

```dart
  Widget _frostedBottom(BuildContext context, CLTheme theme, {required bool withBottomBar}) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.all(theme.gapLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radiusBubble),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.secondaryBackground.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(theme.radiusBubble),
                border: Border.all(color: theme.borderColor),
              ),
              child: AnimatedBuilder(
                animation: _slots,
                builder: (context, _) {
                  final hasContext = _hasContent(_slots.slots);
                  return Padding(
                    padding: EdgeInsets.all(theme.gapLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _mobileContextArea(context, frosted: true),
                        if (hasContext && withBottomBar) SizedBox(height: theme.gapMd),
                        if (withBottomBar)
                          CLBottomBar(
                            destinations: widget.bottomDestinations ?? widget.destinations,
                            selectedKey: widget.selectedKey,
                            onSelect: _onSelect,
                            onOpenGroup: (_) => _scaffoldKey.currentState?.openDrawer(),
                            onOverflow: () => _scaffoldKey.currentState?.openDrawer(),
                            maxItems: widget.config.maxBottomBarItems,
                            topBorder: true,
                            floating: true,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
```

> Nota DRY: il contenuto interno (context area + CLBottomBar) duplica `_mobileBottomStrip`. Se preferisci, estrai un helper `_bubbleInner(context, theme, withBottomBar)` condiviso tra `_mobileBottomStrip` (legacy, dentro `_sideCard`) e `_frostedBottom` (dentro il blur). Mantieni una sola copia della logica context-area+nav.

- [ ] **Step 4: Esegui → passa**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: PASS (tutti).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/layout/cl_adaptive_shell.widget.dart test/cl_adaptive_shell_frosted_test.dart
git commit -m "feat(shell): bolla in basso frosted con blur + bg traslucido"
```

---

### Task 5: Comportamento bolla — nav nascosta a pannello/selezione, uno alla volta

Quando un pannello reveal (filtri) è aperto (`_panelId != null`) OPPURE c'è una selezione attiva (`selectionBar != null`), la riga di navigazione (`CLBottomBar`) **non** viene mostrata. La selezione ha priorità sul pannello (uno alla volta), già garantito da `_areaContent` (selectionBar prima del reveal).

**Files:**
- Modify: `genai_components/lib/widgets/layout/cl_adaptive_shell.widget.dart` (`_frostedBottom`)
- Modify: `genai_components/test/cl_adaptive_shell_frosted_test.dart` (nuovi test)

**Interfaces:**
- Consumes: `_slots.slots.selectionBar`, `_panelId`, `_hasContent`.

- [ ] **Step 1: Test che fallisce — nav nascosta in selezione**

Aggiungi a `cl_adaptive_shell_frosted_test.dart`:

```dart
  testWidgets('selezione attiva: la nav (CLBottomBar) sparisce', (tester) async {
    final ctrl = ShellSlotsController();
    addTearDown(ctrl.dispose);
    await tester.pumpWidget(mountShell(
      config: const CLShellConfig(frostedFullBleed: true),
      controller: ctrl,
    ));
    await tester.pump();
    // Nav presente di base.
    expect(find.byType(CLBottomBar), findsOneWidget);

    // Attiva selezione → nav via, selectionBar visibile.
    ctrl.setSelectionBar(const Text('3 selezionati', key: Key('bulk-bar')));
    await tester.pump();

    expect(find.byKey(const Key('bulk-bar')), findsOneWidget);
    expect(find.byType(CLBottomBar), findsNothing, reason: 'la bulk sostituisce la nav');
  });
```

- [ ] **Step 2: Esegui → fallisce**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: FAIL (`CLBottomBar` ancora presente durante la selezione).

- [ ] **Step 3: Implementa il gating della nav**

In `_frostedBottom`, dentro l'`AnimatedBuilder`, calcola `showNav` e usalo al posto del solo `withBottomBar`:

```dart
                builder: (context, _) {
                  final s = _slots.slots;
                  final hasContext = _hasContent(s);
                  final panelOpen = _panelId != null;
                  final selecting = s.selectionBar != null;
                  // Nav sparisce quando un pannello è aperto o c'è selezione (bulk).
                  final showNav = withBottomBar && !panelOpen && !selecting;
                  return Padding(
                    padding: EdgeInsets.all(theme.gapLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _mobileContextArea(context, frosted: true),
                        if (hasContext && showNav) SizedBox(height: theme.gapMd),
                        if (showNav)
                          CLBottomBar(
                            destinations: widget.bottomDestinations ?? widget.destinations,
                            selectedKey: widget.selectedKey,
                            onSelect: _onSelect,
                            onOpenGroup: (_) => _scaffoldKey.currentState?.openDrawer(),
                            onOverflow: () => _scaffoldKey.currentState?.openDrawer(),
                            maxItems: widget.config.maxBottomBarItems,
                            topBorder: true,
                            floating: true,
                          ),
                      ],
                    ),
                  );
                },
```

- [ ] **Step 4: Esegui → passa**

Run: `flutter test test/cl_adaptive_shell_frosted_test.dart`
Expected: PASS (tutti).

- [ ] **Step 5: Suite intera + analyze**

Run: `flutter test`
Expected: PASS.
Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/layout/cl_adaptive_shell.widget.dart test/cl_adaptive_shell_frosted_test.dart
git commit -m "feat(shell): bolla nasconde nav a pannello aperto / selezione (uno alla volta)"
```

---

### Task 6: Opt-in in skillera_emp + validazione manuale

**Files:**
- Modify: `skillera_emp/lib/core/layout/app.layout.dart` (uso `CLShellConfig`, ~riga 137)

**Interfaces:**
- Consumes: `CLShellConfig.frostedFullBleed` (Task 1).

- [ ] **Step 1: Attiva il flag in emp**

In `app.layout.dart`, modifica la `CLShellConfig` passata a `CLAdaptiveShell`:

```dart
  config: const CLShellConfig(maxBottomBarItems: 3, frostedFullBleed: true),
```

- [ ] **Step 2: Analyze emp**

Run (da `FRONTEND/skillera_emp`): `flutter analyze lib/core/layout/app.layout.dart`
Expected: `No issues found!`

> Se `genai_components` è una path-dependency, assicurati che punti al branch locale aggiornato: `flutter pub get` in `skillera_emp`.

- [ ] **Step 3: Avvio manuale (mobile width)**

Run (da `FRONTEND/skillera_emp`): `flutter run -d chrome`
Poi restringi la finestra sotto i 600px (viewport mobile) e verifica a mano:

- [ ] Il contenuto scorre **sotto** l'header in alto (si intravede sfocato).
- [ ] Il contenuto scorre **sotto** la bolla in basso (si intravede sfocato).
- [ ] L'**inizio** del contenuto non resta nascosto sotto l'header (spazio riservato ok).
- [ ] La **fine** del contenuto non resta nascosta sotto la bolla (spazio riservato ok).
- [ ] In una pagina con tabella: apri i **filtri** → la bolla cresce, la **nav sparisce**, alla chiusura torna.
- [ ] Seleziona righe → compare la **barra bulk**, la nav sparisce; deseleziona → torna.
- [ ] Scroll lungo e veloce: il blur non genera jank evidente (CanvasKit).

- [ ] **Step 4: Verifica non-regressione larghezza desktop**

Allarga la finestra (>1079px): lo shell desktop deve essere **identico a prima** (il flag tocca solo il path mobile). Verifica che sidebar + header + body siano invariati.

- [ ] **Step 5: Commit**

```bash
git add lib/core/layout/app.layout.dart
git commit -m "feat(shell): emp opt-in shell mobile full-bleed (frostedFullBleed)"
```

---

## Fase 2 (fuori da questo piano)

- Desktop full-bleed sotto header blur + menu sopra l'header (Stack manuale, insets fissi).
- Eventuale `radiusBubble`/sigma blur come token configurabili.
- Migrazione pagine emp che forzano padding (se la validazione manuale ne scopre).
- Propagazione del flag ad admin/mentore dopo validazione su emp.

---

## Self-Review

**1. Copertura spec:**
- Layout full-bleed sotto header/bolla → Task 2 (insets) + 3 (header blur) + 4 (bolla blur). ✓
- Insets via Scaffold (`extendBody`/`extendBodyBehindAppBar`) → Task 2. ✓
- Bolla strumenti per-pagina → usa gli slot esistenti (`setContextControls`/`setSelectionBar`); la bolla li rende (Task 4) — nessun nuovo meccanismo necessario. ✓
- Comportamenti decisi (uno alla volta; nav sparisce) → Task 5. ✓
- Opt-in componente condiviso → Task 1 (flag) + Task 6 (emp). admin/mentore invariati (test legacy in Task 2). ✓
- Rischio perf blur / migrazione pagine → validazione manuale Task 6 step 3-4. ✓
- Desktop full-bleed → spec lo cita nel modello ma la sezione "Fuori scope" esclude la bolla desktop; il full-bleed desktop è rimandato a Fase 2 (annotato). ✓

**2. Placeholder scan:** nessun TBD/TODO nel codice dei task; le due "Nota" sono indicazioni di adattamento/DRY, non placeholder di logica. ✓

**3. Coerenza tipi/nomi:** `frostedFullBleed` (Task1→2,6), `_frostedScaffold`/`_frostedHeader`/`_frostedBottom` (Task2→3,4,5), `_panelId`/`selectionBar`/`_hasContent`/`_mobileContextArea` (nomi esistenti verificati nel file). `CLBottomBar`/`CLIconButton`/`Sizes.*`/`theme.*` come da interfacce raccolte. ✓
