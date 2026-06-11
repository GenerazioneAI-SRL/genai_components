import 'package:flutter/material.dart';

import '../cl_theme.dart';

/// Shared overlay scrim tokens — single source of truth for barrier colors.
///
/// [kCLModalScrim]: modal surfaces (dialogs, sheets) — black @ 45%.
/// [kCLPopoverScrim]: anchored popovers (menus, dropdown overlays) — light.
const Color kCLModalScrim = Color(0x73000000); // Colors.black, alpha 0.45
const Color kCLPopoverScrim = Colors.black12;

/// Shared visual + entry-animation wrapper for floating popups
/// (dropdowns, overlay menus, autocomplete suggestions).
///
/// Caller is responsible for the OverlayEntry / positioning / dismiss-on-outside-tap.
/// This widget only handles:
/// - chrome (rounded radius, hairline border, soft 2-layer shadow, clip)
/// - entry animation (fade + small slide, 140ms easeOutCubic)
///
/// We deliberately avoid `Material(elevation: …)` — its physical-shape shadow
/// rasterization is expensive on web/desktop. A `BoxDecoration` with two
/// pre-computed `BoxShadow` layers paints in a single pass and produces
/// visually equivalent depth at a fraction of the cost.
class CLPopupSurface extends StatefulWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool animateUpward;
  final bool animate;

  const CLPopupSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.animateUpward = false,
    this.animate = true,
  });

  @override
  State<CLPopupSurface> createState() => _CLPopupSurfaceState();
}

class _CLPopupSurfaceState extends State<CLPopupSurface> with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _opacity;
  Animation<Offset>? _slide;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..forward();
    final curve = CurvedAnimation(parent: _ctrl!, curve: Curves.easeOutCubic);
    _opacity = curve;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.animateUpward ? 0.025 : -0.025),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _ctrl?.stop();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final radius = widget.borderRadius ?? BorderRadius.circular(theme.radiusSurface);
    final bg = widget.backgroundColor ?? theme.secondaryBackground;
    final border = widget.borderColor ?? theme.cardBorder;

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        // Material transparente: dà l'antenato richiesto da InkWell/ripple
        // dei contenuti (menu item, liste) senza aggiungere ombre fisiche.
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child,
          ),
        ),
      ),
    );

    if (!widget.animate || _ctrl == null) return surface;

    return FadeTransition(
      opacity: _opacity!,
      child: SlideTransition(position: _slide!, child: surface),
    );
  }
}
