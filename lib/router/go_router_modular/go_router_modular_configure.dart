import 'dart:async';
import 'dart:convert';
import './page_transition_enum.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/cl_error_page.widget.dart';
import 'module.dart';

typedef Modular = GoRouterModular;

class GoRouterModular {
  GoRouterModular._();

  static GoRouter get routerConfig {
    assert(_router != null, 'Add GoRouterModular.configure in main.dart');
    return _router!;
  }

  static bool get debugLogDiagnostics {
    assert(_debugLogDiagnostics != null, 'Add GoRouterModular.configure in main.dart');
    return _debugLogDiagnostics!;
  }

  static PageTransition get getDefaultPageTransition {
    assert(_pageTansition != null, 'Add GoRouterModular.configure in main.dart');
    return _pageTansition!;
  }

  static GoRouter? _router;

  static bool? _debugLogDiagnostics;

  static PageTransition? _pageTansition;

  static getCurrentPathOf(BuildContext context) => GoRouterState.of(context).path ?? '';

  static GoRouterState stateOf(BuildContext context) => GoRouterState.of(context);

  /// Configures the modular GoRouter for the app.
  ///
  /// ### Error handling (additive, non-breaking)
  /// - [errorPageBuilder] (existing) is forwarded to `GoRouter.errorPageBuilder`
  ///   and returns a [Page]. Use it when you need full control over the
  ///   transition/route lifecycle of the error screen.
  /// - [errorBuilder] (existing) is forwarded to `GoRouter.errorBuilder` and
  ///   returns a plain [Widget]. Use it for a simple custom error screen.
  /// - If **neither** is provided, a default fallback based on [CLErrorPage] is
  ///   wired to `errorBuilder` so that uncaught routing errors always render a
  ///   consistent UI.
  ///
  /// All other parameters mirror `GoRouter`'s constructor.
  static Future<FutureOr<GoRouter>> configure({
    required Module appModule,
    required String initialRoute,
    bool debugLogDiagnostics = true,
    Codec<Object?, Object?>? extraCodec,
    void Function(BuildContext, GoRouterState, GoRouter)? onException,

    /// Returns a [Page] for routing errors. Forwarded to
    /// `GoRouter.errorPageBuilder`. Takes precedence over [errorBuilder].
    Page<dynamic> Function(BuildContext, GoRouterState)? errorPageBuilder,

    /// Returns a [Widget] for routing errors. Forwarded to
    /// `GoRouter.errorBuilder`. When both [errorPageBuilder] and [errorBuilder]
    /// are null, a default [CLErrorPage] fallback is used.
    Widget Function(BuildContext, GoRouterState)? errorBuilder,
    FutureOr<String?> Function(BuildContext, GoRouterState)? redirect,
    Listenable? refreshListenable,
    int redirectLimit = 5,
    bool routerNeglect = false,
    bool overridePlatformDefaultLocation = false,
    Object? initialExtra,
    List<NavigatorObserver>? observers,
    bool debugLogDiagnosticsGoRouter = false,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
    bool requestFocus = true,
    PageTransition pageTransition = PageTransition.fade,
  }) async {
    if (_router != null) return _router!;
    _pageTansition = pageTransition;
    _debugLogDiagnostics = debugLogDiagnostics;
    GoRouter.optionURLReflectsImperativeAPIs = true;
    // ignore: deprecated_member_use
    final routes = appModule.configureRoutes(topLevel: true);

    // Default fallback: only kick in when host app provided no error UI at all.
    final Widget Function(BuildContext, GoRouterState)? effectiveErrorBuilder =
        (errorBuilder == null && errorPageBuilder == null)
            ? (context, state) => CLErrorPage(
                  errorCode: '404',
                  message: state.error?.toString(),
                  onGoHome: () => GoRouter.of(context).go(initialRoute),
                )
            : errorBuilder;

    _router = GoRouter(
      routes: routes,
      initialLocation: initialRoute,
      debugLogDiagnostics: debugLogDiagnosticsGoRouter,
      errorBuilder: effectiveErrorBuilder,
      errorPageBuilder: errorPageBuilder,
      extraCodec: extraCodec,
      initialExtra: initialExtra,
      navigatorKey: navigatorKey,
      observers: observers,
      onException: onException,
      overridePlatformDefaultLocation: overridePlatformDefaultLocation,
      redirect: redirect,
      refreshListenable: refreshListenable,
      redirectLimit: redirectLimit,
      requestFocus: requestFocus,
      restorationScopeId: restorationScopeId,
      routerNeglect: routerNeglect,
    );
    debugLogDiagnostics = debugLogDiagnostics;
    return _router!;
  }
}

extension GoRouterExtension on BuildContext {
  String? getPathParam(String param) {
    return GoRouterState.of(this).pathParameters[param];
  }

  String? get getPath {
    return GoRouterState.of(this).path;
  }

  GoRouterState get state {
    return GoRouterState.of(this);
  }
}
