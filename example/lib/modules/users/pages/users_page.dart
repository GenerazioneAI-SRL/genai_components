import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import 'package:genai_components/old/utils/models/pagination.model.dart';
import 'package:go_router/go_router.dart';

import '../constants/users_routes.dart';
import '../models/user.model.dart';
import '../viewmodels/users_viewmodel.dart';

/// Vista LISTA del modulo Users: `GenDataTable` pilotata da [UsersViewModel].
/// Tap su riga → dettaglio (`/users/:id`), passando il nome via `extra` per il
/// breadcrumb. Dimostra title header, azioni bulk e full-body ([fillHeight]).
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _vm = UsersViewModel();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _openDetail(User u) => context.go(UsersRoutes.detailOf(u.id), extra: u.name);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        final table = GenDataTable<String, int, User>(
          initialPage: '0',
          idGetter: (u) => u.id,
          embedded: true,
          rowsSelectable: true,
          fillHeight: _vm.fullBody,
          onItemTap: _openDetail,
          title: 'Utenti',
          titleActions: [
            GenButton.outline(
              onPressed: _vm.toggleFullBody,
              leading: GenIcon(_vm.fullBody ? LucideIcons.minimize2 : LucideIcons.maximize2),
              child: Text(_vm.fullBody ? 'Full body: on' : 'Full body: off'),
            ),
            GenButton(
              onPressed: () {},
              leading: const GenIcon(LucideIcons.plus),
              child: const Text('Nuovo'),
            ),
          ],
          selectionActionsBuilder: (context, count, items) => [
            GenButton.outline(
              onPressed: () {},
              leading: const GenIcon(LucideIcons.download),
              child: Text('Esporta ($count)'),
            ),
            GenButton.destructive(
              onPressed: () {},
              leading: const GenIcon(LucideIcons.trash2),
              child: const Text('Elimina'),
            ),
          ],
          mainFilter: TextTableFilter(
            id: 'q',
            title: 'nome',
            isMainFilter: true,
            chipFormatter: (v) => 'Nome: $v',
          ),
          extraFilters: [
            DropdownTableFilter<String>(
              id: 'role',
              title: 'Ruolo',
              isMainFilter: false,
              chipFormatter: (v) => 'Ruolo: $v',
              items: const [
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                DropdownMenuItem(value: 'Developer', child: Text('Developer')),
              ],
            ),
          ],
          tableActions: [
            TableAction<User>(content: const Text('Apri'), icon: Icons.open_in_new, inline: true, onTap: _openDetail),
            TableAction<User>(content: const Text('Elimina'), icon: Icons.delete_outline, inline: true, onTap: (u) {}),
          ],
          columns: [
            TableColumn(title: const Text('Name'), sizeFactor: .3, cellBuilder: (u) => Text(u.name)),
            TableColumn(title: const Text('Email'), sizeFactor: .4, cellBuilder: (u) => Text(u.email)),
            TableColumn(title: const Text('Role'), sizeFactor: .3, cellBuilder: (u) => Text(u.role)),
          ],
          fetchPage: ({page, perPage, searchBy, orderBy}) async {
            final all = _vm.query(name: searchBy?['q'] as String?, role: searchBy?['role'] as String?);
            final size = perPage ?? 25;
            final pageIdx = page ?? 0; // 0-based
            final rows = all.skip(pageIdx * size).take(size).toList();
            return (
              rows,
              Pagination()
                ..total = all.length
                ..currentPage = pageIdx + 1
                ..perPage = size,
            );
          },
        );

        return Builder(
          builder: (context) {
            // Inset shell: clearance header (top) + gutter (horizontal), bottom 0.
            final pad = MediaQuery.paddingOf(context);
            return _vm.fullBody
                ? Padding(padding: pad, child: table)
                : SingleChildScrollView(padding: pad, child: table);
          },
        );
      },
    );
  }
}
