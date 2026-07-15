# Datatable Native Shad Pickers — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rendere `PagedDataTable` 100% Gen/Shad, sostituendo tutti gli input data/ora e il dropdown di ordinamento con componenti nativi Shad, ed eliminando le dipendenze dal layer `old/` e da `calendar_date_picker2`.

**Architecture:** I filtri data/ora del datatable smettono di usare `CLTextField.*` (maschera) e i dialog `calendar_date_picker2`; passano ai nativi `GenDatePicker`/`GenTimePicker`/`GenSelect` (già aliasati in `gen/primitives/gen_primitives.dart`). Tre nuovi widget riusabili (`GenDateTimeField`, `GenMonthField`, `GenYearField`) coprono i casi composti (data+ora, mese+anno, anno). Il modello `Pagination` viene spostato sotto `gen/` e re-esportato dal barrel per non rompere i consumer.

**Tech Stack:** Flutter, shadcn_ui ^0.55.0 (ShadDatePicker/ShadTimePicker/ShadSelect), intl, package genai_components.

## Global Constraints

- **NO test automatici**: non lanciare `flutter test`. Verifica di ogni task = `flutter analyze` pulito + hot-reload manuale dell'utente. (Preferenza utente registrata.)
- **Nessuna breaking API pubblica**: i nomi delle classi filtro (`CLDateTableFilter`, `DatePickerTableFilter`, ecc.) e la firma `fetchPage`/`Pagination` restano invariati per i consumer.
- **Valori invariati verso il backend**: `state.value` resta `DateTime` / `DateTimeRange`; `chipFormatter` non cambia.
- Locale mesi via `intl` (`DateFormat.MMMM()`), già dipendenza.
- Intervallo anni default: `DateTime.now().year - 10 .. + 10`. Bound `GenDatePicker` default: nessuno (calendario libero) salvo `firstDate`/`lastDate` già presenti sui filtri picker → mappati a `fromMonth`/`toMonth`.
- Commit frequenti, uno per task.

**Riferimenti API verificati (shadcn_ui 0.55.0):**
- `GenDatePicker = ShadDatePicker`; single: `ShadDatePicker(selected: DateTime?, onChanged: ValueChanged<DateTime?>?, placeholder: Widget?, fromMonth: DateTime?, toMonth: DateTime?)`.
- `GenDatePicker.range`: `ShadDatePicker.range(selected: ShadDateTimeRange?, onRangeChanged: ValueChanged<ShadDateTimeRange?>?, placeholder:, fromMonth:, toMonth:)`. `ShadDateTimeRange({DateTime? start, DateTime? end})`.
- `GenTimePicker = ShadTimePicker`: `ShadTimePicker(initialValue: ShadTimeOfDay?, onChanged: ValueChanged<ShadTimeOfDay>?)`. `ShadTimeOfDay({required int hour, required int minute, required int second})`.
- `GenSelect<T> = ShadSelect<T>`, `GenOption<T> = ShadOption<T>`: `GenSelect<T>(placeholder: Widget?, initialValue: T?, options: List<Widget>, selectedOptionBuilder: (context, T) => Widget, onChanged: ValueChanged<T?>?)`.
- `GenSizes.gapSm = 8.0`.

**Nota lifecycle:** `TableFilter` (abstract, `paged_datatable_filter.dart:3`) richiede solo `buildPicker`. I metodi `dispose()` sulle classi filtro **non** sono `@override` e **non** vengono mai chiamati dall'esterno → rimuoverli con i loro `_controller` è sicuro.

---

### Task 1: Widget `GenYearField` + helper anni condiviso

**Files:**
- Create: `lib/gen/widgets/gen_date_field_utils.dart`
- Create: `lib/gen/widgets/gen_year_field.dart`
- Modify: `lib/gen/gen.dart` (aggiungere export)

**Interfaces:**
- Produces: `List<int> genYearRange(int? firstYear, int? lastYear)` — lista anni inclusiva, default `now.year-10..now.year+10`.
- Produces: `class GenYearField extends StatelessWidget` con `GenYearField({DateTime? initialValue, required ValueChanged<DateTime?> onChanged, int? firstYear, int? lastYear, Widget? placeholder})`; emette `DateTime(anno)` o `null`.

