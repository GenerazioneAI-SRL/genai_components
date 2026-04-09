import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

import '../module.dart';
import 'modular_route.dart';

class ModuleRoute extends ModularRoute {
  late final String path;
  final Module module;
  late final String name;
  final IconData? icon;
  final HugeIcon? hugeIcon;
  final bool isVisible;

  /// Etichetta personalizzata da mostrare nel menu al posto di module.moduleRoute.name.
  final String? label;

  /// Se true, il modulo compare come tab nella top bar.
  final bool showInTopBar;

  /// Se true, il modulo compare nel side menu.
  final bool showInSideMenu;

  /// Se true, cliccando la tab nella top bar si naviga alla root del modulo.
  /// Se false, cambia solo il menu laterale senza navigare.
  final bool navigateOnTabTap;

  /// Se true, nel menu laterale il modulo viene mostrato come label grigia
  /// con le voci figlie esplose direttamente sotto (no dropdown collassabile).
  /// Utile per i moduli "contenitore" grandi (HR, Cert, LMS, ecc.).
  final bool onlyShowLabel;

  ModuleRoute({
    required this.module,
    this.icon,
    this.hugeIcon,
    this.isVisible = true,
    this.label,
    this.showInTopBar = true,
    this.showInSideMenu = true,
    this.navigateOnTabTap = false,
    this.onlyShowLabel = false,
  }) {
    name = label ?? module.moduleRoute.name;
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
