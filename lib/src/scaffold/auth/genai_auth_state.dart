import 'package:flutter/material.dart';
import 'genai_user_info.dart';
import 'genai_tenant.dart';

/// Classe astratta per la gestione dell'autenticazione.
/// Ogni app implementa la propria versione concreta (OIDC, email/password, ecc.)
abstract class GenaiAuthState extends ChangeNotifier {
  // ── Stato ──
  bool get isAuthenticated;

  bool get isLoading;

  bool get isAuthenticating;

  // ── Utente ──
  /// Token di accesso (Bearer token per le API)
  String? get accessToken;

  /// Informazioni utente in formato generico
  GenaiUserInfo? get currentUserInfo;

  // ── Tenant (multi-tenant opzionale) ──
  GenaiTenant? get currentTenant;

  List<GenaiTenant> get tenantList;

  void setCurrentTenant(GenaiTenant? tenant);

  // ── Azioni ──
  Future<void> signIn(BuildContext context);

  Future<void> signOut();

  // ── Permessi (opzionale — override nelle app che li usano) ──
  bool can(String action, String subject, {Map<String, dynamic>? resource}) => true;

  bool checkTenantContext(String tenantContext) => true;
}

