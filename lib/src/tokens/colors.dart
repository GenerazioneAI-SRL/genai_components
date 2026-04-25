import 'package:flutter/material.dart';

/// Primitive color palette for the v3 design system — Forma LMS.
///
/// Translated verbatim from the CSS `:root` block of the LMS Dashboard v3
/// reference HTML (`docs/DESIGN_SYSTEM_V3.md` §2.1 / §2.2). DO NOT use these
/// directly in components — components consume semantic tokens via
/// `context.colors` (see [GenaiColorTokens]).
///
/// v3 is **light-only** in v3.0; dark mode is deferred to v3.1.
class GenaiColorsPrimitive {
  GenaiColorsPrimitive._();

  // ─── Surface + ink ramp ───────────────────────────────────────────────────
  /// `--bg` — page background (warm cool neutral).
  static const Color bg = Color(0xFFF6F7F9);

  /// `--panel` — card / surface white.
  static const Color panel = Color(0xFFFFFFFF);

  /// `--ink` — primary text (near-black).
  static const Color ink = Color(0xFF0D1220);

  /// Hover variant of [ink] — used for ink-primary CTA hover.
  ///
  /// Not in the CSS `:root` block; matches the inline hover declared in
  /// `.cta[data-ink="1"]:hover` and in §6 preset spec.
  static const Color inkHover = Color(0xFF1E2642);

  /// `--ink-2` — secondary text.
  static const Color ink2 = Color(0xFF4A5268);

  /// `--ink-3` — tertiary / disabled text.
  static const Color ink3 = Color(0xFF8891A3);

  /// `--line` — default hairline border.
  static const Color line = Color(0xFFE6E9EF);

  /// `--line-2` — strong border (outline buttons, ask-bar).
  static const Color line2 = Color(0xFFD6DAE3);

  // ─── Semantic quartet + neutral (base / soft) ─────────────────────────────
  /// `--ok` — success base.
  static const Color ok = Color(0xFF0A7D50);

  /// `--ok-soft` — success tinted surface.
  static const Color okSoft = Color(0xFFE3F4EC);

  /// `--warn` — warning base.
  static const Color warn = Color(0xFFA35F00);

  /// `--warn-soft` — warning tinted surface.
  static const Color warnSoft = Color(0xFFFDF1DF);

  /// `--danger` — danger base.
  static const Color danger = Color(0xFFB3261E);

  /// `--danger-soft` — danger tinted surface.
  static const Color dangerSoft = Color(0xFFFCE8E6);

  /// `--info` — info base (also primary accent + focus ring in v3).
  static const Color info = Color(0xFF0B5FD9);

  /// `--info-soft` — info tinted surface.
  static const Color infoSoft = Color(0xFFE5EFFC);

  /// `--neutral` — neutral base (muted label, quiet chip).
  static const Color neutral = Color(0xFF5A6277);

  /// `--neutral-soft` — neutral tinted surface (hover bg, kbd pill, sidebar).
  static const Color neutralSoft = Color(0xFFEEF0F4);

  /// `--focus` — focus ring color (identical to [info] per spec §2.2).
  static const Color focus = Color(0xFF0B5FD9);

  // ─── Dark companion ramp (added in v3.1 for color presets) ────────────────
  // The Forma LMS spec is light-first; these dark equivalents back the new
  // dark presets (formaAurora / formaShadcnDark) without altering the canonical
  // Forma look. They mirror the light ramp's role assignments on a dark base.

  /// Dark page background — near-black, slight blue cast to match ink.
  static const Color bgDark = Color(0xFF0B0F1A);

  /// Dark card / panel surface.
  static const Color panelDark = Color(0xFF141926);

  /// Dark inverse ink — paper white for primary text on dark.
  static const Color inkDark = Color(0xFFE6E9EF);

  /// Dark hover variant of [inkDark] — for inverted ink CTA hover.
  static const Color inkDarkHover = Color(0xFFFFFFFF);

  /// Dark secondary text.
  static const Color ink2Dark = Color(0xFFA1A8B8);

