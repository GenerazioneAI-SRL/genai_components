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
    final theme = CLTheme.of(context);

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

    if (isMainFilter) {
      // Search field: recess L2 (tertiaryBackground), no border. Altezza standard
      // (inputHeight) per allineare con gli altri controlli della toolbar.
      // Prefix-icon left pad + size sono la sorgente unica su cui la colonna
      // checkbox si centra (vedi PagedDataTableRowMetrics.searchIconCenterX).
      final m = PagedDataTableRowMetrics.of(context);
      return Container(
        height: theme.inputHeight,
        decoration: BoxDecoration(
          color: _tableSearchFill(context),
          borderRadius: BorderRadius.circular(theme.radiusControl),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: m.searchPrefixLeftPad, right: theme.gapSm),
              child: Icon(
                LucideIcons.search,
                color: theme.primaryText,
                size: m.searchPrefixIconSize,
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _controller!,
                focusNode: _focusNode,
                maxLines: 1,
                style: theme.bodyText.copyWith(fontWeight: FontWeight.w400, height: 1.0),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: "Cerca per $title",
                  hintStyle: theme.bodyText.copyWith(color: theme.secondaryText, height: 1.0),
                ),
                onChanged: onFieldChanged,
              ),
            ),
            SizedBox(width: theme.gapMd),
          ],
        ),
      );
    }

    return CLTextField(
      fillColor: theme.secondaryBackground,
      controller: _controller!,
      focusNode: _focusNode,
      labelText: "Filtra per $title",
      prefixIcon: Icon(
        LucideIcons.search,
        color: theme.secondaryText,
        size: 18,
      ),
      onChanged: (value) async => onFieldChanged(value),
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
    return DropdownButtonFormField<TValue>(
      items: items,
      value: state.value,
      onChanged: (newValue) {},
      onSaved: (newValue) {
        state.value = newValue;
      },
      decoration: decoration ?? InputDecoration(labelText: title),
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
    return _DateTimePicker(
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      initialDate: state.value,
      decoration: decoration ?? InputDecoration(labelText: title),
      onSaved: (newValue) {
        if (newValue != null) {
          state.value = newValue;
        }
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
    return _DateTimeRangePicker(
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      initialValue: state.value,
      decoration: decoration ?? InputDecoration(labelText: title),
      onSaved: (newValue) {
        if (newValue != null) {
          state.value = newValue;
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
    return CLDropdown<TValue>.singleSync(
      hint: title,
      items: items,
      valueToShow: valueToShow,
      searchCallback: searchCallback,
      itemBuilder: itemBuilder,
      selectedValues: state.value is TValue ? state.value : null,
      onSelectItem: (newValue) {
        // Salva sempre l'oggetto completo nello stato
        state.value = newValue;
      },
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
// Filtri inline con CLTextField (senza picker/calendario)
// ═══════════════════════════════════════════════════════════════════════════

/// Filtro data singola — CLTextField.date (gg/mm/aaaa)
class CLDateTableFilter extends TableFilter<DateTime> {
  TextEditingController? _controller;

  CLDateTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController();

    return CLTextField.date(
      controller: _controller!,
      labelText: title,
      initialSelectedDateTime: state.value is DateTime ? state.value : null,
      onDateTimeSelected: (date) {
        state.value = date;
      },
    );
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

/// Filtro data e ora — CLTextField.dateTime (gg/mm/aaaa hh:mm)
class CLDateTimeTableFilter extends TableFilter<DateTime> {
  TextEditingController? _controller;

  CLDateTimeTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController();

    return CLTextField.dateTime(
      controller: _controller!,
      labelText: title,
      initialSelectedDateTime: state.value is DateTime ? state.value : null,
      onDateTimeSelected: (date) {
        state.value = date;
      },
    );
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

/// Filtro solo ora — CLTextField.time (hh:mm)
class CLTimeTableFilter extends TableFilter<DateTime> {
  TextEditingController? _controller;

  CLTimeTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController();

    return CLTextField.time(
      controller: _controller!,
      labelText: title,
      initialSelectedTime: state.value is DateTime
          ? TimeOfDay(hour: (state.value as DateTime).hour, minute: (state.value as DateTime).minute)
          : null,
      onTimeSelected: (time) {
        if (time != null) {
          final now = DateTime.now();
          state.value = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        } else {
          state.value = null;
        }
      },
    );
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

/// Filtro mese — CLTextField.month (mm/aaaa)
class CLMonthTableFilter extends TableFilter<DateTime> {
  TextEditingController? _controller;

  CLMonthTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController();

    return CLTextField.month(
      controller: _controller!,
      labelText: title,
      initialSelectedDateTime: state.value is DateTime ? state.value : null,
      onDateTimeSelected: (date) {
        state.value = date;
      },
    );
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

/// Filtro anno — CLTextField.year (aaaa)
class CLYearTableFilter extends TableFilter<DateTime> {
  TextEditingController? _controller;

  CLYearTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController();

    return CLTextField.year(
      controller: _controller!,
      labelText: title,
      initialSelectedDateTime: state.value is DateTime ? state.value : null,
      onDateTimeSelected: (date) {
        state.value = date;
      },
    );
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

/// Filtro range di date — due CLTextField.date affiancati (Da / A)
class CLDateRangeTableFilter extends TableFilter<DateTimeRange> {
  TextEditingController? _startController;
  TextEditingController? _endController;

  CLDateRangeTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _startController ??= TextEditingController();
    _endController ??= TextEditingController();

    DateTime? startDate;
    DateTime? endDate;

    if (state.value is DateTimeRange) {
      startDate = (state.value as DateTimeRange).start;
      endDate = (state.value as DateTimeRange).end;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CLTextField.date(
            controller: _startController!,
            labelText: 'Da',
            initialSelectedDateTime: startDate,
            onDateTimeSelected: (date) {
              startDate = date;
              if (startDate != null && endDate != null) {
                state.value = DateTimeRange(start: startDate!, end: endDate!);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CLTextField.date(
            controller: _endController!,
            labelText: 'A',
            initialSelectedDateTime: endDate,
            onDateTimeSelected: (date) {
              endDate = date;
              if (startDate != null && endDate != null) {
                state.value = DateTimeRange(start: startDate!, end: endDate!);
              }
            },
          ),
        ),
      ],
    );
  }

  void dispose() {
    _startController?.dispose();
    _startController = null;
    _endController?.dispose();
    _endController = null;
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
  final Future<(List<TValue>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})
      searchCallback;
  final String searchColumn;
  final Widget Function(BuildContext, TValue) itemBuilder;
  final String Function(TValue) valueToShow;
  final dynamic Function(TValue)? valueToSend;

  const CLDropdownTableFilterAsync({
    required this.searchCallback,
    required this.searchColumn,
    required this.itemBuilder,
    required this.valueToShow,
    this.valueToSend,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return CLDropdown<TValue>.singleAsync(
      hint: title,
      searchCallback: searchCallback,
      searchColumn: searchColumn,
      valueToShow: valueToShow,
      itemBuilder: itemBuilder,
      selectedValues: state.value is TValue ? state.value : null,
      onSelectItem: (newValue) {
        // Salva sempre l'oggetto completo nello stato
        state.value = newValue;
      },
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

