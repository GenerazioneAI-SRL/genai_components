import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/models/breadcrumb_item.model.dart';
import '../utils/providers/navigation.util.provider.dart';

/// Observer che ascolta le navigazioni di GoRouter e aggiorna i breadcrumb.
///
/// Legge i parametri della route da `route.settings.arguments` (iniettati
/// da `Module._buildCustomTransitionPage`) e chiama `NavigationState.addBreadcrumb`.
class GoRouterBreadcrumbObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _handleRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _handleRoute(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final ctx = navigator?.context;
    if (ctx == null) return;
    final nav = Provider.of<NavigationState>(ctx, listen: false);

    final prevArgs = previousRoute?.settings.arguments as Map<String, dynamic>?;
    final path = prevArgs?['routePath'] as String? ?? '';
    if (path.isNotEmpty) {
      nav.removeUntil(path);
    }
  }

  void _handleRoute(Route<dynamic> route) {
    if (route is! PageRoute) return;

    final ctx = navigator?.context;
    if (ctx == null) return;
    final nav = Provider.of<NavigationState>(ctx, listen: false);

    final args = route.settings.arguments as Map<String, dynamic>?;

    // routeName (fallback a settings.name)
    final name = args?['routeName'] as String? ?? route.settings.name;
    if (name == null) return;

    final path = args?['routePath'] as String? ?? '';

    // Ignora le route intermedie (moduli senza pagina)
    if (path.isEmpty && name.startsWith('/')) return;

    final isModule = args?['isModule'] as bool? ?? false;
    final parentModuleName = args?['parentModuleName'] as String?;
    final parentModulePath = args?['parentModulePath'] as String?;
    final parentMenuName = args?['parentMenuName'] as String?;
    final parentMenuPath = args?['parentMenuPath'] as String?;
    final isMenuRoute = args?['isMenuRoute'] as bool? ?? false;

    // Se è una voce di menu (ha figli), aggiungila come breadcrumb non cliccabile
    if (isMenuRoute) {
      nav.addBreadcrumb(
        BreadcrumbItem(name: name, path: path, isClickable: false),
        parentModuleName: parentModuleName,
        parentModulePath: parentModulePath,
      );
      return;
    }

    // Se ha un parent menu, assicurati che il menu sia nei breadcrumb prima della pagina
    if (parentMenuName != null) {
      // Aggiungi prima il parent menu (se non c'è già)
      nav.addBreadcrumb(
        BreadcrumbItem(
          name: parentMenuName,
          path: parentMenuPath ?? '',
          isClickable: parentMenuPath != null && parentMenuPath.isNotEmpty,
        ),
        parentModuleName: parentModuleName,
        parentModulePath: parentModulePath,
      );

      // Poi aggiungi la pagina corrente
      nav.addBreadcrumb(
        BreadcrumbItem(name: name, path: path, isClickable: false),
        parentModuleName: parentModuleName,
        parentModulePath: parentModulePath,
      );
      return;
    }

    // Pagina normale
    nav.addBreadcrumb(
      BreadcrumbItem(name: name, path: path, isModule: isModule, isClickable: false),
      parentModuleName: parentModuleName,
      parentModulePath: parentModulePath,
    );
  }
}
