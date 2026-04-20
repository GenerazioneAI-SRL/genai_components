import 'path_utils.dart';
import 'page_transition.dart';
import 'route_registry.dart';
import 'routes/child_route.dart';
import 'routes/genai_route.dart';
import 'routes/modular_route.dart';
import 'routes/module_route.dart';
import 'routes/shell_modular_route.dart';
import 'transition.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'configure.dart';

abstract class Module {
  List<ModularRoute> get routes => const [];

  GenaiRoute get moduleRoute;

  List<RouteBase> configureRoutes({
    String modulePath = '',
    bool topLevel = false,
    String? parentModuleName,
    String? parentModulePath,
    String parentRoutePath = '',
  }) {
    return [
      ..._createChildRoutes(
        routeList: null,
        topLevel: topLevel,
        parentModuleName: parentModuleName,
        parentModulePath: parentModulePath,
        parentRoutePath: parentRoutePath,
      ),
      ..._createModuleRoutes(
        routeList: null,
        modulePath: modulePath,
        topLevel: topLevel,
        grandParentModuleName: parentModuleName,
        grandParentModulePath: parentModulePath,
      ),
      ..._createShellRoutes(topLevel),
    ];
  }

  // ── Child Routes ──────────────────────────────────────────────────────

  List<GoRoute> _createChildRoutes({
    required List<ModularRoute>? routeList,
    required bool topLevel,
    String? parentModuleName,
    String? parentModulePath,
    String parentRoutePath = '',
    String? parentMenuName,
    String? parentMenuPath,
  }) {
    final source = routeList ?? routes;
    return source
        .whereType<ChildRoute>()
        .where((route) => !GenaiPathUtils.isRootRoute(route.path))
        .map((route) => _createChild(
              childRoute: route,
              topLevel: topLevel,
              parentModuleName: parentModuleName,
              parentModulePath: parentModulePath,
              parentRoutePath: parentRoutePath,
              parentMenuName: parentMenuName,
              parentMenuPath: parentMenuPath,
            ))
        .toList();
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
    final String fullPath = GenaiPathUtils.normalizePath(
      path: childRoute.path,
      topLevel: topLevel,
    );

    // Costruisci il path completo assoluto per il RouteRegistry
    final String absolutePath = _buildAbsolutePath(parentRoutePath, fullPath);

    // Registra la route nel registry
    RouteRegistry().registerRoute(childRoute.name, absolutePath);

    final bool hasChildren = childRoute.routes.isNotEmpty;

    return GoRoute(
      path: fullPath,
      name: absolutePath, // path assoluto per unicità globale
      builder: (context, state) => childRoute.child(context, state),
      pageBuilder: childRoute.pageBuilder != null
          ? (context, state) => childRoute.pageBuilder!(context, state)
          : (context, state) {
              final routeParams = _buildRouteParams(
                childRoute: childRoute,
                fullPath: state.uri.path,
                hasChildren: hasChildren,
                parentModuleName: parentModuleName,
                parentModulePath: parentModulePath,
                parentMenuName: parentMenuName,
                parentMenuPath: parentMenuPath,
              );

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
        parentMenuName: hasChildren ? childRoute.name : parentMenuName,
        parentMenuPath: hasChildren ? absolutePath : parentMenuPath,
      ),
      parentNavigatorKey: childRoute.parentNavigatorKey,
      redirect: childRoute.redirect,
      onExit: childRoute.onExit != null
          ? (context, state) => childRoute.onExit!(context, state)
          : null,
    );
  }

  // ── Module Routes ─────────────────────────────────────────────────────

