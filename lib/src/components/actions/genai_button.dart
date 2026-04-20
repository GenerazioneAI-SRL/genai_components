import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Visual style of a [GenaiButton].
enum GenaiButtonVariant {
  primary,
  secondary,
  ghost,
  outline,
  destructive,
}

/// A button from the Genai design system.
///
/// Usually constructed with one of the named constructors:
/// - [GenaiButton.primary] — main page CTA
/// - [GenaiButton.secondary] — alternative action, reduced emphasis
/// - [GenaiButton.ghost] — tertiary, no fill
/// - [GenaiButton.outline] — border, no fill
/// - [GenaiButton.destructive] — delete / reset / revoke
///
/// Loading state replaces the label with a spinner of the same width to
/// avoid layout shift (§6.2.1).
class GenaiButton extends StatefulWidget {
  /// Optional text label (omit for icon-only buttons; prefer [GenaiIconButton] in that case).
  final String? label;

  /// Leading icon shown before the label.
  final IconData? icon;

  /// Trailing icon shown after the label.
  final IconData? trailingIcon;

  /// Tap callback. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual variant.
  final GenaiButtonVariant variant;

  /// Sizing token §2.4.
  final GenaiSize size;

  /// When `true`, replaces the label with a spinner and prevents interaction.
  final bool isLoading;

  /// When `true`, expands to the parent's available width. Recommended for
  /// primary actions on `compact` window size (§6.2.1).
  final bool isFullWidth;

  /// Tooltip shown on hover (desktop). When the button is disabled, it should
  /// explain *why* (§7.8.2).
  final String? tooltip;

  /// Semantic label for screen readers. Falls back to [label] when omitted.
  final String? semanticLabel;

  const GenaiButton({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = GenaiButtonVariant.primary,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  });

  const GenaiButton.primary({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.primary;

  const GenaiButton.secondary({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.secondary;

  const GenaiButton.ghost({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.ghost;

  const GenaiButton.outline({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.outline;

  const GenaiButton.destructive({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.destructive;

  bool get _isDisabled => onPressed == null;

  @override
  State<GenaiButton> createState() => _GenaiButtonState();
}

class _GenaiButtonState extends State<GenaiButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = widget.size.borderRadius;
    final isCompact = context.isCompact;
    final height = widget.size.resolveHeight(isCompact: isCompact);

    final colorset = _resolveColors(colors);
    final bg = _resolveBg(colorset);
    final fg = colorset.fg;
    final border = _resolveBorder(colorset);

    final child = _buildContent(fg);
    final disabled = widget._isDisabled || widget.isLoading;

    Widget button = AnimatedScale(
      scale: _pressed ? GenaiInteraction.pressScale : 1.0,
      duration: _pressed ? GenaiDurations.pressIn : GenaiDurations.pressOut,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: GenaiDurations.hover,
        curve: Curves.easeOut,
        height: height,
        constraints: BoxConstraints(minWidth: height),
        padding: EdgeInsets.symmetric(horizontal: widget.size.paddingH),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: border,
        ),
        child: Center(child: child),
      ),
    );

    if (_focused && !disabled) {
      button = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius + 2),
          border: Border.all(color: colors.borderFocus, width: 2),
        ),
        padding: const EdgeInsets.all(2),
        child: button,
      );
    }

    Widget result = Opacity(
      opacity: widget._isDisabled ? GenaiInteraction.disabledOpacity : (widget.isLoading ? GenaiInteraction.loadingOpacity : 1.0),
      child: button,
    );

    if (widget.isFullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    result = Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: MouseRegion(
        cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
          onTapCancel: disabled ? null : () => setState(() => _pressed = false),
          onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  widget.onPressed?.call();
                },
          child: result,
        ),
      ),
    );

    result = Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel ?? widget.label,
      child: result,
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        waitDuration: GenaiDurations.tooltipDelay,
        child: result,
      );
    }

    return result;
  }

  Widget _buildContent(Color fg) {
    if (widget.isLoading) {
      return SizedBox(
        height: widget.size.iconSize,
        width: widget.size.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    }

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: widget.size.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: widget.size.gap));
      children.add(
        Text(
          widget.label!,
          style: _labelStyle(fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (widget.trailingIcon != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: widget.size.gap));
      children.add(Icon(widget.trailingIcon, size: widget.size.iconSize, color: fg));
    }

    if (children.isEmpty) {
      // Fallback for misuse: render an empty box at the icon size.
      return SizedBox(width: widget.size.iconSize, height: widget.size.iconSize);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  TextStyle _labelStyle(Color fg) {
    final ty = context.typography;
    final base = widget.size == GenaiSize.xs ? ty.labelSm : ty.label;
    return base.copyWith(
      color: fg,
      fontSize: widget.size == GenaiSize.lg || widget.size == GenaiSize.xl ? widget.size.fontSize : base.fontSize,
    );
  }

  _ButtonColors _resolveColors(dynamic colors) {
    switch (widget.variant) {
      case GenaiButtonVariant.primary:
        return _ButtonColors(
          bg: colors.colorPrimary,
          bgHover: colors.colorPrimaryHover,
          bgPressed: colors.colorPrimaryPressed,
          fg: colors.textOnPrimary,
        );
      case GenaiButtonVariant.secondary:
        return _ButtonColors(
          bg: colors.surfaceCard,
          bgHover: colors.surfaceHover,
          bgPressed: colors.surfacePressed,
          fg: colors.textPrimary,
          borderColor: colors.borderDefault,
        );
      case GenaiButtonVariant.ghost:
        return _ButtonColors(
          bg: Colors.transparent,
          bgHover: colors.surfaceHover,
          bgPressed: colors.surfacePressed,
          fg: colors.textPrimary,
        );
      case GenaiButtonVariant.outline:
        return _ButtonColors(
          bg: Colors.transparent,
          bgHover: colors.surfaceHover,
          bgPressed: colors.surfacePressed,
          fg: colors.textPrimary,
          borderColor: colors.borderStrong,
        );
      case GenaiButtonVariant.destructive:
        return _ButtonColors(
          bg: colors.colorError,
          bgHover: colors.colorErrorHover,
          bgPressed: colors.colorErrorHover,
          fg: Colors.white,
        );
    }
  }

  Color _resolveBg(_ButtonColors set) {
    if (_pressed) return set.bgPressed;
    if (_hovered) return set.bgHover;
    return set.bg;
  }

  BoxBorder? _resolveBorder(_ButtonColors set) {
    if (set.borderColor == null) return null;
    return Border.all(color: set.borderColor!, width: widget.size.borderWidth);
  }
}

class _ButtonColors {
  final Color bg;
  final Color bgHover;
  final Color bgPressed;
  final Color fg;
  final Color? borderColor;

  const _ButtonColors({
    required this.bg,
    required this.bgHover,
    required this.bgPressed,
    required this.fg,
    this.borderColor,
  });
}
