import 'package:flutter/material.dart';

/// Primitive color palette — DO NOT use directly in components.
/// Components must reference [GenaiColorTokens] semantic tokens.
class GenaiColorsPrimitive {
  GenaiColorsPrimitive._();

  // Primary (brand)
  static const primary50 = Color(0xFFEFF6FF);
  static const primary100 = Color(0xFFDBEAFE);
  static const primary200 = Color(0xFFBFDBFE);
  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF2563EB);
  static const primary600 = Color(0xFF1D4ED8);
  static const primary700 = Color(0xFF1E40AF);
  static const primary800 = Color(0xFF1E3A8A);
  static const primary900 = Color(0xFF172554);

  // Neutral
  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral700 = Color(0xFF374151);
  static const neutral800 = Color(0xFF1F2937);
  static const neutral850 = Color(0xFF18212F);
  static const neutral900 = Color(0xFF111827);
  static const neutral950 = Color(0xFF030712);

  // Success
  static const success50 = Color(0xFFECFDF5);
  static const success100 = Color(0xFFD1FAE5);
  static const success200 = Color(0xFFA7F3D0);
  static const success300 = Color(0xFF6EE7B7);
  static const success400 = Color(0xFF34D399);
  static const success500 = Color(0xFF10B981);
  static const success600 = Color(0xFF059669);
  static const success700 = Color(0xFF047857);
  static const success800 = Color(0xFF065F46);
  static const success900 = Color(0xFF064E3B);

  // Warning
  static const warning50 = Color(0xFFFFFBEB);
  static const warning100 = Color(0xFFFEF3C7);
  static const warning200 = Color(0xFFFDE68A);
  static const warning300 = Color(0xFFFCD34D);
  static const warning400 = Color(0xFFFBBF24);
  static const warning500 = Color(0xFFF59E0B);
  static const warning600 = Color(0xFFD97706);
  static const warning700 = Color(0xFFB45309);
  static const warning800 = Color(0xFF92400E);
  static const warning900 = Color(0xFF78350F);

  // Error
  static const error50 = Color(0xFFFEF2F2);
  static const error100 = Color(0xFFFEE2E2);
  static const error200 = Color(0xFFFECACA);
  static const error300 = Color(0xFFFCA5A5);
  static const error400 = Color(0xFFF87171);
  static const error500 = Color(0xFFEF4444);
  static const error600 = Color(0xFFDC2626);
  static const error700 = Color(0xFFB91C1C);
  static const error800 = Color(0xFF991B1B);
  static const error900 = Color(0xFF7F1D1D);

  // Info
  static const info50 = Color(0xFFEFF6FF);
  static const info100 = Color(0xFFDBEAFE);
  static const info200 = Color(0xFFBFDBFE);
  static const info300 = Color(0xFF93C5FD);
  static const info400 = Color(0xFF60A5FA);
  static const info500 = Color(0xFF3B82F6);
  static const info600 = Color(0xFF2563EB);
  static const info700 = Color(0xFF1D4ED8);
  static const info800 = Color(0xFF1E40AF);
  static const info900 = Color(0xFF1E3A8A);
}

/// Semantic color tokens — the only colors components should reference.
@immutable
class GenaiColorTokens {
  // Brand
  final Color colorPrimary;
  final Color colorPrimaryHover;
  final Color colorPrimaryPressed;
  final Color colorPrimarySubtle;

  // Surfaces
  final Color surfacePage;
  final Color surfaceCard;
  final Color surfaceInput;
  final Color surfaceOverlay;
  final Color surfaceSidebar;
  final Color surfaceHover;
  final Color surfacePressed;

  // Borders
  final Color borderDefault;
  final Color borderStrong;
  final Color borderFocus;
  final Color borderError;
  final Color borderSuccess;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textLink;
  final Color textError;
  final Color textSuccess;
  final Color textWarning;

