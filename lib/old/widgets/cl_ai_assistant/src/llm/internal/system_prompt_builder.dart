import '../../models/app_context_snapshot.dart';
import 'manifest_section.dart';
import 'prompt_sections.dart';

/// Builds the system prompt sent to the LLM on every iteration of the
/// ReAct loop. Pure function over its inputs — no state, no side effects.
///
/// Extracted from `react_agent.dart` to keep the agent file under the size
/// budget. The output is byte-identical to the original implementation.
/// Bulky text sections live in [PromptSections]; this class orchestrates
/// them and emits the dynamic per-context bits (header, app context, live UI).
class SystemPromptBuilder {
  /// Name shown to the user (used in role declaration).
  final String assistantName;

  /// Whether the agent must hand off the FINAL irreversible action to the
  /// user instead of pressing it itself. Affects rules 3 and 8.
  final bool confirmDestructiveActions;

  /// Optional purpose description of the app (domain vocabulary, use cases).
  final String? appPurpose;

  /// Optional few-shot examples of correct behavior. When empty, generic
  /// examples are generated automatically.
  final List<String> fewShotExamples;

  /// Optional domain-specific behavioral instructions injected into the
  /// system prompt.
  final String? domainInstructions;

  const SystemPromptBuilder({
    required this.assistantName,
    required this.confirmDestructiveActions,
    required this.appPurpose,
    required this.fewShotExamples,
    required this.domainInstructions,
  });

  /// Build the system prompt with full app context.
  ///
  /// Structure:
  /// 1. Role + App Purpose
  /// 2. Core Rules (9 focused, non-contradictory rules)
  /// 3. Few-shot examples
  /// 4. App context (manifest, routes, screen detail)
  /// 5. Live UI
  String build(AppContextSnapshot context) {
    final buffer = StringBuffer();
    final manifest = context.appManifest;

    // ── Section 1: Role + App Purpose ──
    buffer.writeln(
      'You are $assistantName, an AI that controls a mobile app\'s UI on behalf of the user.',
    );
    buffer.writeln(
      'You execute tasks by tapping buttons, entering text, scrolling, and navigating between screens.',
    );
    if (appPurpose != null) {
      buffer.writeln();
      buffer.writeln('APP PURPOSE: $appPurpose');
    }
    buffer.writeln();

    // ── Prime Directives ──
    buffer.writeln('*** PRIME DIRECTIVES (NEVER VIOLATE) ***');
    buffer.writeln(
      '• User gives a command → DO IT. NEVER ask for confirmation when the intent is clear.',
    );
    buffer.writeln(
      '• User specifies details (quantity, name, destination) → USE THEM. NEVER re-ask.',
    );
    buffer.writeln(
      '• When searching, ALWAYS call set_text — even if you do NOT see a text field on screen. '
      'The tool auto-detects hidden, unfocused, and async search bars. NEVER say "I cannot find the search bar" '
      '— just call set_text("Search", "query") and it will find the field.',
    );
    buffer.writeln(
      '• ask_user is ONLY for genuinely ambiguous situations (2+ equally valid options). Aim for ZERO questions.',
    );
    buffer.writeln();

    // ── Section 2: Rules + style guide + recovery guidance ──
    PromptSections.writeRulesAndStyle(
      buffer,
      context: context,
      confirmDestructiveActions: confirmDestructiveActions,
    );

    // ── Domain-specific instructions (provided by the app developer) ──
    if (domainInstructions != null && domainInstructions!.trim().isNotEmpty) {
      buffer.writeln('APP-SPECIFIC INSTRUCTIONS:');
      buffer.writeln(domainInstructions);
      buffer.writeln();
    }

    // ── Section 3: Task types + few-shot examples ──
    PromptSections.writeTaskTypesAndExamples(
      buffer,
      fewShotExamples: fewShotExamples,
    );

    // ── Section 4: App Context ──

    // Tier 1: App Map (from manifest).
    if (manifest != null) {
      ManifestSection.write(buffer, context);

      // Include dynamically discovered routes NOT in the manifest.
      final manifestRoutes = manifest.screens.keys.toSet();
      final extraRoutes = context.availableRoutes.where(
        (r) => !manifestRoutes.contains(r.name),
      );
      if (extraRoutes.isNotEmpty) {
        buffer.writeln('OTHER DISCOVERED SCREENS:');
        for (final route in extraRoutes) {
          final desc =
              route.description != null ? ' — ${route.description}' : '';
          buffer.writeln('  ${route.name}$desc');
        }
        buffer.writeln();
      }
    } else {
      // Fallback: flat route list.
      if (context.availableRoutes.isNotEmpty) {
        buffer.writeln('APP SCREENS (navigate with exact route name):');
        for (final route in context.availableRoutes) {
          final desc =
              route.description != null ? ' — ${route.description}' : '';
          buffer.writeln('  • ${route.name}$desc');
        }
        buffer.writeln();
      }
    }

    // Current screen info.
    if (context.currentRoute != null) {
      buffer.writeln('CURRENT SCREEN: ${context.currentRoute}');
    }
    if (context.navigationStack.isNotEmpty) {
      buffer.writeln(
        'NAVIGATION STACK: ${context.navigationStack.join(' → ')}',
      );
    }
    buffer.writeln();

    // Tier 2: Current screen manifest detail.
    if (manifest != null && context.currentRoute != null) {
      final screenDetail = manifest.toScreenDetailPrompt(context.currentRoute!);
      if (screenDetail != null) {
        buffer.writeln(screenDetail);
        buffer.writeln();
      }
    }

    // ── Section 5: Live UI ──
    buffer.writeln(
      manifest != null
          ? 'LIVE UI (what\'s actually on screen right now):'
          : 'WHAT\'S ON SCREEN:',
    );
    buffer.writeln(context.screenContext.toPromptString());
    buffer.writeln();

    // Screen knowledge cache (brief).
    if (context.screenKnowledge.isNotEmpty) {
      buffer.writeln('SCREENS SEEN BEFORE:');
      final knownEntries =
          context.screenKnowledge.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      for (final entry in knownEntries.take(20)) {
        buffer.writeln(
          '  • ${entry.key}: ${entry.value.elements.length} elements',
        );
      }
      if (knownEntries.length > 20) {
        buffer.writeln('  +${knownEntries.length - 20} more screens omitted');
      }
      buffer.writeln();
    }

    // Global state.
    if (context.globalState != null && context.globalState!.isNotEmpty) {
      buffer.writeln('APP STATE:');
      for (final entry in context.globalState!.entries) {
        buffer.writeln('  • ${entry.key}: ${entry.value}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}
