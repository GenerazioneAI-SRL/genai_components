import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/ai_logger.dart';
import '../../tools/tool_definition.dart';
import '../llm_provider.dart';

/// LLM provider implementation for OpenAI-compatible APIs.
///
/// Supports standard models (GPT-4, GPT-4o) and **reasoning models**
/// (DeepSeek, GPT-oss, etc.) that return a `reasoning` field alongside
/// `content` and `tool_calls`.
///
/// When a reasoning model spends all its completion tokens on the
/// `reasoning` phase without producing `content` or `tool_calls`,
/// this provider extracts tool calls from the reasoning text.
class OpenAiProvider implements LlmProvider {
  final String apiKey;
  final String model;
  final String baseUrl;
  final double temperature;
  final Duration requestTimeout;

  /// Maximum completion tokens (including reasoning). Set high for
  /// reasoning models so they don't run out of tokens. Default: 16384.
  final int? maxCompletionTokens;

  final http.Client _client;
  final bool _ownsClient;

  /// Counter for synthetic tool call IDs extracted from reasoning.
  int _extractedCallCounter = 0;

  OpenAiProvider({
    required this.apiKey,
    this.model = 'gpt-4o',
    this.baseUrl = 'https://api.openai.com/v1',
    this.temperature = 0.2,
    this.requestTimeout = const Duration(seconds: 60),
    this.maxCompletionTokens = 16384,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null;

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }

  @override
  Future<LlmResponse> sendMessage({
    required List<LlmMessage> messages,
    required List<ToolDefinition> tools,
    String? systemPrompt,
  }) => retryOnRateLimit(
    () => _sendMessageInner(messages, tools, systemPrompt),
    tag: 'OpenAI',
  );

  Future<LlmResponse> _sendMessageInner(
    List<LlmMessage> messages,
    List<ToolDefinition> tools,
    String? systemPrompt,
  ) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': _buildMessages(messages, systemPrompt),
      'temperature': temperature,
    };

    if (maxCompletionTokens != null) {
      body['max_completion_tokens'] = maxCompletionTokens;
    }

    if (tools.isNotEmpty) {
      body['tools'] = tools.map(_toOpenAiTool).toList();
      body['tool_choice'] = 'auto';
    }

    AiLogger.log(
      'OpenAI request: model=$model, ${messages.length} messages, '
      '${tools.isEmpty ? 'no tools' : '${tools.length} tools'}',
      tag: 'OpenAI',
    );

