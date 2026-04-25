import 'package:flutter/foundation.dart';

/// Raw 4-px spacing scale — v3 design system (§2.4).
///
/// The Forma LMS HTML uses 8 / 12 / 14 / 18 / 20 / 24 / 28 as explicit
/// one-offs. The raw scale keeps the v2 4-step cadence but adds `s14` /
/// `s18` / `s28` stops so components can mirror the HTML exactly without
/// falling back to a nearby value.
class GenaiSpacing {
  GenaiSpacing._();

  static const double s0 = 0.0;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s26 = 26.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s60 = 60.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;
}

/// Semantic spacing tokens — v3 design system (§2.4).
///
/// Raw steps (`s0`..`s96`) plus v3-specific semantic aliases: `railPadding`
/// (sidebar padding 20/14), `topbarPaddingV` / `topbarPaddingH` (12/28),
/// `pageContentPaddingH` (32 / up to 60 wide), `sectionGap` (26 matches
/// `.section` margin-top in the HTML).
@immutable
class GenaiSpacingTokens {
  // Raw scale
  final double s0;
  final double s2;
  final double s4;
  final double s6;
  final double s8;
  final double s10;
  final double s12;
  final double s14;
  final double s16;
  final double s18;
  final double s20;
  final double s24;
  final double s26;
  final double s28;
  final double s32;
  final double s40;
  final double s48;
  final double s60;
  final double s64;
  final double s80;
  final double s96;

  // Semantic aliases
  /// Gap between an icon and its label — 8.
  final double iconLabelGap;

  /// Vertical gap between form fields — 12.
  final double fieldGap;

  /// Interior padding of a card — 18 (v3 cards are tighter than v2's 20).
  final double cardPadding;

  /// Gap between sections on a page — 26 (`.section` margin-top).
  final double sectionGap;

  /// Horizontal page padding on compact windows — 24.
  final double pageMarginMobile;

  /// Horizontal page padding on desktop — 32 (spec says up to 60 on widest).
  final double pageMarginDesktop;

  /// Vertical topbar padding — 12.
  final double topbarPaddingV;

  /// Horizontal topbar padding — 28.
  final double topbarPaddingH;

  /// Sidebar rail padding (vertical / horizontal) — 20 / 14.
  final double railPaddingV;
  final double railPaddingH;

  /// Content max width — 1400 per §3 layout patterns.
  final double contentMaxWidth;

  // ── v1 backward-compat aliases (deprecated; use canonical v3 names) ────
  /// Deprecated. v1 `s1` ≈ 4 — use [s4]. Removed in v6.
  double get s1 => s4;

  /// Deprecated. v1 `s3` ≈ 6 — use [s6]. Removed in v6.
  double get s3 => s6;

  /// Deprecated. v1 `s5` ≈ 10 — use [s10]. Removed in v6.
  double get s5 => s10;

  /// Deprecated. Use [fieldGap]. Removed in v6.
  double get formFieldGap => fieldGap;

  /// Deprecated. Use [sectionGap]. Removed in v6.
  double get pageSectionGap => sectionGap;

  /// Deprecated. Use [s12]. Removed in v6.
  double get componentPaddingH => s12;

  /// Deprecated. Use [cardPadding]. Removed in v6.
  double get cardGridGap => cardPadding;

  /// Deprecated. Use [pageMarginDesktop]. Removed in v6.
  double get pagePaddingH => pageMarginDesktop;

  /// Deprecated. Use [s16]. Removed in v6.
  double get sectionGapInCard => s16;

  const GenaiSpacingTokens({
    this.s0 = GenaiSpacing.s0,
    this.s2 = GenaiSpacing.s2,
    this.s4 = GenaiSpacing.s4,
    this.s6 = GenaiSpacing.s6,
    this.s8 = GenaiSpacing.s8,
    this.s10 = GenaiSpacing.s10,
    this.s12 = GenaiSpacing.s12,
    this.s14 = GenaiSpacing.s14,
    this.s16 = GenaiSpacing.s16,
    this.s18 = GenaiSpacing.s18,
    this.s20 = GenaiSpacing.s20,
    this.s24 = GenaiSpacing.s24,
    this.s26 = GenaiSpacing.s26,
    this.s28 = GenaiSpacing.s28,
    this.s32 = GenaiSpacing.s32,
    this.s40 = GenaiSpacing.s40,
    this.s48 = GenaiSpacing.s48,
    this.s60 = GenaiSpacing.s60,
    this.s64 = GenaiSpacing.s64,
    this.s80 = GenaiSpacing.s80,
    this.s96 = GenaiSpacing.s96,
    this.iconLabelGap = GenaiSpacing.s8,
    this.fieldGap = GenaiSpacing.s12,
    this.cardPadding = GenaiSpacing.s18,
    this.sectionGap = GenaiSpacing.s26,
    this.pageMarginMobile = GenaiSpacing.s24,
    this.pageMarginDesktop = GenaiSpacing.s32,
    this.topbarPaddingV = GenaiSpacing.s12,
    this.topbarPaddingH = GenaiSpacing.s28,
    this.railPaddingV = GenaiSpacing.s20,
    this.railPaddingH = GenaiSpacing.s14,
    this.contentMaxWidth = 1400.0,
  });

  factory GenaiSpacingTokens.defaultTokens() => const GenaiSpacingTokens();

