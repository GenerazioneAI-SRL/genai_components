import 'package:flutter/semantics.dart';

import '../../core/ai_logger.dart';
import '../../models/ui_element.dart';
import '../../tools/tool_result.dart';
import 'node_finder.dart';
import 'semantics_action_runner.dart';

/// Handles text input actions (focus + setText with several fallbacks).
class InputExecutor {
  final NodeFinder _finder;
  final SemanticsActionRunner _runner;

  InputExecutor({
    required NodeFinder finder,
    required SemanticsActionRunner runner,
  }) : _finder = finder,
       _runner = runner;

  /// Enter text into a text field identified by its label or hint.
  Future<ToolResult> setText(
    String label,
    String text, {
    String? parentContext,
  }) async {
    AiLogger.log('setText: "$label" = "$text"', tag: 'Action');
    final node = _finder.findNode(
      label,
      parentContext: parentContext,
      preferType: UiElementType.textField,
    );
    if (node == null) {
      return ToolResult.fail("Text field '$label' not found on screen.");
    }

    final data = node.getSemanticsData();
    if (!data.actions.containsAction(SemanticsAction.setText)) {
      // Try tapping first to focus, then set text.
      if (data.actions.containsAction(SemanticsAction.tap)) {
        _runner.performAction(node.id, SemanticsAction.tap);
        await _runner.waitForFrame();
        // Extra settle for screen transitions (e.g. tapping a search container
        // that opens a new search screen with a real TextField).
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Retry on the SAME node (handles simple focus-to-activate fields).
      final retryData = node.getSemanticsData();
      if (retryData.actions.containsAction(SemanticsAction.setText)) {
        _runner.performSetText(node.id, text);
        await _runner.waitForFrame();
        return ToolResult.ok({'setText': label, 'value': text});
      }

      // The tap may have opened a NEW screen with a real TextField
      // (common pattern: tappable "Search" container opens a search screen).
      // Look for a TextField that appeared after the tap.
      final newNode = _finder.findNode(
        label,
        parentContext: parentContext,
        preferType: UiElementType.textField,
      );
      if (newNode != null && newNode.id != node.id) {
        final newData = newNode.getSemanticsData();
        if (newData.actions.containsAction(SemanticsAction.setText)) {
          _runner.performSetText(newNode.id, text);
          await _runner.waitForFrame();
          return ToolResult.ok({'setText': label, 'value': text});
        }
      }

      // Last resort: find ANY focused/editable text field on screen.
      final anyTextField = _finder.findAnyTextField();
      if (anyTextField != null) {
        _runner.performSetText(anyTextField.id, text);
        await _runner.waitForFrame();
        return ToolResult.ok({'setText': label, 'value': text});
      }

      return ToolResult.fail(
        "Cannot enter text in '$label'. It may not be a text field. "
        'Try tapping it first with tap_element, then use set_text.',
      );
    }

    _runner.performSetText(node.id, text);
    await _runner.waitForFrame();
    return ToolResult.ok({'setText': label, 'value': text});
  }
}
