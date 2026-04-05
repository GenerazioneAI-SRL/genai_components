import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cl_components/router/go_router_modular/go_router_modular_configure.dart';
import 'package:cl_components/router/go_router_modular/route_registry.dart';


export 'download_extension_stub.dart'
if (dart.library.html) 'download_extension_web.dart'
if (dart.library.io) 'package:cl_components/utils/download_extension_io.dart';

extension NavigationExtensions on BuildContext {
  void safePop() {
// If there is only one route on the stack, navigate to the initial
// page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }

  void customPushNamed(String routeName, {Map<String, String> params = const {}, bool replaceRouteName = false, String? replacedRouteName}) {
    Map<String, String> extraParam = {};
    if (replacedRouteName != null) {
      if (replaceRouteName) {
        extraParam.addAll({"routeName": replacedRouteName});
      } else {
        extraParam.addAll({"routeName": "$routeName $replacedRouteName"});
      }
    }

    // Cerca il path dal RouteRegistry usando il nome
    final registry = RouteRegistry();
    // Passa il path corrente come contesto per aiutare a scegliere la route corretta
    final currentPath = GoRouterState.of(this).uri.path;
    final String? fullPath = registry.getPathByName(routeName, contextPath: currentPath);
    if (fullPath != null) {
      // Sostituisci i parametri nel path
      String processedPath = fullPath;
      params.forEach((key, value) {
        processedPath = processedPath.replaceAll(':$key', value);
      });
      go(processedPath, extra: extraParam);
    } else {
      // Fallback al comportamento originale se la route non è trovata
      goNamed(routeName, extra: extraParam, pathParameters: params);
    }
  }

  void customGoNamed(String routeName, {Map<String, String> params = const {}, bool replaceRouteName = false, String? replacedRouteName}) {
    Map<String, String> extraParam = {};
    if (replacedRouteName != null) {
      if (replaceRouteName) {
        extraParam.addAll({"routeName": replacedRouteName});
      } else {
        extraParam.addAll({"routeName": "$routeName $replacedRouteName"});
      }
    }
    // Controlla se non è desktop e se esiste uno Scaffold
    if (!ResponsiveBreakpoints.of(this).isDesktop) {
      final scaffold = Scaffold.maybeOf(this);
      if (scaffold != null && scaffold.isDrawerOpen) {
        scaffold.closeDrawer();
      }
    }

    // Cerca il path dal RouteRegistry usando il nome
    final registry = RouteRegistry();
    // Passa il path corrente come contesto per aiutare a scegliere la route corretta
    final currentPath = GoRouterState.of(this).uri.path;
    final String? fullPath = registry.getPathByName(routeName, contextPath: currentPath);
    if (fullPath != null) {
      // Sostituisci i parametri nel path
      String processedPath = fullPath;
      params.forEach((key, value) {
        processedPath = processedPath.replaceAll(':$key', value);
      });
      go(processedPath, extra: extraParam);
    } else {
      // Fallback al comportamento originale se la route non è trovata
      goNamed(routeName, extra: extraParam, pathParameters: params);
    }
  }
  String openPopup(String routeName, Map<String,String> param) {
    // Cerca il path dal RouteRegistry usando il nome
    final registry = RouteRegistry();
    final String? pathFromRegistry = registry.getPathByName(routeName);
    if (pathFromRegistry != null) {
      // Sostituisci i parametri nel path
      String processedPath = pathFromRegistry;
      param.forEach((key, value) {
        processedPath = processedPath.replaceAll(':$key', value);
      });
      return processedPath;
    } else {
      // Fallback al comportamento originale
      final fullPath = GoRouterModular.routerConfig.namedLocation(
        routeName,
        pathParameters: param,
      );
      return fullPath;
    }
  }
}

