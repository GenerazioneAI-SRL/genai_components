import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// CLTheme-shaped accessor over the Shad theme, so the migrated custom widgets
/// (CLAdaptiveShell, …) keep reading `theme.X` with minimal edits: colors come
/// from [ShadColorScheme], spacing/sizes are constants, text styles map to
/// [ShadTextTheme]. Get it with `CLShellTokens.of(context)`.
class CLShellTokens {
  CLShellTokens._(this._cs, this.brightness);

  factory CLShellTokens.of(BuildContext context) {
    final t = ShadTheme.of(context);
    return CLShellTokens._(t.colorScheme, t.brightness);
  }

  final ShadColorScheme _cs;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  // ── Colors (mapped to ShadColorScheme) ──────────────────────────────────────
  Color get primary => _cs.primary;
  Color get primaryForeground => _cs.primaryForeground; // contenuto su sfondo primary (bianco)
  Color get primaryText => _cs.foreground;
  Color get secondaryText => _cs.mutedForeground;
  Color get primaryBackground => _cs.muted; // canvas grigio (menu/shell)
  Color get secondaryBackground => _cs.card; // superficie bianca (bolle/card)
  Color get borderColor => _cs.border;

  // ── Spacing / sizes (constants) ─────────────────────────────────────────────
  double get gapXs => 4;
  double get gapSm => 8;
  double get gapMd => 12;
  double get gapLg => 16;
  double get buttonHeightDefault => 40;
  double get inputHeight => 40;
  double get iconSizeDefault => 20;
  double get radiusPill => 9999;
  double get radiusBubble => 28;

  // ── Opacity (from CLTheme) ──────────────────────────────────────────────────
  double get opacitySoft => 0.10;
  double get opacityMuted => 0.14;

  // ── Shadow ──────────────────────────────────────────────────────────────────
  List<BoxShadow> get cardShadowSoft => isDark
      ? const [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))]
      : const [BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1))];

  /// Glow colorato brand (bottone AI/primario con gradient): alone [primary].
  List<BoxShadow> get primaryGlow => [
        BoxShadow(color: primary.withValues(alpha: 0.4), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 2)),
      ];

  // ── Text styles (Inter + CL sizes/weights) ──────────────────────────────────
  TextStyle _text(double size, FontWeight w, double h, Color color, {double? ls}) => TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: w,
        height: h,
        letterSpacing: ls,
        color: color,
      );

  TextStyle get heading1 => _text(32, FontWeight.w700, 1.1, _cs.foreground, ls: -0.6);
  TextStyle get heading2 => _text(24, FontWeight.w600, 1.2, _cs.foreground, ls: -0.5);
  TextStyle get heading4 => _text(17, FontWeight.w500, 1.3, _cs.foreground, ls: -0.15);
  TextStyle get heading5 => _text(14, FontWeight.w500, 1.35, _cs.foreground, ls: -0.05);
  TextStyle get title => _text(15, FontWeight.w500, 1.4, _cs.foreground);
  TextStyle get bodyText => _text(14, FontWeight.w400, 1.6, _cs.foreground);
  TextStyle get bodyLabel => _text(13, FontWeight.w500, 1.4, _cs.mutedForeground);
  TextStyle get smallText => _text(12, FontWeight.w400, 1.5, _cs.mutedForeground);
  TextStyle get smallLabel => _text(12, FontWeight.w400, 1.4, _cs.mutedForeground);

  // ── Extra colors (datatable et al) ──────────────────────────────────────────
  Color get danger => _cs.destructive;
  Color get secondary => _cs.secondary;
  Color get accent => _cs.accent;
  Color get accentForeground => _cs.accentForeground;
  Color get muted => _cs.muted;
  Color get mutedForeground => _cs.mutedForeground;
  Color get controlFill => _cs.muted;
  Color get tertiaryBackground => _cs.muted;
  Color get cardBorder => _cs.border;

  // ── Extra sizes ─────────────────────────────────────────────────────────────
  double get buttonHeightCompact => 32;
  double get iconSizeCompact => 16;
  double get gapIconText => 6;
  double get pagePadX => 20;
  double get radiusControl => 12;
  double get radiusCard => 18;
  double get radiusChip => 6;
  double get radiusSurface => 14;
  double get radiusModal => 28;

  // ── Opacity ─────────────────────────────────────────────────────────────────
  double get opacityDisabled => 0.50;
  double get opacityMedium => 0.20;
  double get opacitySubtle => 0.06;

  // ── Duration ────────────────────────────────────────────────────────────────
  Duration get durationBase => const Duration(milliseconds: 200);
  Duration get durationSlow => const Duration(milliseconds: 300);

  // ── Shadow ──────────────────────────────────────────────────────────────────
  List<BoxShadow> get popoverShadow => const [
        BoxShadow(color: Color(0x38000000), blurRadius: 28, spreadRadius: -6, offset: Offset(0, 12)),
      ];
}
