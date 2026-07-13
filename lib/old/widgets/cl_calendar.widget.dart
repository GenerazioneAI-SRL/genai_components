import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../cl_theme.dart';
import 'cl_popup_surface.widget.dart';
import 'foundation/cl_pressable.widget.dart';
import 'foundation/cl_tone_style.dart';
import 'foundation/cl_focus_ring.dart';

/// Lato del pill giorno (shadcn `dayButtonSize: 36`): la cella può essere più
/// larga (griglia responsive), il pill resta 36 centrato → crisp e con respiro.
/// Il range invece riempie la cella per barre contigue.
const double _kDaySize = 36;

/// Modalità di selezione del [CLCalendar] (shadcn `ShadCalendarVariant`).
enum CLCalendarVariant { single, multiple, range }

/// Layout dell'intestazione (shadcn `ShadCalendarCaptionLayout`): etichetta
/// testuale, oppure dropdown per mese e/o anno.
enum CLCalendarCaptionLayout { label, dropdownMonths, dropdownYears, dropdown }

/// Calendario **in-theme**, modello shadcn `ShadCalendar` (letto dal sorgente
/// `flutter-shadcn-ui`). Header con nav mese, riga giorni settimana, griglia.
/// Celle su `CLPressable` + `CLToneStyle`: selected = solid primary · today =
/// `accent` grigio (shadcn today=secondary=grigio; il ns secondary è blu brand)
/// · normale = ghost · fuori-mese = opacity .5 muted. Pill giorno 36 centrato;
/// range riempie la cella (barra contigua). Settimana lun-first, IT.
///
/// Feature (allineate alla doc shadcn): `showWeekNumbers`, `showOutsideDays`,
/// `fixedWeeks`, `hideNavigation`, `hideWeekdayNames`, `numberOfMonths`,
/// `captionLayout`, `fromMonth`/`toMonth` (bound nav), `min`/`max` (conteggio
/// multiple / lunghezza range).
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

  /// Mese minimo/massimo navigabile (le frecce si disabilitano ai bordi; i
  /// dropdown anno/mese si limitano a questo intervallo).
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

  late DateTime _currentMonth;
  DateTime? _selected;
  final Set<DateTime> _selectedDays = {};
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _selectedDays.addAll(widget.selectedDates.map(_dayOnly));
    _rangeStart = widget.rangeStart == null ? null : _dayOnly(widget.rangeStart!);
    _rangeEnd = widget.rangeEnd == null ? null : _dayOnly(widget.rangeEnd!);
    final base = widget.initialMonth ??
        widget.selected ??
        widget.rangeStart ??
        (widget.selectedDates.isNotEmpty ? widget.selectedDates.first : null) ??
        DateTime.now();
    _currentMonth = _clampMonth(DateTime(base.year, base.month));
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _monthOnly(DateTime d) => DateTime(d.year, d.month);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
  DateTime _addMonths(DateTime d, int n) => DateTime(d.year, d.month + n);

  /// Mese dell'ultimo blocco mostrato (con numberOfMonths).
  DateTime get _lastMonth => _addMonths(_currentMonth, widget.numberOfMonths - 1);

  DateTime _clampMonth(DateTime m) {
    var out = m;
    if (widget.fromMonth != null && out.isBefore(_monthOnly(widget.fromMonth!))) {
      out = _monthOnly(widget.fromMonth!);
    }
    // toMonth vincola l'ULTIMO blocco: il primo non può superare toMonth-(N-1).
    if (widget.toMonth != null) {
      final maxFirst =
          _addMonths(_monthOnly(widget.toMonth!), -(widget.numberOfMonths - 1));
      if (out.isAfter(maxFirst)) out = maxFirst;
    }
    return out;
  }

  bool get _canPrev =>
      widget.fromMonth == null ||
      _currentMonth.isAfter(_monthOnly(widget.fromMonth!));
  bool get _canNext =>
      widget.toMonth == null || _lastMonth.isBefore(_monthOnly(widget.toMonth!));

  bool _isSelectable(DateTime d) {
    if (widget.firstDate != null && d.isBefore(_dayOnly(widget.firstDate!))) {
      return false;
    }
    if (widget.lastDate != null && d.isAfter(_dayOnly(widget.lastDate!))) {
      return false;
    }
    // Range: durante la scelta della fine, disabilita i giorni che darebbero
    // una lunghezza fuori da [min, max] (shadcn).
    if (widget.variant == CLCalendarVariant.range &&
        _rangeStart != null &&
        _rangeEnd == null) {
      final len = (_dayOnly(d).difference(_rangeStart!).inDays).abs() + 1;
      if (widget.min != null && len < widget.min!) return false;
      if (widget.max != null && len > widget.max!) return false;
    }
    return widget.selectableDayPredicate?.call(d) ?? true;
  }

  /// Griglia di un mese (lun-first). `fixedWeeks` → sempre 42 celle (6 righe).
  List<DateTime> _daysInGrid(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    var firstShown = firstOfMonth;
    while (firstShown.weekday != DateTime.monday) {
      firstShown = _addDays(firstShown, -1);
    }
    final firstOfNext = DateTime(month.year, month.month + 1, 1);
    // fixedWeeks richiede showOutsideDays (shadcn): 6 righe fisse.
    final bool fixed = widget.fixedWeeks && widget.showOutsideDays;
    final dates = <DateTime>[];
    var d = firstShown;
    while (d.isBefore(firstOfNext) || dates.length % 7 != 0) {
      dates.add(d);
      d = _addDays(d, 1);
      if (dates.length >= 42) break;
    }
    while (fixed && dates.length < 42) {
      dates.add(d);
      d = _addDays(d, 1);
    }
    return dates;
  }

  /// Numero di settimana ISO 8601 [1..53] (port da shadcn `date_time.dart`).
  int _isoWeek(DateTime date) {
    const offsets = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    bool leap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
    int ordinal(DateTime d) =>
        offsets[d.month - 1] + d.day + (leap(d.year) && d.month > 2 ? 1 : 0);
    final woy = (ordinal(date) - date.weekday + 10) ~/ 7;
    if (woy < 1) return _isoWeek(DateTime(date.year - 1, 12, 28));
    if (woy == 53 &&
        DateTime(date.year).weekday != DateTime.thursday &&
        DateTime(date.year, 12, 31).weekday != DateTime.thursday) {
      return 1;
    }
    return woy;
  }

  void _goToMonth(int deltaMonths) {
    setState(() => _currentMonth = _clampMonth(_addMonths(_currentMonth, deltaMonths)));
  }

  void _onTap(DateTime date) {
    setState(() {
      switch (widget.variant) {
        case CLCalendarVariant.single:
          _selected = date;
          widget.onChanged?.call(date);
        case CLCalendarVariant.multiple:
          final already = _selectedDays.any((d) => _isSameDay(d, date));
          if (already) {
            // min: non scendere sotto la soglia.
            if (widget.min != null && _selectedDays.length <= widget.min!) return;
            _selectedDays.removeWhere((d) => _isSameDay(d, date));
          } else {
            // max: non superare la soglia.
            if (widget.max != null && _selectedDays.length >= widget.max!) return;
            _selectedDays.add(date);
          }
          widget.onMultipleChanged?.call(_selectedDays.toList());
        case CLCalendarVariant.range:
          if (_rangeStart == null) {
            _rangeStart = date;
            _rangeEnd = null;
          } else if (_rangeEnd == null) {
            if (date.isBefore(_rangeStart!)) {
              _rangeEnd = _rangeStart;
              _rangeStart = date;
            } else {
              _rangeEnd = date;
            }
          } else {
            _rangeStart = date;
            _rangeEnd = null;
          }
          widget.onRangeChanged?.call(_rangeStart, _rangeEnd);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    // Un mese = blocco diretto (riempie il parent). Più mesi = Row di Expanded
    // (il GridView ha bisogno di larghezza definita, no MainAxisSize.min).
    if (widget.numberOfMonths <= 1) {
      return _monthBlock(theme, _currentMonth, showPrev: true, showNext: true);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.numberOfMonths; i++) ...[
          if (i > 0) SizedBox(width: theme.gapLg),
          Expanded(
            child: _monthBlock(
              theme,
              _addMonths(_currentMonth, i),
              showPrev: i == 0,
              showNext: i == widget.numberOfMonths - 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _monthBlock(CLTheme theme, DateTime month,
      {required bool showPrev, required bool showNext}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _captionRow(theme, month, showPrev: showPrev, showNext: showNext),
        SizedBox(height: theme.gapLg), // shadcn headerPadding bottom: 16
        if (!widget.hideWeekdayNames) ...[
          _weekdayRow(theme),
          SizedBox(height: theme.gapSm),
        ],
        _grid(theme, month),
      ],
    );
  }

  Widget _captionRow(CLTheme theme, DateTime month,
      {required bool showPrev, required bool showNext}) {
    final bool nav = !widget.hideNavigation;
    return Row(
      children: [
        if (nav)
          (showPrev
              ? _navButton(theme, up: false, enabled: _canPrev)
              : const SizedBox(width: 28)),
        Expanded(child: Center(child: _caption(theme, month))),
        if (nav)
          (showNext
              ? _navButton(theme, up: true, enabled: _canNext)
              : const SizedBox(width: 28)),
      ],
    );
  }

  Widget _caption(CLTheme theme, DateTime month) {
    final labelStyle = theme.bodyText.copyWith(fontWeight: FontWeight.w500);
    switch (widget.captionLayout) {
      case CLCalendarCaptionLayout.label:
        return Text('${_months[month.month - 1]} ${month.year}', style: labelStyle);
      case CLCalendarCaptionLayout.dropdownMonths:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          _monthDropdown(theme, month),
          SizedBox(width: theme.gapSm),
          Text('${month.year}', style: labelStyle),
        ]);
      case CLCalendarCaptionLayout.dropdownYears:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_months[month.month - 1], style: labelStyle),
          SizedBox(width: theme.gapSm),
          _yearDropdown(theme, month),
        ]);
      case CLCalendarCaptionLayout.dropdown:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          _monthDropdown(theme, month),
          SizedBox(width: theme.gapSm),
          _yearDropdown(theme, month),
        ]);
    }
  }

  Widget _monthDropdown(CLTheme theme, DateTime month) {
    // Mesi ammessi nel range fromMonth/toMonth per l'anno corrente.
    int minM = 1, maxM = 12;
    if (widget.fromMonth != null && widget.fromMonth!.year == month.year) {
      minM = widget.fromMonth!.month;
    }
    if (widget.toMonth != null && widget.toMonth!.year == month.year) {
      maxM = widget.toMonth!.month;
    }
    return _CLCaptionDropdown(
      text: _months[month.month - 1],
      selectedIndex: month.month - minM,
      options: [for (int m = minM; m <= maxM; m++) _months[m - 1]],
      onSelected: (i) => _goToMonth(
          (DateTime(month.year, minM + i).year * 12 + (minM + i)) -
              (_currentMonth.year * 12 + _currentMonth.month)),
    );
  }

  Widget _yearDropdown(CLTheme theme, DateTime month) {
    final now = DateTime.now();
    final int y0 = widget.fromMonth?.year ?? now.year - 10;
    final int y1 = widget.toMonth?.year ?? now.year + 10;
    return _CLCaptionDropdown(
      text: '${month.year}',
      selectedIndex: month.year - y0,
      options: [for (int y = y0; y <= y1; y++) '$y'],
      onSelected: (i) => _goToMonth(
          ((y0 + i) * 12 + month.month) - (_currentMonth.year * 12 + _currentMonth.month)),
    );
  }

  Widget _navButton(CLTheme theme, {required bool up, required bool enabled}) {
    return CLPressable(
      enabled: enabled,
      onTap: enabled ? () => _goToMonth(up ? 1 : -1) : null,
      builder: (context, state) {
        // shadcn: ShadIconButton.outline, opacità .5 a riposo → 1 su hover.
        // Disabilitato ai bordi fromMonth/toMonth → opacità ridotta, no hover.
        Widget btn = Opacity(
          opacity: !enabled ? 0.3 : (state.hovered ? 1.0 : 0.5),
          child: AnimatedContainer(
            duration: theme.durationFast,
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: state.hovered ? theme.accent : theme.accent.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(theme.radiusControl),
              border: Border.all(color: theme.cardBorder, width: 1),
            ),
            child: Icon(
              up ? LucideIcons.chevronRight400 : LucideIcons.chevronLeft400,
              size: theme.iconSizeCompact,
              color: theme.secondaryText,
            ),
          ),
        );
        if (state.focused) {
          btn = CustomPaint(
            foregroundPainter:
                CLFocusRingPainter(color: theme.ring, radius: theme.radiusControl),
            child: btn,
          );
        }
        return btn;
      },
    );
  }

  Widget _weekdayRow(CLTheme theme) {
    return Row(
      children: [
        // Colonna vuota allineata al numero-settimana (griglia a 8 col uguali).
        if (widget.showWeekNumbers) const Expanded(child: SizedBox()),
        for (final w in _weekdays)
          Expanded(
            child: Text(
              w,
              textAlign: TextAlign.center,
              style: theme.smallText.copyWith(color: theme.mutedForeground),
            ),
          ),
      ],
    );
  }

  Widget _grid(CLTheme theme, DateTime month) {
    final days = _daysInGrid(month);
    final rows = days.length ~/ 7;
    final bool wn = widget.showWeekNumbers;
    final children = <Widget>[];
    for (int row = 0; row < rows; row++) {
      if (wn) children.add(_weekNumberCell(theme, days[row * 7]));
      for (int col = 0; col < 7; col++) {
        children.add(_dayCell(theme, month, days[row * 7 + col], col));
      }
    }
    return GridView.count(
      crossAxisCount: wn ? 8 : 7,
      childAspectRatio: 1,
      mainAxisSpacing: theme.gapSm,
      crossAxisSpacing: 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: children,
    );
  }

  Widget _weekNumberCell(CLTheme theme, DateTime rowFirstDay) {
    return Center(
      child: Text(
        '${_isoWeek(rowFirstDay)}',
        style: theme.smallText.copyWith(color: theme.mutedForeground),
      ),
    );
  }

  Widget _dayCell(CLTheme theme, DateTime month, DateTime date, int col) {
    final bool inMonth = date.month == month.month && date.year == month.year;
    // showOutsideDays: false → cella vuota fuori-mese (mantiene la posizione).
    if (!inMonth && !widget.showOutsideDays) {
      return const SizedBox.shrink();
    }
    final bool isToday = _isSameDay(date, DateTime.now());
    final bool enabled = _isSelectable(date);

    bool selected = false;
    bool isRangeStart = false, isRangeEnd = false, inRange = false;
    switch (widget.variant) {
      case CLCalendarVariant.single:
        selected = _selected != null && _isSameDay(date, _selected!);
      case CLCalendarVariant.multiple:
        selected = _selectedDays.any((d) => _isSameDay(d, date));
      case CLCalendarVariant.range:
        isRangeStart = _rangeStart != null && _isSameDay(date, _rangeStart!);
        isRangeEnd = _rangeEnd != null && _isSameDay(date, _rangeEnd!);
        inRange = _rangeStart != null &&
            _rangeEnd != null &&
            !date.isBefore(_rangeStart!) &&
            !date.isAfter(_rangeEnd!);
        selected = isRangeStart || isRangeEnd;
    }

    final bool isEndpoint = selected;
    final bool isMiddle = inRange && !isEndpoint;

    final r = Radius.circular(theme.radiusControl);
    final bool isFirstOfRow = col == 0;
    final bool isLastOfRow = col == 6;
    BorderRadius radius;
    if (widget.variant == CLCalendarVariant.range &&
        (isMiddle || isEndpoint) &&
        inRange) {
      final left = isRangeStart || isFirstOfRow;
      final right = isRangeEnd || isLastOfRow;
      radius = BorderRadius.horizontal(
        left: left ? r : Radius.zero,
        right: right ? r : Radius.zero,
      );
    } else {
      radius = BorderRadius.all(r);
    }

    return CLPressable(
      enabled: enabled,
      onTap: enabled ? () => _onTap(date) : null,
      builder: (context, state) {
        final CLToneColors c = isEndpoint
            ? CLToneStyle.resolve(theme,
                color: theme.primary, variant: CLVariant.solid, state: state)
            : isToday
                ? CLToneStyle.resolve(theme,
                    color: theme.accent, variant: CLVariant.solid, state: state)
                : CLToneStyle.resolve(theme,
                    color: theme.primary,
                    variant: CLVariant.ghost,
                    state: state,
                    colored: false);
        final Color bg = isMiddle
            ? (state.hovered ? theme.accent : theme.accent.withValues(alpha: 0.6))
            : c.bg;
        final Color fg = isEndpoint
            ? c.fg
            : (isMiddle
                ? theme.primaryText
                : (isToday ? c.fg : (inMonth ? c.fg : theme.mutedForeground)));

        Widget pill = AnimatedContainer(
          duration: theme.durationFast,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Text(
            '${date.day}',
            style: theme.bodyText.copyWith(
                color: fg,
                fontWeight: isEndpoint ? FontWeight.w500 : FontWeight.w400),
          ),
        );
        if (state.focused) {
          pill = CustomPaint(
            foregroundPainter:
                CLFocusRingPainter(color: theme.ring, radius: theme.radiusControl),
            child: pill,
          );
        }

        final bool fillsCell =
            widget.variant == CLCalendarVariant.range && inRange;
        final Widget cell = fillsCell
            ? pill
            : Center(child: SizedBox.square(dimension: _kDaySize, child: pill));

        return Opacity(opacity: inMonth ? 1.0 : 0.5, child: cell);
      },
    );
  }
}