  /// Dark tertiary / disabled text.
  static const Color ink3Dark = Color(0xFF6B7385);

  /// Dark hairline border.
  static const Color lineDark = Color(0xFF242A38);

  /// Dark strong border.
  static const Color line2Dark = Color(0xFF353C4D);

  /// Dark neutral-soft (hover bg, sidebar tint).
  static const Color neutralSoftDark = Color(0xFF1B2130);
}

/// Semantic color tokens — the only colors v3 components should reference.
///
/// Class name matches v1 / v2 (`GenaiColorTokens`) so consumers can swap
/// libraries by changing the import alias. Shape is tuned for Forma LMS:
///
/// - Primary CTA is **ink-black** (`#0d1220`), not the info blue. Info remains
///   the focus-ring + link + informational accent color.
/// - All semantic intents expose a `base` + `soft` pair per §2.2. No
///   `Hover` / `Pressed` stops beyond ink — v3 HTML rarely tints semantic
///   fills, relying on base+soft plus label+icon pairing for contrast.
/// - `borderSubtle` / `borderDefault` / `borderStrong` mirror `--line` /
///   `--line` / `--line-2`.
@immutable
class GenaiColorTokens {
  // ─── Surfaces ────────────────────────────────────────────────────────────
  /// Deepest background layer (behind [surfacePage]). In light-only v3 this
  /// equals [surfacePage]; reserved for future dark-mode parity.
  final Color surfaceDeepest;

  /// Page background — `--bg`.
  final Color surfacePage;

  /// Card / grouped content — `--panel`.
  final Color surfaceCard;

  /// Input / text-field background — `--panel`.
  final Color surfaceInput;

  /// Popover / menu overlay — `--panel`.
  final Color surfaceOverlay;

  /// Modal dialog content — `--panel`.
  final Color surfaceModal;

  /// Sidebar / navigation chrome — `--panel` in v3 (`--neutral-soft` is used
  /// inline for row hovers, not as rail bg).
  final Color surfaceSidebar;

  /// Row/button hover tint — `--neutral-soft`.
  final Color surfaceHover;

  /// Row/button pressed tint — slightly stronger than hover. Not in CSS vars;
  /// derived from `rgba(13,18,32,.06)` (ink @ 6%).
  final Color surfacePressed;

  /// Inverse surface — toast, tooltip chip background. Uses `--ink`.
  final Color surfaceInverse;

  // ─── Borders ─────────────────────────────────────────────────────────────
  /// Subtle divider inside cards — `--line`.
  final Color borderSubtle;

  /// Default component border (inputs, cards) — `--line`.
  final Color borderDefault;

  /// Strong border (button outline, ask-bar) — `--line-2`.
  final Color borderStrong;

  /// Focus ring color — `--focus` (= `--info`).
  final Color borderFocus;

  // ─── Text ────────────────────────────────────────────────────────────────
  /// Primary text — `--ink`.
  final Color textPrimary;

  /// Secondary text — `--ink-2`.
  final Color textSecondary;

  /// Tertiary text (captions, meta) — `--ink-3`.
  final Color textTertiary;

  /// Disabled text — same token as [textTertiary] (`--ink-3`). v3 HTML uses
  /// a single low-contrast step for both.
  final Color textDisabled;

  /// Text painted on top of [colorPrimary] (ink CTA) — white.
  final Color textOnPrimary;

  /// Text painted on top of [surfaceInverse] (toast over ink) — white.
  final Color textOnInverse;

  /// Hyperlink color — `--info`.
  final Color textLink;

  // ─── Brand accent (primary CTA = ink-black) ──────────────────────────────
  /// Primary CTA base — ink `#0d1220` per §6 preset.
  final Color colorPrimary;

  /// Primary CTA hover — `#1e2642`.
  final Color colorPrimaryHover;

  /// Primary CTA pressed — same as [colorPrimary] (no additional stop in v3).
  final Color colorPrimaryPressed;

