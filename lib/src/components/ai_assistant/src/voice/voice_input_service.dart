import '../core/ai_logger.dart';

/// Stub per il servizio di input vocale (speech-to-text).
///
/// La dipendenza `speech_to_text` non è inclusa nel progetto.
/// Questa classe mantiene l'interfaccia pubblica per compatibilità
/// ma non fornisce funzionalità reali.
class VoiceInputService {
  bool get isListening => false;
  bool get isAvailable => false;
  String? get resolvedLocaleId => null;

  Future<bool> initialize() async {
    AiLogger.warn(
      'VoiceInputService non disponibile: speech_to_text non incluso.',
      tag: 'VoiceIn',
    );
    return false;
  }

  Future<void> startListening({
    required void Function(String finalText, double confidence) onResult,
    void Function(String partialText)? onPartial,
    List<String> preferredLocales = const ['it_IT', 'en_US'],
  }) async {}

  Future<void> stopListening() async {}
  Future<void> cancel() async {}
  void dispose() {}
}
