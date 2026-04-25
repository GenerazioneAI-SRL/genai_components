import 'dart:typed_data';

import '../../models/agent_action.dart';
import '../llm_provider.dart';

/// Helpers that build the system-injected user messages and summary text
/// emitted by [ReactAgent] during the ReAct loop.
///
/// All methods are pure: they take inputs and return strings or message
/// lists, without touching agent state. Extracted from `react_agent.dart`
/// to keep the agent file under the size budget.
class AgentMessages {
  const AgentMessages._();

  /// Build the [SYSTEM — FINAL CHECK] message used during post-completion
  /// verification. Keeps the long template strings out of the main loop.
  static String buildVerificationMessage({
    required String userMessage,
    required String screenNow,
    required bool didHandoff,
    required bool isDetailQuery,
    required bool didTapItemSuccessfully,
    required bool looksLikeQuestion,
  }) {
    final verifyMsg = StringBuffer(
      '[SYSTEM — FINAL CHECK]\n'
      'The user asked: "$userMessage"\n\n'
      'Look at the CURRENT SCREEN below and answer the user\'s question FRESH. '
      'Ignore your previous draft — write a completely new response based on what you see NOW.\n\n'
      'INSTRUCTIONS:\n'
      '- If there is still a primary action button to press '
      '(Confirm, Submit, Pay, etc.), press it — the task is not done.\n'
      '- If there are multiple options the user needs to choose, use ask_user.\n'
      '- If the task is complete, respond with a clean summary.\n'
      '- Every fact must be visible on the current screen. '
      'If a value has a label like Fare, Price, Amount, Total, ₹, coins — report it. '
      'Only bare unlabeled large numbers are IDs.\n\n'
      'RESPONSE RULES:\n'
      '- Write as if this is your FIRST and ONLY response. The user has NOT seen any previous draft.\n'
      '- NEVER say: "apologies", "I misread", "let me correct", "I see the problem", "actually".\n'
      '- NEVER reference a previous attempt or correction. Just answer directly.',
    );

    // Generic incomplete-task detection: if the user gave an ACTION
    // command (not a question) and the agent didn't hand off, check
    // whether the task might be incomplete. The domain instructions
    // in the system prompt define what "complete" means for the app.
    if (!didHandoff && !userMessage.trim().endsWith('?')) {
      verifyMsg.write(
        '\n\nIMPORTANT: Re-read the APP-SPECIFIC INSTRUCTIONS in the system prompt. '
        'Is the user\'s request FULLY completed according to those instructions? '
        'If the instructions say a task requires multiple steps (e.g. a multi-step flow), '
        'and you only completed some of them, you MUST continue — do NOT respond yet.',
      );
    }

    if (isDetailQuery && !didTapItemSuccessfully) {
      verifyMsg.write(
        '\n\nCRITICAL — INCOMPLETE: The user asked for DETAILS about a specific item, '
        'but you did NOT successfully tap into the item\'s detail screen. '
        'List views only show summaries — NOT full details. '
        'FIRST: scroll UP to the TOP of the list (the most recent item is at the top). '
        'THEN: TAP the actual item card/row (NOT the page header or section title). '
        'Look for tappable content like dates, amounts, or status text in the item row. '
        'THEN: ONLY use get_screen_content and scroll to READ the detail screen. '
        'Report ALL visible fields comprehensively.',
      );
    }

    if (looksLikeQuestion) {
      verifyMsg.write(
        '\nCRITICAL: Your response contains a question. '
        'Use ask_user tool to ask it — returning text ends the task.',
      );
    }

    verifyMsg.write('\n\nCURRENT SCREEN:\n$screenNow');
    return verifyMsg.toString();
  }

  /// Generate a user-friendly summary when the agent did work but the LLM
  /// returned an empty response instead of a proper text conclusion.
  static String summarizeActions(List<AgentAction> actions) {
    // Filter out internal tools and ask_user from the visible summary.
    final visible =
        actions
            .where(
              (a) =>
                  a.toolName != 'get_screen_content' &&
                  a.toolName != 'ask_user',
            )
            .toList();
    if (visible.isEmpty) return 'Done.';

    // Count action types for a concise summary instead of listing every action.
    final succeeded = visible.where((a) => a.result.success).length;
    final failed = visible.where((a) => !a.result.success).length;
    final total = visible.length;

    if (failed == 0) {
      return 'Done — completed $total action${total == 1 ? '' : 's'}.';
    }
    return 'Partially done — $succeeded of $total action${total == 1 ? '' : 's'} succeeded, '
        '$failed failed.';
  }

  /// Inject a screenshot into the message list as a multimodal user message.
  ///
  /// The screenshot is appended as the LAST user message so the LLM sees it
  /// alongside the latest context. It is NOT stored in conversation memory
  /// (ephemeral — changes every iteration and is large).
  static List<LlmMessage> injectScreenshot(
    List<LlmMessage> messages,
    Uint8List screenshot,
  ) {
    return [
      ...messages,
      LlmMessage.userMultimodal(
        '[SCREENSHOT] Current screen visual. Use this for text in images, '
        'charts, visual layouts, and content not captured by the semantics tree.',
        [LlmImageContent(bytes: screenshot)],
      ),
    ];
  }
}
