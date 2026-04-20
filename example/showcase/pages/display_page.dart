import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  late List<GenaiKanbanColumn<_Task>> _columns;
  late GenaiTableController<_Customer> _tableController;
  String? _selectedTreeValue = 'invoice-2';

  @override
  void initState() {
    super.initState();
    _columns = [
      GenaiKanbanColumn(id: 'todo', title: 'Da fare', items: const [
        _Task('Riunione settimanale', 'Standup team'),
        _Task('Ordine fornitori', 'Q3 ricarico'),
      ]),
      GenaiKanbanColumn(id: 'doing', title: 'In corso', accent: const Color(0xFFF59E0B), items: const [
        _Task('Refactor auth', 'Fix flusso login'),
      ]),
      GenaiKanbanColumn(id: 'done', title: 'Completato', accent: const Color(0xFF10B981), items: const [
        _Task('Setup CI', 'GitHub Actions OK'),
      ]),
    ];
    _tableController = GenaiTableController<_Customer>();
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<GenaiPageResponse<_Customer>> _fetch(GenaiPageRequest req) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final all = List.generate(
        47,
        (i) => _Customer(
              id: i + 1,
              name: 'Cliente ${i + 1}',
              city: ['Milano', 'Roma', 'Torino', 'Napoli'][i % 4],
              revenue: 1000 + (i * 137.5),
              status: ['attivo', 'sospeso', 'lead'][i % 3],
            ));
    final search = req.search.toLowerCase();
    final filtered = search.isEmpty ? all : all.where((c) => c.name.toLowerCase().contains(search) || c.city.toLowerCase().contains(search)).toList();
    final page = (req.pageKey as int?) ?? 0;
    final start = page * req.pageSize;
    final end = (start + req.pageSize).clamp(0, filtered.length);
    return GenaiPageResponse<_Customer>(
      items: filtered.sublist(start, end),
      nextPageKey: end < filtered.length ? page + 1 : null,
      totalItems: filtered.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Display',
      description: 'List · KPICard · Timeline · Calendar · Kanban · TreeView · Table.',
      children: [
        ShowcaseSection(
          title: 'GenaiList & GenaiListItem',
          child: SizedBox(
            width: 480,
            child: GenaiList(
              bordered: true,
              showDividers: true,
              children: [
                GenaiListItem(
                  leading: GenaiAvatar.initials(name: 'Mario Rossi'),
                  title: 'Mario Rossi',
                  subtitle: 'mario.rossi@example.com',
                  trailing: GenaiBadge.text(text: 'Pro'),
                  onTap: () {},
                ),
                GenaiListItem(
                  leading: GenaiAvatar.initials(name: 'Luca Bianchi'),
                  title: 'Luca Bianchi',
                  subtitle: 'luca@example.com',
                  isSelected: true,
                  onTap: () {},
                ),
                GenaiListItem(
                  leading: GenaiAvatar.initials(name: 'Anna Verdi'),
                  title: 'Anna Verdi',
                  description: 'Account creato 3 giorni fa',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiKPICard',
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            GenaiKPICard(
              label: 'Fatturato',
              value: '128.450',
              unit: '€',
              icon: LucideIcons.euro,
              trendPercentage: 12.3,
              trendLabel: 'vs mese scorso',
            ),
            GenaiKPICard(
              label: 'Nuovi clienti',
              value: '34',
              icon: LucideIcons.userPlus,
              trendPercentage: -4.0,
              trendLabel: 'vs mese scorso',
              footnote: 'Ultimi 30 giorni',
            ),
            GenaiKPICard(
              label: 'Conversioni',
              value: '8,4',
              unit: '%',
              icon: LucideIcons.target,
              trendPercentage: 0.0,
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'GenaiTrendIndicator + Avatar/Group + Status',
          child: Wrap(spacing: 16, runSpacing: 12, children: [
            const GenaiTrendIndicator(percentage: 12.3),
            const GenaiTrendIndicator(percentage: -7.0),
            const GenaiTrendIndicator(percentage: 0),
            GenaiAvatar.initials(name: 'Mario Rossi'),
            GenaiAvatar.placeholder(),
            GenaiAvatarGroup(
              avatars: [
                GenaiAvatar.initials(name: 'AB'),
                GenaiAvatar.initials(name: 'CD'),
                GenaiAvatar.initials(name: 'EF'),
                GenaiAvatar.initials(name: 'GH'),
                GenaiAvatar.initials(name: 'IJ'),
              ],
              maxVisible: 3,
            ),
            const GenaiStatusBadge(label: 'Attivo', status: GenaiStatusType.active),
            const GenaiStatusBadge(label: 'In attesa', status: GenaiStatusType.pending),
            const GenaiStatusBadge(label: 'Errore', status: GenaiStatusType.error),
          ]),
        ),
        ShowcaseSection(
          title: 'GenaiTimeline',
          child: SizedBox(
            width: 520,
            child: GenaiTimeline(
              items: [
                GenaiTimelineItem(
                  title: 'Ordine creato',
                  subtitle: 'Mario Rossi',
                  description: 'Ordine #1234 da 350 €',
                  timestamp: DateTime.now().subtract(const Duration(hours: 3)),
                  icon: LucideIcons.fileText,
                ),
                GenaiTimelineItem(
                  title: 'Pagamento ricevuto',
                  description: 'Bonifico bancario',
                  timestamp: DateTime.now().subtract(const Duration(hours: 1)),
                  icon: LucideIcons.creditCard,
                  iconColor: const Color(0xFF10B981),
                ),
                GenaiTimelineItem(
                  title: 'Spedizione',
                  description: 'Consegna prevista 22/04',
                  timestamp: DateTime.now(),
                  icon: LucideIcons.truck,
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCalendar',
          child: SizedBox(
            height: 460,
            child: GenaiCalendar(
              initialDate: DateTime.now(),
              events: [
                GenaiCalendarEvent(
                  start: DateTime.now(),
                  end: DateTime.now().add(const Duration(hours: 2)),
                  title: 'Riunione team',
                ),
                GenaiCalendarEvent(
                  start: DateTime.now().add(const Duration(days: 2)),
                  end: DateTime.now().add(const Duration(days: 2, hours: 1)),
                  title: 'Demo cliente',
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiKanban',
          child: SizedBox(
            height: 360,
            child: GenaiKanban<_Task>(
              columns: _columns,
              cardBuilder: (ctx, task) => GenaiCard.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: ctx.typography.label.copyWith(color: ctx.colors.textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(task.description, style: ctx.typography.caption.copyWith(color: ctx.colors.textSecondary)),
                    ],
                  ),
                ),
              ),
              onReorder: (item, from, to) {
                if (from == to) return;
                setState(() {
                  _columns = _columns.map((c) {
                    if (c.id == from) {
                      return c.copyWith(items: c.items.where((i) => i != item).toList());
                    }
                    if (c.id == to) {
                      return c.copyWith(items: [...c.items, item]);
                    }
                    return c;
                  }).toList();
                });
              },
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTreeView',
          child: SizedBox(
            width: 360,
            child: GenaiCard.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GenaiTreeView<String>(
                  selectedValue: _selectedTreeValue,
                  onNodeTap: (v) => setState(() => _selectedTreeValue = v),
                  nodes: const [
                    GenaiTreeNode(
                      value: 'docs',
                      label: 'Documenti',
                      icon: LucideIcons.folder,
                      initiallyExpanded: true,
                      children: [
                        GenaiTreeNode(value: 'invoices', label: 'Fatture', icon: LucideIcons.folder, initiallyExpanded: true, children: [
                          GenaiTreeNode(value: 'invoice-1', label: 'F-2026-001.pdf', icon: LucideIcons.fileText),
                          GenaiTreeNode(value: 'invoice-2', label: 'F-2026-002.pdf', icon: LucideIcons.fileText),
                        ]),
                        GenaiTreeNode(value: 'contracts', label: 'Contratti', icon: LucideIcons.folder),
                      ],
                    ),
                    GenaiTreeNode(value: 'media', label: 'Media', icon: LucideIcons.image),
                  ],
                ),
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTable<T>',
          subtitle: 'Paginazione, sort, filtri, ricerca, densità e responsive: tutto in un unico widget tipato.',
          child: SizedBox(
            height: 560,
            child: GenaiCard.outlined(
              child: GenaiTable<_Customer>(
                controller: _tableController,
                fetcher: _fetch,
                rowKey: (c) => c.id,
                title: 'Clienti',
                description: 'Elenco completo (mock data)',
                searchable: true,
                selectable: true,
                filters: const [
                  GenaiOptionsFilter<String>(
                    id: 'status',
                    label: 'Stato',
                    options: [
                      GenaiSelectOption(value: 'attivo', label: 'Attivo'),
                      GenaiSelectOption(value: 'sospeso', label: 'Sospeso'),
                      GenaiSelectOption(value: 'lead', label: 'Lead'),
                    ],
                  ),
                ],
                columns: [
                  GenaiColumn<_Customer>(
                    id: 'name',
                    title: 'Nome',
                    sortable: true,
                    cellBuilder: (ctx, c) => Text(c.name, style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary)),
                  ),
                  GenaiColumn<_Customer>(
                    id: 'city',
                    title: 'Città',
                    cellBuilder: (ctx, c) => Text(c.city, style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textSecondary)),
                  ),
                  GenaiColumn<_Customer>(
                    id: 'revenue',
                    title: 'Fatturato',
                    sortable: true,
                    align: GenaiColumnAlignment.end,
                    cellBuilder: (ctx, c) =>
                        Text(GenaiFormatters.currency(c.revenue), style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary)),
                  ),
                  GenaiColumn<_Customer>(
                    id: 'status',
                    title: 'Stato',
                    cellBuilder: (ctx, c) => GenaiStatusBadge(
                      label: c.status,
                      status: switch (c.status) {
                        'attivo' => GenaiStatusType.active,
                        'sospeso' => GenaiStatusType.warning,
                        _ => GenaiStatusType.info,
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiBarChart',
          subtitle: 'Bar chart basato su fl_chart, integrato con i token Genai.',
          child: SizedBox(
            height: 280,
            child: GenaiCard.outlined(
              child: GenaiBarChart<_BarPoint>(
                data: const [
                  _BarPoint('Gen', 12000),
                  _BarPoint('Feb', 18500),
                  _BarPoint('Mar', 14200),
                  _BarPoint('Apr', 22100),
                  _BarPoint('Mag', 19800),
                  _BarPoint('Giu', 25400),
                ],
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.value,
                showGrid: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarPoint {
  final String label;
  final double value;
  const _BarPoint(this.label, this.value);
}

class _Task {
  final String title;
  final String description;
  const _Task(this.title, this.description);
}

class _Customer {
  final int id;
  final String name;
  final String city;
  final double revenue;
  final String status;
  const _Customer({
    required this.id,
    required this.name,
    required this.city,
    required this.revenue,
    required this.status,
  });
}
