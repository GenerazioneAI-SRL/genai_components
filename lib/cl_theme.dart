import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/providers/cl_theme.provider.dart';
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
    required this.controlFill,
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
  final Color controlFill; // Fill controlli neutri su superficie (es. icon button su L1)

  /// Accento viola decorativo (categorie/CTA secondari NON semantici — es. badge
  /// CERT, bottoni "Aggiungi" di contesto). Non è success/warning/danger/info:
  /// è una tinta brand-adiacente. Light violet-600, override dark violet-400.
  Color get accentPurple => const Color(0xFF7C3AED);

  List<BoxShadow> get cardShadow;

  /// Ombra leggera per card statiche (Foundation L1 raised): sottile, quasi
  /// hairline. Da preferire su superfici NON transitorie. [cardShadow] resta
  /// (più marcata) per retrocompat dei consumer esistenti.
  List<BoxShadow> get cardShadowSoft;

  /// Ombra marcata per superfici transitorie: popover, menu, dropdown, sheet.
  List<BoxShadow> get popoverShadow;

  // ═══════════════════════════════════════════════════════════
  // MOTION — durate ed easing canonici. Concreti (uguali in light/dark:
  // l'animazione non cambia col tema). Easing = Material standard
  // ≈ cubic-bezier(.4, 0, .2, 1), già esposto da Flutter come
  // Curves.fastOutSlowIn (lo stesso identico Cubic).
  // ═══════════════════════════════════════════════════════════

  /// 150ms — hover/press di bottoni e controlli.
  Duration get durationFast => const Duration(milliseconds: 150);

  /// 200ms — toggle, tab, cambi di stato.
  Duration get durationBase => const Duration(milliseconds: 200);

  /// 300ms — popover, sheet, elevazione.
  Duration get durationSlow => const Duration(milliseconds: 300);

  /// cubic-bezier(.4, 0, .2, 1) — easing standard del DS.
  Curve get easingStandard => Curves.fastOutSlowIn;

  // --------- Design token dimensionali ----------
  // Default = valori storici di CLSizes. Override nel tema di progetto per
  // personalizzare spaziature/radii senza toccare la libreria.

  /// 4px — gap atomico.
  double get gapXs => 4.0;

  /// 8px — gap denso (chip, badge, liste compatte).
  double get gapSm => 8.0;

  /// 12px — gap medio (campi form vicini, card dense).
  double get gapMd => 12.0;

  /// 16px — gap standard (sezioni form, card in griglia).
  double get gapLg => 16.0;

  /// 20px — gap ampio.
  double get gapXl => 20.0;

  /// 24px — gap tra blocchi.
  double get gap2Xl => 24.0;

  /// 32px — gap tra macro-sezioni.
  double get gap3Xl => 32.0;

  /// 48px — gap massimo (hero, empty state).
  double get gap4Xl => 48.0;

  // ═══════════════════════════════════════════════════════════
  // OPACITY SCALE — alpha semantici per tinte/bordi tonali.
  // Additivi, no breaking. Consolidano i valori alpha sparsi nel DS
  // (0.04 → 0.30) in step nominati intent-revealing. Si usano come
  // `color.withValues(alpha: theme.opacityXxx)`.
  // Step crescenti = presenza visiva crescente sulla stessa tinta.
  // ═══════════════════════════════════════════════════════════

  /// 0.04 — tinta quasi impercettibile.
  /// Usato per: wash di sfondo pagina su tinta semantica (error page),
  /// fondo gradiente di card tonali nel punto più tenue, hint di colore.
  double get opacityFaint => 0.04;

  /// 0.06 — tinta morbida.
  /// Usato per: fill di info banner/alert in light mode, sfondo di summary
  /// card non-compatte, glow di gradienti decorativi.
  double get opacitySubtle => 0.06;

  /// 0.10 — fill tonale standard (cluster dominante del DS).
  /// Usato per: sfondo di badge/chip/pill tinti, alert soft, stato selezionato
  /// di voci lista/menu/calendario, container icona tenue. Default per tinta su superficie.
  double get opacitySoft => 0.10;

  /// 0.14 — fill tonale enfatizzato.
  /// Usato per: sfondo container icona in card metriche/summary, stato selezionato
  /// di view toggle, avatar tinti, evidenziazioni leggermente più marcate.
  double get opacityMuted => 0.14;

  /// 0.20 — bordo tonale / hover fill.
  /// Usato per: bordo di pill/alert/info banner, hover fill su superfici neutre,
  /// avatar role badge, separatori tinti su tinta.
  double get opacityMedium => 0.20;

  /// 0.28 — bordo tonale forte / hover.
  /// Usato per: bordo di summary card, bordo hover di action chip, bordo
  /// info banner in dark mode, contorni che devono restare leggibili.
  double get opacityStrong => 0.28;

  /// 0.50 — scrim / stato disabilitato.
  /// Usato per: bordo e sfondo di controlli disabilitati (input, card border
  /// disabled), overlay arco di loading, dimming di elementi non interattivi.
  double get opacityDisabled => 0.50;

  // ═══════════════════════════════════════════════════════════
  // SPACING — token mancante.
  // ═══════════════════════════════════════════════════════════

  /// 6px — gap icona↔testo (off-grid intenzionale).
  /// Usato per: spaziatura tra icona leading e label in bottoni/chip/dropdown,
  /// dove `gapSm` (8) è troppo largo e `gapXs` (4) troppo stretto. Consolida i
  /// vari `spacing: 6` / `SizedBox(width: 6)` sparsi (e l'`iconTextGap` locale).
  double get gapIconText => 6.0;

  /// 20px — padding orizzontale di pagina.
  double get pagePadX => 20.0;

  /// 80px — offset verticale header pagina.
  double get pageTop => 80.0;

  /// 4px — radius chip/badge.
  double get radiusChip => 4.0;

  /// 8px — radius controlli (bottoni, input).
  double get radiusControl => 8.0;

  /// 10px — radius superfici (popup, dropdown).
  double get radiusSurface => 10.0;

  /// 14px — radius card.
  double get radiusCard => 14.0;

  /// 24px — radius modali.
  double get radiusModal => 24.0;

  /// 9999px — radius pill.
  double get radiusPill => 9999.0;

  /// 36px — radius delle bolle shell (header/menu/contenuto/AI). Pari a metà
  /// dell'altezza della bolla header (≈ buttonHeightDefault + 2·gapLg) così
  /// l'header risulta tondo alle estremità (capsula); le bolle più alte
  /// condividono lo stesso raggio per coerenza visiva.
  double get radiusBubble => 36.0;

  /// 16px — icone compatte (dentro chip, celle tabella).
  double get iconSizeCompact => 16.0;

  /// 20px — icone default.
  double get iconSizeDefault => 20.0;

  /// 24px — icone grandi (header, empty state).
  double get iconSizeLarge => 24.0;

  /// 40px — altezza bottone default.
  double get buttonHeightDefault => 40.0;

  /// 32px — altezza bottone compatto (`isCompact: true`).
  double get buttonHeightCompact => 32.0;

  /// 48px — altezza bottone large (CTA hero).
  double get buttonHeightLarge => 48.0;

  /// 40px — altezza standard input (CLTextField, CLDropdown).
  double get inputHeight => 40.0;

  /// 32px — altezza input compatto (`isCompact: true`).
  double get inputHeightCompact => 32.0;

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

