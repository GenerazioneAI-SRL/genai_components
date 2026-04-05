import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'breadcrumb_stack.dart';
import 'breadcrumb_observer.dart';
import 'resume_observer.dart';
import 'cl_module_page.dart';

/// Main router configuration for Skillera.
/// Replaces the old GoRouterModular system with a minimal wrapper.
class CLRouter {
  static late GoRouter _router;
  static late CLBreadcrumbStack _breadcrumbs;
  static late List<CLModule> _modules;

  /// The configured GoRouter instance.
  static GoRouter get router => _router;

  /// The breadcrumb stack.
  static CLBreadcrumbStack get breadcrumbs => _breadcrumbs;

  /// All registered modules.
  static List<CLModule> get modules => _modules;

  /// Configure the router with modules.
  static void configure({
    required List<CLModule> modules,
    required Widget Function(BuildContext, GoRouterState, Widget) shellBuilder,
    required GoRouterRedirect redirect,
    required List<RouteBase> preShellRoutes,
    String initialLocation = '/dashboard',
    GlobalKey<NavigatorState>? navigatorKey,
    Listenable? refreshListenable,
  }) {
    _modules = modules;
    _breadcrumbs = CLBreadcrumbStack();

    final shellRoutes = modules.expand((m) => _moduleToRoutes(m, m.path)).toList();

    _router = GoRouter(
      initialLocation: initialLocation,
      navigatorKey: navigatorKey,
      debugLogDiagnostics: false,
      refreshListenable: refreshListenable,
      redirect: redirect,
      routes: [
        ...preShellRoutes,
        ShellRoute(
          builder: shellBuilder,
          observers: [
            CLBreadcrumbObserver(_breadcrumbs),
            CLResumeObserver.instance,
          ],
          routes: shellRoutes,
        ),
      ],
    );
  }

  /// Navigate to a path with optional hidden data.
  static void go(BuildContext context, String path, {Map<String, dynamic>? data}) {
    GoRouter.of(context).go(path, extra: data);
  }

  /// Push a path with optional hidden data.
  static void push(BuildContext context, String path, {Map<String, dynamic>? data}) {
    GoRouter.of(context).push(path, extra: data);
  }

  /// Pop the current route.
  static void pop(BuildContext context, {dynamic result}) {
    GoRouter.of(context).pop(result);
  }

  /// Find a module by path prefix.
  static CLModule? findModuleByPath(String path) {
    for (final module in _modules) {
      if (path.startsWith(module.path)) return module;
    }
    return null;
  }

  // ── Route Generation ──

  static List<GoRoute> _moduleToRoutes(CLModule module, String basePath) {
    return module.pages.map((page) => _pageToRoute(module, page, basePath)).toList();
  }

  static GoRoute _pageToRoute(CLModule module, CLModulePage page, String parentPath) {
    final fullPath = page.path == '/' ? parentPath : '$parentPath${page.path}';

    return GoRoute(
      path: fullPath,
      name: page.name,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: page.builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 140),
        );
      },
      routes: page.children
          .map((child) => _pageToRoute(module, child, fullPath))
          .toList(),
    );
  }
}
