import 'dart:async';
import 'package:cl_components/router/go_router_modular/page_transition_enum.dart';
import 'package:cl_components/router/go_router_modular/route_manager.dart';
import 'package:cl_components/router/go_router_modular/route_registry.dart';
import 'package:cl_components/router/go_router_modular/routes/child_route.dart';
import 'package:cl_components/router/go_router_modular/routes/cl_route.dart';
import 'package:cl_components/router/go_router_modular/routes/i_modular_route.dart';
import 'package:cl_components/router/go_router_modular/routes/module_route.dart';
import 'package:cl_components/router/go_router_modular/routes/shell_modular_route.dart';
import 'package:cl_components/router/go_router_modular/transition.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bind.dart';
import 'go_router_modular_configure.dart';

abstract class Module {
  List<Module> get imports => const [];

  List<Bind<Object>> get binds => const [];

  List<ModularRoute> get routes => const [];

  CLRoute get moduleRoute;

  List<RouteBase> configureRoutes({
    String modulePath = '',
    bool topLevel = false,
    String? parentModuleName,
    String? parentModulePath,
    String parentRoutePath = '',
  }) {
    List<RouteBase> result = [];
    RouteManager().registerBindsAppModule(this);

    result.addAll(
      _createChildRoutes(
        topLevel: topLevel,
        parentModuleName: parentModuleName,
        parentModulePath: parentModulePath,
        parentRoutePath: parentRoutePath,
        parentMenuPath: null,
      ),
    );
    result.addAll(
      _createModuleRoutes(
        modulePath: modulePath,
        topLevel: topLevel,
        grandParentModuleName: parentModuleName,
        grandParentModulePath: parentModulePath,
      ),
    );
    result.addAll(_createShellRoutes(topLevel));
    return result;
  }

  GoRoute _createChild({
    required ChildRoute childRoute,
    required bool topLevel,
    String? parentModuleName,
    String? parentModulePath,
    String parentRoutePath = '',
    String? parentMenuName,
    String? parentMenuPath,
  }) {
    final String fullPath = _normalizePath(
      path: childRoute.path,
      topLevel: topLevel,
    );

    // Costruisci il path completo assoluto per il RouteRegistry
    String absolutePath;
    if (parentRoutePath.isEmpty) {
      // Nessun parent, usa fullPath
      absolutePath = fullPath;
    } else {
      // Concatena parent + child, gestendo correttamente gli slash
      String parent =
          parentRoutePath.endsWith('/')
              ? parentRoutePath.substring(0, parentRoutePath.length - 1)
              : parentRoutePath;
      String child = fullPath.startsWith('/') ? fullPath : '/$fullPath';
      absolutePath = '$parent$child';
    }


    // Registra la route nel registry con il path completo assoluto
    RouteRegistry().registerRoute(childRoute.name, absolutePath);

    // Determina se questa route ha figli (quindi è una voce di menu)
    final bool hasChildren = childRoute.routes.isNotEmpty;

    return GoRoute(
      path: fullPath,
      name: fullPath, // Usa il path completo come name univoco
      builder:
          (context, state) =>
              _buildRouteChild(context, state: state, route: childRoute),
      pageBuilder:
          childRoute.pageBuilder != null
              ? (context, state) => childRoute.pageBuilder!(context, state)
              : (context, state) {
                final String fullPath = state.uri.path;

                final Map<String, dynamic> routeParams = {
                  "routeName": childRoute.name,
                  "routePath": fullPath,
                  "isModule": false,
                  "isMenuRoute": hasChildren, // Se ha figli, è una voce di menu
                  "isNestedInMenu":
                      parentMenuName !=
                      null, // È una route figlia di una voce di menu
                };
                // Aggiungi info sul parent module se presente
                if (parentModuleName != null) {
                  routeParams["parentModuleName"] = parentModuleName;
                }
                if (parentModulePath != null) {
                  routeParams["parentModulePath"] = parentModulePath;
                }
                // Aggiungi il nome della voce di menu parent (se presente)
                if (parentMenuName != null) {
                  routeParams["parentMenuName"] = parentMenuName;
                  // Cerca il path della voce di menu parent nel RouteRegistry usando il contesto corrente
                  final parentPath = RouteRegistry().getPathByName(
                    parentMenuName,
                    contextPath: fullPath,
                  );
                  if (parentPath != null) {
                    routeParams["parentMenuPath"] = parentPath;
                  }
                }
                if (parentMenuPath != null) {
                  routeParams["parentMenuPath"] = parentMenuPath;
                }



                return _buildCustomTransitionPage(
                  context,
                  state: state,
                  route: childRoute,
                  routeParameter: routeParams,
                );
              },
      routes: _createChildRoutes(
        routeList: childRoute.routes,
        topLevel: topLevel,
        parentModuleName: parentModuleName,
        parentModulePath: parentModulePath,
        parentRoutePath: absolutePath,
        parentMenuName:
            hasChildren
                ? childRoute.name
                : parentMenuName, // Se ha figli, è la voce di menu
        parentMenuPath:
            hasChildren
                ? absolutePath
                : parentMenuPath, // Se ha figli, passa il suo path
      ),
      //module.module.configureRoutes(modulePath: modulePath, topLevel: false),
      parentNavigatorKey: childRoute.parentNavigatorKey,
      redirect: childRoute.redirect,
      onExit:
          (context, state) => _handleRouteExit(
            context,
            state: state,
            route: childRoute,
            module: this,
          ),
    );
  }

