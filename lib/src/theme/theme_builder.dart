import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'theme_extension.dart';

/// Builds [ThemeData] for the v3 design system.
///
/// v3.0 shipped **light only** (§6, §7). v3.1 added a [dark] counterpart to
/// back the dark color presets (formaAurora, formaShadcnDark). Forma LMS
/// remains a light-first design — [light] is still the canonical factory.
class GenaiTheme {
  GenaiTheme._();

  /// Canonical light theme. All presets should call this with a
  /// `colorsOverride` if they want to customise the accent quartet.
  ///
  /// [baseRadius] (optional) scales the radius scale around `md` — supplying
  /// a value scales `xs/sm/md/lg/xl` proportionally. Used by the dark color
  /// presets to opt into v1-parity radii (NeoMono `0`, Aurora `10`).
  static ThemeData light({
    GenaiColorTokens? colorsOverride,
    GenaiTypographyTokens? typographyOverride,
    String? fontFamily,
    double? baseRadius,
    GenaiDensity density = GenaiDensity.normal,
  }) {
    final colors = colorsOverride ?? GenaiColorTokens.defaultLight();
    final typography = typographyOverride ??
        GenaiTypographyTokens.defaultTokens(fontFamily: fontFamily);
    return _build(
      brightness: Brightness.light,
      colors: colors,
      typography: typography,
      fontFamily: fontFamily ?? 'Geist',
      density: density,
      elevation: GenaiElevationTokens.defaultLight(),
      radius: _radiusForBase(baseRadius),
    );
  }

  /// Dark theme — added in v3.1 for the dark color presets. Forma LMS is
  /// light-first so this is opt-in: only the dark presets reach for it.
  static ThemeData dark({
    GenaiColorTokens? colorsOverride,
    GenaiTypographyTokens? typographyOverride,
    String? fontFamily,
    double? baseRadius,
    GenaiDensity density = GenaiDensity.normal,
  }) {
    final colors = colorsOverride ?? GenaiColorTokens.defaultDark();
    final typography = typographyOverride ??
        GenaiTypographyTokens.defaultTokens(fontFamily: fontFamily);
    return _build(
      brightness: Brightness.dark,
      colors: colors,
      typography: typography,
      fontFamily: fontFamily ?? 'Geist',
      density: density,
      elevation: GenaiElevationTokens.defaultDark(),
      radius: _radiusForBase(baseRadius),
    );
  }

  /// Scales the radius scale around an explicit [base]. Anchors to the
  /// canonical `md=8` step; preserves `none` (0) and `pill` (999).
  static GenaiRadiusTokens _radiusForBase(double? base) {
    if (base == null) return GenaiRadiusTokens.defaultTokens();
    final canonical = GenaiRadiusTokens.defaultTokens();
    if (canonical.md == 0) return canonical;
    final ratio = base / canonical.md;
    return GenaiRadiusTokens(
      none: 0,
      xs: canonical.xs * ratio,
      sm: canonical.sm * ratio,
      md: base,
      lg: canonical.lg * ratio,
      xl: canonical.xl * ratio,
      hero: canonical.hero * ratio,
      pill: 999,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required GenaiColorTokens colors,
    required GenaiTypographyTokens typography,
    required String fontFamily,
    required GenaiDensity density,
    required GenaiElevationTokens elevation,
    required GenaiRadiusTokens radius,
  }) {
    final extension = GenaiThemeExtension(
      colors: colors,
      typography: typography,
      spacing: GenaiSpacingTokens.defaultTokens(),
      sizing: GenaiSizingTokens.forDensity(density),
      radius: radius,
      elevation: elevation,
      motion: GenaiMotionTokens.defaultTokens(),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.surfacePage,
      canvasColor: colors.surfaceCard,
      // Reset Material defaults — v3 uses hairline borders + neutral-soft
      // hovers, never Material's ripple/hover overlays.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.colorPrimary,
        onPrimary: colors.textOnPrimary,
        secondary: colors.colorInfo,
        onSecondary: colors.textOnPrimary,
        error: colors.colorDanger,
        onError: Colors.white,
        surface: colors.surfaceCard,
        onSurface: colors.textPrimary,
      ),
      textTheme: TextTheme(
        // v3 typography slots don't map 1:1 to Material's display/headline
        // roles — we expose the canonical roles closest to the HTML spec
        // and let components read the v3-specific tokens directly via
        // `context.typography`.
        displayLarge: typography.kpiNumber,
        displayMedium: typography.pageTitle,
        displaySmall: typography.focusTitle,
        headlineLarge: typography.pageTitle,
        headlineMedium: typography.focusTitle,
        headlineSmall: typography.sectionTitle,
        titleLarge: typography.sectionTitle,
        titleMedium: typography.cardTitle,
        titleSmall: typography.cardTitle,
        bodyLarge: typography.body,
        bodyMedium: typography.body,
        bodySmall: typography.bodySm,
        labelLarge: typography.label,
        labelMedium: typography.label,
        labelSmall: typography.labelSm,
      ).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      dividerColor: colors.borderSubtle,
      extensions: [extension],
    );
  }
}
