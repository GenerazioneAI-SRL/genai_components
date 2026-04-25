import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'theme_builder.dart';

/// Curated v3 theme presets (§6).
///
/// v3.0 shipped a single light preset — `formaLms()`. v3.1 adds five v1-parity
/// color variations on top of the Forma LMS shape:
///
/// - [formaAurora] — dark violet companion (introduces v3 dark mode).
/// - [formaSunset] — warm cream / terracotta light variant.
/// - [formaNeoMono] — strict B&W + lime brutalist light.
/// - [formaShadcn] — shadcn zinc neutrals on white.
/// - [formaShadcnDark] — shadcn dark counterpart.
///
/// All five preserve v3's typography rules (Geist + the cardTitle /
/// sectionTitle / pageTitle / kpiNumber roles); only the color tokens shift
/// per preset intent. `formaLms()` remains the canonical default.
///
/// ```dart
/// import 'package:genai_components/genai_components_v3.dart' as v3;
///
/// MaterialApp(
///   theme: v3.GenaiThemePresets.formaLms(),
/// );
/// ```
class GenaiThemePresets {
  GenaiThemePresets._();

  /// **Forma LMS Light** — the canonical v3 preset. Light Geist body on the
  /// `--bg / --panel` ramp, ink-black primary CTA.
  static ThemeData formaLms({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: GenaiColorTokens.defaultLight(),
        fontFamily: 'Geist',
        density: density,
      );

  /// **Forma Aurora** — dark companion to Forma LMS. Indigo-tinted near-black
  /// surfaces, violet600 primary CTA, cyan info accent. Introduces dark mode
  /// to the v3 system; the rest of the Forma typography / spacing rules are
  /// preserved.
  static ThemeData formaAurora({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _formaAuroraColors,
        fontFamily: 'Geist',
        baseRadius: 10,
        density: density,
      );

  /// **Forma Sunset** — cream / terracotta light variant. Anthropic-adjacent
  /// warm palette ported onto the Forma shape. Uses Poppins for the editorial
  /// feel (overrides Geist).
  static ThemeData formaSunset({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _formaSunsetColors,
        fontFamily: 'Poppins',
        baseRadius: 12,
        density: density,
      );

  /// **Forma NeoMono** — strict black + white with an electric lime accent.
  /// Sharp corners (`baseRadius: 0`), Space Grotesk type. The Forma neutrals
  /// (`--ink-2 / --ink-3`) survive for body text so the layout still reads.
  static ThemeData formaNeoMono({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _formaNeoMonoColors,
        fontFamily: 'Space Grotesk',
        baseRadius: 0,
        density: density,
      );

  /// **Forma shadcn** — shadcn/ui zinc palette. Near-black primary, neutral
  /// focus ring, paper-white surfaces. Keeps Geist typography.
  static ThemeData formaShadcn({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _formaShadcnLightColors,
        fontFamily: 'Geist',
        baseRadius: 10,
        density: density,
      );

  /// **Forma shadcn Dark** — dark counterpart to [formaShadcn]. Near-black
  /// surfaces, paper-white primary, zinc neutrals.
  static ThemeData formaShadcnDark(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _formaShadcnDarkColors,
        fontFamily: 'Geist',
        baseRadius: 10,
        density: density,
      );
}

// ─── Aurora (dark, violet accent) ───────────────────────────────────────────
const _auroraSurfaceDeepest = Color(0xFF050509);
const _auroraSurfacePage = Color(0xFF0B0B12);
const _auroraSurfaceCard = Color(0xFF13131F);
const _auroraSurfaceInput = Color(0xFF1C1C2B);
const _auroraSurfaceOverlay = Color(0xFF1F1F30);
const _auroraSurfaceSidebar = Color(0xFF0F0F18);
const _auroraViolet600 = Color(0xFF7C3AED);
const _auroraViolet500 = Color(0xFF8B5CF6);
const _auroraViolet400 = Color(0xFFA78BFA);
const _auroraViolet300 = Color(0xFFC4B5FD);
const _auroraViolet700 = Color(0xFF6D28D9);

final GenaiColorTokens _formaAuroraColors =
    GenaiColorTokens.defaultDark().copyWith(
  surfaceDeepest: _auroraSurfaceDeepest,
  surfacePage: _auroraSurfacePage,
  surfaceCard: _auroraSurfaceCard,
  surfaceInput: _auroraSurfaceInput,
  surfaceOverlay: _auroraSurfaceOverlay,
  surfaceModal: _auroraSurfaceOverlay,
  surfaceSidebar: _auroraSurfaceSidebar,
  surfaceHover: const Color(0x14FFFFFF),
  surfacePressed: const Color(0x29FFFFFF),
  surfaceInverse: const Color(0xFFE4E4E7),
  borderSubtle: const Color(0xFF1C1C2B),
  borderDefault: const Color(0xFF27273A),
  borderStrong: const Color(0xFF3B3B52),
  borderFocus: _auroraViolet400,
  textPrimary: const Color(0xFFE4E4E7),
  textSecondary: const Color(0xFF9CA3AF),
  textTertiary: const Color(0xFF7B8090),
  textDisabled: const Color(0xFF4B5563),
  textOnPrimary: Colors.white,
  textOnInverse: _auroraSurfacePage,
  textLink: _auroraViolet400,
  colorPrimary: _auroraViolet600,
  colorPrimaryHover: _auroraViolet500,
  colorPrimaryPressed: _auroraViolet700,
  colorPrimarySubtle: const Color(0xFF1E1B3A),
  colorPrimaryText: _auroraViolet300,
  // Cyan info accent — v1 aurora signature
  colorInfo: const Color(0xFF22D3EE),
  colorInfoSubtle: const Color(0x3322D3EE),
  colorInfoText: const Color(0xFF67E8F9),
);

// ─── Sunset (light, warm) ───────────────────────────────────────────────────
const _sunsetPrimary = Color(0xFFD97757);
const _sunsetPrimaryHover = Color(0xFFC66440);
const _sunsetPrimaryPressed = Color(0xFFAE5535);
const _sunsetPrimarySubtle = Color(0xFFFAEBE3);
const _sunsetCream = Color(0xFFFAF9F5);
const _sunsetInk = Color(0xFF141413);
const _sunsetSlate = Color(0xFF6B6963);
const _sunsetTertiary = Color(0xFF8C897F);
const _sunsetLightBorder = Color(0xFFE8E6DC);
const _sunsetStrongBorder = Color(0xFFB0AEA5);
const _sunsetBlue = Color(0xFF6A9BCC);
const _sunsetGreen = Color(0xFF788C5D);

final GenaiColorTokens _formaSunsetColors =
    GenaiColorTokens.defaultLight().copyWith(
  surfaceDeepest: _sunsetCream,
  surfacePage: _sunsetCream,
  surfaceCard: Colors.white,
  surfaceInput: Colors.white,
  surfaceOverlay: Colors.white,
  surfaceModal: Colors.white,
  surfaceSidebar: _sunsetCream,
  surfaceHover: const Color(0xFFF3F1E9),
  surfacePressed: _sunsetLightBorder,
  surfaceInverse: _sunsetInk,
  borderSubtle: _sunsetLightBorder,
  borderDefault: _sunsetLightBorder,
  borderStrong: _sunsetStrongBorder,
  borderFocus: _sunsetPrimary,
  textPrimary: _sunsetInk,
  textSecondary: _sunsetSlate,
  textTertiary: _sunsetTertiary,
  textDisabled: _sunsetStrongBorder,
  textOnPrimary: _sunsetCream,
  textOnInverse: _sunsetCream,
  textLink: _sunsetPrimaryHover,
  colorPrimary: _sunsetPrimary,
  colorPrimaryHover: _sunsetPrimaryHover,
  colorPrimaryPressed: _sunsetPrimaryPressed,
  colorPrimarySubtle: _sunsetPrimarySubtle,
  colorPrimaryText: _sunsetPrimaryPressed,
  colorSuccess: _sunsetGreen,
  colorSuccessSubtle: const Color(0xFFEDF1E5),
  colorSuccessText: const Color(0xFF5E7148),
  colorInfo: _sunsetBlue,
  colorInfoSubtle: const Color(0xFFE7EFF9),
  colorInfoText: const Color(0xFF5482B3),
);

// ─── NeoMono (light, brutalist) ─────────────────────────────────────────────
const _neoInk = Color(0xFF000000);
const _neoPaper = Color(0xFFFFFFFF);
const _neoMist = Color(0xFFF5F5F5);
const _neoLime = Color(0xFFE5FF3C);
const _neoLimeDeep = Color(0xFFCAE821);

final GenaiColorTokens _formaNeoMonoColors =
    GenaiColorTokens.defaultLight().copyWith(
  surfaceDeepest: _neoPaper,
  surfacePage: _neoPaper,
  surfaceCard: _neoPaper,
  surfaceInput: _neoMist,
  surfaceOverlay: _neoPaper,
  surfaceModal: _neoPaper,
  surfaceSidebar: _neoPaper,
  surfaceHover: _neoLime,
  surfacePressed: _neoLimeDeep,
  surfaceInverse: _neoInk,
  borderSubtle: _neoInk,
  borderDefault: _neoInk,
  borderStrong: _neoInk,
  borderFocus: _neoLime,
  textPrimary: _neoInk,
  textSecondary: const Color(0xFF525252),
  textTertiary: const Color(0xFF737373),
  textDisabled: const Color(0xFF9CA3AF),
  textOnPrimary: _neoLime,
  textOnInverse: _neoLime,
  textLink: _neoInk,
  colorPrimary: _neoInk,
  colorPrimaryHover: const Color(0xFF1A1A1A),
  colorPrimaryPressed: const Color(0xFF333333),
  colorPrimarySubtle: _neoLime,
  colorPrimaryText: _neoInk,
  colorSuccess: _neoLimeDeep,
  colorSuccessSubtle: _neoLime,
  colorSuccessText: _neoInk,
  colorInfo: _neoInk,
  colorInfoSubtle: _neoMist,
  colorInfoText: _neoInk,
);

// ─── shadcn (light + dark) ──────────────────────────────────────────────────
const _shadcnZinc50 = Color(0xFFFAFAFA);
const _shadcnZinc100 = Color(0xFFF4F4F5);
const _shadcnZinc200 = Color(0xFFE4E4E7);
const _shadcnZinc300 = Color(0xFFD4D4D8);
const _shadcnZinc400 = Color(0xFFA1A1AA);
const _shadcnZinc500 = Color(0xFF71717A);
const _shadcnZinc700 = Color(0xFF3F3F46);
const _shadcnZinc800 = Color(0xFF27272A);
const _shadcnZinc900 = Color(0xFF18181B);
const _shadcnZinc950 = Color(0xFF0A0A0A);
const _shadcnWhite = Color(0xFFFFFFFF);
const _shadcnDestructive = Color(0xFFEF4444);

final GenaiColorTokens _formaShadcnLightColors =
    GenaiColorTokens.defaultLight().copyWith(
  surfaceDeepest: _shadcnZinc100,
  surfacePage: _shadcnWhite,
  surfaceCard: _shadcnWhite,
  surfaceInput: _shadcnWhite,
  surfaceOverlay: _shadcnWhite,
  surfaceModal: _shadcnWhite,
  surfaceSidebar: _shadcnWhite,
  surfaceHover: _shadcnZinc100,
  surfacePressed: _shadcnZinc200,
  surfaceInverse: _shadcnZinc900,
  borderSubtle: _shadcnZinc200,
  borderDefault: _shadcnZinc200,
  borderStrong: _shadcnZinc300,
  borderFocus: _shadcnZinc400,
  textPrimary: _shadcnZinc950,
  textSecondary: _shadcnZinc500,
  textTertiary: _shadcnZinc400,
  textDisabled: _shadcnZinc300,
  textOnPrimary: _shadcnZinc50,
  textOnInverse: _shadcnZinc50,
  textLink: _shadcnZinc950,
  colorPrimary: _shadcnZinc900,
  colorPrimaryHover: _shadcnZinc800,
  colorPrimaryPressed: _shadcnZinc700,
  colorPrimarySubtle: _shadcnZinc100,
  colorPrimaryText: _shadcnZinc950,
  colorDanger: _shadcnDestructive,
  colorDangerSubtle: const Color(0xFFFEF2F2),
  colorDangerText: const Color(0xFFDC2626),
);

final GenaiColorTokens _formaShadcnDarkColors =
    GenaiColorTokens.defaultDark().copyWith(
  surfaceDeepest: const Color(0xFF050505),
  surfacePage: _shadcnZinc950,
  surfaceCard: _shadcnZinc900,
  surfaceInput: _shadcnZinc900,
  surfaceOverlay: _shadcnZinc900,
  surfaceModal: _shadcnZinc900,
  surfaceSidebar: _shadcnZinc950,
  surfaceHover: _shadcnZinc800,
  surfacePressed: _shadcnZinc700,
  surfaceInverse: _shadcnZinc50,
  borderSubtle: _shadcnZinc800,
  borderDefault: _shadcnZinc800,
  borderStrong: _shadcnZinc700,
  borderFocus: _shadcnZinc300,
  textPrimary: _shadcnZinc50,
  textSecondary: _shadcnZinc400,
  textTertiary: _shadcnZinc500,
  textDisabled: _shadcnZinc700,
  textOnPrimary: _shadcnZinc950,
  textOnInverse: _shadcnZinc950,
  textLink: _shadcnZinc50,
  colorPrimary: _shadcnZinc50,
  colorPrimaryHover: _shadcnZinc100,
  colorPrimaryPressed: _shadcnZinc200,
  colorPrimarySubtle: _shadcnZinc800,
  colorPrimaryText: _shadcnZinc50,
  colorDanger: _shadcnDestructive,
  colorDangerSubtle: const Color(0xFF3F1212),
  colorDangerText: const Color(0xFFF87171),
);
