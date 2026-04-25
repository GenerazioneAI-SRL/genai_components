import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// One item inside a [GenaiAccordion]. Opaque data class — no build logic.
@immutable
class GenaiAccordionItem {
  /// Stable id used for keyboard navigation and open-state tracking.
  final String id;

  /// Header text (or use [headerWidget] for custom).
  final String title;

  /// Custom header widget — takes precedence over [title] if provided.
  final Widget? headerWidget;

  /// Body content — revealed when expanded.
  final Widget body;

  /// Optional leading widget before the title (icon, avatar).
  final Widget? leading;

  /// Whether this item is disabled.
  final bool isDisabled;

  const GenaiAccordionItem({
    required this.id,
    required this.title,
    required this.body,
    this.headerWidget,
    this.leading,
    this.isDisabled = false,
  });
}

/// Multi-item accordion — v3 design system.
///
/// Outer chrome: 1 px hairline border + `xl` radius (matches v3 card).
/// Interior: hairline dividers between rows, chevron rotates 180° on expand
/// using `context.motion.expand`. Keyboard: Up/Down moves focus between
/// headers, Enter/Space toggles, Home/End jumps.
class GenaiAccordion extends StatefulWidget {
  /// Ordered list of items.
  final List<GenaiAccordionItem> items;

  /// When false (default), multiple panels can be open at once. When true,
  /// opening one closes the others.
  final bool singleOpen;

  /// Initially open ids.
  final Set<String> initiallyOpen;

  /// Notifier fired when open set changes.
  final ValueChanged<Set<String>>? onOpenChanged;

  const GenaiAccordion({
    super.key,
    required this.items,
    this.singleOpen = false,
    this.initiallyOpen = const {},
    this.onOpenChanged,
  });

  @override
  State<GenaiAccordion> createState() => _GenaiAccordionState();
}

class _GenaiAccordionState extends State<GenaiAccordion> {
  late Set<String> _open;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _open = {...widget.initiallyOpen};
    _focusNodes = List.generate(
      widget.items.length,
      (i) => FocusNode(debugLabel: 'GenaiAccordion[${widget.items[i].id}]'),
    );
  }

  @override
  void didUpdateWidget(GenaiAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      for (final n in _focusNodes) {
        n.dispose();
      }
      _focusNodes = List.generate(
        widget.items.length,
        (i) => FocusNode(debugLabel: 'GenaiAccordion[${widget.items[i].id}]'),
      );
    }
  }

  @override
  void dispose() {
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_open.contains(id)) {
        _open = {..._open}..remove(id);
      } else {
        if (widget.singleOpen) {
          _open = {id};
        } else {
          _open = {..._open, id};
        }
      }
    });
    widget.onOpenChanged?.call(_open);
  }

  void _focusAt(int index) {
    if (index < 0 || index >= widget.items.length) return;
    _focusNodes[index].requestFocus();
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _focusAt(index + 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _focusAt(index - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusAt(0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusAt(widget.items.length - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      final item = widget.items[index];
      if (!item.isDisabled) _toggle(item.id);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(radius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            _AccordionRow(
              item: widget.items[i],
              expanded: _open.contains(widget.items[i].id),
              isFirst: i == 0,
              isLast: i == widget.items.length - 1,
              focusNode: _focusNodes[i],
              onTap: widget.items[i].isDisabled
                  ? null
                  : () => _toggle(widget.items[i].id),
              onKeyEvent: (event) => _handleKey(i, event),
            ),
            if (i != widget.items.length - 1)
              Container(
                height: sizing.dividerThickness,
                color: colors.borderSubtle,
              ),
          ],
        ],
      ),
    );
  }
}

class _AccordionRow extends StatefulWidget {
  final GenaiAccordionItem item;
  final bool expanded;
  final bool isFirst;
  final bool isLast;
  final FocusNode focusNode;
  final VoidCallback? onTap;
  final KeyEventResult Function(KeyEvent) onKeyEvent;

  const _AccordionRow({
    required this.item,
    required this.expanded,
    required this.isFirst,
    required this.isLast,
    required this.focusNode,
    required this.onTap,
    required this.onKeyEvent,
  });

  @override
  State<_AccordionRow> createState() => _AccordionRowState();
}

class _AccordionRowState extends State<_AccordionRow> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    final disabled = widget.item.isDisabled;

    final headerBg =
        _hovered && !disabled ? colors.surfaceHover : colors.surfaceCard;

    final headerContent = Container(
      constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s20,
        vertical: spacing.s12,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: _focused
            ? Border.all(
                color: colors.borderFocus,
                width: sizing.focusRingWidth,
              )
            : null,
      ),
      child: Row(
        children: [
          if (widget.item.leading != null) ...[
            widget.item.leading!,
            SizedBox(width: spacing.iconLabelGap),
          ],
          Expanded(
            child: widget.item.headerWidget ??
                Text(
                  widget.item.title,
                  style: ty.cardTitle.copyWith(
                    color: disabled ? colors.textDisabled : colors.textPrimary,
                  ),
                ),
          ),
          SizedBox(width: spacing.s8),
          AnimatedRotation(
            turns: widget.expanded ? 0.5 : 0,
            duration: motion.expand.duration,
            curve: motion.expand.curve,
            child: Icon(
              LucideIcons.chevronDown,
              size: sizing.iconSize,
              color: disabled ? colors.textDisabled : colors.textSecondary,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      expanded: widget.expanded,
      enabled: !disabled,
      label: widget.item.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Focus(
            focusNode: widget.focusNode,
            onKeyEvent: (node, event) => widget.onKeyEvent(event),
            onFocusChange: (v) => setState(() => _focused = v),
            child: MouseRegion(
              cursor: disabled
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                onTap: widget.onTap,
                behavior: HitTestBehavior.opaque,
                child: headerContent,
              ),
            ),
          ),
          AnimatedSize(
            duration: motion.expand.duration,
            curve: motion.expand.curve,
            alignment: Alignment.topCenter,
            child: widget.expanded
                ? Container(
                    padding: EdgeInsets.fromLTRB(
                      spacing.s20,
                      spacing.s4,
                      spacing.s20,
                      spacing.s16,
                    ),
                    color: colors.surfaceCard,
                    width: double.infinity,
                    child: DefaultTextStyle.merge(
                      style: ty.bodySm.copyWith(color: colors.textSecondary),
                      child: widget.item.body,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
