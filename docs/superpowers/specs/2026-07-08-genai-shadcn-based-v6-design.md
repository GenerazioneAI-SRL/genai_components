# genai_components v6 — "shadcn_based" · Design

- **Data:** 2026-07-08
- **Branch:** `shadcn_based`
- **Stato:** design approvato in brainstorming — in attesa review spec
- **Tipo:** major release breaking (v5 → v6)

---

## 1. Contesto e problema

`genai_components` (v5.9.1, 274 file) è un design system Flutter custom costruito sopra Material. I widget base (bottoni, input) sono reimplementati a mano con micro-interazioni proprie. Manutenzione delle primitive interamente a carico nostro; qualità non allineata a librerie di riferimento (shadcn/tailwind).

Obiettivo: ricostruire genai_components appoggiandosi a **`shadcn_ui`** (nank1ro, MIT, pre-1.0), delegando alla libreria le primitive e il loro feel, mantenendo un design system 100% di proprietà (nomi, brand, widget di dominio).

## 2. Obiettivi / Non-obiettivi

**Obiettivi**
- Adottare `shadcn_ui` come fondamenta delle primitive UI.
- API pubblica di proprietà con prefisso **`Gen`** (brand GenerazioneAI).
- Single source of truth sul tema.
- Riusare i widget di dominio esistenti ricomponendoli sulle primitive Gen.

**Non-obiettivi**
- Nessuna retrocompatibilità con l'API v5 (tabula rasa).
- Non reimplementare micro-animazioni proprie (si adotta il feel shadcn).
- Non toccare stack non-UI (GoRouter, Provider, easy_localization, OIDC).

## 3. Decisioni lockate

1. **Dipendenza (non vendoring):** `shadcn_ui` come dependency di genai_components, **pinnata** a `0.55.0`. Approccio "facade/guscio" (opzione C), leaning sulla libreria per feel e micro-animazioni. Il vendoring (copiare il sorgente) è stato **valutato e scartato**: 62.462 righe / 256 file da mantenere a vita, pipeline di codegen ereditata (`slang`, `theme_extensions_builder`), perdita della manutenzione upstream gratis. Il nome `Shad*` resta interno a genai, invisibile ai consumatori. La churn pre-1.0 si gestisce pinnando la versione, non copiando.
2. **Prefisso `Gen`** per tutta l'API pubblica: `GenButton`, `GenInput`, `GenTheme`, ecc. Lo script interno `./cl` resta invariato (nome tool, cosmetico).
3. **Architettura a 2 livelli** (vedi §4).
4. **Feel:** si adotta quello di shadcn. Nessuna micro-interazione custom re-introdotta.
5. **Tema (Opzione 1):** `ShadThemeData` è l'unica sorgente di verità. Root app passa da `MaterialApp` a `ShadApp.material` (variante Material-compatibile). Estensione Gen (`GenTokens`) per ciò che shadcn non ha: colori semantici `success/info/warning` (`ShadColorScheme` ha solo `destructive`) **+ scala di spacing globale su griglia 4px** (shadcn non ha una spacing scale: padding solo per-componente). Meccanismo: `InheritedWidget` (`ShadThemeData` non è un `ThemeData` Flutter, niente `ThemeExtension`). Padding interno widget → shadcn; margin/gap tra widget → layout con token Gen.
6. **API tabula rasa:** l'API v5 muore. Le primitive Gen espongono la forma API di shadcn (`child:`, `leading:`, `onPressed?:`). Nessuno shim di retrocompat.
7. **Migrazione app incrementale**, per widget, via grep/codemod nel monorepo. genai linkato in DEV (`./cl dev`).

## 4. Architettura a 2 livelli

```
Livello 2 — COMPLESSI / DOMINIO (di proprietà):
   GenTable, GenOrgChart, GenNodeGraph, GenCharts,
   GenAiAssistant, GenSurvey, GenFaq, GenGantt, GenEntityTabs, ...
        │  costruiti COMPONENDO ↓
Livello 1 — PRIMITIVE (1:1 con shadcn):
   GenButton  GenInput  GenCheckbox  GenSelect  GenCard
   GenDialog  GenSheet  GenPopover  GenTabs  GenBadge  ...
        │  wrap/rename di ↓
   shadcn_ui (ShadButton, ShadInput, ...)
```

