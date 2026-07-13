import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenTimePicker] (=GenTimePicker): variante primary
/// (24h), variante period (12h con AM/PM), campi visibili configurabili
/// (showHours/showMinutes/showSeconds), label/placeholder custom, min/max per
/// campo, asse verticale, disabled. Interattivo: la pagina mostra il valore
/// [GenTimeOfDay] corrente sotto ogni picker.
class TimePickerShowcase extends StatefulWidget {
  const TimePickerShowcase({super.key});

  @override
  State<TimePickerShowcase> createState() => _TimePickerShowcaseState();
}

class _TimePickerShowcaseState extends State<TimePickerShowcase> {
  GenTimeOfDay? _primary;
  GenTimeOfDay? _period;
  GenTimeOfDay? _hoursMinutes;
  GenTimeOfDay? _labels;
  GenTimeOfDay? _bounded;
  GenTimeOfDay? _vertical;

  String _fmt(GenTimeOfDay? v) {
    if (v == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    final base = '${two(v.hour)}:${two(v.minute)}:${two(v.second)}';
    return '$base ${v.period.name.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    Widget readout(GenTimeOfDay? v) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Valore: ${_fmt(v)}',
              style: t.smallText.copyWith(color: t.secondaryText)),
        );

    return DemoPage(
      children: [
        DemoGroup(
          title: 'Primary — 24h',
          description:
              'Costruttore default: tre campi (ore/minuti/secondi) in formato 24 ore. onChanged riporta uno GenTimeOfDay.',
          items: [
            DemoTile(
              width: 320,
              label: 'base',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenTimePicker(
                    onChanged: (v) => setState(() => _primary = v),
                  ),
                  readout(_primary),
                ],
              ),
            ),
            DemoTile(
              width: 320,
              label: 'initialValue = adesso',
              child: GenTimePicker(
                initialValue: GenTimeOfDay.now(),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Period — 12h AM/PM',
          description:
              'GenTimePicker.period: formato 12 ore con selettore AM/PM. initialDayPeriod imposta il periodo iniziale.',
          items: [
            DemoTile(
              width: 380,
              label: 'period + initialDayPeriod: pm',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenTimePicker.period(
                    initialDayPeriod: GenDayPeriod.pm,
                    onChanged: (v) => setState(() => _period = v),
                  ),
                  readout(_period),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Campi visibili',
          description:
              'showHours / showMinutes / showSeconds nascondono i singoli campi. Qui: solo ore e minuti.',
          items: [
            DemoTile(
              width: 320,
              label: 'showSeconds: false',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenTimePicker(
                    showSeconds: false,
                    onChanged: (v) => setState(() => _hoursMinutes = v),
                  ),
                  readout(_hoursMinutes),
                ],
              ),
            ),
            DemoTile(
              width: 200,
              label: 'solo ore (showMinutes/showSeconds: false)',
              child: GenTimePicker(
                showMinutes: false,
                showSeconds: false,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Label & placeholder custom',
          description:
              'hourLabel/minuteLabel/secondLabel e i rispettivi placeholder personalizzano testi e suggerimenti dei campi.',
          items: [
            DemoTile(
              width: 320,
              label: 'label + placeholder personalizzati',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenTimePicker(
                    hourLabel: const Text('Ore'),
                    minuteLabel: const Text('Min'),
                    secondLabel: const Text('Sec'),
                    hourPlaceholder: const Text('hh'),
                    minutePlaceholder: const Text('mm'),
                    secondPlaceholder: const Text('ss'),
                    onChanged: (v) => setState(() => _labels = v),
                  ),
                  readout(_labels),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Limiti per campo',
          description:
              'minHour/maxHour, minMinute/maxMinute, minSecond/maxSecond vincolano i valori accettati da ogni campo.',
          items: [
            DemoTile(
              width: 320,
              label: 'ore 8–18, minuti step liberi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenTimePicker(
                    minHour: 8,
                    maxHour: 18,
                    maxMinute: 59,
                    onChanged: (v) => setState(() => _bounded = v),
                  ),
                  readout(_bounded),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Asse verticale',
          description: 'axis: Axis.vertical impila i campi in colonna.',
          items: [
            DemoTile(
              width: 160,
              label: 'axis: vertical',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenTimePicker(
                    axis: Axis.vertical,
                    onChanged: (v) => setState(() => _vertical = v),
                  ),
                  readout(_vertical),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Disabilitato',
          description: 'enabled: false — campi non interagibili.',
          items: [
            DemoTile(
              width: 320,
              label: 'enabled: false',
              child: GenTimePicker(
                enabled: false,
                initialValue: const GenTimeOfDay(hour: 9, minute: 30, second: 0),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
