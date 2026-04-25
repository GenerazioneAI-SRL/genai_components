import 'package:flutter/animation.dart';

/// Animation durations — v3 design system (§2.6).
///
/// Verbatim reuse of the v2 table. Spec §2.6 states: "No explicit keyframes
/// in v3 HTML. Use v2 motion tokens (hover 120, press 80, modal 240, etc.)."
class GenaiDurations {
  GenaiDurations._();

  /// Color/background hover transitions.
  static const Duration hover = Duration(milliseconds: 120);

  /// Press scale-down.
  static const Duration press = Duration(milliseconds: 80);

  /// Accordion/collapsible expand/collapse.
  static const Duration expand = Duration(milliseconds: 220);

  /// Modal / drawer open/close.
  static const Duration modal = Duration(milliseconds: 240);

  /// Toast enter/exit.
  static const Duration toast = Duration(milliseconds: 200);

  /// Route transition.
  static const Duration page = Duration(milliseconds: 180);

  /// Personality motion (spring). Used sparingly.
  static const Duration spring = Duration(milliseconds: 400);
}

/// Animation curves — v3 design system (§2.6).
///
/// `emphasized` is the premium cubic-bezier(0.2, 0, 0, 1) from Material 3.
/// `spring` approximates a spring feel inside a [Curve] contract.
class GenaiCurves {
  GenaiCurves._();

  /// Premium emphasized easing — `cubic-bezier(0.2, 0, 0, 1)`.
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);

  /// Ease-out — hover, press, toast.
  static const Curve easeOut = Curves.easeOut;

  /// Ease-in-out — page transitions.
  static const Curve easeInOut = Curves.easeInOut;

  /// Spring-ish curve used with [GenaiDurations.spring] for personality
  /// micro-motion (AI responses, delight moments).
  static const Curve spring = Curves.elasticOut;
}