  GenaiSpacingTokens copyWith({
    double? s0,
    double? s2,
    double? s4,
    double? s6,
    double? s8,
    double? s10,
    double? s12,
    double? s14,
    double? s16,
    double? s18,
    double? s20,
    double? s24,
    double? s26,
    double? s28,
    double? s32,
    double? s40,
    double? s48,
    double? s60,
    double? s64,
    double? s80,
    double? s96,
    double? iconLabelGap,
    double? fieldGap,
    double? cardPadding,
    double? sectionGap,
    double? pageMarginMobile,
    double? pageMarginDesktop,
    double? topbarPaddingV,
    double? topbarPaddingH,
    double? railPaddingV,
    double? railPaddingH,
    double? contentMaxWidth,
  }) {
    return GenaiSpacingTokens(
      s0: s0 ?? this.s0,
      s2: s2 ?? this.s2,
      s4: s4 ?? this.s4,
      s6: s6 ?? this.s6,
      s8: s8 ?? this.s8,
      s10: s10 ?? this.s10,
      s12: s12 ?? this.s12,
      s14: s14 ?? this.s14,
      s16: s16 ?? this.s16,
      s18: s18 ?? this.s18,
      s20: s20 ?? this.s20,
      s24: s24 ?? this.s24,
      s26: s26 ?? this.s26,
      s28: s28 ?? this.s28,
      s32: s32 ?? this.s32,
      s40: s40 ?? this.s40,
      s48: s48 ?? this.s48,
      s60: s60 ?? this.s60,
      s64: s64 ?? this.s64,
      s80: s80 ?? this.s80,
      s96: s96 ?? this.s96,
      iconLabelGap: iconLabelGap ?? this.iconLabelGap,
      fieldGap: fieldGap ?? this.fieldGap,
      cardPadding: cardPadding ?? this.cardPadding,
      sectionGap: sectionGap ?? this.sectionGap,
      pageMarginMobile: pageMarginMobile ?? this.pageMarginMobile,
      pageMarginDesktop: pageMarginDesktop ?? this.pageMarginDesktop,
      topbarPaddingV: topbarPaddingV ?? this.topbarPaddingV,
      topbarPaddingH: topbarPaddingH ?? this.topbarPaddingH,
      railPaddingV: railPaddingV ?? this.railPaddingV,
      railPaddingH: railPaddingH ?? this.railPaddingH,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    );
  }

  static GenaiSpacingTokens lerp(
      GenaiSpacingTokens a, GenaiSpacingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSpacingTokens(
      s0: l(a.s0, b.s0),
      s2: l(a.s2, b.s2),
      s4: l(a.s4, b.s4),
      s6: l(a.s6, b.s6),
      s8: l(a.s8, b.s8),
      s10: l(a.s10, b.s10),
      s12: l(a.s12, b.s12),
      s14: l(a.s14, b.s14),
      s16: l(a.s16, b.s16),
      s18: l(a.s18, b.s18),
      s20: l(a.s20, b.s20),
      s24: l(a.s24, b.s24),
      s26: l(a.s26, b.s26),
      s28: l(a.s28, b.s28),
      s32: l(a.s32, b.s32),
      s40: l(a.s40, b.s40),
      s48: l(a.s48, b.s48),
      s60: l(a.s60, b.s60),
      s64: l(a.s64, b.s64),
      s80: l(a.s80, b.s80),
      s96: l(a.s96, b.s96),
      iconLabelGap: l(a.iconLabelGap, b.iconLabelGap),
      fieldGap: l(a.fieldGap, b.fieldGap),
      cardPadding: l(a.cardPadding, b.cardPadding),
      sectionGap: l(a.sectionGap, b.sectionGap),
      pageMarginMobile: l(a.pageMarginMobile, b.pageMarginMobile),
      pageMarginDesktop: l(a.pageMarginDesktop, b.pageMarginDesktop),
      topbarPaddingV: l(a.topbarPaddingV, b.topbarPaddingV),
      topbarPaddingH: l(a.topbarPaddingH, b.topbarPaddingH),
      railPaddingV: l(a.railPaddingV, b.railPaddingV),
      railPaddingH: l(a.railPaddingH, b.railPaddingH),
      contentMaxWidth: l(a.contentMaxWidth, b.contentMaxWidth),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiSpacingTokens &&
          runtimeType == other.runtimeType &&
          s0 == other.s0 &&
          s2 == other.s2 &&
          s4 == other.s4 &&
          s6 == other.s6 &&
          s8 == other.s8 &&
          s10 == other.s10 &&
          s12 == other.s12 &&
          s14 == other.s14 &&
          s16 == other.s16 &&
          s18 == other.s18 &&
          s20 == other.s20 &&
          s24 == other.s24 &&
          s26 == other.s26 &&
          s28 == other.s28 &&
          s32 == other.s32 &&
          s40 == other.s40 &&
          s48 == other.s48 &&
          s60 == other.s60 &&
          s64 == other.s64 &&
          s80 == other.s80 &&
          s96 == other.s96 &&
          iconLabelGap == other.iconLabelGap &&
          fieldGap == other.fieldGap &&
          cardPadding == other.cardPadding &&
          sectionGap == other.sectionGap &&
          pageMarginMobile == other.pageMarginMobile &&
          pageMarginDesktop == other.pageMarginDesktop &&
          topbarPaddingV == other.topbarPaddingV &&
          topbarPaddingH == other.topbarPaddingH &&
          railPaddingV == other.railPaddingV &&
          railPaddingH == other.railPaddingH &&
          contentMaxWidth == other.contentMaxWidth;

  @override
  int get hashCode => Object.hashAll([
        s0,
        s2,
        s4,
        s6,
        s8,
        s10,
        s12,
        s14,
        s16,
        s18,
        s20,
        s24,
        s26,
        s28,
        s32,
        s40,
        s48,
        s60,
        s64,
        s80,
        s96,
        iconLabelGap,
        fieldGap,
        cardPadding,
        sectionGap,
        pageMarginMobile,
        pageMarginDesktop,
        topbarPaddingV,
        topbarPaddingH,
        railPaddingV,
        railPaddingH,
        contentMaxWidth,
      ]);
}
