# genai_components v6 — Fase 1: Fondazione + Primitive · Work-order

- **Data:** 2026-07-09
- **Branch:** `shadcn_based` (già su origin)
- **Per:** agente implementatore
- **Design di riferimento:** `docs/superpowers/specs/2026-07-08-genai-shadcn-based-v6-design.md`

---

## 0. Contesto (leggi prima)

`genai_components` v6 viene ricostruito appoggiandosi a **`shadcn_ui`** (nank1ro) come fondamenta. Modello a **2 livelli**:

- **Livello 1 — Primitive:** widget base mappati **1:1** con shadcn, rinominati con prefisso **`Gen`** (`GenButton`, `GenInput`…). Meccanismo: **`typedef GenX = ShadX;`**.
- **Livello 2 — Complessi/dominio (fuori scope Fase 1):** tabella paginata, org-chart, charts, shell, ecc. Costruiti componendo le primitive Gen.

**Questa Fase 1 fa SOLO la fondazione:** dependency + tema + primitive Livello 1 + una schermata smoke che dimostra che compila e renderizza. **Nessuna migrazione app, nessun widget complesso, nessuna cancellazione del codice CL esistente.**

## 1. Decisioni già lockate (NON rimetterle in discussione)

1. **Dependency, non vendoring.** `shadcn_ui` come dependency, **pinnata** a `0.55.0` (pre-1.0, evitiamo churn).
2. **Prefisso `Gen`** per tutta l'API pubblica nuova.
3. **Primitive = `typedef`** 1:1 su shadcn. Niente wrapper, salvo dove indicato.
4. **Tema single-source:** `ShadThemeData` è la sorgente. Aggiungiamo un'estensione Gen (`GenTokens`) per ciò che a shadcn manca: colori semantici `success/info/warning` + **scala di spacing su griglia 4px**.
5. **Feel = shadcn.** Nessuna micro-animazione custom.
6. **Additivo:** il codice `CL*` esistente resta intatto. Le primitive Gen convivono in cartelle nuove.
7. **Niente test widget Flutter.** Verifica con `flutter analyze` + esecuzione dell'example. (Vedi §6.)

## 2. Deliverable

### 2.1 `pubspec.yaml`
Aggiungi la dependency, versione **esatta** pinnata:
```yaml
dependencies:
  shadcn_ui: 0.55.0
```
Poi `flutter pub get`. Verifica che non ci siano conflitti di constraint con le dep esistenti (`flutter_svg`, `intl`, `collection` sono condivise — allinea i range se pub protesta).

### 2.2 `lib/theme/gen_theme.dart`
- `GenThemeData` light + dark basati su `ShadThemeData` (scegli un `ShadColorScheme` preset vicino al brand attuale — es. Slate/Zinc — poi lo si ritocca).
- `GenTokens`: oggetto con
  - colori semantici `success`, `info`, `warning` (+ relativi `*Foreground`) — assenti in shadcn.
  - scala spacing **base 4px**: `gapXs=4, gapSm=8, gapMd=12, gapLg=16, gapXl=24, gap2xl=32`.
- Esposizione: `GenTheme.of(context)` che ritorna i `GenTokens`. Meccanismo consigliato: `InheritedWidget` fornito da `GenApp` (§2.3). `ShadThemeData` **non** è un `ThemeData` Flutter, quindi non usare `ThemeExtension` — usa l'InheritedWidget.

