import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cl_components/providers/app_state.dart';
import 'package:cl_components/utils/providers/module_theme.util.provider.dart';
import 'package:cl_components/router/go_router_modular/go_router_modular_configure.dart';
import 'package:cl_components/router/go_router_modular/routes/i_modular_route.dart';
import 'package:cl_components/auth/cl_auth_state.dart';
import 'package:cl_components/cl_theme.dart';
import 'package:cl_components/widgets/gradient_background.widget.dart';
import 'package:cl_components/layout/constants/sizes.constant.dart';
import 'package:cl_components/layout/header.layout.dart';
import 'package:cl_components/layout/menu.layout.dart';
import 'package:cl_components/layout/notifications_panel.layout.dart';
import 'package:cl_components/layout/ai_chat_drawer.widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppLayout extends StatefulWidget {
  const AppLayout({super.key, required this.shellChild, required this.shellRoutes});

  final Widget shellChild;
  final List<ModularRoute> shellRoutes;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timeago.setLocaleMessages("it", timeago.ItMessages());
    // Ascolta i cambi di route per aggiornare la palette del modulo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouterModular.routerConfig.routerDelegate.addListener(_onRouteChange);
      _onRouteChange(); // Check iniziale
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Salva lo stato o ferma determinate azioni
    } else if (state == AppLifecycleState.resumed) {
      // Ripristina alcune azioni, se necessario
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;

    return Consumer2<AppState, CLAuthState>(
      builder: (context, appState, authState, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          // Drawer solo su mobile/tablet
          drawer: isMobile ? _buildMobileDrawer(context) : null,
          drawerEnableOpenDragGesture: isMobile,
          drawerEdgeDragWidth: isMobile ? 40 : 0,
          // EndDrawer per Assistente AI
          endDrawer: const AiChatDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: GradientBackgroundWidget(showDecorativeCircles: false, child: _buildResponsiveLayout(context, appState)),
        );
      },
    );
  }

  /// Drawer per mobile con overlay scuro e animazione fluida
  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: CLTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
      child: SafeArea(child: MenuLayout(routes: widget.shellRoutes)),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, AppState appState) {
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      return _buildDesktopLayout(appState);
    } else {
      return _buildMobileLayout(appState);
    }
  }

  Widget _buildDesktopLayout(AppState appState) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = Sizes.padding;
    return Padding(
      padding: EdgeInsets.only(left: p, top: p, bottom: 0),
      child: Row(
        children: [
          // Menu in "bolla" glass
          Padding(
            padding: const EdgeInsets.only(bottom: Sizes.padding),
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 268,
                    decoration: BoxDecoration(
                      color: isDark ? theme.primaryBackground.withValues(alpha: 0.85) : theme.secondaryBackground.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                      border: Border.all(color: theme.borderColor),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 12, offset: const Offset(0, 2))],
                    ),
                    child: MenuLayout(routes: widget.shellRoutes),
                  ),
                ),
              ),
            ),
          ),

          // Contenuto principale con header in "bolla"
          Expanded(
            child: Column(
              children: [
                // Header in "bolla" glass
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: p),
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? theme.primaryBackground.withValues(alpha: 0.85) : theme.secondaryBackground.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                            border: Border.all(color: theme.borderColor),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 12, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: HeaderLayout(headerColor: Colors.transparent, headerHeight: 60),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: p),
                // Contenuto pagina
                Expanded(child: widget.shellChild),
              ],
            ),
          ),
          // Notifications panel (se presente)
          const NotificationsPanel(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = CLTheme.of(context);
    final mobileHeaderHeight = 56.0;
    final p = Sizes.padding;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(height: p),
          // Header in "bolla" glass
          Padding(
            padding: EdgeInsets.symmetric(horizontal: p),
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.primaryBackground.withValues(alpha: 0.85) : theme.secondaryBackground.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.2),
                      border: Border.all(color: theme.borderColor.withValues(alpha: .5)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 1))],
                    ),
                    child: HeaderLayout(headerColor: Colors.transparent, headerHeight: mobileHeaderHeight),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: p),
          // Contenuto pagina in "bolla" glass
          Expanded(child: widget.shellChild),
        ],
      ),
    );
  }
}