  List<GoRoute> _createChildRoutes({
    List<ModularRoute>? routeList,
    required bool topLevel,
    String? parentModuleName,
    String? parentModulePath,
    String parentRoutePath = '',
    String? parentMenuName,
    String? parentMenuPath,
  }) {
    if (routeList != null) {
      return routeList
          .whereType<ChildRoute>()
          .where((route) => adjustRoute(route.path) != '/')
          .map((route) {
            return _createChild(
              childRoute: route,
              topLevel: topLevel,
              parentModuleName: parentModuleName,
              parentModulePath: parentModulePath,
              parentRoutePath: parentRoutePath,
              parentMenuName: parentMenuName,
              parentMenuPath: parentMenuPath,
            );
          })
          .toList();
    } else {
      return routes
          .whereType<ChildRoute>()
          .where((route) => adjustRoute(route.path) != '/')
          .map((route) {
            return _createChild(
              childRoute: route,
              topLevel: topLevel,
              parentModuleName: parentModuleName,
              parentModulePath: parentModulePath,
              parentRoutePath: parentRoutePath,
              parentMenuName: parentMenuName,
              parentMenuPath: parentMenuPath,
            );
          })
          .toList();
    }
  }

  GoRoute _createModule({
    required ModuleRoute module,
    required String modulePath,
    required bool topLevel,
    String? grandParentModuleName,
    String? grandParentModulePath,
  }) {
    final childRoute =
        module.module.routes
            .whereType<ChildRoute>()
            .where((route) => adjustRoute(route.path) == '/')
            .firstOrNull;

    // Costruisci il path completo ASSOLUTO per il RouteRegistry (senza normalizzazioni)
    // modulePath è già il path completo del parent (es. /training-designer)
    // Non aggiungere nulla perché la route principale ha path "/"
    final String absolutePathForRegistry = modulePath;

    // Normalizza per go_router (potrebbe rimuovere lo slash se topLevel=false)
    final String fullPath = _normalizePath(
      path: module.path + (childRoute?.path ?? ""),
      topLevel: topLevel,
    );


    // Registra la route nel registry con il path ASSOLUTO completo
    if (childRoute != null) {
      RouteRegistry().registerRoute(childRoute.name, absolutePathForRegistry);
    }
    RouteRegistry().registerRoute(module.name, absolutePathForRegistry);
    return GoRoute(
      path: fullPath,
      name: fullPath, // Usa il path completo come name univoco
      builder:
          (context, state) => _buildModuleChild(
            context,
            state: state,
            module: module,
            route: childRoute,
          ),
      pageBuilder:
          childRoute != null
              ? childRoute.pageBuilder != null
                  ? (context, state) => childRoute.pageBuilder!(context, state)
                  : (context, state) {
                    // Passa il nome della child route, non del modulo
                    // Se c'è un grandParent (modulo principale), usa quello come parent nei breadcrumbs
                    final String parentForBreadcrumbs =
                        grandParentModuleName ?? moduleRoute.name;
                    final String parentPathForBreadcrumbs =
                        grandParentModulePath ?? moduleRoute.path;

                    return _buildCustomTransitionPage(
                      context,
                      state: state,
                      route: childRoute,
                      routeParameter: {
                        "routeName":
                            childRoute
                                .name, // Nome della pagina (es. "Progettazioni")
                        "routePath": state.uri.path,
                        "isModule": false, // È una pagina, non un modulo
                        "parentModuleName":
                            parentForBreadcrumbs, // Nome del modulo principale (es. "Progettista")
                        "parentModulePath":
                            parentPathForBreadcrumbs, // Path del modulo principale
                      },
                    );
                  }
              : null,
      routes: [
        // Route del sottomodulo (esclusa la principale che è questo modulo)
        ...module.module.configureRoutes(
          modulePath: modulePath,
          topLevel: false,
          parentModuleName: grandParentModuleName ?? moduleRoute.name,
          parentModulePath: grandParentModulePath ?? moduleRoute.path,
          parentRoutePath: absolutePathForRegistry,
        ),
        // Route nidificate della childRoute principale (se presenti)
        ...() {
          if (childRoute != null && childRoute.routes.isNotEmpty) {

            return _createChildRoutes(
              routeList: childRoute.routes,
              topLevel: true, // ✅ topLevel=true per mantenere lo slash iniziale
              // Usa grandParentModuleName se disponibile (es. "Progettista" per le route di Juridicals)
              // altrimenti usa il nome del modulo corrente (per moduli top-level)
              parentModuleName: grandParentModuleName ?? moduleRoute.name,
              parentModulePath: grandParentModulePath ?? moduleRoute.path,
              parentRoutePath: absolutePathForRegistry,
              parentMenuName:
                  childRoute
                      .name, // La route principale del modulo è la voce di menu
            );
          } else {
            return <GoRoute>[];
          }
        }(),
      ],
      parentNavigatorKey: childRoute?.parentNavigatorKey,
      redirect: childRoute?.redirect,
      onExit:
          (context, state) =>
              childRoute == null
                  ? Future.value(true)
                  : _handleRouteExit(
                    context,
                    state: state,
                    route: childRoute,
                    module: module.module,
                  ),
    );
  }