  /// Low-contrast accent tint for backgrounds (selected rows) — `--info-soft`.
  /// Components should prefer the info quartet for tinted accents; this alias
  /// exists for API parity with v2.
  final Color colorPrimarySubtle;

  /// Readable accent text on tinted surfaces — `--info`.
  final Color colorPrimaryText;

  // ─── Semantic quartet (base + soft + textOn{Base,Soft}) ─────────────────
  // v3 shape: each intent ships a `base` fill and a `soft` tinted-surface
  // variant. `Hover` stops intentionally omitted — §2.6 keeps hover deltas
  // to border-color changes, not fill shifts.
  final Color colorSuccess;
  final Color colorSuccessSubtle;
  final Color colorSuccessText;

  final Color colorWarning;
  final Color colorWarningSubtle;
  final Color colorWarningText;

  final Color colorDanger;
  final Color colorDangerSubtle;
  final Color colorDangerText;

  final Color colorInfo;
  final Color colorInfoSubtle;
  final Color colorInfoText;

  final Color colorNeutral;
  final Color colorNeutralSubtle;
  final Color colorNeutralText;

  // ─── Scrims ──────────────────────────────────────────────────────────────
  /// Modal backdrop — ink @ 40%.
  final Color scrimModal;

  /// Drawer backdrop — ink @ 60%.
  final Color scrimDrawer;

  // ── v1 backward-compat aliases (deprecated; use canonical v3 names) ────
  /// Deprecated alias for [colorDanger]. Removed in v6.
  Color get colorError => colorDanger;

  /// Deprecated alias for [colorDangerSubtle]. Removed in v6.
  Color get colorErrorSubtle => colorDangerSubtle;

  /// Deprecated alias for [colorDanger]. Removed in v6.
  Color get colorErrorHover => colorDanger;

  /// Deprecated alias for [colorDanger]. Removed in v6.
  Color get textError => colorDanger;

  /// Deprecated alias for [borderStrong]. Removed in v6.
  Color get borderError => colorDanger;

  /// Deprecated alias for [borderStrong]. Removed in v6.
  Color get borderSuccess => colorSuccess;

  const GenaiColorTokens({
    required this.surfaceDeepest,
    required this.surfacePage,
    required this.surfaceCard,
    required this.surfaceInput,
    required this.surfaceOverlay,
    required this.surfaceModal,
    required this.surfaceSidebar,
    required this.surfaceHover,
    required this.surfacePressed,
    required this.surfaceInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textOnInverse,
    required this.textLink,
    required this.colorPrimary,
    required this.colorPrimaryHover,
    required this.colorPrimaryPressed,
    required this.colorPrimarySubtle,
    required this.colorPrimaryText,
    required this.colorSuccess,
    required this.colorSuccessSubtle,
    required this.colorSuccessText,
    required this.colorWarning,
    required this.colorWarningSubtle,
    required this.colorWarningText,
    required this.colorDanger,
    required this.colorDangerSubtle,
    required this.colorDangerText,
    required this.colorInfo,
    required this.colorInfoSubtle,
    required this.colorInfoText,
    required this.colorNeutral,
    required this.colorNeutralSubtle,
    required this.colorNeutralText,
    required this.scrimModal,
    required this.scrimDrawer,
  });

