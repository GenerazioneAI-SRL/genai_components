part of 'paged_datatable.dart';

abstract class TableFilter<TValue> {
  final String title;
  final String id;
  final String Function(TValue value) chipFormatter;
  final TValue? defaultValue;
  final bool visible;
  final bool isMainFilter;

  const TableFilter({
    required this.id,
    required this.title,
    required this.chipFormatter,
    required this.defaultValue,
    required this.visible,
    required this.isMainFilter,
  });

  Widget buildPicker(BuildContext context, TableFilterState state);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is TableFilter ? other.id == id : false;
}

/// A filter that is not visible in the popup dialog but can be set with the controller.
class ProgrammaticTableFilter<TValue> extends TableFilter<TValue> {
  const ProgrammaticTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    super.defaultValue,
    super.visible = false,
    required super.isMainFilter,
  });

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return const SizedBox.shrink();
  }
}

class TextTableFilter extends TableFilter<String> {
  InputDecoration? decoration;
  Function(String)? onChange;
  TextEditingController? _controller;
  FocusNode? _focusNode;
  Timer? _debounceTimer;

  TextTableFilter({
    this.onChange,
    this.decoration,
    required super.chipFormatter,
    required super.id,
    required super.title,
    super.isMainFilter = false,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController(text: state.value);
    _focusNode ??= FocusNode();
    final theme = GenTokens.of(context);

    void onFieldChanged(String value) {
      if (onChange != null) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 350), () {
          onChange!(value);
        });
      } else if (value.isNotEmpty) {
        state.value = value;
      }
    }

    return ShadInput(
      controller: _controller!,
      focusNode: _focusNode,
      placeholder: Text(isMainFilter ? "Cerca per $title" : "Filtra per $title"),
      leading: Icon(LucideIcons.search, size: theme.iconSizeCompact),
      onChanged: onFieldChanged,
    );
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _controller?.dispose();
    _controller = null;
    _focusNode?.dispose();
    _focusNode = null;
  }
}

class DropdownTableFilter<TValue> extends TableFilter<TValue> {
  final InputDecoration? decoration;
  final List<DropdownMenuItem<TValue>> items;

  const DropdownTableFilter({
    this.decoration,
    required this.items,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return ShadSelect<TValue>(
      placeholder: Text(title),
      initialValue: state.value,
      options: [
        for (final i in items)
          if (i.value != null) ShadOption<TValue>(value: i.value as TValue, child: i.child),
      ],
      selectedOptionBuilder: (context, value) => Text('$value'),
      onChanged: (v) => state.value = v,
    );
  }
}

class DatePickerTableFilter extends TableFilter<DateTime> {
  final InputDecoration? decoration;
  final DateTime firstDate, lastDate;
  final DateFormat? dateFormat;

  const DatePickerTableFilter({
    this.decoration,
    this.dateFormat,
    required this.firstDate,
    required this.lastDate,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

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
}

class DateRangePickerTableFilter extends TableFilter<DateTimeRange> {
  final InputDecoration? decoration;
  final DateTime firstDate, lastDate;
  final DateFormat? dateFormat;

  const DateRangePickerTableFilter({
    this.decoration,
    this.dateFormat,
    required this.firstDate,
    required this.lastDate,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

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
}

/// Filtro dropdown che usa CLDropdown con supporto per ricerca sincrona
///
/// Esempio di utilizzo:
/// ```dart
/// CLDropdownTableFilterSync<MyModel>(
///   id: "myModelId",
///   title: "Seleziona modello",
///   items: myModelList,
///   itemBuilder: (context, item) => Text(item.name),
///   valueToShow: (item) => item.name,
///   valueToSend: (item) => item.id,  // Valore da inviare al backend
///   searchCallback: (query) async => myModelList.where((m) => m.name.contains(query)).toList(),
///   chipFormatter: (item) => item.name,
///   isMainFilter: false,
/// )
/// ```
class CLDropdownTableFilterSync<TValue extends Object> extends TableFilter<TValue> {
  final List<TValue> items;
  final Widget Function(BuildContext, TValue) itemBuilder;
  final String Function(TValue) valueToShow;
  final Future<List<TValue>> Function(String)? searchCallback;
  final dynamic Function(TValue)? valueToSend;

  const CLDropdownTableFilterSync({
    required this.items,
    required this.itemBuilder,
    required this.valueToShow,
    this.searchCallback,
    this.valueToSend,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenSelect<TValue>(
      placeholder: Text(title),
      initialValue: state.value is TValue ? state.value : null,
      options: [for (final it in items) ShadOption<TValue>(value: it, child: itemBuilder(context, it))],
      selectedOptionBuilder: (context, value) => Text(valueToShow(value)),
      onChanged: (v) => state.value = v,
    );
  }

  // Metodo per estrarre il valore da inviare al backend
  dynamic getValueForBackend(dynamic value) {
    if (value == null) return null;
    if (valueToSend != null && value is TValue) {
      return valueToSend!(value);
    }
    return value;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Filtri data/ora — picker nativi Shad (GenDatePicker/GenTimePicker/GenSelect)
// ═══════════════════════════════════════════════════════════════════════════

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

/// Esempio di utilizzo:
/// ```dart
/// CLDropdownTableFilterAsync<City>(
///   id: "cityId",
///   title: "Seleziona città",
///   searchCallback: viewModel.getAllCities,
///   searchColumn: "name",
///   itemBuilder: (context, city) => Text(city.name),
///   valueToShow: (city) => city.name,
///   valueToSend: (city) => city.id,  // Valore da inviare al backend
///   chipFormatter: (city) => city.name,
///   isMainFilter: false,
/// )
/// ```
class CLDropdownTableFilterAsync<TValue extends Object> extends TableFilter<TValue> {
  final Future<(List<TValue>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) searchCallback;
  final String searchColumn;
  final Widget Function(BuildContext, TValue) itemBuilder;
  final String Function(TValue) valueToShow;
  final dynamic Function(TValue)? valueToSend;

  /// Dimensione di pagina passata a [GenSelectAsync] (infinite-scroll).
  final int perPage;

  const CLDropdownTableFilterAsync({
    required this.searchCallback,
    required this.searchColumn,
    required this.itemBuilder,
    required this.valueToShow,
    this.valueToSend,
    this.perPage = 100,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return GenSelectAsync<TValue>(
      placeholder: Text(title),
      searchCallback: searchCallback,
      searchColumn: searchColumn,
      valueToShow: valueToShow,
      optionBuilder: itemBuilder,
      perPage: perPage,
      initialValue: state.value is TValue ? state.value : null,
      // Salva sempre l'oggetto completo nello stato.
      onChanged: (newValue) => state.value = newValue,
    );
  }

  // Metodo per estrarre il valore da inviare al backend
  dynamic getValueForBackend(dynamic value) {
    if (value == null) return null;
    if (valueToSend != null && value is TValue) {
      return valueToSend!(value);
    }
    return value;
  }
}
