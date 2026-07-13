import 'package:flutter/semantics.dart';

import '../../context/semantics_walker.dart';
import '../../core/ai_logger.dart';
import '../../models/ui_element.dart';
import 'semantics_action_runner.dart';

/// Locates [SemanticsNode]s on the live screen using a mix of label text,
/// element type, available actions and positional heuristics.
///
/// Centralizes all node-finding logic so action executors (tap, setText,
/// stepper, etc.) share the exact same disambiguation rules.
class NodeFinder {
  final SemanticsWalker _walker;

  NodeFinder({required SemanticsWalker walker}) : _walker = walker;

  /// Find a SemanticsNode by matching its label, with optional disambiguation.
  SemanticsNode? findNode(
    String label, {
    String? parentContext,
    UiElementType? preferType,
  }) {
    final context = _walker.captureScreenContext();
    final normalizedLabel = label.toLowerCase();

    // Find all elements whose label contains the search term.
    var matches = context.elements.where(
      (e) => e.label.toLowerCase().contains(normalizedLabel),
    );
    AiLogger.log(
      '_findNode: "$label" -> ${matches.length} match(es) from ${context.elements.length} elements',
      tag: 'Action',
    );

    // If preferring a specific type, narrow to that type when possible.
    // If no label matches are of the right type, KEEP all label matches
    // so we can still tap/interact with the element found by label.
    if (preferType != null) {
      final typed = matches.where((e) => e.type == preferType);
      if (typed.isNotEmpty) matches = typed;
    }

    final matchList = matches.toList();
    if (matchList.isEmpty) {
      // Also try matching by hint text.
      final hintMatches = context.elements
          .where(
            (e) => e.hint?.toLowerCase().contains(normalizedLabel) ?? false,
          )
          .toList();
      if (hintMatches.isNotEmpty) {
        return _walker.findNodeById(hintMatches.first.nodeId);
      }

      // For short symbolic labels ("+", "-") with parentContext, try finding
      // unlabeled tappable buttons near the parent element. Common pattern:
      // Icon buttons in steppers have no semantic label.
      if (label.length <= 2 && parentContext != null) {
        final normalizedParent = parentContext.toLowerCase();
        // Find elements matching the parent context.
        final parentMatches = context.elements.where(
          (e) => e.label.toLowerCase().contains(normalizedParent),
        );
        if (parentMatches.isNotEmpty) {
          final parentEl = parentMatches.first;
          final parentY = parentEl.bounds.center.dy;
          // Find tappable elements with empty labels on the same row.
          final nearbyButtons = context.elements.where((e) {
            if (e.label.isNotEmpty) return false;
            if (!e.availableActions.contains('tap')) return false;
            final dy = (e.bounds.center.dy - parentY).abs();
            return dy < 60; // Same row within 60px
          }).toList();

          if (nearbyButtons.isNotEmpty) {
            // For "+", pick rightmost; for "-", pick leftmost.
            nearbyButtons.sort(
              (a, b) => a.bounds.center.dx.compareTo(b.bounds.center.dx),
            );
            final target = (label == '+' || label == 'plus')
                ? nearbyButtons.last
                : nearbyButtons.first;
            AiLogger.log(
              '_findNode: positional match for "$label" near "$parentContext" '
              '-> node ${target.nodeId}',
              tag: 'Action',
            );
            return _walker.findNodeById(target.nodeId);
          }
        }
      }

      return null;
    }

    if (matchList.length == 1) {
      return _walker.findNodeById(matchList.first.nodeId);
    }

    // Multiple matches: disambiguate using parentContext.
    // Prefer exact matches over substring matches to avoid "Product 123"
    // matching "Product 1234" or "Product 123-XL".
    if (parentContext != null) {
      final normalizedParent = parentContext.toLowerCase();

      // Pass 1: exact match on a parent label.
      final exactMatch = matchList.where(
        (e) => e.parentLabels.any((p) => p.toLowerCase() == normalizedParent),
      );
      if (exactMatch.isNotEmpty) {
        return _walker.findNodeById(exactMatch.first.nodeId);
      }

      // Pass 2: substring match (looser).
      final substringMatch = matchList.where(
        (e) => e.parentLabels.any(
          (p) => p.toLowerCase().contains(normalizedParent),
        ),
      );
      if (substringMatch.isNotEmpty) {
        return _walker.findNodeById(substringMatch.first.nodeId);
      }
    }

    // Fallback: prefer interactive elements, then first match.
    final interactive = matchList.where((e) => e.availableActions.isNotEmpty);
    if (interactive.isNotEmpty) {
      return _walker.findNodeById(interactive.first.nodeId);
    }

    return _walker.findNodeById(matchList.first.nodeId);
  }

