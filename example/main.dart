import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genai_components/genai_components.dart' hide WidgetBuilder;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'screens/buttons_screen.dart';
import 'screens/compact_screen.dart';
import 'screens/form_screen.dart';

/// Widget gallery for genai_components (UI-pure).
/// Run: flutter run -t example/main.dart -d macos
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedManager.initPrefs();
  runApp(const GalleryApp());
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CLThemeProvider>(
      create: (_) => CLThemeProvider(),
      child: MaterialApp(
        title: 'genai_components Gallery',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFAF9F7),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121218),
        ),
        home: GalleryHome(
          isDark: _themeMode == ThemeMode.dark,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}

class _GalleryEntry {
  const _GalleryEntry({required this.title, required this.icon, required this.builder});

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

final List<_GalleryEntry> _entries = [
  _GalleryEntry(
    title: 'Buttons',
    icon: LucideIcons.mousePointerClick,
    builder: (_) => const ButtonsScreen(),
  ),
  _GalleryEntry(
    title: 'Form',
    icon: LucideIcons.textCursorInput,
    builder: (_) => const FormScreen(),
  ),
  _GalleryEntry(
    title: 'Compact',
    icon: LucideIcons.foldVertical,
    builder: (_) => const CompactScreen(),
  ),
];

class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key, required this.isDark, required this.onToggleTheme});

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final entry = _entries[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title, style: theme.heading4),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(widget.isDark ? LucideIcons.sun : LucideIcons.moon, size: 18),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.transparent,
            destinations: [
              for (final e in _entries)
                NavigationRailDestination(
                  icon: Icon(e.icon, size: 20),
                  label: Text(e.title),
                ),
            ],
          ),
          VerticalDivider(width: 1, thickness: 1, color: theme.borderColor),
          Expanded(child: entry.builder(context)),
        ],
      ),
    );
  }
}
