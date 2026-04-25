import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Size scale for [GenaiFab] — v3 design system (Forma LMS).
///
/// Forma LMS dashboards rarely surface a FAB (decision-first hero handles
/// the role via [GenaiFocusCard]); this component is kept for parity with
/// v1 / v2 and for secondary apps that need a mobile-style overlay action.
enum GenaiFabSize {
  /// 48 px diameter — compact secondary FAB.
  md,

  /// 56 px diameter — default primary FAB.
  lg,

  /// 64 px diameter — prominent CTA.
  xl,
}

/// Floating Action Button — v3 design system (Forma LMS).
///
/// Optional [label] turns the FAB into an extended (pill-shaped) FAB. Primary
/// color is the ink CTA (`colorPrimary`), not info blue — matching the
/// decision-first palette of v3.
class GenaiFab extends StatefulWidget {
  /// Required icon glyph.
  final IconData icon;

  /// Optional label. When non-null, FAB renders as an extended pill.
  final String? label;

  /// Tap callback. `null` disables.
  final VoidCallback? onPressed;

  /// Size scale.
  final GenaiFabSize size;

  /// Tooltip shown on hover.
  final String? tooltip;

  /// Required screen-reader label.
  final String semanticLabel;

  const GenaiFab({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.label,
    this.onPressed,
    this.size = GenaiFabSize.lg,
    this.tooltip,
  });

  bool get _isDisabled => onPressed == null;

  double get _dimension {
    switch (size) {
      case GenaiFabSize.md:
        return 48;
      case GenaiFabSize.lg:
        return 56;
      case GenaiFabSize.xl:
        return 64;
    }
  }

  double get _iconSize {
    switch (size) {
      case GenaiFabSize.md:
        return 20;
      case GenaiFabSize.lg:
        return 24;
      case GenaiFabSize.xl:
        return 28;
    }
  }

  @override
  State<GenaiFab> createState() => _GenaiFabState();
}

class _GenaiFabState extends State<GenaiFab> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final elevation = context.elevation;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final h = widget._dimension;
    final disabled = widget._isDisabled;

    final bg = _pressed
        ? colors.colorPrimaryPressed
        : (_hovered ? colors.colorPrimaryHover : colors.colorPrimary);
    final fg = colors.textOnPrimary;

    // Horizontal padding for extended FAB maps roughly to 1/3 the diameter
    // in v2/v3; clamp via raw spacing stops so pills look balanced across
    // sizes without hardcoding.
    final paddingH = switch (widget.size) {
      GenaiFabSize.md => spacing.s16,
      GenaiFabSize.lg => spacing.s20,
      GenaiFabSize.xl => spacing.s24,
    };

    final children = <Widget>[
      Icon(widget.icon, size: widget._iconSize, color: fg),
    ];
    if (widget.label != null) {
      children.add(SizedBox(width: spacing.s8));
      children.add(Text(widget.label!, style: ty.label.copyWith(color: fg)));
    }

    Widget btn = Container(
      height: h,
      constraints: BoxConstraints(minWidth: h),
      padding: widget.label == null
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: paddingH),
      decoration: BoxDecoration(
        color: bg,
        shape: widget.label == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            widget.label == null ? null : BorderRadius.circular(h / 2),
        boxShadow: elevation.shadowForLayer(_hovered ? 3 : 2),
      ),
      child: Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );

    btn = Opacity(opacity: disabled ? 0.5 : 1.0, child: btn);

    // Focus ring as non-layout overlay → bounds remain stable on focus.
    if (_focused && !disabled) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(
            left: -sizing.focusRingOffset,
            top: -sizing.focusRingOffset,
            right: -sizing.focusRingOffset,
            bottom: -sizing.focusRingOffset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: widget.label == null
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: widget.label == null
                      ? null
                      : BorderRadius.circular(h / 2 + sizing.focusRingOffset),
                  border: Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    btn = MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      opaque: false,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered || _pressed) {
          setState(() {
            _hovered = false;
            _pressed = false;
          });
        }
      },
      child: Focus(
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
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
      ),
    );

    btn = Semantics(
      button: true,
      enabled: !disabled,
      focused: _focused,
      label: widget.semanticLabel,
      child: btn,
    );

    if (widget.tooltip != null) {
      btn = Tooltip(message: widget.tooltip!, child: btn);
    }

    return btn;
  }
}
