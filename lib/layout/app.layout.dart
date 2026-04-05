import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cl_components/providers/app_state.dart';
import 'package:cl_components/utils/providers/module_theme.util.provider.dart';
import 'package:cl_components/router/go_router_modular/go_router_modular_configure.dart';
import 'package:cl_components/router/go_router_modular/routes/i_modular_route.dart';
import 'package:cl_components/router/go_router_modular/routes/module_route.dart';
import 'package:cl_components/auth/cl_auth_state.dart';
import 'package:cl_components/cl_theme.dart';
import 'package:cl_components/providers/theme_provider.dart';
import 'package:cl_components/widgets/logo.widget.dart';
import 'package:cl_components/widgets/avatar.widget.dart';
import 'package:cl_components/widgets/cl_popup_menu.widget.dart';
import 'package:cl_components/core_utils/extension.util.dart';
import 'package:cl_components/layout/constants/sizes.constant.dart';
import 'package:cl_components/layout/menu.layout.dart';
import 'package:cl_components/layout/notifications_panel.layout.dart';
import 'package:cl_components/layout/ai_chat_drawer.widget.dart';
import 'package:cl_components/utils/providers/navigation.util.provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    required this.shellChild,
    required this.shellRoutes,
    this.moduleTabsEnabled = false,
  });

  final Widget shellChild;
  final List<ModularRoute> shellRoutes;

  /// Se true: top bar scura con tab moduli, sidebar filtrata per modulo.
  /// Se false: sidebar con tutte le route, nessuna tab nella top bar.
  final bool moduleTabsEnabled;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timeago.setLocaleMessages("it", timeago.ItMessages());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouterModular.routerConfig.routerDelegate.addListener(_onRouteChange);
      _onRouteChange();
    });
  }

  void _onRouteChange() {
    if (!mounted) return;
    final location = GoRouterModular.routerConfig.routeInformationProvider.value.uri.toString();
    context.read<ModuleThemeProvider>().updateFromRoute(location);
  }

  @override
  void dispose() {
    GoRouterModular.routerConfig.routerDelegate.removeListener(_onRouteChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;

    return Consumer2<AppState, CLAuthState>(
      builder: (context, appState, authState, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: CLTheme.of(context).primaryBackground,
          drawer: isMobile ? _buildMobileDrawer(context) : null,
          drawerEnableOpenDragGesture: isMobile,
          drawerEdgeDragWidth: isMobile ? 40 : 0,
          //endDrawer: const AiChatDrawer(),
          //endDrawerEnableOpenDragGesture: false,
          body: isMobile ? _buildMobileLayout(appState) : _buildDesktopLayout(appState),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(AppState appState) {
    final theme = CLTheme.of(context);
    final moduleTheme = context.watch<ModuleThemeProvider>();
    final visibleModules = widget.shellRoutes.whereType<ModuleRoute>().where((r) => r.isVisible && r.showInTopBar).toList();
    final currentPath = GoRouterModular.routerConfig.routeInformationProvider.value.uri.toString();

    if (widget.moduleTabsEnabled) {
      // ── Layout con module tabs ──
      final showSidebar = moduleTheme.selectedModule != SkilleraModule.concierge;

      return Column(
        children: [
          _TopBar(
            modules: visibleModules,
            currentPath: currentPath,
            moduleTheme: moduleTheme,
          ),
          Expanded(
            child: Row(
              children: [
                ClipRect(
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    offset: showSidebar ? Offset.zero : const Offset(-1, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: showSidebar ? 1.0 : 0.0,
                      child: SizedBox(
                        width: showSidebar ? 220 : 0,
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            border: Border(right: BorderSide(color: theme.borderColor, width: 1)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: MenuLayout(routes: widget.shellRoutes, moduleTabsEnabled: true),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: widget.shellChild),
                const NotificationsPanel(),
              ],
            ),
          ),
        ],
      );
    }

    // ── Layout senza module tabs (sidebar sempre visibile, tutte le route) ──
    return Row(
      children: [
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            border: Border(right: BorderSide(color: theme.borderColor, width: 1)),
          ),
          child: MenuLayout(routes: widget.shellRoutes, moduleTabsEnabled: false),
        ),
        Expanded(child: widget.shellChild),
        const NotificationsPanel(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileLayout(AppState appState) {
    final authState = context.watch<CLAuthState>();
    final navigationState = context.watch<NavigationState>();
    final theme = CLTheme.of(context);

    return Column(
      children: [
        // ── Mobile header ──
        Container(
          color: theme.secondaryBackground,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: theme.primaryText, size: 20),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMobileTitle(navigationState, theme)),
                  _buildUserAvatar(authState),
                ],
              ),
            ),
          ),
        ),
        // ── Content ──
        Expanded(child: widget.shellChild),
      ],
    );
  }

  Widget _buildMobileTitle(NavigationState navigationState, CLTheme theme) {
    return ValueListenableBuilder<bool>(
      valueListenable: navigationState.headerTitleVisible,
      builder: (context, visible, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1.0 : 0.0,
          child: Text(
            navigationState.pageName,
            style: theme.heading6.copyWith(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(CLAuthState authState) {
    final fullName = '${authState.currentUserInfo?.firstName ?? ''} ${authState.currentUserInfo?.lastName ?? ''}'.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.borderRadius),
      onTap: () => _showMobileProfile(authState),
      child: SizedBox(height: 36, width: 36, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
    );
  }

  void _showMobileProfile(CLAuthState authState) {
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final email = authState.currentUserInfo?.email ?? '';
    final fullName = '$firstName $lastName'.trim();
    final t = CLTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(width: 36, height: 4, decoration: BoxDecoration(color: t.borderColor, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(Sizes.padding),
                  child: Row(
                    children: [
                      SizedBox(width: 48, height: 48, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullName, style: t.heading6.copyWith(fontWeight: FontWeight.w700)),
                            Text(email, style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sizes.padding, 0, Sizes.padding, Sizes.padding),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: t.danger, size: 18),
                      label: Text('Logout', style: TextStyle(color: t.danger)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: t.danger.withValues(alpha: 0.3))),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await authState.signOut();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: CLTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(child: MenuLayout(routes: widget.shellRoutes)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR — dark bar con logo + module tabs (TabController) + user profile
// ═══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatefulWidget {
  const _TopBar({
    required this.modules,
    required this.currentPath,
    required this.moduleTheme,
  });

  final List<ModuleRoute> modules;
  final String currentPath;
  final ModuleThemeProvider moduleTheme;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.modules.length, vsync: this, animationDuration: const Duration(milliseconds: 200));
    _tabController.index = _currentTabIndex();
    _tabController.addListener(_onTabTapped);
  }

  @override
  void didUpdateWidget(covariant _TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna l'indice senza triggerare il listener
    final desired = _currentTabIndex();
    if (_tabController.length != widget.modules.length) {
      _tabController.removeListener(_onTabTapped);
      _tabController.dispose();
      _tabController =
          TabController(length: widget.modules.length, vsync: this, initialIndex: desired, animationDuration: const Duration(milliseconds: 200));
      _tabController.addListener(_onTabTapped);
    } else if (_tabController.index != desired) {
      _tabController.removeListener(_onTabTapped);
      _tabController.index = desired;
      _tabController.addListener(_onTabTapped);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabTapped);
    _tabController.dispose();
    super.dispose();
  }

  int _currentTabIndex() {
    final selected = widget.moduleTheme.selectedModule;
    for (int i = 0; i < widget.modules.length; i++) {
      if (_moduleEnumFromPath(widget.modules[i].path) == selected) return i;
    }
    return 0;
  }

  void _onTabTapped() {
    if (_tabController.indexIsChanging) return;
    final mod = widget.modules[_tabController.index];
    final modEnum = _moduleEnumFromPath(mod.path);
    widget.moduleTheme.selectModule(modEnum);
    if (mod.navigateOnTabTap) {
      context.go(mod.path);
    }
  }

  /// Restituisce il colore primario light per un modulo dal suo path.
  Color _moduleColorFromPath(String path) {
    final mod = _moduleEnumFromPath(path);
    return ModuleThemeProvider.palettes[mod]?.lightPrimary ?? const Color(0xFF0C8EC7);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<CLAuthState>();
    final themeProvider = context.watch<ThemeProvider>();
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    final isDarkNow = themeProvider.isDarkMode;
    final selectedIndex = _currentTabIndex();

    return Container(
      height: 56,
      color: const Color(0xFF2E2E38),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Logo ──
          LogoWidget(height: 22, dark: true, color: const Color(0xFF0C8EC7)),
          const SizedBox(width: 28),

          // ── Module Tabs ──
          Theme(
            data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
            child: TabBar(
              controller: _tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: _moduleColorFromPath(widget.modules[selectedIndex].path),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(2),
                insets: const EdgeInsets.symmetric(horizontal: 10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF8B8FA0),
              labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 13),
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: List.generate(widget.modules.length, (i) {
                final mod = widget.modules[i];
                return Tab(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(mod.name),
                  ),
                );
              }),
            ),
          ),

          const Spacer(),

          // ── Tenant ──
          if (authState.currentTenant != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.customGoNamed('La mia azienda'),
                    child: Container(
                      height: 32,
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(icon: HugeIcons.strokeRoundedCorporate, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            authState.currentTenant!.name,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (authState.tenantList.length > 1)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => authState.setCurrentTenant(null),
                      child: Container(
                        height: 32,
                        width: 32,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedRepeat, size: 13, color: Color(0xFF94A3B8))),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 4),
              ],
            ),

          // ── Theme toggle ──
          Tooltip(
            message: isDarkNow ? 'Modalità chiara' : 'Modalità scura',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async => await themeProvider.toggleTheme(),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: isDarkNow ? HugeIcons.strokeRoundedSun03 : HugeIcons.strokeRoundedMoon02,
                      color: const Color(0xFF94A3B8),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── User Avatar + Menu ──
          CLPopupMenu(
            title: 'Account',
            alignment: CLPopupAlignment.end,
            minWidth: 220,
            maxWidth: 260,
            items: [
              CLPopupMenuItem(
                content: Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: const Color(0xFFEF4444), size: Sizes.medium),
                    const SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 13)),
                  ],
                ),
                onTap: () async => await authState.signOut(),
              ),
            ],
            builder: (context, open) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: open,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 28, width: 28, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
                      const SizedBox(width: 8),
                      Text(firstName, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static SkilleraModule _moduleEnumFromPath(String path) {
    if (path.startsWith('/skill-hr')) return SkilleraModule.hr;
    if (path.startsWith('/skill-cert')) return SkilleraModule.cert;
    if (path.startsWith('/skill-lms')) return SkilleraModule.lms;
    if (path.startsWith('/skill-id')) return SkilleraModule.id;
    return SkilleraModule.concierge;
  }
}
