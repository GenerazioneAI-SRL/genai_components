import 'dart:async';

import '../core/ai_event.dart';
import '../core/ai_logger.dart';
import '../models/agent_action.dart';
import '../models/app_context_snapshot.dart';
import '../tools/tool_registry.dart';
import '../tools/tool_result.dart';
import 'conversation_memory.dart';
import 'internal/agent_heuristics.dart';
import 'internal/agent_messages.dart';
import 'internal/system_prompt_builder.dart';
import 'llm_provider.dart';

/// Callback signature for when a tool starts executing.
typedef OnToolStart = void Function(String toolName, Map<String, dynamic> args);

/// Callback signature for when a tool finishes executing.
typedef OnToolComplete =
    void Function(
      String toolName,
      Map<String, dynamic> args,
      ToolResult result,
    );

/// Callback for when the LLM emits reasoning/status text alongside tool calls.
/// This text is shown to the user as progressive status in the action feed.
typedef OnThought = void Function(String thought);

/// Response from the ReAct agent after processing a user message.
class AgentResponse {
  /// The final natural language response to show the user.
  final String text;

  /// All actions the agent performed during this turn.
  final List<AgentAction> actions;

  const AgentResponse({required this.text, this.actions = const []});
}

/// ReAct (Reason → Act → Observe) agent loop.
///
/// This is the core intelligence loop of the AI assistant. Given a user
/// message, it:
/// 1. Sends the message + app context + tool definitions to the LLM
/// 2. If the LLM returns tool calls → executes them → feeds results back
/// 3. Repeats until the LLM returns a text response or max iterations hit
///
/// The LLM sees the full conversation history, the current screen context,
/// and the available tools. It decides whether to act (call tools) or
/// respond (return text).
class ReactAgent {
  final LlmProvider provider;
  final ToolRegistry toolRegistry;
  final ConversationMemory memory;
  final int maxIterations;

  /// Optional override for the system prompt.
  final String? systemPromptOverride;

  /// Name shown to the user.
  final String assistantName;

  /// Whether to ask the user before destructive actions.
  final bool confirmDestructiveActions;

  /// Optional purpose description of the app (domain vocabulary, use cases).
  final String? appPurpose;

  /// Optional few-shot examples of correct behavior. When empty, generic
  /// examples are generated automatically.
  final List<String> fewShotExamples;

  /// Optional domain-specific behavioral instructions injected into the
  /// system prompt. Use this to teach the agent about app-specific workflows,
  /// terminology, and expected behaviors.
  final String? domainInstructions;

  /// Maximum number of post-completion verification passes before accepting
  /// the agent's response. Default: 2.
  ///
  /// After the agent returns a text response following actions, the system
  /// re-checks the screen to verify the task is genuinely complete. For
  /// simple tasks, the first pass confirms and returns. For multi-step flows,
  /// a second pass catches premature completion (e.g., agent stops at an
  /// intermediate step instead of completing the full flow).
  final int maxVerificationAttempts;

  /// Internal collaborator that builds the system prompt each iteration.
  /// Created once in the constructor and reused — pure function over its
  /// inputs, so it's safe to share.
  final SystemPromptBuilder _promptBuilder;

  ReactAgent({
    required this.provider,
    required this.toolRegistry,
    required this.memory,
    this.maxIterations = 100,
    this.systemPromptOverride,
    this.assistantName = 'AI Assistant',
    this.confirmDestructiveActions = true,
    this.appPurpose,
    this.fewShotExamples = const [],
    this.domainInstructions,
    this.maxVerificationAttempts = 2,
  }) : _promptBuilder = SystemPromptBuilder(
         assistantName: assistantName,
         confirmDestructiveActions: confirmDestructiveActions,
         appPurpose: appPurpose,
         fewShotExamples: fewShotExamples,
         domainInstructions: domainInstructions,
       );

