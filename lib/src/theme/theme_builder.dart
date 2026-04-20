import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'theme_extension.dart';

/// Builds [ThemeData] for the Genai design system.
///
/// Resets Material defaults (splash, hover overlays) and installs
/// [GenaiThemeExtension] with all tokens.
class GenaiTheme {
  GenaiTheme._();

  static ThemeData light({
    GenaiColorTokens? colorsOverride,
    GenaiTypographyTokens? typographyOverride,
    String? fontFamily,
    double baseRadius = 8,
    GenaiDensity density = GenaiDensity.normal,
  }) {
    final colors = colorsOverride ?? GenaiColorTokens.defaultLight();
    final typography = typographyOverride ?? GenaiTypographyTokens.defaultTokens(fontFamily: fontFamily ?? 'Inter');

    return _build(
      brightness: Brightness.light,
      colors: colors,
      typography: typography,
      fontFamily: fontFamily ?? 'Inter',
      baseRadius: baseRadius,
      density: density,
      elevation: GenaiElevationTokens.defaultLight(),
    );
  }

  static ThemeData dark({
    GenaiColorTokens? colorsOverride,
    GenaiTypographyTokens? typographyOverride,
    String? fontFamily,
    double baseRadius = 8,
    GenaiDensity density = GenaiDensity.normal,
  }) {
    final colors = colorsOverride ?? GenaiColorTokens.defaultDark();
    final typography = typographyOverride ?? GenaiTypographyTokens.defaultTokens(fontFamily: fontFamily ?? 'Inter');

    return _build(
      brightness: Brightness.dark,
      colors: colors,
      typography: typography,
      fontFamily: fontFamily ?? 'Inter',
      baseRadius: baseRadius,
      density: density,
      elevation: GenaiElevationTokens.defaultDark(),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required GenaiColorTokens colors,
    required GenaiTypographyTokens typography,
    required String fontFamily,
    required double baseRadius,
    required GenaiDensity density,
    required GenaiElevationTokens elevation,
  }) {
    final extension = GenaiThemeExtension(
      colors: colors,
      typography: typography,
      spacing: GenaiSpacingTokens.defaultTokens(),
      sizing: GenaiSizingTokens(density: density),
      elevation: elevation,
      radius: GenaiRadiusTokens.defaultTokens(baseRadius: baseRadius),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.surfacePage,
      canvasColor: colors.surfaceCard,
      // Reset Material default ripple/hover overlays §3.2.1
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.colorPrimary,
        onPrimary: colors.textOnPrimary,
        secondary: colors.colorPrimary,
        onSecondary: colors.textOnPrimary,
        error: colors.colorError,
        onError: Colors.white,
        surface: colors.surfaceCard,
        onSurface: colors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: typography.displayLg,
        displaySmall: typography.displaySm,
        headlineLarge: typography.headingLg,
        headlineSmall: typography.headingSm,
        titleLarge: typography.headingLg,
        titleMedium: typography.headingSm,
        titleSmall: typography.label,
        bodyLarge: typography.bodyLg,
        bodyMedium: typography.bodyMd,
        bodySmall: typography.bodySm,
        labelLarge: typography.label,
        labelMedium: typography.label,
        labelSmall: typography.labelSm,
      ).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      dividerColor: colors.borderDefault,
      extensions: [extension],
    );

    return base;
  }
}
