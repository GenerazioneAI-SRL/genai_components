import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../action/action_executor.dart';
import '../context/ai_navigator_observer.dart';
import '../context/context_cache.dart';
import '../context/context_invalidator.dart';
import '../context/route_discovery.dart';
import '../context/screenshot_capture.dart';
import '../context/semantics_walker.dart';
import '../llm/conversation_memory.dart';
import '../llm/react_agent.dart';
import '../models/action_step.dart';
import '../models/app_context_snapshot.dart';
import '../models/chat_content.dart';
import '../models/chat_message.dart';
import '../tools/built_in_tools.dart';
import '../tools/tool_result.dart';
import '../tools/tool_registry.dart';
import '../voice/voice_input_service.dart';
import '../voice/voice_output_service.dart';
import 'ai_assistant_config.dart';
import 'ai_event.dart';
import 'ai_logger.dart';

// Internal collaborators — split for readability. They are private extensions
// over [AiAssistantController]; no public symbol is added or moved.
part 'managers/chat_state_manager.dart';
part 'managers/action_feed_manager.dart';
part 'managers/handoff_orchestrator.dart';
part 'managers/voice_manager.dart';
part 'managers/response_popup_manager.dart';

const _uuid = Uuid();

/// Controls the AI assistant lifecycle and orchestrates all components.
///
/// This is the central brain that wires together:
/// - Context extraction (SemanticsWalker, NavigatorObserver, Cache)
/// - LLM communication (Provider, ReAct Agent, ConversationMemory)
/// - Action execution (ActionExecutor, ScrollHandler)
/// - Tool management (ToolRegistry, built-in + custom tools)
/// - Voice I/O (VoiceInputService, VoiceOutputService)
/// - Chat state (messages, loading, overlay visibility)
///
/// Internals are split across `managers/*` part files for readability:
/// - [_ChatStateManager]      — sendMessage / button taps / clear
/// - [_ActionFeedManager]     — ReAct streaming hooks + context build
/// - [_HandoffOrchestrator]   — handoff, ask_user, confirmation, stop
/// - [_VoiceManager]          — voice input lifecycle
/// - [_ResponsePopupManager]  — overlay + popup visibility
class AiAssistantController extends ChangeNotifier {
  final AiAssistantConfig _config;

  // Internal components.
  late final SemanticsWalker _walker;
  late final ActionExecutor _executor;
  late final ToolRegistry _toolRegistry;
  late final ConversationMemory _memory;
  late final ReactAgent _agent;
  late final RouteDiscovery _routeDiscovery;
  late final ContextCache _contextCache;
  late final ContextInvalidator _contextInvalidator;

  // Voice services.
  VoiceInputService? _voiceInput;
  VoiceOutputService? _voiceOutput;

  // Public state.
  final List<AiChatMessage> _messages = [];
  bool _isProcessing = false;
  bool _isOverlayVisible = false;

  /// When true, [sendMessage] will NOT auto-open the overlay.
  /// Use this when the chat is embedded inline (e.g. in a dashboard panel).
  /// Setting this to true also disables [hand_off_to_user] — the agent
  /// performs the final action directly instead of waiting for the user.
  bool _embedMode = false;
  bool get embedMode => _embedMode;
  set embedMode(bool value) {
    if (_embedMode == value) return;
    _embedMode = value;
    if (value) {
      _toolRegistry.disableTools(const {'hand_off_to_user'});
    } else {
      _toolRegistry.enableTools(const {'hand_off_to_user'});
    }
  }
  bool _isListening = false;
  bool _disposed = false;

  // Action feed state — real-time step streaming.
  final List<ActionStep> _actionSteps = [];
  bool _isActionFeedVisible = false;
  String? _finalResponseText;

  // Progressive status text — the LLM's user-facing reasoning/thought
  // emitted alongside tool calls. Shown in the action feed header.
  String? _progressText;

  // ask_user state — allows the agent to pause and ask the user a question.
  Completer<String>? _userResponseCompleter;
  bool _waitingForUserResponse = false;

  // Cancellation — allows the user to stop the agent mid-execution.
  bool _cancelRequested = false;

  // Navigation confirmation — when the agent wants to navigate, we pause
  // and ask the user for permission before executing.
  bool _waitingForConfirmation = false;
  Completer<bool>? _confirmationCompleter;

  // Action mode — true when the agent has executed a screen-changing tool
  // (navigation, tap, etc.) and is still processing. Used by the UI to
  // make the overlay semi-transparent so the user can see the app underneath.
  bool _hasExecutedScreenChangingTool = false;

