// Part of [AiAssistantController] — pause-and-resume coordination.
//
// Responsibilities:
// - hand_off_to_user: route-listener-driven pause until the user taps the
//   real action button (or cancels) on the host app screen.
// - ask_user: pause the agent until the user types a reply, with auto-parsed
//   numbered/lettered options and yes/no confirmation buttons.
// - Tool confirmation gate: navigation tools require user approval first.
// - Stop request and the 3-minute processing watchdog timer.
// - Post-task suggestion chips builder.
part of '../ai_assistant_controller.dart';

/// Pattern for numbered options: "1) Option text" or "1. Option text"
final RegExp _kNumberedOptionPattern = RegExp(
  r'^\s*(\d+)[.)]\s+(.+)$',
  multiLine: true,
);

/// Pattern for lettered options: "a) Option text" or "A. Option text"
final RegExp _kLetteredOptionPattern = RegExp(
  r'^\s*([a-zA-Z])[.)]\s+(.+)$',
  multiLine: true,
);

/// Words that suggest a yes/no or confirm/cancel question.
const List<String> _kConfirmPatterns = [
  'confirm',
  'proceed',
  'continue',
  'should i',
  'shall i',
  'do you want',
  'would you like',
  'is that correct',
  'is this correct',
  'are you sure',
];

extension _HandoffOrchestrator on AiAssistantController {
  // ---------------------------------------------------------------------------
  // Navigation confirmation
  // ---------------------------------------------------------------------------

  /// Called by [ToolRegistry] when a confirmation-required tool is invoked.
  Future<bool> _handleToolConfirmationImpl(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    _waitingForConfirmation = true;
    _confirmationCompleter = Completer<bool>();

    // Pause the processing timer — user has unlimited time to decide.
    _processingTimer?.cancel();

    final description = _describeToolAction(toolName, args);
    _messages.add(
      AiChatMessage(
        id: _uuid.v4(),
        role: AiMessageRole.assistant,
        content: description,
        timestamp: DateTime.now(),
        richContent: [
          const CardContent(
            title: 'Autorizzazione richiesta',
            subtitle: 'Autorizzi Skill Assistant a navigare in autonomia?',
          ),
          const ButtonsContent(
            buttons: [
              ChatButton(label: 'Autorizza', style: ChatButtonStyle.success),
              ChatButton(label: 'Annulla', style: ChatButtonStyle.destructive),
            ],
          ),
        ],
      ),
    );
    _safeNotify();

    try {
      final approved = await _confirmationCompleter!.future;
      _waitingForConfirmation = false;
      if (approved) _startProcessingTimer();
      _safeNotify();
      return approved;
    } catch (_) {
      _waitingForConfirmation = false;
      _safeNotify();
      return false;
    }
  }

  /// Build a user-friendly Italian description of a tool action.
  String _describeToolAction(String toolName, Map<String, dynamic> args) {
    return switch (toolName) {
      'navigate_to_route' =>
        'Skill Assistant vuole navigare a "${args['routeName'] ?? 'pagina sconosciuta'}".',
      _ => 'Skill Assistant vuole eseguire: $toolName.',
    };
  }

  // ---------------------------------------------------------------------------
  // Processing timeout — pauses during user-facing waits
  // ---------------------------------------------------------------------------

  /// Start (or restart) the processing timer.
  void _startProcessingTimerImpl() {
    _processingTimer?.cancel();
    _processingTimer = Timer(const Duration(minutes: 3), () {
      if (_isProcessing && !_isHandoffMode && !_waitingForUserResponse) {
        AiLogger.log('Processing timeout (3 min active)', tag: 'Controller');
        _emit(AiEventType.agentTimeout, {'actionCount': _actionSteps.length});
        _cancelRequested = true;
        _safeNotify();
      }
    });
  }

  void _pauseProcessingTimerImpl() => _processingTimer?.cancel();

  /// Resume with a fresh 3-minute window.
  void _resumeProcessingTimerImpl() => _startProcessingTimer();

  // ---------------------------------------------------------------------------
  // Handoff mode — user taps the real button
  // ---------------------------------------------------------------------------

