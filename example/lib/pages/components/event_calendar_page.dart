import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

/// Showcase di [GenEventCalendar] (custom Gen: event-calendar a 4 viste con
/// dialog di editing integrata). Occupa tutta l'altezza disponibile, quindi qui
/// NON usa il DemoPage scrollabile ma un layout a piena pagina.
class EventCalendarShowcase extends StatefulWidget {
  const EventCalendarShowcase({super.key});

  @override
  State<EventCalendarShowcase> createState() => _EventCalendarShowcaseState();
}

class _EventCalendarShowcaseState extends State<EventCalendarShowcase> {
  static const _c = GenEventCalendar.defaultColors; // [blue, amber, violet, rose, green, orange]

  late final List<GenCalendarEvent> _events = _seed();

  static List<GenCalendarEvent> _seed() {
    DateTime at(int day, int h, int m) => DateTime(2026, 7, day, h, m);
    return [
      GenCalendarEvent(
        id: '1',
        title: 'Team Meeting',
        description: 'Weekly team sync',
        location: 'Conference Room A',
        start: at(15, 10, 0),
        end: at(15, 11, 0),
        color: _c[0],
      ),
      GenCalendarEvent(
        id: '2',
        title: 'Lunch with Client',
        description: 'Discuss new project requirements',
        location: 'Downtown Cafe',
        start: at(16, 12, 0),
        end: at(16, 13, 15),
        color: _c[4],
      ),
      GenCalendarEvent(
        id: '3',
        title: 'Product Launch',
        description: 'New product release',
        start: DateTime(2026, 7, 18),
        end: DateTime(2026, 7, 18),
        allDay: true,
        color: _c[2],
      ),
      GenCalendarEvent(
        id: '4',
        title: 'Sales Conference',
        description: 'Discuss about new clients',
        location: 'Downtown Cafe',
        start: at(19, 14, 30),
        end: at(19, 14, 45),
        color: _c[3],
      ),
      GenCalendarEvent(
        id: '5',
        title: 'Team Meeting',
        description: 'Weekly team sync',
        location: 'Conference Room A',
        start: at(20, 9, 0),
        end: at(20, 10, 30),
        color: _c[1],
      ),
      GenCalendarEvent(
        id: '6',
        title: 'Marketing Strategy Session',
        start: at(24, 10, 0),
        end: at(24, 11, 30),
        color: _c[4],
      ),
      GenCalendarEvent(
        id: '7',
        title: 'Quarterly Budget Review',
        start: DateTime(2026, 7, 2),
        end: DateTime(2026, 7, 2),
        allDay: true,
        color: _c[5],
      ),
      GenCalendarEvent(
        id: '8',
        title: 'Project Deadline',
        start: at(6, 13, 0),
        end: at(6, 14, 0),
        color: _c[1],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => Builder(
        // L'inset (clearance header + gutter) è iniettato dallo shell a valle:
        // va letto alla posizione MONTATA, come fa DemoPage.
        builder: (context) {
          // Lo shell inietta già un gutter gapLg su top/bottom. Il respiro extra
          // serve solo su desktop, dove la toolbar è in-page e non deve leggere
          // "attaccata" all'header frosted. Su mobile la toolbar è hoisted nello
          // shell → l'extra sarebbe solo doppio padding.
          final compact = MediaQuery.sizeOf(context).width < 600;
          return Padding(
            padding: MediaQuery.paddingOf(context) +
                EdgeInsets.symmetric(vertical: compact ? 0 : GenSizes.gapLg),
            child: GenEventCalendar(
              events: _events,
              initialDate: DateTime(2026, 7, 15),
            ),
          );
        },
      );
}
