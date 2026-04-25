import 'package:flutter/foundation.dart';

/// Border-radius tokens — v3 design system (§2.4).
///
/// Eight-step scale pulled from the Forma LMS HTML:
/// `none` (0), `xs` (4), `sm` (6), `md` (8), `lg` (10), `xl` (12),
/// `hero` (14), `pill` (999). Cards use `xl` (12), focus hero uses `hero`
/// (14), buttons/rail-items use `md` (8), form icons use `lg` (10), kbd uses
/// `sm` (6), avatars / sparkline thumbs use `pill`.
@immutable
class GenaiRadiusTokens {
  /// 0 — sharp corners.
  final double none;

  /// 4 — focus-ring corners (per §5 `:focus-visible` outline).
  final double xs;

  /// 6 — kbd pills.
  final double sm;

  /// 8 — buttons, rail items.
  final double md;

  /// 10 — form input icons, small badges.
  final double lg;

  /// 12 — default card radius.
  final double xl;

  /// 14 — focus hero card (decision card).
  final double hero;

  /// 999 — pills, circular avatars, sparkline thumb.
  final double pill;

  const GenaiRadiusTokens({
    this.none = 0,
    this.xs = 4,
    this.sm = 6,
    this.md = 8,
    this.lg = 10,
    this.xl = 12,
    this.hero = 14,
    this.pill = 999,
  });

  /// Default tokens per §2.4.
  factory GenaiRadiusTokens.defaultTokens() => const GenaiRadiusTokens();

  GenaiRadiusTokens copyWith({
    double? none,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? hero,
    double? pill,
  }) {
    return GenaiRadiusTokens(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      hero: hero ?? this.hero,
      pill: pill ?? this.pill,
    );
  }

  static GenaiRadiusTokens lerp(
      GenaiRadiusTokens a, GenaiRadiusTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiRadiusTokens(
      none: l(a.none, b.none),
      xs: l(a.xs, b.xs),
      sm: l(a.sm, b.sm),
      md: l(a.md, b.md),
      lg: l(a.lg, b.lg),
      xl: l(a.xl, b.xl),
      hero: l(a.hero, b.hero),
      pill: l(a.pill, b.pill),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiRadiusTokens &&
          runtimeType == other.runtimeType &&
          none == other.none &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl &&
          hero == other.hero &&
          pill == other.pill;

  @override
  int get hashCode => Object.hash(none, xs, sm, md, lg, xl, hero, pill);
}
