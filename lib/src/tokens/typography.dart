import 'package:flutter/material.dart';

/// Typography tokens — v3 design system (§2.3).
///
/// Translated from the Forma LMS reference HTML. Sans is **Geist**
/// (400/500/600/700), mono is **Geist Mono** (400/500). Base is 14 px with
/// line-height 1.45, antialiased.
///
/// Shape differs from v2: v3 adds `pageTitle` / `sectionTitle` / `cardTitle` /
/// `kpiNumber` / `focusTitle` / `tiny` slots pulled directly from the HTML,
/// plus `bodySm` / `labelSm` that match the 13 / 11.5 sizes used for rows and
/// chips. All numeric styles carry tabular figures for dashboard alignment.
@immutable
class GenaiTypographyTokens {
  // Page / section / card titles
  /// `h1.page` — 22 / 600.
  final TextStyle pageTitle;

  /// `.section-h h2` — 15 / 600.
  final TextStyle sectionTitle;

  /// `.card-h h2` — 14 / 600.
  final TextStyle cardTitle;

  /// `.focus-title` — 20 / 600 (decision hero).
  final TextStyle focusTitle;

  /// `.kpi-n` — 28 / 600.
  final TextStyle kpiNumber;

  // Body
  /// Default — 14 / 400.
  final TextStyle body;

  /// Row / list body — 13 / 400.
  final TextStyle bodySm;

  // Labels / UI copy
  /// Captions, chips, form labels — 12 / 500.
  final TextStyle label;

  /// Small chips, kbd — 11.5 / 500.
  final TextStyle labelSm;

  /// Uppercase section labels — 11 / 500 with wide letter-spacing.
  final TextStyle tiny;

  // Mono
  /// IDs, tabular counters — 13 / 500.
  final TextStyle monoMd;

  /// Mono small (kbd pill, deltas) — 11 / 500.
  final TextStyle monoSm;

  // ── v1 backward-compat aliases (deprecated; use canonical v3 names) ────
  /// Deprecated alias for [body]. Removed in v6.
  TextStyle get bodyMd => body;

  /// Deprecated alias for [body]. Removed in v6.
  TextStyle get bodyLg => body;

  /// Deprecated alias for [labelSm]. Removed in v6.
  TextStyle get caption => labelSm;

  /// Deprecated alias for [pageTitle]. Removed in v6.
  TextStyle get headingLg => pageTitle;

  /// Deprecated alias for [sectionTitle]. Removed in v6.
  TextStyle get headingMd => sectionTitle;

  /// Deprecated alias for [cardTitle]. Removed in v6.
  TextStyle get headingSm => cardTitle;

  /// Deprecated alias for [pageTitle]. Removed in v6.
  TextStyle get displayLg => pageTitle;

  /// Deprecated alias for [kpiNumber]. Removed in v6.
  TextStyle get displaySm => kpiNumber;

  /// Deprecated alias for [monoSm]. Removed in v6.
  TextStyle get code => monoSm;

  /// Deprecated alias for [label]. Removed in v6.
  TextStyle get labelMd => label;

  /// Deprecated alias for [label]. Removed in v6.
  TextStyle get labelLg => label;

  const GenaiTypographyTokens({
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.focusTitle,
    required this.kpiNumber,
    required this.body,
    required this.bodySm,
    required this.label,
    required this.labelSm,
    required this.tiny,
    required this.monoMd,
    required this.monoSm,
  });

  /// Default v3 type scale.
  ///
  /// - [fontFamily] overrides the `Geist` sans default.
  /// - [monoFontFamily] overrides the `Geist Mono` default.
  factory GenaiTypographyTokens.defaultTokens({
    String? fontFamily,
    String monoFontFamily = 'Geist Mono',
  }) {
    final sans = fontFamily ?? 'Geist';
    const tabularNums = <FontFeature>[FontFeature.tabularFigures()];
    return GenaiTypographyTokens(
      pageTitle: TextStyle(
        fontFamily: sans,
        fontSize: 22,
        height: 30 / 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      sectionTitle: TextStyle(
        fontFamily: sans,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      cardTitle: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
      ),
      focusTitle: TextStyle(
        fontFamily: sans,
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      kpiNumber: TextStyle(
        fontFamily: sans,
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        fontFeatures: tabularNums,
      ),
      body: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodySm: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        height: 19 / 13,
        fontWeight: FontWeight.w400,
      ),
      label: TextStyle(
        fontFamily: sans,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
      ),
      labelSm: TextStyle(
        fontFamily: sans,
        fontSize: 11.5,
        height: 16 / 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      tiny: TextStyle(
        fontFamily: sans,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.88, // 0.08em @ 11 ≈ 0.88
      ),
      monoMd: TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 13,
        height: 19 / 13,
        fontWeight: FontWeight.w500,
        fontFeatures: tabularNums,
      ),
      monoSm: TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w400,
        fontFeatures: tabularNums,
      ),
    );
  }

  GenaiTypographyTokens copyWith({
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? focusTitle,
    TextStyle? kpiNumber,
    TextStyle? body,
    TextStyle? bodySm,
    TextStyle? label,
    TextStyle? labelSm,
    TextStyle? tiny,
    TextStyle? monoMd,
    TextStyle? monoSm,
  }) {
    return GenaiTypographyTokens(
      pageTitle: pageTitle ?? this.pageTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      cardTitle: cardTitle ?? this.cardTitle,
      focusTitle: focusTitle ?? this.focusTitle,
      kpiNumber: kpiNumber ?? this.kpiNumber,
      body: body ?? this.body,
      bodySm: bodySm ?? this.bodySm,
      label: label ?? this.label,
      labelSm: labelSm ?? this.labelSm,
      tiny: tiny ?? this.tiny,
      monoMd: monoMd ?? this.monoMd,
      monoSm: monoSm ?? this.monoSm,
    );
  }

  static GenaiTypographyTokens lerp(
      GenaiTypographyTokens a, GenaiTypographyTokens b, double t) {
    TextStyle l(TextStyle x, TextStyle y) => TextStyle.lerp(x, y, t)!;
    return GenaiTypographyTokens(
      pageTitle: l(a.pageTitle, b.pageTitle),
      sectionTitle: l(a.sectionTitle, b.sectionTitle),
      cardTitle: l(a.cardTitle, b.cardTitle),
      focusTitle: l(a.focusTitle, b.focusTitle),
      kpiNumber: l(a.kpiNumber, b.kpiNumber),
      body: l(a.body, b.body),
      bodySm: l(a.bodySm, b.bodySm),
      label: l(a.label, b.label),
      labelSm: l(a.labelSm, b.labelSm),
      tiny: l(a.tiny, b.tiny),
      monoMd: l(a.monoMd, b.monoMd),
      monoSm: l(a.monoSm, b.monoSm),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiTypographyTokens &&
          runtimeType == other.runtimeType &&
          pageTitle == other.pageTitle &&
          sectionTitle == other.sectionTitle &&
          cardTitle == other.cardTitle &&
          focusTitle == other.focusTitle &&
          kpiNumber == other.kpiNumber &&
          body == other.body &&
          bodySm == other.bodySm &&
          label == other.label &&
          labelSm == other.labelSm &&
          tiny == other.tiny &&
          monoMd == other.monoMd &&
          monoSm == other.monoSm;

  @override
  int get hashCode => Object.hashAll([
        pageTitle,
        sectionTitle,
        cardTitle,
        focusTitle,
        kpiNumber,
        body,
        bodySm,
        label,
        labelSm,
        tiny,
        monoMd,
        monoSm,
      ]);
}