  /// Handler for the hand_off_to_user tool.
  Future<String> _handleHandoffImpl(String buttonLabel, String summary) async {
    AiLogger.log(
      'hand_off_to_user: button="$buttonLabel", summary="$summary"',
      tag: 'Controller',
    );

    _isHandoffMode = true;
    _handoffButtonLabel = buttonLabel;
    _handoffSummary = summary;
    _progressText = null;
    _emit(AiEventType.handoffStarted, {
      'buttonLabel': buttonLabel,
      'summary': summary,
    });

    // Show the handoff message in the chat history.
    _messages.add(
      AiChatMessage(
        id: _uuid.v4(),
        role: AiMessageRole.assistant,
        content: 'Everything is ready! Tap "$buttonLabel" to confirm.',
        timestamp: DateTime.now(),
      ),
    );
    _safeNotify();

    // Set up a completer that resolves when the user acts.
    _handoffCompleter = Completer<String>();

    // Listen for route changes — if the route changes, the user likely
    // tapped the button and the app navigated to a confirmation/success screen.
    final routeBefore = AiNavigatorObserver.currentRoute;
    _handoffRouteListener = () {
      final routeNow = AiNavigatorObserver.currentRoute;
      if (routeNow != routeBefore &&
          _handoffCompleter != null &&
          !_handoffCompleter!.isCompleted) {
        AiLogger.log(
          'Handoff: route changed $routeBefore → $routeNow',
          tag: 'Controller',
        );
        _handoffCompleter!.complete(
          'User tapped the button. Screen changed from '
          '"$routeBefore" to "$routeNow". '
          'Call get_screen_content to see the result and report to the user.',
        );
      }
    };
    navigatorObserver.onRouteChanged = (route) {
      // Keep the original cache invalidation behavior.
      _contextCache.invalidateScreen();
      // Check for handoff resolution.
      _handoffRouteListener?.call();
    };

    // Pause the processing timer — user has unlimited time to act.
    _pauseProcessingTimer();

    try {
      // 5-minute timeout — if the user doesn't act, auto-cancel so the
      // agent doesn't hang indefinitely.
      final result = await _handoffCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          AiLogger.warn('Handoff timed out after 5 minutes', tag: 'Controller');
          return 'User did not act within 5 minutes. The handoff timed out. '
              'Inform the user the action was not completed and they can try again.';
        },
      );
      AiLogger.log('Handoff resolved: $result', tag: 'Controller');
      final resolution =
          result.contains('cancelled')
              ? 'cancelled'
              : result.contains('timed out')
              ? 'timeout'
              : result.contains('route changed') ||
                  result.contains('Screen changed')
              ? 'route_change'
              : 'manual';
      final routeAfter = AiNavigatorObserver.currentRoute;

      _emit(AiEventType.handoffCompleted, {
        'buttonLabel': buttonLabel,
        'summary': summary,
        'resolution': resolution,
        'routeBefore': routeBefore,
        'routeAfter': routeAfter,
        'userMessage': _currentTaskMessage,
        'wasVoice': _currentTaskIsVoice,
        'durationMs':
            _currentTaskStartedAt != null
                ? DateTime.now()
                    .difference(_currentTaskStartedAt!)
                    .inMilliseconds
                : null,
      });

