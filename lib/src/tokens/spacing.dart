import 'package:flutter/foundation.dart';

/// Spacing scale based on 4px multiples. §2.2.
class GenaiSpacing {
  GenaiSpacing._();

  static const double s0 = 0.0;
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s8 = 32.0;
  static const double s10 = 40.0;
  static const double s12 = 48.0;
  static const double s16 = 64.0;
  static const double s20 = 80.0;
  static const double s24 = 96.0;
}

@immutable
class GenaiSpacingTokens {
  final double s0;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s8;
  final double s10;
  final double s12;
  final double s16;
  final double s20;
  final double s24;

  const GenaiSpacingTokens({
    this.s0 = GenaiSpacing.s0,
    this.s1 = GenaiSpacing.s1,
    this.s2 = GenaiSpacing.s2,
    this.s3 = GenaiSpacing.s3,
    this.s4 = GenaiSpacing.s4,
    this.s5 = GenaiSpacing.s5,
    this.s6 = GenaiSpacing.s6,
    this.s8 = GenaiSpacing.s8,
    this.s10 = GenaiSpacing.s10,
    this.s12 = GenaiSpacing.s12,
    this.s16 = GenaiSpacing.s16,
    this.s20 = GenaiSpacing.s20,
    this.s24 = GenaiSpacing.s24,
  });

  factory GenaiSpacingTokens.defaultTokens() => const GenaiSpacingTokens();

  static GenaiSpacingTokens lerp(GenaiSpacingTokens a, GenaiSpacingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSpacingTokens(
      s0: l(a.s0, b.s0),
      s1: l(a.s1, b.s1),
      s2: l(a.s2, b.s2),
      s3: l(a.s3, b.s3),
      s4: l(a.s4, b.s4),
      s5: l(a.s5, b.s5),
      s6: l(a.s6, b.s6),
      s8: l(a.s8, b.s8),
      s10: l(a.s10, b.s10),
      s12: l(a.s12, b.s12),
      s16: l(a.s16, b.s16),
      s20: l(a.s20, b.s20),
      s24: l(a.s24, b.s24),
    );
  }
}
