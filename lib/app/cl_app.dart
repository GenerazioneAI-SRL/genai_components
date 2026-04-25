import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../api/api_manager.dart';
import '../auth/cl_auth_state.dart';
import '../cl_theme.dart';
import '../core_utils/navigation_observer.dart';
import '../layout/app.layout.dart';
import '../pages/error_page.dart';
import '../providers/app_state.dart';
import '../providers/error_state.dart';
import '../providers/notifications_panel_provider.dart';
import '../providers/theme_provider.dart';
import '../router/go_router_modular/go_router_modular_configure.dart';
import '../router/go_router_modular/module.dart';
import '../router/go_router_modular/module_color_registry.dart';
import '../router/go_router_modular/routes/module_route.dart';
import '../router/go_router_modular/page_transition_enum.dart';
import '../router/go_router_modular/routes/child_route.dart';
import '../router/go_router_modular/routes/cl_route.dart';
import '../router/go_router_modular/routes/modular_route.dart';
import '../router/go_router_modular/routes/shell_modular_route.dart';
import '../router/resume_observer.dart';
import '../utils/providers/module_theme.util.provider.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../utils/shared_manager.util.dart';
import '../widgets/alertmanager/alert_manager.dart';
import '../widgets/cl_ai_assistant/flutter_ai_assistant.dart';

import 'cl_app_config.dart';

/// Cache for the last redirect computation. Invalidated whenever any of the
/// observed app-state listenables (auth/navigation/app/error) emit a notify,
/// so routing decisions never go stale across logins/logouts/tenant switches.
String? _lastRedirectLocation;
String? _lastRedirectResult;

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Entry point generico per le app basate su genai_components.
///
/// Uso:
/// ```dart
/// void main() => CLApp.run(MySkilleraConfig());
/// ```
class CLApp {
  CLApp._();

  /// Inizializza e lancia l'app con la configurazione fornita.
  static Future<void> run(CLAppConfig config) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (kDebugMode && !kIsWeb) {
      HttpOverrides.global = _MyHttpOverrides();
    }
    await SharedManager.initPrefs();
    ApiManager.configure(baseUrl: config.baseUrl, apiVersion: config.apiVersion);

    // Core providers
    final appState = AppState();
    appState.showAiButton = config.showAiButton;
    appState.aiButtonPosition = config.aiButtonPosition;
    appState.aiButtonBuilder = config.aiButtonBuilder;
    appState.profilePosition = config.profilePosition;
    final authState = config.authState;
    final navigationState = NavigationState();
    final errorState = ErrorState();
    final themeProvider = ThemeProvider();
    final moduleThemeProvider = ModuleThemeProvider();
    final notificationsPanelProvider = NotificationsPanelProvider();

    // Callback app-specific di init
    await config.onInit();

    // Popola registry colori moduli (consumato da CLPageHeader e altri widget).
    for (final route in config.shellRoutes) {
      if (route is ModuleRoute && route.color != null) {
        ModuleColorRegistry.register(route.path, route.color!);
      }
    }

    // Router
    final appModule = _CLAppModule(config);

    // Single Listenable instance shared between Modular.configure and the
    // cache-invalidation listener — using the same instance ensures that
    // every state notify flushes the redirect dedup cache exactly once.
    final refreshListenable = Listenable.merge([authState, navigationState, appState, errorState]);
    refreshListenable.addListener(() {
      _lastRedirectLocation = null;
      _lastRedirectResult = null;
    });

    await Modular.configure(
      appModule: appModule,
      initialRoute: config.initialRoute,
      debugLogDiagnostics: config.debugLogDiagnostics,
      debugLogDiagnosticsGoRouter: false,
      pageTransition: PageTransition.fade,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final currentLocation = state.matchedLocation;
        // Dedup: identical location + unchanged state ⇒ reuse last result.
        // Cache is invalidated on every notify of refreshListenable above.
        if (currentLocation == _lastRedirectLocation) {
          return _lastRedirectResult;
        }
        String? result;
        try {
          if (config.customRedirect != null) {
            result = config.customRedirect!(context, state);
          }
        } catch (_) {
          // Durante hot-restart, il context può essere deactivato
          // e i Provider non sono ancora disponibili
        }
        _lastRedirectLocation = currentLocation;
        _lastRedirectResult = result;
        return result;
      },
      observers: [GoRouterBreadcrumbObserver()],
      navigatorKey: AlertManager.navigatorKey,
    );

    /// Lazy AI assistant config: starts as `null` and is populated on the next
    /// microtask via [Future.delayed(Duration.zero)]. The notifier is passed
    /// to [_CLMainApp], which rebuilds via [ValueListenableBuilder] when the
    /// value lands. This keeps app-startup off the critical path without
    /// forcing the AI panel into the initial frame.
    final aiConfigNotifier = ValueNotifier<AiAssistantConfig?>(null);
    unawaited(Future.delayed(Duration.zero, () {
      aiConfigNotifier.value = config.buildAiConfig();
    }));

    // Run
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: navigationState),
          ChangeNotifierProvider.value(value: authState),
          ChangeNotifierProvider<CLAuthState>.value(value: authState),
          ChangeNotifierProvider.value(value: errorState),
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: moduleThemeProvider),
          ChangeNotifierProvider.value(value: notificationsPanelProvider),
          ...config.extraProviders,
        ],
        child: _CLMainApp(
          aiConfigNotifier: aiConfigNotifier,
          locale: config.locale,
          supportedLocales: config.supportedLocales,
          mobileBreakpoint: config.mobileBreakpoint,
        ),
      ),
    );
  }
}

