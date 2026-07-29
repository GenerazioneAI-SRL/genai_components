part of 'paged_datatable.dart';

/// Dimensioni fisse del dialog calendario (calendar_date_picker2) — costante di
/// layout, nessun token del design system copre le dimensioni di un dialog.
const Size _kCalendarDialogSize = Size(496.0, 346.0);

class _DateTimePicker extends HookWidget {
  final InputDecoration? decoration;
  final DateTime firstDate, lastDate;
  final DateTime? initialDate;
  final DateFormat? dateFormat;
  final void Function(DateTime? date) onSaved;

  const _DateTimePicker({
    required this.decoration,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onSaved,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    var textController = useTextEditingController();
    var currentValueRef = useRef<DateTime?>(null);
    var dateFormat = useMemoized(() {
      var df = this.dateFormat ?? DateFormat.yMd();
      if (initialDate != null) {
        currentValueRef.value = initialDate;
        textController.text = df.format(currentValueRef.value!);
      }

      return df;
    });

    return CLTextField(
      controller: textController,
      labelText: decoration?.labelText?.toString() ?? 'Seleziona data',
      isReadOnly: true,
      onTap: () async {
        currentValueRef.value = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            calendarType: CalendarDatePicker2Type.single,
            firstDate: firstDate,
            lastDate: lastDate,
            currentDate: initialDate,
          ),
          dialogSize: _kCalendarDialogSize,
        ).then((value) {
          if (value == null) {
            return null;
          }

          return value.first!;
        });

        if (currentValueRef.value != null) {
          textController.text = dateFormat.format(currentValueRef.value!);
          onSaved(currentValueRef.value);
        }
      },
    );
  }
}

class _DateTimeRangePicker extends HookWidget {
  final InputDecoration? decoration;
  final DateTime firstDate, lastDate;
  final DateTimeRange? initialValue;
  final DateFormat? dateFormat;
  final void Function(DateTimeRange? date) onSaved;

  const _DateTimeRangePicker({
    required this.decoration,
    required this.initialValue,
    required this.firstDate,
    required this.lastDate,
    required this.onSaved,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    var textController = useTextEditingController();
    var currentValueRef = useRef<DateTimeRange?>(null);
    var dateFormat = useMemoized(() {
      var df = this.dateFormat ?? DateFormat.yMd();
      if (initialValue != null) {
        currentValueRef.value = initialValue;
        textController.text = _format(df, currentValueRef);
      }

      return df;
    });

    return CLTextField(
      controller: textController,
      labelText: decoration?.labelText?.toString() ?? 'Seleziona periodo',
      isReadOnly: true,
      onTap: () async {
        currentValueRef.value = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            calendarType: CalendarDatePicker2Type.range,
            firstDate: firstDate,
            lastDate: lastDate,
            currentDate: initialValue?.start,
          ),
          dialogSize: _kCalendarDialogSize,
        ).then((value) {
          if (value == null) {
            return null;
          }

          return DateTimeRange(start: value.first!, end: value.last!);
        });

        if (currentValueRef.value != null) {
          textController.text = _format(dateFormat, currentValueRef);
          onSaved(currentValueRef.value);
        }
      },
    );
  }

  String _format(DateFormat dateFormat, ObjectRef<DateTimeRange?> currentValueRef) {
    return "${dateFormat.format(currentValueRef.value!.start)} - ${dateFormat.format(currentValueRef.value!.end)}";
  }
}
