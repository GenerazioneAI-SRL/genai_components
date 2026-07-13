import 'package:go_router/go_router.dart';

import 'constants/users_routes.dart';
import 'pages/user_detail_page.dart';
import 'pages/users_page.dart';

/// Route del modulo Users (lista + dettaglio), stile `Module.routes` di
/// skillera_admin. Vengono montate come figlie della ShellRoute (vedi
/// `app/router.dart`), così condividono lo shell adattivo.
List<RouteBase> usersRoutes() => [
      GoRoute(
        path: UsersRoutes.listPath,
        name: UsersRoutes.listName,
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: UsersRoutes.detailPath,
        name: UsersRoutes.detailName,
        builder: (context, state) => UserDetailPage(id: int.parse(state.pathParameters['id']!)),
      ),
    ];