  // Semantic
  final Color colorSuccess;
  final Color colorSuccessHover;
  final Color colorWarning;
  final Color colorWarningHover;
  final Color colorError;
  final Color colorErrorHover;
  final Color colorInfo;
  final Color colorInfoHover;

  final Color colorSuccessSubtle;
  final Color colorWarningSubtle;
  final Color colorErrorSubtle;
  final Color colorInfoSubtle;

  const GenaiColorTokens({
    required this.colorPrimary,
    required this.colorPrimaryHover,
    required this.colorPrimaryPressed,
    required this.colorPrimarySubtle,
    required this.surfacePage,
    required this.surfaceCard,
    required this.surfaceInput,
    required this.surfaceOverlay,
    required this.surfaceSidebar,
    required this.surfaceHover,
    required this.surfacePressed,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.borderError,
    required this.borderSuccess,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textLink,
    required this.textError,
    required this.textSuccess,
    required this.textWarning,
    required this.colorSuccess,
    required this.colorSuccessHover,
    required this.colorWarning,
    required this.colorWarningHover,
    required this.colorError,
    required this.colorErrorHover,
    required this.colorInfo,
    required this.colorInfoHover,
    required this.colorSuccessSubtle,
    required this.colorWarningSubtle,
    required this.colorErrorSubtle,
    required this.colorInfoSubtle,
  });

  factory GenaiColorTokens.defaultLight() => const GenaiColorTokens(
        colorPrimary: GenaiColorsPrimitive.primary500,
        colorPrimaryHover: GenaiColorsPrimitive.primary600,
        colorPrimaryPressed: GenaiColorsPrimitive.primary700,
        colorPrimarySubtle: GenaiColorsPrimitive.primary50,
        surfacePage: GenaiColorsPrimitive.neutral50,
        surfaceCard: Colors.white,
        surfaceInput: Colors.white,
        surfaceOverlay: Colors.white,
        surfaceSidebar: Colors.white,
        surfaceHover: GenaiColorsPrimitive.neutral100,
        surfacePressed: GenaiColorsPrimitive.neutral200,
        borderDefault: GenaiColorsPrimitive.neutral200,
        borderStrong: GenaiColorsPrimitive.neutral300,
        borderFocus: GenaiColorsPrimitive.primary500,
        borderError: GenaiColorsPrimitive.error500,
        borderSuccess: GenaiColorsPrimitive.success500,
        textPrimary: GenaiColorsPrimitive.neutral900,
        textSecondary: GenaiColorsPrimitive.neutral500,
        textDisabled: GenaiColorsPrimitive.neutral300,
        textOnPrimary: Colors.white,
        textLink: GenaiColorsPrimitive.primary600,
        textError: GenaiColorsPrimitive.error600,
        textSuccess: GenaiColorsPrimitive.success600,
        textWarning: GenaiColorsPrimitive.warning600,
        colorSuccess: GenaiColorsPrimitive.success500,
        colorSuccessHover: GenaiColorsPrimitive.success600,
        colorWarning: GenaiColorsPrimitive.warning500,
        colorWarningHover: GenaiColorsPrimitive.warning600,
        colorError: GenaiColorsPrimitive.error500,
        colorErrorHover: GenaiColorsPrimitive.error600,
        colorInfo: GenaiColorsPrimitive.info500,
        colorInfoHover: GenaiColorsPrimitive.info600,
        colorSuccessSubtle: GenaiColorsPrimitive.success50,
        colorWarningSubtle: GenaiColorsPrimitive.warning50,
        colorErrorSubtle: GenaiColorsPrimitive.error50,
        colorInfoSubtle: GenaiColorsPrimitive.info50,
      );

