import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Visual style of a [GenaiButton] — v3 design system (Forma LMS §4.1).
///
/// v3 drops `outline` (folded into `secondary`) because the Dashboard v3.html
/// reference renders secondary as a panel-fill with a strong 1 px border —
/// making a separate outline variant redundant. Keep the v2 enum shape
/// otherwise so swapping libraries via `import as` is a pure rename.
enum GenaiButtonVariant {
  /// Solid ink fill (`colorPrimary = #0d1220`), white label. Page hero CTA.
  primary,

  /// Panel-white fill with a strong `line-2` border. Hover flips the border
  /// to ink. Default secondary action.
  secondary,

  /// Transparent background, ink-2 label. Hover promotes label to ink.
  ghost,

  /// Danger accent fill — destructive confirmation.
  destructive,
}

/// Size scale for [GenaiButton] and its siblings — v3 Forma LMS §4.1.
///
/// Dashboard v3.html ships a single 38 px (9 px vertical padding + ~20 content)
/// button; [GenaiButtonSize.md] matches that. `sm` and `lg` are kept for
/// dense toolbars and mobile-first hero CTAs respectively.
enum GenaiButtonSize {
  /// 28 px visual height — dense toolbars, chip-adjacent.
  sm,

  /// 36 px visual height — default, matches `.btn` in the v3 reference.
  md,

  /// 44 px visual height — hero CTA, compact-window primary.
  lg,
}

/// Geometric and typographic specs resolved from a [GenaiButtonSize].
///
/// Shared with sibling action widgets so the size scale stays consistent
/// across the category. Values align with the v3 `.btn` rule:
/// `padding: 9px 14px; font-size: 13px; border-radius: 8px;`.
class GenaiButtonSpec {
  /// Visual button height.
  final double height;

  /// Inline icon glyph size.
  final double iconSize;

  /// Horizontal inner padding.
  final double paddingH;

  /// Icon ↔ label gap.
  final double gap;

  const GenaiButtonSpec._({
    required this.height,
    required this.iconSize,
    required this.paddingH,
    required this.gap,
  });

  /// Resolve a spec for the given size, using v3 tokens.
  factory GenaiButtonSpec.resolve(BuildContext context, GenaiButtonSize size) {
    final spacing = context.spacing;
    switch (size) {
      case GenaiButtonSize.sm:
        return GenaiButtonSpec._(
          height: 28,
          iconSize: 14,
          paddingH: spacing.s10,
          gap: spacing.s6,
        );
      case GenaiButtonSize.md:
        return GenaiButtonSpec._(
          height: 36,
          iconSize: 16,
          paddingH: spacing.s14, // 14 px matches `.btn` horizontal padding.
          gap: spacing.s8,
        );
      case GenaiButtonSize.lg:
        return GenaiButtonSpec._(
          height: 44,
          iconSize: 18,
          paddingH: spacing.s18,
          gap: spacing.s8,
        );
    }
  }

  /// Typography paired with this size — resolved against v3 typography.
  ///
  /// v3 type scale has no `labelMd` (13/500); the closest match is `label`
  /// (12/500). `labelSm` (11.5/500) is used for the dense `sm` button.
  TextStyle labelStyleFor(BuildContext context) {
    final ty = context.typography;
    if (height <= 28) return ty.labelSm;
    return ty.label;
  }
}

/// Primary action button — v3 design system (Forma LMS §4.1).
///
/// Use one of the named constructors to select the variant:
/// - [GenaiButton.primary] — ink hero CTA.
/// - [GenaiButton.secondary] — panel-white with border.
/// - [GenaiButton.ghost] — transparent, label-only.
/// - [GenaiButton.destructive] — delete / revoke / dangerous confirmation.
///
/// v3 polish vs. v2:
/// - Corner radius flips from `radius.sm` to `radius.md` (8 px) to match
///   `.btn { border-radius: 8px }` in the reference HTML.
/// - Secondary hover darkens the border to ink rather than tinting the
///   background — no fill shift per §2.6.
/// - Ghost foreground starts at `textSecondary` (ink-2) and promotes to
///   `textPrimary` on hover.
class GenaiButton extends StatefulWidget {
  /// Text label. Omit for icon-only (prefer [GenaiIconButton] in that case).
  final String? label;

  /// Leading icon shown before the label.
  final IconData? icon;

  /// Trailing icon shown after the label.
  final IconData? trailingIcon;

  /// Tap callback. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual variant.
  final GenaiButtonVariant variant;

  /// Visual size.
  final GenaiButtonSize size;

  /// When `true`, replaces the label with a spinner and suppresses taps.
  final bool isLoading;

  /// When `true`, expands to the parent's available width.
  final bool isFullWidth;

  /// Tooltip shown on hover (desktop). When disabled, explains *why*.
  final String? tooltip;

  /// Screen-reader label. Falls back to [label] when omitted.
  final String? semanticLabel;