- [ ] **Step 1: Creare l'helper anni**

`lib/gen/widgets/gen_date_field_utils.dart`:
```dart
/// Utility condivise dai campi data Gen (mese/anno).
library;

/// Ritorna la lista inclusiva di anni tra [firstYear] e [lastYear].
/// Default: anno corrente ±10.
List<int> genYearRange(int? firstYear, int? lastYear) {
  final now = DateTime.now();
  final first = firstYear ?? now.year - 10;
  final last = lastYear ?? now.year + 10;
  return [for (var y = first; y <= last; y++) y];
}
```

- [ ] **Step 2: Creare `GenYearField`**

`lib/gen/widgets/gen_year_field.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';

import 'gen_date_field_utils.dart';

/// Campo di selezione anno (tendina Shad). Emette un [DateTime] al 1° gennaio
/// dell'anno scelto, o `null` se deselezionato. Intervallo default: anno
/// corrente ±10, sovrascrivibile con [firstYear]/[lastYear].
class GenYearField extends StatelessWidget {
  const GenYearField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.firstYear,
    this.lastYear,
    this.placeholder,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final int? firstYear;
  final int? lastYear;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final years = genYearRange(firstYear, lastYear);
    return GenSelect<int>(
      placeholder: placeholder ?? const Text('Anno'),
      initialValue: initialValue?.year,
      options: [
        for (final y in years) GenOption<int>(value: y, child: Text('$y')),
      ],
      selectedOptionBuilder: (context, value) => Text('$value'),
      onChanged: (y) => onChanged(y == null ? null : DateTime(y)),
    );
  }
}
```

- [ ] **Step 3: Esportare dal barrel**

In `lib/gen/gen.dart`, nella sezione dei custom widget, aggiungere:
```dart
export 'widgets/gen_year_field.dart';
```

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/gen/widgets/gen_year_field.dart lib/gen/widgets/gen_date_field_utils.dart lib/gen/gen.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/gen/widgets/gen_year_field.dart lib/gen/widgets/gen_date_field_utils.dart lib/gen/gen.dart
git commit -m "feat(gen): GenYearField (tendina anno nativa Shad)"
```

---

### Task 2: Widget `GenMonthField`

**Files:**
- Create: `lib/gen/widgets/gen_month_field.dart`
- Modify: `lib/gen/gen.dart` (export)

**Interfaces:**
- Consumes: `genYearRange` (Task 1).
- Produces: `class GenMonthField extends StatefulWidget` con `GenMonthField({DateTime? initialValue, required ValueChanged<DateTime?> onChanged, int? firstYear, int? lastYear})`; emette `DateTime(anno, mese)` quando entrambe le tendine sono valorizzate, `null` altrimenti.

- [ ] **Step 1: Creare `GenMonthField`**

`lib/gen/widgets/gen_month_field.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';

import 'gen_date_field_utils.dart';

/// Campo mese+anno (due tendine Shad affiancate). Emette un [DateTime] al 1°
/// del mese/anno scelti quando entrambe le tendine sono valorizzate, `null`
/// altrimenti. Preserva la semantica `mm/aaaa`.
class GenMonthField extends StatefulWidget {
  const GenMonthField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.firstYear,
    this.lastYear,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final int? firstYear;
  final int? lastYear;

  @override
  State<GenMonthField> createState() => _GenMonthFieldState();
}

class _GenMonthFieldState extends State<GenMonthField> {
  int? _month;
  int? _year;

  @override
  void initState() {
    super.initState();
    _month = widget.initialValue?.month;
    _year = widget.initialValue?.year;
  }