/// Light shadow tokens (DS sottile) — riutilizzati da Material elevation
/// e da decorazioni di card.
const _kLightCardShadow = <BoxShadow>[
  BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x48000000), blurRadius: 10, offset: Offset(0, 3)),
];

const _kDarkCardShadow = <BoxShadow>[
  BoxShadow(color: Color(0x9A000000), blurRadius: 22, offset: Offset(0, 6)),
  BoxShadow(color: Color(0x4C000000), blurRadius: 8, offset: Offset(0, 2)),
];

// Card statiche (Foundation L1): sottile. Popover/menu: marcata, spread negativo.
const _kLightCardShadowSoft = <BoxShadow>[
  BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
];
const _kLightPopoverShadow = <BoxShadow>[
  BoxShadow(color: Color(0x38000000), blurRadius: 28, spreadRadius: -6, offset: Offset(0, 12)),
];
const _kDarkCardShadowSoft = <BoxShadow>[
  BoxShadow(color: Color(0x80000000), blurRadius: 6, offset: Offset(0, 2)),
];
const _kDarkPopoverShadow = <BoxShadow>[
  BoxShadow(color: Color(0xB3000000), blurRadius: 34, spreadRadius: -6, offset: Offset(0, 16)),
];

class LightModeTheme extends CLTheme {
  const LightModeTheme({
    super.primary = const Color(0xFF0C8EC7),
    super.secondary = const Color(0xFF0A7AAD),
    // Rampa neutra quasi-neutra (filo di freddo, Apple-like): accent-agnostica,
    // niente beige caldo né blu marcato. Blu brand #0C8EC7 invariato.
    super.alternate = const Color(0xFFECEEF0),
    super.primaryText = const Color(0xF2000000),
    super.secondaryText = const Color(0xFF5D6066),
    super.primaryBackground = const Color(0xFFFBFBFC),
    super.secondaryBackground = const Color(0xFFFFFFFF),
    super.tertiaryBackground = const Color(0xFFE9EBED),
    super.success = const Color(0xFF16A34A),
    super.warning = const Color(0xFFD97706),
    super.danger = const Color(0xFFDC2626),
    super.info = const Color(0xFF0C8EC7),
    super.borderColor = const Color(0x1A000000),
    super.background = const Color(0xFFF4F5F6),
    super.fillColor = const Color(0xFFF4F5F6),
    super.muted = const Color(0xFFF1F2F4),
    super.mutedForeground = const Color(0xFF9CA0A6),
    super.accent = const Color(0xFFF1F2F4),
    super.accentForeground = const Color(0xFF31302E),
    super.ring = const Color(0xFF097FE8),
    super.cardBorder = const Color(0x1A000000),
    super.controlFill = const Color(0xFFECEEF0),
  });

