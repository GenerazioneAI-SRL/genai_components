import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Single row in a menubar dropdown — v3.
@immutable
class GenaiMenubarItem {
  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional keyboard shortcut hint.
  final String? shortcut;

  /// Value returned via `onSelected` when picked.
  final Object? value;

  /// When true the item is non-interactive.
  final bool isDisabled;

  /// When true the item is rendered as destructive (danger tokens).
  final bool isDestructive;

  /// When true a horizontal divider is rendered above this item.
  final bool isDividerBefore;

  const GenaiMenubarItem({
    required this.label,
    this.value,
    this.icon,
    this.shortcut,
    this.isDisabled = false,
    this.isDestructive = false,
    this.isDividerBefore = false,
  });
}

/// A single top-level menu within a [GenaiMenubar].
@immutable
class GenaiMenubarMenu {
  /// Trigger text.
  final String label;

  /// Items rendered inside the dropdown.
  final List<GenaiMenubarItem> items;

  /// Accessibility override.
  final String? semanticLabel;

  const GenaiMenubarMenu({
    required this.label,
    required this.items,
    this.semanticLabel,
  });
}

/// Horizontal menu bar — v3 design system.
class GenaiMenubar extends StatefulWidget {
  final List<GenaiMenubarMenu> menus;
  final ValueChanged<Object?>? onSelected;
  final String? semanticLabel;

  const GenaiMenubar({
    super.key,
    required this.menus,
    this.onSelected,
    this.semanticLabel,
  });

  @override
  State<GenaiMenubar> createState() => _GenaiMenubarState();
}