  void _emit() {
    if (_month != null && _year != null) {
      widget.onChanged(DateTime(_year!, _month!));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.MMMM();
    final years = genYearRange(widget.firstYear, widget.lastYear);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GenSelect<int>(
            placeholder: const Text('Mese'),
            initialValue: _month,
            options: [
              for (var m = 1; m <= 12; m++)
                GenOption<int>(
                  value: m,
                  child: Text(monthLabel.format(DateTime(2000, m))),
                ),
            ],
            selectedOptionBuilder: (context, value) =>
                Text(monthLabel.format(DateTime(2000, value))),
            onChanged: (m) {
              setState(() => _month = m);
              _emit();
            },
          ),
        ),
        const SizedBox(width: GenSizes.gapSm),
        Expanded(
          child: GenSelect<int>(
            placeholder: const Text('Anno'),
            initialValue: _year,
            options: [
              for (final y in years) GenOption<int>(value: y, child: Text('$y')),
            ],
            selectedOptionBuilder: (context, value) => Text('$value'),
            onChanged: (y) {
              setState(() => _year = y);
              _emit();
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Esportare dal barrel**

In `lib/gen/gen.dart` aggiungere:
```dart
export 'widgets/gen_month_field.dart';
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/gen/widgets/gen_month_field.dart lib/gen/gen.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/gen/widgets/gen_month_field.dart lib/gen/gen.dart
git commit -m "feat(gen): GenMonthField (mese+anno con tendine native Shad)"
```

---

### Task 3: Widget `GenDateTimeField`

**Files:**
- Create: `lib/gen/widgets/gen_datetime_field.dart`
- Modify: `lib/gen/gen.dart` (export)

**Interfaces:**
- Produces: `class GenDateTimeField extends StatefulWidget` con `GenDateTimeField({DateTime? initialValue, required ValueChanged<DateTime?> onChanged, DateTime? firstDate, DateTime? lastDate})`; emette un `DateTime` completo quando data e ora sono entrambe presenti, `null` altrimenti.

- [ ] **Step 1: Creare `GenDateTimeField`**

`lib/gen/widgets/gen_datetime_field.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';

/// Campo data+ora: combina [GenDatePicker] (parte data) e [GenTimePicker]
/// (parte ora) affiancati. Emette un [DateTime] completo quando entrambe le
/// parti sono valorizzate, `null` altrimenti.
class GenDateTimeField extends StatefulWidget {
  const GenDateTimeField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<GenDateTimeField> createState() => _GenDateTimeFieldState();
}

class _GenDateTimeFieldState extends State<GenDateTimeField> {
  DateTime? _date;
  ShadTimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    if (v != null) {
      _date = DateTime(v.year, v.month, v.day);
      _time = ShadTimeOfDay(hour: v.hour, minute: v.minute, second: 0);
    }
  }

  void _emit() {
    final d = _date;
    final t = _time;
    if (d != null && t != null) {
      widget.onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GenDatePicker(
            selected: _date,
            fromMonth: widget.firstDate,
            toMonth: widget.lastDate,
            onChanged: (d) {
              setState(() => _date = d);
              _emit();
            },
          ),
        ),
        const SizedBox(width: GenSizes.gapSm),
        Expanded(
          child: GenTimePicker(
            initialValue: _time,
            onChanged: (t) {
              setState(() => _time = t);
              _emit();
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Esportare dal barrel**

In `lib/gen/gen.dart` aggiungere:
```dart
export 'widgets/gen_datetime_field.dart';
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/gen/widgets/gen_datetime_field.dart lib/gen/gen.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/gen/widgets/gen_datetime_field.dart lib/gen/gen.dart
git commit -m "feat(gen): GenDateTimeField (data+ora con GenDatePicker+GenTimePicker)"
```

---

### Task 4: Re-home del modello `Pagination`

**Files:**
- Create: `lib/gen/datatable/pagination.model.dart` (copia di `lib/old/utils/models/pagination.model.dart`)
- Modify: `lib/gen/datatable/paged_datatable.dart:1` (import)
- Modify: `lib/gen/gen.dart` (re-export)

**Interfaces:**
- Produces: `Pagination` disponibile via `package:genai_components/gen/gen.dart` (stesso nome/classe di prima).

- [ ] **Step 1: Copiare il modello sotto gen/**

Copiare integralmente il contenuto di `lib/old/utils/models/pagination.model.dart` in un nuovo file `lib/gen/datatable/pagination.model.dart` (è un modello leaf, zero import interni — copia verbatim). Comando:
```bash
cp lib/old/utils/models/pagination.model.dart lib/gen/datatable/pagination.model.dart
```

- [ ] **Step 2: Aggiornare l'import nel datatable**

In `lib/gen/datatable/paged_datatable.dart` riga 1, sostituire:
```dart
import 'package:genai_components/old/utils/models/pagination.model.dart';
```
con:
```dart
import 'package:genai_components/gen/datatable/pagination.model.dart';
```

- [ ] **Step 3: Re-export dal barrel (consumer invariati)**

In `lib/gen/gen.dart`, vicino all'export del datatable, aggiungere:
```dart
export 'datatable/pagination.model.dart';
```

- [ ] **Step 4: Analyze su lib ed example**

Run: `flutter analyze lib example`
Expected: `No issues found!` (i consumer come `example/lib/modules/users/pages/users_page.dart` continuano a importare `Pagination` dal barrel senza modifiche).

- [ ] **Step 5: Commit**

```bash
git add lib/gen/datatable/pagination.model.dart lib/gen/datatable/paged_datatable.dart lib/gen/gen.dart
git commit -m "refactor(gen): re-home Pagination sotto gen/datatable + re-export dal barrel"
```

---

### Task 5: Migrare i 6 filtri data/ora a maschera → picker nativi

**Files:**
- Modify: `lib/gen/datatable/paged_datatable_filter.dart` (classi `CLDateTableFilter`, `CLDateTimeTableFilter`, `CLTimeTableFilter`, `CLMonthTableFilter`, `CLYearTableFilter`, `CLDateRangeTableFilter`)

**Interfaces:**
- Consumes: `GenDateTimeField`, `GenMonthField`, `GenYearField` (Task 1-3); `GenDatePicker`, `GenTimePicker` (primitives).
- Produces: le stesse classi filtro, senza `TextEditingController`, con `state.value` invariato (`DateTime`/`DateTimeRange`).

Nota: tutti i tipi `GenDateTimeField`/`GenMonthField`/`GenYearField` sono raggiunti via il barrel già importato nel datatable (verificare che `paged_datatable.dart` importi `gen/gen.dart` o i singoli file; se il datatable usa import puntuali, aggiungere gli import ai nuovi widget in testa a `paged_datatable_filter.dart`).

- [ ] **Step 1: `CLDateTableFilter` → `GenDatePicker`**

Sostituire l'intera classe `CLDateTableFilter` (rimuovendo `_controller` e `dispose()`):
```dart
/// Filtro data singola — GenDatePicker (calendario Shad nativo)
class CLDateTableFilter extends TableFilter<DateTime> {
  CLDateTableFilter({required super.chipFormatter, required super.id, required super.title, required super.isMainFilter, super.defaultValue})
    : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenDatePicker(
      placeholder: Text(title),
      selected: state.value is DateTime ? state.value : null,
      onChanged: (date) => state.value = date,
    );
  }
}
```

- [ ] **Step 2: `CLDateTimeTableFilter` → `GenDateTimeField`**

```dart
/// Filtro data e ora — GenDateTimeField (GenDatePicker + GenTimePicker)
class CLDateTimeTableFilter extends TableFilter<DateTime> {
  CLDateTimeTableFilter({required super.chipFormatter, required super.id, required super.title, required super.isMainFilter, super.defaultValue})
    : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenDateTimeField(
      initialValue: state.value is DateTime ? state.value : null,
      onChanged: (date) => state.value = date,
    );
  }
}
```

- [ ] **Step 3: `CLTimeTableFilter` → `GenTimePicker`**

```dart
/// Filtro solo ora — GenTimePicker (hh:mm). Salva un DateTime con la data di
/// oggi + ora/minuti, come il comportamento legacy.
class CLTimeTableFilter extends TableFilter<DateTime> {
  CLTimeTableFilter({required super.chipFormatter, required super.id, required super.title, required super.isMainFilter, super.defaultValue})
    : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    final v = state.value is DateTime ? state.value as DateTime : null;
    return GenTimePicker(
      initialValue: v == null ? null : ShadTimeOfDay(hour: v.hour, minute: v.minute, second: 0),
      onChanged: (t) {
        final now = DateTime.now();
        state.value = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      },
    );
  }
}
```

- [ ] **Step 4: `CLMonthTableFilter` → `GenMonthField`**

```dart
/// Filtro mese — GenMonthField (tendine mese + anno, mm/aaaa)
class CLMonthTableFilter extends TableFilter<DateTime> {
  CLMonthTableFilter({required super.chipFormatter, required super.id, required super.title, required super.isMainFilter, super.defaultValue})
    : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenMonthField(
      initialValue: state.value is DateTime ? state.value : null,
      onChanged: (date) => state.value = date,
    );
  }
}
```

- [ ] **Step 5: `CLYearTableFilter` → `GenYearField`**

```dart
/// Filtro anno — GenYearField (tendina anno)
class CLYearTableFilter extends TableFilter<DateTime> {
  CLYearTableFilter({required super.chipFormatter, required super.id, required super.title, required super.isMainFilter, super.defaultValue})
    : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenYearField(
      initialValue: state.value is DateTime ? state.value : null,
      onChanged: (date) => state.value = date,
    );
  }
}
```

- [ ] **Step 6: `CLDateRangeTableFilter` → `GenDatePicker.range`**

```dart
/// Filtro range di date — GenDatePicker.range (calendario Shad, Da/A)
class CLDateRangeTableFilter extends TableFilter<DateTimeRange> {
  CLDateRangeTableFilter({required super.chipFormatter, required super.id, required super.title, required super.isMainFilter, super.defaultValue})
    : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    final r = state.value is DateTimeRange ? state.value as DateTimeRange : null;
    return GenDatePicker.range(
      placeholder: Text(title),
      selected: r == null ? null : ShadDateTimeRange(start: r.start, end: r.end),
      onRangeChanged: (range) {
        if (range?.start != null && range?.end != null) {
          state.value = DateTimeRange(start: range!.start!, end: range.end!);
        } else {
          state.value = null;
        }
      },
    );
  }
}
```

- [ ] **Step 7: Analyze**

Run: `flutter analyze lib/gen/datatable/paged_datatable_filter.dart`
Expected: `No issues found!` (nessun riferimento a `CLTextField` residuo in queste 6 classi; `_controller`/`dispose` rimossi).

- [ ] **Step 8: Hot-reload — verifica manuale (utente)**

Chiedere all'utente di hot-reload e provare in una tabella d'esempio i filtri: data, data+ora, ora, mese, anno, range. Verificare che selezione, chip e reset funzionino.

- [ ] **Step 9: Commit**

```bash
git add lib/gen/datatable/paged_datatable_filter.dart
git commit -m "feat(datatable): filtri data/ora a maschera -> picker nativi Shad"
```

---

### Task 6: Migrare i filtri a calendario e rimuovere i picker legacy di controls.dart

**Files:**
- Modify: `lib/gen/datatable/paged_datatable_filter.dart` (classi `DatePickerTableFilter`, `DateRangePickerTableFilter`)
- Delete: `lib/gen/datatable/controls.dart` (contiene solo `_DateTimePicker` e `_DateTimeRangePicker`)
- Modify: `lib/gen/datatable/paged_datatable.dart` (rimuovere `part 'controls.dart';`)

**Interfaces:**
- Consumes: `GenDatePicker`, `ShadDateTimeRange` (primitives).
- Produces: `DatePickerTableFilter`/`DateRangePickerTableFilter` invariate come API, ora su picker nativi.

- [ ] **Step 1: `DatePickerTableFilter` → `GenDatePicker`**

Sostituire il corpo (mantenendo i campi `decoration`, `firstDate`, `lastDate`, `dateFormat` per compatibilità API):
```dart
  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenDatePicker(
      placeholder: Text(decoration?.labelText ?? title),
      selected: state.value is DateTime ? state.value : null,
      fromMonth: firstDate,
      toMonth: lastDate,
      onChanged: (date) {
        if (date != null) state.value = date;
      },
    );
  }