  /// Canonical light Forma LMS palette — verbatim from `Dashboard v3.html`.
  factory GenaiColorTokens.defaultLight() => const GenaiColorTokens(
        // Surfaces
        surfaceDeepest: GenaiColorsPrimitive.bg,
        surfacePage: GenaiColorsPrimitive.bg,
        surfaceCard: GenaiColorsPrimitive.panel,
        surfaceInput: GenaiColorsPrimitive.panel,
        surfaceOverlay: GenaiColorsPrimitive.panel,
        surfaceModal: GenaiColorsPrimitive.panel,
        surfaceSidebar: GenaiColorsPrimitive.panel,
        surfaceHover: GenaiColorsPrimitive.neutralSoft,
        surfacePressed: Color(0x0F0D1220), // ink @ 6%
        surfaceInverse: GenaiColorsPrimitive.ink,
        // Borders
        borderSubtle: GenaiColorsPrimitive.line,
        borderDefault: GenaiColorsPrimitive.line,
        borderStrong: GenaiColorsPrimitive.line2,
        borderFocus: GenaiColorsPrimitive.focus,
        // Text
        textPrimary: GenaiColorsPrimitive.ink,
        textSecondary: GenaiColorsPrimitive.ink2,
        textTertiary: GenaiColorsPrimitive.ink3,
        textDisabled: GenaiColorsPrimitive.ink3,
        textOnPrimary: GenaiColorsPrimitive.panel,
        textOnInverse: GenaiColorsPrimitive.panel,
        textLink: GenaiColorsPrimitive.info,
        // Primary accent — ink, per §6
        colorPrimary: GenaiColorsPrimitive.ink,
        colorPrimaryHover: GenaiColorsPrimitive.inkHover,
        colorPrimaryPressed: GenaiColorsPrimitive.ink,
        colorPrimarySubtle: GenaiColorsPrimitive.infoSoft,
        colorPrimaryText: GenaiColorsPrimitive.info,
        // Semantic — verbatim from CSS vars
        colorSuccess: GenaiColorsPrimitive.ok,
        colorSuccessSubtle: GenaiColorsPrimitive.okSoft,
        colorSuccessText: GenaiColorsPrimitive.ok,
        colorWarning: GenaiColorsPrimitive.warn,
        colorWarningSubtle: GenaiColorsPrimitive.warnSoft,
        colorWarningText: GenaiColorsPrimitive.warn,
        colorDanger: GenaiColorsPrimitive.danger,
        colorDangerSubtle: GenaiColorsPrimitive.dangerSoft,
        colorDangerText: GenaiColorsPrimitive.danger,
        colorInfo: GenaiColorsPrimitive.info,
        colorInfoSubtle: GenaiColorsPrimitive.infoSoft,
        colorInfoText: GenaiColorsPrimitive.info,
        colorNeutral: GenaiColorsPrimitive.neutral,
        colorNeutralSubtle: GenaiColorsPrimitive.neutralSoft,
        colorNeutralText: GenaiColorsPrimitive.neutral,
        // Scrims
        scrimModal: Color(0x660D1220), // ink @ 40%
        scrimDrawer: Color(0x990D1220), // ink @ 60%
      );

