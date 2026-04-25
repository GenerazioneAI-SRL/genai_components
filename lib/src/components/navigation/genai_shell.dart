import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import 'genai_bottom_nav.dart';
import 'genai_command_palette.dart';
import 'genai_navigation_rail.dart';
import 'genai_sidebar.dart';

/// Application shell — v3 design system (§3 layout pattern).
///
/// Composes sidebar + topbar + body:
/// - **Compact** (`<600`): sidebar is hidden; if [bottomNavItems] is provided
///   the first 5 appear as a bottom nav (per §v3 rule 6).
/// - **Medium** (`600–1279`): icon-only [GenaiNavigationRail].
/// - **Expanded** (`>=1280`): full 240 px [GenaiSidebar].
///
/// `Cmd/Ctrl+K` opens the optional command palette when [commands] is
/// provided.
class GenaiShell extends StatefulWidget {
  /// Sidebar groups driving expanded and rail layouts.
  final List<GenaiSidebarGroup> sidebarGroups;

  /// Currently selected item id.
  final String? selectedId;

  /// Fires when a sidebar entry is activated.
  final ValueChanged<String>? onNavigate;

  /// Brand block at the top of the sidebar.
  final GenaiSidebarBrand? sidebarBrand;

  /// Footer block at the bottom of the sidebar.
  final GenaiSidebarFooter? sidebarFooter;

  /// Optional custom sidebar header (overrides [sidebarBrand] when set).
  final Widget? sidebarHeader;

  /// Optional custom sidebar footer (overrides [sidebarFooter] when set).
  final Widget? sidebarFooterOverride;

  /// Top bar — typically a [GenaiTopbar]. Rendered on all window sizes.
  final PreferredSizeWidget? topBar;

  /// Main content body.
  final Widget body;

  /// Command palette entries. When non-null enables `Cmd/Ctrl+K`.
  final List<GenaiCommand>? commands;

  /// Optional mobile bottom-nav destinations. Truncated to the first 5.
  final List<GenaiBottomNavItem>? bottomNavItems;

  /// Currently selected bottom-nav index.
  final int? bottomNavIndex;

  /// Fires when a bottom-nav destination is activated.
  final ValueChanged<int>? onBottomNavChanged;

  const GenaiShell({
    super.key,
    required this.sidebarGroups,
    required this.body,
    this.selectedId,
    this.onNavigate,
    this.sidebarBrand,
    this.sidebarFooter,
    this.sidebarHeader,
    this.sidebarFooterOverride,
    this.topBar,
    this.commands,
    this.bottomNavItems,
    this.bottomNavIndex,
    this.onBottomNavChanged,
  });

  @override
  State<GenaiShell> createState() => _GenaiShellState();
}

class _GenaiShellState extends State<GenaiShell> {
  List<GenaiNavigationRailItem> _railItems() {
    final out = <GenaiNavigationRailItem>[];
    for (final g in widget.sidebarGroups) {
      for (final i in g.items) {
        out.add(GenaiNavigationRailItem(
          icon: i.icon ?? Icons.circle,
          label: i.label,
          badgeCount: i.badgeCount,
        ));
      }
    }
    return out;
  }

  int _railSelectedIndex() {
    final flat = <GenaiSidebarItem>[];
    for (final g in widget.sidebarGroups) {
      flat.addAll(g.items);
    }
    final idx = flat.indexWhere((i) => i.id == widget.selectedId);
    return idx < 0 ? 0 : idx;
  }

  void _onRailSelected(int idx) {
    final flat = <GenaiSidebarItem>[];
    for (final g in widget.sidebarGroups) {
      flat.addAll(g.items);
    }
    if (idx < 0 || idx >= flat.length) return;
    widget.onNavigate?.call(flat[idx].id);
  }

  @override
  Widget build(BuildContext context) {
    final size = context.windowSize;
    final colors = context.colors;

    Widget layout;
    switch (size) {
      case GenaiWindowSize.compact:
      case GenaiWindowSize.medium:
        layout = _buildCompactOrMedium(context, size);
        break;
      case GenaiWindowSize.expanded:
      case GenaiWindowSize.large:
      case GenaiWindowSize.extraLarge:
        layout = _buildExpanded(context);
        break;
    }

    final scaffold = Material(
      type: MaterialType.canvas,
      color: colors.surfacePage,
      textStyle: context.typography.body.copyWith(color: colors.textPrimary),
      child: layout,
    );
    if (widget.commands == null) return scaffold;
    return _CommandShortcutHost(
      commands: widget.commands!,
      child: scaffold,
    );
  }

  Widget _buildCompactOrMedium(BuildContext context, GenaiWindowSize size) {
    final compact = size == GenaiWindowSize.compact;
    final items = widget.bottomNavItems;
    final showBottomNav = compact && items != null && items.isNotEmpty;

    return Column(
      children: [
        if (widget.topBar != null) widget.topBar!,
        Expanded(
          child: Row(
            children: [
              if (!compact)
                GenaiNavigationRail(
                  items: _railItems(),
                  selectedIndex: _railSelectedIndex(),
                  onChanged: _onRailSelected,
                  leading: widget.sidebarHeader,
                  trailing: widget.sidebarFooterOverride,
                ),
              Expanded(child: widget.body),
            ],
          ),
        ),
        if (showBottomNav)
          GenaiBottomNav(
            items: items.take(5).toList(),
            selectedIndex: widget.bottomNavIndex ?? 0,
            onChanged: widget.onBottomNavChanged,
          ),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Row(
      children: [
        GenaiSidebar(
          groups: widget.sidebarGroups,
          selectedId: widget.selectedId,
          onSelected: widget.onNavigate,
          brand: widget.sidebarBrand,
          footer: widget.sidebarFooter,
          header: widget.sidebarHeader,
          footerOverride: widget.sidebarFooterOverride,
        ),
        Expanded(
          child: Column(
            children: [
              if (widget.topBar != null) widget.topBar!,
              Expanded(child: widget.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}

class _CommandShortcutHost extends StatelessWidget {
  final List<GenaiCommand> commands;
  final Widget child;

  const _CommandShortcutHost({required this.commands, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenPaletteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) {
              showGenaiCommandPalette(context, commands: commands);
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
