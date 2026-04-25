/// Internal v1 → v3 compatibility shims.
///
/// Provides deprecated extension getters that map old v1 token names onto
/// their v3 equivalents. Used by domain code (survey, scaffold) that has not
/// yet been refactored to v3 tokens. New code should prefer the canonical
/// v3 names directly.
library;

import 'package:flutter/material.dart';

import 'colors.dart';
import 'elevation.dart';
import 'motion.dart';
import 'spacing.dart';
import 'typography.dart';

/// v1 color name aliases.
extension GenaiColorTokensV1Compat on GenaiColorTokens {
  /// Deprecated alias for [colorDanger].
  @Deprecated('Use colorDanger instead. Removed in v6.')
  Color get colorError => colorDanger;

  /// Deprecated alias for [colorDangerSubtle].
  @Deprecated('Use colorDangerSubtle instead. Removed in v6.')
  Color get colorErrorSubtle => colorDangerSubtle;

  /// Deprecated alias for [colorDanger].
  @Deprecated('Use colorDanger instead. Removed in v6.')
  Color get colorErrorHover => colorDanger;

  /// Deprecated alias for [colorDanger].
  @Deprecated('Use colorDanger instead. Removed in v6.')
  Color get textError => colorDanger;

  /// Deprecated alias for [borderStrong].
  @Deprecated('Use borderStrong instead. Removed in v6.')
  Color get borderError => colorDanger;
}

/// v1 typography name aliases.
extension GenaiTypographyTokensV1Compat on GenaiTypographyTokens {
  /// Deprecated alias — v1 `bodyMd` ≈ v3 `body` (14 / 400).
  @Deprecated('Use body instead. Removed in v6.')
  TextStyle get bodyMd => body;

  /// Deprecated alias — v1 `bodyLg` ≈ v3 `body`.
  @Deprecated('Use body instead. Removed in v6.')
  TextStyle get bodyLg => body;

  /// Deprecated alias — v1 `caption` ≈ v3 `labelSm` (11.5 / 500).
  @Deprecated('Use labelSm instead. Removed in v6.')
  TextStyle get caption => labelSm;

  /// Deprecated alias — v1 `headingLg` ≈ v3 `pageTitle` (22 / 600).
  @Deprecated('Use pageTitle instead. Removed in v6.')
  TextStyle get headingLg => pageTitle;

  /// Deprecated alias — v1 `headingMd` ≈ v3 `sectionTitle`.
  @Deprecated('Use sectionTitle instead. Removed in v6.')
  TextStyle get headingMd => sectionTitle;

  /// Deprecated alias — v1 `headingSm` ≈ v3 `cardTitle`.
  @Deprecated('Use cardTitle instead. Removed in v6.')
  TextStyle get headingSm => cardTitle;

  /// Deprecated alias — v1 `displayLg` ≈ v3 `pageTitle`.
  @Deprecated('Use pageTitle instead. Removed in v6.')
  TextStyle get displayLg => pageTitle;

  /// Deprecated alias — v1 `displaySm` ≈ v3 `kpiNumber`.
  @Deprecated('Use kpiNumber instead. Removed in v6.')
  TextStyle get displaySm => kpiNumber;

  /// Deprecated alias — v1 `code` ≈ v3 `monoSm`.
  @Deprecated('Use monoSm instead. Removed in v6.')
  TextStyle get code => monoSm;
}

/// v1 spacing name aliases.
extension GenaiSpacingTokensV1Compat on GenaiSpacingTokens {
  /// v1 had odd-numbered steps; map onto the closest v3 even step.
  @Deprecated('Use s2 instead. Removed in v6.')
  double get s1 => 2.0;

  /// Deprecated alias — v1 `s3` (~6) → v3 `s6`.
  @Deprecated('Use s6 instead. Removed in v6.')
  double get s3 => s6;

  /// Deprecated alias — v1 `s5` (~10) → v3 `s10`.
  @Deprecated('Use s10 instead. Removed in v6.')
  double get s5 => s10;

  /// Deprecated alias for [fieldGap].
  @Deprecated('Use fieldGap instead. Removed in v6.')
  double get formFieldGap => fieldGap;

  /// Deprecated alias for [sectionGap].
  @Deprecated('Use sectionGap instead. Removed in v6.')
  double get pageSectionGap => sectionGap;

  /// Deprecated alias — v1 `componentPaddingH` was 12.
  @Deprecated('Use s12 instead. Removed in v6.')
  double get componentPaddingH => s12;

  /// Deprecated alias for [cardPadding].
  @Deprecated('Use cardPadding instead. Removed in v6.')
  double get cardGridGap => cardPadding;

  /// Deprecated alias — v1 `pagePaddingH` was 32.
  @Deprecated('Use pageMarginDesktop instead. Removed in v6.')
  double get pagePaddingH => pageMarginDesktop;

  /// Deprecated alias — v1 `sectionGapInCard` was 16.
  @Deprecated('Use s16 instead. Removed in v6.')
  double get sectionGapInCard => s16;
}

/// v1 elevation alias — `shadow(level)` → `shadowForLayer(level)`.
extension GenaiElevationTokensV1Compat on GenaiElevationTokens {
  /// Deprecated alias for [shadowForLayer].
  @Deprecated('Use shadowForLayer instead. Removed in v6.')
  List<BoxShadow> shadow(int level) => shadowForLayer(level);
}

/// v1 motion alias — `autosaveDebounce`.
extension GenaiMotionTokensV1Compat on GenaiMotionTokens {
  /// Deprecated alias — v1 had a dedicated 1500 ms autosave debounce duration.
  @Deprecated('Use a literal Duration(milliseconds: 1500) instead. '
      'Removed in v6.')
  Duration get autosaveDebounce => const Duration(milliseconds: 1500);
}
