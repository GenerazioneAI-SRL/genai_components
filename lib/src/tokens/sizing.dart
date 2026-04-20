import 'package:flutter/foundation.dart';

/// Component size scale §2.4.
enum GenaiSize {
  xs(
    height: 32,
    heightMobile: 36,
    iconSize: 16,
    paddingH: 8,
    paddingV: 6,
    gap: 4,
    borderRadius: 4,
    borderWidth: 1.0,
    fontSize: 12,
  ),
  sm(
    height: 40,
    heightMobile: 44,
    iconSize: 18,
    paddingH: 12,
    paddingV: 8,
    gap: 6,
    borderRadius: 6,
    borderWidth: 1.0,
    fontSize: 14,
  ),
  md(
    height: 48,
    heightMobile: 52,
    iconSize: 20,
    paddingH: 16,
    paddingV: 12,
    gap: 8,
    borderRadius: 8,
    borderWidth: 1.5,
    fontSize: 16,
  ),
  lg(
    height: 56,
    heightMobile: 56,
    iconSize: 24,
    paddingH: 20,
    paddingV: 14,
    gap: 8,
    borderRadius: 10,
    borderWidth: 1.5,
    fontSize: 18,
  ),
  xl(
    height: 64,
    heightMobile: 64,
    iconSize: 28,
    paddingH: 24,
    paddingV: 16,
    gap: 10,
    borderRadius: 12,
    borderWidth: 2.0,
    fontSize: 20,
  );

  final double height;
  final double heightMobile;
  final double iconSize;
  final double paddingH;
  final double paddingV;
  final double gap;
  final double borderRadius;
  final double borderWidth;
  final double fontSize;

  const GenaiSize({
    required this.height,
    required this.heightMobile,
    required this.iconSize,
    required this.paddingH,
    required this.paddingV,
    required this.gap,
    required this.borderRadius,
    required this.borderWidth,
    required this.fontSize,
  });

  /// Returns the mobile-adjusted height when [isCompact] is true.
  double resolveHeight({required bool isCompact}) => isCompact ? heightMobile : height;
}

/// User density preference §8.7.
enum GenaiDensity { compact, normal, comfortable }

@immutable
class GenaiSizingTokens {
  final GenaiDensity density;

  const GenaiSizingTokens({this.density = GenaiDensity.normal});

  factory GenaiSizingTokens.defaultTokens() => const GenaiSizingTokens();

  static GenaiSizingTokens lerp(GenaiSizingTokens a, GenaiSizingTokens b, double t) => t < 0.5 ? a : b;
}
