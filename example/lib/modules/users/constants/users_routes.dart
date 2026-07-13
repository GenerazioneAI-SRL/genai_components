/// Route del modulo Users (path + name), stile AppRoute di skillera_admin.
/// La navigazione avviene per path assoluto via go_router.
class UsersRoutes {
  static const String listPath = '/users';
  static const String listName = 'Utenti';

  /// Pattern route dettaglio (con param `:id`).
  static const String detailPath = '/users/:id';
  static const String detailName = 'Dettaglio Utente';

  /// Path concreto del dettaglio per un dato id.
  static String detailOf(int id) => '/users/$id';
}
