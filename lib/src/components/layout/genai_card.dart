import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';

/// Container card (§6.3.1).
///
/// Named constructors:
/// - [GenaiCard.outlined] — border only (default)
/// - [GenaiCard.elevated] — shadow level 2
/// - [GenaiCard.filled] — neutral subtle background, no border
/// - [GenaiCard.interactive] — hover/press states + onTap
class GenaiCard extends StatefulWidget {
  final Widget? child;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final _GenaiCardVariant _variant;
  final Color? backgroundColor;

  const GenaiCard({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  })  : onTap = null,
        _variant = _GenaiCardVariant.outlined;

  const GenaiCard.outlined({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  })  : onTap = null,
        _variant = _GenaiCardVariant.outlined;

  const GenaiCard.elevated({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  })  : onTap = null,
        _variant = _GenaiCardVariant.elevated;

  const GenaiCard.filled({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  })  : onTap = null,
        _variant = _GenaiCardVariant.filled;

  const GenaiCard.interactive({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    required this.onTap,
  }) : _variant = _GenaiCardVariant.interactive;

  @override
  State<GenaiCard> createState() => _GenaiCardState();
}

enum _GenaiCardVariant { outlined, elevated, filled, interactive }

class _GenaiCardState extends State<GenaiCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final elevation = context.elevation;

    Color bg;
    Border? border;
    List<BoxShadow> shadows = const [];

    switch (widget._variant) {
      case _GenaiCardVariant.outlined:
        bg = widget.backgroundColor ?? colors.surfaceCard;
        border = Border.all(color: colors.borderDefault);
        break;
      case _GenaiCardVariant.elevated:
        bg = widget.backgroundColor ?? colors.surfaceCard;
        shadows = elevation.shadow(2);
        break;
      case _GenaiCardVariant.filled:
        bg = widget.backgroundColor ?? colors.surfaceHover;
        break;
      case _GenaiCardVariant.interactive:
        bg = widget.backgroundColor ?? (_pressed ? colors.surfacePressed : (_hovered ? colors.surfaceHover : colors.surfaceCard));
        border = Border.all(color: _hovered ? colors.borderStrong : colors.borderDefault);
        shadows = _hovered ? elevation.shadow(2) : const [];
        break;
    }

    Widget card = AnimatedContainer(
      duration: GenaiDurations.hover,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.lg),
        border: border,
        boxShadow: shadows,
      ),
      child: Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bounded = constraints.maxHeight.isFinite;
            final children = <Widget>[];
            if (widget.header != null) {
              children.add(Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget.header!,
              ));
            }
            if (widget.child != null) {
              children.add(bounded ? Expanded(child: widget.child!) : widget.child!);
            }
            if (widget.footer != null) {
              children.add(Padding(
                padding: const EdgeInsets.only(top: 12),
                child: widget.footer!,
              ));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              children: children,
            );
          },
        ),
      ),
    );

    if (widget._variant == _GenaiCardVariant.interactive) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: card,
        ),
      );
    }

    return card;
  }
}
