import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';
import 'package:genai_components/widgets/buttons/cl_button.widget.dart';
import 'cl_destination.dart';
import 'cl_shell_config.dart';
import 'cl_shell_slots.dart';
import 'cl_nav_list.widget.dart';
import 'cl_nav_rail.widget.dart';
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
    this.slotsController,
    this.railHeader,
    this.railFooter,
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

  /// Controller dei slot. Se `null`, lo shell ne crea uno proprio. Passarlo
  /// dall'esterno permette all'app di pubblicare il canale nav (back/breadcrumbs)
  /// senza avvolgere il `body` (evita reparenting di widget con GlobalKey).
  final ShellSlotsController? slotsController;

  /// Slot in cima/in fondo alla rail (tier tablet), icon-only. Es. icona tenant
  /// in alto, help + avatar utente in basso. Ignorati su sidebar/bottom-bar.
  final Widget? railHeader;
  final Widget? railFooter;

  @override
  State<CLAdaptiveShell> createState() => _CLAdaptiveShellState();
}

class _CLAdaptiveShellState extends State<CLAdaptiveShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Slot pubblicati dalle pagine discendenti (back/breadcrumbs/azioni/contesto).
  /// Lo shell ascolta questo controller e ricolloca i contenuti per breakpoint.
  /// Usa quello passato da [CLAdaptiveShell.slotsController] o ne crea uno proprio.
  ShellSlotsController? _ownController;
  ShellSlotsController get _slots =>
      widget.slotsController ?? (_ownController ??= ShellSlotsController());

  @override
  void dispose() {
    _ownController?.dispose();
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
          case CLNavMode.rail:
            return _buildRail(context);
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
  Widget _composedHeader(BuildContext context, {required CLNavMode mode}) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        final theme = CLTheme.of(context);
        // Mobile: back + page actions vivono nell'area contestuale in basso, non
        // nell'header (qui solo titolo + G3).
        final bottomBar = mode == CLNavMode.bottomBar;

        // [back] · [breadcrumbs (desktop) / titolo (tablet+mobile)] · [pageActions] · [G3].
        final hasNav = s.back != null || s.breadcrumbs.isNotEmpty;
        if (!hasNav && s.pageActions.isEmpty) return widget.header;
        // Due zone Expanded simmetriche → pageActions centrate. Sinistra: back +
        // breadcrumbs (allineati a sx). Destra: G3 (ricerca+AI) allineato a destra
        // (niente gap residuo in coda).
        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (s.back != null && !bottomBar) ...[
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
                  if (s.breadcrumbs.isNotEmpty)
                    Flexible(
                      child: mode != CLNavMode.sidebar
                          // Tablet/mobile: solo il titolo (pagina corrente), niente breadcrumbs.
                          ? Text(
                              s.breadcrumbs.last.label,
                              style: theme.heading6.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : _breadcrumbs(theme, s.breadcrumbs),
                    ),
                ],
              ),
            ),
            if (!bottomBar)
              for (var i = 0; i < s.pageActions.length; i++) ...[
                if (i > 0) SizedBox(width: theme.gapMd),
                _actionButton(context, theme, s.pageActions[i]),
              ],
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: widget.header),
            ),
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
    if (a.builder != null) return a.builder!(context);
    final onTap = a.enabled ? (a.onTap ?? () {}) : () {};
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
      iconData: a.icon ?? Icons.circle,
      backgroundColor: theme.controlFill,
      iconColor: theme.primaryText,
      size: theme.buttonHeightDefault,
      iconSize: Sizes.iconSizeDefault,
      tooltip: a.tooltip ?? a.label,
    );
  }

  // ── Area contestuale mobile (sopra la bottom bar) ──────────────────────────
  /// Due righe: in alto i controlli contestuali (sort/ricerca/filtri della
  /// pagina, se pubblicati), in basso back + page actions. Vuota → collassa.
  Widget _mobileContextArea(BuildContext context) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        final hasUpper = s.contextControls.isNotEmpty;
        final hasLower = s.back != null || s.pageActions.isNotEmpty;
        if (!hasUpper && !hasLower) return const SizedBox.shrink();
        final theme = CLTheme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            border: Border(top: BorderSide(color: theme.borderColor)),
          ),
          padding: EdgeInsets.symmetric(horizontal: theme.gapLg, vertical: theme.gapSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasUpper) ...[
                Row(
                  children: [
                    for (var i = 0; i < s.contextControls.length; i++) ...[
                      if (i > 0) SizedBox(width: theme.gapSm),
                      _contextControl(context, theme, s.contextControls[i]),
                    ],
                  ],
                ),
                if (hasLower) SizedBox(height: theme.gapSm),
              ],
              if (hasLower)
                Row(
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < s.pageActions.length; i++) ...[
                            if (i > 0) SizedBox(width: theme.gapMd),
                            _actionButton(context, theme, s.pageActions[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  /// Rende un controllo contestuale generico (bottone / ricerca / custom).
  Widget _contextControl(BuildContext context, CLTheme theme, ShellContextControl c) {
    if (c.action != null) return _actionButton(context, theme, c.action!);
    if (c.custom != null) return c.custom!.builder(context);
    final search = c.search!;
    return Expanded(
      child: SizedBox(
        height: theme.buttonHeightDefault,
        child: TextField(
          controller: search.controller,
          onChanged: search.onChanged,
          decoration: InputDecoration(
            isDense: true,
            hintText: search.hint,
            prefixIcon: Icon(Icons.search, size: Sizes.iconSizeDefault, color: theme.secondaryText),
            filled: true,
            fillColor: theme.muted,
            contentPadding: EdgeInsets.symmetric(horizontal: theme.gapMd),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusControl),
              borderSide: BorderSide.none,
            ),
          ),
        ),
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
                  child: _composedHeader(context, mode: CLNavMode.sidebar),
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

  // ── Tablet (rail icon-only) ────────────────────────────────────────────────
  /// Rail persistente a sinistra + header (senza hamburger) + body. Il drawer
  /// resta come overlay: aprendolo da una voce di gruppo della rail mostra il
  /// menu completo.
  Widget _buildRail(BuildContext context) {
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CLNavRail(
            destinations: widget.destinations,
            selectedKey: widget.selectedKey,
            onSelect: _onSelect,
            onOpenGroup: (_) => _scaffoldKey.currentState?.openDrawer(),
            header: widget.railHeader,
            footer: widget.railFooter,
            width: widget.config.railWidth,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: theme.secondaryBackground,
                  padding: const EdgeInsets.all(Sizes.gapLg),
                  child: _composedHeader(context, mode: CLNavMode.rail),
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

  // ── Mobile (drawer + bottom bar) ───────────────────────────────────────────
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Riga(e) contestuali sopra la tab bar: azioni/back (+ controlli tabella).
          _mobileContextArea(context),
          if (withBottomBar)
            CLBottomBar(
              destinations: widget.destinations,
              selectedKey: widget.selectedKey,
              onSelect: _onSelect,
              onOpenGroup: (_) => _scaffoldKey.currentState?.openDrawer(),
              onOverflow: () => _scaffoldKey.currentState?.openDrawer(),
              maxItems: widget.config.maxBottomBarItems,
            ),
        ],
      ),
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
                  Expanded(child: _composedHeader(context, mode: CLNavMode.bottomBar)),
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
