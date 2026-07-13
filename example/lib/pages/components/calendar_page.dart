import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenCalendar] (=GenCalendar): variante single,
/// multiple (con min/max), range (con min/max giorni), giorni disabilitati via
/// selectableDayPredicate, limiti fromMonth/toMonth, caption layout (label /
/// dropdown / dropdownMonths / dropdownYears), settimane (weekStartsOn,
/// showWeekNumbers, fixedWeeks, showOutsideDays) e più mesi affiancati.
/// Interattivo: la pagina possiede selezione single/multiple/range.
class CalendarShowcase extends StatefulWidget {
  const CalendarShowcase({super.key});

  @override
  State<CalendarShowcase> createState() => _CalendarShowcaseState();
}

class _CalendarShowcaseState extends State<CalendarShowcase> {
  DateTime? _single;
  List<DateTime> _multiple = [];
  GenDateTimeRange? _range;
  GenDateTimeRange? _rangeBounded;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final now = DateTime.now();

    // Box contenitore: il calendario ha larghezza propria (monthConstraints
    // default maxWidth 252 per mese), quindi basta un box abbastanza ampio.
    Widget box(Widget child) =>
        SizedBox(width: 300, child: Align(alignment: Alignment.topLeft, child: child));

    Widget boxWide(Widget child) =>
        SizedBox(width: 560, child: Align(alignment: Alignment.topLeft, child: child));

    return DemoPage(
      children: [
        DemoGroup(
          title: 'Single',
          description:
              'Costruttore default: selezione di una singola data. allowDeselection consente di annullare.',
          items: [
            DemoTile(
              width: 320,
              label: 'base',
              child: box(
                GenCalendar(
                  selected: _single,
                  onChanged: (d) => setState(() => _single = d),
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'allowDeselection + selezione iniziale',
              child: box(
                GenCalendar(
                  selected: _single ?? now,
                  allowDeselection: true,
                  onChanged: (d) => setState(() => _single = d),
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Multiple',
          description:
              'GenCalendar.multiple: selezione di più date. min/max limitano il numero selezionabile.',
          items: [
            DemoTile(
              width: 320,
              label: 'multiple',
              child: box(
                GenCalendar.multiple(
                  selected: _multiple,
                  onChanged: (dates) => setState(() => _multiple = dates),
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'multiple con max: 3',
              child: box(
                GenCalendar.multiple(
                  max: 3,
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Range',
          description:
              'GenCalendar.range: selezione di un intervallo. min/max vincolano la lunghezza in giorni.',
          items: [
            DemoTile(
              width: 320,
              label: 'range',
              child: box(
                GenCalendar.range(
                  selected: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'range min: 2, max: 7 giorni',
              child: box(
                GenCalendar.range(
                  selected: _rangeBounded,
                  min: 2,
                  max: 7,
                  onChanged: (r) => setState(() => _rangeBounded = r),
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Giorni disabilitati & limiti',
          description:
              'selectableDayPredicate disabilita giorni (qui i weekend); fromMonth/toMonth limitano i mesi navigabili.',
          items: [
            DemoTile(
              width: 320,
              label: 'weekend disabilitati',
              child: box(
                GenCalendar(
                  selectableDayPredicate: (day) =>
                      day.weekday != DateTime.saturday &&
                      day.weekday != DateTime.sunday,
                  onChanged: (_) {},
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'fromMonth / toMonth (anno corrente)',
              child: box(
                GenCalendar(
                  fromMonth: DateTime(now.year, 1),
                  toMonth: DateTime(now.year, 12),
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Caption layout',
          description:
              'captionLayout: label (default), dropdown (mese+anno), dropdownMonths, dropdownYears.',
          items: [
            DemoTile(
              width: 320,
              label: 'dropdown (mese + anno)',
              child: box(
                GenCalendar(
                  captionLayout: GenCalendarCaptionLayout.dropdown,
                  onChanged: (_) {},
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'dropdownMonths',
              child: box(
                GenCalendar(
                  captionLayout: GenCalendarCaptionLayout.dropdownMonths,
                  onChanged: (_) {},
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'dropdownYears',
              child: box(
                GenCalendar(
                  captionLayout: GenCalendarCaptionLayout.dropdownYears,
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Settimane',
          description:
              'weekStartsOn (1=lunedì), showWeekNumbers, fixedWeeks (6 settimane fisse), showOutsideDays, hideWeekdayNames.',
          items: [
            DemoTile(
              width: 320,
              label: 'weekStartsOn: 7 (domenica) + numeri settimana',
              child: box(
                GenCalendar(
                  weekStartsOn: 7,
                  showWeekNumbers: true,
                  onChanged: (_) {},
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'fixedWeeks + showOutsideDays',
              child: box(
                GenCalendar(
                  fixedWeeks: true,
                  showOutsideDays: true,
                  onChanged: (_) {},
                ),
              ),
            ),
            DemoTile(
              width: 320,
              label: 'hideWeekdayNames + showOutsideDays: false',
              child: box(
                GenCalendar(
                  hideWeekdayNames: true,
                  showOutsideDays: false,
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Più mesi',
          description:
              'numberOfMonths affianca più mesi; reverseMonths inverte l\'ordine.',
          items: [
            DemoTile(
              width: 580,
              label: 'numberOfMonths: 2',
              child: boxWide(
                GenCalendar(
                  numberOfMonths: 2,
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Selezione corrente',
          description: 'Riepilogo dello stato posseduto dalla pagina.',
          items: [
            DemoTile(
              width: 560,
              label: 'stato',
              child: Text(
                'single: ${_single ?? '—'}\n'
                'multiple: ${_multiple.length} date\n'
                'range: ${_range?.start ?? '—'} → ${_range?.end ?? '—'}',
                style: t.smallText.copyWith(color: t.secondaryText),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
