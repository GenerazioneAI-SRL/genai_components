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

  /// Quando passa da `true` a `false` il popover fa il reverse (animate-out)
  /// e a fine reverse chiama [onDismissed]. Default `true` (aperto).
  final bool visible;

  /// Chiamato a fine animazione di uscita (reverse completo): il chiamante
  /// rimuove qui l'OverlayEntry.
  final VoidCallback? onDismissed;

  const CLPopupSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.animateUpward = false,
    this.animate = true,
    this.visible = true,
    this.onDismissed,
  });

  @override
  State<CLPopupSurface> createState() => _CLPopupSurfaceState();
}

class _CLPopupSurfaceState extends State<CLPopupSurface> with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _opacity;
  Animation<Offset>? _slide;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    // shadcn: durata 150ms (Animate.defaultDuration), reverse un filo più corto.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 120),
    );
    // A fine reverse (uscita completata) notifica il chiamante per la rimozione.
    _ctrl!.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !widget.visible) {
        widget.onDismissed?.call();
      }
    });
    if (widget.visible) _ctrl!.forward();
    final curve = CurvedAnimation(parent: _ctrl!, curve: Curves.easeOutCubic);
    _opacity = curve;
    // shadcn: MoveEffect(begin Offset(0,2) → 0) — traslazione FISSA 2px.
    _slide = Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero)
        .animate(curve);
    // shadcn: ScaleEffect(begin .95 → 1), origine CENTRO.
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(curve);
  }

  @override
  void didUpdateWidget(covariant CLPopupSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ctrl == null) return;
    if (oldWidget.visible && !widget.visible) {
      _ctrl!.reverse();
    } else if (!oldWidget.visible && widget.visible) {
      _ctrl!.forward();
    }
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
        // Superficie transitoria (fuori-pila) → ombra marcata del token dedicato.
        boxShadow: theme.popoverShadow,
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
      // shadcn: Scale origine centro (default flutter_animate) + Move 2px fissi.
      child: ScaleTransition(
        scale: _scale!,
        child: AnimatedBuilder(
          animation: _slide!,
          builder: (context, child) =>
              Transform.translate(offset: _slide!.value, child: child),
          child: surface,
        ),
      ),
    );
  }
}