  /// Dark companion to [defaultLight] — added in v3.1 to back the dark color
  /// presets (formaAurora / formaShadcnDark). Surfaces flip to a near-black
  /// ramp keyed off [GenaiColorsPrimitive.bgDark]; text inverts to paper. The
  /// primary CTA is paper-white (inverted ink) so the spec's "primary = ink"
  /// rule still reads as maximum-contrast on the surface.
  factory GenaiColorTokens.defaultDark() => const GenaiColorTokens(
        // Surfaces
        surfaceDeepest: GenaiColorsPrimitive.bgDark,
        surfacePage: GenaiColorsPrimitive.bgDark,
        surfaceCard: GenaiColorsPrimitive.panelDark,
        surfaceInput: GenaiColorsPrimitive.panelDark,
        surfaceOverlay: GenaiColorsPrimitive.panelDark,
        surfaceModal: GenaiColorsPrimitive.panelDark,
        surfaceSidebar: GenaiColorsPrimitive.panelDark,
        surfaceHover: GenaiColorsPrimitive.neutralSoftDark,
        surfacePressed: Color(0x1FFFFFFF), // white @ 12%
        surfaceInverse: GenaiColorsPrimitive.inkDark,
        // Borders
        borderSubtle: GenaiColorsPrimitive.lineDark,
        borderDefault: GenaiColorsPrimitive.lineDark,
        borderStrong: GenaiColorsPrimitive.line2Dark,
        borderFocus: GenaiColorsPrimitive.focus,
        // Text
        textPrimary: GenaiColorsPrimitive.inkDark,
        textSecondary: GenaiColorsPrimitive.ink2Dark,
        textTertiary: GenaiColorsPrimitive.ink3Dark,
        textDisabled: GenaiColorsPrimitive.ink3Dark,
        textOnPrimary: GenaiColorsPrimitive.bgDark,
        textOnInverse: GenaiColorsPrimitive.bgDark,
        textLink: GenaiColorsPrimitive.info,
        // Primary accent — inverted ink (paper) so CTAs read on dark surfaces
        colorPrimary: GenaiColorsPrimitive.inkDark,
        colorPrimaryHover: GenaiColorsPrimitive.inkDarkHover,
        colorPrimaryPressed: GenaiColorsPrimitive.inkDark,
        colorPrimarySubtle: Color(0x330B5FD9), // info @ 20%
        colorPrimaryText: GenaiColorsPrimitive.info,
        // Semantic — bases unchanged, subtles tinted to fit dark surfaces
        colorSuccess: GenaiColorsPrimitive.ok,
        colorSuccessSubtle: Color(0x330A7D50), // ok @ 20%
        colorSuccessText: Color(0xFF34D399), // emerald400 readable on dark
        colorWarning: GenaiColorsPrimitive.warn,
        colorWarningSubtle: Color(0x33A35F00), // warn @ 20%
        colorWarningText: Color(0xFFFBBF24), // amber400 readable on dark
        colorDanger: GenaiColorsPrimitive.danger,
        colorDangerSubtle: Color(0x33B3261E), // danger @ 20%
        colorDangerText: Color(0xFFFB7185), // rose400 readable on dark
        colorInfo: GenaiColorsPrimitive.info,
        colorInfoSubtle: Color(0x330B5FD9), // info @ 20%
        colorInfoText: Color(0xFF60A5FA), // azure400 readable on dark
        colorNeutral: GenaiColorsPrimitive.ink2Dark,
        colorNeutralSubtle: GenaiColorsPrimitive.neutralSoftDark,
        colorNeutralText: GenaiColorsPrimitive.ink2Dark,
        // Scrims
        scrimModal: Color(0x99000000),
        scrimDrawer: Color(0xB3000000),
      );

  GenaiColorTokens copyWith({
    Color? surfaceDeepest,
    Color? surfacePage,
    Color? surfaceCard,
    Color? surfaceInput,
    Color? surfaceOverlay,
    Color? surfaceModal,
    Color? surfaceSidebar,
    Color? surfaceHover,
    Color? surfacePressed,
    Color? surfaceInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? textOnInverse,
    Color? textLink,
    Color? colorPrimary,
    Color? colorPrimaryHover,
    Color? colorPrimaryPressed,
    Color? colorPrimarySubtle,
    Color? colorPrimaryText,
    Color? colorSuccess,
    Color? colorSuccessSubtle,
    Color? colorSuccessText,
    Color? colorWarning,
    Color? colorWarningSubtle,
    Color? colorWarningText,
    Color? colorDanger,
    Color? colorDangerSubtle,
    Color? colorDangerText,
    Color? colorInfo,
    Color? colorInfoSubtle,
    Color? colorInfoText,
    Color? colorNeutral,
    Color? colorNeutralSubtle,
    Color? colorNeutralText,
    Color? scrimModal,
    Color? scrimDrawer,
  }) {
    return GenaiColorTokens(
      surfaceDeepest: surfaceDeepest ?? this.surfaceDeepest,
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceModal: surfaceModal ?? this.surfaceModal,
      surfaceSidebar: surfaceSidebar ?? this.surfaceSidebar,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnInverse: textOnInverse ?? this.textOnInverse,
      textLink: textLink ?? this.textLink,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorPrimaryHover: colorPrimaryHover ?? this.colorPrimaryHover,
      colorPrimaryPressed: colorPrimaryPressed ?? this.colorPrimaryPressed,
      colorPrimarySubtle: colorPrimarySubtle ?? this.colorPrimarySubtle,
      colorPrimaryText: colorPrimaryText ?? this.colorPrimaryText,
      colorSuccess: colorSuccess ?? this.colorSuccess,
      colorSuccessSubtle: colorSuccessSubtle ?? this.colorSuccessSubtle,
      colorSuccessText: colorSuccessText ?? this.colorSuccessText,
      colorWarning: colorWarning ?? this.colorWarning,
      colorWarningSubtle: colorWarningSubtle ?? this.colorWarningSubtle,
      colorWarningText: colorWarningText ?? this.colorWarningText,
      colorDanger: colorDanger ?? this.colorDanger,
      colorDangerSubtle: colorDangerSubtle ?? this.colorDangerSubtle,
      colorDangerText: colorDangerText ?? this.colorDangerText,
      colorInfo: colorInfo ?? this.colorInfo,
      colorInfoSubtle: colorInfoSubtle ?? this.colorInfoSubtle,
      colorInfoText: colorInfoText ?? this.colorInfoText,
      colorNeutral: colorNeutral ?? this.colorNeutral,
      colorNeutralSubtle: colorNeutralSubtle ?? this.colorNeutralSubtle,
      colorNeutralText: colorNeutralText ?? this.colorNeutralText,
      scrimModal: scrimModal ?? this.scrimModal,
      scrimDrawer: scrimDrawer ?? this.scrimDrawer,
    );
  }

