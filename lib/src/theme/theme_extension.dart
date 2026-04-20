import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// ThemeExtension carrying all Genai design tokens.
@immutable
class GenaiThemeExtension extends ThemeExtension<GenaiThemeExtension> {
  final GenaiColorTokens colors;
  final GenaiSpacingTokens spacing;
  final GenaiTypographyTokens typography;
  final GenaiSizingTokens sizing;
  final GenaiElevationTokens elevation;
  final GenaiRadiusTokens radius;

  const GenaiThemeExtension({
    required this.colors,
    required this.spacing,
    required this.typography,
    required this.sizing,
    required this.elevation,
    required this.radius,
  });

  @override
  GenaiThemeExtension copyWith({
    GenaiColorTokens? colors,
    GenaiSpacingTokens? spacing,
    GenaiTypographyTokens? typography,
    GenaiSizingTokens? sizing,
    GenaiElevationTokens? elevation,
    GenaiRadiusTokens? radius,
  }) {
    return GenaiThemeExtension(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
      sizing: sizing ?? this.sizing,
      elevation: elevation ?? this.elevation,
      radius: radius ?? this.radius,
    );
  }

  @override
  GenaiThemeExtension lerp(ThemeExtension<GenaiThemeExtension>? other, double t) {
    if (other is! GenaiThemeExtension) return this;
    return GenaiThemeExtension(
      colors: GenaiColorTokens.lerp(colors, other.colors, t),
      spacing: GenaiSpacingTokens.lerp(spacing, other.spacing, t),
      typography: GenaiTypographyTokens.lerp(typography, other.typography, t),
      sizing: GenaiSizingTokens.lerp(sizing, other.sizing, t),
      elevation: GenaiElevationTokens.lerp(elevation, other.elevation, t),
      radius: GenaiRadiusTokens.lerp(radius, other.radius, t),
    );
  }
}