```

- [ ] **Step 2: `DateRangePickerTableFilter` → `GenDatePicker.range`**

```dart
  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    final r = state.value is DateTimeRange ? state.value as DateTimeRange : null;
    return GenDatePicker.range(
      placeholder: Text(decoration?.labelText ?? title),
      selected: r == null ? null : ShadDateTimeRange(start: r.start, end: r.end),
      fromMonth: firstDate,
      toMonth: lastDate,
      onRangeChanged: (range) {
        if (range?.start != null && range?.end != null) {
          state.value = DateTimeRange(start: range!.start!, end: range.end!);
        }
      },
    );
  }
```

- [ ] **Step 3: Eliminare controls.dart e la sua direttiva part**

Verificare che `controls.dart` contenga solo `_DateTimePicker` e `_DateTimeRangePicker` (più `part of 'paged_datatable.dart';`):
```bash
grep -nE "^class |^part of" lib/gen/datatable/controls.dart
```
Se l'output elenca solo quelle due classi, eliminare il file:
```bash
git rm lib/gen/datatable/controls.dart
```
Poi in `lib/gen/datatable/paged_datatable.dart` rimuovere la riga:
```dart
part 'controls.dart';
```

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/gen/datatable`
Expected: `No issues found!` (nessun riferimento residuo a `_DateTimePicker`/`_DateTimeRangePicker`).

