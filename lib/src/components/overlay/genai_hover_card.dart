import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Floating rich-content card that opens on pointer enter — v3 design system.
///
/// Distinct from [GenaiTooltip](genai_tooltip.dart):
/// - Larger surface for multi-widget content (avatar, title, actions).
/// - Stays open while the cursor moves between the trigger and card via
///   [closeDelay].
/// - Desktop-only — on compact (touch-first) windows the trigger is passed
///   through unchanged.
class GenaiHoverCard extends StatefulWidget {
  /// Trigger widget that anchors the card.
  final Widget child;

  /// Builds the card content. Receives the overlay `BuildContext` so it can
  /// consume v3 tokens.
  final WidgetBuilder content;

  /// Fixed card width.
  final double width;

  /// Delay between pointer entering [child] and showing the card.
  final Duration openDelay;

  /// Delay between pointer leaving and hiding the card — allows the user
  /// to travel from the trigger onto the overlay.
  final Duration closeDelay;

  /// Accessible label announced when the card opens.
  final String? semanticLabel;

  const GenaiHoverCard({
    super.key,
    required this.child,
    required this.content,
    this.width = 320,
    this.openDelay = const Duration(milliseconds: 500),
    this.closeDelay = const Duration(milliseconds: 150),
    this.semanticLabel,
  });

  @override
  State<GenaiHoverCard> createState() => _GenaiHoverCardState();
}

class _GenaiHoverCardState extends State<GenaiHoverCard> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  Timer? _openTimer;
  Timer? _closeTimer;
  bool _triggerHovered = false;
  bool _cardHovered = false;

  void _scheduleOpen() {
    _closeTimer?.cancel();
    if (_entry != null) return;
    _openTimer?.cancel();
    _openTimer = Timer(widget.openDelay, _open);
  }

  void _scheduleClose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _closeTimer = Timer(widget.closeDelay, () {
      if (_triggerHovered || _cardHovered) return;
      _close();
    });
  }

  void _open() {
    if (!mounted || _entry != null) return;
    final overlay = Overlay.of(context);
    final spacing = context.spacing;
    final radius = context.radius;
    final motion = context.motion.expand;
    final reduced = GenaiResponsive.reducedMotion(context);

    _entry = OverlayEntry(builder: (ctx) {
      final colors = ctx.colors;
      return Stack(
        children: [
          CompositedTransformFollower(
            link: _link,
            offset: Offset(0, spacing.s8),
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              heightFactor: 1,
              child: MouseRegion(
                onEnter: (_) {
                  _cardHovered = true;
                  _closeTimer?.cancel();
                },
                onExit: (_) {
                  _cardHovered = false;
                  _scheduleClose();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Semantics(
                    container: true,
                    label: widget.semanticLabel,
                    child: TweenAnimationBuilder<double>(
                      duration: reduced ? Duration.zero : motion.duration,
                      curve: motion.curve,
                      tween: Tween(begin: 0, end: 1),
                      builder: (_, t, c) => Opacity(opacity: t, child: c),
                      child: Container(
                        width: widget.width,
                        padding: EdgeInsets.all(spacing.s14),
                        decoration: BoxDecoration(
                          color: colors.surfaceOverlay,
                          borderRadius: BorderRadius.circular(radius.xl),
                          border: Border.all(color: colors.borderDefault),
                          boxShadow: ctx.elevation.shadowForLayer(2),
                        ),
                        child: widget.content(ctx),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
    overlay.insert(_entry!);
    if (mounted) setState(() {});
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      // Touch-first contexts pass the trigger through unchanged.
      return widget.child;
    }
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) {
          _triggerHovered = true;
          _scheduleOpen();
        },
        onExit: (_) {
          _triggerHovered = false;
          _scheduleClose();
        },
        child: Semantics(
          container: true,
          hint: widget.semanticLabel,
          child: widget.child,
        ),
      ),
    );
  }
}

// Hover cards render on the overlay z-index layer.
// ignore: unused_element
const int _hoverCardZ = GenaiZIndex.overlay;
