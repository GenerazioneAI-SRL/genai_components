import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../models/user.model.dart';
import '../viewmodels/users_viewmodel.dart';

/// Vista DETTAGLIO del modulo Users. Riceve l'`id` dalla route (`/users/:id`),
/// carica il record dal [UsersViewModel] e pubblica le pageActions
/// (Modifica/Elimina) sul canale shell. Back + breadcrumb sono pubblicati
/// centralmente dallo shell in base alla location.
class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.id});

  final int id;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final _vm = UsersViewModel(type: UsersVMType.detail);
  late final User? _user = _vm.byId(widget.id);

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final user = _user;

    final body = Builder(
      builder: (context) {
        final pad = MediaQuery.paddingOf(context);
        if (user == null) {
          return Padding(
            padding: pad,
            child: Text('Utente #${widget.id} non trovato', style: t.bodyText),
          );
        }
        return SingleChildScrollView(
          padding: pad,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, t, user),
                SizedBox(height: t.gapLg),
                _infoCard(context, t, user),
              ],
            ),
          ),
        );
      },
    );

    // pageActions pubblicate sul canale shell (header): Modifica primaria + Elimina.
    return GenShellPageActions(
      actions: [
        ShellAction(icon: LucideIcons.pen, label: 'Modifica', isPrimary: true, onTap: () {}),
        ShellAction(icon: LucideIcons.trash2, label: 'Elimina', onTap: () {}),
      ],
      child: body,
    );
  }

  Widget _header(BuildContext context, GenTokens t, User user) => Row(
        children: [
          GenAvatar('', placeholder: Text(user.initials), backgroundColor: t.primary, size: const Size.square(56)),
          SizedBox(width: t.gapLg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.name, style: t.heading2),
              SizedBox(height: t.gapXs),
              GenBadge.secondary(child: Text(user.role)),
            ],
          ),
        ],
      );

  Widget _infoCard(BuildContext context, GenTokens t, User user) => GenCard(
        title: const Text('Anagrafica'),
        child: Padding(
          padding: EdgeInsets.only(top: t.gapMd),
          child: Column(
            children: [
              _row(t, 'ID', '#${user.id}'),
              GenSeparator.horizontal(),
              _row(t, 'Nome', user.name),
              GenSeparator.horizontal(),
              _row(t, 'Email', user.email),
              GenSeparator.horizontal(),
              _row(t, 'Ruolo', user.role),
            ],
          ),
        ),
      );

  Widget _row(GenTokens t, String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: t.gapSm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: t.bodyLabel.copyWith(color: t.secondaryText))),
            Expanded(child: Text(value, style: t.bodyText)),
          ],
        ),
      );
}
