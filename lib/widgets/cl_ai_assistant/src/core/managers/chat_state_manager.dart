// Part of [AiAssistantController] — chat message lifecycle.
//
// Responsibilities:
// - Sending user messages through the ReAct agent.
// - Handling interactive button taps in chat bubbles.
// - Clearing the conversation and resetting all transient state.
//
// Implemented as an extension over the private controller surface so the
// controller class stays a single declaration with no public API change.
part of '../ai_assistant_controller.dart';

extension _ChatStateManager on AiAssistantController {
  /// Send a text message from the user.
  Future<void> _sendMessageImpl(String text, {bool isVoice = false}) async {
    if (text.trim().isEmpty) return;

    // If the agent is waiting for user response (ask_user tool), complete
    // the completer with the user's message instead of starting a new run.
    if (_waitingForUserResponse &&
        _userResponseCompleter != null &&
        !_userResponseCompleter!.isCompleted) {
      AiLogger.log('User response to ask_user: "$text"', tag: 'Controller');
      _messages.add(
        AiChatMessage(
          id: _uuid.v4(),
          role: AiMessageRole.user,
          content: text,
          timestamp: DateTime.now(),
          isVoice: isVoice,
        ),
      );
      _safeNotify();
      _userResponseCompleter!.complete(text);
      _userResponseCompleter = null;
      return;
    }

    // Don't start a new run while already processing — queue for later.
    if (_isProcessing) {
      AiLogger.log('Queuing message (agent busy): "$text"', tag: 'Controller');
      _pendingMessage = text;
      _pendingIsVoice = isVoice;
      return;
    }

    // Dismiss any visible popup and ensure overlay is open for the new request.
    if (_isResponsePopupVisible) dismissResponsePopup();
    if (!embedMode && !_isOverlayVisible) {
      _isOverlayVisible = true;
      _hasUnreadResponse = false;
    }

    AiLogger.log('sendMessage: "$text" (voice=$isVoice)', tag: 'Controller');
    _emit(AiEventType.messageSent, {'message': text, 'isVoice': isVoice});

    // Track whether this task originated from voice for TTS/haptics.
    _currentTaskIsVoice = isVoice;
    _lastSpokenProgress = null;
    _partialTranscription = null;

    // Store task context for handoff event enrichment.
    _currentTaskMessage = text;
    _currentTaskStartedAt = DateTime.now();

    // Add user message to chat.
    _messages.add(
      AiChatMessage(
        id: _uuid.v4(),
        role: AiMessageRole.user,
        content: text,
        timestamp: DateTime.now(),
        isVoice: isVoice,
      ),
    );
    _isProcessing = true;

    // Reset action feed and cancellation for this new request.
    _actionSteps.clear();
    _isActionFeedVisible = false;
    _finalResponseText = null;
    _progressText = null;
    _cancelRequested = false;
    _hasExecutedScreenChangingTool = false;
    _safeNotify();

    final stopwatch = Stopwatch()..start();
    try {
      // Start the processing timer — fires after 3 minutes of ACTIVE agent
      // work. Paused automatically during handoff and ask_user waits so the
      // user has unlimited time to respond.
      _startProcessingTimer();
      _emit(AiEventType.conversationStarted, {
        'message': text,
        'isVoice': isVoice,
        'conversationLength': _messages.length,
      });

      // Run the ReAct agent with streaming callbacks for the action feed.
      // The context builder is called each iteration so the LLM always
      // sees the current screen state after actions change the UI.
      // A generous 10-minute safety timeout prevents runaway futures.
      final response = await _agent
          .run(
            userMessage: text,
            contextBuilder: _buildContext,
            onToolStart: _onToolStart,
            onToolComplete: _onToolComplete,
            onThought: _onThought,
            shouldCancel: () => _cancelRequested,
            onEvent: _config.onEvent,
          )
          .timeout(
            const Duration(minutes: 10),
            onTimeout:
                () => const AgentResponse(
                  text: 'The session expired. Please try again.',
                ),
          );

      // If tools were executed, show the final response in the feed briefly.
      if (_isActionFeedVisible) {
        _finalResponseText = response.text;
        _safeNotify();

        // Brief pause so the user sees the completed feed + final text.
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Transition: hide action feed, add the normal chat bubble.
      _isActionFeedVisible = false;
      AiLogger.log(
        'Agent response: "${response.text.length > 100 ? '${response.text.substring(0, 100)}...' : response.text}" '
        '(${response.actions.length} actions)',
        tag: 'Controller',
      );
      // Build rich content for the response — include suggestion chips
      // for successful completions so the user has quick follow-up options.
      // Also detect questions-as-text (LLM returned a question without using
      // ask_user) and auto-generate interactive buttons so the user can tap
      // to respond instead of typing.
      final responseType = _classifyResponse(response);
      List<ChatContent>? responseRichContent;
      if (responseType != AiResponseType.error) {
        final suggestions = _buildSuggestionChips(response);
        if (suggestions != null) {
          responseRichContent = [TextContent(response.text), suggestions];
        } else {
          // If no suggestion chips and the response looks like a question
          // with embedded options, auto-generate interactive buttons.
          // This handles cases where the LLM returns a question as plain
          // text instead of using ask_user — the user can still tap to reply.
          final trimmedText = response.text.trim();
          if (trimmedText.endsWith('?') || trimmedText.contains('?')) {
            responseRichContent = _parseAskUserContent(response.text);
          }
        }
      }

      _messages.add(
        AiChatMessage(
          id: _uuid.v4(),
          role: AiMessageRole.assistant,
          content: response.text,
          timestamp: DateTime.now(),
          actions: response.actions.isNotEmpty ? response.actions : null,
          richContent: responseRichContent,
        ),
      );

      stopwatch.stop();
      _emit(AiEventType.conversationCompleted, {
        'response':
            response.text.length > 200
                ? '${response.text.substring(0, 200)}...'
                : response.text,
        'responseType': responseType.name,
        'totalActions': response.actions.length,
        'durationMs': stopwatch.elapsedMilliseconds,
        'wasVoice': isVoice,
      });
      _emit(AiEventType.messageReceived, {
        'response':
            response.text.length > 200
                ? '${response.text.substring(0, 200)}...'
                : response.text,
        'responseType': responseType.name,
        'actionCount': response.actions.length,
      });

      // Post-task behavior depends on response type:
      //
      // ACTION COMPLETE → auto-close overlay, show popup ("Added to cart!")
      //   The user's next step is to interact with the APP, not the agent.
      //
      // INFO RESPONSE → overlay STAYS OPEN for follow-up conversation
      //   The user is talking to the agent, not the app. They'll want to
      //   read the response and might ask follow-ups.
      //
      // ERROR → overlay stays open for retry/correction.
      //
      // If overlay was already hidden (e.g. after handoff), show popup
      // regardless of type since the user needs to see the result somewhere.
      if (_config.autoCloseOnComplete &&
          _isOverlayVisible &&
          responseType == AiResponseType.actionComplete) {
        // Auto-close: agent did something, user needs to see/interact with the app.
        _isOverlayVisible = false;
        _safeNotify();
        await Future.delayed(const Duration(milliseconds: 350));
        if (!_disposed) _showResponsePopup(response.text, responseType);
      } else if (!_isOverlayVisible) {
        // Overlay was already hidden (e.g. after handoff success) — show popup.
        _showResponsePopup(response.text, responseType);
      }
      // Info responses and errors: overlay stays open — user continues chatting.

      // If the user spoke, speak a concise summary back and provide haptic.
      if (_currentTaskIsVoice && _voiceOutput != null) {
        if (_config.enableHaptics) HapticFeedback.heavyImpact();
        if (_config.enableTts) {
          _emit(AiEventType.ttsStarted, {
            'text':
                response.text.length > 100
                    ? '${response.text.substring(0, 100)}...'
                    : response.text,
            'isProgress': false,
          });
          _voiceOutput!.speakSummary(response.text);
        }
      }
    } catch (e, stack) {
      AiLogger.error(
        'sendMessage failed',
        error: e,
        stackTrace: stack,
        tag: 'Controller',
      );
      stopwatch.stop();
      _emit(AiEventType.conversationError, {
        'error': e.toString(),
        'durationMs': stopwatch.elapsedMilliseconds,
      });
      _isActionFeedVisible = false;
      final errorMsg =
          _currentTaskIsVoice
              ? AiAssistantController._friendlyVoiceError(e)
              : AiAssistantController._friendlyError(e);
      _messages.add(
        AiChatMessage(
          id: _uuid.v4(),
          role: AiMessageRole.assistant,
          content: errorMsg,
          timestamp: DateTime.now(),
        ),
      );
      // Speak the error if this was a voice task.
      if (_currentTaskIsVoice && _voiceOutput != null && _config.enableTts) {
        _voiceOutput!.speak(errorMsg);
      }
    } finally {
      _processingTimer?.cancel();
      _isProcessing = false;
      _actionSteps.clear();
      _finalResponseText = null;
      _progressText = null;
      _waitingForUserResponse = false;
      _cancelRequested = false;
      _hasExecutedScreenChangingTool = false;
      if (_isHandoffMode) _exitHandoffMode(keepOverlay: true);
      _safeNotify();

      // Drain the pending message queue — process next queued message.
      if (_pendingMessage != null && !_disposed) {
        final queued = _pendingMessage!;
        final queuedVoice = _pendingIsVoice;
        _pendingMessage = null;
        _pendingIsVoice = false;
        // Schedule after current microtask to avoid re-entrancy.
        Future.microtask(() => sendMessage(queued, isVoice: queuedVoice));
      }
    }
  }

  /// Called when the user taps an interactive button in a chat message.
  void _handleButtonTapImpl(
    AiChatMessage message,
    ChatButton button,
    int buttonIndex,
  ) {
    // Disable all buttons in this message and highlight the tapped one.
    message.buttonsDisabled = true;
    message.tappedButtonIndex = buttonIndex;
    _emit(AiEventType.buttonTapped, {
      'buttonLabel': button.label,
      'wasAskUserResponse': _waitingForUserResponse,
    });
    _safeNotify();

    // If the agent is waiting for navigation confirmation, resolve it.
    if (_waitingForConfirmation &&
        _confirmationCompleter != null &&
        !_confirmationCompleter!.isCompleted) {
      final approved = buttonIndex == 0; // 0 = "Autorizza", 1 = "Annulla"
      AiLogger.log(
        'Button tap resolving confirmation: ${approved ? "approved" : "denied"}',
        tag: 'Controller',
      );
      _confirmationCompleter!.complete(approved);
      _confirmationCompleter = null;
      return;
    }

    // If the agent is waiting for user input (ask_user), resolve the
    // completer with the button label instead of starting a new run.
    if (_waitingForUserResponse &&
        _userResponseCompleter != null &&
        !_userResponseCompleter!.isCompleted) {
      AiLogger.log(
        'Button tap resolving ask_user: "${button.label}"',
        tag: 'Controller',
      );
      _messages.add(
        AiChatMessage(
          id: _uuid.v4(),
          role: AiMessageRole.user,
          content: button.label,
          timestamp: DateTime.now(),
        ),
      );
      _safeNotify();
      _userResponseCompleter!.complete(button.label);
      _userResponseCompleter = null;
      return;
    }

    // Otherwise, send the button label as a new user message.
    sendMessage(button.label);
  }

  /// Clear the conversation and start fresh.
  void _clearConversationImpl() {
    _emit(AiEventType.conversationCleared, {'messageCount': _messages.length});
    // If processing, stop first.
    if (_isProcessing) {
      _cancelRequested = true;
    }
    _messages.clear();
    _memory.clear();
    _actionSteps.clear();
    _isActionFeedVisible = false;
    _finalResponseText = null;
    _progressText = null;
    _waitingForUserResponse = false;
    _cancelRequested = false;
    _hasExecutedScreenChangingTool = false;
    _currentTaskIsVoice = false;
    _lastSpokenProgress = null;
    _partialTranscription = null;
    _pendingMessage = null;
    _pendingIsVoice = false;
    _hasUnreadResponse = false;
    // Resolve any pending completers to prevent dangling futures.
    if (_userResponseCompleter != null &&
        !_userResponseCompleter!.isCompleted) {
      _userResponseCompleter!.completeError(StateError('Conversation cleared'));
    }
    _userResponseCompleter = null;
    if (_isHandoffMode) _exitHandoffMode(keepOverlay: true);
    dismissResponsePopup();
    _processingTimer?.cancel();
    _safeNotify();
  }
}
