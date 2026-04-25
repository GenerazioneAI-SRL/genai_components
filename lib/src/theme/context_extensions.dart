import 'package:flutter/material.dart';

import '../foundations/responsive.dart';
import '../tokens/tokens.dart';
import 'theme_extension.dart';

// Re-export tokens so files that `import 'context_extensions.dart'` also see
// token classes and the v1-compat extension getters bundled in
// `tokens/_v1_compat.dart`.
export '../tokens/tokens.dart';

/// Convenience accessors for v3 design tokens via [BuildContext].
///
/// Usage:
/// ```dart
/// import 'package:genai_components/genai_components_v3.dart' as v3;
///
/// Container(
///   color: context.colors.surfaceCard,
///   padding: EdgeInsets.all(context.spacing.cardPadding),
///   child: Text('Hi', style: context.typography.body),
/// )
/// ```
///
/// NOTE: `context.colors` etc. resolve the **v3** extension. Mixing v1, v2
/// and v3 imports in the same file is not supported because all three
/// libraries define the same extension names; pick one via an `import as`
/// alias.
extension GenaiThemeContext on BuildContext {
  GenaiThemeExtension get _v3Ext {
    final ext = Theme.of(this).extension<GenaiThemeExtension>();
    assert(
      ext != null,
      'v3 GenaiThemeExtension missing. Wrap your app with '
      'v3.GenaiTheme.light() or v3.GenaiThemePresets.formaLms().',
    );
    return ext!;
  }

  GenaiColorTokens get colors => _v3Ext.colors;
  GenaiTypographyTokens get typography => _v3Ext.typography;
  GenaiSpacingTokens get spacing => _v3Ext.spacing;
  GenaiSizingTokens get sizing => _v3Ext.sizing;
  GenaiRadiusTokens get radius => _v3Ext.radius;
  GenaiElevationTokens get elevation => _v3Ext.elevation;

  /// Motion tokens, automatically collapsed to [Duration.zero] pairs when the
  /// OS requests reduced motion (§5).
  GenaiMotionTokens get motion {
    if (GenaiResponsive.reducedMotion(this)) {
      return GenaiMotionTokens.reduced();
    }
    return _v3Ext.motion;
  }

  /// True when the current theme is dark. v3.0 is light-only so this is
  /// always `false`; kept for API parity with v2.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Window-size shortcuts ─────────────────────────────────────────────
  GenaiWindowSize get windowSize => GenaiResponsive.sizeOf(this);
  bool get isCompact => windowSize == GenaiWindowSize.compact;
  bool get isMedium => windowSize == GenaiWindowSize.medium;
  bool get isExpanded => windowSize.index >= GenaiWindowSize.expanded.index;
  bool get isDesktopWide => windowSize.index >= GenaiWindowSize.large.index;

  /// Page horizontal margin adapted to the current window (§3).
  double get pageMargin =>
      isCompact ? spacing.pageMarginMobile : spacing.pageMarginDesktop;
}
