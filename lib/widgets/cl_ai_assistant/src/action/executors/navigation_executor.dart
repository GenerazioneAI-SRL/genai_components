import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../../core/ai_logger.dart';
import '../../tools/tool_result.dart';
import 'node_finder.dart';
import 'semantics_action_runner.dart';

/// Handles route navigation, back/dismiss, and context capture actions.
class NavigationExecutor {
  final NodeFinder _finder;
  final SemanticsActionRunner _runner;

  /// Optional callback for custom route navigation.
  /// If provided, used instead of [NavigatorState].
  final Future<void> Function(String routeName)? onNavigateToRoute;

  /// Global navigator key for fallback navigation.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Navigator observer whose [NavigatorObserver.navigator] provides
  /// a fallback [NavigatorState] when no explicit key or callback is given.
  final NavigatorObserver? navigatorObserver;

  /// Known route names in the app (e.g., ["/home", "/settings"]).
  final List<String> knownRoutes;

  NavigationExecutor({
    required NodeFinder finder,
    required SemanticsActionRunner runner,
    this.onNavigateToRoute,
    this.navigatorKey,
    this.navigatorObserver,
    this.knownRoutes = const [],
  }) : _finder = finder,
       _runner = runner;

  /// Resolve the best available [NavigatorState]:
  /// 1. Explicit [navigatorKey]
  /// 2. [NavigatorObserver.navigator] (auto-set when observer is attached)
  NavigatorState? get _navigator =>
      navigatorKey?.currentState ?? navigatorObserver?.navigator;

  /// Navigate to a named route.
  ///
  /// The LLM may provide route names without a leading `/` or with
  /// incorrect casing. [_resolveRouteName] normalizes the input before
  /// navigating to avoid common mismatches.
  Future<ToolResult> navigateToRoute(String routeName) async {
    final resolved = _resolveRouteName(routeName);
    AiLogger.log(
      'navigateToRoute: "$routeName" -> resolved="$resolved"',
      tag: 'Action',
    );

    // If the resolved route wasn't found in known routes, fail fast with
    // a suggestion instead of attempting navigation that will crash.
    if (knownRoutes.isNotEmpty && !knownRoutes.contains(resolved)) {
      final suggestion = _findClosestRoute(resolved);
      return ToolResult.fail(
        "Route '$resolved' is not a known route. "
        'Available routes: ${knownRoutes.join(', ')}'
        '${suggestion != null ? '. Did you mean "$suggestion"?' : '.'}',
      );
    }

    // Priority 1: developer-provided navigation callback.
    if (onNavigateToRoute != null) {
      try {
        await onNavigateToRoute!(resolved);
        await _runner.waitForFrame();
        // Extra settle time for route transition animations and content loading.
        await Future.delayed(const Duration(milliseconds: 500));
        return ToolResult.ok({'navigatedTo': resolved});
      } catch (e) {
        return ToolResult.fail(
          "Navigation to '$resolved' failed: $e. "
          '${knownRoutes.isNotEmpty ? 'Available routes: ${knownRoutes.join(', ')}' : ''}',
        );
      }
    }

    // Priority 2: NavigatorState from key or observer.
    final navigator = _navigator;
    if (navigator != null) {
      try {
        // Do NOT await pushNamed — it returns a Future that resolves when the
        // route is POPPED, not pushed. Awaiting would block the agent forever.
        unawaited(navigator.pushNamed(resolved));
        await _runner.waitForFrame();
        // Extra settle time for route transition animations and content loading.
        await Future.delayed(const Duration(milliseconds: 500));
        return ToolResult.ok({'navigatedTo': resolved});
      } catch (e) {
        return ToolResult.fail(
          "Navigation to '$resolved' failed: $e. "
          '${knownRoutes.isNotEmpty ? 'Available routes: ${knownRoutes.join(', ')}' : ''}',
        );
      }
    }

    return ToolResult.fail(
      "Cannot navigate: no navigation handler or navigator key configured. "
      "Add the navigatorObserver to your MaterialApp's navigatorObservers list.",
    );
  }

  /// Pop the current route (go back).
  Future<ToolResult> goBack() async {
    // Priority 1: NavigatorState from key or observer.
    final navigator = _navigator;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      await _runner.waitForFrame();
      return ToolResult.ok({'action': 'navigated back'});
    }

    // Priority 2: semantics dismiss action (works for dialogs, sheets, etc.).
    final owner = _runner.rootOwner;
    final root = owner?.rootSemanticsNode;
    if (owner != null && root != null) {
      final dismissNode = _finder.findDismissableNode(root);
      if (dismissNode != null) {
        owner.performAction(dismissNode.id, SemanticsAction.dismiss);
        await _runner.waitForFrame();
        return ToolResult.ok({'action': 'navigated back'});
      }
    }

    return ToolResult.fail('Cannot go back — already at the root screen.');
  }

  /// Resolve a route name from the LLM to the actual registered route.
  ///
  /// The LLM may add or strip the leading `/`, use inconsistent casing,
  /// or otherwise mangle the route name. This method tries progressively
  /// looser matching:
  /// 1. Exact match (e.g., "Dipendenti" → "Dipendenti")
  /// 2. Strip `/` prefix (e.g., "/Dipendenti" → "Dipendenti")
  /// 3. Add `/` prefix (e.g., "settings" → "/settings")
  /// 4. Case-insensitive match
  /// 5. Fallback: return original input and warn.
  String _resolveRouteName(String input) {
    // 1. Exact match.
    if (knownRoutes.contains(input)) return input;

    // 2. Strip leading `/` and check.
    final withoutSlash = input.startsWith('/') ? input.substring(1) : input;
    if (knownRoutes.contains(withoutSlash)) return withoutSlash;

    // 3. Add leading `/` and check.
    final withSlash = input.startsWith('/') ? input : '/$input';
    if (knownRoutes.contains(withSlash)) return withSlash;

    // 4. Case-insensitive match (try both with and without slash).
    final lowerInput = input.toLowerCase();
    final lowerWithout = withoutSlash.toLowerCase();
    final lowerWith = withSlash.toLowerCase();
    for (final route in knownRoutes) {
      final lowerRoute = route.toLowerCase();
      if (lowerRoute == lowerInput ||
          lowerRoute == lowerWithout ||
          lowerRoute == lowerWith) {
        return route;
      }
    }

    // 5. Fallback: return original input and warn.
    AiLogger.warn(
      'Route "$input" not found in known routes, using "$input"',
      tag: 'Action',
    );
    return input;
  }

  /// Find the closest known route to [input] using simple substring overlap.
  /// Returns null if no reasonable match exists.
  String? _findClosestRoute(String input) {
    if (knownRoutes.isEmpty) return null;
    final lower = input.replaceAll('/', '').toLowerCase();
    String? best;
    int bestScore = 0;
    for (final route in knownRoutes) {
      final routeLower = route.replaceAll('/', '').toLowerCase();
      // Count shared characters as a rough similarity score.
      int score = 0;
      for (int i = 0; i < lower.length && i < routeLower.length; i++) {
        if (lower[i] == routeLower[i]) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        best = route;
      }
    }
    // Only suggest if at least 3 chars match (avoids garbage suggestions).
    return bestScore >= 3 ? best : null;
  }
}
