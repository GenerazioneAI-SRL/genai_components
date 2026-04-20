import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../path_utils.dart';
import '../page_transition.dart';
import 'genai_route.dart';
import 'modular_route.dart';

class ChildRoute extends ModularRoute {
  late String path;
  final Widget Function(BuildContext context, GoRouterState state) child;
  final String name;
  String? routeName;
  final Page<dynamic> Function(BuildContext context, GoRouterState state)? pageBuilder;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final FutureOr<String?> Function(BuildContext context, GoRouterState state)? redirect;
  final FutureOr<bool> Function(BuildContext context, GoRouterState state)? onExit;
  final PageTransition? pageTransition;
  IconData? icon;
  final bool isVisible;
  List<ChildRoute> routes;

  ChildRoute(
    this.path, {
    required this.child,
    required this.name,
    this.routeName,
    this.pageBuilder,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.icon,
    this.isVisible = true,
    this.pageTransition,
    this.routes = const [],
  });

  bool get hasIcon => icon != null;

  Widget? buildIcon({double? size, Color? color}) {
    if (icon != null) return Icon(icon, size: size, color: color);
    return null;
  }

  static ChildRoute build({
    required GenaiRoute route,
    List<String> params = const [],
    PageTransition pageTransition = PageTransition.fade,
    required Widget Function(BuildContext context, GoRouterState state) childBuilder,
    bool isModuleRoute = false,
    bool isVisible = true,
    IconData? icon,
    List<ChildRoute> routes = const [],
  }) {
    String routePath = '';
    if (!isModuleRoute) routePath = route.path;
    final String childRoutePath = '/$routePath/';
    final String argsPath = params.map((e) => ':$e').join('/');
    final String fullPath = GenaiPathUtils.buildPath(
      '${childRoutePath.isNotEmpty ? childRoutePath : ''}$argsPath',
    );
    final String name = _extractName(route.name);
    return ChildRoute(
      fullPath,
      child: childBuilder,
      name: name,
      routeName: route.name,
      pageTransition: pageTransition,
      isVisible: isVisible,
      icon: icon,
      routes: routes,
    );
  }

  static String _extractName(String path) {
    final regex = RegExp(r'^/([^/]+)/?');
    final match = regex.firstMatch(path);
    if (match != null && match.groupCount >= 1) return match.group(1)!;
    return path;
  }
}