  // Handoff mode — the overlay clears so the user can see the app and
  // tap the final action button (Book Ride, Place Order, etc.) themselves.
  // The agent pauses execution and waits for the user to act.
  bool _isHandoffMode = false;
  String? _handoffButtonLabel;
  String? _handoffSummary;
  Completer<String>? _handoffCompleter;
  VoidCallback? _handoffRouteListener;

  // Voice state — partial transcription shown live while user speaks,
  // and tracking whether the current task was initiated by voice.
  String? _partialTranscription;
  bool _currentTaskIsVoice = false;
  DateTime? _lastSpokenProgress;

  // Unread response — set when the agent adds a response while the overlay
  // is hidden (e.g. after handoff success). Cleared when overlay opens.
  bool _hasUnreadResponse = false;

  // Message queue — stores messages sent while the agent is already processing.
  // After the current run completes, the next queued message is sent automatically.
  String? _pendingMessage;
  bool _pendingIsVoice = false;

  // Response popup — shown after auto-closing the overlay on task completion.
  // Compact card above the FAB with the agent's response.
  bool _isResponsePopupVisible = false;
  AiResponseType _responsePopupType = AiResponseType.infoResponse;
  String? _responsePopupText;
  Timer? _responsePopupTimer;

  // Screenshot capture (null if disabled).
  ScreenshotCapture? _screenshotCapture;

  // Current task context — stored when sendMessage starts, used by handoff
  // event to provide full context about the user's original request.
  String? _currentTaskMessage;
  DateTime? _currentTaskStartedAt;

  // Processing timeout timer — paused during user-facing waits (handoff,
  // ask_user) so the user has unlimited time to respond.
  Timer? _processingTimer;

  /// Navigator observer to add to your app's Navigator.
  late final AiNavigatorObserver navigatorObserver;

  /// Safe wrapper around [notifyListeners] that checks [_disposed] first.
  /// Prevents "A ChangeNotifier was used after being disposed" errors.
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Emit an analytics event to the host app's [AiAssistantConfig.onEvent].
  void _emit(AiEventType type, [Map<String, dynamic>? properties]) {
    _config.onEvent?.call(AiEvent.now(type, properties));
  }

  AiAssistantController({
    required AiAssistantConfig config,
    GlobalKey? appContentKey,
  }) : _config = config {
    if (_config.enableLogging) AiLogger.enable();
    if (_config.enableScreenshots && appContentKey != null) {
      _screenshotCapture = ScreenshotCapture(appContentKey: appContentKey);
    }
    _init();
  }

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;
  bool get isOverlayVisible => _isOverlayVisible;
  bool get isListening => _isListening;
  String? get partialTranscription => _partialTranscription;
  AiAssistantConfig get config => _config;

  /// Live action steps streamed from the ReAct agent loop.
  List<ActionStep> get actionSteps => List.unmodifiable(_actionSteps);

  /// Whether the action feed overlay is currently showing.
  bool get isActionFeedVisible => _isActionFeedVisible;

  /// The agent's final response text, shown briefly in the feed before
  /// transitioning to the normal chat bubble.
  String? get finalResponseText => _finalResponseText;

  /// The LLM's current progressive status text (e.g. "Setting up your ride...").
  /// Updated each iteration as the agent works through the task.
  String? get progressText => _progressText;

  /// Whether the agent is paused waiting for user input (via ask_user tool).
  bool get isWaitingForUserResponse => _waitingForUserResponse;

  /// Whether the overlay is in handoff mode — the overlay clears and a small
  /// floating indicator tells the user which button to tap.
  bool get isHandoffMode => _isHandoffMode;

  /// The label of the button the user should tap (e.g., "Book Ride").
  String? get handoffButtonLabel => _handoffButtonLabel;

  /// Brief description of what happens when the user taps the button.
  String? get handoffSummary => _handoffSummary;

  /// Whether the agent has an unread response (added while overlay was hidden).
  /// Used by the FAB to show a notification badge.
  bool get hasUnreadResponse => _hasUnreadResponse;

  /// Whether the overlay should enter "action mode" — a compact, semi-transparent
  /// state that lets the user see the app underneath while the agent works.
  ///
  /// True when the agent is processing, has executed at least one screen-changing
  /// tool (navigation, tap, scroll), and is NOT paused waiting for user input.
  bool get isActionMode =>
      _isActionFeedVisible &&
      _isProcessing &&
      !_waitingForUserResponse &&
      _hasExecutedScreenChangingTool;