  factory GenaiColorTokens.defaultDark() => const GenaiColorTokens(
        colorPrimary: GenaiColorsPrimitive.primary400,
        colorPrimaryHover: GenaiColorsPrimitive.primary300,
        colorPrimaryPressed: GenaiColorsPrimitive.primary200,
        colorPrimarySubtle: GenaiColorsPrimitive.primary900,
        surfacePage: GenaiColorsPrimitive.neutral950,
        surfaceCard: GenaiColorsPrimitive.neutral900,
        surfaceInput: GenaiColorsPrimitive.neutral800,
        surfaceOverlay: GenaiColorsPrimitive.neutral850,
        surfaceSidebar: GenaiColorsPrimitive.neutral900,
        surfaceHover: GenaiColorsPrimitive.neutral800,
        surfacePressed: GenaiColorsPrimitive.neutral700,
        borderDefault: GenaiColorsPrimitive.neutral700,
        borderStrong: GenaiColorsPrimitive.neutral600,
        borderFocus: GenaiColorsPrimitive.primary400,
        borderError: GenaiColorsPrimitive.error400,
        borderSuccess: GenaiColorsPrimitive.success400,
        textPrimary: GenaiColorsPrimitive.neutral50,
        textSecondary: GenaiColorsPrimitive.neutral400,
        textDisabled: GenaiColorsPrimitive.neutral600,
        textOnPrimary: Colors.white,
        textLink: GenaiColorsPrimitive.primary400,
        textError: GenaiColorsPrimitive.error400,
        textSuccess: GenaiColorsPrimitive.success400,
        textWarning: GenaiColorsPrimitive.warning400,
        colorSuccess: GenaiColorsPrimitive.success400,
        colorSuccessHover: GenaiColorsPrimitive.success300,
        colorWarning: GenaiColorsPrimitive.warning400,
        colorWarningHover: GenaiColorsPrimitive.warning300,
        colorError: GenaiColorsPrimitive.error400,
        colorErrorHover: GenaiColorsPrimitive.error300,
        colorInfo: GenaiColorsPrimitive.info400,
        colorInfoHover: GenaiColorsPrimitive.info300,
        colorSuccessSubtle: GenaiColorsPrimitive.success900,
        colorWarningSubtle: GenaiColorsPrimitive.warning900,
        colorErrorSubtle: GenaiColorsPrimitive.error900,
        colorInfoSubtle: GenaiColorsPrimitive.info900,
      );

  GenaiColorTokens copyWith({
    Color? colorPrimary,
    Color? colorPrimaryHover,
    Color? colorPrimaryPressed,
    Color? colorPrimarySubtle,
    Color? surfacePage,
    Color? surfaceCard,
    Color? surfaceInput,
    Color? surfaceOverlay,
    Color? surfaceSidebar,
    Color? surfaceHover,
    Color? surfacePressed,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? borderError,
    Color? borderSuccess,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? textLink,
    Color? textError,
    Color? textSuccess,
    Color? textWarning,
    Color? colorSuccess,
    Color? colorSuccessHover,
    Color? colorWarning,
    Color? colorWarningHover,
    Color? colorError,
    Color? colorErrorHover,
    Color? colorInfo,
    Color? colorInfoHover,
    Color? colorSuccessSubtle,
    Color? colorWarningSubtle,
    Color? colorErrorSubtle,
    Color? colorInfoSubtle,
  }) {
    return GenaiColorTokens(
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorPrimaryHover: colorPrimaryHover ?? this.colorPrimaryHover,
      colorPrimaryPressed: colorPrimaryPressed ?? this.colorPrimaryPressed,
      colorPrimarySubtle: colorPrimarySubtle ?? this.colorPrimarySubtle,
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceSidebar: surfaceSidebar ?? this.surfaceSidebar,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      borderError: borderError ?? this.borderError,
      borderSuccess: borderSuccess ?? this.borderSuccess,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textLink: textLink ?? this.textLink,
      textError: textError ?? this.textError,
      textSuccess: textSuccess ?? this.textSuccess,
      textWarning: textWarning ?? this.textWarning,
      colorSuccess: colorSuccess ?? this.colorSuccess,
      colorSuccessHover: colorSuccessHover ?? this.colorSuccessHover,
      colorWarning: colorWarning ?? this.colorWarning,
      colorWarningHover: colorWarningHover ?? this.colorWarningHover,
      colorError: colorError ?? this.colorError,
      colorErrorHover: colorErrorHover ?? this.colorErrorHover,
      colorInfo: colorInfo ?? this.colorInfo,
      colorInfoHover: colorInfoHover ?? this.colorInfoHover,
      colorSuccessSubtle: colorSuccessSubtle ?? this.colorSuccessSubtle,
      colorWarningSubtle: colorWarningSubtle ?? this.colorWarningSubtle,
      colorErrorSubtle: colorErrorSubtle ?? this.colorErrorSubtle,
      colorInfoSubtle: colorInfoSubtle ?? this.colorInfoSubtle,
    );
  }