  /// Find a SemanticsNode that supports a specific [action] (increase/decrease).
  ///
  /// Progressively broader search:
  /// 1. Find node by label — if it supports the action, return it.
  /// 2. If multiple nodes match the label, try each for the action.
  /// 3. Walk up the parent chain of each match (stepper containers often hold
  ///    the increase/decrease action on a parent, not the text child).
  /// 4. Search ALL nodes on screen for one that supports the action near
  ///    the matched element (fallback for unlabeled steppers).
  SemanticsNode? findNodeWithAction(String label, SemanticsAction action) {
    final context = _walker.captureScreenContext();
    final normalizedLabel = label.toLowerCase();

    // Find all elements whose label contains the search term.
    final matches = context.elements
        .where((e) => e.label.toLowerCase().contains(normalizedLabel))
        .toList();
    AiLogger.log(
      '_findNodeWithAction: "$label" -> ${matches.length} match(es), '
      'looking for ${action.name}',
      tag: 'Action',
    );

    // Step 1-2: Check each matching node directly.
    for (final match in matches) {
      final node = _walker.findNodeById(match.nodeId);
      if (node == null) continue;
      final data = node.getSemanticsData();
      if (data.actions.containsAction(action)) {
        AiLogger.log(
          '_findNodeWithAction: direct match on node ${node.id}',
          tag: 'Action',
        );
        return node;
      }
    }

    // Step 3: Walk up parent chain of each match (max 3 levels).
    for (final match in matches) {
      final node = _walker.findNodeById(match.nodeId);
      if (node == null) continue;
      SemanticsNode? current = node.parent;
      for (int depth = 0; depth < 3 && current != null; depth++) {
        final data = current.getSemanticsData();
        if (data.actions.containsAction(action)) {
          AiLogger.log(
            '_findNodeWithAction: found on parent node ${current.id} '
            '(depth ${depth + 1} from "${match.label}")',
            tag: 'Action',
          );
          return current;
        }
        current = current.parent;
      }
    }

    // Step 4: Find ANY node on screen that supports the action.
    // This handles cases where the stepper has no label at all.
    for (final element in context.elements) {
      final node = _walker.findNodeById(element.nodeId);
      if (node == null) continue;
      final data = node.getSemanticsData();
      if (data.actions.containsAction(action)) {
        AiLogger.log(
          '_findNodeWithAction: fallback — found node ${node.id} '
          '("${element.label}") with ${action.name}',
          tag: 'Action',
        );
        return node;
      }
    }

    AiLogger.log(
      '_findNodeWithAction: no node with ${action.name} found on screen',
      tag: 'Action',
    );
    return null;
  }

