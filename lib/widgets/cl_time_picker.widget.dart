import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show TimeOfDay, DayPeriod;
// Budella Shad: nucleo interno = ShadTimePicker reale (campi ora/minuti[/secondi]
// [/AM-PM] nativi). Solo i simboli usati (show). API CL su `TimeOfDay` (tipo
// usato dall'app). Tono dai colori CL via il bridge ShadTheme.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadTimePicker, ShadTimeOfDay, ShadDayPeriod;

/// Time picker **in-theme** (shadcn `ShadTimePicker`): input a campi segmentati
/// (ore/minuti, opzionali secondi e periodo AM/PM). Emette [TimeOfDay].
///
/// Nota: UX a campi (non il clock-dialog di Material `showTimePicker`).
class CLTimePicker extends StatelessWidget {
  const CLTimePicker({
    super.key,
    this.initial,
    this.onChanged,
    this.use24h = true,
    this.showSeconds = false,
    this.fieldWidth,
  });

  /// Ora iniziale.
  final TimeOfDay? initial;

  /// Notificato a ogni cambio (ore/minuti[/secondi][/periodo]).
  final ValueChanged<TimeOfDay>? onChanged;

  /// `true` (default) = 24h; `false` = 12h con selettore AM/PM.
  final bool use24h;

  /// Mostra anche il campo secondi (default `false`).
  final bool showSeconds;

  /// Larghezza dei singoli campi.
  final double? fieldWidth;

  ShadTimeOfDay? get _initial => initial == null
      ? null
      : ShadTimeOfDay(hour: initial!.hour, minute: initial!.minute, second: 0);

  void _emit(ShadTimeOfDay t) =>
      onChanged?.call(TimeOfDay(hour: t.hour, minute: t.minute));

  @override
  Widget build(BuildContext context) {
    if (use24h) {
      return ShadTimePicker(
        initialValue: _initial,
        onChanged: _emit,
        showSeconds: showSeconds,
        fieldWidth: fieldWidth,
        hourLabel: const Text('Ore'),
        minuteLabel: const Text('Minuti'),
        secondLabel: const Text('Secondi'),
      );
    }
    return ShadTimePicker.period(
      initialValue: _initial,
      onChanged: _emit,
      showSeconds: showSeconds,
      fieldWidth: fieldWidth,
      initialDayPeriod: (initial != null && initial!.period == DayPeriod.pm)
          ? ShadDayPeriod.pm
          : ShadDayPeriod.am,
      hourLabel: const Text('Ore'),
      minuteLabel: const Text('Minuti'),
      secondLabel: const Text('Secondi'),
      periodLabel: const Text('AM/PM'),
    );
  }
}
