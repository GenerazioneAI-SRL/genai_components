// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:genai_components/genai_components.dart';
import 'package:genai_components/providers/notifications_panel_provider.dart';

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
    childBuilder: (_, __) => const _ButtonsPage(),
  )..icon = Icons.smart_button_outlined,
  ChildRoute.build(
    route: CLRoute(name: 'Form', path: 'form'),
    childBuilder: (_, __) => const _FormPage(),
  )..icon = Icons.edit_outlined,
  ChildRoute.build(
    route: CLRoute(name: 'Badges', path: 'badges'),
    childBuilder: (_, __) => const _BadgesPage(),
  )..icon = Icons.label_outline,
  ChildRoute.build(
    route: CLRoute(name: 'Alerts', path: 'alerts'),
    childBuilder: (_, __) => const _AlertsPage(),
  )..icon = Icons.notifications_outlined,
  ChildRoute.build(
    route: CLRoute(name: 'Charts', path: 'charts'),
    childBuilder: (_, __) => const _ChartsPage(),
  )..icon = Icons.bar_chart_outlined,
  ChildRoute.build(
    route: CLRoute(name: 'Colors', path: 'colors'),
    childBuilder: (_, __) => const _ColorsPage(),
  )..icon = Icons.palette_outlined,
  // Route usata dal popup profilo nel CLHeaderLayout
  ChildRoute.build(
    route: CLRoute(name: 'Profilo Utente', path: 'profile'),
    childBuilder: (_, __) => const _ProfilePage(),
    isVisible: false,
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
                Breakpoint(start: 0, end: 768, name: MOBILE),
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

// ── Pages ─────────────────────────────────────────────────────────────────

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.heading2),
          const SizedBox(height: 4),
          Container(height: 2, width: 48, color: theme.primary),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _ButtonsPage extends StatelessWidget {
  const _ButtonsPage();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return _PageScaffold(
      title: 'Buttons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Variants', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLButton(context: context, text: 'Primary', onTap: () {}, iconAlignment: IconAlignment.start),
            CLOutlineButton(context: context, text: 'Outline', onTap: () {}, color: theme.primary, iconAlignment: IconAlignment.start),
            CLSoftButton(context: context, text: 'Soft', onTap: () {}, color: theme.primary, iconAlignment: IconAlignment.start),
            CLGhostButton(context: context, text: 'Ghost', onTap: () {}, color: theme.primary, iconAlignment: IconAlignment.start),
          ]),
          const SizedBox(height: 32),
          Text('Semantic colors', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLButton(context: context, text: 'Success', onTap: () {}, backgroundColor: theme.success, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Warning', onTap: () {}, backgroundColor: theme.warning, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Danger', onTap: () {}, backgroundColor: theme.danger, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Info', onTap: () {}, backgroundColor: theme.info, iconAlignment: IconAlignment.start),
          ]),
        ],
      ),
    );
  }
}

class _FormPage extends StatefulWidget {
  const _FormPage();

  @override
  State<_FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<_FormPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      title: 'Form',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CLTextField(controller: _email, labelText: 'Email'),
          const SizedBox(height: 12),
          CLTextField(controller: _password, labelText: 'Password', isObscured: true),
        ],
      ),
    );
  }
}

class _BadgesPage extends StatelessWidget {
  const _BadgesPage();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return _PageScaffold(
      title: 'Badges & Pills',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status badges', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            CLStatusBadge(label: 'Active', color: theme.success),
            CLStatusBadge(label: 'Pending', color: theme.warning),
            CLStatusBadge(label: 'Error', color: theme.danger),
          ]),
          const SizedBox(height: 32),
          Text('Pills', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            CLPill(pillText: 'Flutter', pillColor: theme.primary),
            CLPill(pillText: 'Dart', pillColor: theme.info),
          ]),
        ],
      ),
    );
  }
}

class _AlertsPage extends StatelessWidget {
  const _AlertsPage();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return _PageScaffold(
      title: 'Alerts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CLAlert.border('Success', 'Operation completed successfully.', backgroundColor: theme.success),
          const SizedBox(height: 8),
          CLAlert.border('Warning', 'Please review before proceeding.', backgroundColor: theme.warning),
          const SizedBox(height: 8),
          CLAlert.border('Error', 'Something went wrong.', backgroundColor: theme.danger),
        ],
      ),
    );
  }
}

class _ChartsPage extends StatelessWidget {
  const _ChartsPage();

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      title: 'Charts',
      child: SizedBox(
        height: 320,
        child: CLBarChart<Map<String, dynamic>>(
          data: const [
            {'month': 'Jan', 'value': 30.0},
            {'month': 'Feb', 'value': 45.0},
            {'month': 'Mar', 'value': 28.0},
            {'month': 'Apr', 'value': 60.0},
            {'month': 'May', 'value': 52.0},
            {'month': 'Jun', 'value': 40.0},
          ],
          xValueMapper: (item, _) => item['month'] as String,
          yValueMapper: (item, _) => item['value'] as double,
          showGrid: true,
        ),
      ),
    );
  }
}

class _ColorsPage extends StatelessWidget {
  const _ColorsPage();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return _PageScaffold(
      title: 'Theme Colors',
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        _ColorChip('Primary', theme.primary),
        _ColorChip('Secondary', theme.secondary),
        _ColorChip('Success', theme.success),
        _ColorChip('Warning', theme.warning),
        _ColorChip('Danger', theme.danger),
        _ColorChip('Info', theme.info),
      ]),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return const _PageScaffold(
      title: 'Profilo Utente',
      child: Text('Pagina profilo demo.'),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
