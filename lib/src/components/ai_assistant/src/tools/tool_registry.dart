import '../core/ai_logger.dart';
import '../llm/llm_provider.dart';
import 'tool_definition.dart';
import 'tool_result.dart';

/// Registry of all available tools (built-in + developer-registered).
///
/// The registry is the single source of truth for what tools the LLM
/// can call. It holds both the tool definitions (sent to the LLM) and
/// the executable handlers (called when the LLM invokes a tool).
class ToolRegistry {
  final Map<String, AiTool> _tools = {};

  /// Tool names currently disabled. Disabled tools are hidden from the LLM
  /// and rejected if called. Used to toggle built-in UI tools on/off.
  final Set<String> _disabledTools = {};

  /// Tools that require user confirmation before executing.
  final Set<String> _confirmationRequired = {};

  /// Callback invoked when a confirmation-required tool is about to execute.
  /// Must return `true` to proceed, `false` to deny.
  Future<bool> Function(String toolName, Map<String, dynamic> args)?
  onConfirmationRequired;

  /// Mark tools as requiring user confirmation before execution.
  void setConfirmationRequired(Iterable<String> names) {
    _confirmationRequired.addAll(names);
  }

  /// Remove confirmation requirement from tools.
  void clearConfirmationRequired(Iterable<String> names) {
    _confirmationRequired.removeAll(names);
  }

  /// Register a tool. Replaces any existing tool with the same name.
  void register(AiTool tool) {
    AiLogger.log('Registered tool: ${tool.name}', tag: 'Tools');
    _tools[tool.name] = tool;
  }

  /// Register multiple tools at once.
  void registerAll(Iterable<AiTool> tools) {
    for (final tool in tools) {
      _tools[tool.name] = tool;
    }
  }

  /// Unregister a tool by name.
  void unregister(String name) {
    _tools.remove(name);
  }

  /// Disable tools by name. They remain registered but are hidden from the
  /// LLM and rejected if called.
  void disableTools(Iterable<String> names) {
    _disabledTools.addAll(names);
  }

  /// Re-enable previously disabled tools.
  void enableTools(Iterable<String> names) {
    _disabledTools.removeAll(names);
  }

  /// Whether a tool with the given name is registered.
  bool has(String name) => _tools.containsKey(name);

  /// Get all tool definitions (for sending to the LLM).
  /// Excludes disabled tools.
  List<ToolDefinition> getToolDefinitions() {
    return _tools.entries
        .where((e) => !_disabledTools.contains(e.key))
        .map((e) => e.value.toDefinition())
        .toList();
  }

  /// Execute a tool call returned by the LLM.
  ///
  /// Looks up the tool by name and calls its handler with the provided arguments.
  /// Returns a [ToolResult] with success/failure and data.
  Future<ToolResult> executeTool(ToolCall call) async {
    if (_disabledTools.contains(call.name)) {
      return ToolResult.fail(
        'Tool "${call.name}" is currently disabled (chatbot mode).',
      );
    }

    // Confirmation gate — pause and ask the user before executing.
    if (_confirmationRequired.contains(call.name) &&
        onConfirmationRequired != null) {
      final approved = await onConfirmationRequired!(call.name, call.arguments);
      if (!approved) {
        AiLogger.log('Tool "${call.name}" denied by user', tag: 'Tools');
        return ToolResult.fail(
          'L\'utente ha negato il permesso per questa azione. '
          'Non riprovare, rispondi con un messaggio testuale.',
        );
      }
    }

    final tool = _tools[call.name];
    if (tool == null) {
      return ToolResult.fail('Unknown tool: ${call.name}');
    }

    try {
      final data = await tool.handler(call.arguments);
      AiLogger.log('Tool "${call.name}" succeeded', tag: 'Tools');
      return ToolResult.ok(data);
    } catch (e) {
      AiLogger.error('Tool "${call.name}" failed: $e', tag: 'Tools');
      return ToolResult.fail('Tool "${call.name}" failed: $e');
    }
  }

  /// Clear all registered tools.
  void clear() {
    _tools.clear();
  }

  /// Number of registered tools.
  int get length => _tools.length;

  /// Names of all registered tools.
  Iterable<String> get toolNames => _tools.keys;
}
