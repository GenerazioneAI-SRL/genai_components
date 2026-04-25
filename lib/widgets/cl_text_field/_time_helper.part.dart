part of '../cl_text_field.widget.dart';

/// Time picker dispatch.
class _TextFieldTimeHelper extends _Helper {
  _TextFieldTimeHelper(super.s);

  Future<TimeOfDay?> show(BuildContext context, CLTheme theme, {bool inputOnly = false}) =>
      showTimePicker(
        context: context,
        initialEntryMode:
            inputOnly ? TimePickerEntryMode.inputOnly : TimePickerEntryMode.dial,
        initialTime: w.initialSelectedTime ??
            (w.initialSelectedDateTime != null
                ? TimeOfDay(
                    hour: w.initialSelectedDateTime!.hour,
                    minute: w.initialSelectedDateTime!.minute)
                : TimeOfDay.now()),
        builder: (ctx, child) => Theme(data: _theme(ctx, theme), child: child!),
      );

  ThemeData _theme(BuildContext ctx, CLTheme theme) => Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: theme.primary,
          onPrimary: Colors.white,
          onSurface: theme.primaryText,
          surface: theme.secondaryBackground,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: theme.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
          hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
          dialBackgroundColor: theme.primary.withAlpha(26),
          dialHandColor: theme.primary,
          dialTextColor: WidgetStateColor.resolveWith(
              (st) => st.contains(WidgetState.selected) ? Colors.white : theme.primaryText),
          hourMinuteTextColor: WidgetStateColor.resolveWith(
              (st) => st.contains(WidgetState.selected) ? Colors.white : theme.primaryText),
          dayPeriodTextColor: theme.primaryText,
          dayPeriodColor: WidgetStateColor.resolveWith((st) => st.contains(WidgetState.selected)
              ? theme.primary.withAlpha(50)
              : Colors.transparent),
          cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.danger)),
          confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(theme.primary)),
        ),
      );
}
