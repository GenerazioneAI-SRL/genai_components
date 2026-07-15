import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../primitives/gen_overlays.dart';
import '../shell/gen_shell_slots.dart';
import '../theme/gen_sizes.dart';
import '../theme/gen_tokens.dart';

/// Le quattro viste del [GenEventCalendar]. `agenda` è una lista raggruppata per
/// giorno; `month` è la classica griglia 7×6; `week`/`day` sono time-grid con
/// blocchi posizionati sulle ore.
enum GenCalendarView {
  month('Month'),
  week('Week'),
  day('Day'),
  agenda('Agenda');

  const GenCalendarView(this.label);

  final String label;
}

/// Un evento del calendario. Immutabile: le modifiche passano da [copyWith].
/// [start]/[end] sono istanti locali; per gli eventi [allDay] l'orario è
/// ignorato e conta solo la data.
@immutable
class GenCalendarEvent {
  const GenCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.location,
    this.allDay = false,
    this.color = GenEventCalendar.defaultPalette,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final String? location;
  final Color color;

  /// Durata dell'evento (min 0). Per gli all-day non è significativa.
  Duration get duration => end.isAfter(start) ? end.difference(start) : Duration.zero;

  /// L'evento tocca il giorno [day] (confronto per data, ignora l'ora)?
  bool coversDay(DateTime day) {
    final d0 = DateUtils.dateOnly(day);
    final s = DateUtils.dateOnly(start);
    final e = DateUtils.dateOnly(end);
    return !d0.isBefore(s) && !d0.isAfter(e);
  }

  /// Occupa più di un giorno di calendario?
  bool get isMultiDay => !DateUtils.isSameDay(start, end);

  GenCalendarEvent copyWith({
    String? id,
    String? title,
    Object? description = _sentinel,
    DateTime? start,
    DateTime? end,
    bool? allDay,
    Object? location = _sentinel,
    Color? color,
  }) {
    return GenCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description == _sentinel ? this.description : description as String?,
      start: start ?? this.start,
      end: end ?? this.end,
      allDay: allDay ?? this.allDay,
      location: location == _sentinel ? this.location : location as String?,
      color: color ?? this.color,
    );
  }

  static const Object _sentinel = Object();
}

/// Calendario eventi con quattro viste (Month / Week / Day / Agenda) e dialog di
/// editing integrata. Custom Gen: shadcn_ui non fornisce un event-calendar,
/// quindi è composto dalle primitive (bottoni, select, date/time picker, dialog)
/// e stilizzato interamente da [GenTokens].
///
/// Il widget possiede una copia mutabile della lista eventi: la dialog integrata
/// crea/aggiorna/elimina e la UI si aggiorna subito, notificando il chiamante via
/// [onEventCreated] / [onEventUpdated] / [onEventDeleted].
class GenEventCalendar extends StatefulWidget {
  const GenEventCalendar({
    super.key,
    this.events = const [],
    this.initialDate,
    this.initialView = GenCalendarView.month,
    this.palette = defaultColors,
    this.weekStartsOn = DateTime.sunday,
    this.onEventCreated,
    this.onEventUpdated,
    this.onEventDeleted,
  });

  final List<GenCalendarEvent> events;
  final DateTime? initialDate;
  final GenCalendarView initialView;

  /// Colori proposti nel color-picker ("Etiquette") della dialog.
  final List<Color> palette;

  /// Primo giorno della settimana (1 = lunedì … 7 = domenica). Default domenica.
  final int weekStartsOn;

  final ValueChanged<GenCalendarEvent>? onEventCreated;
  final ValueChanged<GenCalendarEvent>? onEventUpdated;
  final ValueChanged<GenCalendarEvent>? onEventDeleted;

  /// Colore evento di default (blu). Costante per poter essere default di const.
  static const Color defaultPalette = Color(0xFF3B82F6);

  static const List<Color> defaultColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFFF59E0B), // amber
    Color(0xFF8B5CF6), // violet
    Color(0xFFF43F5E), // rose
    Color(0xFF22C55E), // green
    Color(0xFFF97316), // orange
  ];

  @override
  State<GenEventCalendar> createState() => _GenEventCalendarState();
}

class _GenEventCalendarState extends State<GenEventCalendar> {
  late List<GenCalendarEvent> _events;
  late DateTime _focused;
  late GenCalendarView _view;

  @override
  void initState() {
    super.initState();
    _events = List.of(widget.events);
    _focused = DateUtils.dateOnly(widget.initialDate ?? DateTime.now());
    _view = widget.initialView;
  }

  @override
  void didUpdateWidget(covariant GenEventCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-seed solo se il chiamante passa una lista diversa (identità).
    if (!identical(oldWidget.events, widget.events)) {
      _events = List.of(widget.events);
    }
  }

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  // ── Navigazione ──────────────────────────────────────────────────────────
  void _goToday() => setState(() => _focused = _today);

  void _shift(int dir) {
    setState(() {
      switch (_view) {
        case GenCalendarView.month:
          _focused = DateTime(_focused.year, _focused.month + dir, 1);
        case GenCalendarView.week:
          _focused = _focused.add(Duration(days: 7 * dir));
        case GenCalendarView.day:
          _focused = _focused.add(Duration(days: dir));
        case GenCalendarView.agenda:
          _focused = _focused.add(Duration(days: _agendaWindowDays * dir));
      }
    });
  }