  /// Process a user message through the ReAct loop.
  ///
  /// [contextBuilder] is called at the start of each iteration so the LLM
  /// always sees the current screen state after actions (navigation, taps,
  /// scrolls) change the UI. This prevents the LLM from operating on stale
  /// context and stopping prematurely.
  ///
  /// [onToolStart] is called just before each tool executes, allowing the
  /// UI to show a real-time action feed. [onToolComplete] is called after.
  ///
  /// [shouldCancel] is checked at the start of each iteration and between
  /// tool calls. If it returns true, the agent exits gracefully.
  Future<AgentResponse> run({
    required String userMessage,
    required Future<AppContextSnapshot> Function() contextBuilder,
    OnToolStart? onToolStart,
    OnToolComplete? onToolComplete,
    OnThought? onThought,
    bool Function()? shouldCancel,
    AiEventCallback? onEvent,
  }) async {
    AiLogger.log('ReAct run: "$userMessage"', tag: 'Agent');
    void emit(AiEventType type, [Map<String, dynamic>? props]) {
      onEvent?.call(AiEvent.now(type, props));
    }

    memory.addUserMessage(userMessage);
    final executedActions = <AgentAction>[];
    int consecutiveEmptyResponses = 0;
    int verificationAttempts = 0;
    int consecutiveFailures = 0;
    int circuitBreakerFirings = 0;
    final askUserHistory = <String>[];
    int searchRetries = 0;
    bool lastActionWasBlockedAskUser = false;
    String? lastSearchQuery; // T2.2: track last search for result verification

    for (int i = 0; i < maxIterations; i++) {
      // ── Cancellation check ──
      if (shouldCancel?.call() == true) {
        AiLogger.log(
          'Agent cancelled by user at iteration ${i + 1}',
          tag: 'Agent',
        );
        emit(AiEventType.agentCancelled, {
          'iteration': i + 1,
          'actionCount': executedActions.length,
          'reason': 'user_requested',
        });
        final text =
            executedActions.isNotEmpty
                ? 'Task stopped. ${AgentMessages.summarizeActions(executedActions)}'
                : 'Task stopped.';
        memory.addAssistantMessage(text);
        return AgentResponse(text: text, actions: executedActions);
      }

      AiLogger.log('--- Iteration ${i + 1}/$maxIterations ---', tag: 'Agent');
      emit(AiEventType.agentIterationStarted, {
        'iteration': i + 1,
        'maxIterations': maxIterations,
        'actionsSoFar': executedActions.length,
      });

      // T2.5: Orientation checkpoint every 5 iterations to keep the agent
      // focused on the original goal during long multi-step flows.
      if (i > 0 && i % 5 == 0 && executedActions.isNotEmpty) {
        final actionSummary = executedActions
            .where((a) => a.toolName != 'get_screen_content')
            .map(
              (a) =>
                  '${a.toolName}(${a.arguments.values.first}): ${a.result.success ? "OK" : "FAIL"}',
            )
            .take(8)
            .join(' → ');
        memory.addUserMessage(
          '[SYSTEM — PROGRESS CHECK]\n'
          'Original request: "$userMessage"\n'
          'Actions so far: $actionSummary\n'
          'Continue toward the ORIGINAL goal. Do not stop at intermediate steps.',
        );
        AiLogger.log(
          'Orientation checkpoint at iteration ${i + 1}',
          tag: 'Agent',
        );
        emit(AiEventType.agentOrientationCheckpoint, {
          'iteration': i + 1,
          'actionsSummary': actionSummary,
        });
      }

      // Rebuild context each iteration so the LLM sees fresh screen state
      // after actions (navigation, taps, scrolls) change the UI.
      final context = await contextBuilder();
      final systemPrompt = systemPromptOverride ?? _promptBuilder.build(context);
      if (i == 0) {
        AiLogger.log(
          'System prompt length: ${systemPrompt.length} chars, '
          '${memory.length} messages in memory',
          tag: 'Agent',
        );
      }

      // Build the messages to send. If a screenshot is available, inject it
      // as an ephemeral multimodal user message at the end. This is NOT stored
      // in conversation memory (screenshots are large and change every iteration).
      final messages = memory.getMessages();
      final screenshot = context.screenshot;
      final messagesWithScreenshot =
          screenshot != null
              ? AgentMessages.injectScreenshot(messages, screenshot)
              : messages;

      AiLogger.log(
        'Sending ${messages.length} messages '
        '${screenshot != null ? '(+screenshot) ' : ''}'
        '+ ${toolRegistry.length} tools to LLM',
        tag: 'Agent',
      );
      emit(AiEventType.llmRequestSent, {
        'iteration': i + 1,
        'messageCount': messages.length,
        'toolCount': toolRegistry.length,
        'hasScreenshot': screenshot != null,
        'systemPromptLength': systemPrompt.length,
      });
      final llmStopwatch = Stopwatch()..start();

      LlmResponse response;
      try {
        // Race the LLM call against cancellation so the stop button takes
        // effect immediately instead of waiting for the full API timeout.
        final llmFuture = provider.sendMessage(
          messages: messagesWithScreenshot,
          tools: toolRegistry.getToolDefinitions(),
          systemPrompt: systemPrompt,
        );

        if (shouldCancel != null) {
          // Poll cancellation every 500ms while waiting for the LLM.
          final result = await Future.any<LlmResponse?>([
            llmFuture,
            _pollForCancellation(shouldCancel),
          ]);
          if (result == null) {
            // Cancellation won the race.
            AiLogger.log(
              'Agent cancelled during LLM call at iteration ${i + 1}',
              tag: 'Agent',
            );
            final text =
                executedActions.isNotEmpty
                    ? 'Task stopped. ${AgentMessages.summarizeActions(executedActions)}'
                    : 'Task stopped.';
            memory.addAssistantMessage(text);
            return AgentResponse(text: text, actions: executedActions);
          }
          response = result;
        } else {
          response = await llmFuture;
        }
      } on AuthenticationException catch (e) {
        // Non-retryable: bad API key. Fail immediately.
        AiLogger.error('Auth failure', error: e, tag: 'Agent');
        emit(AiEventType.llmError, {
          'iteration': i + 1,
          'error': e.toString(),
          'errorType': 'authentication',
          'isRetryable': false,
        });
        const text =
            'API key is invalid or expired. Please check your configuration.';
        memory.addAssistantMessage(text);
        return AgentResponse(text: text, actions: executedActions);
      } on ContextOverflowException catch (e) {
        // Non-retryable: conversation too long. Fail with a clear message.
        AiLogger.error('Context overflow', error: e, tag: 'Agent');
        emit(AiEventType.llmError, {
          'iteration': i + 1,
          'error': e.toString(),
          'errorType': 'context_overflow',
          'isRetryable': false,
        });
        final text =
            executedActions.isNotEmpty
                ? '${AgentMessages.summarizeActions(executedActions)} (Conversation got too long for the model.)'
                : 'The conversation is too long. Please clear and try again.';
        memory.addAssistantMessage(text);
        return AgentResponse(text: text, actions: executedActions);
      } on ContentFilteredException catch (e) {
        // Non-retryable: safety filter. Inform the user.
        AiLogger.warn('Content filtered: $e', tag: 'Agent');
        emit(AiEventType.llmError, {
          'iteration': i + 1,
          'error': e.toString(),
          'errorType': 'content_filtered',
          'isRetryable': false,
        });
        const text = "I can't help with that request.";
        memory.addAssistantMessage(text);
        return AgentResponse(text: text, actions: executedActions);
      } catch (e) {
        AiLogger.error(
          'LLM call failed at iteration ${i + 1}',
          error: e,
          tag: 'Agent',
        );
        emit(AiEventType.llmError, {
          'iteration': i + 1,
          'error': e.toString(),
          'errorType': 'unknown',
          'isRetryable': true,
          'consecutiveFailures': consecutiveEmptyResponses + 1,
        });
        consecutiveEmptyResponses++;
        if (consecutiveEmptyResponses >= 3) {
          final text =
              executedActions.isNotEmpty
                  ? AgentMessages.summarizeActions(executedActions)
                  : 'I encountered an error communicating with the AI service. Please try again.';
          memory.addAssistantMessage(text);
          return AgentResponse(text: text, actions: executedActions);
        }
        // Brief wait before retry.
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // Handle empty/null response — LLM returned neither text nor tool calls.
      // Retry up to 3 times before giving up (the LLM may have hit a
      // transient limit or returned an empty candidate list).
      if (!response.isToolCall &&
          (response.textContent == null ||
              response.textContent!.trim().isEmpty)) {
        consecutiveEmptyResponses++;
        AiLogger.warn(
          'LLM returned empty response at iteration ${i + 1} '
          '(consecutive: $consecutiveEmptyResponses)',
          tag: 'Agent',
        );
        emit(AiEventType.llmEmptyResponse, {
          'iteration': i + 1,
          'consecutiveEmpty': consecutiveEmptyResponses,
        });

        // If empty responses follow a blocked ask_user, the LLM is confused.
        // Inject a nudge to get it back on track before giving up.
        if (lastActionWasBlockedAskUser && consecutiveEmptyResponses == 1) {
          AiLogger.log(
            'Injecting nudge after blocked ask_user + empty response',
            tag: 'Agent',
          );
          memory.addUserMessage(
            '[SYSTEM — CONTINUE]\n'
            'Your ask_user was blocked because the user already told you what to do. '
            'The original request was: "$userMessage"\n'
            'DO NOT ask again. Just CONTINUE executing the task. '
            'Call get_screen_content to see the current screen, then take the next action.',
          );
          lastActionWasBlockedAskUser = false;
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }

        if (consecutiveEmptyResponses >= 3) {
          if (executedActions.isEmpty) {
            const fallback =
                "I'm not sure how to help with that. Could you rephrase your request?";
            memory.addAssistantMessage(fallback);
            return AgentResponse(text: fallback, actions: executedActions);
          }
          final summary = AgentMessages.summarizeActions(executedActions);
          memory.addAssistantMessage(summary);
          return AgentResponse(text: summary, actions: executedActions);
        }
        // Retry: wait briefly then loop again with fresh context.
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // Got a valid response — reset the empty counter.
      consecutiveEmptyResponses = 0;
      llmStopwatch.stop();
      emit(AiEventType.llmResponseReceived, {
        'iteration': i + 1,
        'hasToolCalls': response.isToolCall,
        'hasText':
            response.textContent != null &&
            response.textContent!.trim().isNotEmpty,
        'durationMs': llmStopwatch.elapsedMilliseconds,
      });

      if (!response.isToolCall) {
        final text = response.textContent!;

        // ── Search failure intercept (max 1 retry) ──
        // If the agent returns text claiming it can't find a search bar,
        // but the user's request implies searching, force ONE retry.
        if (AgentHeuristics.claimsNoSearchBar(text) &&
            AgentHeuristics.userNeedsSearch(userMessage) &&
            searchRetries < 1) {
          searchRetries++;
          memory.addAssistantMessage(text);
          memory.addUserMessage(
            '[SYSTEM — CORRECTION]\n'
            'You said you cannot find a search bar. This is WRONG.\n'
            'The set_text tool has auto-detection that finds hidden and async search fields.\n'
            'CALL set_text("Search", "<the item the user wants>") RIGHT NOW.\n'
            'Do NOT say you cannot find a search bar — just call set_text.',
          );
          onThought?.call('Retrying search...');
          continue;
        }

        // ── Post-completion verification ──
        // If the agent performed actions, verify the task is genuinely
        // complete before returning. Also catches questions returned as text.
        //
        // SKIP verification when the agent only used custom (data-only) tools
        // and no UI-interaction tools. Data tools return complete results
        // directly — re-checking the screen adds a useless LLM round-trip.
        final looksLikeQuestion = AgentHeuristics.looksLikeQuestion(text);

        const builtInToolNames = {
          'tap_element',
          'set_text',
          'scroll',
          'navigate_to_route',
          'go_back',
          'get_screen_content',
          'long_press_element',
          'increase_value',
          'decrease_value',
          'ask_user',
          'hand_off_to_user',
        };
        final usedAnyBuiltInTool = executedActions.any(
          (a) => builtInToolNames.contains(a.toolName),
        );

        // Skip verification for pure form-fill flows: the fields are filled,
        // there is nothing to re-verify. Verification is needed for navigation
        // and action flows, not data entry.
        const _formFillOnlyToolNames = {
          'set_text',
          'select_dropdown_item',
          'get_screen_content',
          'ask_user',
        };
        final isFormFillOnly = executedActions.isNotEmpty &&
            executedActions.every(
              (a) => _formFillOnlyToolNames.contains(a.toolName),
            );

        if (executedActions.isNotEmpty &&
            usedAnyBuiltInTool &&
            !isFormFillOnly &&
            verificationAttempts < maxVerificationAttempts) {
          verificationAttempts++;
          AiLogger.log(
            'Post-completion verification ($verificationAttempts/$maxVerificationAttempts): '
            'agent returned text after ${executedActions.length} actions'
            '${looksLikeQuestion ? ' [question detected]' : ''}',
            tag: 'Agent',
          );

          memory.addAssistantMessage(text);

          final verifyCtx = await contextBuilder();
          final screenNow = verifyCtx.screenContext.toPromptString();

          // Detect if this was a detail-info query but the agent never
          // SUCCESSFULLY tapped into a detail screen (only navigated + read list view).
          final isDetailQuery = AgentHeuristics.isDetailInfoQuery(userMessage);
          final didTapItemSuccessfully = executedActions.any(
            (a) => a.toolName == 'tap_element' && a.result.success,
          );

          // Detect if the agent stopped at an intermediate step without
          // completing the full flow (no hand_off_to_user, task seems incomplete).
          final didHandoff = executedActions.any(
            (a) => a.toolName == 'hand_off_to_user',
          );

          memory.addUserMessage(
            AgentMessages.buildVerificationMessage(
              userMessage: userMessage,
              screenNow: screenNow,
              didHandoff: didHandoff,
              isDetailQuery: isDetailQuery,
              didTapItemSuccessfully: didTapItemSuccessfully,
              looksLikeQuestion: looksLikeQuestion,
            ),
          );

          onThought?.call('Verifying...');
          continue;
        }

        // LLM returned a text response — conversation turn is complete.
        AiLogger.log(
          'LLM returned text (${text.length} chars), turn complete after ${i + 1} iterations',
          tag: 'Agent',
        );
        memory.addAssistantMessage(text);
        return AgentResponse(text: text, actions: executedActions);
      }

      // LLM wants to call tools — execute them.
      final toolCalls = response.toolCalls!;
      final thought = response.textContent;
      AiLogger.log(
        'LLM requested ${toolCalls.length} tool call(s): '
        '${toolCalls.map((c) => c.name).join(', ')}'
        '${thought != null ? ' [thought: "${thought.length > 80 ? '${thought.substring(0, 80)}...' : thought}"]' : ''}',
        tag: 'Agent',
      );

      // Emit the LLM's reasoning text as a progressive status for the user.
      if (thought != null && thought.trim().isNotEmpty) {
        onThought?.call(thought.trim());
      }

      memory.addAssistantToolCalls(toolCalls, thought: thought);

      for (final toolCall in toolCalls) {
        // Check cancellation between tool calls.
        if (shouldCancel?.call() == true) {
          AiLogger.log('Agent cancelled between tool calls', tag: 'Agent');
          // Add a cancelled result for this tool so memory stays consistent.
          memory.addToolResult(toolCall.id, 'Error: Task stopped by user.');
          final text = 'Task stopped. ${AgentMessages.summarizeActions(executedActions)}';
          memory.addAssistantMessage(text);
          return AgentResponse(text: text, actions: executedActions);
        }

        // ── ask_user guards (code-level enforcement) ──
        // The LLM frequently ignores prompt rules about not asking unnecessary
        // questions. These guards intercept bad ask_user calls BEFORE they
        // reach the user, injecting corrective messages so the agent retries.
        if (toolCall.name == 'ask_user') {
          final question = (toolCall.arguments['question'] as String?) ?? '';

          // Guard 1: Unnecessary confirmation ("Would you like to add X?")
          if (AgentHeuristics.isUnnecessaryConfirmation(question, userMessage)) {
            AiLogger.log(
              'ask_user BLOCKED: unnecessary confirmation',
              tag: 'Agent',
            );
            memory.addToolResult(
              toolCall.id,
              '{"blocked": true, "reason": "SYSTEM: The user ALREADY asked you to do this. '
              'Do NOT ask for confirmation — just do it. Proceed with the action immediately."}',
            );
            lastActionWasBlockedAskUser = true;
            onThought?.call('Proceeding...');
            continue;
          }

          // Guard 2: Redundant quantity question ("How many?")
          if (AgentHeuristics.isRedundantQuantityQuestion(
            question,
            userMessage,
          )) {
            AiLogger.log(
              'ask_user BLOCKED: redundant quantity question',
              tag: 'Agent',
            );
            memory.addToolResult(
              toolCall.id,
              '{"blocked": true, "reason": "SYSTEM: The user ALREADY specified the quantity '
              'in their message: \\"$userMessage\\". Extract the number from their message '
              'and use it. Do NOT ask again."}',
            );
            lastActionWasBlockedAskUser = true;
            onThought?.call('Using specified quantity...');
            continue;
          }

          // Guard 3: Duplicate question (same question asked before)
          if (AgentHeuristics.isDuplicateAskUser(question, askUserHistory)) {
            AiLogger.log('ask_user BLOCKED: duplicate question', tag: 'Agent');
            memory.addToolResult(
              toolCall.id,
              '{"blocked": true, "reason": "SYSTEM: You already asked this question. '
              'Do NOT repeat questions. Either proceed with the most reasonable choice '
              'or inform the user you need different information."}',
            );
            lastActionWasBlockedAskUser = true;
            continue;
          }
          askUserHistory.add(question);
        }

        // A real tool is about to execute — clear the blocked flag.
        lastActionWasBlockedAskUser = false;

        AiLogger.log(
          'Executing tool: ${toolCall.name}(${toolCall.arguments})',
          tag: 'Agent',
        );
        onToolStart?.call(toolCall.name, toolCall.arguments);

        // Safety timeout on tool execution — prevents the agent from hanging
        // forever if a tool handler blocks (e.g. awaiting a Future that never
        // completes). 30 seconds is generous; most tools complete in <2s.
        // Exception: ask_user and hand_off_to_user wait for user input — no timeout.
        const _noTimeoutTools = {'ask_user', 'hand_off_to_user'};
        ToolResult result;
        try {
          final execFuture = toolRegistry.executeTool(toolCall);
          result = _noTimeoutTools.contains(toolCall.name)
              ? await execFuture
              : await execFuture.timeout(const Duration(seconds: 30));
        } on TimeoutException {
          AiLogger.warn(
            'Tool ${toolCall.name} timed out after 30s',
            tag: 'Agent',
          );
          result = ToolResult.fail(
            'Tool "${toolCall.name}" timed out. Try a different approach.',
          );
        }

        AiLogger.log(
          'Tool result: ${toolCall.name} -> ${result.success ? 'OK' : 'FAIL'}'
          '${result.error != null ? ': ${result.error}' : ''}',
          tag: 'Agent',
        );
        onToolComplete?.call(toolCall.name, toolCall.arguments, result);

        memory.addToolResult(toolCall.id, result.toPromptString());

        executedActions.add(
          AgentAction(
            toolName: toolCall.name,
            arguments: toolCall.arguments,
            result: result,
            executedAt: DateTime.now(),
          ),
        );

        // T2.2: Track search queries for result verification.
        if (toolCall.name == 'set_text' && result.success) {
          final label = (toolCall.arguments['label'] as String?) ?? '';
          if (label.toLowerCase().contains('search')) {
            lastSearchQuery = (toolCall.arguments['text'] as String?) ?? '';
          }
        }
        // T2.2: Warn if tapping a result that doesn't match the search query.
        if (toolCall.name == 'tap_element' &&
            result.success &&
            lastSearchQuery != null &&
            lastSearchQuery.isNotEmpty) {
          final tapLabel = (toolCall.arguments['label'] as String?) ?? '';
          // Skip mismatch check for common action buttons — these are
          // expected to not match the search query (e.g. tapping "ADD"
          // after searching "aaloo" is correct, not a mismatch).
          const actionLabels = {
            'add',
            'buy',
            'remove',
            'delete',
            'select',
            'view',
            'open',
            'confirm',
            'submit',
            'cancel',
            'ok',
            'yes',
            'no',
            'done',
            'cart',
            'view cart',
            'checkout',
          };
          final isActionButton = actionLabels.contains(
            tapLabel.toLowerCase().trim(),
          );
          final searchWords = AgentHeuristics.extractWords(lastSearchQuery);
          final tapWords = AgentHeuristics.extractWords(tapLabel);
          if (!isActionButton &&
              searchWords.isNotEmpty &&
              tapWords.isNotEmpty) {
            final overlap = searchWords.intersection(tapWords).length;
            final similarity = overlap / searchWords.length;
            if (similarity < 0.3) {
              AiLogger.log(
                'Search-tap mismatch: searched "$lastSearchQuery", '
                'tapped "$tapLabel" (similarity=${similarity.toStringAsFixed(2)})',
                tag: 'Agent',
              );
              // Append warning to the tool result in memory.
              memory.addToolResult(
                '${toolCall.id}_search_warning',
                '[SYSTEM WARNING] You tapped "$tapLabel" but searched for '
                    '"$lastSearchQuery". These don\'t match. Verify this is the '
                    'correct item before proceeding.',
              );
            }
          }
          lastSearchQuery = null; // Clear after first post-search tap.
        }

        // Track consecutive failures for circuit breaker.
        if (result.success) {
          consecutiveFailures = 0;
        } else {
          consecutiveFailures++;
        }
      }

      // ── Consecutive-failure circuit breaker ──
      // If 3+ actions failed in a row, the agent is stuck in a loop
      // (e.g. tapping elements that don't exist). Inject a corrective
      // system message to force it to re-orient.
      if (consecutiveFailures >= 3) {
        circuitBreakerFirings++;
        AiLogger.warn(
          'Circuit breaker firing #$circuitBreakerFirings: '
          '$consecutiveFailures consecutive failures',
          tag: 'Agent',
        );
        emit(AiEventType.agentCircuitBreakerFired, {
          'iteration': i + 1,
          'consecutiveFailures': consecutiveFailures,
          'circuitBreakerCount': circuitBreakerFirings,
        });

        if (circuitBreakerFirings >= 2) {
          // Second firing — the agent is truly stuck. Force an early exit
          // instead of allowing another cycle of failing actions.
          final text =
              executedActions.isNotEmpty
                  ? '${AgentMessages.summarizeActions(executedActions)} '
                      'I ran into repeated issues and could not complete the task.'
                  : 'I ran into repeated issues and could not complete the request. '
                      'Please try a different approach.';
          memory.addAssistantMessage(text);
          return AgentResponse(text: text, actions: executedActions);
        }

        memory.addUserMessage(
          '[SYSTEM — CIRCUIT BREAKER]\n'
          'Your last $consecutiveFailures actions ALL FAILED. You are stuck in a loop. '
          'STOP trying to tap elements. Instead:\n'
          '1. Call get_screen_content to see what is actually on screen.\n'
          '2. Report the information you have gathered so far to the user.\n'
          '3. If you have no useful information, say so honestly.\n'
          'Do NOT attempt any more tap_element or set_text calls.',
        );
        consecutiveFailures =
            0; // Reset so the breaker doesn't fire every iteration.
      }

      emit(AiEventType.agentIterationCompleted, {
        'iteration': i + 1,
        'hasToolCalls': response.isToolCall,
        'hasText': !response.isToolCall,
        'actionCount': executedActions.length,
      });

      // Settle delay so the UI updates (including network-loaded content)
      // before the next iteration re-captures screen context.
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Reached max iterations without a final text response.
    AiLogger.warn('Reached max iterations ($maxIterations)', tag: 'Agent');
    emit(AiEventType.agentMaxIterationsReached, {
      'maxIterations': maxIterations,
      'actionCount': executedActions.length,
    });
    final maxIterText =
        executedActions.isNotEmpty
            ? AgentMessages.summarizeActions(executedActions)
            : "I wasn't able to complete the request within the step limit. "
                'Please try a simpler command.';
    memory.addAssistantMessage(maxIterText);
    return AgentResponse(text: maxIterText, actions: executedActions);
  }

  /// Polls [shouldCancel] every 500ms and returns null when cancelled.
  /// Used with [Future.any] to race against the LLM call so the stop
  /// button takes effect during API waits instead of after timeout.
  static Future<LlmResponse?> _pollForCancellation(
    bool Function() shouldCancel,
  ) async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (shouldCancel()) return null;
    }
  }
}

