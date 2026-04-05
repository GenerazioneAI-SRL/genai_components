import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/cl_auth_state.dart';
import '../router/go_router_modular/routes/i_modular_route.dart';
import '../widgets/cl_ai_assistant/flutter_ai_assistant.dart';

/// Configurazione astratta dell'app.
/// Ogni progetto crea la propria implementazione con i moduli business.
abstract class CLAppConfig {
  /// Nome dell'app
  String get appName;

  /// Base URL delle API
  String get baseUrl;

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

  /// Provider aggiuntivi specifici dell'app
  List<ChangeNotifierProvider> get extraProviders => [];

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

  /// Callback per costruire la configurazione AI a runtime
  /// (dopo che il router e' configurato e le route sono registrate)
  AiAssistantConfig? buildAiConfig() => aiConfig;
}
