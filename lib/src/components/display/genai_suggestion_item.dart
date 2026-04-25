import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// AI-suggested shortcut card — v3 design system (§4.2).
///
/// Small bordered row rendered inside the right column of [GenaiFocusCard]
/// ("Suggeriti per te"). Layout:
/// - 8 px colored dot (intent / accent),
/// - title (13 / 600) + optional subtitle (11.5 / ink-2),
/// - optional right-aligned mono meta (11 / ink-3).
///
/// Card: `surfaceCard` bg, `borderDefault`, `radius.lg` (10), padding 10/12.
/// Hover upgrades the border to `borderStrong`. Tappable when [onTap] is set.
class GenaiSuggestionItem extends StatefulWidget {
  /// Dot color — use intent-bearing tokens (info/ok/warn/danger/neutral).
  final Color dotColor;

  /// Primary title.
  final String title;

  /// Optional secondary line.
  final String? subtitle;

  /// Optional right-aligned mono meta (e.g. time remaining, shortcut).
  final String? metaRight;

  /// Tap callback. Null renders the card as non-interactive.
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to a composed summary.
  final String? semanticLabel;

  const GenaiSuggestionItem({
    super.key,
    required this.dotColor,
    required this.title,
    this.subtitle,
    this.metaRight,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<GenaiSuggestionItem> createState() => _GenaiSuggestionItemState();
}

class _GenaiSuggestionItemState extends State<GenaiSuggestionItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    final isInteractive = widget.onTap != null;
    final a11y = widget.semanticLabel ??
        [
          widget.title,
          if (widget.subtitle != null) widget.subtitle!,
          if (widget.metaRight != null) widget.metaRight!,
        ].join(' — ');

    // Resting border kept at 1 px so layout never reflows on hover/focus.
    final border =
        isInteractive && _hovered ? colors.textPrimary : colors.borderDefault;

    Widget card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s10,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.lg),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: spacing.s8,
            height: spacing.s8,
            decoration: BoxDecoration(
              color: widget.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: spacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: ty.bodySm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (widget.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s2),
                    child: Text(
                      widget.subtitle!,
                      style: ty.labelSm.copyWith(color: colors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.metaRight != null) ...[
            SizedBox(width: spacing.s8),
            Text(
              widget.metaRight!,
              style: ty.monoSm.copyWith(color: colors.textTertiary),
            ),
          ],
        ],
      ),
    );

    // Focus ring overlay so toggling focus doesn't change layout bounds.
    if (_focused && isInteractive) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.lg),
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

    final semanticsNode = Semantics(
      container: true,
      button: isInteractive,
      label: a11y,
      child: card,
    );

    if (!isInteractive) return semanticsNode;

    return FocusableActionDetector(
      onShowFocusHighlight: (v) {
        if (_focused != v) setState(() => _focused = v);
      },
      onShowHoverHighlight: (v) {
        if (_hovered != v) setState(() => _hovered = v);
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
        child: semanticsNode,
      ),
    );
  }
}