  List<GoRoute> _createModuleRoutes({
    List<ModularRoute>? routeList,
    required String modulePath,
    required bool topLevel,
    String? grandParentModuleName,
    String? grandParentModulePath,
  }) {
    if (routeList != null) {
      return routeList.whereType<ModuleRoute>().map((module) {
        String fullPath = "";
        if (modulePath != module.path) {
          fullPath = modulePath + module.path;
        } else {
          fullPath = module.path;
        }
        // Quando creiamo sottomoduli, passa il nome del MODULO CORRENTE come grandParent
        // (non il grandParent ricevuto, che è il parent del modulo corrente)
        final String? parentName = topLevel ? null : moduleRoute.name;
        final String? parentPath = topLevel ? null : moduleRoute.path;
        return _createModule(
          module: module,
          modulePath: fullPath,
          topLevel: topLevel,
          grandParentModuleName: parentName,
          grandParentModulePath: parentPath,
        );
      }).toList();
    } else {
      return routes.whereType<ModuleRoute>().map((module) {
        String fullPath = "";
        if (modulePath != module.path) {
          fullPath = modulePath + module.path;
        } else {
          fullPath = module.path;
        }
        // Quando creiamo sottomoduli, passa il nome del MODULO CORRENTE come grandParent
        // (non il grandParent ricevuto, che è il parent del modulo corrente)
        final String? parentName = topLevel ? null : moduleRoute.name;
        final String? parentPath = topLevel ? null : moduleRoute.path;
        return _createModule(
          module: module,
          modulePath: fullPath,
          topLevel: topLevel,
          grandParentModuleName: parentName,
          grandParentModulePath: parentPath,
        );
      }).toList();
    }
  }

