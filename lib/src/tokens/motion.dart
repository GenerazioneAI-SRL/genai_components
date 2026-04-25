import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../foundations/animations.dart';

/// A (Duration, Curve) pair — the unit of motion in v3 (§2.6).
///
/// v3 reuses the v2 motion table verbatim — spec §2.6 says "Use v2 motion
/// tokens (hover 120, press 80, modal 240, etc.)". `reduced()` returns a
/// zero-duration variant for users who enable the OS "reduce motion" setting.
@immutable
class GenaiMotion {
  final Duration duration;
  final Curve curve;

  const GenaiMotion(this.duration, this.curve);

  /// Returns a motion pair with [Duration.zero]. Use when
  /// `GenaiResponsive.reducedMotion(context)` is true.
  GenaiMotion reduced() => GenaiMotion(Duration.zero, curve);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiMotion &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          curve == other.curve;

  @override
  int get hashCode => Object.hash(duration, curve);
}

/// Semantic motion tokens — v3 design system (§2.6).
///
/// Mirror of v2's seven motions. v3 HTML contains no explicit keyframes;
/// this table exists so components that do animate (drawer, toast, modal)
/// read from consistent timings.
@immutable
class GenaiMotionTokens {
  final GenaiMotion hover;
  final GenaiMotion press;
  final GenaiMotion expand;
  final GenaiMotion modal;
  final GenaiMotion toast;
  final GenaiMotion page;
  final GenaiMotion spring;

  const GenaiMotionTokens({
    required this.hover,
    required this.press,
    required this.expand,
    required this.modal,
    required this.toast,
    required this.page,
    required this.spring,
  });

  /// Default motion tokens per §2.6 (v2 table reused).
  factory GenaiMotionTokens.defaultTokens() => const GenaiMotionTokens(
        hover: GenaiMotion(GenaiDurations.hover, GenaiCurves.easeOut),
        press: GenaiMotion(GenaiDurations.press, GenaiCurves.easeOut),
        expand: GenaiMotion(GenaiDurations.expand, GenaiCurves.emphasized),
        modal: GenaiMotion(GenaiDurations.modal, GenaiCurves.emphasized),
        toast: GenaiMotion(GenaiDurations.toast, GenaiCurves.easeOut),
        page: GenaiMotion(GenaiDurations.page, GenaiCurves.easeInOut),
        spring: GenaiMotion(GenaiDurations.spring, GenaiCurves.spring),
      );

  /// All-zero-duration variant for `prefers-reduced-motion` users (§5).
  factory GenaiMotionTokens.reduced() => GenaiMotionTokens(
        hover: GenaiMotionTokens.defaultTokens().hover.reduced(),
        press: GenaiMotionTokens.defaultTokens().press.reduced(),
        expand: GenaiMotionTokens.defaultTokens().expand.reduced(),
        modal: GenaiMotionTokens.defaultTokens().modal.reduced(),
        toast: GenaiMotionTokens.defaultTokens().toast.reduced(),
        page: GenaiMotionTokens.defaultTokens().page.reduced(),
        spring: GenaiMotionTokens.defaultTokens().spring.reduced(),
      );

  GenaiMotionTokens copyWith({
    GenaiMotion? hover,
    GenaiMotion? press,
    GenaiMotion? expand,
    GenaiMotion? modal,
    GenaiMotion? toast,
    GenaiMotion? page,
    GenaiMotion? spring,
  }) {
    return GenaiMotionTokens(
      hover: hover ?? this.hover,
      press: press ?? this.press,
      expand: expand ?? this.expand,
      modal: modal ?? this.modal,
      toast: toast ?? this.toast,
      page: page ?? this.page,
      spring: spring ?? this.spring,
    );
  }

  // ── v1 backward-compat aliases ─────────────────────────────────────────
  /// Deprecated. v1 had a 1500 ms autosave debounce. Removed in v6.
  Duration get autosaveDebounce => const Duration(milliseconds: 1500);

  /// Deprecated. v1 `tooltipDelay` ≈ 400 ms. Removed in v6.
  Duration get tooltipDelay => const Duration(milliseconds: 400);

  /// Deprecated. v1 `dropdownOpen` motion. Use [expand] instead. Removed in v6.
  GenaiMotion get dropdownOpen => expand;

  /// Deprecated. v1 `accordionOpen` motion. Use [expand] instead. Removed in v6.
  GenaiMotion get accordionOpen => expand;

  /// Deprecated. v1 `searchDebounce`. Removed in v6.
  Duration get searchDebounce => const Duration(milliseconds: 200);

  /// Motion is categorical — `lerp` snaps at midpoint.
  static GenaiMotionTokens lerp(
          GenaiMotionTokens a, GenaiMotionTokens b, double t) =>
      t < 0.5 ? a : b;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiMotionTokens &&
          runtimeType == other.runtimeType &&
          hover == other.hover &&
          press == other.press &&
          expand == other.expand &&
          modal == other.modal &&
          toast == other.toast &&
          page == other.page &&
          spring == other.spring;

  @override
  int get hashCode =>
      Object.hash(hover, press, expand, modal, toast, page, spring);
}
