import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Side of the anchor the popover opens toward.
enum GenaiPopoverPlacement {
  /// Above the anchor.
  top,

  /// Below the anchor (default).
  bottom,

  /// Left of the anchor.
  left,

  /// Right of the anchor.
  right,
}

/// Anchored popover — v3 design system.
///
/// Hairline-bordered overlay with `layer2` shadow, `radius.xl` (12) corners,
/// surface overlay bg. Closes on outside tap or `Esc`. Callers holding a
/// `GlobalKey<GenaiPopoverState>` can drive the popover imperatively via
/// `show / hide / toggle`.
class GenaiPopover extends StatefulWidget {
  /// Anchor trigger widget.
  final Widget child;

  /// Popover contents builder.
  final WidgetBuilder content;

  /// Preferred placement side.
  final GenaiPopoverPlacement placement;

  /// Popover width.
  final double width;

  /// Interior padding. Defaults to `context.spacing.s14`.
  final EdgeInsets? padding;

  /// Accessible label.
  final String? semanticLabel;

  const GenaiPopover({
    super.key,
    required this.child,
    required this.content,
    this.placement = GenaiPopoverPlacement.bottom,
    this.width = 240,
    this.padding,
    this.semanticLabel,
  });

  @override
  State<GenaiPopover> createState() => GenaiPopoverState();
}

/// State of a [GenaiPopover] — exposes imperative controls.
class GenaiPopoverState extends State<GenaiPopover> {
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _entry;
  final FocusNode _overlayFocus = FocusNode(debugLabel: 'GenaiPopover');

  /// Inserts the overlay. No-op if already open.
  void show() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final spacing = context.spacing;
    final radius = context.radius;
    final motion = context.motion.expand;
    final reduced = GenaiResponsive.reducedMotion(context);
    final effectivePadding = widget.padding ?? EdgeInsets.all(spacing.s14);

    Offset offset;
    Alignment target;
    Alignment follower;
    switch (widget.placement) {
      case GenaiPopoverPlacement.bottom:
        offset = Offset(0, spacing.s8);
        target = Alignment.bottomCenter;
        follower = Alignment.topCenter;
        break;
      case GenaiPopoverPlacement.top:
        offset = Offset(0, -spacing.s8);
        target = Alignment.topCenter;
        follower = Alignment.bottomCenter;
        break;
      case GenaiPopoverPlacement.right:
        offset = Offset(spacing.s8, 0);
        target = Alignment.centerRight;
        follower = Alignment.centerLeft;
        break;
      case GenaiPopoverPlacement.left:
        offset = Offset(-spacing.s8, 0);
        target = Alignment.centerLeft;
        follower = Alignment.centerRight;
        break;
    }

    _entry = OverlayEntry(builder: (ctx) {
      final colors = ctx.colors;
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: hide,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            offset: offset,
            targetAnchor: target,
            followerAnchor: follower,
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              child: Focus(
                focusNode: _overlayFocus,
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    hide();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Semantics(
                  container: true,
                  label: widget.semanticLabel,
                  scopesRoute: true,
                  explicitChildNodes: true,
                  child: TweenAnimationBuilder<double>(
                    duration: reduced ? Duration.zero : motion.duration,
                    curve: motion.curve,
                    tween: Tween(begin: 0, end: 1),
                    builder: (_, t, c) => Opacity(opacity: t, child: c),
                    child: Container(
                      width: widget.width,
                      padding: effectivePadding,
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
        ],
      );
    });
    overlay.insert(_entry!);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_entry != null) _overlayFocus.requestFocus();
    });
  }

  /// Removes the overlay if present.
  void hide() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  /// Toggles the overlay's visibility.
  void toggle() => _entry == null ? show() : hide();

  @override
  void dispose() {
    _entry?.remove();
    _overlayFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle,
        child: KeyedSubtree(key: _anchorKey, child: widget.child),
      ),
    );
  }
}

// Popovers render on the overlay z-index layer.
// ignore: unused_element
const int _popoverZ = GenaiZIndex.overlay;
