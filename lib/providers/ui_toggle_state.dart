import 'package:flutter/material.dart';
import '../app/cl_app_config.dart';

/// Granular state for UI toggles (AI chat panel, notification drawer, AI button visibility/position).
///
/// Part of the AppState decomposition introduced in 4.4.x. Prefer this over
/// `AppState` for new code touching the AI chat panel or notification drawer.
class UiToggleState extends ChangeNotifier {
  bool _aiChatOpen = false;
  bool _fromNotification = false;
  final bool _showAiButton = false;
  final AiButtonPosition _aiButtonPosition = AiButtonPosition.header;
  bool _disposed = false;

  /// Whether the AI chat panel is currently open.
  bool get aiChatOpen => _aiChatOpen;

  /// Whether the end drawer was triggered by an incoming notification.
  bool get fromNotification => _fromNotification;

  /// Whether the floating AI button should be displayed.
  bool get showAiButton => _showAiButton;

  /// Where the AI button is anchored (header vs floating).
  AiButtonPosition get aiButtonPosition => _aiButtonPosition;

  /// Toggle the AI chat panel open/closed.
  void toggleAiChat() {
    _aiChatOpen = !_aiChatOpen;
    notifyListeners();
  }

  /// Explicit setter for the AI chat panel state.
  set aiChatOpen(bool value) {
    if (_aiChatOpen == value) return;
    _aiChatOpen = value;
    notifyListeners();
  }

  /// Update the notification-origin flag for the end drawer.
  set fromNotification(bool value) {
    if (_fromNotification == value) return;
    _fromNotification = value;
    notifyListeners();
  }

  /// Mirror of [AppState.changeEndDrawer] for compatibility.
  void changeEndDrawer(bool value) {
    fromNotification = value;
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