  /// Whether the compact response popup is currently visible above the FAB.
  bool get isResponsePopupVisible => _isResponsePopupVisible;

  /// The type of the response popup (action confirmation vs info card).
  AiResponseType get responsePopupType => _responsePopupType;

  /// The text content shown in the response popup.
  String? get responsePopupText => _responsePopupText;

  /// Whether the assistant is in agent mode. Always true — navigation is
  /// gated by per-action confirmation instead of a global toggle.
  bool get agentMode => true;

  /// Whether the assistant is waiting for the user to confirm a navigation action.
  bool get waitingForConfirmation => _waitingForConfirmation;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  void _init() {
    AiLogger.log('Initializing AiAssistantController', tag: 'Controller');
    // 1. Context engine.
    _walker = SemanticsWalker();
    _walker.ensureSemantics();

    _contextCache = ContextCache(
      screenTtl: _config.contextCacheTtl,
      onCaptureScreen: _walker.captureScreenContext,
      onCaptureGlobal: _config.globalContextProvider,
    );
    _contextInvalidator = ContextInvalidator(cache: _contextCache);
    _contextInvalidator.attach();

    _routeDiscovery = RouteDiscovery(
      knownRoutes: _config.knownRoutes,
      routeDescriptions: _config.routeDescriptions,
    );
    navigatorObserver = AiNavigatorObserver(
      onRouteChanged: (route) {
        _contextCache.invalidateScreen();
        _emit(AiEventType.routeChanged, {'toRoute': route});
      },
    );

    // 2. Action execution.
    _executor = ActionExecutor(
      walker: _walker,
      onNavigateToRoute: _config.navigateToRoute,
      navigatorObserver: navigatorObserver,
      knownRoutes: _config.knownRoutes,
    );

    // 3. Tool registry — built-in + custom tools.
    _toolRegistry = ToolRegistry();
    _toolRegistry.registerAll(
      createBuiltInTools(
        BuiltInToolHandlers(
          onTap:
              (label, {parentContext}) => _unwrapResult(
                _executor.tapElement(label, parentContext: parentContext),
              ),
          onSetText:
              (label, text, {parentContext}) => _unwrapResult(
                _executor.setText(label, text, parentContext: parentContext),
              ),
          onScroll: (direction) => _unwrapResult(_executor.scroll(direction)),
          onNavigate:
              (routeName) =>
                  _unwrapResult(_executor.navigateToRoute(routeName)),
          onGoBack: () => _unwrapResult(_executor.goBack()),
          onGetScreenContent: () => _unwrapResult(_executor.getScreenContent()),
          onLongPress:
              (label, {parentContext}) => _unwrapResult(
                _executor.longPress(label, parentContext: parentContext),
              ),
          onIncrease: (label) => _unwrapResult(_executor.increaseValue(label)),
          onDecrease: (label) => _unwrapResult(_executor.decreaseValue(label)),
          onAskUser: _handleAskUser,
          onHandoff: _config.confirmDestructiveActions ? _handleHandoff : null,
        ),
      ),
    );

    // Register any developer-provided custom tools.
    if (_config.customTools.isNotEmpty) {
      _toolRegistry.registerAll(_config.customTools);
    }

    // 4. Conversation memory + ReAct agent.
    _memory = ConversationMemory(
      maxMessages: _config.maxAgentIterations * 4 + 20,
      maxToolResultChars: _config.maxToolResultChars,
    );
    _agent = ReactAgent(
      provider: _config.provider,
      toolRegistry: _toolRegistry,
      memory: _memory,
      maxIterations: _config.maxAgentIterations,
      systemPromptOverride: _config.systemPromptOverride,
      assistantName: _config.assistantName,
      confirmDestructiveActions: _config.confirmDestructiveActions,
      appPurpose: _config.appPurpose,
      fewShotExamples: _config.fewShotExamples,
      domainInstructions: _config.domainInstructions,
      maxVerificationAttempts: _config.maxVerificationAttempts,
    );

    // 4b. Disable built-in tools the host app doesn't need.
    if (_config.disabledBuiltInTools.isNotEmpty) {
      _toolRegistry.disableTools(_config.disabledBuiltInTools);
    }

    // 4c. Navigation confirmation — optional, disabled by default.
    if (_config.requireNavigationConfirmation) {
      _toolRegistry.setConfirmationRequired(const {'navigate_to_route'});
      _toolRegistry.onConfirmationRequired = _handleToolConfirmation;
    }

    // 5. Voice services (lazy-initialized on first use).
    if (_config.voiceEnabled) {
      _voiceInput = VoiceInputService();
      _voiceOutput = VoiceOutputService();
    }

    AiLogger.log(
      'Initialized: ${_toolRegistry.length} tools registered, '
      'voice=${_config.voiceEnabled}, '
      'maxIterations=${_config.maxAgentIterations}',
      tag: 'Controller',
    );
  }

