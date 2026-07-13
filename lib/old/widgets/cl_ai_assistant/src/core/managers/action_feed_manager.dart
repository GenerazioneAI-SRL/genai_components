// Part of [AiAssistantController] — action feed + ReAct streaming hooks.
//
// Responsibilities:
// - Reacting to tool start/complete events from the ReAct agent loop.
// - Maintaining the live action steps list shown in the feed.
// - Filtering and routing the LLM's progressive thought text.
// - Building the [AppContextSnapshot] passed to the agent each iteration.
// - Tool classification (internal vs screen-changing).
part of '../ai_assistant_controller.dart';

/// Tools that are internal to the agent (observations, not user-visible actions).
const Set<String> _kInternalTools = {'get_screen_content'};

/// Tools that change the screen and require cache invalidation.
const Set<String> _kScreenChangingTools = {
  'tap_element',
  'set_text',
  'scroll',
  'navigate_to_route',
  'go_back',
  'long_press_element',
  'increase_value',
  'decrease_value',
};

extension _ActionFeedManager on AiAssistantController {
  /// Called when a tool starts executing in the ReAct loop.
  void _onToolStartImpl(String toolName, Map<String, dynamic> args) {
    _emit(AiEventType.toolExecutionStarted, {
      'toolName': toolName,
      'arguments': args,
    });

    // Internal tools, ask_user, and hand_off_to_user are not shown in the action feed.
    if (_kInternalTools.contains(toolName) ||
        toolName == 'ask_user' ||
        toolName == 'hand_off_to_user') {
      return;
    }

    // Track when a screen-changing tool is executed for action mode.
    if (_kScreenChangingTools.contains(toolName)) {
      _hasExecutedScreenChangingTool = true;
    }

    // Show the action feed on the first user-facing tool call.
    if (!_isActionFeedVisible) {
      _isActionFeedVisible = true;
    }
    _actionSteps.add(ActionStep.started(toolName: toolName, arguments: args));
    // Haptic tick on each visible action.
    if (_config.enableHaptics) HapticFeedback.selectionClick();
    _safeNotify();
  }

  /// Called when a tool finishes executing in the ReAct loop.
  void _onToolCompleteImpl(
    String toolName,
    Map<String, dynamic> args,
    ToolResult result,
  ) {
    _emit(AiEventType.toolExecutionCompleted, {
      'toolName': toolName,
      'arguments': args,
      'success': result.success,
      if (!result.success) 'error': result.error,
    });

    // Emit semantic events for specific tool completions.
    if (toolName == 'get_screen_content' && result.success) {
      _emit(AiEventType.screenContentCaptured, {
        'route': AiNavigatorObserver.currentRoute,
      });
    }
    if (toolName == 'navigate_to_route') {
      _emit(AiEventType.navigationExecuted, {
        'route': args['route_name'] ?? args['routeName'] ?? '',
        'success': result.success,
      });
    }

    // Invalidate screen cache after actions that change the screen,
    // so the next iteration's context rebuild captures fresh state.
    if (_kScreenChangingTools.contains(toolName)) {
      _contextCache.invalidateScreen();
    }

    // Internal tools, ask_user, and hand_off_to_user are not shown in the action feed.
    if (_kInternalTools.contains(toolName) ||
        toolName == 'ask_user' ||
        toolName == 'hand_off_to_user') {
      return;
    }

    // Find the matching in-progress step and mark it completed/failed.
    final index = _actionSteps.lastIndexWhere(
      (s) => s.toolName == toolName && s.status == ActionStepStatus.inProgress,
    );
    if (index != -1) {
      _actionSteps[index] = _actionSteps[index].copyWith(
        status:
            result.success
                ? ActionStepStatus.completed
                : ActionStepStatus.failed,
        error: result.error,
        completedAt: DateTime.now(),
      );
      _safeNotify();
    }
  }

