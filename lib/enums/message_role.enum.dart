/// Unified message role for AI/LLM conversations.
///
/// Consolidates the legacy [AiMessageRole] (chat UI layer) and [LlmRole]
/// (provider layer) into a single canonical type. Both legacy enums remain
/// available with `@Deprecated` annotations and will be removed in 5.0.
///
/// Use [MessageRole.fromAiMessageRole] / [MessageRole.fromLlmRole] (and the
/// inverse helpers) to migrate existing code incrementally.
enum MessageRole {
  /// End-user message.
  user,

  /// Assistant / model response.
  assistant,

  /// System prompt or instruction.
  system,

  /// Tool / function-call result.
  tool,
}
