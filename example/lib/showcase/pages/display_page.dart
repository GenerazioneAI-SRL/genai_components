import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Display',
      description:
          'KpiCard, Sparkline, BarRow, FocusCard, SuggestionItem, '
          'AgendaRow, FormationCard, List, Timeline, TreeView, Calendar, '
          'Kanban, Carousel.',
      children: [
        ShowcaseSection(
          title: 'KPI card',
          subtitle: 'Metric forward con delta + sparkline.',
          child: Wrap(
            spacing: context.spacing.s14,
            runSpacing: context.spacing.s14,
            children: [
              SizedBox(
                width: 260,
                child: GenaiKpiCard(
                  label: 'Ore settimana',
                  value: '6.5',
                  unit: 'h',
                  delta: 0.30,
                  sparkline: const [3.2, 4.1, 5.0, 3.8, 4.5, 5.2, 6.0, 6.5],
                ),
              ),
              SizedBox(
                width: 260,
                child: GenaiKpiCard(
                  label: 'Corsi completati',
                  value: '18',
                  delta: -0.12,
                  sparkline: const [22, 20, 19, 20, 18, 18, 19, 18],
                ),
              ),
              SizedBox(
                width: 260,
                child: GenaiKpiCard(
                  label: 'Tempo medio',
                  value: '12m',
                  delta: 0.0,
                  sparkline: const [12, 12, 12, 13, 12, 12, 11, 12],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Sparkline',
          subtitle: 'Solo ombra e punto finale.',
          child: ShowcaseRow(
            label: 'samples',
            children: [
              const GenaiSparkline(data: [1, 3, 2, 5, 4, 6, 5, 7]),
              GenaiSparkline(
                data: const [5, 6, 5, 4, 3, 2, 3, 1],
                color: context.colors.colorDanger,
              ),
              GenaiSparkline(
                data: const [1, 2, 3, 4, 5, 6, 7, 8],
                color: context.colors.colorSuccess,
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Bar row',
          subtitle: 'Dashboard primitive per classifiche.',
          child: GenaiCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GenaiBarRow(
                  label: 'Obbligatoria',
                  value: 0.58,
                  valueLabel: '14/24h',
                ),
                GenaiBarRow(
                  label: 'Fondo N.C.',
                  value: 0.53,
                  valueLabel: '32/60h',
                  barColor: context.colors.colorInfo,
                ),
                GenaiBarRow(
                  label: 'Tirocinio',
                  value: 0.0,
                  valueLabel: '0/120h',
                  barColor: context.colors.textTertiary,
                ),
                GenaiBarRow(
                  label: 'Apprendistato',
                  value: 0.22,
                  valueLabel: '18/80h',
                  barColor: context.colors.colorWarning,
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'List',
          subtitle: 'Elenco con dividers opzionali.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.zero,
            useHeaderSlot: false,
            child: GenaiList(
              children: [
                GenaiListItem(
                  leading: Icon(
                    LucideIcons.book,
                    color: context.colors.textSecondary,
                  ),
                  title: 'Sicurezza e guardrail',
                  subtitle: 'Modulo 2 di 4',
                  trailing: GenaiChip.readonly(
                    label: 'In corso',
                    tone: GenaiChipTone.info,
                  ),
                  onTap: () {},
                ),
                GenaiListItem(
                  leading: Icon(
                    LucideIcons.book,
                    color: context.colors.textSecondary,
                  ),
                  title: 'Privacy 2026',
                  subtitle: 'Completato il 14/04',
                  trailing: GenaiChip.readonly(
                    label: 'Completato',
                    tone: GenaiChipTone.ok,
                  ),
                  onTap: () {},
                ),
                GenaiListItem(
                  leading: Icon(
                    LucideIcons.lock,
                    color: context.colors.textTertiary,
                  ),
                  title: 'Antiriciclaggio',
                  subtitle: 'Prerequisiti mancanti',
                  trailing: GenaiChip.readonly(
                    label: 'Bloccato',
                    tone: GenaiChipTone.neutral,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Timeline',
          subtitle: 'Eventi in ordine cronologico.',
          child: GenaiCard.outlined(
            child: GenaiTimeline(
              items: [
                GenaiTimelineItem(
                  icon: LucideIcons.play,
                  title: 'Ripreso corso',
                  subtitle: 'Sicurezza e guardrail',
                  timestamp: DateTime(2026, 4, 24, 9, 15),
                ),
                GenaiTimelineItem(
                  icon: LucideIcons.check,
                  title: 'Completato modulo',
                  subtitle: 'Introduzione',
                  timestamp: DateTime(2026, 4, 23, 17, 40),
                ),
                GenaiTimelineItem(
                  icon: LucideIcons.award,
                  title: 'Certificato emesso',
                  subtitle: 'Privacy 2026',
                  timestamp: DateTime(2026, 4, 20, 12, 0),
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'TreeView',
          subtitle: 'Nodi espandibili per navigazione gerarchica.',
          child: GenaiCard.outlined(
            child: GenaiTreeView<String>(
              nodes: const [
                GenaiTreeNode(
                  value: 'oblig',
                  label: 'Obbligatoria',
                  icon: LucideIcons.shield,
                  initiallyExpanded: true,
                  children: [
                    GenaiTreeNode(value: 'sec', label: 'Sicurezza'),
                    GenaiTreeNode(value: 'pri', label: 'Privacy'),
                    GenaiTreeNode(value: 'aml', label: 'Antiriciclaggio'),
                  ],
                ),
                GenaiTreeNode(
                  value: 'fnc',
                  label: 'Fondo N.C.',
                  icon: LucideIcons.sparkles,
                  children: [
                    GenaiTreeNode(value: 'ai', label: 'AI per il business'),
                    GenaiTreeNode(value: 'cloud', label: 'Cloud computing'),
                  ],
                ),
              ],
              onNodeTap: (_) {},
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Calendar',
          subtitle: 'Mini vista mensile con eventi.',
          child: SizedBox(
            height: 420,
            child: GenaiCalendar(
              view: GenaiCalendarView.month,
              initialDate: DateTime(2026, 4, 24),
              events: [
                GenaiCalendarEvent(
                  start: DateTime(2026, 4, 28, 10),
                  end: DateTime(2026, 4, 28, 12),
                  title: 'Quiz FNC',
                  color: context.colors.colorWarning,
                ),
                GenaiCalendarEvent(
                  start: DateTime(2026, 4, 30, 14, 30),
                  end: DateTime(2026, 4, 30, 16),
                  title: 'Webinar AI',
                  color: context.colors.colorInfo,
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Kanban',
          subtitle: 'Colonne di task draggabili.',
          child: SizedBox(
            height: 280,
            child: GenaiKanban<String>(
              columns: const [
                GenaiKanbanColumn(
                  id: 'todo',
                  title: 'Da iniziare',
                  items: ['Privacy 2026', 'FNC intro'],
                ),
                GenaiKanbanColumn(
                  id: 'doing',
                  title: 'In corso',
                  items: ['Sicurezza', 'AI business'],
                ),
                GenaiKanbanColumn(
                  id: 'done',
                  title: 'Completati',
                  items: ['Onboarding'],
                ),
              ],
              cardBuilder: (ctx, item) => GenaiCard.outlined(
                padding: EdgeInsets.all(ctx.spacing.s12),
                child: Text(
                  item,
                  style: ctx.typography.bodySm.copyWith(
                    color: ctx.colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Carousel',
          subtitle: 'Hero slider con indicatori.',
          child: SizedBox(
            height: 160,
            child: GenaiCarousel(
              items: List.generate(
                4,
                (i) => GenaiCard.outlined(
                  child: Center(
                    child: Text(
                      'Slide ${i + 1}',
                      style: context.typography.cardTitle.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Table',
          subtitle:
              'GenaiTable gestisce sort / filter / pagination '
              '(renderer completo — vedi documentazione).',
          child: GenaiCard.outlined(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.s16),
              child: Text(
                'Il componente GenaiTable richiede un GenaiTableController e '
                'un fetcher async; non incluso nel showcase per brevità.',
                style: context.typography.bodySm.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
