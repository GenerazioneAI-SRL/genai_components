import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';
import '../auth/cl_auth_state.dart';
import '../router/go_router_modular/routes/modular_route.dart';
import '../widgets/cl_ai_assistant/flutter_ai_assistant.dart';

/// Signature per il builder custom della shell (layout principale dell'app).
///
/// [child] è il contenuto della pagina corrente (outlet del router).
/// [shellRoutes] è la lista di route visibili nel menu.
/// [moduleTabsEnabled] indica se le tab dei moduli sono abilitate.
typedef ShellLayoutBuilder = Widget Function(
  Widget child,
  List<dynamic> shellRoutes,
  bool moduleTabsEnabled,
);

/// Configurazione astratta dell'app.
/// Ogni progetto crea la propria implementazione con i moduli business.
abstract class CLAppConfig {
  /// Nome dell'app
  String get appName;

  /// Base URL delle API
  String get baseUrl;

  /// Versione API da inserire tra baseUrl e path endpoint (es. "v1/").
  /// Default vuoto — nessuna versione aggiunta.
  String get apiVersion => '';

  /// OIDC endpoint (opzionale)
  String get oidcEndpoint => '';

  /// Istanza dell'AuthState concreto
  CLAuthState get authState;

  /// Route visibili nella shell (menu laterale)
  List<ModularRoute> get shellRoutes;

  /// Route pre-autenticazione (welcome, auth, maintenance, ecc.)
  List<ModularRoute> get preAuthRoutes => [];

  /// Path della route iniziale (default: prima preAuthRoute)
  String get initialRoute;

  /// Path della route di autenticazione (per redirect dalla shell)
  String get authRoute;

  /// Provider aggiuntivi specifici dell'app.
  /// Usare tipi espliciti: `ChangeNotifierProvider<MioState>.value(value: ...)`.
  List<SingleChildWidget> get extraProviders => [];

  /// Configurazione AI assistant (null = disabilitato)
  AiAssistantConfig? get aiConfig => null;

  /// Locale dell'app
  Locale get locale => const Locale('it', 'IT');

  /// Locales supportati
  List<Locale> get supportedLocales =>
      [const Locale('it', 'IT'), const Locale('en', 'US')];

  /// Breakpoint per il passaggio mobile/desktop
  double get mobileBreakpoint => 1079;

  /// Abilita le tab dei moduli nella top bar.
  /// Se true: header scuro con tab colorate per modulo, sidebar filtrata.
  /// Se false: sidebar con tutte le route visibili, nessuna tab.
  bool get moduleTabsEnabled => false;

  /// Redirect custom del router globale
  String? Function(BuildContext context, dynamic state)? get customRedirect =>
      null;

  /// Debug logging per il router
  bool get debugLogDiagnostics => false;

  /// Callback chiamato dopo l'inizializzazione (before runApp)
  Future<void> onInit() async {}

  /// Widget logo custom da usare nel menu.
  /// Se null, viene usato il default [LogoWidget] di genai_components.
  Widget Function(BuildContext context)? get logoBuilder => null;

  /// Widget extra da mostrare nel menu tra l'header e le voci di navigazione.
  /// Es. selettore Company/Store, info utente, ecc.
  /// Se null, non viene mostrato nulla.
  Widget Function(BuildContext context)? get menuExtraBuilder => null;

  /// Widget da mostrare nel footer del menu (sopra il toggle tema).
  /// Es. card utente con nome, email e logout.
  /// Se null, non viene mostrato nulla.
  Widget Function(BuildContext context)? get menuFooterBuilder => null;

  /// Builder custom per la shell (layout principale: menu + header + contenuto).
  /// Se null, viene usato il default [CLAppLayout] di genai_components.
  ///
  /// Esempio:
  /// ```dart
  /// @override
  /// ShellLayoutBuilder? get shellBuilder => (child, routes, tabsEnabled) =>
  ///     MyCustomLayout(shellChild: child, shellRoutes: routes);
  /// ```
  ShellLayoutBuilder? get shellBuilder => null;

  /// Callback per costruire la configurazione AI a runtime
  /// (dopo che il router e' configurato e le route sono registrate)
  AiAssistantConfig? buildAiConfig() => aiConfig;
}
