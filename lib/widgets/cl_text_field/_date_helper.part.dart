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
                _actionBtn(context, 'Annulla', theme.danger.withAlpha(26), theme.danger),
          ),
          headerSettings: PickerHeaderSettings(
            headerBackgroundColor: theme.primary,
            headerCurrentPageTextStyle: theme.heading6.override(color: Colors.white),
          ),
          dateButtonsSettings: PickerDateButtonsSettings(
            buttonBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
            selectedMonthBackgroundColor: theme.primary,
            unselectedMonthsTextColor: theme.primaryText,
            currentMonthTextColor: theme.primary,
          ),
          dialogSettings: PickerDialogSettings(
            scrollAnimationMilliseconds: 0,
            dialogBackgroundColor: theme.secondaryBackground,
            locale: const Locale('it', 'IT'),
            dialogRoundedCornersRadius: Sizes.borderRadius,
          ),
        ),
      );

  Future<DateTime?> _showDatePicker(BuildContext context, CLTheme theme) => showDatePicker(
        locale: const Locale('it', 'IT'),
        context: context,
        initialDate: w.initialSelectedDateTime ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(DateTime.now().year + 100),
        builder: (ctx, child) => Theme(data: _datePickerTheme(ctx, theme), child: child!),
      );

  ThemeData _datePickerTheme(BuildContext ctx, CLTheme theme) => Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: theme.primary,
          onPrimary: Colors.white,
          onSurface: theme.primaryText,
          surface: theme.secondaryBackground,
        ),
        dialogBackgroundColor: theme.secondaryBackground,
        datePickerTheme: DatePickerThemeData(
          backgroundColor: theme.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
          headerBackgroundColor: theme.primary,
          headerForegroundColor: Colors.white,
          dayStyle: theme.bodyText,
          yearStyle: theme.bodyText,
          dayForegroundColor: WidgetStateColor.resolveWith(
              (st) => st.contains(WidgetState.selected) ? Colors.white : theme.primaryText),
          dayBackgroundColor: WidgetStateColor.resolveWith(
              (st) => st.contains(WidgetState.selected) ? theme.primary : Colors.transparent),
          todayBackgroundColor: WidgetStateColor.resolveWith((st) =>
              st.contains(WidgetState.selected) ? theme.primary : theme.primary.withAlpha(26)),
          todayForegroundColor: WidgetStateColor.resolveWith(
              (st) => st.contains(WidgetState.selected) ? Colors.white : theme.primary),
          cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.danger)),
          confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.primary)),
        ),
      );

  Widget _actionBtn(BuildContext ctx, String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.small),
        margin: const EdgeInsets.symmetric(vertical: Sizes.small / 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
        child: Text(label,
            style: CLTheme.of(ctx).bodyText.copyWith(color: fg, fontWeight: FontWeight.w500)),
      );
}
