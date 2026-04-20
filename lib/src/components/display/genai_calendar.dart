import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../actions/genai_icon_button.dart';
import '../../tokens/sizing.dart';

class GenaiCalendarEvent {
  final DateTime start;
  final DateTime end;
  final String title;
  final Color? color;
  final Object? data;

  const GenaiCalendarEvent({
    required this.start,
    required this.end,
    required this.title,
    this.color,
    this.data,
  });
}

enum GenaiCalendarView { month, week, day, agenda }

/// Calendar (§6.7.6).
///
/// Lightweight month/week/day view — shows event chips per day. For complex
/// scheduling needs the host app should embed a more specialised solution.
class GenaiCalendar extends StatefulWidget {
  final GenaiCalendarView view;
  final DateTime? initialDate;
  final List<GenaiCalendarEvent> events;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<GenaiCalendarEvent>? onEventTap;

  const GenaiCalendar({
    super.key,
    this.view = GenaiCalendarView.month,
    this.initialDate,
    this.events = const [],
    this.onDayTap,
    this.onEventTap,
  });

  @override
  State<GenaiCalendar> createState() => _GenaiCalendarState();
}

class _GenaiCalendarState extends State<GenaiCalendar> {
  late DateTime _current;
  late GenaiCalendarView _view;

  static const _weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
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
  void initState() {
    super.initState();
    _current = widget.initialDate ?? DateTime.now();
    _view = widget.view;
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<GenaiCalendarEvent> _eventsFor(DateTime day) => widget.events.where((e) => _sameDay(e.start, day)).toList();

  void _shift(int delta) {
    setState(() {
      switch (_view) {
        case GenaiCalendarView.month:
          _current = DateTime(_current.year, _current.month + delta);
          break;
        case GenaiCalendarView.week:
          _current = _current.add(Duration(days: 7 * delta));
          break;
        case GenaiCalendarView.day:
        case GenaiCalendarView.agenda:
          _current = _current.add(Duration(days: delta));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        Expanded(
          child: switch (_view) {
            GenaiCalendarView.month => _buildMonth(context),
            GenaiCalendarView.week => _buildWeek(context),
            GenaiCalendarView.day => _buildDay(context, _current),
            GenaiCalendarView.agenda => _buildAgenda(context),
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Row(
      children: [
        GenaiIconButton(
          icon: LucideIcons.chevronLeft,
          semanticLabel: 'Precedente',
          size: GenaiSize.sm,
          onPressed: () => _shift(-1),
        ),
        const SizedBox(width: 4),
        GenaiIconButton(
          icon: LucideIcons.chevronRight,
          semanticLabel: 'Successivo',
          size: GenaiSize.sm,
          onPressed: () => _shift(1),
        ),
        const SizedBox(width: 12),
        Text(_titleFor(), style: ty.headingSm.copyWith(color: colors.textPrimary)),
        const Spacer(),
        for (final v in GenaiCalendarView.values) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ChoiceChip(
              label: Text(_viewLabel(v), style: ty.label.copyWith(color: v == _view ? colors.textOnPrimary : colors.textPrimary)),
              selected: v == _view,
              selectedColor: colors.colorPrimary,
              backgroundColor: colors.surfaceCard,
              side: BorderSide(color: colors.borderDefault),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onSelected: (_) => setState(() => _view = v),
            ),
          ),
        ],
      ],
    );
  }

  String _viewLabel(GenaiCalendarView v) => switch (v) {
        GenaiCalendarView.month => 'Mese',
        GenaiCalendarView.week => 'Sett.',
        GenaiCalendarView.day => 'Giorno',
        GenaiCalendarView.agenda => 'Agenda',
      };

  String _titleFor() {
    switch (_view) {
      case GenaiCalendarView.month:
        return '${_months[_current.month - 1]} ${_current.year}';
      case GenaiCalendarView.week:
        final monday = _current.subtract(Duration(days: _current.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return '${monday.day} ${_months[monday.month - 1]} – ${sunday.day} ${_months[sunday.month - 1]} ${sunday.year}';
      case GenaiCalendarView.day:
      case GenaiCalendarView.agenda:
        return '${_current.day} ${_months[_current.month - 1]} ${_current.year}';
    }
  }

  Widget _buildMonth(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final firstOfMonth = DateTime(_current.year, _current.month, 1);
    final daysInMonth = DateTime(_current.year, _current.month + 1, 0).day;
    final firstWeekday = (firstOfMonth.weekday + 6) % 7;

    final cells = <Widget>[
      for (final w in _weekdays)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(w, style: ty.caption.copyWith(color: colors.textSecondary)),
          ),
        ),
      for (var i = 0; i < firstWeekday; i++) const SizedBox.shrink(),
      for (var d = 1; d <= daysInMonth; d++) _buildCell(context, DateTime(_current.year, _current.month, d)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 300.0;
        // 7 weekday labels + up to 6 week rows.
        final rowCount = ((cells.length + 6) ~/ 7).clamp(6, 7);
        final cellHeight = ((h - ((rowCount - 1) * 4)) / rowCount).clamp(32.0, 72.0);
        final cellWidth = ((constraints.maxWidth.isFinite ? constraints.maxWidth : 700.0) - (6 * 4)) / 7;
        final ratio = (cellWidth / cellHeight).clamp(0.8, 2.8);

        return GridView.count(
          crossAxisCount: 7,
          childAspectRatio: ratio,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          physics: const ClampingScrollPhysics(),
          children: cells,
        );
      },
    );
  }

  Widget _buildWeek(BuildContext context) {
    final monday = _current.subtract(Duration(days: _current.weekday - 1));
    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.6,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const ClampingScrollPhysics(),
      children: [
        for (var i = 0; i < 7; i++) _buildCell(context, monday.add(Duration(days: i))),
      ],
    );
  }

  Widget _buildCell(BuildContext context, DateTime day) {
    final colors = context.colors;
    final ty = context.typography;
    final events = _eventsFor(day);
    final isToday = _sameDay(day, DateTime.now());
    return GestureDetector(
      onTap: () => widget.onDayTap?.call(day),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isToday ? colors.colorPrimarySubtle : colors.surfaceCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.day}', style: ty.caption.copyWith(color: colors.textPrimary, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500)),
            const SizedBox(height: 4),
            for (final e in events.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: GestureDetector(
                  onTap: () => widget.onEventTap?.call(e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: (e.color ?? colors.colorPrimary).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ty.caption.copyWith(color: e.color ?? colors.colorPrimary, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            if (events.length > 2) Text('+${events.length - 2}', style: ty.caption.copyWith(color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(BuildContext context, DateTime day) {
    final ty = context.typography;
    final colors = context.colors;
    final events = _eventsFor(day);
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Nessun evento', style: ty.bodySm.copyWith(color: colors.textSecondary)),
        ),
      );
    }
    return ListView(
      children: [
        for (final e in events) _AgendaRow(event: e, onTap: widget.onEventTap),
      ],
    );
  }

  Widget _buildAgenda(BuildContext context) {
    final ty = context.typography;
    final colors = context.colors;
    final futureEvents = widget.events.where((e) => !e.start.isBefore(_current)).toList()..sort((a, b) => a.start.compareTo(b.start));
    if (futureEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Nessun evento futuro', style: ty.bodySm.copyWith(color: colors.textSecondary)),
        ),
      );
    }
    return ListView(
      children: [
        for (final e in futureEvents.take(20)) _AgendaRow(event: e, onTap: widget.onEventTap),
      ],
    );
  }
}

class _AgendaRow extends StatelessWidget {
  final GenaiCalendarEvent event;
  final ValueChanged<GenaiCalendarEvent>? onTap;
  const _AgendaRow({required this.event, this.onTap});

  String _f(DateTime t) => '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: event.color ?? colors.colorPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(event.title, style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                  Text('${_f(event.start)} – ${_f(event.end)}', style: ty.caption.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
