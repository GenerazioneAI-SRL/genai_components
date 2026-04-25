import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Vertical list container — v3 design system.
///
/// Stacks [children] top-to-bottom with optional hairline dividers between
/// rows and an optional rounded bordered frame. Pure layout primitive — each
/// child supplies its own padding / interaction.
class GenaiList extends StatelessWidget {
  /// Rows rendered in order.
  final List<Widget> children;

  /// Whether to render a hairline divider between rows. Defaults to `true`.
  final bool showDividers;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  /// When true, wraps the list in a rounded bordered container.
  final bool bordered;

  const GenaiList({
    super.key,
    required this.children,
    this.showDividers = true,
    this.padding = EdgeInsets.zero,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;

    final list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && showDividers)
            Container(
              height: sizing.dividerThickness,
              color: colors.borderSubtle,
            ),
          children[i],
        ],
      ],
    );

    if (!bordered) {
      return Padding(padding: padding, child: list);
    }
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.xl),
          border: Border.all(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: list,
      ),
    );
  }
}

/// Single list row — v3 design system.
///
/// States handled: default, hover, focused, selected, disabled (via
/// `onTap == null`). Uses `minTouchTarget` for a generous tap target and
/// respects the hover motion token.
class GenaiListItem extends StatefulWidget {
  /// Optional leading widget (avatar, icon).
  final Widget? leading;

  /// Primary text (required).
  final String title;

  /// Optional secondary line.
  final String? subtitle;

  /// Optional tertiary line.
  final String? description;

  /// Optional trailing widget (chevron, switch, icon).
  final Widget? trailing;

  /// Tap callback. When null the row is non-interactive.
  final VoidCallback? onTap;

  /// Whether the row is visually marked as selected.
  final bool isSelected;

  /// Accessibility label — defaults to [title].
  final String? semanticLabel;

  const GenaiListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.description,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.semanticLabel,
  });

  @override
  State<GenaiListItem> createState() => _GenaiListItemState();
}

class _GenaiListItemState extends State<GenaiListItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final bg = widget.isSelected
        ? colors.colorPrimarySubtle
        : (_hovered && widget.onTap != null
            ? colors.surfaceHover
            : Colors.transparent);

    Widget row = Container(
      constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s20,
        vertical: spacing.s14,
      ),
      color: bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            SizedBox(width: spacing.s12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: ty.body.copyWith(color: colors.textPrimary),
                ),
                if (widget.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s2),
                    child: Text(
                      widget.subtitle!,
                      style: ty.bodySm.copyWith(color: colors.textSecondary),
                    ),
                  ),
                if (widget.description != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s4),
                    child: Text(
                      widget.description!,
                      style: ty.labelSm.copyWith(color: colors.textTertiary),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            SizedBox(width: spacing.s12),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (_focused) {
      row = Stack(
        clipBehavior: Clip.none,
        children: [
          row,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
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

    final semanticsChild = Semantics(
      button: widget.onTap != null,
      selected: widget.isSelected,
      label: widget.semanticLabel ?? widget.title,
      child: row,
    );

    if (widget.onTap == null) return semanticsChild;

    return FocusableActionDetector(
      onShowHoverHighlight: (v) {
        if (_hovered != v) setState(() => _hovered = v);
      },
      onShowFocusHighlight: (v) {
        if (_focused != v) setState(() => _focused = v);
      },
      mouseCursor: SystemMouseCursors.click,
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
        onTap: widget.onTap,
        child: semanticsChild,
      ),
    );
  }
}
