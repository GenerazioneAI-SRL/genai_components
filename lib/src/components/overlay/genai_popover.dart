import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';

enum GenaiPopoverPlacement { top, bottom, left, right }

/// Anchored popover (§6.5.3).
///
/// Wraps [child] (the trigger) and shows [content] in an overlay anchored
/// to the trigger when tapped. Closes on outside tap or `Esc`.
class GenaiPopover extends StatefulWidget {
  final Widget child;
  final WidgetBuilder content;
  final GenaiPopoverPlacement placement;
  final double width;
  final EdgeInsets padding;

  const GenaiPopover({
    super.key,
    required this.child,
    required this.content,
    this.placement = GenaiPopoverPlacement.bottom,
    this.width = 240,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  State<GenaiPopover> createState() => GenaiPopoverState();
}

class GenaiPopoverState extends State<GenaiPopover> {
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _entry;

  void show() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset offset;
    Alignment target;
    Alignment follower;
    switch (widget.placement) {
      case GenaiPopoverPlacement.bottom:
        offset = const Offset(0, 8);
        target = Alignment.bottomCenter;
        follower = Alignment.topCenter;
        break;
      case GenaiPopoverPlacement.top:
        offset = const Offset(0, -8);
        target = Alignment.topCenter;
        follower = Alignment.bottomCenter;
        break;
      case GenaiPopoverPlacement.right:
        offset = const Offset(8, 0);
        target = Alignment.centerRight;
        follower = Alignment.centerLeft;
        break;
      case GenaiPopoverPlacement.left:
        offset = const Offset(-8, 0);
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
              child: TweenAnimationBuilder<double>(
                duration: GenaiDurations.dropdownOpen,
                tween: Tween(begin: 0, end: 1),
                builder: (_, t, c) => Opacity(opacity: t, child: c),
                child: Container(
                  width: widget.width,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.borderDefault),
                    boxShadow: ctx.elevation.shadow(3),
                  ),
                  child: widget.content(ctx),
                ),
              ),
            ),
          ),
        ],
      );
    });
    overlay.insert(_entry!);
    setState(() {});
  }

  void hide() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void toggle() => _entry == null ? show() : hide();

  @override
  void dispose() {
    _entry?.remove();
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
