// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:genai_components/genai_components.dart';
import 'package:genai_components/providers/notifications_panel_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'screens/buttons_screen.dart';
import 'screens/form_screen.dart';

/// Demo con CLAppLayout (include CLMenuLayout + CLHeaderLayout).
/// Run: flutter run -t example/main.dart -d macos
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedManager.initPrefs();

  await Modular.configure(
    appModule: _ExampleModule(),
    initialRoute: '/buttons',
    debugLogDiagnostics: false,
    debugLogDiagnosticsGoRouter: false,
    observers: [GoRouterBreadcrumbObserver()],
  );

  runApp(const _RootApp());
}

// ── Router / Module ───────────────────────────────────────────────────────

final List<ModularRoute> _shellRoutes = [
  ChildRoute.build(
    route: CLRoute(name: 'Buttons', path: 'buttons'),
    childBuilder: (_, __) => const ButtonsScreen(),
    icon: LucideIcons.aArrowDown300,
  ),
  ChildRoute.build(
    route: CLRoute(name: 'Form', path: 'form'),
    childBuilder: (_, __) => const FormScreen(),
    icon: LucideIcons.aArrowUp300,
  ),
];

class _ExampleModule extends Module {
  @override
  CLRoute get moduleRoute => CLRoute(name: 'App', path: '/app');

  @override
  List<ModularRoute> get routes => [
        ShellModularRoute(
          builder: (context, state, child) => CLAppLayout(shellChild: child, shellRoutes: _shellRoutes),
          routes: _shellRoutes,
          observers: [GoRouterBreadcrumbObserver()],
        ),
      ];
}

// ── App root + providers richiesti da CLAppLayout/menu/header ───────────

class _RootApp extends StatelessWidget {
  const _RootApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider<CLAuthState>(create: (_) => _NoAuthState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ModuleThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsPanelProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'CL Components Example',
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouterModular.routerConfig,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFFAF9F7),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121218),
            ),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
            locale: const Locale('it', 'IT'),
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: const [
                Breakpoint(start: 0,   end: 767,            name: MOBILE),
                Breakpoint(start: 768, end: double.infinity, name: DESKTOP),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NoAuthState extends CLAuthState {
  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  bool get isAuthenticating => false;

  @override
  String? get accessToken => null;

  @override
  CLUserInfo? get currentUserInfo => null;

  @override
  CLTenant? get currentTenant => null;

  @override
  List<CLTenant> get tenantList => const [];

  @override
  void setCurrentTenant(CLTenant? tenant) {}

  @override
  Future<void> signIn(BuildContext context) async {}

  @override
  Future<void> signOut() async {}
}

