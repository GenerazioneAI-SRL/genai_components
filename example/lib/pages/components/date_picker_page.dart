import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenDatePicker] (=GenDatePicker): variante single
/// (base, formato custom, placeholder, deselezione, closeOnSelection, caption
/// dropdown, fromMonth/toMonth, disabled) e variante range (base + formato
/// custom). Interattivo: la pagina possiede la data / il range selezionati.
class DatePickerShowcase extends StatefulWidget {
  const DatePickerShowcase({super.key});

  @override
  State<DatePickerShowcase> createState() => _DatePickerShowcaseState();
}

class _DatePickerShowcaseState extends State<DatePickerShowcase> {
  DateTime? _single;
  DateTime? _singleFormatted;
  DateTime? _singleDeselect;
  DateTime? _singleClose;
  DateTime? _singleDropdown;
  DateTime? _singleBounded;
  GenDateTimeRange? _range;
  GenDateTimeRange? _rangeFormatted;

  static const _months = [
    'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
    'lug', 'ago', 'set', 'ott', 'nov', 'dic',
  ];

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  String _fmtRange(GenDateTimeRange r) {
    if (r.start == null) return '';
    final start = _fmt(r.start!);
    if (r.end == null) return start;
    return '$start  →  ${_fmt(r.end!)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final now = DateTime.now();

    return DemoPage(
      children: [
        DemoGroup(
          title: 'Single — base',
          description:
              'Costruttore default: selected + onChanged + placeholder. Bottone outline con icona calendario, popover con calendario single.',
          items: [
            DemoTile(
              width: 300,
              label: 'placeholder + onChanged',
              child: GenDatePicker(
                selected: _single,
                placeholder: const Text('Seleziona una data'),
                onChanged: (d) => setState(() => _single = d),
              ),
            ),
            DemoTile(
              width: 300,
              label: 'selezione iniziale = oggi',
              child: GenDatePicker(
                selected: now,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Formato & placeholder',
          description:
              'formatDate personalizza il testo della data selezionata; placeholder personalizzato con icona.',
          items: [
            DemoTile(
              width: 300,
              label: 'formatDate custom (dd mmm yyyy)',
              child: GenDatePicker(
                selected: _singleFormatted,
                formatDate: _fmt,
                placeholder: const Text('gg mmm aaaa'),
                onChanged: (d) => setState(() => _singleFormatted = d),
              ),
            ),
            DemoTile(
              width: 300,
              label: 'placeholder con icona + iconData custom',
              child: GenDatePicker(
                selected: _single,
                iconData: LucideIcons.calendarDays,
                placeholder: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.info, size: 14, color: t.secondaryText),
                    const SizedBox(width: 6),
                    const Text('Data evento'),
                  ],
                ),
                onChanged: (d) => setState(() => _single = d),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Comportamento selezione',
          description:
              'allowDeselection consente di annullare toccando di nuovo il giorno; closeOnSelection chiude il popover appena scelta la data.',
          items: [
            DemoTile(
              width: 300,
              label: 'allowDeselection: true',
              child: GenDatePicker(
                selected: _singleDeselect,
                allowDeselection: true,
                placeholder: const Text('Tocca due volte per annullare'),
                onChanged: (d) => setState(() => _singleDeselect = d),
              ),
            ),
            DemoTile(
              width: 300,
              label: 'closeOnSelection: true',
              child: GenDatePicker(
                selected: _singleClose,
                closeOnSelection: true,
                placeholder: const Text('Chiude alla selezione'),
                onChanged: (d) => setState(() => _singleClose = d),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Caption dropdown & limiti',
          description:
              'captionLayout mostra i menu a tendina di mese/anno; fromMonth/toMonth limitano la navigazione.',
          items: [
            DemoTile(
              width: 300,
              label: 'captionLayout: dropdown',
              child: GenDatePicker(
                selected: _singleDropdown,
                captionLayout: GenCalendarCaptionLayout.dropdown,
                placeholder: const Text('Con dropdown mese/anno'),
                onChanged: (d) => setState(() => _singleDropdown = d),
              ),
            ),
            DemoTile(
              width: 300,
              label: 'fromMonth / toMonth (anno corrente)',
              child: GenDatePicker(
                selected: _singleBounded,
                fromMonth: DateTime(now.year, 1),
                toMonth: DateTime(now.year, 12),
                captionLayout: GenCalendarCaptionLayout.dropdownMonths,
                placeholder: const Text('Solo anno corrente'),
                onChanged: (d) => setState(() => _singleBounded = d),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Disabilitato',
          description: 'enabled: false — bottone non interagibile.',
          items: [
            DemoTile(
              width: 300,
              label: 'enabled: false',
              child: GenDatePicker(
                enabled: false,
                placeholder: const Text('Non interagibile'),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Range',
          description:
              'GenDatePicker.range: selezione di un intervallo. selected è uno GenDateTimeRange, onRangeChanged riporta start/end.',
          items: [
            DemoTile(
              width: 320,
              label: 'range base',
              child: GenDatePicker.range(
                selected: _range,
                placeholder: const Text('Seleziona intervallo'),
                onRangeChanged: (r) => setState(() => _range = r),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'range con formatDateRange custom',
              child: GenDatePicker.range(
                selected: _rangeFormatted,
                formatDateRange: _fmtRange,
                placeholder: const Text('Check-in → Check-out'),
                onRangeChanged: (r) => setState(() => _rangeFormatted = r),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
