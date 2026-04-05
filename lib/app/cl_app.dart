import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../api/api_manager.dart';
import '../auth/cl_auth_state.dart';
import '../cl_theme.dart';
import '../core_utils/navigation_observer.dart';
import '../layout/app.layout.dart';
import '../layout/menu.layout.dart';
import '../pages/error_page.dart';
import '../constants/routes.constants.dart';
import '../providers/app_state.dart';
import '../providers/error_state.dart';
import '../providers/notifications_panel_provider.dart';
import '../providers/theme_provider.dart';
import '../router/go_router_modular/bind.dart';
import '../router/go_router_modular/go_router_modular_configure.dart';
import '../router/go_router_modular/module.dart';
import '../router/go_router_modular/page_transition_enum.dart';
import '../router/go_router_modular/routes/child_route.dart';
import '../router/go_router_modular/routes/cl_route.dart';
import '../router/go_router_modular/routes/i_modular_route.dart';
import '../router/go_router_modular/routes/shell_modular_route.dart';
import '../router/resume_observer.dart';
import '../utils/providers/module_theme.util.provider.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../utils/shared_manager.util.dart';
import '../widgets/alertmanager/alert_manager.dart';
import '../widgets/cl_ai_assistant/flutter_ai_assistant.dart';

import 'cl_app_config.dart';

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Entry point generico per le app basate su cl_components.
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
    HttpOverrides.global = _MyHttpOverrides();
    await SharedManager.initPrefs();
    ApiManager.configure(baseUrl: config.baseUrl);

    // Core providers
    final appState = AppState();
    final authState = config.authState;
    final navigationState = NavigationState();
    final errorState = ErrorState();
    final themeProvider = ThemeProvider();
    final moduleThemeProvider = ModuleThemeProvider();
    final notificationsPanelProvider = NotificationsPanelProvider();

    // Callback app-specific di init
    await config.onInit();

    // Router
    final appModule = _CLAppModule(config);

    await Modular.configure(
      appModule: appModule,
      initialRoute: config.initialRoute,
      debugLogDiagnostics: config.debugLogDiagnostics,
      debugLogDiagnosticsGoRouter: false,
      pageTransition: PageTransition.fade,
      refreshListenable:
          Listenable.merge([authState, navigationState, appState, errorState]),
      redirect: (context, state) {
        if (config.customRedirect != null) {
          final result = config.customRedirect!(context, state);
          if (result != null) return result;
        }
        return null;
      },
      observers: [GoRouterBreadcrumbObserver()],
      navigatorKey: AlertManager.navigatorKey,
    );

    // AI assistant config (after router is configured)
    final aiConfig = config.buildAiConfig();

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
          aiConfig: aiConfig,
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
  List<Bind<Object>> get binds => [
        Bind.factory<MenuLayout>((i) => MenuLayout(routes: routes)),
      ];

  @override
  List<ModularRoute> get routes => [
        ...config.preAuthRoutes,
        ChildRoute.build(
          route: AppRoutes.error,
          childBuilder: (context, state) => const ErrorPage(),
          isVisible: false,
        ),
        ChildRoute.build(
          route: AppRoutes.forbidden,
          childBuilder: (context, state) => const ErrorPage(),
          isVisible: false,
        ),
        if (config.shellRoutes.isNotEmpty)
          ShellModularRoute(
            builder: (context, state, child) => AppLayout(shellChild: child),
            observers: [
              GoRouterBreadcrumbObserver(),
              CLResumeObserver.instance,
            ],
            redirect: (context, state) {
              final authState =
                  Provider.of<CLAuthState>(context, listen: false);
              if (!authState.isAuthenticated) {
                return config.authRoute;
              }
              return null;
            },
            routes: config.shellRoutes,
          ),
      ];
}

/// Widget root dell'app
class _CLMainApp extends StatelessWidget {
  final AiAssistantConfig? aiConfig;
  final Locale locale;
  final List<Locale> supportedLocales;
  final double mobileBreakpoint;

  const _CLMainApp({
    required this.aiConfig,
    required this.locale,
    required this.supportedLocales,
    required this.mobileBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final moduleTheme = Provider.of<ModuleThemeProvider>(context);

    Widget app = MaterialApp.router(
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
            Breakpoint(
                start: mobileBreakpoint, end: double.infinity, name: DESKTOP),
          ],
        );
      },
    );

    // Wrappa con AI assistant se configurato
    if (aiConfig != null) {
      app = AiAssistant(config: aiConfig!, child: app);
    }

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
