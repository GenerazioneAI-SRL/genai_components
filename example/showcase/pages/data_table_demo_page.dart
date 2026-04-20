import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class DataTableDemoPage extends StatefulWidget {
  const DataTableDemoPage({super.key});

  @override
  State<DataTableDemoPage> createState() => _DataTableDemoPageState();
}

class _DataTableDemoPageState extends State<DataTableDemoPage> {
  final _ctrl = GenaiTableController<_Order>();

  // Mock dataset
  late final List<_Order> _data = List.generate(123, (i) {
    final cities = ['Milano', 'Roma', 'Torino', 'Napoli', 'Bologna'];
    final statuses = ['paid', 'pending', 'cancelled'];
    final customers = ['Mario Rossi', 'Luca Bianchi', 'Anna Verdi', 'Paolo Neri'];
    return _Order(
      id: 1000 + i,
      customer: customers[i % customers.length],
      city: cities[i % cities.length],
      total: 50 + (i * 23.7),
      status: statuses[i % statuses.length],
      date: DateTime.now().subtract(Duration(days: i)),
    );
  });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<GenaiPageResponse<_Order>> _fetch(GenaiPageRequest req) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final search = req.search.toLowerCase();
    final statusFilter = req.filters['status'] as List<String>?;
    var filtered = _data.where((o) {
      if (search.isNotEmpty &&
          !o.customer.toLowerCase().contains(search) &&
          !o.city.toLowerCase().contains(search) &&
          !o.id.toString().contains(search)) {
        return false;
      }
      if (statusFilter != null && statusFilter.isNotEmpty && !statusFilter.contains(o.status)) {
        return false;
      }
      return true;
    }).toList();

    if (req.sort != null) {
      filtered.sort((a, b) {
        int cmp;
        switch (req.sort!.columnId) {
          case 'id':
            cmp = a.id.compareTo(b.id);
            break;
          case 'customer':
            cmp = a.customer.compareTo(b.customer);
            break;
          case 'total':
            cmp = a.total.compareTo(b.total);
            break;
          case 'date':
            cmp = a.date.compareTo(b.date);
            break;
          default:
            cmp = 0;
        }
        return req.sort!.direction == GenaiSortDirection.desc ? -cmp : cmp;
      });
    }

    final page = (req.pageKey as int?) ?? 0;
    final start = page * req.pageSize;
    final end = (start + req.pageSize).clamp(0, filtered.length);
    return GenaiPageResponse<_Order>(
      items: filtered.sublist(start, end),
      nextPageKey: end < filtered.length ? page + 1 : null,
      totalItems: filtered.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Demo · Tabella ordini',
      description: 'GenaiTable<T> con paginazione server-side mock, filtri, sort, ricerca.',
      children: [
        SizedBox(
          height: 720,
          child: GenaiCard.outlined(
            child: GenaiTable<_Order>(
              controller: _ctrl,
              fetcher: _fetch,
              rowKey: (o) => o.id,
              title: 'Ordini',
              description: 'Elenco completo ordini (mock)',
              searchable: true,
              selectable: true,
              filters: const [
                GenaiOptionsFilter<String>(
                  id: 'status',
                  label: 'Stato',
                  options: [
                    GenaiSelectOption(value: 'paid', label: 'Pagato'),
                    GenaiSelectOption(value: 'pending', label: 'In attesa'),
                    GenaiSelectOption(value: 'cancelled', label: 'Annullato'),
                  ],
                ),
              ],
              columns: [
                GenaiColumn<_Order>(
                  id: 'id',
                  title: '#',
                  sortable: true,
                  width: 90,
                  cellBuilder: (ctx, o) =>
                      Text('#${o.id}', style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary, fontWeight: FontWeight.w600)),
                ),
                GenaiColumn<_Order>(
                  id: 'customer',
                  title: 'Cliente',
                  sortable: true,
                  cellBuilder: (ctx, o) => Row(children: [
                    GenaiAvatar.initials(name: o.customer, size: GenaiAvatarSize.sm),
                    const SizedBox(width: 8),
                    Text(o.customer, style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary)),
                  ]),
                ),
                GenaiColumn<_Order>(
                  id: 'city',
                  title: 'Città',
                  cellBuilder: (ctx, o) => Text(o.city, style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textSecondary)),
                ),
                GenaiColumn<_Order>(
                  id: 'date',
                  title: 'Data',
                  sortable: true,
                  cellBuilder: (ctx, o) => Text(GenaiFormatters.date(o.date), style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textSecondary)),
                ),
                GenaiColumn<_Order>(
                  id: 'total',
                  title: 'Totale',
                  sortable: true,
                  align: GenaiColumnAlignment.end,
                  cellBuilder: (ctx, o) => Text(GenaiFormatters.currency(o.total),
                      style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary, fontWeight: FontWeight.w600)),
                ),
                GenaiColumn<_Order>(
                  id: 'status',
                  title: 'Stato',
                  cellBuilder: (ctx, o) => GenaiStatusBadge(
                    label: switch (o.status) {
                      'paid' => 'Pagato',
                      'pending' => 'In attesa',
                      _ => 'Annullato',
                    },
                    status: switch (o.status) {
                      'paid' => GenaiStatusType.active,
                      'pending' => GenaiStatusType.warning,
                      _ => GenaiStatusType.error,
                    },
                  ),
                ),
                GenaiColumn<_Order>(
                  id: 'actions',
                  title: '',
                  width: 56,
                  align: GenaiColumnAlignment.center,
                  cellBuilder: (ctx, o) => GenaiIconButton(
                    icon: LucideIcons.ellipsisVertical,
                    semanticLabel: 'Azioni',
                    size: GenaiSize.sm,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Order {
  final int id;
  final String customer;
  final String city;
  final double total;
  final String status;
  final DateTime date;
  const _Order({
    required this.id,
    required this.customer,
    required this.city,
    required this.total,
    required this.status,
    required this.date,
  });
}
