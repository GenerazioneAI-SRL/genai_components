import 'package:flutter/material.dart';

/// Elevation tokens §2.5.
@immutable
class GenaiElevationTokens {
  /// 6 levels (0..5) of box shadows for light surfaces.
  final List<List<BoxShadow>> shadows;

  /// 6 levels of white-overlay opacity for dark surfaces.
  final List<double> darkOverlayOpacities;

  const GenaiElevationTokens({
    required this.shadows,
    required this.darkOverlayOpacities,
  });

  factory GenaiElevationTokens.defaultLight() => const GenaiElevationTokens(
        shadows: [
          [],
          [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ],
        darkOverlayOpacities: [0.0, 0.04, 0.06, 0.08, 0.10, 0.12],
      );

  factory GenaiElevationTokens.defaultDark() => GenaiElevationTokens.defaultLight();

  /// Returns shadows for [level] (0..5).
  List<BoxShadow> shadow(int level) => shadows[level.clamp(0, shadows.length - 1)];

  /// Apply white overlay on top of [baseSurface] for the given dark elevation.
  Color surfaceWithDarkOverlay(int level, Color baseSurface) {
    final opacity = darkOverlayOpacities[level.clamp(0, darkOverlayOpacities.length - 1)];
    return Color.alphaBlend(Colors.white.withValues(alpha: opacity), baseSurface);
  }

  static GenaiElevationTokens lerp(GenaiElevationTokens a, GenaiElevationTokens b, double t) => t < 0.5 ? a : b;
}
