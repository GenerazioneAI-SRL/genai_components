import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Event shown on a [GenaiCalendar]. `data` is opaque user state returned
/// verbatim to `onEventTap`.
class GenaiCalendarEvent {
  /// Event start.
  final DateTime start;

  /// Event end.
  final DateTime end;

  /// Title text rendered inside the chip.
  final String title;

  /// Optional chip color. Falls back to `colorInfo` in v3.
  final Color? color;

  /// User-supplied payload returned via `onEventTap`.
  final Object? data;

  const GenaiCalendarEvent({
    required this.start,
    required this.end,
    required this.title,
    this.color,
    this.data,
  });
}

/// Granularity shown by a [GenaiCalendar].
enum GenaiCalendarView {
  /// Full month grid.
  month,

  /// Single week.
  week,

  /// Single day.
  day,

  /// Upcoming events list.
  agenda,
}

/// Lightweight calendar — v3 design system.
///
/// Month / week / day / agenda views with event chips per day. Suitable for
/// a dashboard sidebar / widget; production scheduling UIs should embed a
/// dedicated library.
class GenaiCalendar extends StatefulWidget {
  /// Initial view.
  final GenaiCalendarView view;

  /// Anchor date. Defaults to `DateTime.now()`.
  final DateTime? initialDate;

  /// Events to render. Multi-day events still anchor to `start`.
  final List<GenaiCalendarEvent> events;

  /// Tap on a day cell.
  final ValueChanged<DateTime>? onDayTap;

  /// Tap on an event chip.
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

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<GenaiCalendarEvent> _eventsFor(DateTime day) =>
      widget.events.where((e) => _sameDay(e.start, day)).toList();

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
    final spacing = context.spacing;
    return Semantics(
      container: true,
      label: 'Calendario',
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          SizedBox(height: spacing.s12),
          Expanded(
            child: switch (_view) {
              GenaiCalendarView.month => _buildMonth(context),
              GenaiCalendarView.week => _buildWeek(context),
              GenaiCalendarView.day => _buildDay(context, _current),
              GenaiCalendarView.agenda => _buildAgenda(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    Widget navBtn(IconData icon, VoidCallback onTap, String label) {
      return Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius.md),
          child: Container(
            width: sizing.minTouchTarget,
            height: sizing.minTouchTarget,
            alignment: Alignment.center,
            child: Icon(icon, size: sizing.iconSize, color: colors.textPrimary),
          ),
        ),
      );
    }

    return Row(
      children: [
        navBtn(LucideIcons.chevronLeft, () => _shift(-1), 'Precedente'),
        navBtn(LucideIcons.chevronRight, () => _shift(1), 'Successivo'),
        SizedBox(width: spacing.s12),
        Text(
          _titleFor(),
          style: ty.sectionTitle.copyWith(color: colors.textPrimary),
        ),
        const Spacer(),
        for (final v in GenaiCalendarView.values)
          Padding(
            padding: EdgeInsets.only(left: spacing.s4),
            child: _viewChip(context, v),
          ),
      ],
    );
  }

  Widget _viewChip(BuildContext context, GenaiCalendarView v) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final selected = v == _view;
    return Semantics(
      button: true,
      selected: selected,
      label: _viewLabel(v),
      child: InkWell(
        onTap: () => setState(() => _view = v),
        borderRadius: BorderRadius.circular(radius.md),
        child: AnimatedContainer(
          duration: context.motion.hover.duration,
          curve: context.motion.hover.curve,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s6,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.colorPrimary : colors.surfaceCard,
            borderRadius: BorderRadius.circular(radius.md),
            border: Border.all(
              color: selected ? colors.colorPrimary : colors.borderDefault,
            ),
          ),
          child: Text(
            _viewLabel(v),
            style: ty.labelSm.copyWith(
              color: selected ? colors.textOnPrimary : colors.textPrimary,
            ),
          ),
        ),
      ),
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
    final spacing = context.spacing;
    final firstOfMonth = DateTime(_current.year, _current.month, 1);
    final daysInMonth = DateTime(_current.year, _current.month + 1, 0).day;
    final firstWeekday = (firstOfMonth.weekday + 6) % 7;

