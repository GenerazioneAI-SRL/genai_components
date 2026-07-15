# Design — Migrazione input data/ora del datatable a picker nativi Shad (datatable legacy-free)

Data: 2026-07-15
Branch: `shadcn_based`

## Obiettivo

Rendere `PagedDataTable` **100% Gen/Shad**, eliminando ogni dipendenza dal layer
legacy `old/` e dalla dipendenza `calendar_date_picker2`. Al termine il datatable
è drop-in in progetti terzi (es. Skillera admin) importando solo
`package:genai_components/gen/gen.dart`, senza montare il `CLThemeProvider`.

Punto di partenza: la migrazione a Shad è già all'~80%. Filtri testo (`ShadInput`),
select sincrono (`GenSelect`) e dropdown async (`GenSelectAsync`) sono già nativi.
Restano legacy **solo** gli input data/ora e un dropdown di ordinamento.

## Decisione architetturale

**Tutti i filtri data/ora usano picker nativi Shad.** Nessun campo a maschera
digitata: `GenDateField` (ipotizzato inizialmente) **non viene costruito**, e
`old/widgets/formatters/date_mask_formatter.dart` **non viene portato**. I
componenti nativi (`GenDatePicker = ShadDatePicker`, `GenTimePicker = ShadTimePicker`,
`GenSelect = ShadSelect`) sono già aliasati in `gen/primitives/gen_primitives.dart`.

Motivazione: consistenza UX 100% Shad, meno codice da mantenere, eliminazione di
`calendar_date_picker2`. Trade-off accettato: i filtri passano da "digiti i numeri"
a "clicchi/scegli"; mese e anno non hanno un picker Shad dedicato e vanno composti.

## Inventario legacy da rimuovere (airtight)

`lib/gen/datatable/`:

- `paged_datatable.dart` — import da rimuovere:
  - `old/utils/models/pagination.model.dart` (riga 1) → **re-home**, non rimozione
  - `old/widgets/cl_text_field.widget.dart` (riga 14)
  - `old/widgets/cl_dropdown/cl_dropdown.dart` (riga 17)
  - `calendar_date_picker2/calendar_date_picker2.dart` (riga 18)
- `paged_datatable_filter.dart` — 6 classi filtro masked + 2 classi filtro calendario
- `paged_datatable_filter_bar.dart` — 2× `CLDropdown.singleSync` (righe 425, 689)
- `controls.dart` — 2× `CLTextField` readonly (righe 33, 94) dentro
  `_DateTimePicker` / `_DateTimeRangePicker`

## Componenti nuovi (riusabili, in `gen/widgets/`, esportati dal barrel `gen.dart`)

Solo tre widget nuovi; date/range/ora si cablano direttamente sul nativo senza
wrapper.

### `GenDateTimeField`
- Scopo: catturare un `DateTime` completo (data + ora).
- Composizione: `GenDatePicker` (parte data) + `GenTimePicker` (parte ora),
  affiancati.
- Stato: **stateful**. Tiene `DateTime? _date` e `TimeOfDay? _time` separatamente;
  emette `onChanged(DateTime)` solo quando entrambi sono valorizzati (combina
  anno/mese/giorno + ora/minuti). Se uno dei due viene azzerato → `onChanged(null)`.
- API: `initialValue: DateTime?`, `onChanged: ValueChanged<DateTime?>`,
  `firstDate`/`lastDate` (default `DateTime(1900)`/`DateTime(2100)`), `placeholder`.

### `GenMonthField`
- Scopo: catturare mese + anno → `DateTime(anno, mese)`. Preserva la semantica
  attuale `mm/aaaa`.
- Composizione: due `GenSelect` — mese (1–12, label localizzata) + anno.
- Stato: **stateful**. Tiene `int? _month` e `int? _year`; emette
  `onChanged(DateTime(year, month))` quando entrambi presenti, `null` altrimenti.
- API: `initialValue: DateTime?`, `onChanged: ValueChanged<DateTime?>`,
  `firstYear`/`lastYear` (default `anno corrente ± 10`), `placeholder`.

### `GenYearField`
- Scopo: catturare un anno → `DateTime(anno)`.
- Composizione: un `GenSelect` (anno).
- Stato: stateless rispetto al valore (single select).
- API: `initialValue: DateTime?`, `onChanged: ValueChanged<DateTime?>`,
  `firstYear`/`lastYear` (default `anno corrente ± 10`), `placeholder`.

Nota: `GenMonthField` e `GenYearField` condividono la logica "lista anni" →
estrarre un helper privato comune (`_yearOptions(firstYear, lastYear)`).

## Mappatura filtro → nuovo componente

Tutti i valori (`state.value`) restano `DateTime` / `DateTimeRange`. `chipFormatter`
e il payload verso il backend **non cambiano**. Spariscono tutti i
`TextEditingController` e i relativi `dispose()`.

| Classe filtro | Oggi | Diventa |
|---|---|---|
| `CLDateTableFilter` | `CLTextField.date` | `GenDatePicker` (single) |
| `DatePickerTableFilter` | `_DateTimePicker` + `calendar_date_picker2` | `GenDatePicker` (single) |
| `CLDateRangeTableFilter` | 2× `CLTextField.date` | `GenDatePicker.range` |
| `DateRangePickerTableFilter` | `_DateTimeRangePicker` + `calendar_date_picker2` | `GenDatePicker.range` |
| `CLTimeTableFilter` | `CLTextField.time` | `GenTimePicker` |
| `CLDateTimeTableFilter` | `CLTextField.dateTime` | `GenDateTimeField` |
| `CLMonthTableFilter` | `CLTextField.month` | `GenMonthField` |
| `CLYearTableFilter` | `CLTextField.year` | `GenYearField` |