  static const int _agendaWindowDays = 30;

  // ── CRUD via dialog integrata ────────────────────────────────────────────
  Future<void> _openEditor({GenCalendarEvent? event, DateTime? seedStart}) async {
    final now = seedStart ?? _focused.add(const Duration(hours: 9));
    final seed = DateTime(now.year, now.month, now.day, now.hour == 0 ? 9 : now.hour);
    // Mobile → bottom sheet (più a portata di pollice); desktop → dialog centrato.
    // Il Future è creato sincrono (usa `context` prima dell'await), poi atteso.
    final compact = MediaQuery.sizeOf(context).width < _kCalendarCompactBreakpoint;
    final future = compact
        ? showGenSheet<_EditorResult>(
            context: context,
            side: ShadSheetSide.bottom,
            useRootNavigator: true,
            builder: (_) => _EventEditDialog(
              event: event,
              palette: widget.palette,
              seedStart: seed,
              asSheet: true,
            ),
          )
        : showGenDialog<_EditorResult>(
            context: context,
            builder: (_) => _EventEditDialog(
              event: event,
              palette: widget.palette,
              seedStart: seed,
              asSheet: false,
            ),
          );
    final result = await future;
    if (result == null) return;
    setState(() {
      switch (result.action) {
        case _EditorAction.save:
          final e = result.event!;
          final i = _events.indexWhere((x) => x.id == e.id);
          if (i >= 0) {
            _events[i] = e;
            widget.onEventUpdated?.call(e);
          } else {
            _events.add(e);
            widget.onEventCreated?.call(e);
          }
        case _EditorAction.delete:
          final e = result.event!;
          _events.removeWhere((x) => x.id == e.id);
          widget.onEventDeleted?.call(e);
      }
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar: inline su desktop/standalone; su mobile (compact) con uno
        // shell antenato pubblica nav/vista/New event nell'area contestuale
        // sopra la GenBottomBar (niente overflow orizzontale). La gap sotto è
        // resa dall'host solo quando la toolbar è inline.
        _ShellToolbarHost(
          title: _title(),
          view: _view,
          onToday: _goToday,
          onPrev: () => _shift(-1),
          onNext: () => _shift(1),
          onViewChanged: (v) => setState(() => _view = v),
          onNewEvent: () => _openEditor(),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.secondaryBackground,
              border: Border.all(color: t.borderColor),
              borderRadius: BorderRadius.circular(GenSizes.radiusCard),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GenSizes.radiusCard),
              child: _buildBody(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_view) {
      case GenCalendarView.month:
        return _MonthView(
          focused: _focused,
          today: _today,
          events: _events,
          weekStartsOn: widget.weekStartsOn,
          onDayTap: (d) => _openEditor(seedStart: d),
          onEventTap: (e) => _openEditor(event: e),
        );
      case GenCalendarView.week:
        return _TimeGridView(
          days: _weekDays(),
          today: _today,
          events: _events,
          onSlotTap: (d) => _openEditor(seedStart: d),
          onEventTap: (e) => _openEditor(event: e),
        );
      case GenCalendarView.day:
        return _TimeGridView(
          days: [_focused],
          today: _today,
          events: _events,
          onSlotTap: (d) => _openEditor(seedStart: d),
          onEventTap: (e) => _openEditor(event: e),
        );
      case GenCalendarView.agenda:
        return _AgendaView(
          start: _focused,
          days: _agendaWindowDays,
          today: _today,
          events: _events,
          onEventTap: (e) => _openEditor(event: e),
        );
    }
  }

  List<DateTime> _weekDays() {
    final start = _startOfWeek(_focused, widget.weekStartsOn);
    return [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];
  }

  String _title() {
    switch (_view) {
      case GenCalendarView.month:
      case GenCalendarView.week:
        return '${_monthNames[_focused.month - 1]} ${_focused.year}';
      case GenCalendarView.day:
        return '${_weekdayShort[_focused.weekday % 7]} '
            '${_monthNames[_focused.month - 1]} ${_focused.day}, ${_focused.year}';
      case GenCalendarView.agenda:
        final end = _focused.add(const Duration(days: _agendaWindowDays - 1));
        final left = _monthShort[_focused.month - 1];
        final right = _monthShort[end.month - 1];
        return _focused.year == end.year
            ? '$left – $right ${end.year}'
            : '$left ${_focused.year} – $right ${end.year}';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Toolbar
// ═══════════════════════════════════════════════════════════════════════════

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.title,
    required this.view,
    required this.onToday,
    required this.onPrev,
    required this.onNext,
    required this.onViewChanged,
    required this.onNewEvent,
  });

  final String title;
  final GenCalendarView view;
  final VoidCallback onToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<GenCalendarView> onViewChanged;
  final VoidCallback onNewEvent;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    // Sotto ~600px (mobile) i controlli a larghezza fissa non entrano tutti:
    // il bottone "New event" diventa icona-only e il select si stringe, come
    // nella versione mobile di riferimento.
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 600;
        return Row(
          children: [
            ShadButton.outline(onPressed: onToday, child: const Text('Today')),
            const SizedBox(width: GenSizes.gapSm),
            ShadIconButton.ghost(icon: const Icon(LucideIcons.chevronLeft, size: 18), onPressed: onPrev),
            ShadIconButton.ghost(icon: const Icon(LucideIcons.chevronRight, size: 18), onPressed: onNext),
            const SizedBox(width: GenSizes.gapMd),
            Expanded(
              child: Text(title, style: t.heading4.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: GenSizes.gapSm),
            SizedBox(
              width: compact ? 104 : 130,
              child: ShadSelect<GenCalendarView>(
                initialValue: view,
                onChanged: (v) {
                  if (v != null) onViewChanged(v);
                },
                options: [
                  for (final v in GenCalendarView.values) ShadOption(value: v, child: Text(v.label)),
                ],
                selectedOptionBuilder: (context, value) => Text(value.label),
              ),
            ),
            const SizedBox(width: GenSizes.gapSm),
            if (compact)
              ShadIconButton(onPressed: onNewEvent, icon: const Icon(LucideIcons.plus, size: 16))
            else
              ShadButton(
                onPressed: onNewEvent,
                leading: const Icon(LucideIcons.plus, size: 16),
                child: const Text('New event'),
              ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shell toolbar host — hoisting dei controlli su mobile
// ═══════════════════════════════════════════════════════════════════════════

/// Larghezza sotto la quale lo shell mostra la bottom bar (allineata a
/// [GenShellConfig.tabletBreakpoint] e al breakpoint della datatable).
const double _kCalendarCompactBreakpoint = 600.0;

/// Colloca la toolbar del calendario nel posto giusto per breakpoint, sul
/// modello di `_FilterBarShellHost` della datatable:
/// - **desktop / standalone** (nessuno shell antenato o larghezza ≥ breakpoint):
///   rende la toolbar inline (con la gap sotto), comportamento invariato.
/// - **mobile + [GenShellScope]**: pubblica nav (stepper custom), selettore
///   vista (reveal) e "New event" (pageAction primaria) nell'area contestuale
///   sopra la bottom bar, e collassa (niente toolbar in-page → niente overflow).
///
/// Opt-in e non invasivo: senza shell il componente resta riusabile ovunque.
class _ShellToolbarHost extends StatefulWidget {
  const _ShellToolbarHost({
    required this.title,
    required this.view,
    required this.onToday,
    required this.onPrev,
    required this.onNext,
    required this.onViewChanged,
    required this.onNewEvent,
  });

  final String title;
  final GenCalendarView view;
  final VoidCallback onToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<GenCalendarView> onViewChanged;
  final VoidCallback onNewEvent;

  @override
  State<_ShellToolbarHost> createState() => _ShellToolbarHostState();
}

class _ShellToolbarHostState extends State<_ShellToolbarHost> {
  ShellSlotsController? _shell;
  bool _published = false;
  // Ultime liste pubblicate: pulizia con guard per identità, così non si
  // clobberano i controlli/azioni che un'altra pagina potrebbe aver ripubblicato.
  List<ShellContextControl>? _lastControls;
  List<ShellAction>? _lastActions;
  // Rotta che ospita il calendario: pubblica SOLO quando è quella corrente,
  // de-pubblica quando una figlia (es. dettaglio) la copre.
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shell = GenShellScope.maybeOf(context);
    final route = ModalRoute.of(context);
    if (route != _route) {
      _route?.secondaryAnimation?.removeListener(_onRouteChanged);
      _route = route;
      _route?.secondaryAnimation?.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _route?.secondaryAnimation?.removeListener(_onRouteChanged);
    _clearPublished();
    super.dispose();
  }

  /// Azzera controlli e azioni pubblicati, differito a post-frame (dispose/route
  /// change avvengono ad albero LOCKED → niente notify sincrono) e con guard per
  /// identità così non si clobbera chi ha già ripubblicato.
  void _clearPublished() {
    if (!_published) return;
    _published = false;
    final shell = _shell;
    if (shell == null) return;
    final controls = _lastControls;
    final actions = _lastActions;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(shell.slots.contextControls, controls)) {
        shell.setContextControls(const []);
      }
      if (identical(shell.slots.pageActions, actions)) {
        shell.setPageActions(const []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = _shell;
    final compact = MediaQuery.sizeOf(context).width < _kCalendarCompactBreakpoint;
    final isCurrent = _route?.isCurrent ?? true;

    // Nessuno shell o non-compact → toolbar inline (+ gap). Pulisci se prima
    // avevamo pubblicato (es. resize da mobile a desktop).
    if (shell == null || !compact) {
      _clearPublished();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Toolbar(
            title: widget.title,
            view: widget.view,
            onToday: widget.onToday,
            onPrev: widget.onPrev,
            onNext: widget.onNext,
            onViewChanged: widget.onViewChanged,
            onNewEvent: widget.onNewEvent,
          ),
          const SizedBox(height: GenSizes.gapLg),
        ],
      );
    }

    // Compact ma rotta coperta da una figlia → de-pubblica e collassa (l'area
    // shell è comunque hoisted altrove).
    if (!isCurrent) {
      _clearPublished();
      return const SizedBox.shrink();
    }

    // Mobile + shell + rotta corrente → pubblica gli slot e collassa la toolbar.
    final controls = <ShellContextControl>[
      // Nav: stepper Today/‹ ›/titolo. Custom (non standard) → wrap in Expanded
      // così riempie la riga e il titolo tronca invece di sfondare.
      ShellContextControl.custom(ShellCustom(
        (ctx) => Expanded(
          child: _NavStepper(
            title: widget.title,
            onToday: widget.onToday,
            onPrev: widget.onPrev,
            onNext: widget.onNext,
          ),
        ),
        id: 'calendar-nav',
      )),
      // Vista: reveal inline (Month/Week/Day/Agenda).
      ShellContextControl.reveal(ShellRevealControl(
        id: 'calendar-view',
        icon: LucideIcons.calendarRange,
        title: 'Vista',
        tooltip: 'Vista',
        panelBuilder: (ctx, close) => _ViewPanel(
          current: widget.view,
          onSelect: (v) {
            widget.onViewChanged(v);
            close();
          },
        ),
      )),
    ];
    // New event: azione primaria → riga bassa dell'area contestuale, full-width,
    // accanto al back (se presente). `mobileOnly` così NON finisce nell'header
    // desktop/rail (dove il calendario ha già il proprio bottone in toolbar) →
    // niente doppione né overflow, nemmeno durante il resize.
    final actions = <ShellAction>[
      ShellAction(
        icon: LucideIcons.plus,
        label: 'New event',
        onTap: widget.onNewEvent,
        isPrimary: true,
        mobileOnly: true,
      ),
    ];

    _lastControls = controls;
    _lastActions = actions;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      shell.setContextControls(controls);
      shell.setPageActions(actions);
    });
    _published = true;
    return const SizedBox.shrink();
  }
}

/// Stepper di navigazione del calendario (Today · ‹ › · titolo), riusato come
/// controllo custom nell'area contestuale mobile. Il titolo è [Expanded] così
/// tronca con ellipsis quando lo spazio è poco.
class _NavStepper extends StatelessWidget {
  const _NavStepper({
    required this.title,
    required this.onToday,
    required this.onPrev,
    required this.onNext,
  });

  final String title;
  final VoidCallback onToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShadButton.outline(onPressed: onToday, child: const Text('Today')),
        const SizedBox(width: GenSizes.gapSm),
        // Segmented con il mese in mezzo alle frecce: [ ‹ | July 2026 | › ].
        Expanded(child: _NavSegmented(title: title, onPrev: onPrev, onNext: onNext)),
      ],
    );
  }
}

/// Controllo segmentato di navigazione: `[ ‹ | mese | › ]`. Stessi token visivi
/// di [GenSegmented] (bordo, [CLSizes.radiusControl], divisori hairline) ma con
/// frecce a larghezza fissa e mese [Expanded] al centro — layout che il
/// [GenSegmented] (segmenti equidimensionati + fill di selezione) non copre. Le
/// frecce sono azioni momentanee: nessun fill persistente.
class _NavSegmented extends StatelessWidget {
  const _NavSegmented({
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  // Allineata all'altezza di ShadButton default (Today) accanto.
  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final divider = SizedBox(width: 1, height: height - 2, child: ColoredBox(color: t.borderColor));

    Widget arrow(IconData icon, VoidCallback onTap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: height,
            child: Center(child: Icon(icon, size: 18, color: t.primaryText)),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: t.borderColor),
        borderRadius: BorderRadius.circular(t.radiusControl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          arrow(LucideIcons.chevronLeft, onPrev),
          divider,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GenSizes.gapSm),
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: t.bodyText,
              ),
            ),
          ),
          divider,
          arrow(LucideIcons.chevronRight, onNext),
        ],
      ),
    );
  }
}

