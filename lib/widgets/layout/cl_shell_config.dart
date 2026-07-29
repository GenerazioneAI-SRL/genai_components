import 'package:flutter/widgets.dart';

enum CLNavMode { bottomBar, rail, sidebar }

/// Parametri di layout dello shell. Default = valori attuali del progetto.
@immutable
class CLShellConfig {
  /// < tablet → mobile (bottom bar). Default 600.
  final double tabletBreakpoint;

  /// >= desktop → sidebar. [tablet, desktop) → rail (icon-only). Default 1079.
  final double desktopBreakpoint;

  final double sidebarWidth;     // 268
  final double railWidth;        // 72 (rail icon-only tablet)
  final double trailingWidth;    // 360 (pannello AI desktop)
  final int maxBottomBarItems;   // 5
  final double drawerWidthFactor; // 0.85 (mobile/tablet)

  /// Opt-in: attiva lo shell mobile "full-bleed" (contenuto edge-to-edge sotto
  /// header/bolla in blur). Default false → comportamento legacy invariato.
  final bool frostedFullBleed;

  /// Opt-in: layout desktop/tablet "a bolle" (dashboard shadcn). Menu FLAT sul
  /// canvas grigio a sinistra, UNA bolla centrale arrotondata (header frosted
  /// fisso + contenuto scrollabile che scorre SOTTO l'header), assistente in
  /// bolla a destra. Su mobile ricade sul path frosted con bottom bar. Default
  /// false → comportamento invariato.
  final bool bubbleBody;

  /// Opt-in: nella sidebar espansa la bolla [navHeader] diventa un pannello ad
  /// altezza regolabile con maniglia di drag sul bordo basso; le destinazioni
  /// sotto occupano lo spazio residuo (scorrono sotto l'header). Default false.
  final bool resizableNavHeader;

  const CLShellConfig({
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 1079,
    this.sidebarWidth = 268,
    this.railWidth = 72,
    this.trailingWidth = 360,
    this.maxBottomBarItems = 5,
    this.drawerWidthFactor = 0.85,
    this.frostedFullBleed = false,
    this.bubbleBody = false,
    this.resizableNavHeader = false,
  });
}

/// Larghezza → modalità navigazione.
CLNavMode resolveCLNavMode(double width, CLShellConfig config) {
  if (width >= config.desktopBreakpoint) return CLNavMode.sidebar;
  if (width >= config.tabletBreakpoint) return CLNavMode.rail;
  return CLNavMode.bottomBar;
}