  /// Find a tappable button that looks like a stepper +/- control.
  ///
  /// Strategy:
  /// 1. Search by label patterns ("+", "Increase quantity", etc.)
  /// 2. If no labeled match, find unlabeled tappable buttons NEAR the target
  ///    product — common pattern for `IconButton(Icons.add)` without semantics.
  ///    Stepper buttons typically appear as: [- button] [count text] [+ button],
  ///    so we look for small tappable nodes adjacent to a number value.
  SemanticsNode? findStepperButton(String label, {required bool isIncrease}) {
    final context = _walker.captureScreenContext();

    final patterns = isIncrease
        ? const ['increase quantity', 'increase', '+', 'plus', 'add']
        : const [
            'decrease quantity',
            'decrease',
            '-',
            'minus',
            'subtract',
            'remove',
          ];

    // Pass 1: Search by label patterns (including non-empty labels).
    for (final element in context.elements) {
      final lower = element.label.toLowerCase().trim();
      if (lower.isEmpty) continue;

      final matches = patterns.any((p) => lower == p || lower.contains(p));
      if (!matches) continue;

      final node = _walker.findNodeById(element.nodeId);
      if (node == null) continue;

      final data = node.getSemanticsData();
      if (data.actions.containsAction(SemanticsAction.tap)) {
        AiLogger.log(
          '_findStepperButton: found "${element.label}" (node ${node.id}) '
          'as ${isIncrease ? "increase" : "decrease"} fallback',
          tag: 'Action',
        );
        return node;
      }
    }

    // Pass 2: Find unlabeled tappable buttons near a number value.
    // Stepper layouts: [- button (empty label)] [Text "1"] [+ button (empty label)]
    // Find elements showing a numeric value, then look at nearby tappable
    // elements with empty labels (icon buttons).
    final normalizedLabel = label.toLowerCase();
    final numberElements = <UiElement>[];
    final emptyLabelButtons = <UiElement>[];

    for (final element in context.elements) {
      final lower = element.label.toLowerCase().trim();
      // Numeric elements (the count display "1", "2", etc.)
      if (lower.isNotEmpty && RegExp(r'^\d+$').hasMatch(lower)) {
        // Check if this number is near the target product in the element tree.
        final isNearTarget = element.parentLabels.any(
          (p) => p.toLowerCase().contains(normalizedLabel),
        );
        if (isNearTarget) numberElements.add(element);
      }
      // Empty-label tappable buttons (likely icon buttons)
      if (lower.isEmpty && element.availableActions.contains('tap')) {
        emptyLabelButtons.add(element);
      }
    }

    // For each number element near the target, find adjacent empty-label buttons.
    for (final numEl in numberElements) {
      final numY = numEl.bounds.center.dy;
      final numX = numEl.bounds.center.dx;

      // Find empty-label tappable buttons on the same horizontal line.
      final nearby = emptyLabelButtons.where((btn) {
        final dy = (btn.bounds.center.dy - numY).abs();
        return dy < 40; // Same row (within 40px vertically).
      }).toList();

      if (nearby.isEmpty) continue;

      // Sort by X position. For increase (+), pick the one to the RIGHT of
      // the number. For decrease (-), pick the one to the LEFT.
      nearby.sort((a, b) => a.bounds.center.dx.compareTo(b.bounds.center.dx));

      final candidates = isIncrease
          ? nearby.where((btn) => btn.bounds.center.dx > numX)
          : nearby.where((btn) => btn.bounds.center.dx < numX);

      if (candidates.isNotEmpty) {
        final target = isIncrease ? candidates.first : candidates.last;
        final node = _walker.findNodeById(target.nodeId);
        if (node != null) {
          AiLogger.log(
            '_findStepperButton: found unlabeled button (node ${node.id}) '
            '${isIncrease ? "right" : "left"} of count "${numEl.label}" '
            'near "$label"',
            tag: 'Action',
          );
          return node;
        }
      }
    }

    AiLogger.log(
      '_findStepperButton: no ${isIncrease ? "increase" : "decrease"} '
      'button found on screen',
      tag: 'Action',
    );
    return null;
  }

  /// Find the best TextField node on screen that supports setText.
  ///
  /// Prefers focused fields over unfocused, and picks the LAST editable
  /// field in document order (most likely the newly-opened search bar).
  SemanticsNode? findAnyTextField() {
    final context = _walker.captureScreenContext();
    final textFields = context.elements
        .where((e) => e.type == UiElementType.textField)
        .toList();
    if (textFields.isEmpty) return null;

    // Prefer a focused field if one exists.
    SemanticsNode? bestNode;
    String? bestLabel;
    for (final tf in textFields) {
      final node = _walker.findNodeById(tf.nodeId);
      if (node == null) continue;
      final data = node.getSemanticsData();
      if (!data.actions.containsAction(SemanticsAction.setText)) continue;
      // ignore: deprecated_member_use
      final isFocused = data.hasFlag(SemanticsFlag.isFocused);
      if (isFocused) {
        AiLogger.log(
          '_findAnyTextField: found focused "${tf.label}" (node ${node.id})',
          tag: 'Action',
        );
        return node; // Focused field wins immediately.
      }
      // Track the last editable field as fallback.
      bestNode = node;
      bestLabel = tf.label;
    }

    if (bestNode != null) {
      AiLogger.log(
        '_findAnyTextField: found "$bestLabel" (node ${bestNode.id})',
        tag: 'Action',
      );
    }
    return bestNode;
  }

  /// Search for a node with a dismiss action (back button, close button, etc.).
  SemanticsNode? findDismissableNode(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.actions & SemanticsAction.dismiss.index != 0) return node;
    SemanticsNode? result;
    node.visitChildren((child) {
      result ??= findDismissableNode(child);
      return result == null;
    });
    return result;
  }

  /// Resolve a [SemanticsNode] by id via the wrapped [SemanticsWalker].
  SemanticsNode? findNodeById(int id) => _walker.findNodeById(id);

  /// Capture the current screen context once (delegating to the walker).
  dynamic captureScreenContext() => _walker.captureScreenContext();
}
