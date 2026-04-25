import 'package:flutter/semantics.dart';

import '../../context/semantics_walker.dart';
import '../../tools/tool_result.dart';
import 'semantics_action_runner.dart';

/// Drives directional scrolling on the current scrollable area.
///
/// Distinct from [ScrollHandler], which handles longer "scroll-to-find"
/// loops. This executor performs single-step scrolls keyed off semantics
/// actions.
class ScrollExecutor {
  final SemanticsWalker _walker;
  final SemanticsActionRunner _runner;

  ScrollExecutor({
    required SemanticsWalker walker,
    required SemanticsActionRunner runner,
  }) : _walker = walker,
       _runner = runner;

  /// Scroll the current scrollable area in the given direction.
  Future<ToolResult> scroll(String direction) async {
    final context = _walker.captureScreenContext();
    final scrollable = context.firstScrollable;

    if (scrollable == null) {
      return ToolResult.fail('No scrollable area found on the current screen.');
    }

    final action = switch (direction.toLowerCase()) {
      'up' => SemanticsAction.scrollUp,
      'down' => SemanticsAction.scrollDown,
      'left' => SemanticsAction.scrollLeft,
      'right' => SemanticsAction.scrollRight,
      _ => null,
    };

    if (action == null) {
      return ToolResult.fail(
        "Invalid scroll direction: '$direction'. Use up, down, left, or right.",
      );
    }

    final node = _walker.findNodeById(scrollable.nodeId);
    if (node == null) {
      return ToolResult.fail('Scrollable element no longer available.');
    }

    final data = node.getSemanticsData();
    if (!data.actions.containsAction(action)) {
      return ToolResult.fail("Cannot scroll $direction — already at the edge.");
    }

    _runner.performAction(node.id, action);
    await _runner.waitForFrame();
    // Extra wait for scroll animation and content loading to settle.
    await Future.delayed(const Duration(milliseconds: 250));
    return ToolResult.ok({'scrolled': direction});
  }
}
