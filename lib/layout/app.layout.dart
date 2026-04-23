import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../providers/app_state.dart';
import '../utils/providers/module_theme.util.provider.dart';
import '../router/go_router_modular/go_router_modular_configure.dart';
import '../auth/cl_auth_state.dart';
import '../cl_theme.dart';
import '../widgets/gradient_background.widget.dart';
import 'constants/sizes.constant.dart';
import 'header.layout.dart';
import 'menu.layout.dart';
import 'notifications_panel.layout.dart';
import 'ai_chat_drawer.widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class CLAppLayout extends StatefulWidget {
  const CLAppLayout({
    super.key,
    required this.shellChild,
    this.shellRoutes = const [],
    this.moduleTabsEnabled = false,
    this.logoBuilder,
    this.menuExtraBuilder,
    this.menuFooterBuilder,
  });

  final Widget shellChild;
  final List<dynamic> shellRoutes;
  final bool moduleTabsEnabled;
  final Widget Function(BuildContext context)? logoBuilder;
  final Widget Function(BuildContext context)? menuExtraBuilder;
  final Widget Function(BuildContext context)? menuFooterBuilder;

  @override
  State<CLAppLayout> createState() => _CLAppLayoutState();
}

class _CLAppLayoutState extends State<CLAppLayout> {
  static const double _menuWidth = 268;
  static const double _aiPanelWidth = 360;
  static const double _desktopHeaderHeight = 60;
  static const double _mobileHeaderHeight = 56;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;

    return Consumer2<AppState, CLAuthState>(
      builder: (context, appState, authState, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: isMobile ? _buildMobileDrawer(context) : null,
          drawerEnableOpenDragGesture: isMobile,
          drawerEdgeDragWidth: isMobile ? 40 : 0,
          endDrawer: isMobile && appState.showAiButton ? const AiChatDrawer() : null,
          endDrawerEnableOpenDragGesture: false,
          body: GradientBackgroundWidget(
            showDecorativeCircles: false,
            child: _buildResponsiveLayout(context, appState),
          ),
        );
      },
    );
  }

  Widget _buildMenu() => CLMenuLayout(
        routes: widget.shellRoutes.cast(),
        logoBuilder: widget.logoBuilder,
        menuExtraBuilder: widget.menuExtraBuilder,
        menuFooterBuilder: widget.menuFooterBuilder,
      );

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: CLTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.zero, bottomRight: Radius.zero),
      ),
      child: SafeArea(child: _buildMenu()),
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
    final showAiPanel = appState.showAiButton && appState.aiChatOpen;

    return Row(
      children: [
        // Menu flat
        Container(
          width: _menuWidth,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            border: Border(right: BorderSide(color: theme.borderColor)),
          ),
          child: _buildMenu(),
        ),

        // Main area (header + content)
        Expanded(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  border: Border(bottom: BorderSide(color: theme.borderColor)),
                ),
                child: const HeaderLayout(
                  headerColor: Colors.transparent,
                  headerHeight: _desktopHeaderHeight,
                ),
              ),
              const SizedBox(height: Sizes.padding),
              Expanded(child: widget.shellChild),
            ],
          ),
        ),

        // AI Chat panel (glass bubble preservato)
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.centerRight,
          child: showAiPanel
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 0, bottom: Sizes.padding, right: Sizes.padding, top: Sizes.padding),
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: _aiPanelWidth,
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.primaryBackground.withValues(alpha: 0.85)
                                : theme.secondaryBackground.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                            border: Border.all(color: theme.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const AiChatPanel(),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const NotificationsPanel(),
      ],
    );
  }

  Widget _buildMobileLayout(AppState appState) {
    final theme = CLTheme.of(context);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            border: Border(bottom: BorderSide(color: theme.borderColor)),
          ),
          child: SafeArea(
            bottom: false,
            child: const HeaderLayout(
              headerColor: Colors.transparent,
              headerHeight: _mobileHeaderHeight,
            ),
          ),
        ),
        Expanded(child: widget.shellChild),
      ],
    );
  }
}

/// Retrocompatibilità: il vecchio nome [AppLayout] resta disponibile come alias.
typedef AppLayout = CLAppLayout;
