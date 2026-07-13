import 'package:flutter/material.dart';

import '../../cl_theme.dart';

/// Preset di superficie — le tipologie ricorrenti censite dall'audit 2026-07-02.
enum CLSurfaceKind {
  /// Card in rilievo: `radiusCard` + `cardShadow` + bordo `cardBorder`.
  cardElevated,

  /// Card leggera: `radiusCard` + `cardShadowSoft`, senza bordo.
  cardSoft,

  /// Superficie incassata (L0): `primaryBackground`, `radiusSurface`, no ombra.
  recessed,

  /// Pannello flottante (popover/menu/dialog): `radiusSurface` + `popoverShadow`
  /// + bordo hairline. Per i dialog passare `radius: theme.radiusModal`.
  panel,

  /// Tinta tonale (chip/badge/banner): colore × `opacitySoft`, `radiusChip`.
  tint,
}

/// Primitivo **L1 Foundation** — l'unico posto dove si costruisce una
/// "superficie" (background + bordo + radius + ombra + clip).
///
/// Sostituisce i `BoxDecoration` hand-rolled sparsi nella libreria: ogni
/// componente sceglie un [CLSurfaceKind] e al più sovrascrive i singoli
/// aspetti. Non gestisce interazione (per quella c'è `CLPressable`).
class CLSurface extends StatelessWidget {
  const CLSurface({
    super.key,
    required this.kind,
    this.child,
    this.color,
    this.radius,
    this.border,
    this.shadows,
    this.padding,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  }) : tintColor = null,
       assert(kind != CLSurfaceKind.tint || color != null, 'CLSurfaceKind.tint richiede un colore: usa CLSurface.tint(color: ...)');

  const CLSurface.card({
    super.key,
    this.child,
    this.color,
    this.radius,
    this.border,
    this.shadows,
    this.padding,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  })  : kind = CLSurfaceKind.cardElevated,
        tintColor = null;

  const CLSurface.soft({
    super.key,
    this.child,
    this.color,
    this.radius,
    this.border,
    this.shadows,
    this.padding,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  })  : kind = CLSurfaceKind.cardSoft,
        tintColor = null;

  const CLSurface.recessed({
    super.key,
    this.child,
    this.color,
    this.radius,
    this.border,
    this.shadows,
    this.padding,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  })  : kind = CLSurfaceKind.recessed,
        tintColor = null;

  const CLSurface.panel({
    super.key,
    this.child,
    this.color,
    this.radius,
    this.border,
    this.shadows,
    this.padding,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  })  : kind = CLSurfaceKind.panel,
        tintColor = null;

  const CLSurface.tint({
    super.key,
    required Color color,
    this.child,
    this.radius,
    this.border,
    this.shadows,
    this.padding,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  })  : kind = CLSurfaceKind.tint,
        tintColor = color,
        color = null;

  final CLSurfaceKind kind;
  final Widget? child;

  /// Colore della tinta per [CLSurfaceKind.tint].
  final Color? tintColor;

  /// Override puntuali del preset (null = default del [kind]).
  final Color? color;
  final double? radius;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  final double? width;
  final double? height;

  BoxDecoration _decoration(CLTheme theme) {
    switch (kind) {
      case CLSurfaceKind.cardElevated:
        return BoxDecoration(
          color: color ?? theme.secondaryBackground,
          borderRadius: BorderRadius.circular(radius ?? theme.radiusCard),
          border: border ?? Border.all(color: theme.cardBorder),
          boxShadow: shadows ?? theme.cardShadow,
        );
      case CLSurfaceKind.cardSoft:
        return BoxDecoration(
          color: color ?? theme.secondaryBackground,
          borderRadius: BorderRadius.circular(radius ?? theme.radiusCard),
          border: border,
          boxShadow: shadows ?? theme.cardShadowSoft,
        );
      case CLSurfaceKind.recessed:
        return BoxDecoration(
          color: color ?? theme.primaryBackground,
          borderRadius: BorderRadius.circular(radius ?? theme.radiusSurface),
          border: border,
          boxShadow: shadows,
        );
      case CLSurfaceKind.panel:
        return BoxDecoration(
          color: color ?? theme.secondaryBackground,
          borderRadius: BorderRadius.circular(radius ?? theme.radiusSurface),
          border: border ?? Border.all(color: theme.cardBorder),
          boxShadow: shadows ?? theme.popoverShadow,
        );
      case CLSurfaceKind.tint:
        return BoxDecoration(
          color: color ?? tintColor!.withValues(alpha: theme.opacitySoft),
          borderRadius: BorderRadius.circular(radius ?? theme.radiusChip),
          border: border,
          boxShadow: shadows,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: _decoration(theme),
      child: child,
    );
  }
}
