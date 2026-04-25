import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_registry.dart';

/// Convenience extensions on [BuildContext] for the GenAI Components
/// modular router.
///
/// These helpers query [RouteRegistry] (the internal name → path map populated
/// by `Module.configureRoutes`) so callers can navigate by **name** without
/// having to know the absolute path of a route.
extension GoRouterModularContextExtension on BuildContext {
  /// Returns `true` when [pathOrName] matches a route currently registered in
  /// [RouteRegistry].
  ///
  /// The argument can be either:
  /// - a route **name** (e.g. `'dashboard'`), or
  /// - an absolute **path** previously registered (e.g. `'/dashboard'`).
  ///
  /// Useful to guard navigation calls when a route may not exist in the
  /// current build (feature flags, conditional modules, etc.).
  bool isRouteDefined(String pathOrName) {
    return RouteRegistry.instance.has(pathOrName);
  }

  /// Navigates to [pathOrName] only if [isRouteDefined] returns `true`.
  ///
  /// When [pathOrName] resolves via [RouteRegistry] as a name, the registered
  /// absolute path is used. Otherwise [pathOrName] is forwarded as-is to
  /// `GoRouter.go`. The optional [extra] is passed through unchanged.
  ///
  /// No-op when the route is not registered — safe to call unconditionally.
  void goIfDefined(String pathOrName, {Object? extra}) {
    if (!isRouteDefined(pathOrName)) return;
    final resolved =
        RouteRegistry.instance.getPathByName(pathOrName) ?? pathOrName;
    GoRouter.of(this).go(resolved, extra: extra);
  }
}
