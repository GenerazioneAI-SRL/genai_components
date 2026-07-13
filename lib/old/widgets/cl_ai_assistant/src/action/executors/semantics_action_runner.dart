import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../../core/ai_logger.dart';

/// Low-level helpers wrapping [SemanticsOwner] interactions.
///
/// Keeping these in one place ensures all sub-executors talk to the
/// semantics tree the same way (lookup of root owner, frame settling,
/// etc.) and avoids drift between action implementations.
class SemanticsActionRunner {
  /// Perform a semantics action on a node.
  void performAction(int nodeId, SemanticsAction action) {
    final views = WidgetsBinding.instance.renderViews;
    if (views.isEmpty) return;
    final owner = views.first.owner?.semanticsOwner;
    owner?.performAction(nodeId, action);
  }

  /// Perform a setText action on a node.
  void performSetText(int nodeId, String text) {
    final views = WidgetsBinding.instance.renderViews;
    if (views.isEmpty) return;
    final owner = views.first.owner?.semanticsOwner;
    owner?.performAction(nodeId, SemanticsAction.setText, text);
  }

  /// Resolve the active root [SemanticsOwner], if any.
  SemanticsOwner? get rootOwner {
    final views = WidgetsBinding.instance.renderViews;
    if (views.isEmpty) return null;
    return views.first.owner?.semanticsOwner;
  }

  /// Wait for the next frame to settle after performing an action.
  ///
  /// Times out after 5 seconds to prevent the agent from hanging forever
  /// if the render pipeline stalls or the widget tree is torn down.
  Future<void> waitForFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        if (!completer.isCompleted) completer.complete();
        AiLogger.warn('_waitForFrame timed out after 5s', tag: 'Action');
      },
    );
  }
}

/// Extension to check actions in the bitmask.
extension SemanticsActionBitmask on int {
  bool containsAction(SemanticsAction action) => this & action.index != 0;
}
