# Resizable Nav Header Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere una maniglia di resize sul bordo basso della bolla `navHeader` della sidebar espansa, così l'utente bilancia lo spazio tra voci cliente (dentro l'header) e voci nav normali (sotto).

**Architecture:** In `_navPanel`, quando il tier è sidebar espansa e il flag opt-in `GenShellConfig.resizableNavHeader` è attivo, si sostituisce l'attuale `Stack` (header frosted floating + `GenNavList` full che scorre sotto) con un `GenResizablePanelGroup(axis: Axis.vertical)` a due pannelli: Panel A = `navHeader` (frosted, scrollabile), Panel B = `GenNavList(destinations)`. La maniglia tra i pannelli È il bordo basso dell'header. Footer resta barra frosted fissa.

**Tech Stack:** Flutter, `shadcn_ui` (`GenResizablePanelGroup`/`GenResizablePanel` = typedef di `ShadResizablePanelGroup`/`ShadResizablePanel`), `flutter_test`.

## Global Constraints

- Nessun breaking change: `resizableNavHeader` default `false` → layout attuale invariato per tutti i tier.
- Resize attivo SOLO in sidebar espansa (`!isCompact && !collapsed`). Rail/mobile/drawer ignorano il flag.
- Nessuna persistenza: lo split vive nello stato di sessione di `GenResizablePanelGroupState`.
- Frazioni pannelli (0..1): Panel A `defaultSize 0.4` `minSize 0.15` `maxSize 0.85`; Panel B `defaultSize 0.6` `minSize 0.15`. La somma dei `defaultSize` deve fare `1.0`.
- Riusare `_frostedMenuBar` per la superficie di Panel A (coerenza visiva col frost odierno).
- Convenzione commit: Conventional Commits, come nel repo.

---

### Task 1: Rendering resizable in `_navPanel` + flag config

**Files:**
- Modify: `lib/gen/shell/gen_shell_config.dart` (aggiunta campo `resizableNavHeader`)
- Modify: `lib/gen/shell/gen_adaptive_shell.widget.dart` (ramo resizable in `_navPanel`, ~riga 219-285)
- Test: `test/resizable_nav_header_test.dart` (nuovo, package-level)

**Interfaces:**
- Consumes: `GenResizablePanelGroup({required List<Widget> children, Axis axis, bool? showHandle, Color? dividerColor})`, `GenResizablePanel({required Object id, required Widget child, required double defaultSize, double minSize, double maxSize})` — da `lib/gen/primitives/gen_primitives.dart`. `GenNavList(destinations, selectedKey, onSelect, isCompact, collapsed, forceExpandedKey, onExpandRequest, padding)`. `_frostedMenuBar(GenTokens theme, {required Widget child, EdgeInsets margin})`. `_MeasureSize({required ValueChanged<Size> onChange, required Widget child})`. Campi stato: `_menuFooterH`.
- Produces: `GenShellConfig.resizableNavHeader` (bool, default false).

- [ ] **Step 1: Write the failing test**

Create `test/resizable_nav_header_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/gen/gen.dart';

/// Wrappa lo shell nel tema Gen + forza una larghezza desktop (>= 1079) così il
/// tier risolto è `sidebar` (dove il resize è attivo).
Widget _harness({required bool resizable}) {
  return GenApp(
    debugShowCheckedModeBanner: false,
    theme: GenThemeData.light().toShad(),
    home: GenTheme(
      data: GenThemeData.light(),
      child: GenAdaptiveShell(
        config: GenShellConfig(resizableNavHeader: resizable),
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/resizable_nav_header_test.dart`
Expected: FAIL — `GenShellConfig` non ha `resizableNavHeader` (errore di compilazione: "No named parameter with the name 'resizableNavHeader'").

- [ ] **Step 3: Aggiungi il campo config**

In `lib/gen/shell/gen_shell_config.dart`, dopo il campo `bubbleBody` (dichiarazione + init nel costruttore):

Dichiarazione (dopo `final bool bubbleBody;`):

```dart
  /// Opt-in (solo tier sidebar espanso): la bolla `navHeader` diventa un pannello
  /// ad altezza regolabile con maniglia sul bordo basso; le destinations sotto
  /// prendono lo spazio rimanente. Default false → header frosted fisso (odierno).
  /// Ignorato in rail/mobile/drawer.
  final bool resizableNavHeader;
```

Init nel costruttore (dopo `this.bubbleBody = false,`):

```dart
    this.resizableNavHeader = false,
```

- [ ] **Step 4: Aggiungi il ramo resizable in `_navPanel`**

In `lib/gen/shell/gen_adaptive_shell.widget.dart`, dentro `_navPanel`, subito dopo la riga `final hasFooter = footerContent != null;` (attorno a riga 217) aggiungi:

```dart
    // Resize dell'header attivo solo in sidebar espansa (no rail/compact) e con
    // header presente. In quel caso: header = Panel A (frosted, scroll), lista
    // destinations = Panel B; la maniglia tra i due È il bordo basso dell'header.
    final resizableHeader =
        !isCompact && !collapsed && widget.config.resizableNavHeader && hasHeader;
```

Poi, sostituisci il `child: Stack(...)` esistente (il blocco `child: Stack( children: [ Positioned.fill(GenNavList...), if (hasHeader) Positioned(top...), if (hasFooter) Positioned(bottom...) ] )`) con una scelta condizionale. Estrai il footer frosted in una variabile locale riusata da entrambi i rami e ramifica lo Stack:

