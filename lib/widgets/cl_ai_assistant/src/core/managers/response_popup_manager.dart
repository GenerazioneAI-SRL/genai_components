// Part of [AiAssistantController] — response popup + overlay visibility.
//
// Responsibilities:
// - Classifying the agent's final response (action vs info vs error) to
//   decide whether to auto-close the overlay and surface a popup.
// - Showing/dismissing/expanding the compact response popup above the FAB.
// - Toggling and opening/closing the chat overlay, including stop-on-close
//   behavior when the agent is mid-run.
part of '../ai_assistant_controller.dart';

extension _ResponsePopupManager on AiAssistantController {
  // ---------------------------------------------------------------------------
  // Response classification
  // ---------------------------------------------------------------------------

  /// Classify a completed agent response for post-task UI behavior.
  AiResponseType _classifyResponseImpl(
    AgentResponse response, {
    bool isError = false,
  }) {
    if (isError) return AiResponseType.error;

    // Tools that MODIFY app state or perform user-requested actions.
    const mutatingTools = {
      'tap_element',
      'set_text',
      'long_press_element',
      'increase_value',
      'decrease_value',
      'navigate_to_route',
      'go_back',
    };
    final hasMutatingAction = response.actions.any(
      (a) => mutatingTools.contains(a.toolName),
    );

    // Info-query pattern: agent navigated somewhere THEN read the screen to
    // extract data (e.g. "what's my balance?" → navigate → get_screen_content).
    // These should stay open even if the response is short.
    final isInfoPattern =
        response.actions.isNotEmpty &&
        response.actions.last.toolName == 'get_screen_content' &&
        !response.actions.any(
          (a) =>
              a.toolName == 'tap_element' ||
              a.toolName == 'set_text' ||
              a.toolName == 'long_press_element',
        );

    // Short response + mutating tools = action confirmation ("Added to cart!")
    // Long response or no mutating tools = informational (needs reading time)
    // Info pattern (navigate → read) = informational regardless of length.
    if (hasMutatingAction && response.text.length <= 80 && !isInfoPattern) {
      return AiResponseType.actionComplete;
    }
    return AiResponseType.infoResponse;
  }

  // ---------------------------------------------------------------------------
  // Response popup
  // ---------------------------------------------------------------------------

  /// Show the response popup above the FAB with the given text and type.
  void _showResponsePopupImpl(String text, AiResponseType type) {
    _emit(AiEventType.responsePopupShown, {
      'responseType': type.name,
      'text': text.length > 100 ? '${text.substring(0, 100)}...' : text,
    });
    _isResponsePopupVisible = true;
    _responsePopupType = type;
    _responsePopupText = text;
    _hasUnreadResponse = false; // The popup IS the notification.

    // Auto-dismiss: action confirmations after 8s, info stays until dismissed.
    _responsePopupTimer?.cancel();
    if (type == AiResponseType.actionComplete) {
      _responsePopupTimer = Timer(
        const Duration(seconds: 8),
        dismissResponsePopup,
      );
    }
    _safeNotify();
  }

  /// Dismiss the response popup (called by timer, swipe, or tap-away).
  void _dismissResponsePopupImpl() {
    if (!_isResponsePopupVisible) return;
    _responsePopupTimer?.cancel();
    _isResponsePopupVisible = false;
    _responsePopupText = null;
    _safeNotify();
  }

  /// Tap the response popup to re-open the full chat.
  void _expandResponsePopupImpl() {
    dismissResponsePopup();
    showOverlay();
  }

  // ---------------------------------------------------------------------------
  // Overlay control
  // ---------------------------------------------------------------------------

  /// Toggle the chat overlay visibility.
  void _toggleOverlayImpl() {
    if (_isResponsePopupVisible) {
      expandResponsePopup();
      return;
    }
    _isOverlayVisible = !_isOverlayVisible;
    if (_isOverlayVisible) {
      _hasUnreadResponse = false;
      _emit(AiEventType.chatOverlayOpened);
    } else {
      _emit(AiEventType.chatOverlayClosed, {'wasProcessing': _isProcessing});
      if (_isProcessing) requestStop();
    }
    _safeNotify();
  }

  /// Show the chat overlay. Dismisses any visible response popup.
  void _showOverlayImpl() {
    dismissResponsePopup();
    _isOverlayVisible = true;
    _hasUnreadResponse = false;
    _safeNotify();
  }

  /// Hide the chat overlay. Stops any in-progress agent execution.
  void _hideOverlayImpl() {
    _isOverlayVisible = false;
    if (_isProcessing) {
      requestStop();
    }
    _safeNotify();
  }
}
