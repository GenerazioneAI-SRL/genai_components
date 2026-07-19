import 'package:flutter/material.dart';
// Budella Shad: nucleo interno = ShadCalendar reale (griglia/nav/caption-dropdown/
// range/multiple nativi). Solo i simboli usati (show). Firma pubblica CLCalendar
// (costruttori single/multiple/range + tutti i flag) invariata. Tono dai colori
// CL via il bridge ShadTheme (cl_theme.toShadTheme). Locale IT lun-first tramite
// formatMonth/formatWeekday + weekStartsOn:1.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadCalendar, ShadCalendarCaptionLayout, ShadDateTimeRange;

/// Modalità di selezione del [CLCalendar] (shadcn `ShadCalendarVariant`).
enum CLCalendarVariant { single, multiple, range }

/// Layout dell'intestazione (shadcn `ShadCalendarCaptionLayout`): etichetta
/// testuale, oppure dropdown per mese e/o anno.
enum CLCalendarCaptionLayout { label, dropdownMonths, dropdownYears, dropdown }

/// Lato del pill giorno (shadcn `dayButtonSize: 36`).
const double _kDaySize = 36;

/// Calendario **in-theme**, ora su `ShadCalendar` reale (dependency shadcn_ui).
/// Header con nav mese, riga giorni settimana, griglia; selected = primary CL ·
/// today = stile Shad · fuori-mese attenuato. Settimana lun-first, IT.
///
/// Feature (allineate a shadcn): `showWeekNumbers`, `showOutsideDays`,
/// `fixedWeeks`, `hideNavigation`, `hideWeekdayNames`, `numberOfMonths`,
/// `captionLayout`, `fromMonth`/`toMonth` (bound nav), `min`/`max` (conteggio
/// multiple / lunghezza range). `firstDate`/`lastDate` disabilitano i giorni
/// fuori intervallo (ripiegati nel `selectableDayPredicate`).
class CLCalendar extends StatefulWidget {
  /// Selezione singola.
  const CLCalendar({
    super.key,
    this.selected,
    this.initialMonth,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.showWeekNumbers = false,
    this.showOutsideDays = true,
    this.fixedWeeks = false,
    this.hideNavigation = false,
    this.hideWeekdayNames = false,
    this.numberOfMonths = 1,
    this.captionLayout = CLCalendarCaptionLayout.label,
    this.fromMonth,
    this.toMonth,
  })  : variant = CLCalendarVariant.single,
        selectedDates = const [],
        onMultipleChanged = null,
        rangeStart = null,
        rangeEnd = null,
        onRangeChanged = null,
        min = null,
        max = null;

  /// Selezione multipla (più giorni). `min`/`max` = conteggio giorni.
  const CLCalendar.multiple({
    super.key,
    this.selectedDates = const [],
    this.initialMonth,
    this.onMultipleChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.min,
    this.max,
    this.showWeekNumbers = false,
    this.showOutsideDays = true,
    this.fixedWeeks = false,
    this.hideNavigation = false,
    this.hideWeekdayNames = false,
    this.numberOfMonths = 1,
    this.captionLayout = CLCalendarCaptionLayout.label,
    this.fromMonth,
    this.toMonth,
  })  : variant = CLCalendarVariant.multiple,
        selected = null,
        onChanged = null,
        rangeStart = null,
        rangeEnd = null,
        onRangeChanged = null;

  /// Selezione di un intervallo (start–end). `min`/`max` = lunghezza in giorni.
  const CLCalendar.range({
    super.key,
    this.rangeStart,
    this.rangeEnd,
    this.initialMonth,
    this.onRangeChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.min,
    this.max,
    this.showWeekNumbers = false,
    this.showOutsideDays = true,
    this.fixedWeeks = false,
    this.hideNavigation = false,
    this.hideWeekdayNames = false,
    this.numberOfMonths = 1,
    this.captionLayout = CLCalendarCaptionLayout.label,
    this.fromMonth,
    this.toMonth,
  })  : variant = CLCalendarVariant.range,
        selected = null,
        onChanged = null,
        selectedDates = const [],
        onMultipleChanged = null;

  final CLCalendarVariant variant;

  final DateTime? selected;
  final ValueChanged<DateTime>? onChanged;

  final List<DateTime> selectedDates;
  final ValueChanged<List<DateTime>>? onMultipleChanged;

  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final void Function(DateTime? start, DateTime? end)? onRangeChanged;

  final DateTime? initialMonth;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime)? selectableDayPredicate;

  /// multiple = conteggio giorni; range = lunghezza intervallo (giorni).
  final int? min;
  final int? max;

  final bool showWeekNumbers;
  final bool showOutsideDays;
  final bool fixedWeeks;
  final bool hideNavigation;
  final bool hideWeekdayNames;
  final int numberOfMonths;
  final CLCalendarCaptionLayout captionLayout;

  /// Mese minimo/massimo navigabile.
  final DateTime? fromMonth;
  final DateTime? toMonth;

  @override
  State<CLCalendar> createState() => _CLCalendarState();
}

