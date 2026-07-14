import 'package:flutter/foundation.dart';

import '../models/user.model.dart';

/// Tipo d'uso del ViewModel (come `VMType` di skillera): un unico VM serve
/// lista e dettaglio, discriminati qui.
enum UsersVMType { list, detail }

/// ViewModel del modulo Users: logica di fetch/filtro (lista) + lookup singolo
/// (dettaglio). La view osserva questo notifier; nessuna logica di dominio vive
/// nel widget.
class UsersViewModel extends ChangeNotifier {
  UsersViewModel({this.type = UsersVMType.list});

  final UsersVMType type;

  /// Filtro in-memory su nome + ruolo (rimpiazzabile da una fetch remota).
  List<User> query({String? name, String? role}) {
    final q = (name ?? '').toLowerCase();
    return demoUsers.where((u) {
      final okName = q.isEmpty || u.name.toLowerCase().contains(q);
      final okRole = role == null || u.role == role;
      return okName && okRole;
    }).toList();
  }

  /// Record singolo per il dettaglio (null se id inesistente).
  User? byId(int id) {
    for (final u in demoUsers) {
      if (u.id == id) return u;
    }
    return null;
  }
}