/// Dropdown compatto per mese/anno nell'header (shadcn `captionLayout`): testo +
/// chevron, apre un popover in-theme con la lista scrollabile.
class _CLCaptionDropdown extends StatefulWidget {
  const _CLCaptionDropdown({
    required this.text,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String text;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_CLCaptionDropdown> createState() => _CLCaptionDropdownState();
}

class _CLCaptionDropdownState extends State<_CLCaptionDropdown> {
  final LayerLink _link = LayerLink();
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _entry;
  bool _closing = false;

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  void _open() {
    if (_entry != null) return;
    _closing = false;
    _entry = _build();
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    if (_entry == null || _closing) return;
    _closing = true;
    _entry!.markNeedsBuild();
  }

  void _finalize() {
    _entry?.remove();
    _entry = null;
    _closing = false;
    if (mounted) setState(() {});
  }

  OverlayEntry _build() {
    final theme = CLTheme.of(context);
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _close,
            behavior: HitTestBehavior.translucent,
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: CLPopupSurface(
                visible: !_closing,
                onDismissed: _finalize,
                padding: EdgeInsets.all(theme.gapXs),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, minWidth: 96),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < widget.options.length; i++)
                          _option(theme, i),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _option(CLTheme theme, int i) {
    final bool sel = i == widget.selectedIndex;
    return CLPressable(
      onTap: () {
        widget.onSelected(i);
        _close();
      },
      builder: (context, state) {
        final Color bg = sel
            ? theme.primary.withValues(alpha: theme.opacitySoft)
            : (state.hovered
                ? theme.secondaryText.withValues(alpha: theme.opacitySoft)
                : Colors.transparent);
        return AnimatedContainer(
          duration: theme.durationFast,
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: theme.gapXs),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.gapSm),
          ),
          child: Text(
            widget.options[i],
            style: theme.bodyText.copyWith(
                color: sel ? theme.primary : theme.primaryText,
                fontWeight: sel ? FontWeight.w500 : FontWeight.w400),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return CompositedTransformTarget(
      link: _link,
      child: CLPressable(
        key: _key,
        onTap: _open,
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: theme.gapSm, vertical: theme.gapXs),
            decoration: BoxDecoration(
              color: state.hovered
                  ? theme.accent
                  : theme.accent.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(theme.radiusControl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text,
                    style: theme.bodyText.copyWith(fontWeight: FontWeight.w500)),
                SizedBox(width: theme.gapXs),
                Icon(LucideIcons.chevronDown400,
                    size: theme.iconSizeCompact, color: theme.secondaryText),
              ],
            ),
          );
        },
      ),
    );
  }
}
