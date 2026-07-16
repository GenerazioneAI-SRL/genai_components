import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
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
          initialPageSize: 100,
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
            // Demo filtro ASYNC (GenSelectAsync): ricerca debounced + infinite
            // scroll. perPage basso così la paginazione è visibile su ~60 voci.
            CLDropdownTableFilterAsync<String>(
              id: 'struttura',
              title: 'Struttura',
              isMainFilter: false,
              chipFormatter: (s) => 'Struttura: $s',
              searchColumn: 'name',
              perPage: 15,
              searchCallback: _searchStrutture,
              itemBuilder: (context, s) => Text(s),
              valueToShow: (s) => s,
            ),
          ],
          tableActions: [
            TableAction<User>(content: const Text('Apri'), icon: Icons.open_in_new, inline: true, onTap: _openDetail),
            TableAction<User>(content: const Text('Elimina'), icon: Icons.delete_outline, inline: true, onTap: (u) {}),
          ],
          columns: [
            TableColumn(
              title: const Text('Name'),
              sizeFactor: .22,
              cellBuilder: (u) => _nameCell(context, u),
            ),
            TableColumn(
              title: const Text('Codice Fiscale'),
              sizeFactor: .24,
              cellBuilder: (u) => _cfCell(context, u.codiceFiscale),
            ),
            TableColumn(title: const Text('Email'), sizeFactor: .32, cellBuilder: (u) => _emailCell(context, u.email)),
            TableColumn(
              title: const Text('Role'),
              sizeFactor: .22,
              cellBuilder: (u) => Align(alignment: Alignment.centerLeft, child: _roleBadge(context, u.role)),
            ),
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

  /// Dataset demo per il filtro async "Struttura" (~60 voci).
  static final List<String> _strutture = List.generate(60, (i) => 'Struttura ${i + 1}');

  /// Sorgente finta PAGINATA per [CLDropdownTableFilterAsync]: simula la rete con
  /// un delay, filtra per `searchBy['name']` e ritorna la fetta di pagina + una
  /// [Pagination] con `next` valorizzato finché ci sono altre pagine.
  Future<(List<String>, Object?)> _searchStrutture({
    int? page,
    int? perPage,
    Map<String, dynamic>? searchBy,
    Map<String, dynamic>? orderBy,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400)); // simula rete
    final q = (searchBy?['name'] as String?)?.toLowerCase() ?? '';
    final filtered = q.isEmpty ? _strutture : _strutture.where((s) => s.toLowerCase().contains(q)).toList();
    final size = perPage ?? 15;
    final p = (page ?? 1) - 1; // 1-based → 0-based
    final slice = filtered.skip(p * size).take(size).toList();
    final pagination = Pagination()
      ..total = filtered.length
      ..currentPage = page ?? 1
      ..perPage = size
      ..next = ((p + 1) * size < filtered.length) ? (page ?? 1) + 1 : null;
    return (slice, pagination);
  }

  /// Cella nome: GenAvatar con le iniziali (bg primary, testo bianco) · nome in
  /// peso normale (niente bold).
  Widget _nameCell(BuildContext context, User u) {
    final theme = GenTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GenAvatar(
          // src null → mostra direttamente il placeholder (iniziali). Con '' proverebbe
          // a caricare un'immagine vuota e resterebbe il solo bg colorato.
          null,
          size: const Size.square(32),
          backgroundColor: theme.primary,
          placeholder: Text(_initials(u.name), style: theme.smallLabel.copyWith(color: Colors.white)),
        ),
        SizedBox(width: theme.gapSm),
        Flexible(
          child: Text(u.name, style: theme.bodyText, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }

  /// Iniziali dal nome: prima lettera del primo e dell'ultimo token (es.
  /// "Davide Sgravo" → "DS"; "Cher" → "C").
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// Cella email: icona mail leading · testo · ghost button compatto trailing
  /// che copia l'indirizzo negli appunti e mostra un toast. Tutto tokenizzato Gen.
  Widget _emailCell(BuildContext context, String email) {
    final theme = GenTokens.of(context);
    return Row(
      // Min: la riga si stringe sul contenuto → il bottone copia resta attaccato
      // al testo, non spinto al bordo destro della colonna (larga).
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.mail, size: GenSizes.iconSizeCompact, color: theme.secondaryText),
        SizedBox(width: theme.gapSm),
        Flexible(
          child: Text(email, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        SizedBox(width: theme.gapSm),
        _copyButton(context, value: email, toastTitle: 'Email copiata'),
      ],
    );
  }

  /// Cella codice fiscale: testo secondaryText in bold (monospazio non richiesto)
  /// · ghost button compatto che copia il CF e mostra un toast.
  Widget _cfCell(BuildContext context, String cf) {
    final theme = GenTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            cf,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.bodyText,
          ),
        ),
        SizedBox(width: theme.gapSm),
        _copyButton(context, value: cf, toastTitle: 'Codice fiscale copiato'),
      ],
    );
  }

  /// Ghost button compatto che copia [value] negli appunti e mostra un toast.
  Widget _copyButton(BuildContext context, {required String value, required String toastTitle}) {
    return GenIconButton.ghost(
      width: GenSizes.buttonHeightCompact,
      height: GenSizes.buttonHeightCompact,
      iconSize: GenSizes.iconSizeCompact,
      icon: const Icon(LucideIcons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        GenToaster.of(context).show(
          GenToast(title: Text(toastTitle), description: Text(value)),
        );
      },
    );
  }

  /// Badge del ruolo: stesso [GenBadge] per tutti, colore PIENO distinto per
  /// ruolo con testo bianco. Admin = blu (primary del tema), Developer = viola,
  /// Viewer = verde.
  Widget _roleBadge(BuildContext context, String role) {
    final Color hue;
    switch (role) {
      case 'Admin':
        hue = GenTokens.of(context).primary;
      case 'Developer':
        hue = const Color(0xFF7C3AED); // viola
      default: // Viewer e altri
        hue = const Color(0xFF16A34A); // verde
    }
    return GenBadge(
      backgroundColor: hue,
      foregroundColor: Colors.white,
      // Riga singola con ellissi: in colonna stretta il badge tronca invece di
      // andare a capo un carattere per riga.
      child: Text(role, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    );
  }
}
