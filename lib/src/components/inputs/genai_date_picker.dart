import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';
import 'genai_text_field.dart';

/// Date picker — single date (§6.1.8).
///
/// Trigger looks like a [GenaiTextField]; clicking opens a calendar popover.
class GenaiDatePicker extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isDisabled;
  final bool clearable;
  final GenaiSize size;

  const GenaiDatePicker({
    super.key,
    this.label,
    this.hint = 'gg/mm/aaaa',
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.minDate,
    this.maxDate,
    this.isDisabled = false,
    this.clearable = true,
    this.size = GenaiSize.md,
  });

  @override
  State<GenaiDatePicker> createState() => _GenaiDatePickerState();
}

class _GenaiDatePickerState extends State<GenaiDatePicker> {
  String _format(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _open() async {
    if (widget.isDisabled) return;
    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _CalendarDialog(
        initial: widget.value ?? DateTime.now(),
        minDate: widget.minDate,
        maxDate: widget.maxDate,
      ),
    );
    if (result != null) widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = widget.value != null;
    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: GenaiTextField(
          label: widget.label,
          hint: widget.hint,
          helperText: widget.helperText,
          errorText: widget.errorText,
          isDisabled: widget.isDisabled,
          isReadOnly: true,
          size: widget.size,
          controller: TextEditingController(text: hasValue ? _format(widget.value!) : ''),
          suffix: hasValue && widget.clearable
              ? GenaiIconButton(
                  icon: LucideIcons.x,
                  size: GenaiSize.xs,
                  semanticLabel: 'Cancella data',
                  onPressed: () => widget.onChanged?.call(null),
                )
              : Icon(LucideIcons.calendar, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}

/// Date range picker (§6.1.8) — picks two dates.
class GenaiDateRangePicker extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?>? onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isDisabled;
  final bool clearable;
  final GenaiSize size;

  const GenaiDateRangePicker({
    super.key,
    this.label,
    this.hint = 'gg/mm/aaaa - gg/mm/aaaa',
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.minDate,
    this.maxDate,
    this.isDisabled = false,
    this.clearable = true,
    this.size = GenaiSize.md,
  });

  @override
  State<GenaiDateRangePicker> createState() => _GenaiDateRangePickerState();
}

class _GenaiDateRangePickerState extends State<GenaiDateRangePicker> {
  String _f(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _open() async {
    if (widget.isDisabled) return;
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (ctx) => _RangeDialog(
        initial: widget.value,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
      ),
    );
    if (result != null) widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = widget.value != null;
    final text = hasValue ? '${_f(widget.value!.start)} - ${_f(widget.value!.end)}' : '';
    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: GenaiTextField(
          label: widget.label,
          hint: widget.hint,
          helperText: widget.helperText,
          errorText: widget.errorText,
          isDisabled: widget.isDisabled,
          isReadOnly: true,
          size: widget.size,
          controller: TextEditingController(text: text),
          suffix: hasValue && widget.clearable
              ? GenaiIconButton(
                  icon: LucideIcons.x,
                  size: GenaiSize.xs,
                  semanticLabel: 'Cancella intervallo',
                  onPressed: () => widget.onChanged?.call(null),
                )
              : Icon(LucideIcons.calendarRange, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}

/// Month picker (§6.1.8).
class GenaiMonthPicker extends StatefulWidget {
  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final int? minYear;
  final int? maxYear;
  final bool isDisabled;
  final GenaiSize size;

  const GenaiMonthPicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.minYear,
    this.maxYear,
    this.isDisabled = false,
    this.size = GenaiSize.md,
  });

  @override
  State<GenaiMonthPicker> createState() => _GenaiMonthPickerState();
}

class _GenaiMonthPickerState extends State<GenaiMonthPicker> {
  static const _months = [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic',
  ];

  Future<void> _open() async {
    if (widget.isDisabled) return;
    final v = widget.value ?? DateTime.now();
    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthDialog(
        initialYear: v.year,
        initialMonth: v.month,
        minYear: widget.minYear ?? v.year - 10,
        maxYear: widget.maxYear ?? v.year + 10,
      ),
    );
    if (result != null) widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = widget.value == null ? '' : '${_months[widget.value!.month - 1]} ${widget.value!.year}';
    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: GenaiTextField(
          label: widget.label,
          hint: 'mese / anno',
          isDisabled: widget.isDisabled,
          isReadOnly: true,
          size: widget.size,
          controller: TextEditingController(text: text),
          suffix: Icon(LucideIcons.calendar, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}

// ───────── Internal calendar dialogs ─────────

class _CalendarDialog extends StatefulWidget {
  final DateTime initial;
  final DateTime? minDate;
  final DateTime? maxDate;
  const _CalendarDialog({required this.initial, this.minDate, this.maxDate});

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  late DateTime _visibleMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _visibleMonth = DateTime(widget.initial.year, widget.initial.month);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MonthHeader(
                visibleMonth: _visibleMonth,
                onPrev: () => setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1)),
                onNext: () => setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1)),
              ),
              const SizedBox(height: 12),
              _MonthGrid(
                visibleMonth: _visibleMonth,
                isSelected: (d) => d.year == _selected.year && d.month == _selected.month && d.day == _selected.day,
                isInRange: (_) => false,
                isEnabled: (d) => _isInBounds(d, widget.minDate, widget.maxDate),
                onTap: (d) => setState(() => _selected = d),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GenaiButton.ghost(
                    label: 'Annulla',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  GenaiButton.primary(
                    label: 'Conferma',
                    onPressed: () => Navigator.of(context).pop(_selected),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeDialog extends StatefulWidget {
  final DateTimeRange? initial;
  final DateTime? minDate;
  final DateTime? maxDate;
  const _RangeDialog({this.initial, this.minDate, this.maxDate});

  @override
  State<_RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<_RangeDialog> {
  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initial?.start;
    _end = widget.initial?.end;
    final base = _start ?? DateTime.now();
    _visibleMonth = DateTime(base.year, base.month);
  }

  void _tap(DateTime d) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        _start = d;
        _end = null;
      } else if (d.isBefore(_start!)) {
        _start = d;
      } else {
        _end = d;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MonthHeader(
                visibleMonth: _visibleMonth,
                onPrev: () => setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1)),
                onNext: () => setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1)),
              ),
              const SizedBox(height: 12),
              _MonthGrid(
                visibleMonth: _visibleMonth,
                isSelected: (d) => _sameDay(d, _start) || _sameDay(d, _end),
                isInRange: (d) => _start != null && _end != null && d.isAfter(_start!) && d.isBefore(_end!),
                isEnabled: (d) => _isInBounds(d, widget.minDate, widget.maxDate),
                onTap: _tap,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GenaiButton.ghost(
                    label: 'Annulla',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  GenaiButton.primary(
                    label: 'Conferma',
                    onPressed: _start != null && _end != null ? () => Navigator.of(context).pop(DateTimeRange(start: _start!, end: _end!)) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int minYear;
  final int maxYear;
  const _MonthDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.minYear,
    required this.maxYear,
  });

  @override
  State<_MonthDialog> createState() => _MonthDialogState();
}

class _MonthDialogState extends State<_MonthDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    const months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];

