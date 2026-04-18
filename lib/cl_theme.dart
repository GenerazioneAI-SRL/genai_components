import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/providers/cl_theme.provider.dart';
import 'utils/providers/module_theme.util.provider.dart';
import 'utils/shared_manager.util.dart';

const kThemeModeKey = '__theme_mode__';

/// --- Utils ---------------------------------------------------------------

class ColorUtils {
  const ColorUtils._();

  static Color fromHex(String code) => Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);

  static String toHex(Color color, {bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(color.a * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
      '${(color.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
      '${(color.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
      '${(color.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}';
}

/// --- Theme root ----------------------------------------------------------

abstract class CLTheme {
  const CLTheme({
    required this.primary,
    required this.secondary,
    required this.alternate,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.tertiaryBackground,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.borderColor,
    required this.background,
    required this.fillColor,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.ring,
    required this.cardBorder,
  });

  static Color hexToColor(String code) => ColorUtils.fromHex(code);

  static String toHex(Color color, {bool leadingHashSign = true}) => ColorUtils.toHex(color, leadingHashSign: leadingHashSign);

  static ThemeMode get themeMode {
    final darkMode = SharedManager.getBool(kThemeModeKey);
    return darkMode == null ? ThemeMode.system : (darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await SharedManager.setBool(kThemeModeKey, mode == ThemeMode.dark);
  }

  static CLTheme of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Cerca il provider generico (nuovo, consigliato)
    try {
      final tp = Provider.of<CLThemeProvider>(context);
      return isDark ? tp.darkTheme : tp.lightTheme;
    } catch (_) {}

    // 2. Fallback: cerca il vecchio ModuleThemeProvider (retrocompatibilità)
    try {
      // ignore: deprecated_member_use_from_same_package
      final mp = Provider.of<ModuleThemeProvider>(context);
      return isDark ? mp.darkTheme : mp.lightTheme;
    } catch (_) {}

    // 3. Default built-in
    return isDark ? dark : light;
  }

  // Singletons (default ID/azzurro)
  static const CLTheme light = LightModeTheme();
  static const CLTheme dark = DarkModeTheme();

  // Palette
  final Color primary;
  final Color secondary;
  final Color alternate;
  final Color primaryText;
  final Color secondaryText;
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color tertiaryBackground;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color borderColor;
  final Color background;
  final Color fillColor;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color ring;
  final Color cardBorder;

  /// Typography provider
  Typography get typography => ThemeTypography(this);

  /// --------- Getter compatibili (no refactor in app) ----------
  TextStyle get heading1 => typography.heading1;

  TextStyle get heading2 => typography.heading2;

  TextStyle get heading3 => typography.heading3;

  TextStyle get heading4 => typography.heading4;

  TextStyle get heading5 => typography.heading5;

  TextStyle get heading6 => typography.heading6;

  TextStyle get title => typography.title;

  TextStyle get subTitle => typography.subTitle;

  TextStyle get bodyText => typography.bodyText;

  TextStyle get smallText => typography.smallText;

  TextStyle get bodyLabel => typography.bodyLabel;

  TextStyle get bodyLabelTableHead => typography.bodyLabelTableHead;

  TextStyle get smallLabel => typography.smallLabel;

  /// ------------------------------------------------------------

  // Utility stabile (niente stato)
  Color generateColorFromText(String text) {
    final int hash = text.hashCode;
    final Random random = Random(hash);
    return Color.fromARGB(255, 100 + random.nextInt(155), 100 + random.nextInt(155), 100 + random.nextInt(155));
  }
}

/// --- Light / Dark --------------------------------------------------------

class LightModeTheme extends CLTheme {
  const LightModeTheme({
    Color primary = const Color(0xFF0C8EC7),
    Color secondary = const Color(0xFF0A7AAD),
    Color alternate = const Color(0xFFE8EBF0),
    Color primaryText = const Color(0xFF2E2E38),
    Color secondaryText = const Color(0xFF6B7080),
    Color primaryBackground = const Color(0xFFFAF9F7),
    Color secondaryBackground = const Color(0xFFFFFFFF),
    Color tertiaryBackground = const Color(0xFFF0F1F4),
    Color success = const Color(0xFF16A34A),
    Color warning = const Color(0xFFD97706),
    Color danger = const Color(0xFFDC2626),
    Color info = const Color(0xFF0C8EC7),
    Color borderColor = const Color(0xFFE8EBF0),
    Color background = const Color(0xFFFAF9F7),
    Color fillColor = const Color(0xFFF0F1F4),
    Color muted = const Color(0xFFF4F4F5),
    Color mutedForeground = const Color(0xFF71717A),
    Color accent = const Color(0xFFF4F4F5),
    Color accentForeground = const Color(0xFF18181B),
    Color ring = const Color(0xFF0C8EC7),
    Color cardBorder = const Color(0xFFE4E4E7),
  }) : super(
        primary: primary,
        secondary: secondary,
        alternate: alternate,
        primaryText: primaryText,
        secondaryText: secondaryText,
        primaryBackground: primaryBackground,
        secondaryBackground: secondaryBackground,
        tertiaryBackground: tertiaryBackground,
        success: success,
        warning: warning,
        danger: danger,
        info: info,
        borderColor: borderColor,
        background: background,
        fillColor: fillColor,
        muted: muted,
        mutedForeground: mutedForeground,
        accent: accent,
        accentForeground: accentForeground,
        ring: ring,
        cardBorder: cardBorder,
      );
}

class DarkModeTheme extends CLTheme {
  const DarkModeTheme({
    Color primary = const Color(0xFF3BA8D8),
    Color secondary = const Color(0xFF0C8EC7),
    Color alternate = const Color(0xFF2A2A34),
    Color primaryText = const Color(0xFFE8E8EC),
    Color secondaryText = const Color(0xFF8B8FA0),
    Color primaryBackground = const Color(0xFF121218),
    Color secondaryBackground = const Color(0xFF1E1E26),
    Color tertiaryBackground = const Color(0xFF2A2A34),
    Color success = const Color(0xFF4ADE80),
    Color warning = const Color(0xFFFBBF24),
    Color danger = const Color(0xFFF87171),
    Color info = const Color(0xFF3BA8D8),
    Color borderColor = const Color(0xFF2A2A34),
    Color background = const Color(0xFF121218),
    Color fillColor = const Color(0xFF1E1E26),
    Color muted = const Color(0xFF27272A),
    Color mutedForeground = const Color(0xFFA1A1AA),
    Color accent = const Color(0xFF27272A),
    Color accentForeground = const Color(0xFFFAFAFA),
    Color ring = const Color(0xFF3BA8D8),
    Color cardBorder = const Color(0xFF27272A),
  }) : super(
        primary: primary,
        secondary: secondary,
        alternate: alternate,
        primaryText: primaryText,
        secondaryText: secondaryText,
        primaryBackground: primaryBackground,
        secondaryBackground: secondaryBackground,
        tertiaryBackground: tertiaryBackground,
        success: success,
        warning: warning,
        danger: danger,
        info: info,
        borderColor: borderColor,
        background: background,
        fillColor: fillColor,
        muted: muted,
        mutedForeground: mutedForeground,
        accent: accent,
        accentForeground: accentForeground,
        ring: ring,
        cardBorder: cardBorder,
      );
}

/// --- Typography ----------------------------------------------------------

abstract class Typography {
  TextStyle get heading1;

  TextStyle get heading2;

  TextStyle get heading3;

  TextStyle get heading4;

  TextStyle get heading5;

  TextStyle get heading6;

  TextStyle get title;

  TextStyle get subTitle;

  TextStyle get bodyText;

  TextStyle get smallText;

  TextStyle get bodyLabel;

  TextStyle get bodyLabelTableHead;

  TextStyle get smallLabel;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final CLTheme theme;
  static const _bodyFamily = 'Inter';
  static const _displayFamily = 'Satoshi';

  /// Body/UI text helper (Inter — variable font locale con asse opsz)
  TextStyle _text(
    double size, {
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: _bodyFamily,
      // Attiva l'asse optical-size di Inter per rendering ottimale a ogni dimensione
      fontVariations: [FontVariation('opsz', size.clamp(14.0, 32.0))],
      color: color ?? theme.primaryText,
      fontSize: size,
      letterSpacing: letterSpacing ?? 0,
      fontWeight: weight,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
    );
  }

  /// Display/heading text helper (Satoshi — font locale)
  TextStyle _display(
    double size, {
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: _displayFamily,
      color: color ?? theme.primaryText,
      fontSize: size,
      letterSpacing: letterSpacing ?? 0,
      fontWeight: weight,
      height: lineHeight,
    );
  }

  // ── Headings — tutti Satoshi per scala visiva coerente ──────────────────

  /// H1: hero titles, page intro — Satoshi Black 32px
  @override
  TextStyle get heading1 => _display(32, weight: FontWeight.w900, letterSpacing: -1.2, lineHeight: 1.15);

  /// H2: sezioni principali — Satoshi Bold 24px
  @override
  TextStyle get heading2 => _display(24, weight: FontWeight.w700, letterSpacing: -0.6, lineHeight: 1.2);

  /// H3: sottosezioni — Satoshi Bold 20px
  @override
  TextStyle get heading3 => _display(20, weight: FontWeight.w700, letterSpacing: -0.3, lineHeight: 1.25);

  /// H4: card headers, dialog titles — Satoshi Medium 17px
  @override
  TextStyle get heading4 => _display(17, weight: FontWeight.w500, letterSpacing: -0.2, lineHeight: 1.3);

  /// H5: etichette di sezione — Inter SemiBold 14px
  @override
  TextStyle get heading5 => _text(14, weight: FontWeight.w600, letterSpacing: -0.1, lineHeight: 1.35);

  /// H6: micro-heading, caption in neretto — Inter SemiBold 13px
  @override
  TextStyle get heading6 => _text(13, weight: FontWeight.w600, lineHeight: 1.4);

  // ── Body / UI ────────────────────────────────────────────────────────────

  /// Titolo UI (pulsanti, tab, menu item) — Inter SemiBold 15px
  @override
  TextStyle get title => _text(15, weight: FontWeight.w600, letterSpacing: -0.1, lineHeight: 1.4);

  /// Sottotitolo descrittivo — Inter Medium 14px
  @override
  TextStyle get subTitle => _text(14, weight: FontWeight.w500, lineHeight: 1.5);

  /// Corpo testo principale — Inter Regular 14px, interlinea aperta
  @override
  TextStyle get bodyText => _text(14, weight: FontWeight.w400, lineHeight: 1.6);

  /// Testo piccolo — Inter Regular 12px
  @override
  TextStyle get smallText => _text(12, weight: FontWeight.w400, lineHeight: 1.5);

  /// Label UI secondaria — Inter Medium 13px, colore secondario
  @override
  TextStyle get bodyLabel => _text(13, weight: FontWeight.w500, color: theme.secondaryText, lineHeight: 1.5);

  /// Intestazione colonna tabella — Inter SemiBold 11px, spaziatura lettere positiva
  @override
  TextStyle get bodyLabelTableHead => _text(11, weight: FontWeight.w600, color: theme.secondaryText, letterSpacing: 0.4, lineHeight: 1.4);

  /// Label piccola — Inter Regular 12px, colore secondario
  @override
  TextStyle get smallLabel => _text(12, weight: FontWeight.w400, color: theme.secondaryText, lineHeight: 1.4);
}

/// --- TextStyle extension --------------------------------------------------

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    // ignorato — mantenuto per retrocompatibilità API
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
  }) {
    // Non passare fontFamily se è null: copyWith(fontFamily: null) in Flutter
    // azzera il fontFamily originale (comportamento Flutter), facendo cadere
    // il testo sul font di sistema (Roboto/SF). Preserviamo il fontFamily
    // del TextStyle padre a meno che non sia stato esplicitamente sovrascritto.
    return copyWith(
      fontFamily: fontFamily ?? this.fontFamily,
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
    );
  }
}
