import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../indicators/genai_kbd.dart';

/// Alignment of a dropdown menu relative to its trigger.
enum GenaiDropdownAlignment {
  /// Aligned to the trigger's leading edge (default).
  start,

  /// Centered under the trigger.
  center,

  /// Aligned to the trigger's trailing edge.
  end,
}

/// Single entry inside a [GenaiDropdownMenu] — v3 design system.
class GenaiDropdownMenuItem {
  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional keyboard shortcut hint, rendered on the right as a [GenaiKbd].
  final String? shortcut;

  /// Tap handler.
  final VoidCallback? onTap;

  /// When true, renders the row in the danger color.
  final bool isDestructive;

  /// When true, the row is shown but non-interactive.
  final bool isDisabled;

  /// When true, the row reserves a leading check column.
  final bool isCheckable;

  /// When [isCheckable], controls whether the check is rendered.
  final bool isChecked;

  /// When non-null, the row opens a submenu containing these items.
  final List<GenaiDropdownMenuItem>? subItems;

  /// True for a divider line.
  final bool isSeparator;

  const GenaiDropdownMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
    this.isCheckable = false,
    this.isChecked = false,
    this.subItems,
  }) : isSeparator = false;

  const GenaiDropdownMenuItem._separator()
      : label = '',
        icon = null,
        shortcut = null,
        onTap = null,
        isDestructive = false,
        isDisabled = true,
        isCheckable = false,
        isChecked = false,
        subItems = null,
        isSeparator = true;

  /// Inserts a thin divider between groups of items.
  factory GenaiDropdownMenuItem.separator() =>
      const GenaiDropdownMenuItem._separator();
}

/// Click-to-open dropdown menu (shadcn parity: `<DropdownMenu>`) — v3.
///
/// Distinct from [showGenaiContextMenu] (right-click): `GenaiDropdownMenu`
/// opens on **left-click of a trigger** and renders an anchored popover with
/// the v3 hairline-flat overlay style.
///
/// Features:
/// - Left-click on [trigger] toggles the menu.
/// - `Esc` closes; outside-tap closes.
/// - Up/down arrow keys move the keyboard highlight; `Enter` activates.
/// - `isCheckable` items reserve a leading check column for alignment.
class GenaiDropdownMenu extends StatefulWidget {
  /// Anchor widget — the user clicks this to open the menu.
  final Widget trigger;

  /// Menu rows.
  final List<GenaiDropdownMenuItem> items;

  /// How the menu aligns relative to the trigger horizontally.
  final GenaiDropdownAlignment alignment;

  /// Menu width. Defaults to 220.
  final double width;

  /// Accessibility label for the menu container.
  final String? semanticLabel;

  const GenaiDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.alignment = GenaiDropdownAlignment.start,
    this.width = 220,
    this.semanticLabel,
  });

  @override
  State<GenaiDropdownMenu> createState() => _GenaiDropdownMenuState();
}

class _GenaiDropdownMenuState extends State<GenaiDropdownMenu> {
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _entry;
  final FocusNode _menuFocus = FocusNode(debugLabel: 'GenaiDropdownMenu');
  int _highlightedIndex = -1;

  void _toggle() => _entry == null ? _show() : _hide();