class _GenaiMenubarState extends State<GenaiMenubar> {
  final List<GlobalKey> _triggerKeys = [];
  final List<FocusNode> _triggerNodes = [];
  OverlayEntry? _entry;
  int? _openIndex;
  int _highlightedItem = 0;
  final FocusNode _menuFocus = FocusNode(debugLabel: 'GenaiMenubar.menu');

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
  }

  @override
  void didUpdateWidget(covariant GenaiMenubar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menus.length != widget.menus.length) {
      for (final n in _triggerNodes) {
        n.dispose();
      }
      _rebuildKeys();
    }
  }

  void _rebuildKeys() {
    _triggerKeys
      ..clear()
      ..addAll(List.generate(widget.menus.length, (_) => GlobalKey()));
    _triggerNodes.clear();
    _triggerNodes.addAll(List.generate(
      widget.menus.length,
      (i) => FocusNode(debugLabel: 'GenaiMenubar.trigger[$i]'),
    ));
  }

  @override
  void dispose() {
    _closeMenu();
    for (final n in _triggerNodes) {
      n.dispose();
    }
    _menuFocus.dispose();
    super.dispose();
  }

  void _openMenu(int index) {
    if (_openIndex == index) return;
    if (index < 0 || index >= widget.menus.length) return;
    final menu = widget.menus[index];
    if (menu.items.isEmpty) return;

    // Hover-switch path: an overlay is already mounted. Update the open index
    // and let the existing OverlayEntry rebuild against the new menu instead
    // of removing + reinserting (which causes a one-frame blink).
    if (_entry != null) {
      setState(() {
        _openIndex = index;
        _highlightedItem = _firstEnabled(menu.items);
      });
      _entry!.markNeedsBuild();
      return;
    }

    setState(() {
      _openIndex = index;
      _highlightedItem = _firstEnabled(menu.items);
    });

    _entry = OverlayEntry(
      builder: (ctx) {
        // Resolve trigger geometry on every build so hover-switching to a
        // sibling re-anchors the same overlay against the new trigger.
        final i = _openIndex;
        if (i == null) return const SizedBox.shrink();
        final triggerBox =
            _triggerKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (triggerBox == null) return const SizedBox.shrink();
        final triggerTopLeft = triggerBox.localToGlobal(Offset.zero);
        final triggerSize = triggerBox.size;
        final activeMenu = widget.menus[i];
        return _MenubarOverlay(
          triggerOrigin: Offset(
            triggerTopLeft.dx,
            triggerTopLeft.dy + triggerSize.height,
          ),
          items: activeMenu.items,
          highlight: _highlightedItem,
          onHighlight: (idx) {
            if (_highlightedItem == idx) return;
            setState(() => _highlightedItem = idx);
            // The OverlayEntry's builder closure captures `_highlightedItem`
            // from this State; setState alone doesn't rebuild the overlay,
            // so without this call the highlight blinks/lags on hover.
            _entry?.markNeedsBuild();
          },
          onDismiss: _closeMenu,
          onSelect: (item) {
            _closeMenu();
            widget.onSelected?.call(item.value);
          },
          menuFocus: _menuFocus,
          onMoveTrigger: (delta) {
            final cur = _openIndex ?? 0;
            final next = (cur + delta) % widget.menus.length;
            _openMenu(next < 0 ? next + widget.menus.length : next);
          },
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _menuFocus.requestFocus();
    });
  }

  int _firstEnabled(List<GenaiMenubarItem> items) {
    for (var i = 0; i < items.length; i++) {
      if (!items[i].isDisabled) return i;
    }
    return 0;
  }

  void _closeMenu() {
    _entry?.remove();
    _entry = null;
    if (_openIndex != null && mounted) {
      setState(() => _openIndex = null);
    } else {
      _openIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Menubar',
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.menus.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : spacing.s2),
              child: _MenubarTrigger(
                key: _triggerKeys[i],
                menu: widget.menus[i],
                isOpen: _openIndex == i,
                anyOpen: _openIndex != null,
                focusNode: _triggerNodes[i],
                onTap: () {
                  if (_openIndex == i) {
                    _closeMenu();
                  } else {
                    _openMenu(i);
                  }
                },
                onHover: () {
                  if (_openIndex != null && _openIndex != i) _openMenu(i);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MenubarTrigger extends StatefulWidget {
  final GenaiMenubarMenu menu;
  final bool isOpen;
  final bool anyOpen;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _MenubarTrigger({
    super.key,
    required this.menu,
    required this.isOpen,
    required this.anyOpen,
    required this.focusNode,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_MenubarTrigger> createState() => _MenubarTriggerState();
}

class _MenubarTriggerState extends State<_MenubarTrigger> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    Color bg = Colors.transparent;
    if (widget.isOpen) {
      bg = colors.surfacePressed;
    } else if (_hover) {
      bg = colors.surfaceHover;
    }

    final inner = Container(
      constraints: BoxConstraints(
        minHeight: sizing.minTouchTarget - 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.menu.label,
        style: ty.label.copyWith(color: colors.textPrimary),
      ),
    );

    // Focus ring as a non-layout overlay so focus appearance never resizes
    // the trigger and never drops the cursor out of the MouseRegion.
    final stacked = Stack(
      clipBehavior: Clip.none,
      children: [
        inner,
        if (_focused)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.sm),
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

    return Semantics(
      button: true,
      expanded: widget.isOpen,
      label: widget.menu.semanticLabel ?? widget.menu.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hover) setState(() => _hover = true);
          if (widget.anyOpen) widget.onHover();
        },
        onExit: (_) {
          if (_hover) setState(() => _hover = false);
        },
        child: Focus(
          focusNode: widget.focusNode,
          onFocusChange: (v) {
            if (_focused != v) setState(() => _focused = v);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: stacked,
          ),
        ),
      ),
    );
  }
}

class _MenubarOverlay extends StatefulWidget {
  final Offset triggerOrigin;
  final List<GenaiMenubarItem> items;
  final int highlight;
  final ValueChanged<int> onHighlight;
  final VoidCallback onDismiss;
  final ValueChanged<GenaiMenubarItem> onSelect;
  final ValueChanged<int> onMoveTrigger;
  final FocusNode menuFocus;

  const _MenubarOverlay({
    required this.triggerOrigin,
    required this.items,
    required this.highlight,
    required this.onHighlight,
    required this.onDismiss,
    required this.onSelect,
    required this.onMoveTrigger,
    required this.menuFocus,
  });

  @override
  State<_MenubarOverlay> createState() => _MenubarOverlayState();
}

class _MenubarOverlayState extends State<_MenubarOverlay> {
  void _move(int delta) {
    if (widget.items.isEmpty) return;
    var next = widget.highlight;
    var guard = 0;
    do {
      next = (next + delta) % widget.items.length;
      if (next < 0) next += widget.items.length;
      guard++;
    } while (widget.items[next].isDisabled && guard < widget.items.length);
    widget.onHighlight(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),
        Positioned(
          left: widget.triggerOrigin.dx,
          top: widget.triggerOrigin.dy + 4,
          child: Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.arrowDown): _DownIntent(),
              SingleActivator(LogicalKeyboardKey.arrowUp): _UpIntent(),
              SingleActivator(LogicalKeyboardKey.arrowLeft):
                  _TriggerDeltaIntent(-1),
              SingleActivator(LogicalKeyboardKey.arrowRight):
                  _TriggerDeltaIntent(1),
              SingleActivator(LogicalKeyboardKey.enter): _EnterIntent(),
              SingleActivator(LogicalKeyboardKey.space): _EnterIntent(),
              SingleActivator(LogicalKeyboardKey.escape): _EscIntent(),
            },
            child: Actions(
              actions: {
                _DownIntent: CallbackAction<_DownIntent>(
                  onInvoke: (_) {
                    _move(1);
                    return null;
                  },
                ),
                _UpIntent: CallbackAction<_UpIntent>(
                  onInvoke: (_) {
                    _move(-1);
                    return null;
                  },
                ),
                _TriggerDeltaIntent: CallbackAction<_TriggerDeltaIntent>(
                  onInvoke: (i) {
                    widget.onMoveTrigger(i.delta);
                    return null;
                  },
                ),
                _EnterIntent: CallbackAction<_EnterIntent>(
                  onInvoke: (_) {
                    final i = widget.highlight;
                    if (i >= 0 && i < widget.items.length) {
                      final item = widget.items[i];
                      if (!item.isDisabled) widget.onSelect(item);
                    }
                    return null;
                  },
                ),
                _EscIntent: CallbackAction<_EscIntent>(
                  onInvoke: (_) {
                    widget.onDismiss();
                    return null;
                  },
                ),
              },
              child: Focus(
                focusNode: widget.menuFocus,
                autofocus: true,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 200),
                    padding: EdgeInsets.symmetric(vertical: spacing.s4),
                    decoration: BoxDecoration(
                      color: colors.surfaceOverlay,
                      borderRadius: BorderRadius.circular(radius.md),
                      border: Border.all(
                        color: colors.borderDefault,
                        width: sizing.dividerThickness,
                      ),
                      boxShadow: context.elevation.layer2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < widget.items.length; i++) ...[
                          if (widget.items[i].isDividerBefore && i != 0)
                            Container(
                              height: sizing.dividerThickness,
                              margin: EdgeInsets.symmetric(
                                vertical: spacing.s4,
                                horizontal: spacing.s4,
                              ),
                              color: colors.borderSubtle,
                            ),
                          _MenuItemRow(
                            item: widget.items[i],
                            highlighted: i == widget.highlight,
                            onHover: () => widget.onHighlight(i),
                            onTap: widget.items[i].isDisabled
                                ? null
                                : () => widget.onSelect(widget.items[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItemRow extends StatefulWidget {
  final GenaiMenubarItem item;
  final bool highlighted;
  final VoidCallback? onTap;
  final VoidCallback onHover;

  const _MenuItemRow({
    required this.item,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final item = widget.item;
    final disabled = item.isDisabled;
    final fg = disabled
        ? colors.textDisabled
        : item.isDestructive
            ? colors.colorDangerText
            : colors.textPrimary;
    final active = (widget.highlighted || _hovered) && !disabled;
    final bg = active
        ? (item.isDestructive ? colors.colorDangerSubtle : colors.surfaceHover)
        : Colors.transparent;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: item.label,
      child: MouseRegion(
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        cursor:
            disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
          widget.onHover();
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.s4),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s8,
              vertical: spacing.s6,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: sizing.iconSize, color: fg),
                  SizedBox(width: spacing.s8),
                ] else
                  SizedBox(width: sizing.iconSize + spacing.s8),
                Expanded(
                  child: Text(
                    item.label,
                    style: ty.label.copyWith(color: fg),
                  ),
                ),
                if (item.shortcut != null) ...[
                  SizedBox(width: spacing.s16),
                  Text(
                    item.shortcut!,
                    style: ty.monoSm.copyWith(color: colors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownIntent extends Intent {
  const _DownIntent();
}

class _UpIntent extends Intent {
  const _UpIntent();
}

class _EnterIntent extends Intent {
  const _EnterIntent();
}

class _EscIntent extends Intent {
  const _EscIntent();
}

class _TriggerDeltaIntent extends Intent {
  final int delta;
  const _TriggerDeltaIntent(this.delta);
}
