import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin that auto-disposes common stateful resources on `dispose()`.
///
/// Tracks: [TextEditingController], [FocusNode], [Timer], [StreamSubscription].
///
/// Usage:
/// ```dart
/// class _MyState extends State<MyWidget> with DisposableMixin {
///   late final emailCtrl = createController();
///   late final emailFocus = createFocusNode();
/// }
/// ```
///
/// Note: [AnimationController] is **not** handled here because it requires a
/// [TickerProvider]. Use [DisposableTickerMixin] when you need that, or call
/// `super.dispose()` after disposing your animation controllers manually.
mixin DisposableMixin<T extends StatefulWidget> on State<T> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];

  /// Creates a [TextEditingController] tracked for auto-dispose.
  TextEditingController createController({String? text}) {
    final c = TextEditingController(text: text);
    _controllers.add(c);
    return c;
  }

  /// Creates a [FocusNode] tracked for auto-dispose.
  FocusNode createFocusNode() {
    final f = FocusNode();
    _focusNodes.add(f);
    return f;
  }

  /// Tracks an externally created [Timer] so it gets cancelled on dispose.
  Timer trackTimer(Timer timer) {
    _timers.add(timer);
    return timer;
  }

  /// Tracks a [StreamSubscription] so it gets cancelled on dispose.
  StreamSubscription<S> trackSubscription<S>(StreamSubscription<S> sub) {
    _subscriptions.add(sub);
    return sub;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final t in _timers) {
      t.cancel();
    }
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}

/// Variant of [DisposableMixin] that also handles [AnimationController].
///
/// Includes [TickerProviderStateMixin] so consumer doesn't need to mix it in
/// separately. Use when the State needs a single ticker.
///
/// Usage:
/// ```dart
/// class _MyState extends State<MyWidget> with DisposableTickerMixin {
///   late final fade = createAnimationController(duration: const Duration(milliseconds: 200));
/// }
/// ```
mixin DisposableTickerMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<Timer> _timers = [];
  final List<AnimationController> _animationControllers = [];
  final List<StreamSubscription> _subscriptions = [];

  /// Creates a [TextEditingController] tracked for auto-dispose.
  TextEditingController createController({String? text}) {
    final c = TextEditingController(text: text);
    _controllers.add(c);
    return c;
  }

  /// Creates a [FocusNode] tracked for auto-dispose.
  FocusNode createFocusNode() {
    final f = FocusNode();
    _focusNodes.add(f);
    return f;
  }

  /// Tracks an externally created [Timer] so it gets cancelled on dispose.
  Timer trackTimer(Timer timer) {
    _timers.add(timer);
    return timer;
  }

  /// Creates an [AnimationController] using this State as the [TickerProvider].
  AnimationController createAnimationController({
    required Duration duration,
    Duration? reverseDuration,
    double? value,
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    final c = AnimationController(
      vsync: this,
      duration: duration,
      reverseDuration: reverseDuration,
      value: value,
      lowerBound: lowerBound,
      upperBound: upperBound,
    );
    _animationControllers.add(c);
    return c;
  }

  /// Tracks a [StreamSubscription] so it gets cancelled on dispose.
  StreamSubscription<S> trackSubscription<S>(StreamSubscription<S> sub) {
    _subscriptions.add(sub);
    return sub;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final t in _timers) {
      t.cancel();
    }
    for (final c in _animationControllers) {
      c.dispose();
    }
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}