  List<GoRoute> _createModuleRoutes({
    required List<ModularRoute>? routeList,
    required String modulePath,
    required bool topLevel,
    String? grandParentModuleName,
    String? grandParentModulePath,
  }) {
    final source = routeList ?? routes;
    return source.whereType<ModuleRoute>().map((module) {
      final fullPath = (modulePath != module.path)
          ? modulePath + module.path
          : module.path;
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

  GoRoute _createModule({
    required ModuleRoute module,
    required String modulePath,
    required bool topLevel,
    String? grandParentModuleName,
    String? grandParentModulePath,
  }) {
    final childRoute = module.module.routes
        .whereType<ChildRoute>()
        .where((route) => GenaiPathUtils.isRootRoute(route.path))
        .firstOrNull;

    final String absolutePathForRegistry = modulePath;

    final String fullPath = GenaiPathUtils.normalizePath(
      path: module.path + (childRoute?.path ?? ""),
      topLevel: topLevel,
    );

    // Registra nel registry
    if (childRoute != null) {
      RouteRegistry().registerRoute(childRoute.name, absolutePathForRegistry);
    }
    RouteRegistry().registerRoute(module.name, absolutePathForRegistry);

    return GoRoute(
      path: fullPath,
      name: absolutePathForRegistry, // path assoluto per unicità globale
      builder: (context, state) =>
          childRoute?.child(context, state) ?? Container(),
      pageBuilder: childRoute != null
          ? childRoute.pageBuilder != null
              ? (context, state) => childRoute.pageBuilder!(context, state)
              : (context, state) {
                  final String parentForBreadcrumbs =
                      grandParentModuleName ?? moduleRoute.name;
                  final String parentPathForBreadcrumbs =
                      grandParentModulePath ?? moduleRoute.path;

                  return _buildCustomTransitionPage(
                    context,
                    state: state,
                    route: childRoute,
                    routeParameter: {
                      "routeName": childRoute.name,
                      "routePath": state.uri.path,
                      "isModule": false,
                      "parentModuleName": parentForBreadcrumbs,
                      "parentModulePath": parentPathForBreadcrumbs,
                    },
                  );
                }
          : null,
      routes: [
        ...module.module.configureRoutes(
          modulePath: modulePath,
          topLevel: false,
          parentModuleName: grandParentModuleName ?? moduleRoute.name,
          parentModulePath: grandParentModulePath ?? moduleRoute.path,
          parentRoutePath: absolutePathForRegistry,
        ),
        if (childRoute != null && childRoute.routes.isNotEmpty)
          ..._createChildRoutes(
            routeList: childRoute.routes,
            topLevel: true,
            parentModuleName: grandParentModuleName ?? moduleRoute.name,
            parentModulePath: grandParentModulePath ?? moduleRoute.path,
            parentRoutePath: absolutePathForRegistry,
            parentMenuName: childRoute.name,
          ),
      ],
      parentNavigatorKey: childRoute?.parentNavigatorKey,
      redirect: childRoute?.redirect,
      onExit: childRoute?.onExit != null
          ? (context, state) => childRoute!.onExit!(context, state)
          : null,
    );
  }

  // ── Shell Routes ──────────────────────────────────────────────────────

  List<RouteBase> _createShellRoutes(bool topLevel) {
    return routes.whereType<ShellModularRoute>().map((shellRoute) {
      return ShellRoute(
        builder: (context, state, child) =>
            shellRoute.builder!(context, state, child),
        pageBuilder: shellRoute.pageBuilder != null
            ? (context, state, child) =>
                shellRoute.pageBuilder!(context, state, child)
            : null,
        redirect: shellRoute.redirect,
        navigatorKey: shellRoute.navigatorKey,
        observers: shellRoute.observers,
        parentNavigatorKey: shellRoute.parentNavigatorKey,
        restorationScopeId: shellRoute.restorationScopeId,
        routes: shellRoute.routes
            .map((routeOrModule) {
              if (routeOrModule is ChildRoute) {
                return _createChild(
                    childRoute: routeOrModule, topLevel: topLevel);
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

  // ── Helpers ───────────────────────────────────────────────────────────

  String _buildAbsolutePath(String parentRoutePath, String fullPath) {
    if (parentRoutePath.isEmpty) return fullPath;
    final parent = parentRoutePath.endsWith('/')
        ? parentRoutePath.substring(0, parentRoutePath.length - 1)
        : parentRoutePath;
    final child = fullPath.startsWith('/') ? fullPath : '/$fullPath';
    return '$parent$child';
  }

  Map<String, dynamic> _buildRouteParams({
    required ChildRoute childRoute,
    required String fullPath,
    required bool hasChildren,
    String? parentModuleName,
    String? parentModulePath,
    String? parentMenuName,
    String? parentMenuPath,
  }) {
    final Map<String, dynamic> params = {
      "routeName": childRoute.name,
      "routePath": fullPath,
      "isModule": false,
      "isMenuRoute": hasChildren,
      "isNestedInMenu": parentMenuName != null,
    };

    if (parentModuleName != null) params["parentModuleName"] = parentModuleName;
    if (parentModulePath != null) params["parentModulePath"] = parentModulePath;
    if (parentMenuName != null) {
      params["parentMenuName"] = parentMenuName;
      final parentPath = RouteRegistry().getPathByName(
        parentMenuName,
        contextPath: fullPath,
      );
      if (parentPath != null) params["parentMenuPath"] = parentPath;
    }
    if (parentMenuPath != null) params["parentMenuPath"] = parentMenuPath;

    return params;
  }

  Page<void> _buildCustomTransitionPage(
    BuildContext context, {
    required GoRouterState state,
    required ChildRoute route,
    required Map<String, dynamic> routeParameter,
  }) {
    Map<String, String> extraMap = {};
    if (state.extra != null && state.extra is Map<String, String>) {
      extraMap = (state.extra as Map<String, String>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }

    final Map<String, dynamic> allParams = {
      ...routeParameter,
      ...extraMap,
    };

    final pageTransition =
        route.pageTransition ?? Modular.getDefaultPageTransition;

    if (pageTransition == PageTransition.noTransition) {
      return NoTransitionPage(
        key: state.pageKey,
        child: route.child(context, state),
        arguments: allParams,
      );
    }

    return CustomTransitionPage(
      key: state.pageKey,
      child: route.child(context, state),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: Transition.builder(
        pageTransition: pageTransition,
      ),
      arguments: allParams,
    );
  }
}
