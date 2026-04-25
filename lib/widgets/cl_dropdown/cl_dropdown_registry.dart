/// Abstract interface that all DropdownState instances implement to support
/// programmatic item selection (e.g., from AI assistant custom tools).
abstract interface class ISelectableDropdown {
  Future<bool> selectByName(String name);
}

/// Singleton registry mapping CLDropdown hint labels → their DropdownState.
/// Used by the AI assistant's `select_dropdown_item` tool to bypass the UI
/// and select items programmatically without needing to tap/open overlays.
class CLDropdownRegistry {
  CLDropdownRegistry._();
  static final CLDropdownRegistry instance = CLDropdownRegistry._();

  final Map<String, ISelectableDropdown> _registry = {};

  // Strip trailing asterisks added by CLTextField when validators include required.
  static String _normalize(String hint) =>
      hint.trimRight().replaceAll(RegExp(r'\*+$'), '').trim();

  void register(String hint, ISelectableDropdown state) {
    _registry[_normalize(hint)] = state;
  }

  void unregister(String hint) {
    _registry.remove(_normalize(hint));
  }

  /// Selects [itemName] in the dropdown identified by [hint].
  /// Loads async items if needed. Returns true on success.
  Future<bool> selectByName(String hint, String itemName) async {
    final state = _registry[_normalize(hint)];
    if (state == null) return false;
    return state.selectByName(itemName);
  }

  /// All currently registered dropdown hint labels (useful for debugging).
  List<String> get registeredHints => List.unmodifiable(_registry.keys);
}