### 2.3 `lib/theme/gen_app.dart`
- `GenApp` = wrapper su **`ShadApp.material(...)`** (variante Material-compatibile: durante la migrazione convivono widget Material e shadcn, serve l'ancestor Material).
- Fornisce `theme`/`darkTheme` (da §2.2) e avvolge il child con l'`InheritedWidget` dei `GenTokens`.
- Espone `themeMode` toggle (light/dark) come parametro.

### 2.4 `lib/primitives/` — typedef 1:1
Crea un file per gruppo (o uno per widget) con i `typedef`. **Verifica i nomi esatti** delle classi aprendo il package installato (`~/.pub-cache/hosted/pub.dev/shadcn_ui-0.55.0/lib/`) ed enumerando gli export pubblici `Shad*` — non fidarti di nomi a memoria.

Set **core** da fare in questa fase (mappa 1:1 al widget shadcn corrispondente):
`GenButton, GenIconButton, GenInput, GenInputFormField, GenTextarea, GenSelect, GenCheckbox, GenSwitch, GenRadioGroup, GenCard, GenBadge, GenAvatar, GenSeparator, GenDialog, GenSheet, GenPopover, GenTooltip, GenTabs, GenToast/Sonner, GenProgress, GenTable, GenDatePicker, GenTimePicker`

Esempio:
```dart
import 'package:shadcn_ui/shadcn_ui.dart';
typedef GenButton = ShadButton;   // GenButton.destructive(...) resta disponibile
```

Barrel: `lib/primitives/primitives.dart` che riesporta tutti i typedef.

Le **restanti** primitive shadcn (accordion, alert, calendar, command, context-menu, menubar, input-otp, resizable, slider…) si fanno **dopo**, stesso pattern.

### 2.5 `lib/genai_components.dart` (barrel principale)
Aggiungi export di `theme/gen_theme.dart`, `theme/gen_app.dart`, `primitives/primitives.dart`. **Non toccare** gli export CL esistenti. Attenzione a eventuali collisioni di nomi in `flutter analyze`.

### 2.6 Example smoke — `example/gen_main.dart`
Nuovo entry (NON modificare `example/main.dart` esistente). Boota `GenApp` e renderizza in una singola pagina scrollabile:
- ogni variante di `GenButton` (default/secondary/destructive/outline/ghost/link) + uno stato disabled + uno con `backgroundColor: GenTheme.of(context).success` (dimostra i colori semantici via estensione).
- `GenInput`, `GenInputFormField` con un validator, `GenSelect`, `GenCheckbox`, `GenSwitch`.
- `GenCard`, `GenBadge`, `GenAvatar`, `GenSeparator`.
- un `GenDialog` aperto da bottone, un `GenToast`.
- una riga che dimostra la scala spacing (box separati da `gapXs…gap2xl`).
- toggle **light/dark** in appbar.

Questa pagina è di fatto la prima **kitchen-sink** (cresce nelle fasi dopo).

## 3. Vincoli

- `shadcn_ui` **pinnato** a `0.55.0`.
- `ShadApp.material` (non `ShadApp` puro) per l'interop Material.
- **Additivo**: zero modifiche/cancellazioni al codice `CL*` e a `example/main.dart`.
- Spacing sempre **multipli di 4**.
- Prefisso `Gen` per tutto il nuovo pubblico.
- **Nessun test widget Flutter** (headless non renderizza shader/RenderObject).

## 4. Fuori scope (fasi successive)

Migrazione app (admin/emp/lms/hrqr), widget Livello 2 (shell, tabella paginata, charts, org-chart, CRM), split del god-widget `CLTextField`, cancellazione codice CL, release/publish.

## 5. Ordine consigliato

1. dep + `pub get` (verifica constraint).
2. `GenTokens` + `GenTheme` + `GenApp`.
3. `example/gen_main.dart` minimo che boota `GenApp` con **un** `GenButton` → conferma che tema/app compilano e renderizzano.
4. resto dei typedef core + completa la kitchen-sink.

## 6. Verifica (obbligatoria prima di consegnare)

```bash
flutter pub get
flutter analyze                                   # zero error
flutter run -t example/gen_main.dart -d chrome    # o -d macos
```
Controllo manuale: la pagina renderizza tutte le primitive; il toggle light/dark cambia tema; i bottoni semantici (success) usano il colore giusto; gli spacing sono coerenti. Screenshot light + dark.

## 7. Cosa riportare a fine task

- Versione `shadcn_ui` risolta + eventuali bump di constraint necessari.
- Elenco dei `typedef` creati (e quelli saltati perché il nome shadcn non combaciava / widget assente in 0.55.0).
- Nomi Shad reali usati (per validare la mappatura).
- Output di `flutter analyze` + screenshot light/dark dell'example.
- Problemi/attriti incontrati (interop Material, temi, constraint).
