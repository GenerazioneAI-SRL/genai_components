import 'package:flutter/foundation.dart';

/// User density preference — v3 design system.
///
/// v3 keeps the v2 density triple (compact / normal / spacious) — Forma LMS
/// dashboards sit comfortably at `normal` but power-user pages may opt into
/// `compact` for tables and agenda rows.
enum GenaiDensity {
  /// Row 28 / icon 16 / touch 40. Power-user tables, dense dashboards.
  compact,

  /// Row 36 / icon 18 / touch 44. Default for Forma LMS.
  normal,

  /// Row 44 / icon 20 / touch 52. Accessibility, mobile-first pages.
  spacious;

  /// Row height in logical pixels.
  double get rowHeight {
    switch (this) {
      case GenaiDensity.compact:
        return 28;
      case GenaiDensity.normal:
        return 36;
      case GenaiDensity.spacious:
        return 44;
    }
  }

  /// Inline icon size in logical pixels.
  double get iconSize {
    switch (this) {
      case GenaiDensity.compact:
        return 16;
      case GenaiDensity.normal:
        return 18;
      case GenaiDensity.spacious:
        return 20;
    }
  }

  /// Minimum touch target in logical pixels.
  ///
  /// v3 uses slightly tighter targets than v2 to match the Forma LMS
  /// density — rail items are 34 px in the HTML, ask-bar pill is 36 px.
  double get touchTarget {
    switch (this) {
      case GenaiDensity.compact:
        return 40;
      case GenaiDensity.normal:
        return 44;
      case GenaiDensity.spacious:
        return 52;
    }
  }
}

/// Semantic sizing tokens — v3 design system.
///
/// Shape matches v2 `GenaiSizingTokens` so components using the shared API
/// can swap libraries via import alias. Per-role icon sizes are tuned to the
/// Forma LMS HTML:
/// - Sidebar icon: 18 (tighter than v2's 20).
/// - Topbar action icon: 20.
/// - AskBar spark badge: 20 × 20 gradient square.
/// - Top-icon button diameter: 34.
@immutable
class GenaiSizingTokens {
  final GenaiDensity density;
  final double rowHeight;
  final double iconSize;
  final double minTouchTarget;

  final double iconSidebar;
  final double iconAppBarAction;
  final double iconEmptyState;
  final double iconIllustration;

  /// AskBar pill height — 36 (implied by 7 px vertical padding + ~22 content).
  final double askBarHeight;

  /// Topbar circular icon button diameter — 34.
  final double topIconSize;

  /// Sidebar width — 240 per §3 layout pattern.
  final double sidebarWidth;

  /// Focus ring stroke width — 2 px per §5.
  final double focusRingWidth;

  /// Focus ring offset from component — 2 px per §5.
  final double focusRingOffset;

  /// Default divider thickness.
  final double dividerThickness;

  const GenaiSizingTokens._({
    required this.density,
    required this.rowHeight,
    required this.iconSize,
    required this.minTouchTarget,
    required this.iconSidebar,
    required this.iconAppBarAction,
    required this.iconEmptyState,
    required this.iconIllustration,
    required this.askBarHeight,
    required this.topIconSize,
    required this.sidebarWidth,
    required this.focusRingWidth,
    required this.focusRingOffset,
    required this.dividerThickness,
  });

  /// Build sizing tokens for a given [density].
  factory GenaiSizingTokens.forDensity(GenaiDensity density) {
    return GenaiSizingTokens._(
      density: density,
      rowHeight: density.rowHeight,
      iconSize: density.iconSize,
      minTouchTarget: density.touchTarget,
      iconSidebar: 18,
      iconAppBarAction: 20,
      iconEmptyState: 48,
      iconIllustration: 96,
      askBarHeight: 36,
      topIconSize: 34,
      sidebarWidth: 240,
      focusRingWidth: 2,
      focusRingOffset: 2,
      dividerThickness: 1,
    );
  }

  /// Default tokens (normal density).
  factory GenaiSizingTokens.defaultTokens() =>
      GenaiSizingTokens.forDensity(GenaiDensity.normal);

  GenaiSizingTokens copyWith({
    GenaiDensity? density,
    double? rowHeight,
    double? iconSize,
    double? minTouchTarget,
    double? iconSidebar,
    double? iconAppBarAction,
    double? iconEmptyState,
    double? iconIllustration,
    double? askBarHeight,
    double? topIconSize,
    double? sidebarWidth,
    double? focusRingWidth,
    double? focusRingOffset,
    double? dividerThickness,
  }) {
    return GenaiSizingTokens._(
      density: density ?? this.density,
      rowHeight: rowHeight ?? this.rowHeight,
      iconSize: iconSize ?? this.iconSize,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      iconSidebar: iconSidebar ?? this.iconSidebar,
      iconAppBarAction: iconAppBarAction ?? this.iconAppBarAction,
      iconEmptyState: iconEmptyState ?? this.iconEmptyState,
      iconIllustration: iconIllustration ?? this.iconIllustration,
      askBarHeight: askBarHeight ?? this.askBarHeight,
      topIconSize: topIconSize ?? this.topIconSize,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingOffset: focusRingOffset ?? this.focusRingOffset,
      dividerThickness: dividerThickness ?? this.dividerThickness,
    );
  }

  static GenaiSizingTokens lerp(
      GenaiSizingTokens a, GenaiSizingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSizingTokens._(
      density: t < 0.5 ? a.density : b.density,
      rowHeight: l(a.rowHeight, b.rowHeight),
      iconSize: l(a.iconSize, b.iconSize),
      minTouchTarget: l(a.minTouchTarget, b.minTouchTarget),
      iconSidebar: l(a.iconSidebar, b.iconSidebar),
      iconAppBarAction: l(a.iconAppBarAction, b.iconAppBarAction),
      iconEmptyState: l(a.iconEmptyState, b.iconEmptyState),
      iconIllustration: l(a.iconIllustration, b.iconIllustration),
      askBarHeight: l(a.askBarHeight, b.askBarHeight),
      topIconSize: l(a.topIconSize, b.topIconSize),
      sidebarWidth: l(a.sidebarWidth, b.sidebarWidth),
      focusRingWidth: l(a.focusRingWidth, b.focusRingWidth),
      focusRingOffset: l(a.focusRingOffset, b.focusRingOffset),
      dividerThickness: l(a.dividerThickness, b.dividerThickness),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiSizingTokens &&
          runtimeType == other.runtimeType &&
          density == other.density &&
          rowHeight == other.rowHeight &&
          iconSize == other.iconSize &&
          minTouchTarget == other.minTouchTarget &&
          iconSidebar == other.iconSidebar &&
          iconAppBarAction == other.iconAppBarAction &&
          iconEmptyState == other.iconEmptyState &&
          iconIllustration == other.iconIllustration &&
          askBarHeight == other.askBarHeight &&
          topIconSize == other.topIconSize &&
          sidebarWidth == other.sidebarWidth &&
          focusRingWidth == other.focusRingWidth &&
          focusRingOffset == other.focusRingOffset &&
          dividerThickness == other.dividerThickness;

  @override
  int get hashCode => Object.hashAll([
        density,
        rowHeight,
        iconSize,
        minTouchTarget,
        iconSidebar,
        iconAppBarAction,
        iconEmptyState,
        iconIllustration,
        askBarHeight,
        topIconSize,
        sidebarWidth,
        focusRingWidth,
        focusRingOffset,
        dividerThickness,
      ]);
}
