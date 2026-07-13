import 'package:flutter/widgets.dart';

enum GenNavMode { bottomBar, rail, sidebar }

/// Parametri di layout dello shell. Default = valori attuali del progetto.
@immutable
class GenShellConfig {
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

  /// Opt-in (solo tier desktop/sidebar): layout "a bolle" stile shadcn dashboard.
  /// Menu FLAT sul canvas grigio (niente card) a sinistra; centro = UNA bolla
  /// arrotondata che contiene header frosted fisso + contenuto scrollabile sotto;
  /// assistente in bolla a destra. Default false → il desktop resta il layout
  /// classico (menu in bolla + header strip / full-bleed). Non tocca rail/mobile.
  final bool bubbleBody;

  /// Opt-in (solo tier sidebar espanso): la bolla `navHeader` diventa un pannello
  /// ad altezza regolabile con maniglia sul bordo basso; le destinations sotto
  /// prendono lo spazio rimanente. Default false → header frosted fisso (odierno).
  /// Ignorato in rail/mobile/drawer.
  final bool resizableNavHeader;

  const GenShellConfig({
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
GenNavMode resolveGenNavMode(double width, GenShellConfig config) {
  if (width >= config.desktopBreakpoint) return GenNavMode.sidebar;
  if (width >= config.tabletBreakpoint) return GenNavMode.rail;
  return GenNavMode.bottomBar;
}