### Livello 1 — Primitive (1:1 shadcn)

- Mappatura **1:1**: `GenButton = ShadButton`, `GenInput = ShadInput`, ecc.
- Meccanismo di default: **`typedef GenX = ShadX;`** (i costruttori nominati shadcn — es. `GenButton.destructive(...)` — restano disponibili tramite typedef).
- **Promozione a wrapper sottile** solo se emerge un bisogno reale (es. boilerplate ricorrente). Il nome Gen resta uguale → le app non se ne accorgono.
- Copre le ~45 primitive shadcn: accordion, alert, avatar, badge, button, calendar, card, checkbox, context-menu, date-picker, dialog, form, input, input-otp, menubar, popover, progress, radio, resizable, select, separator, sheet, slider, switch, table (base), tabs, textarea, time-picker, toast/sonner, tooltip, command.

### Livello 2 — Complessi / dominio (di proprietà)

- Widget che shadcn **non ha**: charts, org_chart, node_graph (canvas), ai_assistant, paged_datatable, survey, faq, announcement, entity_tabs, responsive_grid, gantt.
- Esistono già in v5 → **si ricompongono** usando le primitive Gen del Livello 1 (i bottoni/input interni diventano `GenButton`/`GenInput`), leggendo i token da `ShadTheme`.
- Lavoro = refactor (restyle + ricomposizione), non greenfield.

## 5. Tema

- `ShadThemeData` unico oggetto tema, settato in `GenApp` (wrapper su `ShadApp` Material-compatibile).
- Palette light/dark v5 mappate in `ShadColorScheme`.
- **Estensione semantica Gen** per `success` / `info` / `warning` (assenti in shadcn). Un bottone "successo" = `backgroundColor: theme.success`, non una variante dedicata.
- I widget di Livello 2 leggono `ShadTheme.of(context)`.

## 6. Casi concreti

### GenButton — primitiva 1:1

```dart
typedef GenButton = ShadButton;   // GenButton.destructive(...) funziona
```

- Feel, varianti (`default/secondary/destructive/outline/ghost/link`), animazioni: tutto shadcn.
- **Spariscono** le varianti colore v5 (`.primary/.success/.warning`). Semantica colore via `backgroundColor`.
- `loading`/`haptic` **non** re-introdotti (haptic inutile su web; loading = spinner in `leading`, promuovibile a wrapper se il boilerplate diventa frequente).

### GenInput e lo split del god-widget

`CLTextField` v5 = god-widget da 714 righe, **558 usi in 110 file**, che impacchetta 6 mestieri. Si **spacca** nelle primitive giuste:

| Mestiere v5 | Usi app | Primitiva Gen | shadcn |
|---|---|---|---|
| testo/password | ~grezzo | `GenInput` | ShadInput |
| testo + **validazione** | 237 con `validators` | `GenInputFormField` | ShadInputFormField |
| textarea | 11 | `GenTextarea` | ShadTextarea |
| date picker | 67 | `GenDatePicker` | ShadDatePicker |
| time picker | 21 | `GenTimePicker` | ShadTimePicker |
| color picker | 4 | `GenColorField` (custom, Livello 2) | — |
| file picker | 4 | `GenFileField` (custom, Livello 2) | — |

- **Deciso (1:1 shadcn):** `GenInput` (grezzo) + `GenInputFormField` (validato), come `ShadInput`/`ShadInputFormField`. Niente nome unico che le fonde.
- Migrazione: ~470 casi = rinomina quasi meccanica su `GenInput`/`GenInputFormField`; ~88 date/ora su componenti dedicati; 8 picker custom (Livello 2).

## 7. Struttura package (proposta)