    final response = await _client
        .post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);

    if (response.statusCode != 200) {
      AiLogger.error(
        'OpenAI error ${response.statusCode}: ${response.body}',
        tag: 'OpenAI',
      );
      throwForHttpStatus(response.statusCode, response.body, 'OpenAI');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Log token usage
    final usage = json['usage'] as Map<String, dynamic>?;
    if (usage != null) {
      AiLogger.log(
        'Tokens: prompt=${usage['prompt_tokens']}, '
        'completion=${usage['completion_tokens']}, '
        'total=${usage['total_tokens']}',
        tag: 'OpenAI',
      );
    }

    final parsed = _parseResponse(json);
    AiLogger.log(
      'OpenAI response: ${parsed.isToolCall ? '${parsed.toolCalls!.length} tool call(s)' : 'text (${parsed.textContent?.length ?? 0} chars)'}',
      tag: 'OpenAI',
    );
    return parsed;
  }

  /// Build OpenAI messages array.
  List<Map<String, dynamic>> _buildMessages(
    List<LlmMessage> messages,
    String? systemPrompt,
  ) {
    final result = <Map<String, dynamic>>[];

    if (systemPrompt != null) {
      result.add({'role': 'system', 'content': systemPrompt});
    }

    for (final msg in messages) {
      switch (msg.role) {
        case LlmRole.system:
          result.add({'role': 'system', 'content': msg.content ?? ''});

        case LlmRole.user:
          if (msg.images != null && msg.images!.isNotEmpty) {
            result.add({
              'role': 'user',
              'content': [
                {'type': 'text', 'text': msg.content ?? ''},
                for (final img in msg.images!)
                  {
                    'type': 'image_url',
                    'image_url': {
                      'url':
                          'data:${img.mimeType};base64,${base64Encode(img.bytes)}',
                      'detail': 'low',
                    },
                  },
              ],
            });
          } else {
            result.add({'role': 'user', 'content': msg.content ?? ''});
          }

        case LlmRole.assistant:
          if (msg.toolCalls != null && msg.toolCalls!.isNotEmpty) {
            result.add({
              'role': 'assistant',
              'tool_calls':
                  msg.toolCalls!
                      .map(
                        (tc) => {
                          'id': tc.id,
                          'type': 'function',
                          'function': {
                            'name': tc.name,
                            'arguments': jsonEncode(tc.arguments),
                          },
                        },
                      )
                      .toList(),
            });
          } else {
            result.add({'role': 'assistant', 'content': msg.content ?? ''});
          }

        case LlmRole.tool:
          result.add({
            'role': 'tool',
            'tool_call_id': msg.toolCallId ?? '',
            'content': msg.content ?? '',
          });
      }
    }

    return result;
  }

  /// Convert a [ToolDefinition] to OpenAI's tool format.
  Map<String, dynamic> _toOpenAiTool(ToolDefinition tool) {
    return {
      'type': 'function',
      'function': {
        'name': tool.name,
        'description': tool.description,
        'parameters': _buildParametersSchema(tool),
      },
    };
  }

  /// Build JSON Schema for tool parameters.
  Map<String, dynamic> _buildParametersSchema(ToolDefinition tool) {
    if (tool.parameters.isEmpty) {
      return {'type': 'object', 'properties': {}};
    }

    final properties = <String, dynamic>{};
    for (final entry in tool.parameters.entries) {
      properties[entry.key] = _parameterToSchema(entry.value);
    }

    return {
      'type': 'object',
      'properties': properties,
      if (tool.required.isNotEmpty) 'required': tool.required,
    };
  }

  Map<String, dynamic> _parameterToSchema(ToolParameter param) {
    return {
      'type': param.type,
      'description': param.description,
      if (param.enumValues != null) 'enum': param.enumValues,
    };
  }

  /// Parse OpenAI response JSON, with reasoning model support.
  LlmResponse _parseResponse(Map<String, dynamic> json) {
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return const LlmResponse(textContent: 'No response from OpenAI.');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return const LlmResponse(textContent: 'No response from OpenAI.');
    }
    final message = firstChoice['message'] as Map<String, dynamic>?;
    if (message == null) {
      return const LlmResponse(textContent: 'No response from OpenAI.');
    }

    // ── Reasoning field (DeepSeek, GPT-oss, etc.) ──
    final reasoning = message['reasoning'] as String?;
    if (reasoning != null && reasoning.isNotEmpty) {
      AiLogger.log(
        'Reasoning (${reasoning.length} chars): ${reasoning.length > 300 ? '${reasoning.substring(0, 300)}...' : reasoning}',
        tag: 'OpenAI',
      );
    }

    // ── Check for tool calls ──
    final toolCallsJson = message['tool_calls'] as List<dynamic>?;
    if (toolCallsJson != null && toolCallsJson.isNotEmpty) {
      final parsedCalls = <ToolCall>[];
      for (int i = 0; i < toolCallsJson.length; i++) {
        final tc = toolCallsJson[i];
        if (tc is! Map<String, dynamic>) continue;
        final fn = tc['function'] as Map<String, dynamic>?;
        if (fn == null) continue;
        final toolName = fn['name']?.toString().trim();
        if (toolName == null || toolName.isEmpty) continue;

        final rawId = tc['id']?.toString();
        final toolId =
            (rawId != null && rawId.isNotEmpty)
                ? rawId
                : 'openai_$toolName#${i + 1}';
        parsedCalls.add(
          ToolCall(
            id: toolId,
            name: toolName,
            arguments: _parseToolArguments(fn['arguments'], toolName: toolName),
          ),
        );
      }
      if (parsedCalls.isNotEmpty) {
        return LlmResponse(toolCalls: parsedCalls);
      }
    }

    // ── Check for text content ──
    final content = message['content'] as String?;
    if (content != null && content.trim().isNotEmpty) {
      // Some models (Gemma) emit tool calls as inline text tokens
      // e.g. <|tool_call>call:navigate_to_route(<|"|>Route<|"|>)<tool_call|>
      // Detect and convert to proper ToolCalls.
      final inlineCalls = _extractInlineToolCalls(content);
      if (inlineCalls.isNotEmpty) {
        AiLogger.log(
          'Extracted ${inlineCalls.length} inline tool call(s) from content: '
          '${inlineCalls.map((t) => t.name).join(', ')}',
          tag: 'OpenAI',
        );
        return LlmResponse(toolCalls: inlineCalls);
      }
      return LlmResponse(textContent: content);
    }

    // ── Reasoning fallback ──
    // The model reasoned but produced neither content nor tool_calls.
    // Extract tool calls from the reasoning text.
    if (reasoning != null && reasoning.isNotEmpty) {
      AiLogger.warn(
        'content=null, tool_calls=[] — extracting from reasoning',
        tag: 'OpenAI',
      );
      final extracted = _extractToolCallsFromReasoning(reasoning);
      if (extracted.isNotEmpty) {
        AiLogger.log(
          'Extracted ${extracted.length} tool call(s) from reasoning: ${extracted.map((t) => t.name).join(', ')}',
          tag: 'OpenAI',
        );
        return LlmResponse(toolCalls: extracted);
      }
      AiLogger.warn('No tool calls extracted from reasoning', tag: 'OpenAI');
      return const LlmResponse(textContent: 'Let me try a different approach.');
    }

    return LlmResponse(textContent: content);
  }

  /// Extracts tool calls from inline token format used by some models (Gemma).
  ///
  /// Handles formats like:
  /// - `<|tool_call>call:navigate_to_route(<|"|>Route<|"|>)<tool_call|>`
  /// - `<|tool_call>call:set_text(<|"|>Field<|"|>, <|"|>Value<|"|>)<tool_call|>`
  /// - `<|tool_call>call:tap_element(<|"|>Button<|"|>)<tool_call|>`
  /// - `<|tool_call>call:get_screen_content()<tool_call|>`
  /// Also handles JSON-style: `<|tool_call>{"name":"tool","arguments":{...}}<tool_call|>`
  List<ToolCall> _extractInlineToolCalls(String content) {
    final results = <ToolCall>[];

    // Pattern for <|tool_call>...<tool_call|> or <|tool_call>...<|tool_call|>
    final blockPattern = RegExp(
      r'<\|tool_call>(.+?)(?:<tool_call\|>|<\|tool_call\|>)',
      dotAll: true,
    );

    final blocks = blockPattern.allMatches(content);
    if (blocks.isEmpty) return results;

    for (final block in blocks) {
      final inner = block.group(1)!.trim();

      // Try JSON format first: {"name":"tool","arguments":{...}}
      if (inner.startsWith('{')) {
        try {
          final parsed = jsonDecode(inner);
          if (parsed is Map<String, dynamic> && parsed['name'] != null) {
            final name = parsed['name'].toString();
            final args = parsed['arguments'];
            results.add(
              ToolCall(
                id: 'inline_${_extractedCallCounter++}',
                name: name,
                arguments:
                    args is Map<String, dynamic>
                        ? args
                        : args is Map
                        ? Map<String, dynamic>.from(args)
                        : const {},
              ),
            );
            continue;
          }
        } catch (_) {}
      }

      // call:TOOL_NAME(args) format
      final callPattern = RegExp(r'^call:(\w+)\((.*)\)$', dotAll: true);
      final callMatch = callPattern.firstMatch(inner);
      if (callMatch == null) continue;

      final toolName = callMatch.group(1)!;
      final rawArgs = callMatch.group(2)!.trim();

      // Extract arguments from <|"|>...<|"|> delimiters
      final argPattern = RegExp(r'<\|"\|>([^<]*)<\|"\|>');
      final argMatches = argPattern.allMatches(rawArgs).toList();

      final arguments = _mapPositionalArgs(toolName, argMatches);
      results.add(
        ToolCall(
          id: 'inline_${_extractedCallCounter++}',
          name: toolName,
          arguments: arguments,
        ),
      );
    }

    return results;
  }

  /// Map positional arguments to named parameters based on tool name.
  Map<String, dynamic> _mapPositionalArgs(
    String toolName,
    List<RegExpMatch> argMatches,
  ) {
    final args = argMatches.map((m) => m.group(1) ?? '').toList();
    if (args.isEmpty) return const {};

    return switch (toolName) {
      'tap_element' => {
        'label': args[0],
        if (args.length > 1) 'parentContext': args[1],
      },
      'set_text' => {
        'label': args.isNotEmpty ? args[0] : '',
        'text': args.length > 1 ? args[1] : '',
        if (args.length > 2) 'parentContext': args[2],
      },
      'scroll' => {'direction': args[0]},
      'navigate_to_route' => {'routeName': args[0]},
      'long_press_element' => {
        'label': args[0],
        if (args.length > 1) 'parentContext': args[1],
      },
      'increase_value' || 'decrease_value' => {'label': args[0]},
      'ask_user' => {'question': args[0]},
      'hand_off_to_user' => {
        'buttonLabel': args[0],
        'summary': args.length > 1 ? args[1] : '',
      },
      // Custom tools — pass as json if single arg looks like JSON,
      // otherwise first arg as 'input'.
      _ => args.length == 1 ? _tryParseJsonArg(args[0]) : {'args': args},
    };
  }

  Map<String, dynamic> _tryParseJsonArg(String arg) {
    if (arg.startsWith('{')) {
      try {
        final parsed = jsonDecode(arg);
        if (parsed is Map<String, dynamic>) return parsed;
      } catch (_) {}
    }
    return {'input': arg};
  }

  /// Extracts tool calls from the reasoning text of a reasoning model.
  List<ToolCall> _extractToolCallsFromReasoning(String reasoning) {
    final lower = reasoning.toLowerCase();

    // navigate_to_route — pattern: navigate to "Route" or navigate_to_route("Route") or navigate_to_route("/Route")
    final navPattern = RegExp(
      r'navigate[_\s]*(?:to[_\s]*)?(?:route\s*\(?\s*)?["\x27](/?[A-Za-z\u00C0-\u024F_\s-]+)["\x27]',
      caseSensitive: false,
    );
    final navMatch = navPattern.firstMatch(reasoning);
    if (navMatch != null) {
      final rawRoute = navMatch.group(1)!.trim();
      return [
        ToolCall(
          id: 'r_${_extractedCallCounter++}',
          name: 'navigate_to_route',
          arguments: {'routeName': rawRoute},
        ),
      ];
    }

    // tap_element — pattern: tap "Label" or tap on "Label"
    final tapPattern = RegExp(
      r'tap(?:\s+on)?\s+["\x27]([^"\x27]+)["\x27]',
      caseSensitive: false,
    );
    final tapMatch = tapPattern.firstMatch(reasoning);
    if (tapMatch != null) {
      return [
        ToolCall(
          id: 'r_${_extractedCallCounter++}',
          name: 'tap_element',
          arguments: {'label': tapMatch.group(1)!},
        ),
      ];
    }

    // set_text — pattern: set_text("Field", "Value")
    final setTextPattern = RegExp(
      r'set_text\s*\(\s*["\x27]([^"\x27]+)["\x27]\s*,\s*["\x27]([^"\x27]+)["\x27]',
      caseSensitive: false,
    );
    final setTextMatch = setTextPattern.firstMatch(reasoning);
    if (setTextMatch != null) {
      return [
        ToolCall(
          id: 'r_${_extractedCallCounter++}',
          name: 'set_text',
          arguments: {
            'label': setTextMatch.group(1)!,
            'text': setTextMatch.group(2)!,
          },
        ),
      ];
    }

    // get_screen_content
    if (lower.contains('get_screen_content') ||
        lower.contains('get screen content')) {
      return [
        ToolCall(
          id: 'r_${_extractedCallCounter++}',
          name: 'get_screen_content',
          arguments: const {},
        ),
      ];
    }

    // scroll
    if (lower.contains('scroll down') || lower.contains('scroll up')) {
      return [
        ToolCall(
          id: 'r_${_extractedCallCounter++}',
          name: 'scroll',
          arguments: {
            'direction': lower.contains('scroll down') ? 'down' : 'up',
          },
        ),
      ];
    }

    // go_back
    if (lower.contains('go_back') || lower.contains('go back')) {
      return [
        ToolCall(
          id: 'r_${_extractedCallCounter++}',
          name: 'go_back',
          arguments: const {},
        ),
      ];
    }

    return [];
  }

  Map<String, dynamic> _parseToolArguments(
    Object? rawArguments, {
    required String toolName,
  }) {
    if (rawArguments is Map<String, dynamic>) return rawArguments;
    if (rawArguments is Map) {
      return Map<String, dynamic>.from(rawArguments);
    }
    if (rawArguments is String) {
      if (rawArguments.trim().isEmpty) return const <String, dynamic>{};
      try {
        final decoded = jsonDecode(rawArguments);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        AiLogger.warn(
          'OpenAI returned invalid tool arguments for "$toolName"',
          tag: 'OpenAI',
        );
      }
    }
    return const <String, dynamic>{};
  }
}