    return Dialog(
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GenaiIconButton(
                    icon: LucideIcons.chevronLeft,
                    semanticLabel: 'Anno precedente',
                    size: GenaiSize.sm,
                    onPressed: _year > widget.minYear ? () => setState(() => _year--) : null,
                  ),
                  Text('$_year', style: ty.headingSm.copyWith(color: colors.textPrimary)),
                  GenaiIconButton(
                    icon: LucideIcons.chevronRight,
                    semanticLabel: 'Anno successivo',
                    size: GenaiSize.sm,
                    onPressed: _year < widget.maxYear ? () => setState(() => _year++) : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.6,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 1; i <= 12; i++)
                    GestureDetector(
                      onTap: () => setState(() => _month = i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: i == _month ? colors.colorPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[i - 1],
                          style: ty.bodyMd.copyWith(
                            color: i == _month ? colors.textOnPrimary : colors.textPrimary,
                            fontWeight: i == _month ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GenaiButton.ghost(
                    label: 'Annulla',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  GenaiButton.primary(
                    label: 'Conferma',
                    onPressed: () => Navigator.of(context).pop(DateTime(_year, _month)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime visibleMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader({
    required this.visibleMonth,
    required this.onPrev,
    required this.onNext,
  });

  static const _months = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GenaiIconButton(
          icon: LucideIcons.chevronLeft,
          semanticLabel: 'Mese precedente',
          size: GenaiSize.sm,
          onPressed: onPrev,
        ),
        Text(
          '${_months[visibleMonth.month - 1]} ${visibleMonth.year}',
          style: ty.headingSm.copyWith(color: colors.textPrimary),
        ),
        GenaiIconButton(
          icon: LucideIcons.chevronRight,
          semanticLabel: 'Mese successivo',
          size: GenaiSize.sm,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime visibleMonth;
  final bool Function(DateTime) isSelected;
  final bool Function(DateTime) isInRange;
  final bool Function(DateTime) isEnabled;
  final ValueChanged<DateTime> onTap;

  const _MonthGrid({
    required this.visibleMonth,
    required this.isSelected,
    required this.isInRange,
    required this.isEnabled,
    required this.onTap,
  });

  static const _weekdays = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final lastOfMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final firstWeekday = (firstOfMonth.weekday + 6) % 7; // Mon=0
    final daysInMonth = lastOfMonth.day;
    final cells = <Widget>[];

    for (final w in _weekdays) {
      cells.add(Center(
        child: Text(w, style: ty.caption.copyWith(color: colors.textSecondary)),
      ));
    }
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(visibleMonth.year, visibleMonth.month, d);
      final selected = isSelected(date);
      final inRange = isInRange(date);
      final enabled = isEnabled(date);
      cells.add(GestureDetector(
        onTap: enabled ? () => onTap(date) : null,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected ? colors.colorPrimary : (inRange ? colors.colorPrimarySubtle : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$d',
            style: ty.bodySm.copyWith(
              color: !enabled ? colors.textDisabled : (selected ? colors.textOnPrimary : colors.textPrimary),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }
}

bool _sameDay(DateTime a, DateTime? b) => b != null && a.year == b.year && a.month == b.month && a.day == b.day;

bool _isInBounds(DateTime d, DateTime? min, DateTime? max) {
  if (min != null && d.isBefore(DateTime(min.year, min.month, min.day))) {
    return false;
  }
  if (max != null && d.isAfter(DateTime(max.year, max.month, max.day))) {
    return false;
  }
  return true;
}