      // On cancel, keep overlay so user can give new instructions.
      // On success (route change or manual Done), hide overlay so user
      // sees the app's confirmation/result screen.
      final wasCancelled = result.contains('cancelled');
      _exitHandoffMode(keepOverlay: wasCancelled);
      _resumeProcessingTimer();
      return result;
    } catch (e) {
      _exitHandoffMode(keepOverlay: true);
      _resumeProcessingTimer();
      rethrow;
    }
  }

  /// Exit handoff mode and restore normal state.
  void _exitHandoffModeImpl({bool keepOverlay = false}) {
    _isHandoffMode = false;
    _handoffButtonLabel = null;
    _handoffSummary = null;
    _handoffCompleter = null;
    _handoffRouteListener = null;
    // Restore the original route change callback.
    navigatorObserver.onRouteChanged = (_) => _contextCache.invalidateScreen();
    if (!keepOverlay) {
      _isOverlayVisible = false;
    }
    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // ask_user — pause agent and wait for user input
  // ---------------------------------------------------------------------------

  /// Handler for the ask_user tool.
  Future<String> _handleAskUserImpl(String question) async {
    AiLogger.log('ask_user: "$question"', tag: 'Controller');
    _emit(AiEventType.askUserStarted, {'question': question});
    _waitingForUserResponse = true;
    _progressText = null;

    // Auto-parse the question text into rich content with buttons.
    final richContent = _parseAskUserContent(question);

    // Show the question as an assistant message in the chat.
    _messages.add(
      AiChatMessage(
        id: _uuid.v4(),
        role: AiMessageRole.assistant,
        content: question,
        timestamp: DateTime.now(),
        richContent: richContent,
      ),
    );
    _safeNotify();

    // Pause the processing timer — user has unlimited time to respond.
    _pauseProcessingTimer();

    // Create a completer and wait for the user's response.
    _userResponseCompleter = Completer<String>();
    try {
      final response = await _userResponseCompleter!.future;
      AiLogger.log('ask_user response: "$response"', tag: 'Controller');
      _emit(AiEventType.askUserCompleted, {
        'question': question,
        'response': response,
      });
      _waitingForUserResponse = false;
      _safeNotify();
      _resumeProcessingTimer();
      return response;
    } catch (e) {
      _waitingForUserResponse = false;
      _safeNotify();
      _resumeProcessingTimer();
      rethrow;
    }
  }

  /// Parse an ask_user question into rich content with auto-detected buttons.
  List<ChatContent>? _parseAskUserContentImpl(String question) {
    // Try numbered options first.
    var matches = _kNumberedOptionPattern.allMatches(question).toList();
    if (matches.length >= 2) {
      return _buildOptionsContent(question, matches);
    }

    // Try lettered options.
    matches = _kLetteredOptionPattern.allMatches(question).toList();
    if (matches.length >= 2) {
      return _buildOptionsContent(question, matches);
    }

    // Try yes/no confirmation pattern.
    final lower = question.toLowerCase();
    for (final pattern in _kConfirmPatterns) {
      if (lower.contains(pattern)) {
        return [
          TextContent(question),
          const ButtonsContent(
            buttons: [
              ChatButton(
                label: 'Yes',
                style: ChatButtonStyle.success,
                icon: IconData(0xe156, fontFamily: 'MaterialIcons'), // check
              ),
              ChatButton(
                label: 'No',
                style: ChatButtonStyle.destructive,
                icon: IconData(0xe16a, fontFamily: 'MaterialIcons'), // close
              ),
            ],
          ),
        ];
      }
    }

    return null;
  }

  /// Build rich content from a question with extracted option matches.
  List<ChatContent> _buildOptionsContent(
    String question,
    List<RegExpMatch> matches,
  ) {
    // Extract the preamble — text before the first option.
    final firstMatchStart = matches.first.start;
    final preamble = question.substring(0, firstMatchStart).trim();

    // Extract option labels.
    final buttons =
        matches.map((m) {
          final label = m.group(2)!.trim();
          return ChatButton(label: label, style: ChatButtonStyle.primary);
        }).toList();

    return [
      if (preamble.isNotEmpty) TextContent(preamble),
      ButtonsContent(
        buttons: buttons,
        layout:
            buttons.any((b) => b.label.length > 30)
                ? ButtonLayout.column
                : ButtonLayout.wrap,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Post-task suggestion chips
  // ---------------------------------------------------------------------------

  /// Build contextual suggestion chips based on what the agent just did.
  ButtonsContent? _buildSuggestionChipsImpl(AgentResponse response) {
    if (_config.postTaskChipsBuilder == null) return null;

    // Don't add suggestions to very short confirmations — they auto-close.
    if (response.text.length <= 40) return null;

    // Don't add suggestions if no actions were performed (simple text response).
    if (response.actions.isEmpty) return null;

    // Don't add suggestions if the response is a question — the user needs
    // to answer, not navigate away.
    final trimmedText = response.text.trim();
    if (trimmedText.endsWith('?')) return null;

    return _config.postTaskChipsBuilder!(response);
  }

  // ---------------------------------------------------------------------------
  // Cancellation
  // ---------------------------------------------------------------------------

  /// Request the agent to stop execution.
  void _requestStopImpl() {
    AiLogger.log('Stop requested by user', tag: 'Controller');
    _emit(AiEventType.stopRequested);
    _cancelRequested = true;

    // If waiting for user response, resolve the completer so the agent
    // doesn't hang forever.
    if (_waitingForUserResponse &&
        _userResponseCompleter != null &&
        !_userResponseCompleter!.isCompleted) {
      _userResponseCompleter!.complete('The user stopped the task.');
      _userResponseCompleter = null;
      _waitingForUserResponse = false;
    }
    // If in handoff mode, cancel it and close the overlay.
    if (_isHandoffMode) {
      cancelHandoff();
      _isOverlayVisible = false;
    }
    _safeNotify();
  }

  /// Resolve handoff from the UI — user tapped "Done" on the indicator.
  void _resolveHandoffImpl() {
    if (_handoffCompleter != null && !_handoffCompleter!.isCompleted) {
      AiLogger.log('Handoff: user confirmed manually', tag: 'Controller');
      _handoffCompleter!.complete(
        'User confirmed they completed the action. '
        'Call get_screen_content to see the result and report to the user.',
      );
    }
  }

  /// Cancel handoff from the UI — user tapped "Cancel" on the indicator.
  void _cancelHandoffImpl() {
    if (_handoffCompleter != null && !_handoffCompleter!.isCompleted) {
      AiLogger.log('Handoff: user cancelled', tag: 'Controller');
      _handoffCompleter!.complete(
        'User cancelled the action. Do NOT proceed. '
        'Inform the user the action was cancelled.',
      );
    }
  }
}
