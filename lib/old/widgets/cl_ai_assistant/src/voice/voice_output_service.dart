import '../core/ai_logger.dart';

/// Stub per il servizio di output vocale (text-to-speech).
///
/// La dipendenza `flutter_tts` non è inclusa nel progetto.
/// Questa classe mantiene l'interfaccia pubblica per compatibilità
/// ma non fornisce funzionalità reali.
class VoiceOutputService {
  bool get isSpeaking => false;

  Future<void> initialize({double speechRate = 0.5, double pitch = 1.0}) async {
    AiLogger.warn(
      'VoiceOutputService non disponibile: flutter_tts non incluso.',
      tag: 'VoiceOut',
    );
  }

  static String detectLanguage(String text) => 'it-IT';

  Future<void> speak(String text) async {}
  Future<void> speakSummary(String text, {int maxChars = 120}) async {}
  Future<void> stop() async {}
  void dispose() {}
}
