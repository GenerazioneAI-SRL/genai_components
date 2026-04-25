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

  static String toHex(Color color, {bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
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

  static String toHex(Color color, {bool leadingHashSign = true}) =>
      ColorUtils.toHex(color, leadingHashSign: leadingHashSign);

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
    // listen:false — la sostituzione del provider richiede ricostruzione del MaterialApp,
    // quindi non serve sottoscrivere qui (evita rebuild a cascata su notifyListeners).
    try {
      final tp = Provider.of<CLThemeProvider>(context, listen: false);
      return isDark ? tp.darkTheme : tp.lightTheme;
    } catch (_) {}

    // 2. Fallback: cerca il vecchio ModuleThemeProvider (retrocompatibilità)
    // listen:false — stesso motivo: lookup dati tema, non flusso reattivo.
    try {
      // ignore: deprecated_member_use_from_same_package
      final mp = Provider.of<ModuleThemeProvider>(context, listen: false);
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
  final Color muted; // Subtle background for non-interactive elements
  final Color mutedForeground; // Text on muted surfaces
  final Color accent; // Hover/interactive surface (defaults to muted)
  final Color accentForeground; // Text on accent surfaces
  final Color ring; // Focus ring / outline color
  final Color cardBorder; // Card and panel border

  List<BoxShadow> get cardShadow;

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
    super.primary = const Color(0xFF0C8EC7),
    super.secondary = const Color(0xFF0A7AAD),
    super.alternate = const Color(0xFFE8EBF0),
    super.primaryText = const Color(0xF2000000),
    super.secondaryText = const Color(0xFF615D59),
    super.primaryBackground = const Color(0xFFF6F5F4),
    super.secondaryBackground = const Color(0xFFFFFFFF),
    super.tertiaryBackground = const Color(0xFFECEBE9),
    super.success = const Color(0xFF16A34A),
    super.warning = const Color(0xFFD97706),
    super.danger = const Color(0xFFDC2626),
    super.info = const Color(0xFF0C8EC7),
    super.borderColor = const Color(0x1A000000),
    super.background = const Color(0xFFF6F5F4),
    super.fillColor = const Color(0xFFF6F5F4),
    super.muted = const Color(0xFFF2F1EF),
    super.mutedForeground = const Color(0xFFA39E98),
    super.accent = const Color(0xFFF2F1EF),
    super.accentForeground = const Color(0xFF31302E),
    super.ring = const Color(0xFF097FE8),
    super.cardBorder = const Color(0x1A000000),
  });

  @override
  List<BoxShadow> get cardShadow => const [
        BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 4)),
        BoxShadow(color: Color(0x07000000), blurRadius: 7.85, offset: Offset(0, 2.025)),
        BoxShadow(color: Color(0x05000000), blurRadius: 2.93, offset: Offset(0, 0.8)),
        BoxShadow(color: Color(0x03000000), blurRadius: 1.04, offset: Offset(0, 0.175)),
      ];
}

class DarkModeTheme extends CLTheme {
  const DarkModeTheme({
    super.primary = const Color(0xFF3BA8D8),
    super.secondary = const Color(0xFF0C8EC7),
    super.alternate = const Color(0xFF2A2A34),
    super.primaryText = const Color(0xFFE8E8EC),
    super.secondaryText = const Color(0xFF8B8FA0),
    super.primaryBackground = const Color(0xFF121218),
    super.secondaryBackground = const Color(0xFF1E1E26),
    super.tertiaryBackground = const Color(0xFF2A2A34),
    super.success = const Color(0xFF4ADE80),
    super.warning = const Color(0xFFFBBF24),
    super.danger = const Color(0xFFF87171),
    super.info = const Color(0xFF3BA8D8),
    super.borderColor = const Color(0xFF2A2A34),
    super.background = const Color(0xFF121218),
    super.fillColor = const Color(0xFF1E1E26),
    super.muted = const Color(0xFF27272A),
    super.mutedForeground = const Color(0xFFA1A1AA),
    super.accent = const Color(0xFF27272A),
    super.accentForeground = const Color(0xFFFAFAFA),
    super.ring = const Color(0xFF3BA8D8),
    super.cardBorder = const Color(0xFF27272A),
  });

  @override
  List<BoxShadow> get cardShadow => const [
        BoxShadow(color: Color(0x29000000), blurRadius: 18, offset: Offset(0, 4)),
        BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
      ];
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

  /// H1: hero titles, page intro — Satoshi Bold 32px
  @override
  TextStyle get heading1 => _display(32, weight: FontWeight.w700, letterSpacing: -1.0, lineHeight: 1.15);

  /// H2: sezioni principali — Satoshi SemiBold 24px
  @override
  TextStyle get heading2 => _display(24, weight: FontWeight.w600, letterSpacing: -0.5, lineHeight: 1.2);

  /// H3: sottosezioni — Satoshi SemiBold 20px
  @override
  TextStyle get heading3 => _display(20, weight: FontWeight.w600, letterSpacing: -0.25, lineHeight: 1.25);

  /// H4: card headers, dialog titles — Satoshi Medium 17px
  @override
  TextStyle get heading4 => _display(17, weight: FontWeight.w500, letterSpacing: -0.15, lineHeight: 1.3);

  /// H5: etichette di sezione — Inter Medium 14px
  @override
  TextStyle get heading5 => _text(14, weight: FontWeight.w500, letterSpacing: -0.05, lineHeight: 1.35);

  /// H6: micro-heading — Inter Medium 13px
  @override
  TextStyle get heading6 => _text(13, weight: FontWeight.w500, lineHeight: 1.4);

  // ── Body / UI ────────────────────────────────────────────────────────────

  /// Titolo UI (pulsanti, tab, menu item) — Inter Medium 15px
  @override
  TextStyle get title => _text(15, weight: FontWeight.w500, letterSpacing: -0.05, lineHeight: 1.4);

  /// Sottotitolo descrittivo — Inter Regular 14px
  @override
  TextStyle get subTitle => _text(14, weight: FontWeight.w400, lineHeight: 1.5);

  /// Corpo testo principale — Inter Regular 14px, interlinea aperta
  @override
  TextStyle get bodyText => _text(14, weight: FontWeight.w400, lineHeight: 1.6);

  /// Testo piccolo — Inter Regular 12px
  @override
  TextStyle get smallText => _text(12, weight: FontWeight.w400, lineHeight: 1.5);

  /// Label UI secondaria — Inter Regular 13px, colore secondario
  @override
  TextStyle get bodyLabel => _text(13, weight: FontWeight.w400, color: theme.secondaryText, lineHeight: 1.5);

  /// Intestazione colonna tabella — Inter Medium 11px, spaziatura lettere positiva
  @override
  TextStyle get bodyLabelTableHead =>
      _text(11, weight: FontWeight.w500, color: theme.secondaryText, letterSpacing: 0.3, lineHeight: 1.4);

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
