part of '../cl_text_field.widget.dart';

/// Date picker dispatch: month / date pickers and combined date+time flow.
class _TextFieldDateHelper extends _Helper {
  _TextFieldDateHelper(super.s);

  String formatDateTime(DateTime dt) {
    if (w.withTime) {
      return DateFormat(w.withoutDay ? 'MM-yyyy HH:mm' : 'dd-MM-yyyy HH:mm').format(dt);
    }
    return DateFormat(w.withoutDay ? 'MM-yyyy' : 'dd-MM-yyyy').format(dt);
  }

  String formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> selectDate(BuildContext context) async {
    final theme = CLTheme.of(context);
    if (!w.onlyTime) {
      final DateTime? picked;
      if (w.withoutDay) {
        picked = await _showMonthPicker(context, theme);
      } else {
        picked = await _showDatePicker(context, theme);
      }
      if (!s.mounted) return;
      if (picked != null) {
        DateTime finalDt = picked;
        if (w.withTime) {
          if (!s.mounted) return;
          final TimeOfDay? pt = await s._timeHelper.show(s.context, theme);
          if (!s.mounted) return;
          if (pt == null) {
            // ignore: invalid_use_of_protected_member
            s.setState(() {
              s.isDatePicked = false;
              s.controllerRef.clear();
            });
            return;
          }
          finalDt = DateTime(picked.year, picked.month, picked.day, pt.hour, pt.minute);
        }
        // ignore: invalid_use_of_protected_member
        s.setState(() {
          s.isDatePicked = true;
          w.onDateTimeSelected!(finalDt);
          s.controllerRef.text = formatDateTime(finalDt);
        });
      }
    } else {
      final TimeOfDay? pt = await s._timeHelper.show(context, theme, inputOnly: true);
      if (!s.mounted) return;
      if (pt != null) {
        // ignore: invalid_use_of_protected_member
        s.setState(() {
          w.onTimeSelected!(pt);
          s.isDatePicked = true;
          s.controllerRef.text = formatTime(pt);
        });
      }
    }
  }

  Future<DateTime?> _showMonthPicker(BuildContext context, CLTheme theme) => showMonthPicker(
        context: context,
        initialDate: w.initialSelectedDateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(DateTime.now().year + 100),
        monthPickerDialogSettings: MonthPickerDialogSettings(
          actionBarSettings: PickerActionBarSettings(
            confirmWidget: _actionBtn(context, 'Conferma', theme.primary, Colors.white),
            cancelWidget:
                _actionBtn(context, 'Annulla', theme.mutedForeground.withValues(alpha: theme.opacitySoft), theme.mutedForeground),
          ),
          headerSettings: PickerHeaderSettings(
            headerBackgroundColor: theme.primary,
            headerCurrentPageTextStyle: theme.heading6.override(color: Colors.white),
          ),
          dateButtonsSettings: PickerDateButtonsSettings(
            buttonBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusChip)),
            selectedMonthBackgroundColor: theme.primary,
            unselectedMonthsTextColor: theme.primaryText,
            currentMonthTextColor: theme.primary,
          ),
          dialogSettings: PickerDialogSettings(
            scrollAnimationMilliseconds: 0,
            dialogBackgroundColor: theme.secondaryBackground,
            locale: const Locale('it', 'IT'),
            dialogRoundedCornersRadius: Sizes.radiusControl,
          ),
        ),
      );

  /// Picker giorno **in-theme**: popover ancorato al campo con [CLCalendar]
  /// (ShadCalendar sotto), al posto del dialog Material. Ritorna la data scelta
  /// (tap giorno → chiude) o `null` se si tocca fuori. La scrittura mascherata
  /// nel campo resta il percorso alternativo.
  Future<DateTime?> _showDatePicker(BuildContext context, CLTheme theme) {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Future<DateTime?>.value(null);

    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.of(context).size;
    const gap = 4.0;
    const estH = 360.0;
    const popW = 288.0;
    final spaceBelow = screen.height - (offset.dy + size.height + gap);
    final openUp = spaceBelow < estH && offset.dy - gap > spaceBelow;
    final left = offset.dx.clamp(8.0, (screen.width - popW - 8).clamp(8.0, double.infinity));

    final completer = Completer<DateTime?>();
    late OverlayEntry entry;
    var done = false;
    void finish(DateTime? d) {
      if (done) return;
      done = true;
      entry.remove();
      if (!completer.isCompleted) completer.complete(d);
    }

    entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => finish(null),
            ),
          ),
          Positioned(
            left: left,
            top: openUp ? null : offset.dy + size.height + gap,
            bottom: openUp ? screen.height - offset.dy + gap : null,
            child: CLPopupSurface(
              animateUpward: openUp,
              padding: EdgeInsets.all(theme.gapMd),
              child: SizedBox(
                width: 280,
                child: CLCalendar(
                  selected: w.initialSelectedDateTime,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(DateTime.now().year + 100),
                  onChanged: finish,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
    return completer.future;
  }

  Widget _actionBtn(BuildContext ctx, String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.gapXl, vertical: Sizes.gapLg),
        margin: const EdgeInsets.symmetric(vertical: Sizes.gapSm),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Sizes.radiusControl)),
        child: Text(label,
            style: CLTheme.of(ctx).bodyText.copyWith(color: fg, fontWeight: FontWeight.w500)),
      );
}
