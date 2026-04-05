// child_route.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../page_transition_enum.dart';
import 'cl_route.dart';
import 'i_modular_route.dart';

class ChildRoute extends ModularRoute {
  late String path;
  final Widget Function(BuildContext context, GoRouterState state) child;
  final String name;
  String? routeName; // Nome originale della CLRoute per la navigazione
  final Page<dynamic> Function(BuildContext context, GoRouterState state)? pageBuilder;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final FutureOr<String?> Function(BuildContext context, GoRouterState state)? redirect;
  final FutureOr<bool> Function(BuildContext context, GoRouterState state)? onExit;
  final PageTransition? pageTransition;
  IconData? icon;
  HugeIcon? hugeIcon;
  final bool isVisible;
  List<ChildRoute> routes = [];

  ChildRoute(this.path,
      {required this.child,
      required this.name,
      this.routeName,
      this.pageBuilder,
      this.parentNavigatorKey,
      this.redirect,
      this.onExit,
      this.icon,
      this.hugeIcon,
      this.isVisible = true,
      this.pageTransition,
      this.routes = const []});

  /// Restituisce true se ha un'icona (IconData o HugeIcon)
  bool get hasIcon => icon != null || hugeIcon != null;

  /// Restituisce il widget icona appropriato, con priorità a IconData
  Widget? buildIcon({double? size, Color? color}) {
    if (icon != null) {
      return Icon(icon, size: size, color: color);
    }
    if (hugeIcon != null) {
      return HugeIcon(
        icon: hugeIcon!.icon,
        size: size,
        color: color,
      );
    }
    return null;
  }

  /// Metodo statico per costruire una istanza di ChildRoute
  static ChildRoute build(
      {required CLRoute route,
      List<String> params = const [],
      PageTransition pageTransition = PageTransition.fade,
      required Widget Function(BuildContext context, GoRouterState state) childBuilder,
      bool isModuleRoute = false,
      bool isVisible = true,
      List<ChildRoute> routes = const []}) {
    String routePath = "";
    if (!isModuleRoute) {
      routePath = route.path;//routeName.replaceAll(" ", "-").toLowerCase();
    }
    String childRoutePath = "/$routePath/";
    String argsPath = params.map((e) => ":$e").join("/");

    String fullPath = _buildPath(
      "${childRoutePath.isNotEmpty ? childRoutePath : ''}$argsPath",
    );

    String name = _extractName(route.name);

    return ChildRoute(fullPath, child: childBuilder, name: name, routeName: route.name, pageTransition: pageTransition, isVisible: isVisible, routes: routes);
  }

  static String _extractName(String path) {
    final regex = RegExp(r'^/([^/]+)/?');
    final match = regex.firstMatch(path);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }

    return path;
  }

  static String _buildPath(String path) {
    if (!path.endsWith('/')) {
      path = '$path/';
    }
    path = path.replaceAll(RegExp(r'/+'), '/');
    if (path == '/') return path;
    return path.substring(0, path.length - 1);
  }
}