/// AppModule generico che usa CLAppConfig
class _CLAppModule extends Module {
  final CLAppConfig config;

  _CLAppModule(this.config);

  @override
  CLRoute get moduleRoute => CLRoute(name: "App", path: "/app");

  @override
  List<ModularRoute> get routes => [
        ...config.preAuthRoutes,
        ChildRoute.build(
          route: CLRoute(name: "Errore", path: "/error"),
          childBuilder: (context, state) => const ErrorPage(),
          isVisible: false,
        ),
        ChildRoute.build(
          route: CLRoute(name: "Accesso Negato", path: "/forbidden"),
          childBuilder: (context, state) => const ErrorPage(),
          isVisible: false,
        ),
        if (config.shellRoutes.isNotEmpty)
          ShellModularRoute(
            builder: (context, state, child) {
              if (config.shellBuilder != null) {
                return config.shellBuilder!(child, config.shellRoutes, config.moduleTabsEnabled);
              }
              return CLAppLayout(
                shellChild: child,
                shellRoutes: config.shellRoutes,
                moduleTabsEnabled: config.moduleTabsEnabled,
                logoBuilder: config.logoBuilder,
                menuExtraBuilder: config.menuExtraBuilder,
                menuFooterBuilder: config.menuFooterBuilder,
              );
            },
            observers: [
              GoRouterBreadcrumbObserver(),
              CLResumeObserver.instance,
            ],
            redirect: (context, state) {
              final authState = Provider.of<CLAuthState>(context, listen: false);
              if (!authState.isAuthenticated) {
                return config.authRoute;
              }
              return null;
            },
            routes: config.shellRoutes,
          ),
      ];
}

/// Widget root dell'app.
///
/// Receives a [ValueListenable] for the AI assistant config so the AI overlay
/// can be wired in lazily after the first frame. The wrapping
/// [ValueListenableBuilder] is scoped to just the AI overlay, so the
/// [MaterialApp.router] subtree is built only once and is not rebuilt when the
/// AI config lands.
class _CLMainApp extends StatelessWidget {
  final ValueListenable<AiAssistantConfig?> aiConfigNotifier;
  final Locale locale;
  final List<Locale> supportedLocales;
  final double mobileBreakpoint;

  const _CLMainApp({
    required this.aiConfigNotifier,
    required this.locale,
    required this.supportedLocales,
    required this.mobileBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final moduleTheme = Provider.of<ModuleThemeProvider>(context);

    final Widget materialApp = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouterModular.routerConfig,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF9F7),
        colorScheme: ColorScheme.light(
          primary: moduleTheme.lightPrimary,
          secondary: moduleTheme.lightSecondary,
          surface: CLTheme.light.secondaryBackground,
          error: CLTheme.light.danger,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121218),
        colorScheme: ColorScheme.dark(
          primary: moduleTheme.darkPrimary,
          secondary: moduleTheme.darkSecondary,
          surface: CLTheme.dark.secondaryBackground,
          error: CLTheme.dark.danger,
        ),
      ),
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: locale,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: Builder(
            builder: (routerContext) => DefaultAlertListener(child: child!),
          ),
          breakpoints: [
            Breakpoint(start: 0, end: mobileBreakpoint, name: MOBILE),
            Breakpoint(start: mobileBreakpoint, end: double.infinity, name: DESKTOP),
          ],
        );
      },
    );

    // Lazy AI assistant overlay: ValueListenableBuilder uses `child:` so
    // `materialApp` is *not* rebuilt when the notifier emits — only the
    // AiAssistant wrapper toggles in place.
    final Widget app = ValueListenableBuilder<AiAssistantConfig?>(
      valueListenable: aiConfigNotifier,
      child: materialApp,
      builder: (context, aiConfig, child) {
        if (aiConfig == null) return child!;
        return AiAssistant(config: aiConfig, child: child!);
      },
    );

    return _RootScaffold(locale: locale, child: app);
  }
}

/// Fornisce Directionality, Localizations e MediaQuery
/// come ancestor per lo Stack interno di AiAssistant.
class _RootScaffold extends StatelessWidget {
  final Locale locale;
  final Widget child;

  const _RootScaffold({required this.locale, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery.fromView(
        view: View.of(context),
        child: Localizations(
          locale: locale,
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: child,
        ),
      ),
    );
  }
}