class _CLCalendarState extends State<CLCalendar> {
  static const _months = [
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
  ];
  static const _weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  String _fmtMonth(DateTime d) => _months[d.month - 1];
  String _fmtMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';
  String _fmtWeekday(DateTime d) => _weekdays[d.weekday - 1];

  ShadCalendarCaptionLayout get _captionLayout => switch (widget.captionLayout) {
        CLCalendarCaptionLayout.label => ShadCalendarCaptionLayout.label,
        CLCalendarCaptionLayout.dropdownMonths =>
          ShadCalendarCaptionLayout.dropdownMonths,
        CLCalendarCaptionLayout.dropdownYears =>
          ShadCalendarCaptionLayout.dropdownYears,
        CLCalendarCaptionLayout.dropdown => ShadCalendarCaptionLayout.dropdown,
      };

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // firstDate/lastDate (bound a livello di giorno) ripiegati nel predicate:
  // ShadCalendar limita la nav con fromMonth/toMonth, i giorni col predicate.
  bool _selectable(DateTime d) {
    if (widget.firstDate != null && d.isBefore(_dayOnly(widget.firstDate!))) {
      return false;
    }
    if (widget.lastDate != null && d.isAfter(_dayOnly(widget.lastDate!))) {
      return false;
    }
    return widget.selectableDayPredicate?.call(d) ?? true;
  }

  DateTime? get _initialMonth =>
      widget.initialMonth ??
      widget.selected ??
      widget.rangeStart ??
      (widget.selectedDates.isNotEmpty ? widget.selectedDates.first : null);

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case CLCalendarVariant.single:
        return ShadCalendar(
          selected: widget.selected,
          onChanged: (d) {
            if (d != null) widget.onChanged?.call(d);
          },
          initialMonth: _initialMonth,
          selectableDayPredicate: _selectable,
          showWeekNumbers: widget.showWeekNumbers,
          showOutsideDays: widget.showOutsideDays,
          fixedWeeks: widget.fixedWeeks,
          hideNavigation: widget.hideNavigation,
          hideWeekdayNames: widget.hideWeekdayNames,
          numberOfMonths: widget.numberOfMonths,
          captionLayout: _captionLayout,
          fromMonth: widget.fromMonth,
          toMonth: widget.toMonth,
          weekStartsOn: 1,
          dayButtonSize: _kDaySize,
          formatMonth: _fmtMonth,
          formatMonthYear: _fmtMonthYear,
          formatWeekday: _fmtWeekday,
        );
      case CLCalendarVariant.multiple:
        return ShadCalendar.multiple(
          selected: widget.selectedDates,
          onChanged: (days) => widget.onMultipleChanged?.call(days),
          min: widget.min,
          max: widget.max,
          initialMonth: _initialMonth,
          selectableDayPredicate: _selectable,
          showWeekNumbers: widget.showWeekNumbers,
          showOutsideDays: widget.showOutsideDays,
          fixedWeeks: widget.fixedWeeks,
          hideNavigation: widget.hideNavigation,
          hideWeekdayNames: widget.hideWeekdayNames,
          numberOfMonths: widget.numberOfMonths,
          captionLayout: _captionLayout,
          fromMonth: widget.fromMonth,
          toMonth: widget.toMonth,
          weekStartsOn: 1,
          dayButtonSize: _kDaySize,
          formatMonth: _fmtMonth,
          formatMonthYear: _fmtMonthYear,
          formatWeekday: _fmtWeekday,
        );
      case CLCalendarVariant.range:
        return ShadCalendar.range(
          selected: (widget.rangeStart == null && widget.rangeEnd == null)
              ? null
              : ShadDateTimeRange(
                  start: widget.rangeStart, end: widget.rangeEnd),
          onChanged: (r) => widget.onRangeChanged?.call(r?.start, r?.end),
          min: widget.min,
          max: widget.max,
          initialMonth: _initialMonth,
          selectableDayPredicate: _selectable,
          showWeekNumbers: widget.showWeekNumbers,
          showOutsideDays: widget.showOutsideDays,
          fixedWeeks: widget.fixedWeeks,
          hideNavigation: widget.hideNavigation,
          hideWeekdayNames: widget.hideWeekdayNames,
          numberOfMonths: widget.numberOfMonths,
          captionLayout: _captionLayout,
          fromMonth: widget.fromMonth,
          toMonth: widget.toMonth,
          weekStartsOn: 1,
          dayButtonSize: _kDaySize,
          formatMonth: _fmtMonth,
          formatMonthYear: _fmtMonthYear,
          formatWeekday: _fmtWeekday,
        );
    }
  }
}
