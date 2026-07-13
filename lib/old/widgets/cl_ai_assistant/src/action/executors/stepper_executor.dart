import 'package:flutter/semantics.dart';

import '../../tools/tool_result.dart';
import 'node_finder.dart';
import 'semantics_action_runner.dart';

/// Increment/decrement actions for sliders and stepper widgets.
///
/// Tries the native [SemanticsAction.increase]/[SemanticsAction.decrease]
/// path first, then falls back to tapping a +/- button found via
/// [NodeFinder.findStepperButton].
class StepperExecutor {
  final NodeFinder _finder;
  final SemanticsActionRunner _runner;

  StepperExecutor({
    required NodeFinder finder,
    required SemanticsActionRunner runner,
  }) : _finder = finder,
       _runner = runner;

  /// Increase the value of a slider/stepper.
  ///
  /// The LLM often targets the quantity text (e.g. "1") which doesn't support
  /// increase. The actual stepper container or a sibling/parent node usually
  /// holds the action. This method tries progressively broader searches.
  Future<ToolResult> increaseValue(String label) async {
    final found = _finder.findNodeWithAction(label, SemanticsAction.increase);
    if (found != null) {
      _runner.performAction(found.id, SemanticsAction.increase);
      await _runner.waitForFrame();
      return ToolResult.ok({'increased': label});
    }

    // Fallback: find a tappable button that looks like an increase/+ control.
    final fallback = _finder.findStepperButton(label, isIncrease: true);
    if (fallback != null) {
      _runner.performAction(fallback.id, SemanticsAction.tap);
      await _runner.waitForFrame();
      await Future.delayed(const Duration(milliseconds: 300));
      return ToolResult.ok({'increased': label, 'via': 'tap_fallback'});
    }

    return ToolResult.fail(
      "Element '$label' does not support increase. "
      'Try tapping the "+" or "Increase quantity" button instead.',
    );
  }

  /// Decrease the value of a slider/stepper.
  ///
  /// Same progressive search as [increaseValue] — see its doc comment.
  Future<ToolResult> decreaseValue(String label) async {
    final found = _finder.findNodeWithAction(label, SemanticsAction.decrease);
    if (found != null) {
      _runner.performAction(found.id, SemanticsAction.decrease);
      await _runner.waitForFrame();
      return ToolResult.ok({'decreased': label});
    }

    // Fallback: find a tappable button that looks like a decrease/- control.
    final fallback = _finder.findStepperButton(label, isIncrease: false);
    if (fallback != null) {
      _runner.performAction(fallback.id, SemanticsAction.tap);
      await _runner.waitForFrame();
      await Future.delayed(const Duration(milliseconds: 300));
      return ToolResult.ok({'decreased': label, 'via': 'tap_fallback'});
    }

    return ToolResult.fail(
      "Element '$label' does not support decrease. "
      'Try tapping the "-" or "Decrease quantity" button instead.',
    );
  }
}