  const GenaiButton({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = GenaiButtonVariant.primary,
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.ghost;

  const GenaiButton.destructive({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiButtonSize.md,
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
    final sizing = context.sizing;
    final radius = context.radius.md; // v3 `.btn { border-radius: 8px }`.
    final spec = GenaiButtonSpec.resolve(context, widget.size);

    final disabled = widget._isDisabled || widget.isLoading;
    final colorset = _resolveColors();
    final fg = _resolveFg(colorset);
    final bg = _resolveBg(colorset);
    final borderColor = _resolveBorderColor(colorset);
    final child = _buildContent(fg, spec);

    Widget button = Container(
      height: spec.height,
      constraints: BoxConstraints(minWidth: spec.height),
      padding: EdgeInsets.symmetric(horizontal: spec.paddingH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor, width: sizing.dividerThickness),
      ),
      child: Center(child: child),
    );

    Widget result = Opacity(opacity: disabled ? 0.5 : 1.0, child: button);

    if (widget.isFullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    // Focus ring is a non-layout overlay so hit-test bounds stay stable
    // when focus toggles on click → prevents hover/focus blink loops.
    if (_focused && !disabled) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            left: -sizing.focusRingOffset,
            top: -sizing.focusRingOffset,
            right: -sizing.focusRingOffset,
            bottom: -sizing.focusRingOffset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.radius.xs + sizing.focusRingOffset,
                  ),
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

    result = MouseRegion(
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

    // Enforce the 44 px touch-target floor without inflating the visual box.
    if (spec.height < sizing.minTouchTarget) {
      result = ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
        child: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: result,
        ),
      );
    }

    result = Semantics(
      button: true,
      enabled: !disabled,
      focused: _focused,
      label: widget.semanticLabel ?? widget.label,
      child: result,
    );

    if (widget.tooltip != null) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }

    return result;
  }

  Widget _buildContent(Color fg, GenaiButtonSpec spec) {
    if (widget.isLoading) {
      return SizedBox(
        height: spec.iconSize,
        width: spec.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: context.sizing.focusRingWidth,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    }

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: spec.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: spec.gap));
      children.add(
        Text(
          widget.label!,
          style: spec.labelStyleFor(context).copyWith(color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (widget.trailingIcon != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: spec.gap));
      children.add(
        Icon(widget.trailingIcon, size: spec.iconSize, color: fg),
      );
    }

    if (children.isEmpty) {
      return SizedBox(width: spec.iconSize, height: spec.iconSize);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  _ButtonColors _resolveColors() {
    final colors = context.colors;
    switch (widget.variant) {
      case GenaiButtonVariant.primary:
        return _ButtonColors(
          bg: colors.colorPrimary,
          bgHover: colors.colorPrimaryHover,
          bgPressed: colors.colorPrimaryPressed,
          fg: colors.textOnPrimary,
          fgHover: colors.textOnPrimary,
        );
      case GenaiButtonVariant.secondary:
        // `.btn-s` — panel bg, `--line-2` border, ink text. Hover flips the
        // border to `--ink`, no fill shift (§2.6).
        return _ButtonColors(
          bg: colors.surfaceCard,
          bgHover: colors.surfaceCard,
          bgPressed: colors.surfacePressed,
          fg: colors.textPrimary,
          fgHover: colors.textPrimary,
          borderColor: colors.borderStrong,
          borderColorHover: colors.textPrimary,
        );
      case GenaiButtonVariant.ghost:
        // `.btn-ghost` — transparent bg, ink-2 text → ink on hover.
        return _ButtonColors(
          bg: Colors.transparent,
          bgHover: Colors.transparent,
          bgPressed: colors.surfacePressed,
          fg: colors.textSecondary,
          fgHover: colors.textPrimary,
        );
      case GenaiButtonVariant.destructive:
        return _ButtonColors(
          bg: colors.colorDanger,
          bgHover: colors.colorDanger,
          bgPressed: colors.colorDanger,
          fg: colors.textOnPrimary,
          fgHover: colors.textOnPrimary,
        );
    }
  }

  Color _resolveBg(_ButtonColors set) {
    if (_pressed) return set.bgPressed;
    if (_hovered) return set.bgHover;
    return set.bg;
  }

  Color _resolveFg(_ButtonColors set) {
    if (_hovered || _pressed) return set.fgHover;
    return set.fg;
  }

  Color? _resolveBorderColor(_ButtonColors set) {
    if (_hovered || _pressed) return set.borderColorHover ?? set.borderColor;
    return set.borderColor;
  }
}

class _ButtonColors {
  final Color bg;
  final Color bgHover;
  final Color bgPressed;
  final Color fg;
  final Color fgHover;
  final Color? borderColor;
  final Color? borderColorHover;

  const _ButtonColors({
    required this.bg,
    required this.bgHover,
    required this.bgPressed,
    required this.fg,
    required this.fgHover,
    this.borderColor,
    this.borderColorHover,
  });
}
