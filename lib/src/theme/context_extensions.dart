import 'package:flutter/material.dart';

import '../foundations/responsive.dart';
import '../tokens/tokens.dart';
import 'theme_extension.dart';

/// Convenience accessors for Genai design tokens via [BuildContext].
///
/// Usage:
/// ```dart
/// Container(
///   color: context.colors.surfaceCard,
///   padding: EdgeInsets.all(context.spacing.s4),
///   child: Text('Hi', style: context.typography.bodyMd),
/// )
/// ```
extension GenaiThemeContext on BuildContext {
  GenaiThemeExtension get _ext {
    final ext = Theme.of(this).extension<GenaiThemeExtension>();
    assert(
      ext != null,
      'GenaiThemeExtension missing. Wrap your app with GenaiTheme.light()/dark().',
    );
    return ext!;
  }

  GenaiColorTokens get colors => _ext.colors;
  GenaiSpacingTokens get spacing => _ext.spacing;
  GenaiTypographyTokens get typography => _ext.typography;
  GenaiSizingTokens get sizing => _ext.sizing;
  GenaiElevationTokens get elevation => _ext.elevation;
  GenaiRadiusTokens get radius => _ext.radius;

  /// True when the current theme is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Window size shortcuts (delegate to GenaiResponsive).
  GenaiWindowSize get windowSize => GenaiResponsive.sizeOf(this);
  bool get isCompact => windowSize == GenaiWindowSize.compact;
  bool get isMedium => windowSize == GenaiWindowSize.medium;
  bool get isExpanded => windowSize.index >= GenaiWindowSize.expanded.index;
  bool get isDesktopWide => windowSize.index >= GenaiWindowSize.large.index;
}
