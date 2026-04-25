import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Single tab descriptor consumed by [GenaiTabs].
@immutable
class GenaiTabItem {
  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional numeric badge shown after the label.
  final int? badgeCount;

  /// When true the tab is non-interactive.
  final bool isDisabled;

  /// Accessibility override — defaults to [label].
  final String? semanticLabel;

  const GenaiTabItem({
    required this.label,
    this.icon,
    this.badgeCount,
    this.isDisabled = false,
    this.semanticLabel,
  });
}

/// Visual style of a [GenaiTabs] row — v3.
///
/// - [underline]: thin 2 px underline below the selected tab (default).
/// - [segmented]: `.seg` — inline-flex bg `neutralSoft`, radius 8, padding 2.
///   Active button uses surfaceCard bg with a subtle shadow; others render
///   transparent with `ink-2` text.
/// - [pill]: filled pill for the selected tab.
enum GenaiTabsVariant { underline, pill, segmented }

/// Tabs — v3 design system (§v3 rule 4 `.seg`).
class GenaiTabs extends StatefulWidget {
  /// Ordered tab list.
  final List<GenaiTabItem> items;

  /// Currently selected index.
  final int selectedIndex;

  /// Fires when a user activates a different tab.
  final ValueChanged<int>? onChanged;

  /// Visual style. Defaults to [GenaiTabsVariant.underline].
  final GenaiTabsVariant variant;

  /// When true tabs expand to fill the row equally.
  final bool isFullWidth;

  const GenaiTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.variant = GenaiTabsVariant.underline,
    this.isFullWidth = false,
  });

  @override
  State<GenaiTabs> createState() => _GenaiTabsState();
}

class _TabMoveIntent extends Intent {
  final int delta;
  const _TabMoveIntent(this.delta);
}

class _TabJumpIntent extends Intent {
  final bool toEnd;
  const _TabJumpIntent({required this.toEnd});
}

class _GenaiTabsState extends State<GenaiTabs> {
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = List.generate(widget.items.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant GenaiTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      for (final n in _nodes) {
        n.dispose();
      }
      _nodes = List.generate(widget.items.length, (_) => FocusNode());
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _move(int delta) {
    if (widget.items.isEmpty) return;
    final total = widget.items.length;
    int next = (widget.selectedIndex + delta) % total;
    if (next < 0) next += total;
    var guard = 0;
    while (widget.items[next].isDisabled && guard < total) {
      next = (next + delta.sign) % total;
      if (next < 0) next += total;
      guard++;
    }
    if (widget.items[next].isDisabled) return;
    widget.onChanged?.call(next);
    _nodes[next].requestFocus();
  }

  void _jump({required bool toEnd}) {
    if (widget.items.isEmpty) return;
    final indices = toEnd
        ? List.generate(widget.items.length, (i) => widget.items.length - 1 - i)
        : List.generate(widget.items.length, (i) => i);
    for (final i in indices) {
      if (!widget.items[i].isDisabled) {
        widget.onChanged?.call(i);
        _nodes[i].requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    final tabs = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      final w = _TabCell(
        item: widget.items[i],
        selected: i == widget.selectedIndex,
        variant: widget.variant,
        focusNode: _nodes[i],
        onTap: widget.items[i].isDisabled
            ? null
            : () {
                widget.onChanged?.call(i);
                _nodes[i].requestFocus();
              },
      );
      tabs.add(widget.isFullWidth ? Expanded(child: w) : w);
    }

    Widget row = FocusableActionDetector(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): _TabMoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowRight): _TabMoveIntent(1),
        SingleActivator(LogicalKeyboardKey.home): _TabJumpIntent(toEnd: false),
        SingleActivator(LogicalKeyboardKey.end): _TabJumpIntent(toEnd: true),
      },
      actions: {
        _TabMoveIntent: CallbackAction<_TabMoveIntent>(
          onInvoke: (i) {
            _move(i.delta);
            return null;
          },
        ),
        _TabJumpIntent: CallbackAction<_TabJumpIntent>(
          onInvoke: (i) {
            _jump(toEnd: i.toEnd);
            return null;
          },
        ),
      },
      child: Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: tabs,
      ),
    );

    switch (widget.variant) {
      case GenaiTabsVariant.underline:
        return Semantics(
          container: true,
          label: 'Tabs',
          explicitChildNodes: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.borderSubtle,
                  width: sizing.dividerThickness,
                ),
              ),
            ),
            child: row,
          ),
        );
      case GenaiTabsVariant.segmented:
        return Semantics(
          container: true,
          label: 'Tabs',
          explicitChildNodes: true,
          child: Container(
            padding: EdgeInsets.all(spacing.s2),
            decoration: BoxDecoration(
              color: colors.colorNeutralSubtle,
              borderRadius: BorderRadius.circular(radius.md),
            ),
            child: row,
          ),
        );
      case GenaiTabsVariant.pill:
        return Semantics(
          container: true,
          label: 'Tabs',
          explicitChildNodes: true,
          child: row,
        );
    }
  }
}