  @override
  List<BoxShadow> get cardShadow => _kLightCardShadow;

  @override
  List<BoxShadow> get cardShadowSoft => _kLightCardShadowSoft;

  @override
  List<BoxShadow> get popoverShadow => _kLightPopoverShadow;
}

class DarkModeTheme extends CLTheme {
  const DarkModeTheme({
    super.primary = const Color(0xFF3BA8D8),
    super.secondary = const Color(0xFF0C8EC7),
    // Rampa neutra quasi-neutra (filo di freddo, Apple-like): niente blu marcato
    // (#2A2A34) né caldo. Superfici grigio-neutro a livelli. Blu brand invariato.
    super.alternate = const Color(0xFF2E2F33),
    super.primaryText = const Color(0xFFE8E8EC),
    super.secondaryText = const Color(0xFF8B8F98),
    super.primaryBackground = const Color(0xFF1A1B1E),
    super.secondaryBackground = const Color(0xFF232427),
    super.tertiaryBackground = const Color(0xFF2C2D31),
    super.success = const Color(0xFF4ADE80),
    super.warning = const Color(0xFFFBBF24),
    super.danger = const Color(0xFFF87171),
    super.info = const Color(0xFF3BA8D8),
    super.borderColor = const Color(0xFF313338),
    super.background = const Color(0xFF131417),
    super.fillColor = const Color(0xFF1E1F22),
    super.muted = const Color(0xFF27282B),
    super.mutedForeground = const Color(0xFF9A9DA4),
    super.accent = const Color(0xFF27282B),
    super.accentForeground = const Color(0xFFFAFAFA),
    super.ring = const Color(0xFF3BA8D8),
    super.cardBorder = const Color(0xFF2A2B2F),
    super.controlFill = const Color(0xFF2E2F33),
  });