Note di mapping:
- **`GenDatePicker.range`** usa `ShadDateTimeRange` (start/end) ↔ mappare a/da
  `DateTimeRange`.
- **`GenTimePicker`** usa `ShadTimeOfDay` ↔ `TimeOfDay`. Il filtro ora continua a
  salvare un `DateTime` con la data di oggi + ora/minuti (comportamento attuale).
- Le **due famiglie** di filtri data (masked `CL*TableFilter` e calendario
  `*PickerTableFilter`) collassano sullo stesso picker nativo. Si **mantengono
  entrambi i nomi-classe** (nessuna breaking API pubblica); internamente diventano
  equivalenti. Eventuale deprecation/unificazione di una delle due → follow-up.
- `DatePickerTableFilter`/`DateRangePickerTableFilter` hanno già `firstDate`/`lastDate`:
  passarli a `GenDatePicker`. Per i filtri masked (senza bound) usare i default ampi.

## Componenti da rimuovere / svuotare

- `controls.dart`: `_DateTimePicker` e `_DateTimeRangePicker` diventano **inutili**
  (i loro consumer usano direttamente `GenDatePicker`/`.range`). Rimuovere entrambe
  le classi. Se dopo la rimozione `controls.dart` resta vuoto → eliminare il file e
  la sua direttiva `part`.

## Task sorella (necessaria per rimuovere gli import legacy)

I soli campi data **non bastano** a togliere l'import `cl_dropdown`. Serve anche:

### Dropdown "Ordina per" → `GenSelect`
`paged_datatable_filter_bar.dart` righe 425 e 689 usano
`CLDropdown<Map<BaseTableColumn?, bool>>.singleSync(hint, items, valueToShow,
itemBuilder, onSelectItem)`. Migrare a `GenSelect`/`ShadSelect`:
- `hint` → `placeholder`
- `items: List<T>` → `options: [ShadOption<T>(value:, child: itemBuilder(...))]`
- `valueToShow` → `selectedOptionBuilder`
- `onSelectItem` → `onChanged`

Pattern di riferimento già in repo: `CLDropdownTableFilterSync.buildPicker`
(`paged_datatable_filter.dart:234`) fa esattamente questa mappatura.

### Re-home `Pagination`
`old/utils/models/pagination.model.dart` è un modello **leaf** (zero import interni).
Spostarlo in `gen/datatable/pagination.model.dart` e **re-esportarlo dal barrel
`gen/gen.dart`**, così i consumer (`example/lib/modules/users/pages/users_page.dart`,
firma `fetchPage`) **non cambiano import** → nessuna breaking change.
NB: `Pagination` è usato anche da `lib/old/...` — quei file legacy tengono il
proprio import esistente, non vanno toccati.

### Rimozione import
Dopo i punti sopra, rimuovere da `paged_datatable.dart` gli import:
`cl_text_field`, `cl_dropdown`, `calendar_date_picker2`, e aggiornare l'import di
`pagination.model` alla nuova sede.

## Semantica valori e default

- Intervallo anni default: `DateTime.now().year - 10 .. + 10`, sovrascrivibile con
  `firstYear`/`lastYear` sui widget e (opzionali, con default) sui filtri `Month`/`Year`.
  `DateTime.now()` è valutato a runtime nel widget (nessun vincolo tipo workflow).
- Bound `GenDatePicker` default: `DateTime(1900)` .. `DateTime(2100)` dove non forniti.
- Mese: label mesi localizzate via `intl` (`DateFormat.MMMM`), già dipendenza.

## Rischi e mitigazioni

- **Popover dentro popover** (picker aperto dentro il popup filtri della tabella):
  rischio basso — `ShadSelect` fa già esattamente questo nel datatable e funziona
  (es. `DropdownTableFilter`, `CLDropdownTableFilterSync`). I nuovi picker usano lo
  stesso meccanismo di overlay Shad.
- **`GenTimePicker` inline nel filtro**: verificare in hot-reload che l'ingombro
  verticale nel popover filtri sia accettabile; in caso, wrappare in scroll.
- **Collasso due famiglie di filtri data**: mantenendo i nomi-classe non c'è
  breaking; il rischio è solo cosmetico (due classi con comportamento identico).

## Verifica (no test automatici — vedi memoria "no-run-tests")

- `flutter analyze` pulito su `lib/` ed `example/`.
- Hot-reload dell'utente: aprire una tabella d'esempio e verificare ogni tipo di
  filtro data/ora (data, range, ora, data+ora, mese, anno) + il dropdown "Ordina per".
- `grep -rn "genai_components/old\|calendar_date_picker2" lib/gen/datatable` → 0
  risultati (esclusi commenti).

## Fuori scope

- Rinomina delle classi filtro `CL*` → `Gen*` (cosmetica; le classi restano
  pubbliche, rinominarle sarebbe breaking). Eventuale follow-up con typedef alias.
- Unificazione delle due famiglie di filtri data in un'unica classe.
- Migrazione di altri consumer di `Pagination` fuori dal datatable.
