import 'package:cl_components/router/go_router_modular/routes/cl_route.dart';

class AppRoutes {
  static const Duration d = Duration(milliseconds: 700);
  static final CLRoute error = CLRoute(name: "Errore", path: "/error");
  static final CLRoute forbidden = CLRoute(name: "Accesso Negato", path: "/forbidden");
}
