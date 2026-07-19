import 'package:flutter/widgets.dart';
// Budella Shad: nucleo interno = ShadDatePicker reale (trigger ShadButton.outline
// + popover + ShadCalendar nativi). Solo i simboli usati (show). Firma pubblica
// CLDatePicker (single/range + campi) invariata. Tono dai colori CL via il
// bridge ShadTheme (cl_theme.toShadTheme). Locale IT lun-first.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadDatePicker, ShadDateTimeRange;

const List<String> _months = [
  'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
  'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
];
const List<String> _weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String _fmtMonth(DateTime d) => _months[d.month - 1];
String _fmtMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';
String _fmtWeekday(DateTime d) => _weekdays[d.weekday - 1];

/// Date picker **in-theme** (shadcn `ShadDatePicker`): trigger a bottone (icona
/// calendario + data/placeholder) che apre un popover ancorato con il calendario.
/// Varianti `single` e `range`. Nessun dialog Material.
class CLDatePicker extends StatelessWidget {
  /// Selezione singola.
  const CLDatePicker({
    super.key,
    this.selected,
    this.onChanged,
    this.placeholder,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.width,
    this.closeOnSelect = true,
  })  : isRange = false,
        rangeStart = null,
        rangeEnd = null,
        onRangeChanged = null;

  /// Selezione di un intervallo.
  const CLDatePicker.range({
    super.key,
    this.rangeStart,
    this.rangeEnd,
    this.onRangeChanged,
    this.placeholder,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.width,
    this.closeOnSelect = false,
  })  : isRange = true,
        selected = null,
        onChanged = null;

  final bool isRange;
  final DateTime? selected;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final void Function(DateTime? start, DateTime? end)? onRangeChanged;

  final String? placeholder;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final double? width;

  /// Chiude il popover alla selezione (single: default true; range: false).
  final bool closeOnSelect;

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // firstDate/lastDate (bound a livello di giorno) ripiegati nel predicate:
  // ShadDatePicker/Calendar disabilita i giorni col predicate.
  bool _selectable(DateTime d) {
    if (firstDate != null && d.isBefore(_dayOnly(firstDate!))) return false;
    if (lastDate != null && d.isAfter(_dayOnly(lastDate!))) return false;
    return selectableDayPredicate?.call(d) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (isRange) {
      return ShadDatePicker.range(
        selected: (rangeStart == null && rangeEnd == null)
            ? null
            : ShadDateTimeRange(start: rangeStart, end: rangeEnd),
        onRangeChanged: (r) => onRangeChanged?.call(r?.start, r?.end),
        placeholder: Text(placeholder ?? 'Seleziona intervallo'),
        closeOnSelection: closeOnSelect,
        width: width,
        selectableDayPredicate: _selectable,
        weekStartsOn: 1,
        formatDateRange: (r) {
          final s = r.start == null ? '…' : _fmt(r.start!);
          final e = r.end == null ? '…' : _fmt(r.end!);
          return '$s → $e';
        },
        formatMonth: _fmtMonth,
        formatMonthYear: _fmtMonthYear,
        formatWeekday: _fmtWeekday,
      );
    }
    return ShadDatePicker(
      selected: selected,
      onChanged: onChanged,
      placeholder: Text(placeholder ?? 'Seleziona data'),
      closeOnSelection: closeOnSelect,
      width: width,
      selectableDayPredicate: _selectable,
      weekStartsOn: 1,
      formatDate: _fmt,
      formatMonth: _fmtMonth,
      formatMonthYear: _fmtMonthYear,
      formatWeekday: _fmtWeekday,
    );
  }
}
