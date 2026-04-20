import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Floating Action Button (§6.2.5).
///
/// Optional [label] turns the FAB into an extended FAB. Hide-on-scroll behavior
/// must be handled by the caller (e.g., wrapping in `AnimatedSlide`).
class GenaiFAB extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final GenaiSize size;
  final String? tooltip;
  final String semanticLabel;

  const GenaiFAB({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.label,
    this.onPressed,
    this.size = GenaiSize.lg,
    this.tooltip,
  });

  bool get _isDisabled => onPressed == null;

  @override
  State<GenaiFAB> createState() => _GenaiFABState();
}

class _GenaiFABState extends State<GenaiFAB> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final elevation = context.elevation;
    final ty = context.typography;
    final h = widget.size.resolveHeight(isCompact: context.isCompact);
    final disabled = widget._isDisabled;

    final bg = _pressed ? colors.colorPrimaryPressed : (_hovered ? colors.colorPrimaryHover : colors.colorPrimary);
    final fg = colors.textOnPrimary;

    final children = <Widget>[
      Icon(widget.icon, size: widget.size.iconSize, color: fg),
    ];
    if (widget.label != null) {
      children.add(SizedBox(width: widget.size.gap));
      children.add(Text(widget.label!, style: ty.label.copyWith(color: fg)));
    }

    Widget btn = AnimatedScale(
      scale: _pressed ? GenaiInteraction.pressScale : 1.0,
      duration: _pressed ? GenaiDurations.pressIn : GenaiDurations.pressOut,
      child: AnimatedContainer(
        duration: GenaiDurations.hover,
        height: h,
        constraints: BoxConstraints(minWidth: h),
        padding: widget.label == null ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: widget.size.paddingH),
        decoration: BoxDecoration(
          color: bg,
          shape: widget.label == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.label == null ? null : BorderRadius.circular(h / 2),
          boxShadow: elevation.shadow(_hovered ? 4 : 3),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );

    btn = Opacity(
      opacity: disabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: btn,
    );

    btn = MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTap: disabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              },
        child: btn,
      ),
    );

    btn = Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel,
      child: btn,
    );

    if (widget.tooltip != null) {
      btn = Tooltip(
        message: widget.tooltip!,
        waitDuration: GenaiDurations.tooltipDelay,
        child: btn,
      );
    }

    return btn;
  }
}
