import '../../models/app_context_snapshot.dart';

/// Emits the scoped app-manifest summary block (APP OVERVIEW, GLOBAL
/// NAVIGATION, APP SCREENS core map, ALL ROUTES) into the system prompt.
///
/// Pure: no state, no side effects. Extracted from `prompt_sections.dart`
/// to keep that file under the 400-line budget.
class ManifestSection {
  const ManifestSection._();

  /// Section: scoped manifest summary (app overview, prioritized routes).
  static void write(StringBuffer buffer, AppContextSnapshot context) {
    final manifest = context.appManifest;
    if (manifest == null) return;

    const maxDetailedScreens = 24;
    const maxCurrentLinks = 8;

    buffer.writeln('APP OVERVIEW:');
    buffer.writeln(manifest.appDescription);
    buffer.writeln();

    if (manifest.globalNavigation.isNotEmpty) {
      buffer.writeln('GLOBAL NAVIGATION:');
      final navItems = manifest.globalNavigation
          .map((n) => '${n.label} (${n.route})')
          .join(', ');
      buffer.writeln('  $navItems');
      buffer.writeln();
    }

    final prioritizedRoutes = <String>{};
    final currentRoute = context.currentRoute;
    if (currentRoute != null && manifest.screens.containsKey(currentRoute)) {
      prioritizedRoutes.add(currentRoute);
      final currentScreen = manifest.screens[currentRoute];
      if (currentScreen != null) {
        for (final link in currentScreen.linksTo) {
          if (!manifest.screens.containsKey(link.targetRoute)) continue;
          prioritizedRoutes.add(link.targetRoute);
          if (prioritizedRoutes.length >= maxCurrentLinks) break;
        }
      }
    }

    for (final nav in manifest.globalNavigation) {
      if (!manifest.screens.containsKey(nav.route)) continue;
      prioritizedRoutes.add(nav.route);
      if (prioritizedRoutes.length >= maxDetailedScreens) break;
    }

    if (prioritizedRoutes.length < maxDetailedScreens) {
      for (final flow in manifest.flows) {
        for (final step in flow.steps) {
          if (!manifest.screens.containsKey(step.route)) continue;
          prioritizedRoutes.add(step.route);
          if (prioritizedRoutes.length >= maxDetailedScreens) break;
        }
        if (prioritizedRoutes.length >= maxDetailedScreens) break;
      }
    }

    if (prioritizedRoutes.length < maxDetailedScreens) {
      final remaining =
          manifest.screens.keys
              .where((r) => !prioritizedRoutes.contains(r))
              .toList()
            ..sort();
      for (final route in remaining) {
        prioritizedRoutes.add(route);
        if (prioritizedRoutes.length >= maxDetailedScreens) break;
      }
    }

    buffer.writeln('APP SCREENS (core map):');
    for (final route in prioritizedRoutes) {
      final screen = manifest.screens[route];
      if (screen == null) continue;
      buffer.writeln(
        '  $route - ${screen.title} - ${_truncate(screen.description, 120)}',
      );
      if (route == currentRoute && screen.linksTo.isNotEmpty) {
        for (final link in screen.linksTo.take(maxCurrentLinks)) {
          buffer.writeln(
            '    -> ${link.targetRoute} (${_truncate(link.trigger, 70)})',
          );
        }
      }
    }
    buffer.writeln();

    final allRoutes =
        <String>{
            ...manifest.screens.keys,
            ...context.availableRoutes.map((r) => r.name),
          }.toList()
          ..sort();
    buffer.writeln('ALL ROUTES (exact names for navigate_to_route):');
    for (final route in allRoutes) {
      buffer.writeln('  - $route');
    }
    buffer.writeln();
  }

  static String _truncate(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars - 3)}...';
  }
}
