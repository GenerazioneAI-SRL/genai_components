import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single-panel expand/collapse — v3 design system.
///
/// Unlike [GenaiAccordion], there is no grouping — this is a one-shot toggle.
/// Animates body via [AnimatedSize] using `context.motion.expand`. Chevron
/// rotates 180° on open. When [bordered] is true, wraps in a `xl` radius
/// card-like border.
class GenaiCollapsible extends StatefulWidget {
  /// Trigger text (used when [headerWidget] is null).
  final String title;

  /// Custom header widget — takes precedence over [title] if provided.
  final Widget? headerWidget;

  /// Body revealed on expand.
  final Widget body;

  /// Initial open state.
  final bool initiallyOpen;

  /// Callback when open state changes.
  final ValueChanged<bool>? onOpenChanged;

  /// Accessible label for the trigger. Defaults to [title].
  final String? semanticLabel;

  /// When true, renders a thin border + `xl` radius around the entire
  /// collapsible. Useful standalone; disable when embedding in a card.
  final bool bordered;

  const GenaiCollapsible({
    super.key,
    required this.title,
    required this.body,
    this.headerWidget,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.semanticLabel,
    this.bordered = true,
  });

  @override
  State<GenaiCollapsible> createState() => _GenaiCollapsibleState();
}

class _GenaiCollapsibleState extends State<GenaiCollapsible> {
  late bool _open;
  bool _hovered = false;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'GenaiCollapsible');

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyOpen;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    widget.onOpenChanged?.call(_open);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _toggle();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final headerBg = _hovered ? colors.surfaceHover : colors.surfaceCard;

    final header = Container(
      constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
      padding: EdgeInsets.symmetric(
        horizontal: widget.bordered ? spacing.s20 : spacing.s0,
        vertical: spacing.s12,
      ),
      decoration: BoxDecoration(
        color: widget.bordered ? headerBg : null,
        border: _focused
            ? Border.all(
                color: colors.borderFocus,
                width: sizing.focusRingWidth,
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: widget.headerWidget ??
                Text(
                  widget.title,
                  style: ty.cardTitle.copyWith(color: colors.textPrimary),
                ),
          ),
          SizedBox(width: spacing.s8),
          AnimatedRotation(
            turns: _open ? 0.5 : 0,
            duration: motion.expand.duration,
            curve: motion.expand.curve,
            child: Icon(
              LucideIcons.chevronDown,
              size: sizing.iconSize,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          label: widget.semanticLabel ?? widget.title,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _onKey,
            onFocusChange: (v) => setState(() => _focused = v),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.opaque,
                child: header,
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: motion.expand.duration,
          curve: motion.expand.curve,
          alignment: Alignment.topCenter,
          child: _open
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    widget.bordered ? spacing.s20 : spacing.s0,
                    spacing.s8,
                    widget.bordered ? spacing.s20 : spacing.s0,
                    widget.bordered ? spacing.s16 : spacing.s0,
                  ),
                  child: widget.body,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );

    if (widget.bordered) {
      content = Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(radius.xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return content;
  }
}
