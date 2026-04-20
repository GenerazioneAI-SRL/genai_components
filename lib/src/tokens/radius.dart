import 'package:flutter/foundation.dart';

/// Border radius tokens.
@immutable
class GenaiRadiusTokens {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  const GenaiRadiusTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    this.pill = 9999,
  });

  factory GenaiRadiusTokens.defaultTokens({double baseRadius = 8}) {
    final base = baseRadius;
    return GenaiRadiusTokens(
      xs: base * 0.5,
      sm: base * 0.75,
      md: base,
      lg: base * 1.25,
      xl: base * 1.5,
    );
  }

  static GenaiRadiusTokens lerp(GenaiRadiusTokens a, GenaiRadiusTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiRadiusTokens(
      xs: l(a.xs, b.xs),
      sm: l(a.sm, b.sm),
      md: l(a.md, b.md),
      lg: l(a.lg, b.lg),
      xl: l(a.xl, b.xl),
      pill: l(a.pill, b.pill),
    );
  }
}