  static GenaiColorTokens lerp(
      GenaiColorTokens a, GenaiColorTokens b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return GenaiColorTokens(
      surfaceDeepest: c(a.surfaceDeepest, b.surfaceDeepest),
      surfacePage: c(a.surfacePage, b.surfacePage),
      surfaceCard: c(a.surfaceCard, b.surfaceCard),
      surfaceInput: c(a.surfaceInput, b.surfaceInput),
      surfaceOverlay: c(a.surfaceOverlay, b.surfaceOverlay),
      surfaceModal: c(a.surfaceModal, b.surfaceModal),
      surfaceSidebar: c(a.surfaceSidebar, b.surfaceSidebar),
      surfaceHover: c(a.surfaceHover, b.surfaceHover),
      surfacePressed: c(a.surfacePressed, b.surfacePressed),
      surfaceInverse: c(a.surfaceInverse, b.surfaceInverse),
      borderSubtle: c(a.borderSubtle, b.borderSubtle),
      borderDefault: c(a.borderDefault, b.borderDefault),
      borderStrong: c(a.borderStrong, b.borderStrong),
      borderFocus: c(a.borderFocus, b.borderFocus),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textTertiary: c(a.textTertiary, b.textTertiary),
      textDisabled: c(a.textDisabled, b.textDisabled),
      textOnPrimary: c(a.textOnPrimary, b.textOnPrimary),
      textOnInverse: c(a.textOnInverse, b.textOnInverse),
      textLink: c(a.textLink, b.textLink),
      colorPrimary: c(a.colorPrimary, b.colorPrimary),
      colorPrimaryHover: c(a.colorPrimaryHover, b.colorPrimaryHover),
      colorPrimaryPressed: c(a.colorPrimaryPressed, b.colorPrimaryPressed),
      colorPrimarySubtle: c(a.colorPrimarySubtle, b.colorPrimarySubtle),
      colorPrimaryText: c(a.colorPrimaryText, b.colorPrimaryText),
      colorSuccess: c(a.colorSuccess, b.colorSuccess),
      colorSuccessSubtle: c(a.colorSuccessSubtle, b.colorSuccessSubtle),
      colorSuccessText: c(a.colorSuccessText, b.colorSuccessText),
      colorWarning: c(a.colorWarning, b.colorWarning),
      colorWarningSubtle: c(a.colorWarningSubtle, b.colorWarningSubtle),
      colorWarningText: c(a.colorWarningText, b.colorWarningText),
      colorDanger: c(a.colorDanger, b.colorDanger),
      colorDangerSubtle: c(a.colorDangerSubtle, b.colorDangerSubtle),
      colorDangerText: c(a.colorDangerText, b.colorDangerText),
      colorInfo: c(a.colorInfo, b.colorInfo),
      colorInfoSubtle: c(a.colorInfoSubtle, b.colorInfoSubtle),
      colorInfoText: c(a.colorInfoText, b.colorInfoText),
      colorNeutral: c(a.colorNeutral, b.colorNeutral),
      colorNeutralSubtle: c(a.colorNeutralSubtle, b.colorNeutralSubtle),
      colorNeutralText: c(a.colorNeutralText, b.colorNeutralText),
      scrimModal: c(a.scrimModal, b.scrimModal),
      scrimDrawer: c(a.scrimDrawer, b.scrimDrawer),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiColorTokens &&
          runtimeType == other.runtimeType &&
          surfaceDeepest == other.surfaceDeepest &&
          surfacePage == other.surfacePage &&
          surfaceCard == other.surfaceCard &&
          surfaceInput == other.surfaceInput &&
          surfaceOverlay == other.surfaceOverlay &&
          surfaceModal == other.surfaceModal &&
          surfaceSidebar == other.surfaceSidebar &&
          surfaceHover == other.surfaceHover &&
          surfacePressed == other.surfacePressed &&
          surfaceInverse == other.surfaceInverse &&
          borderSubtle == other.borderSubtle &&
          borderDefault == other.borderDefault &&
          borderStrong == other.borderStrong &&
          borderFocus == other.borderFocus &&
          textPrimary == other.textPrimary &&
          textSecondary == other.textSecondary &&
          textTertiary == other.textTertiary &&
          textDisabled == other.textDisabled &&
          textOnPrimary == other.textOnPrimary &&
          textOnInverse == other.textOnInverse &&
          textLink == other.textLink &&
          colorPrimary == other.colorPrimary &&
          colorPrimaryHover == other.colorPrimaryHover &&
          colorPrimaryPressed == other.colorPrimaryPressed &&
          colorPrimarySubtle == other.colorPrimarySubtle &&
          colorPrimaryText == other.colorPrimaryText &&
          colorSuccess == other.colorSuccess &&
          colorSuccessSubtle == other.colorSuccessSubtle &&
          colorSuccessText == other.colorSuccessText &&
          colorWarning == other.colorWarning &&
          colorWarningSubtle == other.colorWarningSubtle &&
          colorWarningText == other.colorWarningText &&
          colorDanger == other.colorDanger &&
          colorDangerSubtle == other.colorDangerSubtle &&
          colorDangerText == other.colorDangerText &&
          colorInfo == other.colorInfo &&
          colorInfoSubtle == other.colorInfoSubtle &&
          colorInfoText == other.colorInfoText &&
          colorNeutral == other.colorNeutral &&
          colorNeutralSubtle == other.colorNeutralSubtle &&
          colorNeutralText == other.colorNeutralText &&
          scrimModal == other.scrimModal &&
          scrimDrawer == other.scrimDrawer;

  @override
  int get hashCode => Object.hashAll([
        surfaceDeepest,
        surfacePage,
        surfaceCard,
        surfaceInput,
        surfaceOverlay,
        surfaceModal,
        surfaceSidebar,
        surfaceHover,
        surfacePressed,
        surfaceInverse,
        borderSubtle,
        borderDefault,
        borderStrong,
        borderFocus,
        textPrimary,
        textSecondary,
        textTertiary,
        textDisabled,
        textOnPrimary,
        textOnInverse,
        textLink,
        colorPrimary,
        colorPrimaryHover,
        colorPrimaryPressed,
        colorPrimarySubtle,
        colorPrimaryText,
        colorSuccess,
        colorSuccessSubtle,
        colorSuccessText,
        colorWarning,
        colorWarningSubtle,
        colorWarningText,
        colorDanger,
        colorDangerSubtle,
        colorDangerText,
        colorInfo,
        colorInfoSubtle,
        colorInfoText,
        colorNeutral,
        colorNeutralSubtle,
        colorNeutralText,
        scrimModal,
        scrimDrawer,
      ]);
}