```dart
      child: Stack(
        children: [
          if (resizableHeader)
            Positioned.fill(
              child: GenResizablePanelGroup(
                axis: Axis.vertical,
                showHandle: true,
                dividerColor: theme.borderColor,
                children: [
                  GenResizablePanel(
                    id: 'nav-header',
                    defaultSize: 0.4,
                    minSize: 0.15,
                    maxSize: 0.85,
                    // Frosted come la barra header odierna, ma ora ad altezza
                    // regolabile; scrollabile perché con minSize basso le voci
                    // cliente devono scorrere dentro il pannello.
                    child: _frostedMenuBar(
                      theme,
                      margin: const EdgeInsets.only(bottom: GenSizes.gapSm),
                      child: SingleChildScrollView(child: headerContent),
                    ),
                  ),
                  GenResizablePanel(
                    id: 'nav-primary',
                    defaultSize: 0.6,
                    minSize: 0.15,
                    child: GenNavList(
                      destinations: widget.destinations,
                      selectedKey: widget.selectedKey,
                      onSelect: _onSelect,
                      isCompact: false,
                      collapsed: false,
                      onExpandRequest: () => setState(() => _collapsed = false),
                      padding: EdgeInsets.only(
                        bottom: hasFooter ? _menuFooterH : GenSizes.gapSm,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Positioned.fill(
              child: GenNavList(
                destinations: widget.destinations,
                selectedKey: widget.selectedKey,
                onSelect: _onSelect,
                isCompact: isCompact,
                forceExpandedKey: forceExpandedKey,
                collapsed: collapsed,
                onExpandRequest: () => setState(() => _collapsed = false),
                padding: EdgeInsets.only(
                  top: hasHeader ? _menuHeaderH : GenSizes.gapSm,
                  bottom: hasFooter ? _menuFooterH : GenSizes.gapSm,
                ),
              ),
            ),
            // Barra header frosted (logo + navHeader): in alto, full-width.
            if (hasHeader)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _MeasureSize(
                  onChange: (s) {
                    if (s.height != _menuHeaderH) setState(() => _menuHeaderH = s.height);
                  },
                  child: _frostedMenuBar(theme,
                      margin: const EdgeInsets.only(bottom: GenSizes.gapSm), child: headerContent),
                ),
              ),
          ],
          // Barra footer frosted (navFooter): in basso, full-width. Comune ai due rami.
          if (hasFooter)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MeasureSize(
                onChange: (s) {
                  if (s.height != _menuFooterH) setState(() => _menuFooterH = s.height);
                },
                child: _frostedMenuBar(theme,
                    margin: const EdgeInsets.only(top: GenSizes.gapSm), child: footerContent),
              ),
            ),
        ],
      ),
```

Nota: il ramo `else` è identico al codice odierno (Positioned.fill list + header frosted floating); il footer frosted è ora condiviso fuori dal ramo. `footerContent` è già non-null quando `hasFooter` (safe nel `child:`).

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/resizable_nav_header_test.dart`
Expected: PASS (2 test verdi).

- [ ] **Step 6: Analyze**

Run: `flutter analyze lib/gen/shell/gen_shell_config.dart lib/gen/shell/gen_adaptive_shell.widget.dart test/resizable_nav_header_test.dart`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/gen/shell/gen_shell_config.dart lib/gen/shell/gen_adaptive_shell.widget.dart test/resizable_nav_header_test.dart
git commit -m "feat(shell): resizable navHeader with bottom handle (opt-in)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Attiva il resize nell'esempio + smoke visivo

**Files:**
- Modify: `example/lib/app/home_shell.dart` (config dello shell, ~riga 125)

**Interfaces:**
- Consumes: `GenShellConfig.resizableNavHeader` (da Task 1). `ClientContextMenu` già passato via `NavHeader(extra: ...)` in `navHeader`.

- [ ] **Step 1: Abilita il flag nella config dello shell**

In `example/lib/app/home_shell.dart`, cambia:

```dart
      config: const GenShellConfig(bubbleBody: true),
```

in:

```dart
      config: const GenShellConfig(bubbleBody: true, resizableNavHeader: true),
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze example/lib/app/home_shell.dart`
Expected: `No issues found!`

- [ ] **Step 3: Smoke visivo (manuale)**

Run: `flutter run -d macos` (dalla dir `example/`)
Verifica (spec §Test manuali):
1. Sidebar espansa: maniglia sul bordo basso della bolla header (azienda + "Gestione cliente").
2. Drag giù → header cresce, voci cliente scrollano dentro; destinations si comprimono.
3. Drag su fino al minimo → header minimo, destinations massime.
4. Restringi finestra sotto 1079px → rail: nessuna maniglia (railHeader).
5. Restringi sotto 600px → drawer mobile: `navHeader` inline, niente resize.
6. Interazione: il drag della maniglia non deve essere catturato dallo scroll interno di Panel A (gesture arena). Se lo fosse, annotare per follow-up.

- [ ] **Step 4: Commit**

```bash
git add example/lib/app/home_shell.dart
git commit -m "feat(example): enable resizable navHeader in home shell

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Note di verifica (self-review)

- **Spec coverage:** flag opt-in (Task 1 Step 3) · rendering 2 pannelli + handle (Task 1 Step 4) · fallback tier non-espansi = ramo `else` identico all'odierno (Task 1 Step 4) · footer fisso (comune) · esempio (Task 2) · test manuali (Task 2 Step 3). ✓
- **Persistenza:** nessuna — non serve codice (stato interno del group). ✓
- **Rischio gesture arena** (drag handle vs scroll Panel A): coperto dal check manuale Task 2 Step 3.6; il group Shad tratta la maniglia come area dedicata (atteso ok).
- **Tipi:** `resizableNavHeader` (bool) coerente tra config e uso; `id` pannelli `'nav-header'`/`'nav-primary'`; frazioni sommano a 1.0.
