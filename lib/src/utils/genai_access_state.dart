/// Visibility / interaction policy for components driven by user permissions
/// or feature gating (§7.8.3).
enum GenaiAccessState {
  /// Render normally.
  allowed,

  /// Render disabled with explanatory tooltip ([accessReason]).
  disabledNoPermission,

  /// Render disabled with upgrade CTA (e.g. "Disponibile nel piano …").
  disabledUpgrade,

  /// Do not render at all.
  hidden,
}

extension GenaiAccessStateX on GenaiAccessState {
  bool get isVisible => this != GenaiAccessState.hidden;
  bool get isInteractive => this == GenaiAccessState.allowed;
  bool get isDisabled => this == GenaiAccessState.disabledNoPermission || this == GenaiAccessState.disabledUpgrade;
}
