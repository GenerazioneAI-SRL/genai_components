import 'package:flutter/material.dart';
import 'cl_user_info.dart';
import 'cl_tenant.dart';

/// Classe astratta per la gestione dell'autenticazione.
/// Ogni app implementa la propria versione concreta (OIDC, email/password, ecc.)
abstract class CLAuthState extends ChangeNotifier {
  // ── Stato ──
  bool get isAuthenticated;

  bool get isLoading;

  bool get isAuthenticating;

  // ── Utente ──
  /// Token di accesso (Bearer token per le API)
  String? get accessToken;

  /// Informazioni utente in formato generico
  CLUserInfo? get currentUserInfo;

  // ── Tenant (multi-tenant opzionale) ──
  CLTenant? get currentTenant;

  List<CLTenant> get tenantList;

  void setCurrentTenant(CLTenant? tenant);

  // ── Azioni ──
  Future<void> signIn(BuildContext context);

  Future<void> signOut();

  // ── Permessi (opzionale — override nelle app che li usano) ──
  bool can(String action, String subject, {Map<String, dynamic>? resource}) => true;

  bool checkTenantContext(String tenantContext) => true;
}