  /// Unwrap a [ToolResult] into the data map, throwing on failure so the
  /// [ToolRegistry] can catch it and create a proper failed [ToolResult].
  static Future<Map<String, dynamic>> _unwrapResult(
    Future<ToolResult> future,
  ) async {
    final result = await future;
    if (!result.success) {
      throw Exception(result.error ?? 'Action failed');
    }
    return result.data;
  }

  // ---------------------------------------------------------------------------
  // Public API — thin delegators to the internal collaborators above.
  //
  // Every public symbol that existed before the refactor is preserved here
  // with an IDENTICAL signature. Implementations live in the part files.
  // ---------------------------------------------------------------------------

  // Chat actions.
  /// Send a suggestion chip message.
  Future<void> sendSuggestion(String label, String message) async {
    _emit(AiEventType.suggestionChipTapped, {
      'label': label,
      'message': message,
    });
    return sendMessage(message);
  }

  /// Send a text message from the user.
  Future<void> sendMessage(String text, {bool isVoice = false}) =>
      _sendMessageImpl(text, isVoice: isVoice);

  /// Called when the user taps an interactive button in a chat message.
  void handleButtonTap(
    AiChatMessage message,
    ChatButton button,
    int buttonIndex,
  ) =>
      _handleButtonTapImpl(message, button, buttonIndex);

  /// Clear the conversation and start fresh.
  void clearConversation() => _clearConversationImpl();

  /// Request the agent to stop execution.
  void requestStop() => _requestStopImpl();

  // Handoff — public UI hooks.
  /// Resolve handoff from the UI — user tapped "Done" on the indicator.
  void resolveHandoff() => _resolveHandoffImpl();

  /// Cancel handoff from the UI — user tapped "Cancel" on the indicator.
  void cancelHandoff() => _cancelHandoffImpl();

  // Action feed.
  /// Dismiss the action feed manually (e.g. user taps away).
  void dismissActionFeed() => _dismissActionFeedImpl();

  // Response popup + overlay.
  /// Dismiss the response popup (called by timer, swipe, or tap-away).
  void dismissResponsePopup() => _dismissResponsePopupImpl();

  /// Tap the response popup to re-open the full chat.
  void expandResponsePopup() => _expandResponsePopupImpl();

  /// Toggle the chat overlay visibility.
  void toggleOverlay() => _toggleOverlayImpl();

  /// Show the chat overlay. Dismisses any visible response popup.
  void showOverlay() => _showOverlayImpl();

  /// Hide the chat overlay. Stops any in-progress agent execution.
  void hideOverlay() => _hideOverlayImpl();

  // Voice.
  /// Start voice input. Recognized speech is sent as a message.
  Future<void> startVoiceInput() => _startVoiceInputImpl();

  /// Stop voice input.
  Future<void> stopVoiceInput() => _stopVoiceInputImpl();

  /// Toggle voice listening on/off.
  Future<void> toggleVoiceInput() async {
    if (_isListening) {
      await stopVoiceInput();
    } else {
      await startVoiceInput();
    }
  }

  // ---------------------------------------------------------------------------
  // Internal callback dispatchers used by the ReAct agent loop and tool
  // registry. They route through the part files for the actual behavior.
  // ---------------------------------------------------------------------------

  void _onToolStart(String toolName, Map<String, dynamic> args) =>
      _onToolStartImpl(toolName, args);

  void _onToolComplete(
    String toolName,
    Map<String, dynamic> args,
    ToolResult result,
  ) =>
      _onToolCompleteImpl(toolName, args, result);

  void _onThought(String thought) => _onThoughtImpl(thought);

  Future<AppContextSnapshot> _buildContext() => _buildContextImpl();

  Future<bool> _handleToolConfirmation(
    String toolName,
    Map<String, dynamic> args,
  ) =>
      _handleToolConfirmationImpl(toolName, args);

  Future<String> _handleHandoff(String buttonLabel, String summary) =>
      _handleHandoffImpl(buttonLabel, summary);

  void _exitHandoffMode({bool keepOverlay = false}) =>
      _exitHandoffModeImpl(keepOverlay: keepOverlay);

  Future<String> _handleAskUser(String question) => _handleAskUserImpl(question);

