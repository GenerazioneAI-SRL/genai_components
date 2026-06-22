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
    this.bottomDestinations,
  });

  final List<CLDestination> destinations;

  /// Voci dedicate alla bottom bar (mobile). Se `null` usa [destinations]. Serve a
  /// curare un set diverso dal menu completo (es. solo le 4 scorciatoie chiave).
  final List<CLDestination>? bottomDestinations;
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

  /// Pannello reveal aperto nell'area contestuale mobile: filtri / ordina /
  /// altre azioni. `null` = righe di controlli. Cambio contenuto = snap (nessuna
  /// animazione di transizione).
  String? _panelId;

  /// Gruppo da espandere nel drawer quando viene aperto da un tap su gruppo del
  /// rail. Azzerato alla chiusura del drawer → l'apertura da avatar parte pulita
  /// (espande solo il gruppo della rotta corrente).
  String? _drawerExpandKey;

  /// Slot pubblicati dalle pagine discendenti (back/breadcrumbs/azioni/contesto).
  /// Lo shell ascolta questo controller e ricolloca i contenuti per breakpoint.
  /// Usa quello passato da [CLAdaptiveShell.slotsController] o ne crea uno proprio.
  ShellSlotsController? _ownController;
  ShellSlotsController get _slots => widget.slotsController ?? (_ownController ??= ShellSlotsController());

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

  Widget _navPanel(CLTheme theme, {required bool isCompact, String? forceExpandedKey}) {
    return Container(
      // Menu = L0 (primaryBackground) + bordo destro (delimita dal content page bg).
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(right: BorderSide(color: theme.borderColor)),
      ),
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
              forceExpandedKey: forceExpandedKey,
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
                      child: Builder(
                        builder: (context) {
                          // Titolo (pagina corrente = ultimo crumb).
                          final titleOnly = Text(
                            s.breadcrumbs.last.label,
                            style: theme.heading4,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                          // Tablet/mobile: sempre solo titolo.
                          if (mode != CLNavMode.sidebar) return titleOnly;
                          // Desktop ma barra stretta: solo titolo invece del path
                          // completo (libera spazio per il cluster di destra).
                          return LayoutBuilder(
                            builder: (ctx, c) => (c.maxWidth.isFinite && c.maxWidth < 360)
                                ? titleOnly
                                : _breadcrumbs(theme, s.breadcrumbs),
                          );
                        },
                      ),
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
        (c.onTap != null && !isLast) ? GestureDetector(onTap: c.onTap, child: label) : label,
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
  /// pagina, se pubblicati), in basso back + page actions + altre azioni. Se un
  /// reveal (filtri / altre azioni) è aperto, le righe collassano e al loro
  /// posto compare il pannello inline. Vuota → collassa.
  Widget _mobileContextArea(BuildContext context) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        // Cambio contenuto = snap istantaneo (nessuna transizione).
        if (!_hasContent(s)) return const SizedBox.shrink();
        final theme = CLTheme.of(context);
        return Container(
          decoration: BoxDecoration(
            // Chrome shell (toolbar contestuale mobile) = L0.
            color: theme.primaryBackground,
            border: Border(top: BorderSide(color: theme.borderColor)),
          ),
          padding: EdgeInsets.symmetric(horizontal: theme.gapLg, vertical: theme.gapMd),
          child: _areaContent(context, s, theme, _panelId),
        );
      },
    );
  }

  bool _hasContent(ShellSlots s) =>
      s.contextControls.isNotEmpty || s.back != null || s.pageActions.isNotEmpty || s.contextOverflow != null;

  /// Contenuto dell'area per un dato pannello: `null`/id-non-trovato → le due
  /// righe di controlli; altrimenti il pannello reveal corrispondente.
  Widget _areaContent(BuildContext context, ShellSlots s, CLTheme theme, String? id) {
    if (id != null) {
      final reveal = _revealById(s, id);
      if (reveal != null) return _panelView(context, theme, reveal);
    }
    return _rowsContent(context, s, theme);
  }

  /// Le due righe: [sort/ricerca/filtri] sopra, [back/azione/altre azioni] sotto.
  Widget _rowsContent(BuildContext context, ShellSlots s, CLTheme theme) {
    final hasUpper = s.contextControls.isNotEmpty;
    final hasLower = s.back != null || s.pageActions.isNotEmpty || s.contextOverflow != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasUpper) ...[
          Row(
            children: [
              for (var i = 0; i < s.contextControls.length; i++) ...[
                // Stesso gap della riga bassa così le due righe si allineano.
                if (i > 0) SizedBox(width: theme.gapLg),
                _contextControl(context, theme, s.contextControls[i]),
              ],
            ],
          ),
          if (hasLower) SizedBox(height: theme.gapMd),
        ],
        if (hasLower)
          Builder(
            builder: (context) {
              // Azione primaria (full-width) + secondarie come icone trailing.
              // Il primario riempie lo slot tra back e le icone; le altre azioni
              // (es. "Altre azioni" ⋮) restano compatte a destra. Senza primario →
              // FittedBox scaleDown di tutte (anti-overflow).
              ShellAction? primary;
              final others = <ShellAction>[];
              for (final a in s.pageActions) {
                if (primary == null && a.isPrimary && a.label != null) {
                  primary = a;
                } else {
                  others.add(a);
                }
              }
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
                    SizedBox(width: theme.gapLg),
                  ],
                  Expanded(
                    child: primary != null
                        ? CLButton.primary(
                            text: primary.label!,
                            icon: primary.icon,
                            iconAlignment: IconAlignment.start,
                            fullWidth: true,
                            borderRadius: theme.radiusPill,
                            onTap: primary.enabled ? (primary.onTap ?? () {}) : () {},
                            context: context,
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < s.pageActions.length; i++) ...[
                                  if (i > 0) SizedBox(width: theme.gapLg),
                                  _actionButton(context, theme, s.pageActions[i]),
                                ],
                              ],
                            ),
                          ),
                  ),
                  // Azioni secondarie a destra del primario (solo se c'è un primario).
                  if (primary != null)
                    for (final a in others) ...[
                      SizedBox(width: theme.gapLg),
                      _actionButton(context, theme, a),
                    ],
                  if (s.contextOverflow != null) ...[
                    SizedBox(width: theme.gapLg),
                    _revealButton(context, theme, s.contextOverflow!),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }

  /// Reveal con [id] tra contextControls + overflow, o `null` se non presente
  /// (es. dopo cambio rotta → l'area torna alle righe).
  ShellRevealControl? _revealById(ShellSlots s, String id) {
    for (final c in s.contextControls) {
      if (c.reveal?.id == id) return c.reveal;
    }
    if (s.contextOverflow?.id == id) return s.contextOverflow;
    return null;
  }

  /// Apre/chiude il pannello [id] (snap, nessuna transizione).
  void _togglePanel(String id) => setState(() => _panelId = _panelId == id ? null : id);

  void _closePanel() {
    if (_panelId == null) return;
    setState(() => _panelId = null);
  }

  /// Header (chiudi + titolo) + contenuto inline del reveal, con altezza max e
  /// scroll così un form lungo non spinge fuori schermo la bottom bar.
  Widget _panelView(BuildContext context, CLTheme theme, ShellRevealControl r) {
    void close() => _closePanel();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CLIconButton(
              onTap: close,
              iconData: Icons.arrow_back,
              backgroundColor: theme.controlFill,
              iconColor: theme.primaryText,
              size: theme.buttonHeightDefault,
              iconSize: Sizes.iconSizeDefault,
              tooltip: 'Chiudi',
            ),
            SizedBox(width: theme.gapMd),
            Expanded(child: Text(r.title, style: theme.heading5, overflow: TextOverflow.ellipsis)),
          ],
        ),
        SizedBox(height: theme.gapSm),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
          child: SingleChildScrollView(child: r.panelBuilder(context, close)),
        ),
      ],
    );
  }

  /// Bottone reveal (filtri / altre azioni): toggle del pannello inline.
  /// Evidenziato quando aperto; badge opzionale (es. filtri attivi).
  Widget _revealButton(BuildContext context, CLTheme theme, ShellRevealControl r) {
    final active = _panelId == r.id;
    final btn = CLIconButton(
      onTap: () => _togglePanel(r.id),
      iconData: r.icon,
      backgroundColor: active ? theme.primary.withValues(alpha: 0.12) : theme.controlFill,
      iconColor: active ? theme.primary : theme.primaryText,
      size: theme.buttonHeightDefault,
      iconSize: Sizes.iconSizeDefault,
      tooltip: r.tooltip ?? r.title,
    );
    if (r.badgeCount == null || r.badgeCount! <= 0) return btn;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        btn,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: theme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryBackground, width: 1.5),
            ),
            child: Center(
              child: Text(
                '${r.badgeCount}',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Rende un controllo contestuale generico (bottone / ricerca / custom / reveal).
  Widget _contextControl(BuildContext context, CLTheme theme, ShellContextControl c) {
    if (c.action != null) return _actionButton(context, theme, c.action!);
    if (c.reveal != null) return _revealButton(context, theme, c.reveal!);
    if (c.custom != null) return c.custom!.builder(context);
    final search = c.search!;
    return Expanded(
      child: SizedBox(
        height: theme.buttonHeightDefault,
        child: TextField(
          controller: search.controller,
          onChanged: search.onChanged,
          // Tipografia di sistema: input + hint usano i token del tema (Inter),
          // non il default Material.
          style: theme.bodyText.copyWith(color: theme.primaryText),
          cursorColor: theme.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: search.hint,
            hintStyle: theme.bodyText.copyWith(color: theme.secondaryText),
            prefixIcon: Icon(Icons.search, size: Sizes.iconSizeDefault, color: theme.secondaryText),
            filled: true,
            fillColor: theme.tertiaryBackground,
            contentPadding: EdgeInsets.symmetric(horizontal: theme.gapMd),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(theme.radiusPill),
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
      // Shell content = page bg (#F6F5F4); menu/header dipingono L0 sopra.
      color: theme.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: widget.config.sidebarWidth, child: _navPanel(theme, isCompact: false)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  // Header = L0 + bordo inferiore (delimita dal content page bg).
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    border: Border(bottom: BorderSide(color: theme.borderColor)),
                  ),
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
      // Shell content = page bg (#F6F5F4).
      backgroundColor: theme.background,
      // Drawer chiuso → azzera il gruppo forzato (apertura da avatar parte pulita).
      onDrawerChanged: (open) {
        if (!open && _drawerExpandKey != null) setState(() => _drawerExpandKey = null);
      },
      drawer: Drawer(
        width: drawerWidth,
        // Menu drawer = L0.
        backgroundColor: theme.primaryBackground,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true, forceExpandedKey: _drawerExpandKey)),
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
            // Tap su gruppo del rail → apri il drawer GIÀ espanso su quel gruppo.
            onOpenGroup: (d) {
              setState(() => _drawerExpandKey = d.key);
              _scaffoldKey.currentState?.openDrawer();
            },
            header: widget.railHeader,
            footer: widget.railFooter,
            width: widget.config.railWidth,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  // Header = L0 + bordo inferiore.
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    border: Border(bottom: BorderSide(color: theme.borderColor)),
                  ),
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
      // Shell content = page bg (#F6F5F4).
      backgroundColor: theme.background,
      drawer: Drawer(
        width: drawerWidth,
        // Menu drawer = L0.
        backgroundColor: theme.primaryBackground,
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
              destinations: widget.bottomDestinations ?? widget.destinations,
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
              // Header = L0 + bordo inferiore.
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                border: Border(bottom: BorderSide(color: theme.borderColor)),
              ),
              padding: const EdgeInsets.all(Sizes.gapLg),
              // Altezza pinnata ai controlli: senza questo il titolo (heading6,
              // line-height alto) gonfia la Row oltre buttonHeightDefault e
              // l'hit-box del hamburger (ElevatedButton centrato in una riga
              // sovradimensionata) si dimezza. Pin → hit == visibile.
              child: SizedBox(
                height: theme.buttonHeightDefault,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CLIconButton(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      iconData: Icons.menu,
                      backgroundColor: theme.controlFill,
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
            ),
            Expanded(child: _scopedBody()),
          ],
        ),
      ),
    );
  }
}
