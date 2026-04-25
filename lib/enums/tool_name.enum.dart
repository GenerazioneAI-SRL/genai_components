/// AI tool-call names used by the assistant agent.
///
/// Replaces string magic across AI/agent code. Use [ToolName.name] to obtain
/// the canonical wire string (matches the existing string identifiers exactly,
/// e.g. `ToolName.tapElement.wireName == 'tap_element'`).
///
/// Backed by snake_case wire identifiers via [wireName]; Dart enum members use
/// the project's lowerCamelCase convention.
enum ToolName {
  /// Ask the end-user a clarification question.
  askUser('ask_user'),

  /// Decrease a numeric field's value.
  decreaseValue('decrease_value'),

  /// Capture the current screen as structured content for the model.
  getScreenContent('get_screen_content'),

  /// Navigate back in the router stack.
  goBack('go_back'),

  /// Hand control of the conversation back to the user.
  handOffToUser('hand_off_to_user'),

  /// Increase a numeric field's value.
  increaseValue('increase_value'),

  /// Long-press a UI element.
  longPressElement('long_press_element'),

  /// Navigate to a named route.
  navigateToRoute('navigate_to_route'),

  /// Scroll a scrollable region.
  scroll('scroll'),

  /// Set text in a text field.
  setText('set_text'),

  /// Tap a UI element.
  tapElement('tap_element');

  /// Canonical wire identifier (snake_case) used by LLM providers and logs.
  final String wireName;

  const ToolName(this.wireName);

  /// Resolve a wire identifier (e.g. `'tap_element'`) to its [ToolName].
  ///
  /// Throws [ArgumentError] when no enum value matches.
  static ToolName fromString(String name) {
    for (final v in ToolName.values) {
      if (v.wireName == name || v.name == name) return v;
    }
    throw ArgumentError('Unknown tool name: $name');
  }

  /// Same as [fromString] but returns `null` instead of throwing.
  static ToolName? tryFromString(String name) {
    try {
      return fromString(name);
    } catch (_) {
      return null;
    }
  }
}
