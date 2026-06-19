import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';
import 'package:genai_components/widgets/buttons/cl_button.widget.dart';
import 'cl_destination.dart';
import 'cl_shell_config.dart';
import 'cl_shell_slots.dart';
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

  /// Slot pubblicati dalle pagine discendenti (back/breadcrumbs/azioni/contesto).
  /// Lo shell ascolta questo controller e ricolloca i contenuti per breakpoint.
  final ShellSlotsController _slots = ShellSlotsController();

  @override
  void dispose() {
    _slots.dispose();
    super.dispose();
  }

  /// Rende il `body` accessibile alle pagine per pubblicare i loro slot.
  Widget _scopedBody() => CLShellScope(controller: _slots, child: widget.body);

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

  // ── Header dinamico ────────────────────────────────────────────────────────
  /// Compone l'header per breakpoint a partire dai slot pubblicati dalla pagina:
  /// `[back + breadcrumbs] · [header app: titolo/ricerca/AI] · [page actions]`.
  /// Se la pagina non pubblica nulla → ritorna `widget.header` invariato
  /// (back-compat totale: i consumer che non usano gli slot non cambiano).
  Widget _composedHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        if (s.back == null && s.breadcrumbs.isEmpty && s.pageActions.isEmpty) {
          return widget.header;
        }
        final theme = CLTheme.of(context);
        return Row(
          children: [
            if (s.back != null) ...[
              CLIconButton(
                onTap: s.back!.onTap,
                iconData: Icons.arrow_back,
                backgroundColor: theme.controlFill,
                iconColor: theme.primaryText,
                size: theme.buttonHeightDefault,
                iconSize: Sizes.iconSizeDefault,
                tooltip: s.back!.tooltip ?? 'Indietro',
              ),
              SizedBox(width: theme.gapMd),
            ],
            if (s.breadcrumbs.isNotEmpty) ...[
              Flexible(child: _breadcrumbs(theme, s.breadcrumbs)),
              SizedBox(width: theme.gapMd),
            ],
            Expanded(child: widget.header),
            for (final a in s.pageActions) ...[
              SizedBox(width: theme.gapMd),
              _actionButton(context, theme, a),
            ],
          ],
        );
      },
    );
  }

  Widget _breadcrumbs(CLTheme theme, List<ShellCrumb> crumbs) {
    final children = <Widget>[];
    for (var i = 0; i < crumbs.length; i++) {
      final c = crumbs[i];
      final isLast = i == crumbs.length - 1;
      final label = Text(
        c.label,
        overflow: TextOverflow.ellipsis,
        style: theme.bodyText.copyWith(
          color: isLast ? theme.primaryText : theme.secondaryText,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
        ),
      );
      children.add(
        (c.onTap != null && !isLast)
            ? GestureDetector(onTap: c.onTap, child: label)
            : label,
      );
      if (!isLast) {
        children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.gapSm),
          child: Icon(Icons.chevron_right, size: Sizes.iconSizeDefault, color: theme.secondaryText),
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _actionButton(BuildContext context, CLTheme theme, ShellAction a) {
    final onTap = a.enabled ? a.onTap : () {};
    if (a.isPrimary && a.label != null) {
      return CLButton(
        text: a.label!,
        iconData: a.icon,
        iconAlignment: IconAlignment.start,
        onTap: onTap,
        context: context,
      );
    }
    return CLIconButton(
      onTap: onTap,
      iconData: a.icon,
      backgroundColor: theme.controlFill,
      iconColor: theme.primaryText,
      size: theme.buttonHeightDefault,
      iconSize: Sizes.iconSizeDefault,
      tooltip: a.tooltip ?? a.label,
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
                  child: _composedHeader(context),
                ),
                Expanded(child: _scopedBody()),
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
                  const SizedBox(width: Sizes.gapLg),
                  Expanded(child: _composedHeader(context)),
                ],
              ),
            ),
            Expanded(child: _scopedBody()),
          ],
        ),
      ),
    );
  }
}