  List<RouteBase> _createShellRoutes(bool topLevel) {
    return routes.whereType<ShellModularRoute>().map((shellRoute) {
      // if (shellRoute.routes.whereType<ChildRoute>().where((element) => element.path == '/').isNotEmpty) {
      //   throw Exception('ShellModularRoute cannot contain ChildRoute with path "/"');
      // }
      return ShellRoute(
        builder:
            (context, state, child) =>
                shellRoute.builder!(context, state, child),
        pageBuilder:
            shellRoute.pageBuilder != null
                ? (context, state, child) =>
                    shellRoute.pageBuilder!(context, state, child)
                : null,
        redirect: shellRoute.redirect,
        navigatorKey: shellRoute.navigatorKey,
        observers: shellRoute.observers,
        parentNavigatorKey: shellRoute.parentNavigatorKey,
        restorationScopeId: shellRoute.restorationScopeId,
        routes:
            shellRoute.routes
                .map((routeOrModule) {
                  if (routeOrModule is ChildRoute) {
                    return _createChild(
                      childRoute: routeOrModule,
                      topLevel: topLevel,
                    );
                  } else if (routeOrModule is ModuleRoute) {
                    return _createModule(
                      module: routeOrModule,
                      modulePath: routeOrModule.path,
                      topLevel: topLevel,
                    );
                  }
                  return null;
                })
                .whereType<RouteBase>()
                .toList(),
      );
    }).toList();
  }

  String adjustRoute(String route) {
    if (route == "/") {
      return "/";
    } else if (route.startsWith("/:")) {
      return "/";
    } else {
      return route;
    }
  }

  String _normalizePath({required String path, required bool topLevel}) {
    if (path.startsWith("/") && !topLevel && !path.startsWith("/:")) {
      path = path.substring(1);
    }
    return _buildPath(path);
  }

  Widget _buildRouteChild(
    BuildContext context, {
    required GoRouterState state,
    required ChildRoute route,
  }) {
    _register(path: state.uri.toString());
    return route.child(context, state);
  }

  Page<void> _buildCustomTransitionPage(
    BuildContext context, {
    required GoRouterState state,
    required ChildRoute route,
    required Map<String, dynamic> routeParameter,
  }) {
    Map<String, String> extraMap = {};
    if (state.extra != null && state.extra is Map<String, String>) {
      final dynamicExtra = state.extra as Map<String, String>;
      extraMap = dynamicExtra.map(
        (key, value) => MapEntry(
          key,
          value
              .toString(), // Converti il valore a stringa, se è null usa una stringa vuota
        ),
      );
    }
    // Crea il Map con tutti i parametri
    Map<String, dynamic> allParams = {
      ...routeParameter,
      ...extraMap, // Aggiungi le voci extra
    };

    final pageTransition =
        route.pageTransition ?? Modular.getDefaultPageTransition;

    // Se noTransition, usa NoTransitionPage per cambio istantaneo
    if (pageTransition == PageTransition.noTransition) {
      _register(path: state.uri.toString());
      return NoTransitionPage(
        key: state.pageKey,
        child: route.child(context, state),
      );
    }

    return CustomTransitionPage(
      key: state.pageKey,
      child: route.child(context, state),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: Transition.builder(
        configRouteManager: () {
          _register(path: state.uri.toString());
        },
        pageTransition: pageTransition,
      ),
      arguments: allParams,
    );
  }

  Widget _buildModuleChild(
    BuildContext context, {
    required GoRouterState state,
    required ModuleRoute module,
    ChildRoute? route,
  }) {
    _register(path: state.uri.toString(), module: module.module);
    return route?.child(context, state) ?? Container();
  }

  FutureOr<bool> _handleRouteExit(
    BuildContext context, {
    required GoRouterState state,
    required ChildRoute route,
    required Module module,
  }) {
    final completer = Completer<bool>();
    final onExit = route.onExit?.call(context, state) ?? Future.value(true);
    completer.complete(onExit);
    return completer.future.then((exit) {
      try {
        if (exit) _unregister(state.uri.toString(), module: module);
        return exit;
      } catch (_) {
        return false;
      }
    });
  }

  void _register({required String path, Module? module}) {
    RouteManager().registerBindsIfNeeded(module ?? this);
    if (path == '/') return;
    RouteManager().registerRoute(path, module ?? this);
  }

  void _unregister(String path, {Module? module}) {
    Future.delayed(const Duration(milliseconds: 500), () {
      RouteManager().unregisterRoute(path, module ?? this);
    });
  }

  String _buildPath(String path) {
    if (!path.endsWith('/')) {
      path = '$path/';
    }
    path = path.replaceAll(RegExp(r'/+'), '/');
    if (path == '/') return path;
    return path.substring(0, path.length - 1);
  }
}
