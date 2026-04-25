import 'package:flutter/material.dart';

/// Logical window-size buckets — v3 design system.
///
/// Identical breakpoints to v1 / v2 so responsive helpers behave the same
/// way across libraries. The Forma LMS reference HTML uses a single desktop
/// layout (`240px 1fr`) with content max-width 1400 px.
enum GenaiWindowSize {
  compact, // < 600
  medium, // 600 - 900
  expanded, // 900 - 1280
  large, // 1280 - 1536
  extraLarge; // > 1536

  static GenaiWindowSize fromWidth(double width) {
    if (width < 600) return GenaiWindowSize.compact;
    if (width < 900) return GenaiWindowSize.medium;
    if (width < 1280) return GenaiWindowSize.expanded;
    if (width < 1536) return GenaiWindowSize.large;
    return GenaiWindowSize.extraLarge;
  }
}

/// Static helpers around window-size and motion-accessibility resolution.
class GenaiResponsive {
  GenaiResponsive._();

  /// The current [GenaiWindowSize] derived from [MediaQuery].
  static GenaiWindowSize sizeOf(BuildContext context) =>
      GenaiWindowSize.fromWidth(MediaQuery.sizeOf(context).width);

  /// True when the user prefers reduced motion (OS accessibility setting).
  ///
  /// v3 components should collapse all [GenaiMotion] durations to
  /// [Duration.zero] when this is true (§5).
  static bool reducedMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
