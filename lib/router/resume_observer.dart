import 'package:flutter/material.dart';

/// Observer that notifies pages when they become visible again after a pop.
class CLResumeObserver extends NavigatorObserver {
  static final CLResumeObserver instance = CLResumeObserver._();
  CLResumeObserver._();

  final Map<String, VoidCallback> _callbacks = {};
  final Set<String> _registeredPaths = <String>{};

  void register(String path, VoidCallback onResume) {
    if (_registeredPaths.contains(path)) return;
    _registeredPaths.add(path);
    _callbacks[path] = onResume;
  }

  void unregister(String path) {
    _registeredPaths.remove(path);
    _callbacks.remove(path);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) return;
    final previousPath = _extractPath(previousRoute.settings);
    if (previousPath != null && _callbacks.containsKey(previousPath)) {
      Future.delayed(const Duration(milliseconds: 250), () {
        _callbacks[previousPath]?.call();
      });
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

/// Mixin for pages that need automatic refresh on resume (after pop).
mixin CLPageResumeMixin<T extends StatefulWidget> on State<T> {
  String get resumePath;
  void onResume();

  @override
  void initState() {
    super.initState();
    CLResumeObserver.instance.register(resumePath, onResume);
  }

  @override
  void dispose() {
    CLResumeObserver.instance.unregister(resumePath);
    super.dispose();
  }
}
