import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cl_components/utils/models/breadcrumb_item.model.dart';
import 'package:cl_components/utils/providers/navigation.util.provider.dart';

class GoRouterBreadcrumbObserver extends NavigatorObserver {
  void _addBreadcrumb(Route<dynamic> route) {
    if (route is PageRoute) {
      final ctx = navigator?.context;
      if (ctx == null) return;
      final nav = Provider.of<NavigationState>(ctx, listen: false);

      final args = route.settings.arguments as Map<String, dynamic>?;

      // routeName (fallback a settings.name)
      final name = args?['routeName'] as String? ?? route.settings.name;
      if (name == null) return;

      // Flags e informazioni sulla gerarchia
      final isModule = args?['isModule'] as bool? ?? false;
      final isMenuRoute = args?['isMenuRoute'] as bool? ?? false;
      final isNestedInMenu = args?['isNestedInMenu'] as bool? ?? false;
      final parentModuleName = args?['parentModuleName'] as String?;
      final parentModulePath = args?['parentModulePath'] as String?;
      final parentMenuName = args?['parentMenuName'] as String?;
      final parentMenuPath = args?['parentMenuPath'] as String?;

      String path = args?['routePath'] as String? ?? '';

      // Ignora le route intermedie (moduli senza pagina) che hanno path vuoto e nome che inizia con /
      if (path.isEmpty && name.startsWith('/')) {
        return;
      }

      // Se questa è una voce di menu (isMenuRoute=true), aggiungi solo il breadcrumb con il parent module info
      if (isMenuRoute) {
        final item = BreadcrumbItem(
          name: name,
          path: path,
          isModule: false,
          isClickable: false,
        );
        nav.addBreadcrumb(item, parentModuleName: parentModuleName, parentModulePath: parentModulePath, isNestedInMenu: isNestedInMenu);
      } else if (parentMenuName != null) {
        // Pagina dettaglio con parent menu - costruisci gerarchia completa

        // PRIMA cerca se il menu esiste già (prima di rimuovere qualsiasi cosa!)
        final menuIdx = nav.breadcrumbs.indexWhere((b) => b.name == parentMenuName && !b.isModule);

        // Prima assicurati che il modulo ci sia (se non c'è già)
        if (parentModuleName != null) {
          final moduleIdx = nav.breadcrumbs.indexWhere((b) => b.name == parentModuleName && b.isModule);

          if (moduleIdx == -1) {
            // Aggiungi il modulo usando addBreadcrumb
            nav.addBreadcrumb(
              BreadcrumbItem(
                name: parentModuleName,
                path: parentModulePath ?? '',
                isModule: true,
                isClickable: false,
              ),
              parentModuleName: null,
              parentModulePath: null,
            );
          } else {
            // Il modulo esiste già
            if (menuIdx != -1 && menuIdx > moduleIdx) {
              if (menuIdx < nav.breadcrumbs.length - 1) {
                nav.breadcrumbs.removeRange(menuIdx + 1, nav.breadcrumbs.length);
              }
            } else {
              if (moduleIdx < nav.breadcrumbs.length - 1) {
                nav.breadcrumbs.removeRange(moduleIdx + 1, nav.breadcrumbs.length);
              }
            }
          }
        }

        // Avvolgi le modifiche in un postFrameCallback per evitare setState durante il build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Ri-cerca il menu dopo le modifiche
          final currentMenuIdx = nav.breadcrumbs.indexWhere((b) => b.name == parentMenuName && !b.isModule);

          if (currentMenuIdx == -1) {
            nav.breadcrumbs.add(BreadcrumbItem(
              name: parentMenuName,
              path: parentMenuPath ?? '',
              isModule: false,
              isClickable: parentMenuPath != null && parentMenuPath.isNotEmpty,
            ));
          }

          // Infine aggiungi la pagina corrente direttamente
          nav.breadcrumbs.add(BreadcrumbItem(
            name: name,
            path: path,
            isModule: false,
            isClickable: false,
          ));

          nav.pageName = name;
          nav.notifyListeners();
        });
      } else {
        // Pagina normale senza parent menu - usa il sistema standard
        final item = BreadcrumbItem(
          name: name,
          path: path,
          isModule: isModule,
          isClickable: false,
        );
        nav.addBreadcrumb(item, parentModuleName: parentModuleName, parentModulePath: parentModulePath, isNestedInMenu: isNestedInMenu);
      }
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _addBreadcrumb(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _addBreadcrumb(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final ctx = navigator?.context;
    if (ctx == null) return;
    final nav = Provider.of<NavigationState>(ctx, listen: false);

    // recupera l'argomento isModule della route su cui siamo atterrati
    final prevArgs = previousRoute?.settings.arguments as Map<String, dynamic>?;
    String path = prevArgs?['routePath'] as String? ?? '';
    nav.removeUntil(path);
  }
}
