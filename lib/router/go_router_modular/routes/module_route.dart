import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

import '../module.dart';
import 'i_modular_route.dart';

class ModuleRoute extends ModularRoute {
  late final String path;
  final Module module;
  late final String name;
  final IconData? icon;
  final HugeIcon? hugeIcon;
  final bool isVisible;

  /// Se true, il modulo compare come tab nella top bar.
  final bool showInTopBar;

  /// Se true, il modulo compare nel side menu.
  final bool showInSideMenu;

  ModuleRoute({
    required this.module,
    this.icon,
    this.hugeIcon,
    this.isVisible = true,
    this.showInTopBar = true,
    this.showInSideMenu = true,
  }) {
    name = module.moduleRoute.name;
    path = module.moduleRoute.path;
  }

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
}
