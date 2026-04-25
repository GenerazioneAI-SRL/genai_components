import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final col = context.colors;
    final spacing = context.spacing;

    return ShowcaseScaffold(
      title: 'AI Assistant',
      description:
          'Assistant drop-in basato su LLM provider (Claude · Gemini · OpenAI). '
          'Richiede chiavi API reali per funzionare — questa pagina mostra la forma '
          'della config e i modelli di dato.',
      children: [
        ShowcaseSection(
          title: 'Requisito di configurazione',
          child: GenaiAlert.warning(
            title: 'API key richieste',
            body:
                'GenaiAiAssistant invoca provider LLM remoti. Senza chiavi valide la chat non risponde. '
                'Configura la chiave in un ambiente di sviluppo sicuro (es. --dart-define) '
                'prima di usarlo in showcase.',
          ),
        ),
        ShowcaseSection(
          title: 'Snippet — integrazione',
          subtitle: 'Wrap della MaterialApp per abilitare le capacità AI.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.all(spacing.s4),
            child: SelectableText('''GenaiAiAssistant(
  config: GenaiAiAssistantConfig(
    provider: GeminiProvider(apiKey: key),
    systemPrompt: 'Assistente interno',
    tools: [ /* ToolDefinition(...) */ ],
  ),
  child: MaterialApp(home: HomeScreen()),
)''', style: ty.monoSm.copyWith(color: col.textPrimary)),
          ),
        ),
        ShowcaseSection(
          title: 'Provider disponibili',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ProviderCard(
                icon: LucideIcons.sparkles,
                title: 'ClaudeProvider',
                description: 'Anthropic Claude — tool use, vision, streaming.',
              ),
              _ProviderCard(
                icon: LucideIcons.gem,
                title: 'GeminiProvider',
                description: 'Google Gemini — multimodale, function calling.',
              ),
              _ProviderCard(
                icon: LucideIcons.brainCircuit,
                title: 'OpenAIProvider',
                description: 'OpenAI GPT-4o / mini — completions + tools.',
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Mock conversazione',
          subtitle: 'UI statica a scopo illustrativo.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.all(spacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChatBubble(
                  role: 'Utente',
                  body: 'Genera un riepilogo delle vendite del mese scorso.',
                  color: col.surfaceHover,
                ),
                SizedBox(height: spacing.s6),
                _ChatBubble(
                  role: 'Assistant',
                  body:
                      'Ho aggregato 342 ordini per un totale di 128.450 €. '
                      'Top città: Milano (+18%), Roma (+12%). Conversione 8,4%.',
                  color: col.colorPrimarySubtle,
                  isAssistant: true,
                ),
                SizedBox(height: spacing.s4),
                Row(
                  children: [
                    Expanded(
                      child: GenaiTextField.search(
                        hintText: 'Scrivi un messaggio...',
                      ),
                    ),
                    SizedBox(width: spacing.s2),
                    GenaiIconButton(
                      icon: LucideIcons.send,
                      semanticLabel: 'Invia',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _ProviderCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: GenaiCard.outlined(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: context.colors.colorPrimary, size: 22),
              SizedBox(height: context.spacing.s2),
              Text(
                title,
                style: context.typography.cardTitle.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: context.spacing.s2),
              Text(
                description,
                style: context.typography.bodySm.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String role;
  final String body;
  final Color color;
  final bool isAssistant;
  const _ChatBubble({
    required this.role,
    required this.body,
    required this.color,
    this.isAssistant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isAssistant
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(context.spacing.s6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(context.radius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role,
                  style: context.typography.labelSm.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: context.spacing.s2),
                Text(
                  body,
                  style: context.typography.body.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
