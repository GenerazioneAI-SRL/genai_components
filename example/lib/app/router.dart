import 'package:go_router/go_router.dart';

import '../modules/users/users_module.dart';
import 'home_shell.dart';
import 'sections.dart';

/// Router globale: una ShellRoute avvolge lo shell adattivo ([HomeShell]); le
/// route figlie (showcase componenti + modulo Users) ne condividono il layout.
/// La sidebar naviga con `context.go(path)`; breadcrumb/back derivano dalla
/// location corrente (vedi [HomeShell]).
GoRouter buildRouter() => GoRouter(
      initialLocation: '/button',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeShell(
            location: state.uri.path,
            detailTitle: state.extra is String ? state.extra as String : null,
            child: child,
          ),
          routes: [
            for (final s in showcaseSections)
              GoRoute(path: s.path, builder: (context, state) => s.builder()),
            ...usersRoutes(),
          ],
        ),
      ],
    );
