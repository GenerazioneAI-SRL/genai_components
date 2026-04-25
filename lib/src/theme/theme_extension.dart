import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// ThemeExtension carrying all v3 design tokens.
///
/// Installed on [ThemeData] by [GenaiTheme.light]. Read via the `context.*`
/// extensions (see `context_extensions.dart`).
///
/// Class name matches v1 / v2 so consumers can swap libraries by changing
/// the import alias.
@immutable
class GenaiThemeExtension extends ThemeExtension<GenaiThemeExtension> {
  final GenaiColorTokens colors;
  final GenaiTypographyTokens typography;
  final GenaiSpacingTokens spacing;
  final GenaiSizingTokens sizing;
  final GenaiRadiusTokens radius;
  final GenaiElevationTokens elevation;
  final GenaiMotionTokens motion;

  const GenaiThemeExtension({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.sizing,
    required this.radius,
    required this.elevation,
    required this.motion,
  });

  @override
  GenaiThemeExtension copyWith({
    GenaiColorTokens? colors,
    GenaiTypographyTokens? typography,
    GenaiSpacingTokens? spacing,
    GenaiSizingTokens? sizing,
    GenaiRadiusTokens? radius,
    GenaiElevationTokens? elevation,
    GenaiMotionTokens? motion,
  }) {
    return GenaiThemeExtension(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      sizing: sizing ?? this.sizing,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      motion: motion ?? this.motion,
    );
  }

  @override
  GenaiThemeExtension lerp(
      covariant ThemeExtension<GenaiThemeExtension>? other, double t) {
    if (other is! GenaiThemeExtension) return this;
    return GenaiThemeExtension(
      colors: GenaiColorTokens.lerp(colors, other.colors, t),
      typography: GenaiTypographyTokens.lerp(typography, other.typography, t),
      spacing: GenaiSpacingTokens.lerp(spacing, other.spacing, t),
      sizing: GenaiSizingTokens.lerp(sizing, other.sizing, t),
      radius: GenaiRadiusTokens.lerp(radius, other.radius, t),
      elevation: GenaiElevationTokens.lerp(elevation, other.elevation, t),
      motion: GenaiMotionTokens.lerp(motion, other.motion, t),
    );
  }
}
