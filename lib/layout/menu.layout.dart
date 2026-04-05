import 'package:cl_components/widgets/avatar.widget.dart';
import 'package:cl_components/widgets/logo.widget.dart';
import 'package:cl_components/core_utils/extension.util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'package:cl_components/auth/cl_auth_state.dart';
import 'package:cl_components/providers/theme_provider.dart';
import 'package:cl_components/layout/constants/sizes.constant.dart';
import 'package:cl_components/router/go_router_modular/routes/child_route.dart';
import 'package:cl_components/router/go_router_modular/routes/i_modular_route.dart';
import 'package:cl_components/router/go_router_modular/routes/module_route.dart';
import 'package:cl_components/router/go_router_modular/routes/shell_modular_route.dart';
import 'package:cl_components/utils/providers/navigation.util.provider.dart';
import 'package:cl_components/utils/providers/module_theme.util.provider.dart';
import 'package:cl_components/cl_theme.dart';

class MenuLayout extends StatefulWidget {
  final List<ModularRoute> routes;
  final String? logoImagePath;
  final String? logoImagePathMini;

  /// Callback quando l'utente clicca sul tenant card. Se null, il tap non fa nulla.
  final VoidCallback? onTenantTap;

  /// Se true, filtra le route per il modulo selezionato nella top bar.
  /// Se false, mostra tutte le route (comportamento classico).
  final bool moduleTabsEnabled;

  const MenuLayout({
    super.key,
    required this.routes,
    this.logoImagePath,
    this.logoImagePathMini,
    this.onTenantTap,
    this.moduleTabsEnabled = false,
  });

  @override
  createState() => _MenuLayoutState();
}

