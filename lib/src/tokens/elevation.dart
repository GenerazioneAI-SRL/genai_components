import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Elevation tokens — v3 design system (§2.5).
///
/// Forma LMS is a **flat, hairline** system: cards carry **no shadow** by
/// default. Interactive cards use a single soft hover shadow
/// (`0 4px 12px rgba(13,18,32,.04)`). Overlays (popovers, context menus)
/// get a slightly stronger shadow so they read as floating.
///
/// Shape parity with v2: `layer0`..`layer3` + `darkTintOpacities`. Since v3
/// is light-only in v3.0, all tint opacities are zero — the field exists to
/// preserve the shared `surfaceWithTint` helper signature components expect.
@immutable
class GenaiElevationTokens {
  /// Layer 0 — surface page (no elevation).
  final List<BoxShadow> layer0;

  /// Layer 1 — surface card (no elevation — flat + border only).
  final List<BoxShadow> layer1;

  /// Layer 1-hover — single soft shadow for interactive cards on hover.
  /// Value: `0 4px 12px rgba(13,18,32,.04)` per §2.5.
  final List<BoxShadow> layer1Hover;

  /// Layer 2 — popover / context menu.
  final List<BoxShadow> layer2;

  /// Layer 3 — modal / drawer.
  final List<BoxShadow> layer3;

  /// White-tint overlay opacity for dark surfaces (reserved; always zero in
  /// v3.0 light-only).
  final List<double> darkTintOpacities;

  const GenaiElevationTokens({
    required this.layer0,
    required this.layer1,
    required this.layer1Hover,
    required this.layer2,
    required this.layer3,
    required this.darkTintOpacities,
  });

  /// Default light tokens per §2.5.
  factory GenaiElevationTokens.defaultLight() => const GenaiElevationTokens(
        layer0: [],
        layer1: [],
        layer1Hover: [
          BoxShadow(
            color: Color(0x0A0D1220), // rgba(13,18,32,0.04)
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        layer2: [
          BoxShadow(
            color: Color(0x140D1220), // rgba(13,18,32,0.08)
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        layer3: [
          BoxShadow(
            color: Color(0x1F0D1220), // rgba(13,18,32,0.12)
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
        darkTintOpacities: [0.0, 0.0, 0.0, 0.0],
      );

  /// Default dark tokens (added in v3.1 to back the dark color presets).
  /// Shadows are stronger (rgba(0,0,0,.45..)) so they read on near-black
  /// surfaces; darkTintOpacities provide subtle white lift per layer.
  factory GenaiElevationTokens.defaultDark() => const GenaiElevationTokens(
        layer0: [],
        layer1: [],
        layer1Hover: [
          BoxShadow(
            color: Color(0x66000000), // rgba(0,0,0,0.40)
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        layer2: [
          BoxShadow(
            color: Color(0x80000000), // rgba(0,0,0,0.50)
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        layer3: [
          BoxShadow(
            color: Color(0x99000000), // rgba(0,0,0,0.60)
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
        darkTintOpacities: [0.0, 0.02, 0.04, 0.06],
      );

  /// Deprecated v1 alias for [shadowForLayer]. Removed in v6.
  List<BoxShadow> shadow(int level) => shadowForLayer(level);

  /// Returns the shadow list for [level] (0..3). Clamps out-of-range.
  List<BoxShadow> shadowForLayer(int level) {
    switch (level.clamp(0, 3)) {
      case 0:
        return layer0;
      case 1:
        return layer1;
      case 2:
        return layer2;
      default:
        return layer3;
    }
  }

  /// White-tint overlay opacity for [level]. Always zero in v3.0.
  double darkTintForLayer(int level) =>
      darkTintOpacities[level.clamp(0, darkTintOpacities.length - 1)];

  /// No-op in v3.0 light-only; preserved for API parity with v2.
  Color surfaceWithTint(int level, Color baseSurface) {
    final opacity = darkTintForLayer(level);
    if (opacity == 0) return baseSurface;
    return Color.alphaBlend(
      Colors.white.withValues(alpha: opacity),
      baseSurface,
    );
  }

  GenaiElevationTokens copyWith({
    List<BoxShadow>? layer0,
    List<BoxShadow>? layer1,
    List<BoxShadow>? layer1Hover,
    List<BoxShadow>? layer2,
    List<BoxShadow>? layer3,
    List<double>? darkTintOpacities,
  }) {
    return GenaiElevationTokens(
      layer0: layer0 ?? this.layer0,
      layer1: layer1 ?? this.layer1,
      layer1Hover: layer1Hover ?? this.layer1Hover,
      layer2: layer2 ?? this.layer2,
      layer3: layer3 ?? this.layer3,
      darkTintOpacities: darkTintOpacities ?? this.darkTintOpacities,
    );
  }

  /// Elevation is categorical — `lerp` snaps at the midpoint.
  static GenaiElevationTokens lerp(
          GenaiElevationTokens a, GenaiElevationTokens b, double t) =>
      t < 0.5 ? a : b;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiElevationTokens &&
          runtimeType == other.runtimeType &&
          listEquals(layer0, other.layer0) &&
          listEquals(layer1, other.layer1) &&
          listEquals(layer1Hover, other.layer1Hover) &&
          listEquals(layer2, other.layer2) &&
          listEquals(layer3, other.layer3) &&
          listEquals(darkTintOpacities, other.darkTintOpacities);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(layer0),
        Object.hashAll(layer1),
        Object.hashAll(layer1Hover),
        Object.hashAll(layer2),
        Object.hashAll(layer3),
        Object.hashAll(darkTintOpacities),
      );
}
