import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../theme/context_extensions.dart';
import 'providers/genai_error_state.dart';

/// Full-page HTTP error display (401/403/other).
class GenaiErrorPage extends StatelessWidget {
  final int? errorCode;
  final String? errorDetail;
  final String? errorMessage;
  final VoidCallback? onGoToLogin;
  final VoidCallback? onGoHome;

  const GenaiErrorPage({
    super.key,
    this.errorCode,
    this.errorDetail,
    this.errorMessage,
    this.onGoToLogin,
    this.onGoHome,
  });

  String _title(int? code) => switch (code) {
        401 => 'Sessione Scaduta',
        403 => 'Accesso Negato',
        _ => 'Errore',
      };

  String _message(int? code) => switch (code) {
        401 => 'La tua sessione è scaduta. Effettua nuovamente il login per continuare.',
        403 => 'Non hai i permessi necessari per accedere a questa risorsa.',
        _ => 'Si è verificato un errore imprevisto.',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final errorState = context.watch<GenaiPageErrorState>();
    final code = errorState.hasError ? errorState.errorCode : errorCode;

    return Scaffold(
      backgroundColor: c.surfacePage,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.s6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(spacing.s6),
                decoration: BoxDecoration(
                  color: c.colorErrorSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  code == 401 ? LucideIcons.lockKeyhole : LucideIcons.ban,
                  size: 56,
                  color: c.colorError,
                ),
              ),
              SizedBox(height: spacing.s6),
              Text(
                '${code ?? 'Errore'} — ${_title(code)}',
                style: ty.headingLg.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.s4),
              Text(
                _message(code),
                style: ty.bodyMd.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.s8),
              FilledButton.icon(
                onPressed: () {
                  errorState.clearError();
                  if (code == 401) {
                    onGoToLogin?.call();
                  } else {
                    onGoHome?.call();
                  }
                },
                icon: Icon(code == 401 ? LucideIcons.logIn : LucideIcons.house),
                label: Text(code == 401 ? 'Vai al Login' : 'Torna alla Home'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.colorPrimary,
                  foregroundColor: c.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