```
lib/
  genai_components.dart          # barrel export
  theme/
    gen_theme.dart               # ShadThemeData + GenTokens (success/info/warning + spacing 4px)
    gen_app.dart                 # GenApp = ShadApp.material (Material-compatibile)
  primitives/                    # Livello 1 — 1:1 shadcn (typedef/thin wrapper)
    gen_button.dart
    gen_input.dart
    gen_date_picker.dart
    ...
  widgets/                       # Livello 2 — complessi/dominio, composti da primitive
    table/ org_chart/ node_graph/ charts/ ai_assistant/ survey/ ...
  utils/  enums/  core_models/   # invariati
```

## 8. Piano di migrazione (alto livello)

1. Aggiungere `shadcn_ui`, definire `GenTheme` + `GenApp`, mappare palette light/dark.
2. Definire le primitive Livello 1 (typedef).
3. Switch root app `MaterialApp` → `ShadApp` (per app: admin, emp, lms, hrqr).
4. Migrare per widget, dal più usato: `GenButton` → `GenInput` (+ split date/time/color/file) → resto.
5. Ricomporre i widget di dominio (Livello 2) sulle primitive Gen.
6. Rimuovere codice v5 morto man mano.

Il piano dettagliato per-task va nel documento di implementazione (skill writing-plans).

## 9. Rischi

- **shadcn_ui pre-1.0**: breaking changes sugli upgrade. Mitigazione: versione pinnata, upgrade deliberati; i pochi wrapper "caldi" assorbono i breaking in un punto.
- **Interop ShadApp/Material**: durante la migrazione convivono widget Material e shadcn → usare `ShadApp.material`/`ShadApp.custom` per mantenere l'ancestor Material.
- **Ampiezza migrazione**: 558 usi text field, molti bottoni → fasi obbligatorie, non big-bang.
- **Dark mode**: mappare correttamente le palette v5 in `ShadColorScheme`.

## 10. Example / dev driver

- **App example unica = finto CRM** (ruolo: dev driver + reference vivo). Serve a sviluppare i widget in un flusso reale e a beccare i bug d'integrazione presto (risolve l'uovo-gallina: costruisci `GenTable` → la provi subito).
- La **gallery** v5 (`example/main.dart`, widget isolati) **eliminata**. Sostituita da una **kitchen-sink dev-page** dentro il CRM (tutti i widget in tutti gli stati) come smoke-test della copertura isolata.
- **Struttura CRM (MVP):** shell (sidebar + topbar) → Dashboard (KPI card + `GenCharts` + tabella) → Contatti (`GenTable` con ricerca/filtri/paginazione) → Contatto (form `GenInputFormField` + `GenSelect` + `GenDatePicker`, validazione, salva→`GenToast`, elimina→`GenDialog`) → kitchen-sink. Stretch: kanban trattative, impostazioni.
- **Shell:** flutter-shadcn-ui **non ha** sidebar/shell (sono "blocks" solo-React). La shell è un widget **Livello 2 di proprietà**: si porta `CLAdaptiveShell` (+ slot, nav rail, breadcrumb già esistenti) → `GenAdaptiveShell`, restyle su `ShadTheme`, interni ricomposti da primitive Gen.
- **Dati:** seed in-memory finto, latenza simulata (`Future.delayed`) per loading/skeleton. Niente backend/NATS.
- **Principio buchi shadcn:** ciò che flutter-shadcn-ui non ha (shell, tabella paginata, org-chart, charts, gantt) → Livello 2 nostro, quasi sempre **già esistente in v5** → porta + restyle, non greenfield.

## 11. Domande aperte

- Nessuna. Decisioni chiuse in brainstorming (2026-07-08 → 09).

## 12. Fasi

- **Fase 1 — Fondazione + primitive:** dep + `GenTheme`/`GenApp`/`GenTokens` + typedef primitive core + kitchen-sink smoke. Work-order: `docs/superpowers/plans/2026-07-09-fase1-fondazione-primitive.md`.
- **Fasi successive:** shell + widget Livello 2, schermate CRM, migrazione app, split `CLTextField`, rimozione codice CL.
