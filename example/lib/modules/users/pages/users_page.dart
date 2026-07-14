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
    // Mobile = tier bottom bar dello shell (default tabletBreakpoint 600). Su
    // mobile le azioni della toolbar salgono nell'area contestuale sopra la
    // bottom bar (slot shell); su desktop/tablet restano nella toolbar tabella.
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        final nuovoBtn = GenButton(
          onPressed: () {},
          leading: const Icon(LucideIcons.plus),
          child: const Text('Nuovo'),
        );

        final table = GenDataTable<String, int, User>(
          initialPage: '0',
          idGetter: (u) => u.id,
          embedded: true,
          rowsSelectable: true,
          fillHeight: true,
          onItemTap: _openDetail,
          title: 'Utenti',
          // Mobile: ricerca + filtri pubblicati nell'area contestuale dello shell
          // (riga alta sopra la bottom bar) invece che inline. Desktop: invariato.
          hoistFilterBarToShell: true,
          // Mobile: azioni tolte dalla toolbar (le pubblica la pagina agli slot).
          titleActions: isMobile ? const [] : [nuovoBtn],
          selectionActionsBuilder: (context, count, items) => [
            GenButton.outline(
              onPressed: () {},
              leading: const Icon(LucideIcons.download),
              child: Text('Esporta ($count)'),
            ),
            GenButton.destructive(
              onPressed: () {},
              leading: const Icon(LucideIcons.trash2),
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

        // fillHeight → il parent dev'essere bounded: Padding (non uno scroll view).
        final layout = Builder(
          builder: (context) {
            // Inset shell: clearance header (top) + gutter (horizontal), bottom 0.
            final pad = MediaQuery.paddingOf(context);
            return Padding(padding: pad, child: table);
          },
        );

        // Desktop/tablet: azioni nella toolbar tabella (sopra). Mobile: pubblicate
        // agli slot shell → riga bassa dell'area contestuale sopra la bottom bar.
        // gateOnCurrentRoute:false → la lista è il body dello ShellRoute; il
        // cleanup avviene via dispose quando si naviga al dettaglio (go replace).
        if (!isMobile) return layout;
        return GenShellPageActions(
          gateOnCurrentRoute: false,
          // Main action full-width: ShellAction primaria con label → lo shell la
          // rende come bottone a tutta larghezza nell'area contestuale.
          actions: [
            ShellAction(icon: LucideIcons.plus, label: 'Nuovo', isPrimary: true, onTap: () {}),
          ],
          child: layout,
        );
      },
    );
  }
}