class _MenuLayoutState extends State<MenuLayout> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<CLAuthState>();
    final navigationState = context.watch<NavigationState>();
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isMobile ? double.infinity : null,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Logo & Header (solo mobile — su desktop è nella top bar) ──
          if (isMobile) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.padding),
              child: _MenuHeader(authState: authState, isMobile: isMobile, onClose: () => _closeDrawer(context)),
            ),

            // ── Tenant Card ──
            if (authState.currentTenant != null)
              _TenantCard(
                authState: authState,
                isMobile: isMobile,
                onTap: () {
                  if (isMobile) _closeDrawer(context);
                  widget.onTenantTap?.call();
                },
                onSwitch: authState.tenantList.length > 1
                    ? () {
                        if (isMobile) _closeDrawer(context);
                        authState.setCurrentTenant(null);
                      }
                    : null,
              ),

            // ── Divider ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: 6),
              child: Divider(color: theme.borderColor, height: 1, thickness: 1),
            ),
          ] else ...[
            // Desktop: piccolo padding in alto
            const SizedBox(height: 12),
          ],

          // ── Voci menu ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 0, 0, Sizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildMenuItems(navigationState, isMobile),
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

          // ── Footer: Toggle tema ──────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, isMobile ? Sizes.padding * 1.2 : Sizes.padding * 0.75),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final isDarkNow = themeProvider.isDarkMode;
                return GestureDetector(
                  onTap: () async => await themeProvider.toggleTheme(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.75, vertical: Sizes.padding * 0.6),
                    decoration: BoxDecoration(
                      color: isDark ? theme.secondaryBackground : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDarkNow ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: isDarkNow ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun03,
                              color: isDarkNow ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
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
                                isDarkNow ? 'Modalità scura' : 'Modalità chiara',
                                style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w500, fontSize: isMobile ? 12.5 : 13),
                              ),
                              Text('Tocca per cambiare', style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10)),
                            ],
                          ),
                        ),
                        // Switch toggle visivo
                        _ThemeToggleSwitch(isDark: isDarkNow),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Versione app ─────────────────────────────────────
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
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

  // ── Logica costruzione voci menu ────────────────────────────────────────────

  /// Su desktop con moduleTabsEnabled: mostra solo le sotto-route del modulo selezionato.
  /// Altrimenti: mostra tutte le route (comportamento classico).
  List<Widget> _buildMenuItems(NavigationState navigationState, bool isMobile) {
    // Mobile o moduleTabsEnabled disabilitato → mostra tutte le route
    if (isMobile || !widget.moduleTabsEnabled) {
      return _buildAllRoutes(navigationState, widget.routes);
    }

    // Desktop con module tabs: filtra per modulo selezionato
    final moduleTheme = context.watch<ModuleThemeProvider>();
    final activeModule = _findModuleForSelected(moduleTheme.selectedModule);
    if (activeModule != null) {
      return _buildModuleSubRoutes(navigationState, activeModule);
    }

    // Fallback: mostra tutte le route
    return _buildAllRoutes(navigationState, widget.routes);
  }

  /// Trova il ModuleRoute corrispondente al SkilleraModule selezionato.
  ModuleRoute? _findModuleForSelected(SkilleraModule selected) {
    final allModules = <ModuleRoute>[];
    for (final route in widget.routes) {
      if (route is ModuleRoute) {
        allModules.add(route);
      } else if (route is ShellModularRoute) {
        for (final sub in route.routes) {
          if (sub is ModuleRoute) allModules.add(sub);
        }
      }
    }

    for (final mod in allModules) {
      if (_moduleEnumFromPath(mod.path) == selected) {
        return mod;
      }
    }
    return null;
  }

  /// Mappa un path di modulo al corrispondente SkilleraModule.
  static SkilleraModule _moduleEnumFromPath(String path) {
    if (path.startsWith('/skill-hr')) return SkilleraModule.hr;
    if (path.startsWith('/skill-cert')) return SkilleraModule.cert;
    if (path.startsWith('/skill-lms')) return SkilleraModule.lms;
    if (path.startsWith('/skill-id')) return SkilleraModule.id;
    return SkilleraModule.concierge;
  }

  /// Costruisce le sotto-route di un singolo modulo (per la sidebar desktop).
  List<Widget> _buildModuleSubRoutes(NavigationState navigationState, ModuleRoute activeModule) {
    final List<Widget> items = [];
    final basePath = activeModule.path;

    for (final route in activeModule.module.routes) {
      if (route is ChildRoute && route.isVisible) {
        // Route figlia diretta del modulo
        items.add(_buildChildRoute(navigationState, route));
      } else if (route is ModuleRoute && route.isVisible) {
        // Sotto-modulo: se ha una sola route visibile → voce semplice, altrimenti → gruppo
        if (_countVisibleRoutes(route.module.routes) == 1 && route.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).isNotEmpty) {
          final child = route.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).first;
          items.add(_buildChildRoute(
            navigationState,
            child
              ..icon = route.icon
              ..hugeIcon = route.hugeIcon
              ..path = '$basePath${route.path}'.replaceAll('//', '/'),
          ));
        } else {
          items.add(_buildGroupRoute(navigationState, route, basePath: basePath, depth: 0));
        }
      }
    }

    return items;
  }

  /// Costruisce tutte le route (usato su mobile e come fallback).
  List<Widget> _buildAllRoutes(NavigationState navigationState, List<ModularRoute> routes) {
    final List<Widget> items = [];
    for (final route in routes) {
      if (route is ChildRoute && route.isVisible) {
        items.add(_buildChildRoute(navigationState, route));
      } else if (route is ModuleRoute && route.isVisible && route.showInSideMenu) {
        if (_countVisibleRoutes(route.module.routes) == 1 && route.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).isNotEmpty) {
          items.add(_buildChildRoute(
            navigationState,
            (route.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).first)
              ..icon = route.icon
              ..hugeIcon = route.hugeIcon
              ..path = route.module.moduleRoute.path,
          ));
        } else {
          items.add(_buildGroupRoute(navigationState, route, depth: 0));
        }
      } else if (route is ShellModularRoute) {
        for (final subRoute in route.routes) {
          if (subRoute is ChildRoute && subRoute.isVisible) {
            items.add(_buildChildRoute(navigationState, subRoute));
          } else if (subRoute is ModuleRoute && subRoute.isVisible && subRoute.showInSideMenu) {
            if (_countVisibleRoutes(subRoute.module.routes) == 1 &&
                subRoute.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).isNotEmpty) {
              items.add(_buildChildRoute(
                navigationState,
                (subRoute.module.routes.whereType<ChildRoute>().where((r) => r.isVisible).first)
                  ..icon = subRoute.icon
                  ..hugeIcon = subRoute.hugeIcon
                  ..path = subRoute.module.moduleRoute.path,
              ));
            } else {
              items.add(_buildGroupRoute(navigationState, subRoute, depth: 0));
            }
          }
        }
      }
    }
    return items;
  }

  // ── Voce semplice ──────────────────────────────────────────────────────────
  Widget _buildChildRoute(NavigationState navigationState, ChildRoute route) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final selected = _isSelected(navigationState, route.path);

    return _MenuTile(
      label: route.name,
      selected: selected,
      isMobile: isMobile,
      onTap: () {
        if (isMobile) _closeDrawer(context);
        context.customGoNamed(route.name);
      },
    );
  }

  // ── Sezione menu (flat) ────────────────────────────────────────────────────
  Widget _buildGroupRoute(NavigationState navigationState, ModuleRoute subRoute, {String basePath = '', int depth = 0}) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final currentPath = "$basePath${subRoute.path}".replaceAll('//', '/');
    final isSelected = _isSelected(navigationState, currentPath, isParentRoute: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuSectionHeader(
          title: subRoute.name,
          isSelected: isSelected,
        ),
        for (var childRoute in subRoute.module.routes)
          if (childRoute is ChildRoute && childRoute.isVisible)
            _MenuTile(
              label: childRoute.name,
              selected: _isSelected(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/')),
              isMobile: isMobile,
              indent: depth + 1,
              onTap: () {
                if (isMobile) _closeDrawer(context);
                context.customGoNamed(childRoute.routeName ?? childRoute.name);
              },
            )
          else if (childRoute is ModuleRoute && childRoute.isVisible)
            if (childRoute.module.routes.where((r) => r is ChildRoute && r.isVisible).length == 1)
              _MenuTile(
                label: (childRoute.module.routes.where((r) => r is ChildRoute && r.isVisible).first as ChildRoute).name,
                selected: _isSelected(navigationState, "$currentPath${childRoute.path}".replaceAll('//', '/')),
                isMobile: isMobile,
                indent: depth + 1,
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

/// Header del menu: logo + titolo + close button
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
          // Logo SVG
          Expanded(child: LogoWidget(height: isMobile ? 22 : 24, dark: false, color: theme.primary)),
          if (isMobile)
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: theme.borderColor.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: theme.secondaryText, size: 18)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card tenant compatta con avatar, nome e pulsante switch
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Sizes.padding * 0.6, vertical: isMobile ? 2 : 4),
        padding: EdgeInsets.symmetric(horizontal: Sizes.padding * 0.75, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: isMobile
              ? (isDark ? theme.secondaryBackground : Colors.white)
              : (isDark ? theme.secondaryBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          children: [
            CLAvatarWidget(name: authState.currentTenant!.name, medias: [], iconSize: isMobile ? 34 : 38),
            SizedBox(width: isMobile ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.currentTenant!.name,
                    style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (authState.currentTenant!.rawData['vatNumber'] != null) ...[
                    const SizedBox(height: 1),
                    Text('P.IVA ${authState.currentTenant!.rawData['vatNumber']}',
                        style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10)),
                  ],
                ],
              ),
            ),
            if (onSwitch != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onSwitch,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
                  child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedRepeat, color: theme.primary, size: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Voce di menu — stile coerente per tutte le label.
/// Active: suite color tint bg, weight 600, border-right 2.5px.
class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.label, required this.selected, required this.isMobile, required this.onTap, this.indent = 0});

  final String label;
  final bool selected;
  final bool isMobile;
  final VoidCallback onTap;
  final int indent;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final suiteColor = theme.primary;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            14,
            isMobile ? 11 : 10,
            14,
            isMobile ? 11 : 10,
          ),
          decoration: BoxDecoration(
            color: selected ? suiteColor.withValues(alpha: 0.10) : Colors.transparent,
            border: Border(
              right: BorderSide(
                color: selected ? suiteColor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: theme.bodyLabel.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? suiteColor : theme.secondaryText,
              fontSize: 13,
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

/// Section header per raggruppare le voci di menu.
/// Stile overline: icona piccola + titolo uppercase, nessuna interazione.
class _MenuSectionHeader extends StatelessWidget {
  const _MenuSectionHeader({required this.title, required this.isSelected});

  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final suiteColor = theme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 6),
      child: Text(
        title.toUpperCase(),
        style: theme.smallLabel.copyWith(
          fontWeight: FontWeight.w700,
          color: isSelected ? suiteColor : theme.secondaryText,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
