import '../../core/ai_logger.dart';
import '../../tools/tool_definition.dart';
import '../llm_provider.dart';

/// Stub LLM provider for Google Gemini.
///
/// La dipendenza `google_generative_ai` non è inclusa nel progetto.
/// Questa classe mantiene l'interfaccia per compatibilità ma lancia
/// un errore se istanziata. Usare [OpenAiProvider] o [ClaudeProvider].
class GeminiProvider implements LlmProvider {
  final String apiKey;
  final String model;
  final double temperature;
  final Duration requestTimeout;

  GeminiProvider({
    required this.apiKey,
    this.model = 'gemini-2.0-flash',
    this.temperature = 0.2,
    this.requestTimeout = const Duration(seconds: 45),
  }) {
    AiLogger.warn(
      'GeminiProvider non è disponibile: la dipendenza google_generative_ai '
      'non è inclusa. Usare OpenAiProvider.',
      tag: 'Gemini',
    );
  }

  @override
  void dispose() {}

  @override
  Future<LlmResponse> sendMessage({
    required List<LlmMessage> messages,
    required List<ToolDefinition> tools,
    String? systemPrompt,
  }) async {
    throw UnsupportedError(
      'GeminiProvider non è disponibile. Aggiungere google_generative_ai '
      'al pubspec.yaml oppure usare OpenAiProvider.',
    );
  }
}