  void _show() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    _highlightedIndex = _firstEnabledIndex();
    _entry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_entry!);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_entry != null) _menuFocus.requestFocus();
    });
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  int _firstEnabledIndex() {
    for (var i = 0; i < widget.items.length; i++) {
      final it = widget.items[i];
      if (!it.isSeparator && !it.isDisabled) return i;
    }
    return -1;
  }

  void _moveHighlight(int direction) {
    if (widget.items.isEmpty) return;
    var i = _highlightedIndex;
    final n = widget.items.length;
    for (var step = 0; step < n; step++) {
      i = (i + direction + n) % n;
      final it = widget.items[i];
      if (!it.isSeparator && !it.isDisabled) {
        setState(() => _highlightedIndex = i);
        _entry?.markNeedsBuild();
        return;
      }
    }
  }

  void _activate(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final it = widget.items[index];
    if (it.isSeparator || it.isDisabled) return;
    if (it.subItems != null) return;
    _hide();
    it.onTap?.call();
  }

  Widget _buildOverlay(BuildContext ctx) {
    final spacing = ctx.spacing;
    Alignment target;
    Alignment follower;
    Offset offset;
    switch (widget.alignment) {
      case GenaiDropdownAlignment.start:
        target = Alignment.bottomLeft;
        follower = Alignment.topLeft;
        offset = Offset(0, spacing.s8);
        break;
      case GenaiDropdownAlignment.center:
        target = Alignment.bottomCenter;
        follower = Alignment.topCenter;
        offset = Offset(0, spacing.s8);
        break;
      case GenaiDropdownAlignment.end:
        target = Alignment.bottomRight;
        follower = Alignment.topRight;
        offset = Offset(0, spacing.s8);
        break;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hide,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          offset: offset,
          targetAnchor: target,
          followerAnchor: follower,
          showWhenUnlinked: false,
          child: Material(
            color: Colors.transparent,
            child: _MenuPanel(
              focusNode: _menuFocus,
              width: widget.width,
              semanticLabel: widget.semanticLabel,
              onEscape: _hide,
              onArrowDown: () => _moveHighlight(1),
              onArrowUp: () => _moveHighlight(-1),
              onActivate: () => _activate(_highlightedIndex),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    _ItemRow(
                      item: widget.items[i],
                      highlighted: i == _highlightedIndex,
                      onHover: (hovered) {
                        if (hovered &&
                            !widget.items[i].isSeparator &&
                            !widget.items[i].isDisabled) {
                          setState(() => _highlightedIndex = i);
                          _entry?.markNeedsBuild();
                        }
                      },
                      onTap: () => _activate(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    _menuFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: KeyedSubtree(key: _anchorKey, child: widget.trigger),
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  final FocusNode focusNode;
  final double width;
  final String? semanticLabel;
  final VoidCallback onEscape;
  final VoidCallback onArrowDown;
  final VoidCallback onArrowUp;
  final VoidCallback onActivate;
  final Widget child;

  const _MenuPanel({
    required this.focusNode,
    required this.width,
    required this.semanticLabel,
    required this.onEscape,
    required this.onArrowDown,
    required this.onArrowUp,
    required this.onActivate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;
    final motion = context.motion.expand;

    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          onEscape();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          onArrowDown();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          onArrowUp();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          onActivate();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        container: true,
        label: semanticLabel,
        scopesRoute: true,
        explicitChildNodes: true,
        child: TweenAnimationBuilder<double>(
          duration: motion.duration,
          curve: motion.curve,
          tween: Tween(begin: 0, end: 1),
          builder: (_, t, c) => Opacity(opacity: t, child: c),
          child: Container(
            width: width,
            padding: EdgeInsets.symmetric(vertical: spacing.s4),
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(color: colors.borderDefault),
              boxShadow: context.elevation.shadowForLayer(2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final GenaiDropdownMenuItem item;
  final bool highlighted;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _ItemRow({
    required this.item,
    required this.highlighted,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    if (item.isSeparator) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s4),
        child: Container(
          height: sizing.dividerThickness,
          color: colors.borderSubtle,
        ),
      );
    }

    final fg = item.isDisabled
        ? colors.textDisabled
        : item.isDestructive
            ? colors.colorDangerText
            : colors.textPrimary;

    final bg = highlighted && !item.isDisabled
        ? colors.surfaceHover
        : Colors.transparent;

    return Semantics(
      button: true,
      enabled: !item.isDisabled,
      checked: item.isCheckable ? item.isChecked : null,
      label: item.label,
      hint: item.shortcut,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        cursor: item.isDisabled ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.isDisabled ? null : onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: spacing.s8,
            ),
            color: bg,
            child: Row(
              children: [
                if (item.isCheckable)
                  SizedBox(
                    width: sizing.iconSize,
                    child: item.isChecked
                        ? Icon(
                            LucideIcons.check,
                            size: sizing.iconSize,
                            color: fg,
                          )
                        : const SizedBox.shrink(),
                  ),
                if (item.isCheckable) SizedBox(width: spacing.s8),
                if (item.icon != null) ...[
                  Icon(item.icon, size: sizing.iconSize, color: fg),
                  SizedBox(width: spacing.s8),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: ty.bodySm.copyWith(color: fg),
                  ),
                ),
                if (item.shortcut != null && item.subItems == null)
                  Padding(
                    padding: EdgeInsets.only(left: spacing.s8),
                    child: GenaiKbd(
                      keys: item.shortcut!,
                      size: GenaiKbdSize.sm,
                    ),
                  ),
                if (item.subItems != null)
                  Icon(
                    LucideIcons.chevronRight,
                    size: sizing.iconSize,
                    color: colors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
