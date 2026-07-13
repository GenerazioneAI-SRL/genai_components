import 'package:flutter/semantics.dart';

import '../../context/semantics_walker.dart';
import '../../core/ai_logger.dart';
import '../../tools/tool_result.dart';
import '../scroll_handler.dart';
import 'node_finder.dart';
import 'semantics_action_runner.dart';

/// Handles tap-style actions: single tap (with screen-change detection
/// and transient feedback capture) and long press.
class TapExecutor {
  final SemanticsWalker _walker;
  final NodeFinder _finder;
  final SemanticsActionRunner _runner;
  final ScrollHandler _scrollHandler;

  TapExecutor({
    required SemanticsWalker walker,
    required NodeFinder finder,
    required SemanticsActionRunner runner,
    required ScrollHandler scrollHandler,
  }) : _walker = walker,
       _finder = finder,
       _runner = runner,
       _scrollHandler = scrollHandler;

  /// Tap an element identified by its label text.
  ///
  /// Uses [parentContext] to disambiguate when multiple elements share
  /// the same label (e.g., multiple "Add" buttons in a product list).
  Future<ToolResult> tapElement(String label, {String? parentContext}) async {
    AiLogger.log(
      'tapElement: "$label" (parentContext=$parentContext)',
      tag: 'Action',
    );
    final node = _finder.findNode(label, parentContext: parentContext);
    if (node == null) {
      // Try scrolling to find the element.
      final scrollResult = await _scrollHandler.scrollToFind(label: label);
      if (scrollResult == null) {
        return ToolResult.fail(
          "Element '$label' not found on screen. "
          'Try scrolling or navigating to a different screen.',
        );
      }
      return _performTap(scrollResult, label);
    }
    return _performTap(node, label);
  }

  /// Long press an element.
  Future<ToolResult> longPress(String label, {String? parentContext}) async {
    final node = _finder.findNode(label, parentContext: parentContext);
    if (node == null) {
      return ToolResult.fail("Element '$label' not found on screen.");
    }

    final data = node.getSemanticsData();
    if (!data.actions.containsAction(SemanticsAction.longPress)) {
      return ToolResult.fail("Element '$label' does not support long press.");
    }

    _runner.performAction(node.id, SemanticsAction.longPress);
    await _runner.waitForFrame();
    return ToolResult.ok({'longPressed': label});
  }

  Future<ToolResult> _performTap(SemanticsNode node, String label) async {
    var data = node.getSemanticsData();
    if (!data.actions.containsAction(SemanticsAction.tap)) {
      // Walk up parent chain to find a tappable ancestor (max 5 levels).
      // Common pattern: Text label is a child of an InkWell/GestureDetector
      // whose semantics node holds the tap action.
      SemanticsNode? current = node.parent;
      SemanticsNode? tappableAncestor;
      for (int depth = 0; depth < 5 && current != null; depth++) {
        final parentData = current.getSemanticsData();
        if (parentData.actions.containsAction(SemanticsAction.tap)) {
          tappableAncestor = current;
          AiLogger.log(
            '_performTap: "$label" not tappable, found tappable ancestor '
            'at depth ${depth + 1} (node ${current.id})',
            tag: 'Action',
          );
          break;
        }
        current = current.parent;
      }
      if (tappableAncestor == null) {
        return ToolResult.fail("Element '$label' is not tappable.");
      }
      node = tappableAncestor;
    }

    // Capture element labels before tap for change detection.
    final beforeContext = _walker.captureScreenContext();
    final beforeLabels = <String>{
      for (final e in beforeContext.elements) e.label.toLowerCase(),
    };

    _runner.performAction(node.id, SemanticsAction.tap);
    await _runner.waitForFrame();

    // Flash capture immediately after tap to catch transient feedback
    // (snackbars, toasts) before they disappear.
    final flashContext = _walker.captureScreenContext();

    // Extra settle time for UI state changes (dialogs, animations, network loads).
    await Future.delayed(const Duration(milliseconds: 300));

    // Re-capture after settle to detect screen changes.
    // Compare label sets, not just counts — catches in-place content changes,
    // modals that replace elements, and other mutations that keep the count stable.
    final afterContext = _walker.captureScreenContext();
    final afterLabels = <String>{
      for (final e in afterContext.elements) e.label.toLowerCase(),
    };
    final addedLabels = afterLabels.difference(beforeLabels);
    final removedLabels = beforeLabels.difference(afterLabels);
    final screenChanged = addedLabels.length + removedLabels.length > 1;

    // Extract transient feedback from both flash and settled snapshots.
    final transientFeedback = _extractTransientFeedback(
      flashContext,
      beforeContext,
      afterContext,
    );

    final result = <String, dynamic>{
      'tapped': label,
      'screenChanged': screenChanged,
    };
    if (!screenChanged) {
      result['hint'] =
          'Screen appears unchanged — element may be disabled or the action had no visible effect.';
    }
    if (transientFeedback != null) {
      result['feedback'] = transientFeedback;
    }
    return ToolResult.ok(result);
  }

  /// Extract transient feedback (snackbar/toast messages) by comparing
  /// screen state before and after an action.
  ///
  /// Also captures from the post-settle snapshot to catch feedback that
  /// appears with a slight delay (network confirmations, animated toasts).
  String? _extractTransientFeedback(
    dynamic flashContext,
    dynamic beforeContext, [
    dynamic settledContext,
  ]) {
    try {
      final beforeLabels = <String>{};
      for (final e in (beforeContext as dynamic).elements) {
        beforeLabels.add((e.label as String).toLowerCase());
      }

      const transientKeywords = [
        'added',
        'removed',
        'success',
        'error',
        'failed',
        'deleted',
        'updated',
        'saved',
        'confirmed',
        'cancelled',
        'cart',
      ];

      // Check both the flash capture (immediate) and settled capture (delayed).
      final snapshots = [flashContext, settledContext];
      for (final snapshot in snapshots) {
        for (final e in (snapshot as dynamic).elements) {
          final label = e.label as String;
          final lower = label.toLowerCase();
          if (beforeLabels.contains(lower)) continue; // Not new.
          if (transientKeywords.any((k) => lower.contains(k))) {
            AiLogger.log(
              'Transient feedback captured: "$label"',
              tag: 'Action',
            );
            return label;
          }
        }
      }
    } catch (e) {
      AiLogger.warn('Transient feedback extraction failed: $e', tag: 'Action');
    }
    return null;
  }
}
