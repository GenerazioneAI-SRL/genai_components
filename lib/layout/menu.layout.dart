import '../widgets/logo.widget.dart';
import '../core_utils/extension.util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../auth/cl_auth_state.dart';
import '../providers/theme_provider.dart';
import '../router/go_router_modular/routes/modular_route.dart';
import 'constants/sizes.constant.dart';
import '../router/go_router_modular/routes/child_route.dart';
import '../router/go_router_modular/routes/module_route.dart';
import '../router/go_router_modular/routes/shell_modular_route.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../cl_theme.dart';

class MenuLayout extends StatefulWidget {
  final List<ModularRoute> routes;
  final String? logoImagePath;
  final String? logoImagePathMini;

  const MenuLayout({super.key, required this.routes, this.logoImagePath, this.logoImagePathMini});

  @override
  createState() => _MenuLayoutState();
}

class _MenuLayoutState extends State<MenuLayout> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<CLAuthState>();
    final navigationState = context.watch<NavigationState>();
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mobile: sfondo opaco. Desktop: trasparente (il glass è nel container di app.layout)
    final menuBg = isMobile ? (isDark ? theme.primaryBackground : Colors.white) : Colors.transparent;

    return Container(
      width: isMobile ? double.infinity : null,
      color: isMobile ? menuBg : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.padding),
            child: _MenuHeader(authState: authState, isMobile: isMobile, onClose: () => _closeDrawer(context)),
          ),

          // ── Tenant Card ──────────────────────────────────────
          if (authState.currentTenant != null)
            _TenantCard(
              authState: authState,
              isMobile: isMobile,
              onTap: () {
                if (isMobile) _closeDrawer(context);
                context.customGoNamed('La mia azienda');
              },
              onSwitch: authState.tenantList.length > 1
                  ? () {
                      if (isMobile) _closeDrawer(context);
                      authState.setCurrentTenant(null);
                    }
                  : null,
            ),

          // ── Divider ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: isMobile ? 6 : 8),
            child: Divider(color: theme.borderColor, height: 1, thickness: 1),
          ),

          // ── Voci menu ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, Sizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var route in widget.routes)
                    if (route is ChildRoute && route.isVisible)
                      _buildChildRoute(navigationState, route)
                    else if (route is ModuleRoute && route.isVisible && route.showInSideMenu && !route.onlyShowLabel)
                      _buildVisibleModuleRoute(navigationState, route)
                    else if (route is ModuleRoute && route.isVisible && (route.onlyShowLabel || !route.showInSideMenu))
                      ..._buildSectionModule(navigationState, route)
                    else if (route is ShellModularRoute)
                      for (var subRoute in route.routes)
                        if (subRoute is ChildRoute && subRoute.isVisible)
                          _buildChildRoute(navigationState, subRoute)
                        else if (subRoute is ModuleRoute && subRoute.isVisible && subRoute.showInSideMenu && !subRoute.onlyShowLabel)
                          _buildVisibleModuleRoute(navigationState, subRoute)
                        else if (subRoute is ModuleRoute && subRoute.isVisible && (subRoute.onlyShowLabel || !subRoute.showInSideMenu))
                          ..._buildSectionModule(navigationState, subRoute),

                  // ── Mobile: Profilo + Logout + Versione ──────────
                  if (isMobile) ...[
                    const SizedBox(height: 12),
                    // Versione (scorre con il menu su mobile)
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final info = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'v${info.version} (${info.buildNumber})',
                            textAlign: TextAlign.center,
                            style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Footer: Pulsante Test UI ──────────────────────
          /*Padding(
            padding: EdgeInsets.fromLTRB(
              Sizes.padding * 0.6,
              0,
              Sizes.padding * 0.6,
              8,
            ),
            child: GestureDetector(
              onTap: () {
                if (isMobile) _closeDrawer(context);
                context.go('/test-ui');
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.padding * 0.75,
                    vertical: Sizes.padding * 0.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primary.withValues(alpha: 0.12),
                        theme.secondary.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedPaintBoard,
                            color: theme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test nuova UI',
                              style: theme.bodyLabel.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 12.5 : 13,
                                color: theme.primary,
                              ),
                            ),
                            Text(
                              'Prova il nuovo layout',
                              style: theme.smallLabel.copyWith(
                                color: theme.secondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: theme.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),*/

          // ── Footer: Toggle tema (solo desktop — su mobile è nell'intestazione drawer) ──
          if (!isMobile)
            Padding(
              padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, Sizes.padding * 0.75),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  final isDarkNow = themeProvider.isDarkMode;
                  return GestureDetector(
                    onTap: () async => await themeProvider.toggleTheme(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.75, vertical: Sizes.padding * 0.5),
                        decoration: BoxDecoration(
                          color: isDark ? theme.secondaryBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? theme.borderColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDarkNow ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: isDarkNow ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun03,
                                  color: isDarkNow ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
                                  size: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isDarkNow ? 'Modalità scura' : 'Modalità chiara',
                                style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                            _ThemeToggleSwitch(isDark: isDarkNow),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── Versione app (solo desktop — su mobile scorre con le voci) ──
          if (!isMobile)
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final info = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'v${info.version} (${info.buildNumber})',
                    textAlign: TextAlign.center,
                    style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10),
                  ),
                );
              },
            ),

          // ── Header ──────────────────────────────────────────
        ],
      ),
    );
  }

  void _closeDrawer(BuildContext context) {
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  /// Restituisce la singola ChildRoute visibile di un ModuleRoute, configurata
  /// con l'icona e il path corretti, se il modulo ha esattamente una pagina
  /// visibile (anche attraverso un livello di ModuleRoute annidato).
  /// Restituisce null se il modulo deve essere mostrato come gruppo espandibile.
  ChildRoute? _extractSingleVisibleChild(ModuleRoute route) {
    final visibleCount = _countVisibleRoutes(route.module.routes);
    if (visibleCount != 1) return null;

    // Caso A: ChildRoute diretta
    final directChild = route.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).firstOrNull;
    if (directChild != null) {
      return directChild
        ..icon = route.icon
        ..hugeIcon = route.hugeIcon
        ..path = route.module.moduleRoute.path;
    }

    // Caso B: singolo ModuleRoute annidato con una sola ChildRoute visibile
    final nestedModule = route.module.routes.whereType<ModuleRoute>().where((r) => r.isVisible).firstOrNull;
    if (nestedModule != null) {
      final nestedVisible = _countVisibleRoutes(nestedModule.module.routes);
      if (nestedVisible == 1) {
        final nestedChild = nestedModule.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).firstOrNull;
        if (nestedChild != null) {
          return nestedChild
            ..icon = route.icon
            ..hugeIcon = route.hugeIcon
            ..path = "${route.module.moduleRoute.path}${nestedModule.module.moduleRoute.path}".replaceAll('//', '/');
        }
      }
    }

    return null;
  }

  /// Costruisce la voce di menu per un ModuleRoute visibile con showInSideMenu=true:
  /// - voce singola con icona se il modulo ha una sola pagina visibile
  /// - gruppo espandibile altrimenti
  Widget _buildVisibleModuleRoute(NavigationState navigationState, ModuleRoute route) {
    final singleChild = _extractSingleVisibleChild(route);
    if (singleChild != null) {
      return _buildChildRoute(navigationState, singleChild);
    }
    return _buildGroupRoute(navigationState, route, depth: 0);
  }

  Widget _buildChildRoute(NavigationState navigationState, ChildRoute route) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final selected = _isSelected(navigationState, route.path);
    final theme = CLTheme.of(context);
    final iconSize = isMobile ? 19.0 : 20.0;

    return _MenuTile(
      label: route.name,
      icon: route.hasIcon ? route.buildIcon(size: iconSize, color: selected ? theme.primary : theme.secondaryText) : null,
      selected: selected,
      isMobile: isMobile,
      onTap: () {
        if (isMobile) _closeDrawer(context);
        context.customGoNamed(route.name);
      },
    );
  }

  // ── Modulo come sezione con label + children strutturati ─────────────────────
  List<Widget> _buildSectionModule(NavigationState navigationState, ModuleRoute parentRoute) {
    final List<Widget> widgets = [];
    final theme = CLTheme.of(context);
    final defaultIcon = HugeIcons.strokeRoundedFolder01;

    // Section label
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 12, top: 14, bottom: 6),
        child: Text(
          parentRoute.name.toUpperCase(),
          style: theme.smallLabel.copyWith(
            color: theme.secondaryText.withValues(alpha: 0.55),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );

    // Children
    final basePath = parentRoute.module.moduleRoute.path;
    for (final childRoute in parentRoute.module.routes) {
      if (childRoute is ChildRoute && childRoute.isVisible) {
        // Voce singola direttamente sotto la sezione → con icona fallback
        if (!childRoute.hasIcon) {
          childRoute.hugeIcon = HugeIcon(icon: defaultIcon);
        }
        widgets.add(_buildChildRoute(navigationState, childRoute..path = basePath));
      } else if (childRoute is ModuleRoute && childRoute.isVisible) {
        final visibleCount = _countVisibleRoutes(childRoute.module.routes);
        if (visibleCount == 1) {
          // Caso A: singola ChildRoute diretta
          final directChild = childRoute.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).firstOrNull;
          if (directChild != null) {
            directChild
              ..icon = childRoute.icon
              ..hugeIcon = childRoute.hugeIcon ?? HugeIcon(icon: defaultIcon)
              ..path = "$basePath${childRoute.module.moduleRoute.path}".replaceAll('//', '/');
            widgets.add(_buildSectionChildRoute(
              navigationState,
              directChild,
              displayName: childRoute.name,
            ));
            continue;
          }
          // Caso B: singolo ModuleRoute annidato con una sola ChildRoute visibile
          final nestedModule = childRoute.module.routes.whereType<ModuleRoute>().where((r) => r.isVisible).firstOrNull;
          if (nestedModule != null && _countVisibleRoutes(nestedModule.module.routes) == 1) {
            final nestedChild = nestedModule.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).firstOrNull;
            if (nestedChild != null) {
              nestedChild
                ..icon = childRoute.icon
                ..hugeIcon = childRoute.hugeIcon ?? HugeIcon(icon: defaultIcon)
                ..path = "$basePath${childRoute.module.moduleRoute.path}${nestedModule.module.moduleRoute.path}".replaceAll('//', '/');
              widgets.add(_buildSectionChildRoute(
                navigationState,
                nestedChild,
                displayName: childRoute.name,
              ));
              continue;
            }
          }
        }
        // Modulo con più voci → dropdown espandibile con icona e freccia
        widgets.add(_buildGroupRoute(navigationState, childRoute, basePath: basePath, depth: 0));
      }
    }
    return widgets;
  }

  /// Voce singola dentro una sezione, con nome personalizzabile
  Widget _buildSectionChildRoute(NavigationState navigationState, ChildRoute route, {String? displayName}) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final selected = _isSelected(navigationState, route.path, isParentRoute: true);
    final theme = CLTheme.of(context);
    final iconSize = isMobile ? 19.0 : 20.0;

    return _MenuTile(
      label: displayName ?? route.name,
      icon: route.hasIcon
          ? route.buildIcon(size: iconSize, color: selected ? theme.primary : theme.secondaryText)
          : HugeIcon(icon: HugeIcons.strokeRoundedFolder01, size: iconSize, color: selected ? theme.primary : theme.secondaryText),
      selected: selected,
      isMobile: isMobile,
      onTap: () {
        if (isMobile) _closeDrawer(context);
        // Usa il path assoluto già calcolato da _buildSectionModule per evitare
        // che customGoNamed risolva il nome sbagliato quando lo stesso modulo
        // (es. TrainingPlanModule) è registrato sotto più sezioni.
        context.go(route.path);
      },
    );
  }

  // ── Gruppo espandibile ─────────────────────────────────────────────────────
  Widget _buildGroupRoute(NavigationState navigationState, ModuleRoute subRoute, {String basePath = '', int depth = 0}) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final currentPath = "$basePath${subRoute.path}".replaceAll('//', '/');
    final isSelected = _isSelected(navigationState, currentPath, isParentRoute: true);
    final theme = CLTheme.of(context);
    final iconSize = isMobile ? 19.0 : 20.0;
    final iconColor = isSelected ? theme.primary : theme.secondaryText;

    return _MenuGroup(
      title: subRoute.name,
      isSelected: isSelected,
      isMobile: isMobile,
      depth: depth,
      icon: subRoute.buildIcon(size: iconSize, color: iconColor) ?? HugeIcon(icon: HugeIcons.strokeRoundedFolder01, size: iconSize, color: iconColor),
      children: [
        for (var childRoute in subRoute.module.routes)
          if (childRoute is ChildRoute && childRoute.isVisible)
            _MenuSubTile(
              label: childRoute.name,
              selected: _isSelected(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/')),
              isMobile: isMobile,
              depth: depth,
              onTap: () {
                if (isMobile) _closeDrawer(context);
                context.customGoNamed(childRoute.routeName ?? childRoute.name);
              },
            )
          else if (childRoute is ModuleRoute && childRoute.isVisible)
            if (childRoute.module.routes.where((r) => r is ChildRoute && r.isVisible).length == 1)
              _MenuSubTile(
                // Usa il nome del ModuleRoute (rispetta label override) invece del ChildRoute interno
                label: childRoute.name,
                selected: _isSelected(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/')),
                isMobile: isMobile,
                depth: depth,
                onTap: () {
                  if (isMobile) _closeDrawer(context);
                  context.go("$currentPath${childRoute.path}".replaceAll('//', '/'));
                },
              )
            else
              _buildGroupRoute(navigationState, childRoute, basePath: currentPath, depth: depth + 1),
      ],
    );
  }

  /// Conta tutte le route visibili (sia ChildRoute che ModuleRoute)
  int _countVisibleRoutes(List<ModularRoute> routes) {
    int count = 0;
    for (final r in routes) {
      if (r is ChildRoute && r.isVisible) count++;
      if (r is ModuleRoute && r.isVisible) count++;
    }
    return count;
  }

  bool _isSelected(NavigationState navigationState, String fullPath, {bool isParentRoute = false}) {
    final currentUri = Router.of(context).routeInformationProvider?.value.uri;
    var norm = fullPath.endsWith('/') ? fullPath.substring(0, fullPath.length - 1) : fullPath;
    final current = currentUri.toString();
    if (isParentRoute) {
      return current == norm || (current.startsWith(norm) && current.length > norm.length && current[norm.length] == '/');
    }
    return current == norm;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sotto-widget interni
// ═══════════════════════════════════════════════════════════════════════════

/// Header del menu: logo + (mobile only: tema toggle + close button)
class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.authState, required this.isMobile, required this.onClose});

  final CLAuthState authState;
  final bool isMobile;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Sizes.padding,
        isMobile ? Sizes.padding * 0.8 : Sizes.padding * 0.75,
        isMobile ? Sizes.padding * 0.5 : Sizes.padding,
        0,
      ),
      child: Row(
        children: [
          // Toggle tema (solo mobile) — a sinistra del logo
          if (isMobile) ...[
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final isDarkNow = themeProvider.isDarkMode;
                return Tooltip(
                  message: isDarkNow ? 'Modalità chiara' : 'Modalità scura',
                  child: GestureDetector(
                    onTap: () async => await themeProvider.toggleTheme(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDarkNow ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: isDarkNow ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun03,
                            color: isDarkNow ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          // Logo SVG — al centro
          Expanded(child: LogoWidget(height: isMobile ? 22 : 24, dark: false, color: theme.primary)),
          // Close button (solo mobile) — a destra del logo
          if (isMobile) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: theme.borderColor),
                ),
                child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: theme.secondaryText, size: 17)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card tenant — mostra workspace corrente con due azioni esplicite
class _TenantCard extends StatelessWidget {
  const _TenantCard({required this.authState, required this.isMobile, required this.onTap, this.onSwitch});

  final CLAuthState authState;
  final bool isMobile;
  final VoidCallback onTap;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyName = authState.currentTenant!.name;
    final vatNumber = authState.currentTenant!.rawData['vatNumber'];
    final subtitle = vatNumber != null ? 'P.IVA $vatNumber' : 'Workspace attivo';

    final cardBg = isDark ? theme.secondaryBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.55);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.padding * 0.6, vertical: isMobile ? 2 : 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Info azienda ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
                ),
                child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedBuilding04, color: theme.primary, size: 15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(subtitle, style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Bottoni azione ────────────────────────────────
          Row(
            children: [
              // Vai all'azienda
              Expanded(
                child: _TenantActionButton(
                  label: 'La mia azienda',
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  isPrimary: true,
                  onTap: onTap,
                  theme: theme,
                ),
              ),
              // Cambia azienda (solo multi-tenant)
              if (onSwitch != null) ...[
                const SizedBox(width: 6),
                _TenantActionButton(
                  label: 'Cambia',
                  icon: HugeIcons.strokeRoundedRepeat,
                  isPrimary: false,
                  onTap: onSwitch!,
                  theme: theme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottone azione compatto usato dentro _TenantCard
class _TenantActionButton extends StatefulWidget {
  const _TenantActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final dynamic icon;
  final bool isPrimary;
  final VoidCallback onTap;
  final CLTheme theme;

  @override
  State<_TenantActionButton> createState() => _TenantActionButtonState();
}

class _TenantActionButtonState extends State<_TenantActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final color = widget.isPrimary ? t.primary : t.secondaryText;
    final bg = widget.isPrimary ? (_hovered ? t.primary.withValues(alpha: 0.14) : t.primary.withValues(alpha: 0.08)) : Colors.transparent;
    final border =
        widget.isPrimary ? Border.all(color: Colors.transparent) : Border.all(color: _hovered ? t.borderColor.withValues(alpha: 0.8) : t.borderColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(7),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isPrimary) ...[
                Flexible(
                  child: Text(
                    widget.label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11, fontFamily: 'Inter'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                HugeIcon(icon: widget.icon, size: 11, color: color),
              ] else ...[
                Text(widget.label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 11, fontFamily: 'Inter')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Voce di menu principale con pill indicatore, sfondo e hover
class _MenuTile extends StatefulWidget {
  const _MenuTile({required this.label, required this.selected, required this.isMobile, required this.onTap, this.icon});

  final String label;
  final Widget? icon;
  final bool selected;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hovered = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = widget.isMobile ? 42.0 : 40.0;

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _hovered = true),
      onExit: (_) => _safeSetState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: h,
          child: Stack(
            children: [
              // Box colorato con margine sinistro dal bordo del menu
              Positioned.fill(
                top: 1.5,
                bottom: 1.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? theme.primary.withValues(alpha: 0.12)
                        : _hovered
                            ? theme.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Contenuto: icona e testo restano alla posizione originale (left: 12)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: widget.icon != null ? Center(child: widget.icon!) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: theme.bodyLabel.override(
                          color: widget.selected ? theme.primary : theme.secondaryText,
                          fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: widget.isMobile ? 13 : 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gruppo espandibile con stile coerente
class _MenuGroup extends StatefulWidget {
  const _MenuGroup({
    required this.title,
    required this.isSelected,
    required this.isMobile,
    required this.icon,
    required this.children,
    this.depth = 0,
  });

  final String title;
  final bool isSelected;
  final bool isMobile;
  final Widget icon;
  final List<Widget> children;
  final int depth;

  @override
  State<_MenuGroup> createState() => _MenuGroupState();
}

class _MenuGroupState extends State<_MenuGroup> with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _rotationCtrl;
  bool _hovered = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();
    _expanded = widget.isSelected;
    _rotationCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: _expanded ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _rotationCtrl.forward() : _rotationCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isNested = widget.depth > 0;

    // Stile diverso per gruppi annidati
    if (isNested) {
      return _buildNestedGroup(theme);
    }
    return _buildTopLevelGroup(theme);
  }

  /// Gruppo di primo livello (depth == 0) — contenitore visivo raggruppato
  Widget _buildTopLevelGroup(CLTheme theme) {
    final h = widget.isMobile ? 42.0 : 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => _safeSetState(() => _hovered = true),
          onExit: (_) => _safeSetState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _toggle,
            child: SizedBox(
              height: h,
              child: Stack(
                children: [
                  // Box colorato con margine sinistro dal bordo del menu
                  Positioned.fill(
                    top: 1.5,
                    bottom: 1.5,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: _hovered ? theme.primary.withValues(alpha: 0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Contenuto: icona e testo restano alla posizione originale (left: 12)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 20, child: Center(child: widget.icon)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.bodyLabel.override(
                              color: widget.isSelected ? theme.primary : theme.secondaryText,
                              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: widget.isMobile ? 13 : 13.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 0.25).animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              size: 15,
                              color: widget.isSelected ? theme.primary : theme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Stack(
                    children: [
                      // Linea verticale allineata al centro dell'icona del parent (left 12 + 10 = 22px)
                      Positioned(
                        left: 21,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1.5,
                          color: theme.borderColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Gruppo annidato (depth >= 1) — stile indentato con contenitore visivo
  Widget _buildNestedGroup(CLTheme theme) {
    final h = widget.isMobile ? 42.0 : 40.0;
    // Primo livello di nesting: 38px (allinea con sub-tile hover box a 32px + margine)
    // Ogni livello successivo: +16px incrementali
    final nestedPadding = widget.depth == 1 ? 38.0 : 16.0;

    return Padding(
      padding: EdgeInsets.only(left: nestedPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) {
              if (mounted) setState(() => _hovered = true);
            },
            onExit: (_) {
              if (mounted) setState(() => _hovered = false);
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: h,
                decoration: BoxDecoration(
                  color: _hovered ? theme.primary.withValues(alpha: 0.04) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Spaziatura icona identica al top-level (12+20+10=42px per il testo)
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 20,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFolder01,
                          size: 16,
                          color: widget.isSelected ? theme.primary : theme.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.bodyLabel.override(
                          color: widget.isSelected ? theme.primary : theme.secondaryText,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: widget.isMobile ? 13 : 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.25).animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 14,
                          color: widget.isSelected ? theme.primary : theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Voce figlia indentata sotto un gruppo espandibile
class _MenuSubTile extends StatefulWidget {
  const _MenuSubTile({required this.label, required this.selected, required this.isMobile, required this.onTap, this.depth = 0});

  final String label;
  final bool selected;
  final bool isMobile;
  final VoidCallback onTap;
  final int depth;

  @override
  State<_MenuSubTile> createState() => _MenuSubTileState();
}

class _MenuSubTileState extends State<_MenuSubTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = widget.isMobile ? 38.0 : 36.0;
    // Allineamento testo: 32 (area icona) + 10 (padding) = 42px
    // Identico a _MenuTile e _MenuGroup header (12 + 20 + 10 = 42px)
    const double boxLeftMargin = 32.0;

    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _hovered = false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          height: h,
          child: Padding(
            padding: EdgeInsets.only(left: boxLeftMargin, top: 1, bottom: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: widget.selected
                    ? theme.primary.withValues(alpha: 0.1)
                    : _hovered
                        ? theme.primary.withValues(alpha: 0.04)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
                style: theme.bodyText.copyWith(
                  color: widget.selected ? theme.primary : theme.secondaryText,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: widget.isMobile ? 13 : 13.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Voce logout per il menu mobile — con colore danger
class _MobileLogoutTile extends StatefulWidget {
  const _MobileLogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MobileLogoutTile> createState() => _MobileLogoutTileState();
}

class _MobileLogoutTileState extends State<_MobileLogoutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    const h = 42.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                top: 1.5,
                bottom: 1.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: _hovered ? theme.danger.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Center(
                        child: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: theme.danger, size: 19),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: theme.bodyLabel.copyWith(
                        color: theme.danger,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini switch visivo per il toggle tema nel footer del menu
class _ThemeToggleSwitch extends StatelessWidget {
  const _ThemeToggleSwitch({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 20,
      decoration: BoxDecoration(color: isDark ? theme.primary.withValues(alpha: 0.8) : theme.borderColor, borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isDark ? 18.0 : 2.0,
            top: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