  List<ChatContent>? _parseAskUserContent(String question) =>
      _parseAskUserContentImpl(question);

  ButtonsContent? _buildSuggestionChips(AgentResponse response) =>
      _buildSuggestionChipsImpl(response);

  AiResponseType _classifyResponse(
    AgentResponse response, {
    bool isError = false,
  }) =>
      _classifyResponseImpl(response, isError: isError);

  void _showResponsePopup(String text, AiResponseType type) =>
      _showResponsePopupImpl(text, type);

  void _startProcessingTimer() => _startProcessingTimerImpl();

  void _pauseProcessingTimer() => _pauseProcessingTimerImpl();

  void _resumeProcessingTimer() => _resumeProcessingTimerImpl();

  // ---------------------------------------------------------------------------
  // Error formatting — kept on the controller so the part files can call
  // them via [AiAssistantController._friendlyError] without an instance.
  // ---------------------------------------------------------------------------

  /// Convert raw exceptions into user-friendly messages.
  static String _friendlyError(Object error) {
    final msg = error.toString();

    // Network / connectivity errors.
    if (msg.contains('SocketException') || msg.contains('HandshakeException')) {
      return 'It looks like there\'s no internet connection. Please check your network and try again.';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'The request timed out. Please try again.';
    }

    // HTTP status codes from LLM providers.
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Authentication failed. Please check the API key configuration.';
    }
    if (msg.contains('429') || msg.contains('rate limit')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
      return 'The AI service is temporarily unavailable. Please try again shortly.';
    }

    // Generic fallback — no raw stack trace.
    return 'Something went wrong. Please try again.';
  }

  /// Concise, speakable error messages for voice-initiated tasks.
  static String _friendlyVoiceError(Object error) {
    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('HandshakeException')) {
      return "Can't reach the server. Check your connection.";
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'That took too long. Try again?';
    }
    if (msg.contains('429') || msg.contains('rate limit')) {
      return 'Too many requests. Wait a moment and try again.';
    }
    return 'Something went wrong. Want to try again?';
  }

  /// Filter meta-commentary from LLM thoughts before showing to users.
  ///
  /// The system prompt tells the LLM to write user-friendly status text,
  /// but it sometimes leaks internal reasoning like "Let me call
  /// get_screen_content...". This filter catches purely technical thoughts
  /// while allowing user-friendly progress messages through.
  static String? _sanitizeThought(String thought) {
    final trimmed = thought.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();

    // Drop entirely if it's purely internal meta-commentary.
    // These patterns indicate the LLM is talking to itself, not the user.
    const metaPatterns = [
      'calling ',
      'executing ',
      'using the ',
      'looking at the screen',
      'the current screen shows',
      'based on the screen',
      'according to the screen',
    ];

    for (final pattern in metaPatterns) {
      if (lower.startsWith(pattern)) return null;
    }

    // Drop if it's purely a tool reference with no user-facing context.
    // e.g. "I'll call get_screen_content" but NOT "Searching for onion..."
    const toolNames = [
      'get_screen_content',
      'tap_element',
      'set_text',
      'navigate_to_route',
      'scroll',
      'go_back',
      'long_press_element',
      'ask_user',
      'hand_off_to_user',
      'increase_value',
      'decrease_value',
    ];
    for (final tool in toolNames) {
      if (lower.contains(tool)) return null;
    }

    return trimmed;
  }

  @override
  void dispose() {
    AiLogger.log('Disposing AiAssistantController', tag: 'Controller');
    _disposed = true;
    _cancelRequested = true;
    _processingTimer?.cancel();
    _responsePopupTimer?.cancel();
    // Resolve any pending completers to prevent dangling futures.
    if (_userResponseCompleter != null &&
        !_userResponseCompleter!.isCompleted) {
      _userResponseCompleter!.completeError(StateError('Controller disposed'));
    }
    if (_handoffCompleter != null && !_handoffCompleter!.isCompleted) {
      _handoffCompleter!.completeError(StateError('Controller disposed'));
    }
    if (_confirmationCompleter != null &&
        !_confirmationCompleter!.isCompleted) {
      _confirmationCompleter!.completeError(StateError('Controller disposed'));
    }
    _contextInvalidator.detach();
    _walker.dispose();
    _voiceInput?.dispose();
    _voiceOutput?.dispose();
    try {
      _config.provider.dispose();
    } catch (e) {
      AiLogger.warn('Provider dispose failed: $e', tag: 'Controller');
    }
    super.dispose();
  }
}
