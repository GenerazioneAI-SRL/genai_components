import 'package:flutter/material.dart';

/// Typography scale §2.3.
@immutable
class GenaiTypographyTokens {
  final TextStyle displayLg;
  final TextStyle displaySm;
  final TextStyle headingLg;
  final TextStyle headingSm;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodySm;
  final TextStyle label;
  final TextStyle labelSm;
  final TextStyle caption;
  final TextStyle code;

  const GenaiTypographyTokens({
    required this.displayLg,
    required this.displaySm,
    required this.headingLg,
    required this.headingSm,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodySm,
    required this.label,
    required this.labelSm,
    required this.caption,
    required this.code,
  });

  /// Desktop scale (default).
  factory GenaiTypographyTokens.defaultTokens({String? fontFamily}) {
    return GenaiTypographyTokens(
      displayLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      displaySm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
      ),
      headingLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headingSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      bodySm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
      ),
      label: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
      labelSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
      ),
      caption: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      code: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.54,
      ),
    );
  }

  /// Mobile-adapted scale (§2.3.2). Slightly larger for legibility.
  factory GenaiTypographyTokens.mobile({String? fontFamily}) {
    return GenaiTypographyTokens(
      displayLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      displaySm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.33,
      ),
      headingLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headingSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      bodySm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.33,
      ),
      label: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
      labelSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.33,
      ),
      caption: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      code: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.54,
      ),
    );
  }

  static GenaiTypographyTokens lerp(GenaiTypographyTokens a, GenaiTypographyTokens b, double t) {
    return GenaiTypographyTokens(
      displayLg: TextStyle.lerp(a.displayLg, b.displayLg, t)!,
      displaySm: TextStyle.lerp(a.displaySm, b.displaySm, t)!,
      headingLg: TextStyle.lerp(a.headingLg, b.headingLg, t)!,
      headingSm: TextStyle.lerp(a.headingSm, b.headingSm, t)!,
      bodyLg: TextStyle.lerp(a.bodyLg, b.bodyLg, t)!,
      bodyMd: TextStyle.lerp(a.bodyMd, b.bodyMd, t)!,
      bodySm: TextStyle.lerp(a.bodySm, b.bodySm, t)!,
      label: TextStyle.lerp(a.label, b.label, t)!,
      labelSm: TextStyle.lerp(a.labelSm, b.labelSm, t)!,
      caption: TextStyle.lerp(a.caption, b.caption, t)!,
      code: TextStyle.lerp(a.code, b.code, t)!,
    );
  }
}