- [ ] **Step 5: Hot-reload — verifica manuale (utente)**

Provare i filtri `DatePickerTableFilter` e `DateRangePickerTableFilter` (calendario singolo e range) in una tabella d'esempio.

- [ ] **Step 6: Commit**

```bash
git add lib/gen/datatable/paged_datatable_filter.dart lib/gen/datatable/paged_datatable.dart
git rm --cached lib/gen/datatable/controls.dart 2>/dev/null; true
git commit -m "feat(datatable): filtri a calendario -> GenDatePicker, rimossi picker legacy controls.dart"
```

---

### Task 7: Migrare il dropdown "Ordina per" → `GenSelect`

**Files:**
- Modify: `lib/gen/datatable/paged_datatable_filter_bar.dart` (righe ~425 e ~689, i due `CLDropdown.singleSync`)

**Interfaces:**
- Consumes: `GenSelect`, `GenOption` (primitives).
- Produces: stesso comportamento (imposta `selectedColumn`/`descending`; applicazione all'"Applica").

Nota: `SortBy` espone `columnId` e `descending`. Gli `items`/`sortItems` sono `List<Map<BaseTableColumn?, bool>>` con due voci per colonna (`{col: true}` = discendente, `{col: false}` = ascendente). L'`initialValue` è l'istanza in lista che combacia con `state._sortModel` (identità di Map garantita perché le options sono costruite dalla stessa lista).

- [ ] **Step 1: Sostituire il blocco 1 (~riga 425)**

Rimpiazzare il widget `CLDropdown<Map<BaseTableColumn<TResult>?, bool>>.singleSync(...)` con:
```dart
GenSelect<Map<BaseTableColumn<TResult>?, bool>>(
  placeholder: const Text('Ordina per'),
  initialValue: () {
    final sm = state._sortModel;
    if (sm == null) return null;
    for (final it in items) {
      if (it.keys.first?.id == sm.columnId && it.values.first == sm.descending) {
        return it;
      }
    }
    return null;
  }(),
  options: [
    for (final it in items)
      GenOption<Map<BaseTableColumn<TResult>?, bool>>(
        value: it,
        child: Text(it.values.first
            ? '${it.keys.first!.title} - Discendente'
            : '${it.keys.first!.title} - Ascendente'),
      ),
  ],
  selectedOptionBuilder: (context, value) => Text(value.values.first
      ? '${value.keys.first!.title} - Discendente'
      : '${value.keys.first!.title} - Ascendente'),
  onChanged: (item) {
    if (item != null) {
      selectedColumn = item.keys.first;
      descending = item.values.first;
    }
  },
),
```

- [ ] **Step 2: Sostituire il blocco 2 (~riga 689)**

Idem, usando la lista `sortItems` al posto di `items`:
```dart
GenSelect<Map<BaseTableColumn<TResult>?, bool>>(
  placeholder: const Text('Ordina per'),
  initialValue: () {
    final sm = state._sortModel;
    if (sm == null) return null;
    for (final it in sortItems) {
      if (it.keys.first?.id == sm.columnId && it.values.first == sm.descending) {
        return it;
      }
    }
    return null;
  }(),
  options: [
    for (final it in sortItems)
      GenOption<Map<BaseTableColumn<TResult>?, bool>>(
        value: it,
        child: Text(it.values.first
            ? '${it.keys.first!.title} - Discendente'
            : '${it.keys.first!.title} - Ascendente'),
      ),
  ],
  selectedOptionBuilder: (context, value) => Text(value.values.first
      ? '${value.keys.first!.title} - Discendente'
      : '${value.keys.first!.title} - Ascendente'),
  onChanged: (item) {
    if (item != null) {
      selectedColumn = item.keys.first;
      descending = item.values.first;
    }
  },
),
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/gen/datatable/paged_datatable_filter_bar.dart`
Expected: `No issues found!`

- [ ] **Step 4: Hot-reload — verifica manuale (utente)**

Aprire il pannello filtri/ordinamento, verificare che la tendina "Ordina per" mostri le colonne (asc/desc), pre-selezioni l'ordinamento corrente, e che "Applica" ordini correttamente.

- [ ] **Step 5: Commit**

```bash
git add lib/gen/datatable/paged_datatable_filter_bar.dart
git commit -m "feat(datatable): dropdown Ordina per -> GenSelect nativo"
```

---

### Task 8: Rimuovere gli import legacy e verifica finale legacy-free

**Files:**
- Modify: `lib/gen/datatable/paged_datatable.dart` (rimuovere import `cl_text_field`, `cl_dropdown`, `calendar_date_picker2`)

**Interfaces:**
- Produces: `lib/gen/datatable` senza alcun riferimento a `old/` o `calendar_date_picker2`.

- [ ] **Step 1: Rimuovere i 3 import residui**

In `lib/gen/datatable/paged_datatable.dart`, eliminare le righe:
```dart
import 'package:genai_components/old/widgets/cl_text_field.widget.dart';
import 'package:genai_components/old/widgets/cl_dropdown/cl_dropdown.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
```
(L'import di `Pagination` è già stato aggiornato nel Task 4.)

- [ ] **Step 2: Verifica grep — zero legacy nel datatable**

Run:
```bash
grep -rnE "genai_components/old|calendar_date_picker2|CLTextField|CLDropdown[^T]" lib/gen/datatable | grep -vE "^\s*//|///"
```
Expected: nessun output (0 risultati non-commento).

- [ ] **Step 3: Analyze completo su lib ed example**

Run: `flutter analyze lib example`
Expected: `No issues found!`

- [ ] **Step 4: Hot-reload — smoke test completo (utente)**

Chiedere all'utente di eseguire un giro completo: tabella d'esempio con tutti i tipi di filtro data/ora + ordinamento + paginazione, per confermare che nulla si sia rotto.

- [ ] **Step 5: Commit**

```bash
git add lib/gen/datatable/paged_datatable.dart
git commit -m "chore(datatable): rimossi import old/ e calendar_date_picker2 -> datatable legacy-free"
```

---

## Self-Review (eseguita in fase di stesura)

**Spec coverage:**
- Nuovi widget `GenDateTimeField`/`GenMonthField`/`GenYearField` → Task 3/2/1 ✓
- Mappatura 8 classi filtro → Task 5 (6 masked) + Task 6 (2 calendario) ✓
- Dropdown "Ordina per" → Task 7 ✓
- Re-home `Pagination` + re-export → Task 4 ✓
- Rimozione import `old/` + `calendar_date_picker2` → Task 8 ✓
- Rimozione `_DateTimePicker`/`_DateTimeRangePicker`/controls.dart → Task 6 ✓
- Default anni ±10 / bound `fromMonth`/`toMonth` → Global Constraints + Task 1/3/6 ✓
- Verifica via analyze + hot-reload (no test) → ogni task ✓

**Placeholder scan:** nessun TBD/TODO; ogni step di codice mostra il codice completo.

**Type consistency:** `genYearRange(int?, int?)` definito in Task 1 e usato in Task 1/2; `GenDateTimeField`/`GenMonthField`/`GenYearField` firme coerenti tra definizione (Task 1-3) e uso (Task 5); `state.value` sempre `DateTime`/`DateTimeRange`; callback picker allineate alle firme shadcn_ui verificate.

## Rischi noti (dal design)

- **Popover-in-popover**: rischio basso, `ShadSelect` già lo fa nel datatable. Verificare in hot-reload (Task 5/6/7).
- **Filtro ora non azzerabile dal picker** (`GenTimePicker.onChanged` non nullable): il chip resta rimovibile dalla UI filtri. Accettabile; segnalare se emerge in verifica.
- **Ingombro verticale `GenTimePicker`** dentro il popover filtri: valutare in hot-reload; eventualmente wrappare in scroll.
