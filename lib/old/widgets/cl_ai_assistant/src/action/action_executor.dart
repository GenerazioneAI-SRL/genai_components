import 'package:flutter/widgets.dart';

import '../context/semantics_walker.dart';
import '../tools/tool_result.dart';
import 'executors/input_executor.dart';
import 'executors/navigation_executor.dart';
import 'executors/node_finder.dart';
import 'executors/scroll_executor.dart';
import 'executors/semantics_action_runner.dart';
import 'executors/stepper_executor.dart';
import 'executors/tap_executor.dart';
import 'scroll_handler.dart';

/// Executes actions on the live Flutter UI via the Semantics tree.
///
/// This is the bridge between what the LLM decides to do (tool calls) and
/// the actual UI interactions. All actions are performed through
/// [SemanticsOwner.performAction], which triggers the same callbacks as
/// real user interactions (taps, text input, scrolling, etc.).
///
/// Internally this class is a thin facade: each public method delegates
/// to a focused sub-executor (tap, input, scroll, stepper, navigation)
/// living under `executors/`. The public API is unchanged.
class ActionExecutor {
  /// Optional callback for custom route navigation.
  /// If provided, used by [navigateToRoute] instead of Navigator.
  final Future<void> Function(String routeName)? onNavigateToRoute;

  /// Global navigator key for fallback navigation.
  final GlobalKey<NavigatorState>? navigatorKey;

  final SemanticsWalker _walker;
  final TapExecutor _tapExecutor;
  final InputExecutor _inputExecutor;
  final ScrollExecutor _scrollExecutor;
  final StepperExecutor _stepperExecutor;
  final NavigationExecutor _navigationExecutor;

  ActionExecutor._({
    required SemanticsWalker walker,
    required this.onNavigateToRoute,
    required this.navigatorKey,
    required TapExecutor tapExecutor,
    required InputExecutor inputExecutor,
    required ScrollExecutor scrollExecutor,
    required StepperExecutor stepperExecutor,
    required NavigationExecutor navigationExecutor,
  }) : _walker = walker,
       _tapExecutor = tapExecutor,
       _inputExecutor = inputExecutor,
       _scrollExecutor = scrollExecutor,
       _stepperExecutor = stepperExecutor,
       _navigationExecutor = navigationExecutor;

  factory ActionExecutor({
    required SemanticsWalker walker,
    Future<void> Function(String routeName)? onNavigateToRoute,
    GlobalKey<NavigatorState>? navigatorKey,
    NavigatorObserver? navigatorObserver,
    List<String> knownRoutes = const [],
  }) {
    // One shared runner + finder across all sub-executors. They are
    // stateless wrappers around the semantics tree, so reusing them
    // avoids duplicate allocations.
    final runner = SemanticsActionRunner();
    final finder = NodeFinder(walker: walker);
    final scrollHandler = ScrollHandler(walker: walker);

    return ActionExecutor._(
      walker: walker,
      onNavigateToRoute: onNavigateToRoute,
      navigatorKey: navigatorKey,
      tapExecutor: TapExecutor(
        walker: walker,
        finder: finder,
        runner: runner,
        scrollHandler: scrollHandler,
      ),
      inputExecutor: InputExecutor(finder: finder, runner: runner),
      scrollExecutor: ScrollExecutor(walker: walker, runner: runner),
      stepperExecutor: StepperExecutor(finder: finder, runner: runner),
      navigationExecutor: NavigationExecutor(
        finder: finder,
        runner: runner,
        onNavigateToRoute: onNavigateToRoute,
        navigatorKey: navigatorKey,
        navigatorObserver: navigatorObserver,
        knownRoutes: knownRoutes,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Public API — delegated to focused sub-executors. Signatures unchanged.
  // ---------------------------------------------------------------------------

  /// Tap an element identified by its label text.
  ///
  /// Uses [parentContext] to disambiguate when multiple elements share
  /// the same label (e.g., multiple "Add" buttons in a product list).
  Future<ToolResult> tapElement(String label, {String? parentContext}) =>
      _tapExecutor.tapElement(label, parentContext: parentContext);

  /// Enter text into a text field identified by its label or hint.
  Future<ToolResult> setText(
    String label,
    String text, {
    String? parentContext,
  }) => _inputExecutor.setText(label, text, parentContext: parentContext);

  /// Scroll the current scrollable area in the given direction.
  Future<ToolResult> scroll(String direction) =>
      _scrollExecutor.scroll(direction);

  /// Navigate to a named route.
  ///
  /// The LLM may provide route names without a leading `/` or with
  /// incorrect casing. The route is normalized before navigating to avoid
  /// common mismatches.
  Future<ToolResult> navigateToRoute(String routeName) =>
      _navigationExecutor.navigateToRoute(routeName);

  /// Pop the current route (go back).
  Future<ToolResult> goBack() => _navigationExecutor.goBack();

  /// Re-capture the current screen and return a description.
  ///
  /// Includes a settle delay before capturing so that asynchronously-loaded
  /// content (network results, animations) has time to appear in the
  /// semantics tree.
  Future<ToolResult> getScreenContent() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final context = _walker.captureScreenContext();
    return ToolResult.ok({'screenContent': context.toPromptString()});
  }

  /// Long press an element.
  Future<ToolResult> longPress(String label, {String? parentContext}) =>
      _tapExecutor.longPress(label, parentContext: parentContext);

  /// Increase the value of a slider/stepper.
  ///
  /// The LLM often targets the quantity text (e.g. "1") which doesn't support
  /// increase. The actual stepper container or a sibling/parent node usually
  /// holds the action. This method tries progressively broader searches.
  Future<ToolResult> increaseValue(String label) =>
      _stepperExecutor.increaseValue(label);

  /// Decrease the value of a slider/stepper.
  ///
  /// Same progressive search as [increaseValue] — see its doc comment.
  Future<ToolResult> decreaseValue(String label) =>
      _stepperExecutor.decreaseValue(label);
}
