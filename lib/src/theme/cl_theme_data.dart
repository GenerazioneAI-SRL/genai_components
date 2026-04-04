import 'package:flutter/material.dart';

/// Theme data for CL Components.
///
/// Every token has a sensible default. Projects override only what they need.
///
/// ```dart
/// CLThemeProvider(
///   theme: CLThemeData(
///     primary: Color(0xFFE11D48),  // custom primary
///     displayFontFamily: 'Poppins',
///   ),
///   child: app,
/// )
/// ```
class CLThemeData {
  // ── Colors ──
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color text;
  final Color textSecondary;
  final Color background;
  final Color surface;
  final Color border;
  final Color borderLight;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  // ── Typography ──
  final String displayFontFamily;
  final String bodyFontFamily;

  // ── Radius ──
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;

  // ── Spacing ──
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  const CLThemeData({
    this.primary = const Color(0xFF0C8EC7),
    this.primaryDark = const Color(0xFF0A7AAD),
    this.secondary = const Color(0xFF0A7AAD),
    this.text = const Color(0xFF2E2E38),
    this.textSecondary = const Color(0xFF6B7080),
    this.background = const Color(0xFFFAF9F7),
    this.surface = const Color(0xFFFFFFFF),
    this.border = const Color(0xFFE8EBF0),
    this.borderLight = const Color(0xFFF0F1F4),
    this.success = const Color(0xFF16A34A),
    this.warning = const Color(0xFFD97706),
    this.danger = const Color(0xFFDC2626),
    this.info = const Color(0xFF0C8EC7),
    this.displayFontFamily = 'Plus Jakarta Sans',
    this.bodyFontFamily = 'Inter',
    this.radiusSm = 6,
    this.radiusMd = 8,
    this.radiusLg = 16,
    this.radiusXl = 20,
    this.radiusFull = 999,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 20,
    this.xxl = 24,
    this.xxxl = 32,
  });

  /// Create a copy with some values overridden.
  CLThemeData copyWith({
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? text,
    Color? textSecondary,
    Color? background,
    Color? surface,
    Color? border,
    Color? borderLight,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    String? displayFontFamily,
    String? bodyFontFamily,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return CLThemeData(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      displayFontFamily: displayFontFamily ?? this.displayFontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  /// Generate a color from text (for avatars, etc.)
  Color generateColorFromText(String text) {
    final int hash = text.hashCode;
    final r = 100 + (hash & 0xFF) % 156;
    final g = 100 + ((hash >> 8) & 0xFF) % 156;
    final b = 100 + ((hash >> 16) & 0xFF) % 156;
    return Color.fromARGB(255, r, g, b);
  }
}
