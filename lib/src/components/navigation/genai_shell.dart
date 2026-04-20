import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../ai_assistant/src/core/ai_assistant.dart';
import '../ai_assistant/src/core/ai_assistant_config.dart';
import 'genai_bottom_nav.dart';
import 'genai_command_palette.dart';
import 'genai_navigation_rail.dart';
import 'genai_sidebar.dart';

/// Application shell (§5 + §6.6.12).
///
/// Composes sidebar (or rail or bottom-nav) + app bar + body, switching
/// layout automatically based on the window size.
///
/// Cmd/Ctrl+K opens an optional [commandPalette].
class GenaiShell extends StatefulWidget {
  /// Sidebar configuration (always provided; collapses/transforms on small
  /// breakpoints).
  final List<GenaiSidebarGroup> sidebarGroups;
  final String? selectedId;
  final ValueChanged<String>? onNavigate;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;

  /// Top app bar (kept on all sizes).
  final PreferredSizeWidget? appBar;
  final Widget body;

  /// If non-null, enables Cmd/Ctrl+K command palette.
  final List<GenaiCommand>? commands;

  /// If non-null, mobile uses these primary destinations as bottom nav.
  final List<GenaiBottomNavItem>? bottomNavItems;
  final int? bottomNavIndex;
  final ValueChanged<int>? onBottomNavChanged;

  /// If non-null, wraps the shell in a [GenaiAiAssistant] overlay (FAB +
  /// chat). The assistant scope sees the full shell as its child.
  final GenaiAiAssistantConfig? aiAssistantConfig;

  const GenaiShell({
    super.key,
    required this.sidebarGroups,
    required this.body,
    this.selectedId,
    this.onNavigate,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBar,
    this.commands,
    this.bottomNavItems,
    this.bottomNavIndex,
    this.onBottomNavChanged,
    this.aiAssistantConfig,
  });

  @override
  State<GenaiShell> createState() => _GenaiShellState();
}

class _GenaiShellState extends State<GenaiShell> {
  bool _sidebarCollapsed = false;

  // Convert sidebar groups to a flat list of rail items (icons only, top
  // level entries only).
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

  void _railSelect(int index) {
    final flat = <GenaiSidebarItem>[];
    for (final g in widget.sidebarGroups) {
      flat.addAll(g.items);
    }
    if (index < flat.length) widget.onNavigate?.call(flat[index].id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = GenaiResponsive.sizeOf(context);

    Widget content = Scaffold(
      backgroundColor: colors.surfacePage,
      appBar: widget.appBar,
      body: _buildBody(size),
      bottomNavigationBar: size == GenaiWindowSize.compact && widget.bottomNavItems != null
          ? GenaiBottomNav(
              items: widget.bottomNavItems!,
              selectedIndex: widget.bottomNavIndex ?? 0,
              onChanged: widget.onBottomNavChanged,
            )
          : null,
    );

    if (widget.commands != null) {
      content = _CommandShortcutHost(
        onOpen: () => showGenaiCommandPalette(context, commands: widget.commands!),
        child: content,
      );
    }
    if (widget.aiAssistantConfig != null) {
      content = GenaiAiAssistant(
        config: widget.aiAssistantConfig!,
        child: content,
      );
    }
    return content;
  }

  Widget _buildBody(GenaiWindowSize size) {
    if (size == GenaiWindowSize.compact) {
      // Mobile: just the body; sidebar replaced by bottom nav (above).
      return widget.body;
    }
    if (size == GenaiWindowSize.medium) {
      return Row(
        children: [
          GenaiNavigationRail(
            items: _railItems(),
            selectedIndex: _railSelectedIndex(),
            onChanged: _railSelect,
          ),
          Expanded(child: widget.body),
        ],
      );
    }
    return Row(
      children: [
        GenaiSidebar(
          groups: widget.sidebarGroups,
          selectedId: widget.selectedId,
          onSelected: widget.onNavigate,
          isCollapsed: _sidebarCollapsed,
          onCollapsedChanged: (v) => setState(() => _sidebarCollapsed = v),
          header: widget.sidebarHeader,
          footer: widget.sidebarFooter,
        ),
        Expanded(child: widget.body),
      ],
    );
  }
}

class _CommandShortcutHost extends StatelessWidget {
  final VoidCallback onOpen;
  final Widget child;
  const _CommandShortcutHost({required this.onOpen, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): const _OpenCommandIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): const _OpenCommandIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenCommandIntent: CallbackAction<_OpenCommandIntent>(
            onInvoke: (_) {
              onOpen();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class _OpenCommandIntent extends Intent {
  const _OpenCommandIntent();
}
