import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';
import 'cl_destination.dart';
import 'cl_shell_config.dart';
import 'cl_nav_list.widget.dart';
import 'cl_bottom_bar.widget.dart';

/// Shell adattivo a slot. Sceglie sidebar/drawer/bottom-bar per larghezza.
/// Trasparente alle logiche app: riceve dati + slot, non conosce router/AI/auth.
///
/// Nota: sul tier desktop (sidebar) NON crea uno `Scaffold`. Se `body`/`trailing`
/// usano SnackBar/`showModalBottomSheet`, l'app deve garantire uno `Scaffold`
/// antenato. Sui tier drawer/bottom-bar lo `Scaffold` è fornito dallo shell.
class CLAdaptiveShell extends StatefulWidget {
  const CLAdaptiveShell({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    required this.header,
    required this.body,
    this.navHeader,
    this.navFooter,
    this.trailing,
    this.endDrawer,
    this.config = const CLShellConfig(),
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;

  /// Contenuto top bar (logo/titolo + search + AI). Lo shell antepone l'hamburger
  /// su drawer/bottom-bar; NON includerlo qui.
  final Widget header;
  final Widget body;
  final Widget? navHeader;
  final Widget? navFooter;
  final Widget? trailing; // pannello AI desktop (full-height)
  final Widget? endDrawer; // AI drawer: solo tier drawer/bottom-bar; ignorato su desktop
  final CLShellConfig config;

  @override
  State<CLAdaptiveShell> createState() => _CLAdaptiveShellState();
}

class _CLAdaptiveShellState extends State<CLAdaptiveShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Selezione: chiude prima il drawer (se aperto su tablet/mobile), poi delega
  /// all'app. Su desktop `_scaffoldKey` non è montato → no-op.
  void _onSelect(CLDestination d) {
    final st = _scaffoldKey.currentState;
    if (st?.isDrawerOpen ?? false) st!.closeDrawer();
    widget.onSelect(d);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = resolveCLNavMode(constraints.maxWidth, widget.config);
        switch (mode) {
          case CLNavMode.sidebar:
            return _buildSidebar(context);
          case CLNavMode.drawer:
            return _buildScaffold(context, withBottomBar: false);
          case CLNavMode.bottomBar:
            return _buildScaffold(context, withBottomBar: true);
        }
      },
    );
  }

  Widget _navPanel(CLTheme theme, {required bool isCompact}) {
    return Container(
      color: theme.secondaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.navHeader != null) widget.navHeader!,
          if (widget.navHeader != null) Divider(height: 1, thickness: 1, color: theme.borderColor),
          Expanded(
            child: CLNavList(
              destinations: widget.destinations,
              selectedKey: widget.selectedKey,
              onSelect: _onSelect,
              isCompact: isCompact,
            ),
          ),
          if (widget.navFooter != null) Divider(height: 1, thickness: 1, color: theme.borderColor),
          if (widget.navFooter != null) widget.navFooter!,
        ],
      ),
    );
  }

  // ── Desktop ──────────────────────────────────────────────────────────────
  Widget _buildSidebar(BuildContext context) {
    final theme = CLTheme.of(context);
    return ColoredBox(
      color: theme.primaryBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: widget.config.sidebarWidth, child: _navPanel(theme, isCompact: false)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: theme.secondaryBackground,
                  padding: const EdgeInsets.all(Sizes.gapLg),
                  child: widget.header,
                ),
                Expanded(child: widget.body),
              ],
            ),
          ),
          if (widget.trailing != null) SizedBox(width: widget.config.trailingWidth, child: widget.trailing!),
        ],
      ),
    );
  }

  // ── Tablet (drawer) / Mobile (drawer + bottom bar) ─────────────────────────
  Widget _buildScaffold(BuildContext context, {required bool withBottomBar}) {
    final theme = CLTheme.of(context);
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.primaryBackground,
      drawer: Drawer(
        width: drawerWidth,
        backgroundColor: theme.secondaryBackground,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true)),
      ),
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      bottomNavigationBar: withBottomBar
          ? CLBottomBar(
              destinations: widget.destinations,
              selectedKey: widget.selectedKey,
              onSelect: _onSelect,
              maxItems: widget.config.maxBottomBarItems,
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: theme.secondaryBackground,
              padding: const EdgeInsets.all(Sizes.gapLg),
              child: Row(
                children: [
                  CLIconButton(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    iconData: Icons.menu,
                    backgroundColor: theme.muted,
                    iconColor: theme.primaryText,
                    size: theme.buttonHeightDefault,
                    iconSize: Sizes.iconSizeDefault,
                    tooltip: 'Menu',
                  ),
                  const SizedBox(width: Sizes.gapSm),
                  Expanded(child: widget.header),
                ],
              ),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }
}
