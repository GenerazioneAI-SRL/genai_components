import 'package:flutter/material.dart';
import 'cl_confirm_dialog.dart';

/// Mixin che fornisce la logica comune di gestione async per i button.
/// Gestisce loading state, confirmation dialog, e detect di funzioni async.
mixin AsyncButtonMixin<T extends StatefulWidget> on State<T> {
  bool loading = false;

  /// Gestisce il tap del button con supporto per:
  /// - Funzioni async (mostra loading state)
  /// - Confirmation dialog (se richiesto)
  /// - Auto-cleanup sul unmount
  Future<void> handleAsyncTap({
    required Function() onTap,
    required bool needConfirmation,
    required String? confirmationMessage,
  }) async {
    if (loading) return;

    if (needConfirmation) {
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: ConfirmationDialog(
              confirmationMessage: confirmationMessage,
              onTap: () async {
                if (_isAsync(onTap)) {
                  if (mounted) setState(() => loading = true);
                  await onTap();
                  if (mounted) setState(() => loading = false);
                } else {
                  onTap();
                }
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
          );
        },
      );
    } else {
      if (_isAsync(onTap)) {
        if (mounted) setState(() => loading = true);
        await onTap();
        if (mounted) setState(() => loading = false);
      } else {
        onTap();
      }
    }
  }

  /// Determina se una funzione è async (Future Function)
  bool _isAsync(Function function) {
    return function is Future Function();
  }
}

