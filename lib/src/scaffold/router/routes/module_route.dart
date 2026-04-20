import 'package:flutter/material.dart';

import '../module.dart';
import 'modular_route.dart';

class ModuleRoute extends ModularRoute {
  late final String path;
  final Module module;
  late final String name;
  final IconData? icon;
  final dynamic _isVisible;
  final String? label;
  final bool showInTopBar;
  final bool showInSideMenu;
  final bool navigateOnTabTap;
  final bool onlyShowLabel;

  bool get isVisible =>
      _isVisible is bool Function() ? _isVisible() : (_isVisible as bool);

  ModuleRoute({
    required this.module,
    this.icon,
    dynamic isVisible = true,
    this.label,
    this.showInTopBar = true,
    this.showInSideMenu = true,
    this.navigateOnTabTap = false,
    this.onlyShowLabel = false,
  }) : _isVisible = isVisible {
    name = label ?? module.moduleRoute.name;
    path = module.moduleRoute.path;
  }

  bool get hasIcon => icon != null;

  Widget? buildIcon({double? size, Color? color}) {
    if (icon != null) return Icon(icon, size: size, color: color);
    return null;
  }
}