class _TabCell extends StatefulWidget {
  final GenaiTabItem item;
  final bool selected;
  final GenaiTabsVariant variant;
  final FocusNode focusNode;
  final VoidCallback? onTap;

  const _TabCell({
    required this.item,
    required this.selected,
    required this.variant,
    required this.focusNode,
    required this.onTap,
  });

  @override
  State<_TabCell> createState() => _TabCellState();
}

class _TabCellState extends State<_TabCell> {
  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final disabled = widget.item.isDisabled;
    final selected = widget.selected;

    Color fg;
    if (disabled) {
      fg = colors.textDisabled;
    } else if (selected) {
      fg = widget.variant == GenaiTabsVariant.pill
          ? colors.textOnPrimary
          : colors.textPrimary;
    } else {
      fg = colors.textSecondary;
    }

    Color bg = Colors.transparent;
    List<BoxShadow>? bgShadow;
    if (selected) {
      switch (widget.variant) {
        case GenaiTabsVariant.pill:
          bg = colors.colorPrimary;
          break;
        case GenaiTabsVariant.segmented:
          bg = colors.surfaceCard;
          bgShadow = [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ];
          break;
        case GenaiTabsVariant.underline:
          bg = Colors.transparent;
          break;
      }
    } else if (_hover && !disabled) {
      bg = colors.surfaceHover;
    }
    if (_pressed && !disabled) {
      bg = colors.surfacePressed;
    }

    final cellRadius = widget.variant == GenaiTabsVariant.underline
        ? BorderRadius.zero
        : BorderRadius.circular(radius.sm);

    final labelStyle = ty.label.copyWith(
      color: fg,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    );

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: sizing.iconSize, color: fg),
          SizedBox(width: spacing.iconLabelGap),
        ],
        Flexible(child: Text(widget.item.label, style: labelStyle)),
        if (widget.item.badgeCount != null) ...[
          SizedBox(width: spacing.s6),
          _TabBadge(count: widget.item.badgeCount!, foreground: fg),
        ],
      ],
    );

    final underline = widget.variant == GenaiTabsVariant.underline && selected
        ? Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: sizing.focusRingWidth,
              color: disabled ? colors.borderDefault : colors.colorPrimary,
            ),
          )
        : null;

    Widget content = Container(
      constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: cellRadius,
        boxShadow: bgShadow,
      ),
      alignment: Alignment.center,
      child: label,
    );
    if (underline != null) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [content, underline],
      );
    }

    final focusRing = _focused && !disabled
        ? Positioned.fill(
            child: IgnorePointer(
              child: Container(
                margin: EdgeInsets.all(sizing.focusRingOffset),
                decoration: BoxDecoration(
                  borderRadius: cellRadius,
                  border: Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusRingWidth,
                  ),
                ),
              ),
            ),
          )
        : null;

    return Semantics(
      button: true,
      selected: selected,
      enabled: !disabled,
      label: widget.item.semanticLabel ?? widget.item.label,
      child: MouseRegion(
        cursor:
            disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hover) setState(() => _hover = true);
        },
        onExit: (_) {
          if (_hover || _pressed) {
            setState(() {
              _hover = false;
              _pressed = false;
            });
          }
        },
        child: Focus(
          focusNode: widget.focusNode,
          onFocusChange: (v) {
            if (_focused != v) setState(() => _focused = v);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: Stack(
              children: [
                content,
                if (focusRing != null) focusRing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  final int count;
  final Color foreground;
  const _TabBadge({required this.count, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s6,
        vertical: spacing.s2,
      ),
      decoration: BoxDecoration(
        color: colors.colorNeutralSubtle,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: ty.labelSm.copyWith(color: foreground),
      ),
    );
  }
}
