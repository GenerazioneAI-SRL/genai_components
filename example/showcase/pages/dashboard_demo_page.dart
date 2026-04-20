import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class DashboardDemoPage extends StatelessWidget {
  const DashboardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;

    return ShowcaseScaffold(
      title: 'Demo · Dashboard',
      description: 'Composizione completa: KPI, attività recenti, classifica clienti, calendario.',
      children: [
        // KPI row
        Wrap(spacing: 16, runSpacing: 16, children: [
          GenaiKPICard(
            label: 'Fatturato mese',
            value: GenaiFormatters.currency(128450),
            icon: LucideIcons.euro,
            trendPercentage: 12.3,
            trendLabel: 'vs mese scorso',
          ),
          GenaiKPICard(
            label: 'Ordini',
            value: '342',
            icon: LucideIcons.shoppingBag,
            trendPercentage: 7.4,
          ),
          GenaiKPICard(
            label: 'Nuovi clienti',
            value: '34',
            icon: LucideIcons.userPlus,
            trendPercentage: -4.0,
            footnote: 'Ultimi 30 giorni',
          ),
          GenaiKPICard(
            label: 'Conversione',
            value: '8,4',
            unit: '%',
            icon: LucideIcons.target,
            trendPercentage: 0.6,
          ),
        ]),
        const SizedBox(height: 24),
        // Two columns
        LayoutBuilder(builder: (ctx, cs) {
          final wide = cs.maxWidth >= 900;
          final left = SizedBox(
            width: wide ? (cs.maxWidth - 24) * 0.6 : cs.maxWidth,
            child: GenaiCard.outlined(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Attività recenti', style: ty.headingSm.copyWith(color: c.textPrimary)),
                        const Spacer(),
                        GenaiLinkButton(label: 'Vedi tutte', onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GenaiTimeline(items: [
                      GenaiTimelineItem(
                          title: 'Ordine #2451 creato',
                          subtitle: 'Mario Rossi',
                          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
                          icon: LucideIcons.fileText),
                      GenaiTimelineItem(
                          title: 'Pagamento ricevuto',
                          subtitle: 'Bonifico · 1.250 €',
                          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
                          icon: LucideIcons.creditCard,
                          iconColor: const Color(0xFF10B981)),
                      GenaiTimelineItem(
                          title: 'Nuovo cliente registrato',
                          subtitle: 'Anna Verdi',
                          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
                          icon: LucideIcons.userPlus),
                      GenaiTimelineItem(
                          title: 'Ticket aperto #112',
                          subtitle: 'Priorità alta',
                          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
                          icon: LucideIcons.lifeBuoy,
                          iconColor: const Color(0xFFF59E0B)),
                    ]),
                  ],
                ),
              ),
            ),
          );
          final right = SizedBox(
            width: wide ? (cs.maxWidth - 24) * 0.4 : cs.maxWidth,
            child: GenaiCard.outlined(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top clienti', style: ty.headingSm.copyWith(color: c.textPrimary)),
                    const SizedBox(height: 12),
                    GenaiList(
                      showDividers: true,
                      children: [
                        for (final t in const [
                          ('Mario Rossi', 12450.0),
                          ('Luca Bianchi', 9820.0),
                          ('Anna Verdi', 7340.0),
                          ('Paolo Neri', 5210.0),
                        ])
                          GenaiListItem(
                            leading: GenaiAvatar.initials(name: t.$1),
                            title: t.$1,
                            subtitle: 'Fatturato: ${GenaiFormatters.currency(t.$2)}',
                            trailing: const GenaiStatusBadge(label: 'Attivo', status: GenaiStatusType.active),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          return Wrap(spacing: 24, runSpacing: 24, children: [left, right]);
        }),
        const SizedBox(height: 24),
        SizedBox(
          height: 480,
          child: GenaiCard.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Agenda', style: ty.headingSm.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GenaiCalendar(
                      initialDate: DateTime.now(),
                      events: [
                        GenaiCalendarEvent(start: DateTime.now(), end: DateTime.now().add(const Duration(hours: 1)), title: 'Standup'),
                        GenaiCalendarEvent(
                            start: DateTime.now().add(const Duration(days: 1)),
                            end: DateTime.now().add(const Duration(days: 1, hours: 2)),
                            title: 'Demo cliente',
                            color: const Color(0xFFF59E0B)),
                        GenaiCalendarEvent(
                            start: DateTime.now().add(const Duration(days: 3)),
                            end: DateTime.now().add(const Duration(days: 3, hours: 1)),
                            title: 'Review sprint',
                            color: const Color(0xFF10B981)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