/// Pannello reveal del selettore vista: una riga per vista, con check sulla
/// selezione corrente. Il tap applica la vista e chiude (via `onSelect`).
class _ViewPanel extends StatelessWidget {
  const _ViewPanel({required this.current, required this.onSelect});

  final GenCalendarView current;
  final ValueChanged<GenCalendarView> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final v in GenCalendarView.values)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(v),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: GenSizes.gapMd, horizontal: GenSizes.gapSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      v.label,
                      style: t.bodyText.copyWith(
                        fontWeight: v == current ? FontWeight.w600 : FontWeight.w400,
                        color: v == current ? t.primary : t.primaryText,
                      ),
                    ),
                  ),
                  if (v == current) Icon(LucideIcons.check, size: 16, color: t.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Month view
// ═══════════════════════════════════════════════════════════════════════════

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.focused,
    required this.today,
    required this.events,
    required this.weekStartsOn,
    required this.onDayTap,
    required this.onEventTap,
  });

  final DateTime focused;
  final DateTime today;
  final List<GenCalendarEvent> events;
  final int weekStartsOn;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<GenCalendarEvent> onEventTap;

  static const int _maxChips = 3;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final first = DateTime(focused.year, focused.month, 1);
    final gridStart = _startOfWeek(first, weekStartsOn);
    // 6 settimane fisse per un'altezza costante durante la navigazione.
    final weeks = [
      for (var w = 0; w < 6; w++)
        [for (var d = 0; d < 7; d++) gridStart.add(Duration(days: w * 7 + d))],
    ];

    return Column(
      children: [
        // Header giorni della settimana.
        Row(
          children: [
            for (final day in weeks.first)
              Expanded(
                child: Container(
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: t.borderColor)),
                  ),
                  child: Text(_weekdayShort[day.weekday % 7], style: t.smallLabel),
                ),
              ),
          ],
        ),
        for (var w = 0; w < weeks.length; w++)
          Expanded(
            child: Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: _MonthCell(
                      day: weeks[w][d],
                      inMonth: weeks[w][d].month == focused.month,
                      isToday: DateUtils.isSameDay(weeks[w][d], today),
                      lastCol: d == 6,
                      lastRow: w == weeks.length - 1,
                      events: _eventsForDay(weeks[w][d]),
                      onDayTap: onDayTap,
                      onEventTap: onEventTap,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<GenCalendarEvent> _eventsForDay(DateTime day) {
    final list = events.where((e) => e.coversDay(day)).toList()
      ..sort((a, b) {
        if (a.allDay != b.allDay) return a.allDay ? -1 : 1;
        return a.start.compareTo(b.start);
      });
    return list;
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.lastCol,
    required this.lastRow,
    required this.events,
    required this.onDayTap,
    required this.onEventTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool lastCol;
  final bool lastRow;
  final List<GenCalendarEvent> events;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<GenCalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final b = Theme.of(context).brightness;
    final visible = events.take(_MonthView._maxChips).toList();
    final overflow = events.length - visible.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onDayTap(DateTime(day.year, day.month, day.day, 9)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: lastCol ? BorderSide.none : BorderSide(color: t.borderColor),
            bottom: lastRow ? BorderSide.none : BorderSide(color: t.borderColor),
          ),
          color: inMonth ? null : t.primaryBackground.withValues(alpha: 0.4),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Numero del giorno; oggi = pallino primary.
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: isToday
                    ? Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: t.primary, shape: BoxShape.circle),
                        child: Text(
                          '${day.day}',
                          style: t.smallText.copyWith(color: t.primaryForeground, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Text(
                        '${day.day}',
                        style: t.smallText.copyWith(
                          color: inMonth ? t.primaryText : t.secondaryText.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            for (final e in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _MonthChip(event: e, day: day, brightness: b, onTap: () => onEventTap(e)),
              ),
            if (overflow > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 1),
                child: Text('+$overflow more', style: t.smallLabel.copyWith(fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({required this.event, required this.day, required this.brightness, required this.onTap});

  final GenCalendarEvent event;
  final DateTime day;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    // All-day / multi-day: barra piena colorata. Timed: pallino + ora + titolo.
    final bar = event.allDay || event.isMultiDay;
    final strong = _strong(event.color, brightness);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: bar ? _tint(event.color, brightness) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (!bar) ...[
              Container(width: 6, height: 6, decoration: BoxDecoration(color: event.color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
            ],
            Expanded(
              // Ora + titolo in un unico Text: tronca a fine riga (ellipsis) e
              // non sfonda mai la cella, per quanto stretta.
              child: Text.rich(
                TextSpan(
                  children: [
                    if (!bar)
                      TextSpan(
                        text: '${_fmtChipTime(event.start)} ',
                        style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 11),
                      ),
                    TextSpan(text: event.title),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.smallLabel.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: bar ? strong : t.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Time grid (week / day)
// ═══════════════════════════════════════════════════════════════════════════

class _TimeGridView extends StatefulWidget {
  const _TimeGridView({
    required this.days,
    required this.today,
    required this.events,
    required this.onSlotTap,
    required this.onEventTap,
  });

  final List<DateTime> days;
  final DateTime today;
  final List<GenCalendarEvent> events;
  final ValueChanged<DateTime> onSlotTap;
  final ValueChanged<GenCalendarEvent> onEventTap;

  @override
  State<_TimeGridView> createState() => _TimeGridViewState();
}

class _TimeGridViewState extends State<_TimeGridView> {
  static const double _hourHeight = 52;
  static const double _gutter = 56;

  late final ScrollController _scroll = ScrollController(initialScrollOffset: 7 * _hourHeight);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final b = Theme.of(context).brightness;
    final allDayByDay = [
      for (final d in widget.days) widget.events.where((e) => (e.allDay || e.isMultiDay) && e.coversDay(d)).toList(),
    ];
    final hasAllDay = allDayByDay.any((l) => l.isNotEmpty);

    return Column(
      children: [
        // Header con i giorni (week) o vuoto (day).
        Row(
          children: [
            SizedBox(width: _gutter, child: _tzLabel(t)),
            for (var i = 0; i < widget.days.length; i++)
              Expanded(child: _DayHeader(day: widget.days[i], today: widget.today, single: widget.days.length == 1)),
          ],
        ),
        // Riga all-day.
        if (hasAllDay)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: _gutter,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: t.borderColor))),
                  child: Text('All day', style: t.smallLabel.copyWith(fontSize: 11)),
                ),
                for (var i = 0; i < widget.days.length; i++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: t.borderColor),
                          left: BorderSide(color: t.borderColor),
                        ),
                      ),
                      child: Column(
                        children: [
                          for (final e in allDayByDay[i])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: _AllDayBar(event: e, brightness: b, onTap: () => widget.onEventTap(e)),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Corpo scrollabile con le ore.
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: SizedBox(
              height: 24 * _hourHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HourGutter(width: _gutter, hourHeight: _hourHeight),
                  for (var i = 0; i < widget.days.length; i++)
                    Expanded(
                      child: _DayColumn(
                        day: widget.days[i],
                        isToday: DateUtils.isSameDay(widget.days[i], widget.today),
                        hourHeight: _hourHeight,
                        events: widget.events
                            .where((e) => !e.allDay && !e.isMultiDay && DateUtils.isSameDay(e.start, widget.days[i]))
                            .toList(),
                        brightness: b,
                        onSlotTap: widget.onSlotTap,
                        onEventTap: widget.onEventTap,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tzLabel(GenTokens t) => Container(
        height: 44,
        alignment: Alignment.center,
        child: Text('GMT', style: t.smallLabel.copyWith(fontSize: 10)),
      );
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.today, required this.single});

  final DateTime day;
  final DateTime today;
  final bool single;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final isToday = DateUtils.isSameDay(day, today);
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(left: BorderSide(color: t.borderColor))),
      child: single
          ? const SizedBox.shrink()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_weekdayShort[day.weekday % 7]} ', style: t.smallLabel),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: isToday ? BoxDecoration(color: t.primary, shape: BoxShape.circle) : null,
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: t.smallText.copyWith(
                      color: isToday ? t.primaryForeground : t.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HourGutter extends StatelessWidget {
  const _HourGutter({required this.width, required this.hourHeight});

  final double width;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return SizedBox(
      width: width,
      child: Column(
        children: [
          for (var h = 0; h < 24; h++)
            SizedBox(
              height: hourHeight,
              child: h == 0
                  ? null
                  : Transform.translate(
                      offset: const Offset(0, -7),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(_fmtHourLabel(h), style: t.smallLabel.copyWith(fontSize: 10)),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.isToday,
    required this.hourHeight,
    required this.events,
    required this.brightness,
    required this.onSlotTap,
    required this.onEventTap,
  });

  final DateTime day;
  final bool isToday;
  final double hourHeight;
  final List<GenCalendarEvent> events;
  final Brightness brightness;
  final ValueChanged<DateTime> onSlotTap;
  final ValueChanged<GenCalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final layouts = _layoutDay(events);
    final now = DateTime.now();
    final showNow = isToday;

    return Container(
      decoration: BoxDecoration(border: Border(left: BorderSide(color: t.borderColor))),
      child: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            children: [
              // Linee orarie + hit-target per creare eventi.
              Column(
                children: [
                  for (var h = 0; h < 24; h++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSlotTap(DateTime(day.year, day.month, day.day, h)),
                      child: Container(
                        height: hourHeight,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: h == 0 ? Colors.transparent : t.borderColor)),
                        ),
                      ),
                    ),
                ],
              ),
              // Eventi.
              for (final l in layouts)
                Positioned(
                  top: _minutes(l.event.start) / 60 * hourHeight,
                  height: math.max(18, l.event.duration.inMinutes / 60 * hourHeight - 2),
                  left: (c.maxWidth - 4) * l.column / l.columnCount + 2,
                  width: (c.maxWidth - 4) / l.columnCount - 2,
                  child: _TimedEvent(event: l.event, brightness: brightness, onTap: () => onEventTap(l.event)),
                ),
              // Indicatore ora corrente.
              if (showNow)
                Positioned(
                  top: (now.hour * 60 + now.minute) / 60 * hourHeight,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: t.primary, shape: BoxShape.circle)),
                      Expanded(child: Container(height: 1.5, color: t.primary)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TimedEvent extends StatelessWidget {
  const _TimedEvent({required this.event, required this.brightness, required this.onTap});

  final GenCalendarEvent event;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final strong = _strong(event.color, brightness);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: _tint(event.color, brightness),
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: event.color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.smallLabel.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: strong),
            ),
            Text(
              '${_fmtChipTime(event.start)} – ${_fmtChipTime(event.end)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.smallLabel.copyWith(fontSize: 10, color: strong.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllDayBar extends StatelessWidget {
  const _AllDayBar({required this.event, required this.brightness, required this.onTap});

  final GenCalendarEvent event;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: _tint(event.color, brightness), borderRadius: BorderRadius.circular(4)),
        child: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.smallLabel.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: _strong(event.color, brightness)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Agenda view
// ═══════════════════════════════════════════════════════════════════════════

class _AgendaView extends StatelessWidget {
  const _AgendaView({
    required this.start,
    required this.days,
    required this.today,
    required this.events,
    required this.onEventTap,
  });

  final DateTime start;
  final int days;
  final DateTime today;
  final List<GenCalendarEvent> events;
  final ValueChanged<GenCalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final b = Theme.of(context).brightness;

    // Raggruppa per giorno nella finestra; scarta i giorni senza eventi.
    final groups = <DateTime, List<GenCalendarEvent>>{};
    for (var i = 0; i < days; i++) {
      final day = DateUtils.dateOnly(start.add(Duration(days: i)));
      final dayEvents = events.where((e) => e.coversDay(day)).toList()
        ..sort((a, b) {
          if (a.allDay != b.allDay) return a.allDay ? -1 : 1;
          return a.start.compareTo(b.start);
        });
      if (dayEvents.isNotEmpty) groups[day] = dayEvents;
    }

    if (groups.isEmpty) {
      return Center(
        child: Text('Nessun evento in questo periodo', style: t.bodyText.copyWith(color: t.secondaryText)),
      );
    }

    final entries = groups.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: GenSizes.gapMd),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final day = entries[i].key;
        final dayEvents = entries[i].value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(GenSizes.gapLg, GenSizes.gapMd, GenSizes.gapLg, GenSizes.gapSm),
              child: Text(
                '${day.day} ${_monthShort[day.month - 1].toUpperCase()}, ${_weekdayFull[day.weekday % 7].toUpperCase()}',
                style: t.smallLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DateUtils.isSameDay(day, today) ? t.primary : t.secondaryText,
                ),
              ),
            ),
            for (final e in dayEvents)
              Padding(
                padding: const EdgeInsets.fromLTRB(GenSizes.gapLg, 0, GenSizes.gapLg, GenSizes.gapSm),
                child: _AgendaCard(event: e, brightness: b, onTap: () => onEventTap(e)),
              ),
          ],
        );
      },
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.event, required this.brightness, required this.onTap});

  final GenCalendarEvent event;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final strong = _strong(event.color, brightness);
    final meta = <String>[
      if (event.allDay) 'All day' else '${_fmtLongTime(event.start)} – ${_fmtLongTime(event.end)}',
      if (event.location != null && event.location!.isNotEmpty) event.location!,
    ].join('   ·   ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(GenSizes.gapMd),
        decoration: BoxDecoration(color: _tint(event.color, brightness), borderRadius: BorderRadius.circular(GenSizes.radiusChip)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: t.title.copyWith(color: strong, fontWeight: FontWeight.w600)),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(meta, style: t.smallText.copyWith(color: strong.withValues(alpha: 0.85))),
            ],
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(event.description!, style: t.smallText.copyWith(color: strong.withValues(alpha: 0.9))),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Edit dialog
// ═══════════════════════════════════════════════════════════════════════════

enum _EditorAction { save, delete }

class _EditorResult {
  const _EditorResult(this.action, this.event);
  final _EditorAction action;
  final GenCalendarEvent? event;
}

class _EventEditDialog extends StatefulWidget {
  const _EventEditDialog({
    required this.event,
    required this.palette,
    required this.seedStart,
    this.asSheet = false,
  });

  final GenCalendarEvent? event;
  final List<Color> palette;
  final DateTime seedStart;

  /// Presentazione: `true` → bottom sheet (mobile), `false` → dialog (desktop).
  final bool asSheet;

  @override
  State<_EventEditDialog> createState() => _EventEditDialogState();
}

class _EventEditDialogState extends State<_EventEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _startMin; // minuti da mezzanotte
  late int _endMin;
  late bool _allDay;
  late Color _color;

  bool get _isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    final s = e?.start ?? widget.seedStart;
    final en = e?.end ?? widget.seedStart.add(const Duration(hours: 1));
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _startDate = DateUtils.dateOnly(s);
    _endDate = DateUtils.dateOnly(en);
    _startMin = s.hour * 60 + s.minute;
    _endMin = en.hour * 60 + en.minute;
    _allDay = e?.allDay ?? false;
    _color = e?.color ?? widget.palette.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    final start = _allDay
        ? _startDate
        : DateTime(_startDate.year, _startDate.month, _startDate.day, _startMin ~/ 60, _startMin % 60);
    final end = _allDay
        ? _endDate
        : DateTime(_endDate.year, _endDate.month, _endDate.day, _endMin ~/ 60, _endMin % 60);
    final event = (widget.event ??
            GenCalendarEvent(id: _newId(), title: '', start: start, end: end))
        .copyWith(
      title: _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      start: start,
      end: end.isBefore(start) ? start : end,
      allDay: _allDay,
      color: _color,
    );
    Navigator.of(context).pop(_EditorResult(_EditorAction.save, event));
  }

  static String _newId() => 'evt_${DateTime.now().microsecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final title = Text(_isEdit ? 'Edit Event' : 'New Event');
    final body = _body(t);
    // Mobile → ShadSheet (bottom, scrollabile); desktop → ShadDialog centrato.
    return widget.asSheet
        ? ShadSheet(title: title, child: body)
        : ShadDialog(title: title, constraints: const BoxConstraints(maxWidth: 440), child: body);
  }

  Widget _body(GenTokens t) {
    return Padding(
        padding: const EdgeInsets.only(top: GenSizes.gapMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(t, 'Title', ShadInput(controller: _title, placeholder: const Text('Event title'))),
            _field(t, 'Description',
                ShadInput(controller: _description, placeholder: const Text('Description'), maxLines: 3)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _field(t, 'Start Date', _datePicker(_startDate, (d) => setState(() => _startDate = d)))),
                if (!_allDay) ...[
                  const SizedBox(width: GenSizes.gapMd),
                  SizedBox(
                    width: 130,
                    child: _field(t, 'Start Time', _timeSelect(_startMin, (m) => setState(() => _startMin = m))),
                  ),
                ],
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _field(t, 'End Date', _datePicker(_endDate, (d) => setState(() => _endDate = d)))),
                if (!_allDay) ...[
                  const SizedBox(width: GenSizes.gapMd),
                  SizedBox(
                    width: 130,
                    child: _field(t, 'End Time', _timeSelect(_endMin, (m) => setState(() => _endMin = m))),
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: GenSizes.gapSm),
              child: Row(
                children: [
                  ShadCheckbox(value: _allDay, onChanged: (v) => setState(() => _allDay = v)),
                  const SizedBox(width: GenSizes.gapSm),
                  Text('All day', style: t.bodyText),
                ],
              ),
            ),
            _field(t, 'Location', ShadInput(controller: _location, placeholder: const Text('Location'))),
            Text('Etiquette', style: t.bodyLabel),
            const SizedBox(height: GenSizes.gapSm),
            Row(
              children: [
                for (final c in widget.palette)
                  Padding(
                    padding: const EdgeInsets.only(right: GenSizes.gapSm),
                    child: _Swatch(color: c, selected: c.toARGB32() == _color.toARGB32(), onTap: () => setState(() => _color = c)),
                  ),
              ],
            ),
            const SizedBox(height: GenSizes.gapLg),
            Row(
              children: [
                if (_isEdit)
                  ShadIconButton.outline(
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    onPressed: () => Navigator.of(context).pop(_EditorResult(_EditorAction.delete, widget.event)),
                  ),
                const Spacer(),
                ShadButton.outline(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: GenSizes.gapSm),
                ShadButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      );
  }

  Widget _field(GenTokens t, String label, Widget input) => Padding(
        padding: const EdgeInsets.only(bottom: GenSizes.gapMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.bodyLabel),
            const SizedBox(height: 6),
            input,
          ],
        ),
      );

  Widget _datePicker(DateTime value, ValueChanged<DateTime> onChanged) => ShadDatePicker(
        selected: value,
        onChanged: (d) {
          if (d != null) onChanged(DateUtils.dateOnly(d));
        },
      );

  Widget _timeSelect(int value, ValueChanged<int> onChanged) => ShadSelect<int>(
        initialValue: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        options: [
          for (var m = 0; m < 24 * 60; m += 15) ShadOption(value: m, child: Text(_fmtMinutes(m))),
        ],
        selectedOptionBuilder: (context, v) => Text(_fmtMinutes(v)),
      );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: t.primaryText, width: 2) : null,
        ),
        child: selected ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Helpers condivisi (date/ora/colore)
// ═══════════════════════════════════════════════════════════════════════════

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _monthShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// Indice per `weekday % 7`: 0=domenica, 1=lunedì … 6=sabato.
const _weekdayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _weekdayFull = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

/// Inizio settimana contenente [d] dato il primo giorno [weekStartsOn] (1..7).
DateTime _startOfWeek(DateTime d, int weekStartsOn) {
  final day = DateUtils.dateOnly(d);
  final diff = (day.weekday - weekStartsOn) % 7;
  return day.subtract(Duration(days: diff < 0 ? diff + 7 : diff));
}

int _minutes(DateTime d) => d.hour * 60 + d.minute;

/// "10am", "12pm", "2:30pm" — compatto per chip/blocchi.
String _fmtChipTime(DateTime d) {
  final h = d.hour;
  final period = h < 12 ? 'am' : 'pm';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return d.minute == 0 ? '$h12$period' : '$h12:${d.minute.toString().padLeft(2, '0')}$period';
}

/// "10:00 AM" — esteso per agenda e select.
String _fmtLongTime(DateTime d) => _fmtMinutes(d.hour * 60 + d.minute);

String _fmtMinutes(int totalMin) {
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  final period = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}

/// Etichetta del gutter orario: "1 AM", "12 PM"…
String _fmtHourLabel(int h) {
  final period = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12 $period';
}

/// Sfondo tinto (fill tenue) dal colore evento, per tema chiaro/scuro.
Color _tint(Color c, Brightness b) => c.withValues(alpha: b == Brightness.dark ? 0.24 : 0.16);

/// Variante "forte" del colore (testo leggibile su [_tint]).
Color _strong(Color c, Brightness b) {
  final hsl = HSLColor.fromColor(c);
  final l = b == Brightness.dark ? (hsl.lightness + 0.22).clamp(0.0, 1.0) : (hsl.lightness - 0.22).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

/// Layout di un evento in una colonna giornaliera (posizione orizzontale).
class _EventLayout {
  _EventLayout({required this.event, required this.column, required this.columnCount});
  final GenCalendarEvent event;
  final int column;
  int columnCount;
}

/// Assegna colonne agli eventi che si sovrappongono (packing greedy per cluster).
List<_EventLayout> _layoutDay(List<GenCalendarEvent> events) {
  final sorted = List.of(events)..sort((a, b) => a.start.compareTo(b.start));
  final result = <_EventLayout>[];
  var group = <_EventLayout>[];
  DateTime? groupEnd;

  void flush() {
    if (group.isEmpty) return;
    final cols = group.fold<int>(0, (m, l) => math.max(m, l.column + 1));
    for (final l in group) {
      l.columnCount = cols;
    }
    result.addAll(group);
    group = [];
    groupEnd = null;
  }

  for (final e in sorted) {
    if (groupEnd != null && !e.start.isBefore(groupEnd!)) flush();
    final used = group.where((l) => l.event.end.isAfter(e.start)).map((l) => l.column).toSet();
    var col = 0;
    while (used.contains(col)) {
      col++;
    }
    group.add(_EventLayout(event: e, column: col, columnCount: 1));
    if (groupEnd == null || e.end.isAfter(groupEnd!)) groupEnd = e.end;
  }
  flush();
  return result;
}