  /// Called when the LLM emits reasoning/status text alongside tool calls.
  void _onThoughtImpl(String thought) {
    final sanitized = AiAssistantController._sanitizeThought(thought);
    if (sanitized == null) return; // Entirely meta — don't update.

    _progressText = sanitized;

    // Show the action feed if not already visible (thought can arrive
    // before the first tool call starts).
    if (!_isActionFeedVisible) {
      _isActionFeedVisible = true;
    }

    // Voice progress: speak sanitized thoughts aloud (throttled to max
    // once per 4 seconds) so the user hears what the agent is doing.
    if (_currentTaskIsVoice &&
        _voiceOutput != null &&
        _config.enableTts &&
        sanitized.length > 5) {
      final now = DateTime.now();
      if (_lastSpokenProgress == null ||
          now.difference(_lastSpokenProgress!) > const Duration(seconds: 4)) {
        _lastSpokenProgress = now;
        _emit(AiEventType.ttsStarted, {'text': sanitized, 'isProgress': true});
        _voiceOutput!.speak(sanitized);
      }
    }

    _safeNotify();
  }

  /// Build the full app context snapshot for the LLM.
  Future<AppContextSnapshot> _buildContextImpl() async {
    final currentRoute = AiNavigatorObserver.currentRoute;

    // Use the cache for screen context.
    var screenContext = _contextCache.getScreenContext(currentRoute);

    // Screen stabilization: after a cache rebuild (screen was dirty),
    // wait briefly and re-capture to handle content that loads asynchronously
    // (e.g. ride options after confirming a destination, search results, etc.).
    // Skip if the screen already has enough elements (content loaded fast).
    if (_contextCache.wasDirty && screenContext.elements.length <= 5) {
      final initialElements = screenContext.elements.length;
      int stabilizationAttempts = 0;
      for (int attempt = 0; attempt < 4; attempt++) {
        await Future.delayed(const Duration(milliseconds: 500));
        _contextCache.invalidateScreen();
        final fresh = _contextCache.getScreenContext(currentRoute);
        final oldCount = screenContext.elements.length;
        final newCount = fresh.elements.length;
        stabilizationAttempts++;
        if (newCount > 5) {
          screenContext = fresh;
          break;
        }
        AiLogger.log(
          'Screen stabilization: element count '
          '$oldCount → $newCount, '
          '${newCount <= 5 ? 'too few elements, ' : ''}'
          'retrying (attempt ${attempt + 1}/4)',
          tag: 'Controller',
        );
        screenContext = fresh;
      }
      _emit(AiEventType.screenStabilizationAttempted, {
        'route': currentRoute,
        'attempts': stabilizationAttempts,
        'initialElements': initialElements,
        'finalElements': screenContext.elements.length,
      });
    }

    // Cache the current screen knowledge for future cross-screen commands.
    if (currentRoute != null) {
      AiNavigatorObserver.cacheScreenKnowledge(currentRoute, screenContext);
    }

    // Get global state (also via cache).
    final globalState = await _contextCache.getGlobalContext();

    // Capture screenshot if enabled and the screen changed.
    // Only capture on dirty rebuilds to avoid redundant captures.
    Uint8List? screenshot;
    if (_screenshotCapture != null && _contextCache.wasDirty) {
      screenshot = await _screenshotCapture!.capture();
      AiLogger.log(
        'Screenshot captured: ${screenshot != null ? '${(screenshot.length / 1024).toStringAsFixed(1)}KB' : 'failed'}',
        tag: 'Controller',
      );
    }

    return AppContextSnapshot(
      currentRoute: currentRoute,
      navigationStack: AiNavigatorObserver.routeStack,
      screenContext: screenContext,
      availableRoutes: _routeDiscovery.getAvailableRoutes(),
      globalState: globalState.isNotEmpty ? globalState : null,
      screenKnowledge: AiNavigatorObserver.screenKnowledge,
      appManifest: _config.appManifest,
      screenshot: screenshot,
    );
  }

  /// Dismiss the action feed manually (e.g. user taps away).
  void _dismissActionFeedImpl() {
    _isActionFeedVisible = false;
    _safeNotify();
  }
}
