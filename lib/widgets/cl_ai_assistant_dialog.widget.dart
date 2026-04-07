import 'package:flutter/material.dart';

import 'cl_ai_assistant/src/core/ai_assistant.dart';

/// Apre/chiude l'overlay dell'assistente AI globale.
///
/// L'[AiAssistant] è già configurato nel `main.dart` e legge le route
/// automaticamente dal progetto. Questo helper semplicemente togga l'overlay.
///
/// Uso: `CLAiAssistantDialog.show(context);`
class CLAiAssistantDialog {
  CLAiAssistantDialog._();

  /// Mostra (o nasconde) l'overlay dell'assistente AI.
  static void show(BuildContext context) {
    try {
      final controller = AiAssistant.read(context);
      controller.toggleOverlay();
    } catch (_) {
      debugPrint('AiAssistant non trovato nel context. '
          'Assicurati che AiAssistant avvolga l\'app in main.dart.');
    }
  }
}