  @override
  Color get accentPurple => const Color(0xFFA78BFA);

  @override
  List<BoxShadow> get cardShadow => _kDarkCardShadow;

  @override
  List<BoxShadow> get cardShadowSoft => _kDarkCardShadowSoft;

  @override
  List<BoxShadow> get popoverShadow => _kDarkPopoverShadow;
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

  /// Cifre tabulari: ogni cifra stessa larghezza → colonne numeriche allineate
  /// e nessun jitter agli update (tabelle dati: ore, importi, date). Applicato
  /// ai soli stili "dato" (body/small/label/tablehead), non agli heading.
  static const _tnum = [FontFeature.tabularFigures()];

  /// Body/UI text helper (Inter — variable font locale con asse opsz)
  TextStyle _text(
    double size, {
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? lineHeight,
    List<FontFeature>? fontFeatures,
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
      fontFeatures: fontFeatures,
    );
  }

  // ── Headings — Inter (Foundation: un solo carattere) ────────────────────

  /// H1: hero titles, page intro — Inter Bold 32px (Foundation: -0.6 / lh 1.1)
  @override
  TextStyle get heading1 => _text(32, weight: FontWeight.w700, letterSpacing: -0.6, lineHeight: 1.1);

  /// H2: sezioni principali — Inter SemiBold 24px
  @override
  TextStyle get heading2 => _text(24, weight: FontWeight.w600, letterSpacing: -0.5, lineHeight: 1.2);

  /// H3: sottosezioni — Inter SemiBold 20px
  @override
  TextStyle get heading3 => _text(20, weight: FontWeight.w600, letterSpacing: -0.25, lineHeight: 1.25);

  /// H4: card headers, dialog titles — Inter Medium 17px
  @override
  TextStyle get heading4 => _text(17, weight: FontWeight.w500, letterSpacing: -0.15, lineHeight: 1.3);

  /// H5: etichette di sezione — Inter Medium 14px
  @override
  TextStyle get heading5 => _text(14, weight: FontWeight.w500, letterSpacing: -0.05, lineHeight: 1.35);

  /// H6: micro-heading — Inter Medium 13px
  @override
  TextStyle get heading6 => _text(13, weight: FontWeight.w500, lineHeight: 1.4);

  // ── Body / UI ────────────────────────────────────────────────────────────

  /// Titolo UI (pulsanti, tab, menu item) — Inter Medium 15px (Foundation: no tracking)
  @override
  TextStyle get title => _text(15, weight: FontWeight.w500, lineHeight: 1.4);

  /// Sottotitolo descrittivo — Inter Regular 14px
  @override
  TextStyle get subTitle => _text(14, weight: FontWeight.w400, lineHeight: 1.5);

  /// Corpo testo principale — Inter Regular 14px, interlinea aperta
  @override
  TextStyle get bodyText => _text(14, weight: FontWeight.w400, lineHeight: 1.6, fontFeatures: _tnum);

  /// Testo piccolo — Inter Regular 12px
  @override
  TextStyle get smallText => _text(12, weight: FontWeight.w400, lineHeight: 1.5, fontFeatures: _tnum);

  /// Label UI secondaria — Inter Regular 13px, colore secondario
  @override
  TextStyle get bodyLabel =>
      _text(13, weight: FontWeight.w400, color: theme.secondaryText, lineHeight: 1.5, fontFeatures: _tnum);

  /// Intestazione colonna tabella — Inter Medium 11px, spaziatura lettere positiva
  @override
  TextStyle get bodyLabelTableHead => _text(11,
      weight: FontWeight.w500, color: theme.secondaryText, letterSpacing: 0.3, lineHeight: 1.4, fontFeatures: _tnum);

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
