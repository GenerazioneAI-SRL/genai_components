import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Generic row primitive (shadcn parity: `<Item>`) — v3 design system.
///
/// Building block for list rows, menu items, command results, settings rows.
/// Renders `Row(leading, gap, Expanded(child), gap, trailing)` with token-
/// driven padding, hover/selected/disabled visuals, and a touch target floor
/// equal to the current density's `minTouchTarget`.
///
/// v3 selected rows tint with `colorPrimarySubtle`; hover uses `surfaceHover`.
/// Body uses the v3 `bodySm` style by default (matches list rows in the Forma
/// LMS reference HTML).
class GenaiItem extends StatefulWidget {
  /// Leading slot — typically an icon or avatar.
  final Widget? leading;

  /// Trailing slot — typically a chevron, kbd shortcut, or badge.
  final Widget? trailing;

  /// Main content.
  final Widget child;

  /// Tap handler. Null disables interaction.
  final VoidCallback? onTap;

  /// When true, applies the selected background tint.
  final bool isSelected;

  /// When true, dims content and disables interaction.
  final bool isDisabled;

  /// Override the default token-driven padding.
  final EdgeInsetsGeometry? padding;

  /// Accessibility label for the whole row.
  final String? semanticLabel;

  const GenaiItem({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.padding,
    this.semanticLabel,
  });

  @override
  State<GenaiItem> createState() => _GenaiItemState();
}

class _GenaiItemState extends State<GenaiItem> {
  bool _hovered = false;
  bool _focused = false;

  bool get _interactive => widget.onTap != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final bg = widget.isSelected
        ? colors.colorPrimarySubtle
        : (_hovered && _interactive ? colors.surfaceHover : Colors.transparent);

    final padding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: spacing.s12,
          vertical: spacing.s8,
        );

    final iconColor = widget.isDisabled
        ? colors.textDisabled
        : (widget.isSelected ? colors.colorPrimary : colors.textSecondary);

    return Semantics(
      button: widget.onTap != null,
      enabled: _interactive,
      selected: widget.isSelected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _interactive,
        mouseCursor:
            _interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (h) {
          if (_hovered != h) setState(() => _hovered = h);
        },
        onShowFocusHighlight: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _interactive ? widget.onTap : null,
          child: Opacity(
            opacity: widget.isDisabled ? 0.5 : 1,
            child: Container(
              constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
              padding: padding,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius.md),
                border: Border.all(
                  color: _focused ? colors.borderFocus : Colors.transparent,
                  width: sizing.focusRingWidth,
                ),
              ),
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: sizing.iconSize),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      SizedBox(width: spacing.s8),
                    ],
                    Expanded(child: widget.child),
                    if (widget.trailing != null) ...[
                      SizedBox(width: spacing.s8),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
