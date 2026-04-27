import '../widgets/logo.widget.dart';
import '../core_utils/extension.util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../auth/cl_auth_state.dart';
import '../auth/cl_user_info.dart';
import '../providers/app_state.dart';
import '../providers/theme_provider.dart';
import '../app/cl_app_config.dart';
import '../router/go_router_modular/routes/modular_route.dart';
import 'constants/sizes.constant.dart';
import '../router/go_router_modular/routes/child_route.dart';
import '../router/go_router_modular/routes/module_route.dart';
import '../router/go_router_modular/routes/shell_modular_route.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../cl_theme.dart';
import '../widgets/avatar.widget.dart';
import '../widgets/cl_popup_menu.widget.dart';

part 'menu_parts/_header.part.dart';
part 'menu_parts/_tenant.part.dart';
part 'menu_parts/_tiles.part.dart';
part 'menu_parts/_group.part.dart';
part 'menu_parts/_footer.part.dart';

class CLMenuLayout extends StatefulWidget {
  final List<ModularRoute> routes;
  final String? logoImagePath;
  final String? logoImagePathMini;
  final Widget Function(BuildContext context)? logoBuilder;
  final Widget Function(BuildContext context)? menuExtraBuilder;
  final Widget Function(BuildContext context)? menuFooterBuilder;

  const CLMenuLayout({
    super.key,
    required this.routes,
    this.logoImagePath,
    this.logoImagePathMini,
    this.logoBuilder,
    this.menuExtraBuilder,
    this.menuFooterBuilder,
  });

  @override
  createState() => _CLMenuLayoutState();
}

class _CLMenuLayoutState extends State<CLMenuLayout> {
  @override
  Widget build(BuildContext context) {
    // NavigationState: il menu si ridisegna solo al cambio di pageName
    // (proxy del cambio rotta — guida lo stato selected delle voci).
    context.select<NavigationState, String>((s) => s.pageName);
    final navigationState = context.read<NavigationState>();
    // CLAuthState: rebuild su tenant/user changes (tenant card + header).
    // Sottoscrizioni mirate ai campi effettivamente letti.
    context.select<CLAuthState, dynamic>((s) => s.currentTenant);
    context.select<CLAuthState, int>((s) => s.tenantList.length);
    context.select<CLAuthState, CLUserInfo?>((s) => s.currentUserInfo);
    final authState = context.read<CLAuthState>();
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);

    // Mobile: sfondo opaco. Desktop: trasparente (il glass è nel container di app.layout)
    final menuBg = isMobile ? theme.secondaryBackground : Colors.transparent;

    return Container(
      width: isMobile ? double.infinity : null,
      color: isMobile ? menuBg : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.padding),
            child: _MenuHeader(authState: authState, isMobile: isMobile, onClose: () => _closeDrawer(context), logoBuilder: widget.logoBuilder),
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

          // ── Extra builder (es. Company/Store selector) ──────
          if (widget.menuExtraBuilder != null) widget.menuExtraBuilder!(context),

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
                    const _MenuVersionLabel(bottomPadding: 4.0),
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

          // ── Footer custom (es. card utente con logout) ──────
          if (widget.menuFooterBuilder != null) widget.menuFooterBuilder!(context),

          // ── Pulsante AI (se posizione = menu) ──────────────
          const _MenuAiButton(),

          // ── Profilo utente (se posizione = menu) ───────────────
          const _MenuUserProfile(),

          // ── Footer: Toggle tema (solo desktop — su mobile è nell'intestazione drawer) ──
          if (!isMobile) const _MenuThemeToggle(),

          // ── Versione app (solo desktop — su mobile scorre con le voci) ──
          if (!isMobile) const _MenuVersionLabel(bottomPadding: 8.0),

          // ── Header ──────────────────────────────────────────
        ],
      ),
    );
  }

  void _closeDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) {
      scaffold!.closeDrawer();
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
/// Retrocompatibilità: il vecchio nome [MenuLayout] resta disponibile come alias.
typedef MenuLayout = CLMenuLayout;