  static GenaiColorTokens lerp(GenaiColorTokens a, GenaiColorTokens b, double t) {
    return GenaiColorTokens(
      colorPrimary: Color.lerp(a.colorPrimary, b.colorPrimary, t)!,
      colorPrimaryHover: Color.lerp(a.colorPrimaryHover, b.colorPrimaryHover, t)!,
      colorPrimaryPressed: Color.lerp(a.colorPrimaryPressed, b.colorPrimaryPressed, t)!,
      colorPrimarySubtle: Color.lerp(a.colorPrimarySubtle, b.colorPrimarySubtle, t)!,
      surfacePage: Color.lerp(a.surfacePage, b.surfacePage, t)!,
      surfaceCard: Color.lerp(a.surfaceCard, b.surfaceCard, t)!,
      surfaceInput: Color.lerp(a.surfaceInput, b.surfaceInput, t)!,
      surfaceOverlay: Color.lerp(a.surfaceOverlay, b.surfaceOverlay, t)!,
      surfaceSidebar: Color.lerp(a.surfaceSidebar, b.surfaceSidebar, t)!,
      surfaceHover: Color.lerp(a.surfaceHover, b.surfaceHover, t)!,
      surfacePressed: Color.lerp(a.surfacePressed, b.surfacePressed, t)!,
      borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
      borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
      borderFocus: Color.lerp(a.borderFocus, b.borderFocus, t)!,
      borderError: Color.lerp(a.borderError, b.borderError, t)!,
      borderSuccess: Color.lerp(a.borderSuccess, b.borderSuccess, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
      textOnPrimary: Color.lerp(a.textOnPrimary, b.textOnPrimary, t)!,
      textLink: Color.lerp(a.textLink, b.textLink, t)!,
      textError: Color.lerp(a.textError, b.textError, t)!,
      textSuccess: Color.lerp(a.textSuccess, b.textSuccess, t)!,
      textWarning: Color.lerp(a.textWarning, b.textWarning, t)!,
      colorSuccess: Color.lerp(a.colorSuccess, b.colorSuccess, t)!,
      colorSuccessHover: Color.lerp(a.colorSuccessHover, b.colorSuccessHover, t)!,
      colorWarning: Color.lerp(a.colorWarning, b.colorWarning, t)!,
      colorWarningHover: Color.lerp(a.colorWarningHover, b.colorWarningHover, t)!,
      colorError: Color.lerp(a.colorError, b.colorError, t)!,
      colorErrorHover: Color.lerp(a.colorErrorHover, b.colorErrorHover, t)!,
      colorInfo: Color.lerp(a.colorInfo, b.colorInfo, t)!,
      colorInfoHover: Color.lerp(a.colorInfoHover, b.colorInfoHover, t)!,
      colorSuccessSubtle: Color.lerp(a.colorSuccessSubtle, b.colorSuccessSubtle, t)!,
      colorWarningSubtle: Color.lerp(a.colorWarningSubtle, b.colorWarningSubtle, t)!,
      colorErrorSubtle: Color.lerp(a.colorErrorSubtle, b.colorErrorSubtle, t)!,
      colorInfoSubtle: Color.lerp(a.colorInfoSubtle, b.colorInfoSubtle, t)!,
    );
  }
}
