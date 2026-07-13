import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../cl_theme.dart';
import 'cl_calendar.widget.dart';
import 'cl_popup_surface.widget.dart';
import 'foundation/cl_pressable.widget.dart';
import 'foundation/cl_tone_style.dart';
import 'foundation/cl_focus_ring.dart';

/// Date picker **in-theme** (shadcn `ShadDatePicker`): trigger a bottone
/// (icona calendario + data/placeholder) che apre un popover ancorato con
/// [CLCalendar]. Varianti `single` e `range`. Nessun dialog Material.
class CLDatePicker extends StatefulWidget {
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

  @override
  State<CLDatePicker> createState() => _CLDatePickerState();
}

class _CLDatePickerState extends State<CLDatePicker> {
  final LayerLink _link = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _entry;
  bool _open = false;
  bool _closing = false;

  DateTime? _selected;
  DateTime? _rStart;
  DateTime? _rEnd;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _rStart = widget.rangeStart;
    _rEnd = widget.rangeEnd;
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _focusNode.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _label {
    if (widget.isRange) {
      if (_rStart == null) return widget.placeholder ?? 'Seleziona intervallo';
      return _rEnd == null
          ? '${_fmt(_rStart!)} → …'
          : '${_fmt(_rStart!)} → ${_fmt(_rEnd!)}';
    }
    return _selected == null
        ? (widget.placeholder ?? 'Seleziona data')
        : _fmt(_selected!);
  }

  bool get _hasValue => widget.isRange ? _rStart != null : _selected != null;

  void _open_() {
    if (_open) return;
    _open = true;
    _entry = _createEntry();
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    if (!_open || _closing) return;
    _closing = true;
    _entry?.markNeedsBuild();
  }

  void _finalize() {
    _entry?.remove();
    _entry = null;
    _open = false;
    _closing = false;
    if (mounted) setState(() {});
    // Come shadcn (date_picker.dart: solo popover.hide()): niente refocus del
    // trigger dopo selezione/chiusura → il focus ring non ricompare (e non
    // espone il taglio del ring). Il focus resta dove l'ha lasciato l'utente.
  }

  void _onSingle(DateTime? d) {
    setState(() => _selected = d);
    widget.onChanged?.call(d);
    if (widget.closeOnSelect) _close();
  }

  void _onRange(DateTime? s, DateTime? e) {
    setState(() {
      _rStart = s;
      _rEnd = e;
    });
    widget.onRangeChanged?.call(s, e);
    if (widget.closeOnSelect && s != null && e != null) _close();
  }

  OverlayEntry _createEntry() {
    final theme = CLTheme.of(context);
    final box = _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    const gap = 4.0;
    const estH = 360.0;
    final spaceBelow = screenH - (offset.dy + size.height + gap);
    final spaceAbove = offset.dy - gap;
    final openUp = spaceBelow < estH && spaceAbove > spaceBelow;

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
              targetAnchor:
                  openUp ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor:
                  openUp ? Alignment.bottomLeft : Alignment.topLeft,
              offset: openUp ? const Offset(0, -gap) : const Offset(0, gap),
              child: CLPopupSurface(
                animateUpward: openUp,
                visible: !_closing,
                onDismissed: _finalize,
                padding: EdgeInsets.all(theme.gapMd),
                child: SizedBox(
                  width: 280,
                  child: widget.isRange
                      ? CLCalendar.range(
                          rangeStart: _rStart,
                          rangeEnd: _rEnd,
                          firstDate: widget.firstDate,
                          lastDate: widget.lastDate,
                          selectableDayPredicate: widget.selectableDayPredicate,
                          onRangeChanged: _onRange,
                        )
                      : CLCalendar(
                          selected: _selected,
                          firstDate: widget.firstDate,
                          lastDate: widget.lastDate,
                          selectableDayPredicate: widget.selectableDayPredicate,
                          onChanged: _onSingle,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return CompositedTransformTarget(
      link: _link,
      child: CLPressable(
        key: _triggerKey,
        focusNode: _focusNode,
        onTap: _open_,
        builder: (context, state) {
          // Hover come shadcn (date picker trigger = ShadButton.raw variant
          // outline): rest = superficie, hover/press = overlay neutro `accent`
          // dal motore CLToneStyle (identico a outline/ghost). Niente magic.
          final Color bg = (state.hovered || state.pressed)
              ? CLToneStyle.resolve(theme,
                      color: theme.primary,
                      variant: CLVariant.outline,
                      state: state)
                  .bg
              : theme.secondaryBackground;
          Widget box = AnimatedContainer(
            duration: theme.durationFast,
            curve: Curves.easeOut,
            width: widget.width,
            height: theme.inputHeight,
            padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(theme.radiusControl),
              border: Border.all(color: theme.cardBorder, width: 1),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendar400,
                    size: theme.iconSizeCompact,
                    color: _hasValue
                        ? theme.secondaryText
                        : theme.mutedForeground),
                SizedBox(width: theme.gapSm),
                Expanded(
                  child: Text(
                    _label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyText.copyWith(
                        color: _hasValue
                            ? theme.primaryText
                            : theme.mutedForeground),
                  ),
                ),
              ],
            ),
          );
          if (state.focused) {
            box = CustomPaint(
              foregroundPainter: CLFocusRingPainter(
                  color: theme.ring, radius: theme.radiusControl),
              child: box,
            );
          }
          return box;
        },
      ),
    );
  }
}
