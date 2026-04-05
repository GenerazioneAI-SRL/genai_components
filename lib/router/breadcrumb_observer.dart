import 'package:flutter/material.dart';
import 'breadcrumb_stack.dart';

/// NavigatorObserver that updates CLBreadcrumbStack on push/pop.
class CLBreadcrumbObserver extends NavigatorObserver {
  final CLBreadcrumbStack stack;

  CLBreadcrumbObserver(this.stack);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    final path = _extractPath(route.settings);
    if (name != null && path != null && name.isNotEmpty) {
      stack.push(CLBreadcrumbEntry(name: name, path: path));
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.pop();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      stack.pop();
      final name = newRoute.settings.name;
      final path = _extractPath(newRoute.settings);
      if (name != null && path != null && name.isNotEmpty) {
        stack.push(CLBreadcrumbEntry(name: name, path: path));
      }
    }
  }

  String? _extractPath(RouteSettings settings) {
    final args = settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('routePath')) {
      return args['routePath'] as String?;
    }
    return settings.name;
  }
}
