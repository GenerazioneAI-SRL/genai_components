import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

class ShowcasePage {
  final String id;
  final String label;
  final String group;
  final IconData? icon;
  final Widget child;

  const ShowcasePage({
    required this.id,
    required this.label,
    required this.group,
    required this.child,
    this.icon,
  });
}

class ShowcaseShell extends StatefulWidget {
  final List<ShowcasePage> pages;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const ShowcaseShell({
    super.key,
    required this.pages,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  late String _selectedId = widget.pages.first.id;

  ShowcasePage get _current => widget.pages.firstWhere((p) => p.id == _selectedId);

  List<GenaiSidebarGroup> _buildGroups() {
    final groups = <String, List<GenaiSidebarItem>>{};
    for (final p in widget.pages) {
      groups.putIfAbsent(p.group, () => []).add(GenaiSidebarItem(
            id: p.id,
            label: p.label,
            icon: p.icon ?? _defaultIcon(p.id),
          ));
    }
    return groups.entries.map((e) => GenaiSidebarGroup(title: e.key, items: e.value)).toList();
  }

  IconData _defaultIcon(String id) => switch (id) {
        'home' => LucideIcons.house,
        'foundations' => LucideIcons.palette,
        'actions' => LucideIcons.mousePointerClick,
        'inputs' => LucideIcons.pencilLine,
        'layout' => LucideIcons.layoutDashboard,
        'feedback' => LucideIcons.messageSquareWarning,
        'overlay' => LucideIcons.layers,
        'display' => LucideIcons.table,
        'navigation' => LucideIcons.navigation,
        _ => LucideIcons.circle,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return GenaiShell(
      sidebarGroups: _buildGroups(),
      selectedId: _selectedId,
      onNavigate: (id) => setState(() => _selectedId = id),
      sidebarHeader: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(LucideIcons.sparkles, color: context.colors.colorPrimary, size: 22),
            const SizedBox(width: 8),
            Text('Genai', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      appBar: GenaiAppBar(
        title: Text(_current.label),
        subtitle: Text(_current.group),
        actions: [
          GenaiIconButton(
            icon: isDark ? LucideIcons.sun : LucideIcons.moon,
            tooltip: isDark ? 'Tema chiaro' : 'Tema scuro',
            semanticLabel: 'Cambia tema',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavItems: [
        for (final p in widget.pages.take(5))
          GenaiBottomNavItem(
            icon: _defaultIcon(p.id),
            label: p.label,
          ),
      ],
      bottomNavIndex: () {
        final idx = widget.pages.take(5).toList().indexWhere((p) => p.id == _selectedId);
        return idx < 0 ? 0 : idx;
      }(),
      onBottomNavChanged: (i) => setState(() => _selectedId = widget.pages[i].id),
      body: KeyedSubtree(
        key: ValueKey(_selectedId),
        child: _current.child,
      ),
    );
  }
}