    final cells = <Widget>[
      for (final w in _weekdays)
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.s4),
            child: Text(
              w.toUpperCase(),
              style: ty.tiny.copyWith(color: colors.textTertiary),
            ),
          ),
        ),
      for (var i = 0; i < firstWeekday; i++) const SizedBox.shrink(),
      for (var d = 1; d <= daysInMonth; d++)
        _buildCell(context, DateTime(_current.year, _current.month, d)),
    ];

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      mainAxisSpacing: spacing.s4,
      crossAxisSpacing: spacing.s4,
      physics: const ClampingScrollPhysics(),
      children: cells,
    );
  }

  Widget _buildWeek(BuildContext context) {
    final spacing = context.spacing;
    final monday = _current.subtract(Duration(days: _current.weekday - 1));
    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.6,
      mainAxisSpacing: spacing.s4,
      crossAxisSpacing: spacing.s4,
      physics: const ClampingScrollPhysics(),
      children: [
        for (var i = 0; i < 7; i++)
          _buildCell(context, monday.add(Duration(days: i))),
      ],
    );
  }

  Widget _buildCell(BuildContext context, DateTime day) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final events = _eventsFor(day);
    final isToday = _sameDay(day, DateTime.now());
    final accent = colors.colorInfo;
    return Semantics(
      button: true,
      selected: isToday,
      label:
          '${day.day}/${day.month}/${day.year}${events.isEmpty ? '' : ' - ${events.length} eventi'}',
      child: GestureDetector(
        onTap: () => widget.onDayTap?.call(day),
        child: Container(
          padding: EdgeInsets.all(spacing.s4),
          decoration: BoxDecoration(
            color: isToday ? colors.colorInfoSubtle : colors.surfaceCard,
            borderRadius: BorderRadius.circular(radius.md),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${day.day}',
                style: ty.labelSm.copyWith(
                  color: colors.textPrimary,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              SizedBox(height: spacing.s2),
              for (final e in events.take(2))
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.s2),
                  child: GestureDetector(
                    onTap: () => widget.onEventTap?.call(e),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.s4,
                        vertical: spacing.s2,
                      ),
                      decoration: BoxDecoration(
                        color: (e.color ?? accent).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(radius.xs),
                      ),
                      child: Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ty.labelSm.copyWith(
                          color: e.color ?? accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              if (events.length > 2)
                Text(
                  '+${events.length - 2}',
                  style: ty.labelSm.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDay(BuildContext context, DateTime day) {
    final ty = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;
    final events = _eventsFor(day);
    if (events.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Center(
          child: Text(
            'Nessun evento',
            style: ty.bodySm.copyWith(color: colors.textSecondary),
          ),
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
    final spacing = context.spacing;
    final futureEvents = widget.events
        .where((e) => !e.start.isBefore(_current))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    if (futureEvents.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Center(
          child: Text(
            'Nessun evento futuro',
            style: ty.bodySm.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }
    return ListView(
      children: [
        for (final e in futureEvents.take(20))
          _AgendaRow(event: e, onTap: widget.onEventTap),
      ],
    );
  }
}

class _AgendaRow extends StatelessWidget {
  final GenaiCalendarEvent event;
  final ValueChanged<GenaiCalendarEvent>? onTap;

  const _AgendaRow({required this.event, this.onTap});

  String _f(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Semantics(
      button: onTap != null,
      label: '${event.title} ${_f(event.start)} – ${_f(event.end)}',
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(event),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.s8,
            horizontal: spacing.s4,
          ),
          child: Row(
            children: [
              Container(
                width: spacing.s4,
                height: spacing.s32,
                decoration: BoxDecoration(
                  color: event.color ?? colors.colorInfo,
                  borderRadius: BorderRadius.circular(radius.xs),
                ),
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: ty.bodySm.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_f(event.start)} – ${_f(event.end)}',
                      style: ty.monoSm.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
