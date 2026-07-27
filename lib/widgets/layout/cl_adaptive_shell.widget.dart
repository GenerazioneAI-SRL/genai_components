import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'cl_shell_tokens.dart';
import 'cl_shell_sizes.dart';
import 'cl_destination.dart';
import 'cl_shell_config.dart';
import 'cl_shell_slots.dart';
import 'cl_nav_tile.widget.dart';
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
    this.headerLeading,
    this.navHeader,
    this.navSecondary,
    this.navFooter,
    this.trailing,
    this.endDrawer,
    this.config = const CLShellConfig(),
    this.slotsController,
    this.railHeader,
    this.railSecondary,
    this.railFooter,
    this.bottomDestinations,
    this.bottomBarItems,
    this.bottomBarHomeLogo,
  });

  final List<CLDestination> destinations;

  /// Voci dedicate alla bottom bar (mobile). Se `null` usa [destinations]. Serve a
  /// curare un set diverso dal menu completo (es. solo le 4 scorciatoie chiave).
  final List<CLDestination>? bottomDestinations;

  /// Voci FISSE custom della bottom bar (mobile). Se non null sostituisce la barra
  /// nav (destination-driven) con queste voci nell'ordine dato — es. [menu,
  /// dashboard, AI, profilo, ricerca]. L'hamburger nell'header viene nascosto
  /// (il menu vive nella barra). Usa `slotsController.openMenu()/openAi()` per le
  /// azioni che richiedono lo Scaffold interno.
  final List<CLBottomBarItem>? bottomBarItems;

  /// Logo mostrato nell'header MOBILE (bottom-bar) quando la pagina non ha
  /// breadcrumb né back (es. home). Sostituisce il titolo vuoto. `null` = niente.
  final Widget? bottomBarHomeLogo;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;

  /// Contenuto top bar (logo/titolo + search + AI). Lo shell antepone l'hamburger
  /// su drawer/bottom-bar; NON includerlo qui.
  final Widget header;

  /// Logo dell'app, mostrato in cima al menu (nav panel) su tutti i breakpoint —
  /// sidebar desktop e drawer tablet/mobile. Mai nell'header. `null` = assente.
  final Widget? headerLeading;
  final Widget body;
  final Widget? navHeader;

  /// Voci secondarie del menu (es. "Gestione cliente") sotto l'azienda. Con
  /// `config.resizableNavHeader` diventano la parte SCROLLABILE del pannello
  /// header (azienda pinnata sopra, queste scrollano fino al divider). Senza
  /// resize, impilate sotto navHeader nella barra frosted.
  final Widget? navSecondary;
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

  /// Voci secondarie ICON-ONLY per il tier collassato (rail/tablet): con
  /// `resizableNavHeader` diventano la parte scrollabile della bolla header
  /// (icone cliente sotto l'azienda, con drag sul bordo). Analogo rail di
  /// [navSecondary]. Se null, in rail la bolla non si estende con le voci cliente.
  final Widget? railSecondary;
  final Widget? railFooter;

  @override
  State<CLAdaptiveShell> createState() => _CLAdaptiveShellState();
}

class _CLAdaptiveShellState extends State<CLAdaptiveShell> {
  static const double _kFrostSigma = 18.0;

  /// Vetro smerigliato. Su **web** il `BackdropFilter` rompe l'input dei
  /// `TextField` (bug noto di Flutter web: il layer blur occlude l'overlay
  /// nascosto dell'input → focus ok ma tasti/paste non arrivano, senza errori).
  /// Quindi su web niente blur: resta lo sfondo traslucido del figlio
  /// (`DecoratedBox`). Su mobile/desktop native il blur è pieno.
  static Widget _frostBlur({required Widget child}) => kIsWeb
      ? child
      : BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _kFrostSigma, sigmaY: _kFrostSigma),
          child: child,
        );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Pannello reveal aperto nell'area contestuale mobile: filtri / ordina /
  /// altre azioni. `null` = righe di controlli. Cambio contenuto = snap (nessuna
  /// animazione di transizione).
  String? _panelId;

  /// Gruppo da espandere nel drawer quando viene aperto da un tap su gruppo del
  /// rail. Azzerato alla chiusura del drawer → l'apertura da avatar parte pulita
  /// (espande solo il gruppo della rotta corrente).
  String? _drawerExpandKey;

  /// Override manuale collapse della sidebar (bubble desktop/tablet). `null` =
  /// automatico: esteso su desktop, rail su tablet. Il pulsante nell'header lo
  /// setta; al cambio di breakpoint torna `null` (→ auto rail sotto desktop).
  bool? _collapsed;
  CLNavMode? _prevMode;

  /// Frazione (0..1) dell'altezza disponibile occupata dall'header nav quando
  /// `config.resizableNavHeader` è attivo. Regolata dalla maniglia sul bordo
  /// basso dell'header; clamp [0.15, 0.85]. Stato di sessione (no persistenza).
  double _navHeaderFraction = 0.4;

  /// Altezze intrinseche misurate: blocco azienda (pinnato) e voci cliente
  /// (scrollabili). Servono al cap dell'header resizable (min = azienda+1 voce,
  /// max = azienda+cliente) → azienda sempre visibile, niente vuoto sotto l'ultima.
  double _navCompanyH = 0;
  double _navClientH = 0;

  /// Ultimo `trailing` non-null: ritenuto durante l'animazione di CHIUSURA della
  /// bolla assistente (quando `widget.trailing` torna null) così il contenuto
  /// resta montato mentre la bolla collassa. Azzerato a collasso completo.
  Widget? _retainedTrailing;

  /// Collapse effettivo per il [mode] corrente (override o automatico).
  bool _isCollapsed(CLNavMode mode) => _collapsed ?? (mode != CLNavMode.sidebar);

  /// Altezze misurate delle barre frosted (header/footer) del menu bolla: servono
  /// a riservare il padding della lista così le voci scorrono SOTTO il vetro
  /// smerigliato senza finire coperte in modo permanente.
  double _menuHeaderH = 0;
  double _menuFooterH = 0;

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
  /// Scrollbar nascosta in tutto il contenuto shell (scroll via drag/wheel) →
  /// coerente con la rail; le pagine non mostrano scrollbar.
  Widget _scopedBody() => Builder(
    builder: (context) => ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CLShellScope(controller: _slots, child: widget.body),
    ),
  );

  /// Selezione: chiude prima il drawer (se aperto su tablet/mobile), poi delega
  /// all'app. Su desktop `_scaffoldKey` non è montato → no-op.
  void _onSelect(CLDestination d) {
    final st = _scaffoldKey.currentState;
    if (st?.isDrawerOpen ?? false) st!.closeDrawer();
    widget.onSelect(d);
  }

  @override
  Widget build(BuildContext context) {
    // Collega le azioni shell (menu/AI) al controller: le voci custom della
    // bottom bar le invocano senza accedere al contesto interno dello shell.
    _slots.bindShellActions(
      openMenu: () => _scaffoldKey.currentState?.openDrawer(),
      openAi: () => _scaffoldKey.currentState?.openEndDrawer(),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = resolveCLNavMode(constraints.maxWidth, widget.config);
        // Al cambio di breakpoint: azzera l'override → torna automatico (rail
        // sotto desktop, esteso su desktop).
        if (_prevMode != null && _prevMode != mode && _collapsed != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _collapsed = null);
          });
        }
        _prevMode = mode;
        // Bubble: desktop E tablet condividono lo stesso layout a bolle; il tier
        // decide solo il collapse iniziale (rail su tablet).
        if (widget.config.bubbleBody && mode != CLNavMode.bottomBar) {
          return _bubbleDesktop(context, CLShellTokens.of(context), mode: mode);
        }
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

  Widget _navPanel(
    CLShellTokens theme, {
    required bool isCompact,
    String? forceExpandedKey,
    bool frosted = false,
    bool showRightBorder = true,
    bool collapsed = false,
  }) {
    // Blocco AZIENDA (logo/headerLeading + navHeader): in resizable è la parte
    // FISSA in cima al pannello header (non scrolla).
    final Widget? companyContent = (widget.headerLeading != null || widget.navHeader != null)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.headerLeading != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(CLShellSizes.gapLg, CLShellSizes.gapLg, CLShellSizes.gapLg, 0),
                  child: Align(alignment: Alignment.centerLeft, child: widget.headerLeading!),
                ),
              if (widget.navHeader != null) widget.navHeader!,
            ],
          )
        : null;

    // Separator azienda↔voci nello stack ESPANSO non-resizable.
    final bool expandedHasSep = companyContent != null && widget.navSecondary != null;

    // Header espanso (non collassato) = azienda + separator + navSecondary
    // IMPILATI. È il contenuto della barra frosted floating nel ramo non-resizable;
    // nel ramo resizable azienda+separator restano fissi e navSecondary scrolla.
    final Widget? expandedHeader = (companyContent != null || widget.navSecondary != null)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (companyContent != null) companyContent,
              if (expandedHasSep) _navHeaderSeparator(theme),
              // Clearance Lg sotto l'ultima voce cliente: nel ramo non-resizable
              // (drawer mobile) l'header non scrolla → senza questo la pill finale
              // tocca il bordo basso della bolla frosted. Nel ramo resizable lo dà
              // il padding del SingleChildScrollView.
              if (widget.navSecondary != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: CLShellSizes.gapLg),
                  child: widget.navSecondary!,
                ),
            ],
          )
        : null;

    final Widget? headerContent = collapsed ? widget.railHeader : expandedHeader;
    final Widget? footerContent = collapsed ? widget.railFooter : widget.navFooter;
    final hasHeader = headerContent != null;
    final hasFooter = footerContent != null;

    // Zona FISSA + parte SCROLL del pannello resizable, adattate al tier:
    // - espanso (sidebar): azienda (companyContent) + voci cliente (navSecondary).
    // - collassato (rail/tablet): azienda icone (railHeader) + voci cliente icone
    //   (railSecondary). La bolla bianca si allunga con le icone cliente + drag.
    final Widget? pinnedCompany = collapsed ? widget.railHeader : companyContent;
    final Widget? scrollSecondary = collapsed ? widget.railSecondary : widget.navSecondary;
    final bool hasSep = pinnedCompany != null && scrollSecondary != null;

    // Resize attivo (sidebar espansa, rail/tablet E drawer mobile) quando c'è la
    // parte scrollabile: la bolla azienda si comporta uguale su tutti i tier —
    // azienda pinnata + voci cliente scrollabili + maniglia di drag sul bordo.
    final resizableHeader = widget.config.resizableNavHeader && scrollSecondary != null;

    return Container(
      // Menu = L0 (primaryBackground) + bordo destro. In card (bolla desktop): bg/
      // bordo li dà la card esterna → qui trasparente.
      decoration: frosted
          ? null
          : BoxDecoration(
              // Drawer mobile (compact): superficie elevata = secondaryBackground.
              // Menu desktop (rail/sidebar): L0 = primaryBackground + bordo destro.
              color: isCompact ? theme.secondaryBackground : theme.primaryBackground,
              border: showRightBorder ? Border(right: BorderSide(color: theme.borderColor)) : null,
            ),
      // Stack: la lista riempie e scorre SOTTO le barre frosted di header/footer
      // (vetro smerigliato traslucido come l'header shell, niente hairline). Il
      // padding top/bottom della lista = altezza misurata delle barre → prima/ultima
      // voce restano raggiungibili.
      //
      // Drawer mobile (compact): inset Lg su tutti i lati → bolle frosted + lista
      // non toccano i bordi del drawer. Desktop/rail (card esterna già a gapSm dal
      // canvas): nessun inset qui.
      child: Padding(
        padding: isCompact ? const EdgeInsets.all(CLShellSizes.gapLg) : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer mobile: bottone ghost "chiudi" sopra la bolla azienda.
            if (isCompact)
              Align(
                alignment: Alignment.centerRight,
                child: ShadIconButton.ghost(
                  onPressed: () => _scaffoldKey.currentState?.closeDrawer(),
                  iconSize: CLShellSizes.iconSizeDefault,
                  icon: const Icon(LucideIcons.x),
                ),
              ),
            if (isCompact) const SizedBox(height: CLShellSizes.gapLg),
            Expanded(
              child: Stack(
                children: [
                  if (resizableHeader)
                    // Overlay resizable: la lista scorre SOTTO l'header frosted (frost
                    // preservato: il vetro sfoca la lista dietro). L'header ha altezza =
                    // frazione regolabile via maniglia custom sul suo bordo basso. Nessun
                    // divider Shad → niente hairline staccata.
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final avail = c.maxHeight;
                          // Cap: header non oltre azienda+cliente misurati (niente vuoto sotto
                          // l'ultima voce). Min: azienda + ~1 voce (azienda sempre visibile,
                          // no overflow). Tra i due, il cliente scrolla nell'area residua.
                          // _navCompanyH = zona FISSA (azienda + separator, misurata insieme).
                          // Cap max = fissa + voci + clearance (niente vuoto). Min = fissa +
                          // ~1 voce (fissa sempre visibile). +gapLg = clearance bottom scroll.
                          final contentTotal = (_navCompanyH + _navClientH) > 0
                              ? _navCompanyH + _navClientH + CLShellSizes.gapLg
                              : avail;
                          final minFrac = ((_navCompanyH + CLShellSizes.buttonHeightCompact) / avail).clamp(0.0, 0.85);
                          final maxFrac = (contentTotal / avail).clamp(minFrac, 0.85);
                          final frac = _navHeaderFraction.clamp(minFrac, maxFrac);
                          final headerH = frac * avail;
                          return Stack(
                            children: [
                              Positioned.fill(
                                // Clip col raggio delle bolle frosted (header/footer): la lista
                                // scorre SOTTO il vetro con angoli arrotondati; senza questo, in
                                // overscroll una voce (es. selezionata) spunta nei triangolini
                                // d'angolo dove la bolla è trasparente fuori dal raggio.
                                child: ClipRRect(
                                  // Deve combaciare col raggio delle bolle frosted del menu.
                                  borderRadius: BorderRadius.circular(CLShellSizes.radiusBubble),
                                  child: CLNavList(
                                    destinations: widget.destinations,
                                    selectedKey: widget.selectedKey,
                                    onSelect: _onSelect,
                                    isCompact: false,
                                    collapsed: collapsed,
                                    padding: EdgeInsets.only(
                                      // Lg ESATTO tra bordo basso header e pill prima voce: la
                                      // voce ha già padding vertical gapXs (cl_nav_list) → lo
                                      // sottraggo per non sommare (gapLg + gapXs).
                                      top: headerH + CLShellSizes.gapLg - CLShellSizes.gapXs,
                                      bottom: hasFooter ? _menuFooterH : CLShellSizes.gapSm,
                                    ),
                                  ),
                                ),
                              ),
                              // Header frosted ad altezza fissa: AZIENDA pinnata in cima +
                              // voci CLIENTE (navSecondary) scrollabili nell'area residua fino
                              // al divider. Il vetro sfoca la lista che scorre sotto.
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: headerH,
                                child: _frostedMenuBar(
                                  theme,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Zona FISSA: azienda + separator (misurata insieme).
                                      if (pinnedCompany != null)
                                        _MeasureSize(
                                          onChange: (s) {
                                            if (s.height != _navCompanyH) setState(() => _navCompanyH = s.height);
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [pinnedCompany, if (hasSep) _navHeaderSeparator(theme)],
                                          ),
                                        ),
                                      Expanded(
                                        // Gate: sopprime i tooltip delle voci cliente durante
                                        // lo scroll (stesso fix della lista principale).
                                        child: CLNavScrollTooltipGate(
                                          child: SingleChildScrollView(
                                            // Stessa physics della lista principale (CLNavList):
                                            // bounce coerente, niente "scatto" clamping al limite.
                                            physics: const BouncingScrollPhysics(),
                                            // Clearance bottom → l'ultima voce si ferma sopra il
                                            // divider, che resta visibile mentre scorri.
                                            padding: const EdgeInsets.only(bottom: CLShellSizes.gapLg),
                                            // Misura l'altezza intrinseca delle voci cliente (lo
                                            // scroll dà vincolo verticale illimitato) → serve al cap.
                                            child: _MeasureSize(
                                              onChange: (s) {
                                                if (s.height != _navClientH) setState(() => _navClientH = s.height);
                                              },
                                              child: scrollSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Maniglia sul bordo basso dell'header.
                              Positioned(
                                top: headerH - 8,
                                left: 0,
                                right: 0,
                                child: _NavHeaderHandle(
                                  key: const Key('cl-nav-header-resize-handle'),
                                  onDrag: (dy) => setState(() {
                                    _navHeaderFraction = (frac + dy / avail).clamp(minFrac, maxFrac);
                                  }),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  else ...[
                    Positioned.fill(
                      child: CLNavList(
                        destinations: widget.destinations,
                        selectedKey: widget.selectedKey,
                        onSelect: _onSelect,
                        isCompact: isCompact,
                        forceExpandedKey: forceExpandedKey,
                        collapsed: collapsed,
                        // Orizzontale 0: le pill delle voci sono a filo delle bolle frosted
                        // (contenuti allineati via il padding interno della tile).
                        // Top/bottom = altezza bolla (già include il margin gapSm verso la
                        // lista) → gap 8px, niente gapLg extra. Fallback gapSm se assente.
                        padding: EdgeInsets.only(
                          top: hasHeader ? _menuHeaderH : CLShellSizes.gapSm,
                          bottom: hasFooter ? _menuFooterH : CLShellSizes.gapSm,
                        ),
                      ),
                    ),
                    // Barra header frosted (logo + navHeader): in alto, full-width.
                    if (hasHeader)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _MeasureSize(
                          onChange: (s) {
                            if (s.height != _menuHeaderH) setState(() => _menuHeaderH = s.height);
                          },
                          child: _frostedMenuBar(
                            theme,
                            margin: const EdgeInsets.only(bottom: CLShellSizes.gapSm),
                            child: headerContent,
                          ),
                        ),
                      ),
                  ],
                  // Barra footer frosted (navFooter): in basso, full-width. Comune ai due rami.
                  if (hasFooter)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _MeasureSize(
                        onChange: (s) {
                          if (s.height != _menuFooterH) setState(() => _menuFooterH = s.height);
                        },
                        child: _frostedMenuBar(
                          theme,
                          margin: const EdgeInsets.only(top: CLShellSizes.gapSm),
                          child: footerContent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bolla vetro smerigliato per header/footer del menu: margin gapSm (galleggia
  /// sulla lista trasparente) + card arrotondata `secondaryBackground` traslucida
  /// + BackdropFilter. La lista dietro scorre sotto il vetro nei gutter.
  /// Separator tra azienda e voci secondarie ("Gestione cliente"): linea 1px
  /// borderColor. Niente gap verticale proprio: il gap sopra lo dà il padding
  /// bottom del blocco azienda (es. NavHeader ha Padding all gapLg) → un solo Lg.
  /// In resizable è pinnato con l'azienda (non scrolla).
  ///
  /// Inset orizzontale gapLg: allinea le estremità all'inset del contenuto e le
  /// stacca dal bordo della bolla frosted → niente giunzione a "T"/overlap 1px.
  Widget _navHeaderSeparator(CLShellTokens theme) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: CLShellSizes.gapLg),
    color: theme.borderColor,
  );

  Widget _frostedMenuBar(CLShellTokens theme, {required Widget child, EdgeInsets margin = EdgeInsets.zero}) {
    // Bolla menu (header/footer frosted) → radiusBubble concentrico coi controlli.
    final radius = BorderRadius.circular(CLShellSizes.radiusBubble);
    return Padding(
      // Bolla a filo dei bordi del menu (già a gapSm dal canvas): [margin] dà solo
      // il gap verso la lista (bottom per header, top per footer) → 8px uniformi.
      padding: margin,
      // foregroundDecoration: hairline dipinta SOPRA il contenuto clippato → bordo
      // crisp (non tagliato dal ClipRRect).
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: theme.borderColor),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: _frostBlur(
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.secondaryBackground.withValues(alpha: 0.82), borderRadius: radius),
              child: child,
            ),
          ),
        ),
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
        final theme = CLShellTokens.of(context);
        // Mobile: back + page actions vivono nell'area contestuale in basso, non
        // nell'header (qui solo titolo + G3).
        final bottomBar = mode == CLNavMode.bottomBar;

        // Due gruppi con space-between in mezzo: leading [back · breadcrumbs] a
        // sinistra, trailing [pageActions · G3 ricerca/AI] a destra. Lo Spacer tra i
        // due si accorcia restringendo la finestra.
        final leading = <Widget>[];
        // Toggle collapse sidebar (solo bubble desktop/tablet): estende/collassa
        // il menu a rail. Icona statica; lo stato reale lo dà `_prevMode`.
        if (widget.config.bubbleBody && !bottomBar) {
          leading.add(
            ShadIconButton.ghost(
              onPressed: () => setState(() => _collapsed = !_isCollapsed(_prevMode ?? CLNavMode.sidebar)),
              icon: Icon(Icons.view_sidebar_outlined),
              iconSize: CLShellSizes.iconSizeDefault,
            ),
          );
        }
        // Il logo vive in cima al menu (tutti i breakpoint), mai nell'header → qui
        // niente logo: leading parte da back + breadcrumbs.
        if (s.back != null && !bottomBar) {
          leading.add(
            ShadIconButton.ghost(
              onPressed: s.back!.onTap,
              icon: Icon(Icons.chevron_left),
              iconSize: CLShellSizes.iconSizeDefault,
            ),
          );
        }
        if (s.breadcrumbs.isNotEmpty) {
          if (bottomBar) {
            // Mobile: solo titolo (ultimo crumb), Flexible → ellissi su header
            // stretto (niente overflow). Il path completo non entra nel header
            // mobile e vive semmai nell'area contestuale.
            leading.add(
              Flexible(
                child: Text(
                  s.breadcrumbs.last.label,
                  style: theme.heading4,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          } else {
            // Desktop + tablet/rail: ShadBreadcrumb (DS) col path completo. È
            // Wrap-based e l'header ha altezza fissa (40) → lo tengo su riga
            // singola con OverflowBox(maxWidth: ∞) (il Wrap con larghezza
            // illimitata non va mai a capo), allineato a sinistra; ClipRect
            // taglia la coda solo nel caso estremo di header strettissimo. A
            // larghezza normale: DS pieno, nessun clip.
            leading.add(
              Flexible(
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: _breadcrumbs(theme, s.breadcrumbs),
                  ),
                ),
              ),
            );
          }
        } else if (bottomBar && s.back == null && widget.bottomBarHomeLogo != null) {
          // Mobile, pagina senza breadcrumb/back (home): logo al posto del titolo.
          leading.add(widget.bottomBarHomeLogo!);
        }

        final trailing = <Widget>[];
        if (!bottomBar) {
          for (final a in s.pageActions) {
            // mobileOnly: hoisted solo nell'area contestuale mobile, mai in header.
            if (a.mobileOnly) continue;
            trailing.add(_actionButton(context, theme, a));
          }
        }
        // G3 (ricerca + AI + profilo): desktop/tablet. Su mobile le azioni globali
        // vivono nella bottom bar (menu/AI/ricerca) → niente cluster in header,
        // che altrimenti (pill 240 + bottoni) andrebbe in overflow.
        if (!bottomBar) trailing.add(widget.header);

        // Intercala Lg dentro ciascun gruppo.
        List<Widget> joined(List<Widget> ws) {
          final out = <Widget>[];
          for (var i = 0; i < ws.length; i++) {
            if (i > 0) out.add(SizedBox(width: theme.gapLg));
            out.add(ws[i]);
          }
          return out;
        }

        // Leading in Expanded (riempie e fa ellissi sul titolo), trailing flush a
        // destra. NIENTE Spacer: con un leading Flexible "loose" (titolo mobile) lo
        // spazio flex allocato ma non usato diventerebbe vuoto in coda (mainAxis
        // start) → il cluster G3 si sposterebbe verso il centro invece che a destra.
        return Row(
          children: [
            Expanded(child: Row(children: joined(leading))),
            ...joined(trailing),
          ],
        );
      },
    );
  }

  /// Breadcrumb DS ([ShadBreadcrumb]): crumb cliccabili come [ShadBreadcrumbLink],
  /// ultimo (pagina corrente) come Text. Separatore chevron di default dal tema.
  /// NB: [ShadBreadcrumb] è Wrap-based; il confinamento a riga singola nell'header
  /// (altezza fissa) lo fa il chiamante con OverflowBox + ClipRect.
  Widget _breadcrumbs(CLShellTokens theme, List<ShellCrumb> crumbs) {
    return ShadBreadcrumb(
      children: [
        for (var i = 0; i < crumbs.length; i++)
          if (i < crumbs.length - 1 && crumbs[i].onTap != null)
            ShadBreadcrumbLink(onPressed: crumbs[i].onTap, child: Text(crumbs[i].label))
          else
            Text(crumbs[i].label),
      ],
    );
  }

  Widget _actionButton(BuildContext context, CLShellTokens theme, ShellAction a) {
    if (a.builder != null) return a.builder!(context);
    final onTap = a.enabled ? (a.onTap ?? () {}) : () {};
    if (a.isPrimary && a.label != null) {
      return ShadButton(onPressed: onTap, leading: a.icon != null ? Icon(a.icon!) : null, child: Text(a.label!));
    }
    return ShadIconButton.ghost(
      onPressed: onTap,
      icon: Icon(a.icon ?? Icons.circle),
      // Azione secondaria nella bolla: flat su primaryBackground, niente ombra.
      // Bottom bar mobile (chrome): pill.
      iconSize: CLShellSizes.iconSizeDefault,
    );
  }

  // ── Area contestuale mobile (sopra la bottom bar) ──────────────────────────
  /// Due righe: in alto i controlli contestuali (sort/ricerca/filtri della
  /// pagina, se pubblicati), in basso back + page actions + altre azioni. Se un
  /// reveal (filtri / altre azioni) è aperto, le righe collassano e al loro
  /// posto compare il pannello inline. Vuota → collassa.
  Widget _mobileContextArea(BuildContext context, {bool frosted = false}) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        // Cambio contenuto = snap istantaneo (nessuna transizione).
        if (!_hasContent(s)) return const SizedBox.shrink();
        final theme = CLShellTokens.of(context);
        return Container(
          // Frosted: bg/bordo + padding li dà la bolla esterna (card con padding Lg)
          // → qui niente. Non-frosted: striscia a sé con bg/bordo + padding Md.
          decoration: frosted
              ? null
              : BoxDecoration(
                  // Chrome shell (toolbar contestuale mobile) = L0.
                  color: theme.primaryBackground,
                  border: Border(top: BorderSide(color: theme.borderColor)),
                ),
          padding: frosted ? EdgeInsets.zero : EdgeInsets.all(theme.gapMd),
          child: _areaContent(context, s, theme, _panelId),
        );
      },
    );
  }

  bool _hasContent(ShellSlots s) =>
      s.selectionBar != null ||
      s.contextControls.isNotEmpty ||
      s.back != null ||
      s.pageActions.isNotEmpty ||
      s.contextOverflow != null;

  /// Contenuto dell'area per un dato pannello: selezione attiva → SOLO la barra
  /// bulk (priorità); altrimenti `null`/id-non-trovato → le due righe di
  /// controlli; altrimenti il pannello reveal corrispondente.
  Widget _areaContent(BuildContext context, ShellSlots s, CLShellTokens theme, String? id) {
    // Selezione tabella: la barra bulk sostituisce controlli + pageActions.
    if (s.selectionBar != null) return s.selectionBar!;
    if (id != null) {
      final reveal = _revealById(s, id);
      if (reveal != null) return _panelView(context, theme, reveal);
    }
    return _rowsContent(context, s, theme);
  }

  /// Le due righe: [sort/ricerca/filtri] sopra, [back/azione/altre azioni] sotto.
  Widget _rowsContent(BuildContext context, ShellSlots s, CLShellTokens theme) {
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
                if (i > 0) SizedBox(width: theme.gapMd),
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
                    ShadIconButton.ghost(
                      onPressed: s.back!.onTap,
                      icon: Icon(Icons.chevron_left),
                      // Bolla frosted: card bianca elevata (non flat/recessed).
                      // Bottom bar mobile (chrome): pill.
                      iconSize: CLShellSizes.iconSizeDefault,
                    ),
                    SizedBox(width: theme.gapMd),
                  ],
                  Expanded(
                    child: primary != null
                        ? ShadButton(
                            onPressed: primary.enabled ? (primary.onTap ?? () {}) : () {},
                            leading: primary.icon != null ? Icon(primary.icon) : null,
                            width: double.infinity,
                            child: Text(primary.label!),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < s.pageActions.length; i++) ...[
                                  if (i > 0) SizedBox(width: theme.gapMd),
                                  _actionButton(context, theme, s.pageActions[i]),
                                ],
                              ],
                            ),
                          ),
                  ),
                  // Azioni secondarie a destra del primario (solo se c'è un primario).
                  if (primary != null)
                    for (final a in others) ...[SizedBox(width: theme.gapMd), _actionButton(context, theme, a)],
                  if (s.contextOverflow != null) ...[
                    SizedBox(width: theme.gapMd),
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
  Widget _panelView(BuildContext context, CLShellTokens theme, ShellRevealControl r) {
    void close() => _closePanel();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ShadIconButton.ghost(onPressed: close, icon: Icon(Icons.arrow_back), iconSize: CLShellSizes.iconSizeDefault),
            SizedBox(width: theme.gapMd),
            Expanded(
              child: Text(r.title, style: theme.heading5, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        SizedBox(height: theme.gapLg),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
          child: SingleChildScrollView(child: r.panelBuilder(context, close)),
        ),
      ],
    );
  }

  /// Bottone reveal (filtri / altre azioni): toggle del pannello inline.
  /// Evidenziato quando aperto; badge opzionale (es. filtri attivi).
  Widget _revealButton(BuildContext context, CLShellTokens theme, ShellRevealControl r) {
    final btn = ShadIconButton.outline(
      onPressed: () => _togglePanel(r.id),
      // iconSize ESPLICITO obbligatorio: ShadIconButton NON eredita l'IconTheme
      // ambientale (senza iconSize cadrebbe sul fallback Flutter, 24). Compact
      // (16) → pareggia l'icona di ricerca dell'input accanto.
      icon: Icon(r.icon),
      iconSize: CLShellSizes.iconSizeCompact,
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
  Widget _contextControl(BuildContext context, CLShellTokens theme, ShellContextControl c) {
    if (c.action != null) return _actionButton(context, theme, c.action!);
    if (c.reveal != null) return _revealButton(context, theme, c.reveal!);
    if (c.custom != null) return c.custom!.builder(context);
    final search = c.search!;
    // Ricerca contestuale su primitivo Shad (ShadInput): decorazione,
    // tipografia e cursore dai token del tema, icona di ricerca come leading.
    return Expanded(
      child: ShadInput(
        controller: search.controller,
        onChanged: search.onChanged,
        placeholder: search.hint != null ? Text(search.hint!) : null,
        leading: Icon(LucideIcons.search, size: CLShellSizes.iconSizeCompact),
      ),
    );
  }

  /// Card bianca (bolla menu/assistente desktop): secondaryBackground, angoli
  /// bolla (radiusBubble), ombra soft, clip.
  Widget _sideCard(BuildContext context, {required Widget child}) {
    final theme = CLShellTokens.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(CLShellSizes.radiusBubble),
        border: Border.all(color: theme.borderColor),
      ),
      child: child,
    );
  }

  // ── Desktop ──────────────────────────────────────────────────────────────
  /// Menu in bolla FULL-HEIGHT a sinistra (logo in cima + nav), con padding esterno;
  /// a destra, in Column: header frosted (solo sopra il contenuto) · shell ·
  /// assistente. Il logo vive nel menu, non nell'header.
  Widget _buildSidebar(BuildContext context) {
    final theme = CLShellTokens.of(context);
    // Nota: bubbleBody è gestito in build() (desktop+tablet unificati) prima di
    // arrivare qui → nessun branch bubble in questo metodo.
    if (widget.config.frostedFullBleed) {
      return _frostedSidebar(context, theme);
    }
    return ColoredBox(
      // Shell content bg = primaryBackground (uguale a header/footer strip).
      color: theme.primaryBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Menu in bolla full-height. Margine esterno Lg su TUTTI i lati: il
          // right serve allo spazio dell'ombra della card (toglierlo la clippa).
          Padding(
            padding: const EdgeInsets.all(CLShellSizes.gapLg),
            child: SizedBox(
              width: widget.config.sidebarWidth,
              child: _sideCard(context, child: _navPanel(theme, isCompact: false, frosted: true)),
            ),
          ),
          // Colonna centrale: header solo sopra il contenuto, poi corpo.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerStrip(context, theme, child: _composedHeader(context, mode: CLNavMode.sidebar)),
                Expanded(child: _scopedBody()),
              ],
            ),
          ),
          // Assistente AI: bolla full-height a destra, di fianco a header + shell,
          // stessa card del menu (bianca + ombra). Margine esterno Lg.
          if (widget.trailing != null)
            Padding(
              padding: const EdgeInsets.all(CLShellSizes.gapLg),
              child: SizedBox(
                width: widget.config.trailingWidth,
                child: _sideCard(context, child: widget.trailing!),
              ),
            ),
        ],
      ),
    );
  }

  // ── Desktop full-bleed (opt-in) ────────────────────────────────────────────
  /// Stack: contenuto full-bleed che scorre sotto un header blur FULL WIDTH, con
  /// menu (e assistente) in card sopra l'header nello z-order → l'ombra delle card
  /// galleggia sopra header/contenuto e non viene MAI clippata. Insets verticali
  /// del contenuto via MediaQuery (come mobile); orizzontali via Positioned.
  Widget _frostedSidebar(BuildContext context, CLShellTokens theme) {
    return ColoredBox(
      color: theme.primaryBackground,
      child: _frostedBody(
        context,
        theme,
        navCard: _sideCard(context, child: _navPanel(theme, isCompact: false, frosted: true)),
        cardWidth: widget.config.sidebarWidth,
        headerMode: CLNavMode.sidebar,
      ),
    );
  }

  /// Corpo full-bleed condiviso da desktop ([_frostedSidebar]) e tablet
  /// ([_frostedRail]). Stack: contenuto sotto un header blur FULL WIDTH; la card
  /// nav (e l'AI) stanno SOPRA l'header nello z-order → l'ombra galleggia e non
  /// viene MAI clippata. Insets del contenuto su tutti i lati via MediaQuery
  /// (gutter = gapLg; top = header + gutter) → le pagine li consumano. Il wrapper
  /// (ColoredBox desktop / Scaffold tablet col drawer) lo fornisce il chiamante.
  Widget _frostedBody(
    BuildContext context,
    CLShellTokens theme, {
    required Widget navCard,
    required double cardWidth,
    required CLNavMode headerMode,
  }) {
    final topInset = MediaQuery.paddingOf(context).top;
    final headerH = theme.buttonHeightDefault + theme.gapLg * 2 + topInset;
    // Il content region parte al bordo della card nav (margine sx + card); il gutter
    // sx iniettato è lo spazio dove vive l'ombra (card su z superiore → safe).
    final cardRight = theme.gapLg + cardWidth;
    final hasAi = widget.trailing != null;
    final aiCardLeft = hasAi ? theme.gapLg + widget.config.trailingWidth : 0.0;
    final mq = MediaQuery.of(context);

    return Stack(
      children: [
        // z0 — contenuto: tra card nav (sx) e card AI (dx). Insets su tutti i lati.
        Positioned(
          top: 0,
          bottom: 0,
          left: cardRight,
          right: aiCardLeft,
          child: MediaQuery(
            data: mq.copyWith(
              padding: mq.padding.copyWith(
                top: headerH + theme.gapLg, // clearance header + gutter
                bottom: theme.gapLg,
                left: theme.gapLg,
                right: theme.gapLg,
              ),
            ),
            child: _scopedBody(),
          ),
        ),
        // z1 — header blur (hairline) FULL-BLEED: da bordo a bordo, SOTTO le card
        // nav (sx) e AI (dx) che galleggiano z2/z3 → l'header non viene "spinto"
        // dalla bolla AI, le passa sotto come fa col menu. leftInset/rightInset
        // riservano lo spazio delle card così il contenuto header (titolo/ricerca/
        // AI button) resta allineato al contenuto pagina e mai sotto le bolle.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _frostedHeader(
            context,
            theme,
            withMenuButton: false,
            leftInset: cardWidth + theme.gapLg,
            mode: headerMode,
            rightInset: aiCardLeft,
          ),
        ),
        // z2 — card nav SOPRA l'header. Ombra safe. Margine sx/top/bottom.
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: CLShellSizes.gapLg, top: CLShellSizes.gapLg, bottom: CLShellSizes.gapLg),
            child: SizedBox(width: cardWidth, child: navCard),
          ),
        ),
        // z3 — assistente AI a destra, sopra (ombra safe). Margine dx/top/bottom.
        if (hasAi)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: CLShellSizes.gapLg, top: CLShellSizes.gapLg, bottom: CLShellSizes.gapLg),
              child: SizedBox(
                width: widget.config.trailingWidth,
                child: _sideCard(context, child: widget.trailing!),
              ),
            ),
          ),
      ],
    );
  }

  // ── Desktop "a bolle" (opt-in config.bubbleBody) ───────────────────────────
  /// Menu FLAT sul canvas grigio a sinistra (niente card, solo bordo destro dal
  /// [_navPanel] flat); centro = UNA bolla arrotondata con header frosted fisso +
  /// contenuto scrollabile che scorre SOTTO l'header; assistente in bolla a
  /// destra. Gutter Lg attorno alle bolle. Stile shadcn dashboard.
  Widget _bubbleDesktop(BuildContext context, CLShellTokens theme, {required CLNavMode mode}) {
    final collapsed = _isCollapsed(mode);
    // Ritieni l'ultimo trailing non-null: montato durante l'animazione di
    // chiusura della bolla assistente (vedi reveal più sotto).
    if (widget.trailing != null) _retainedTrailing = widget.trailing;
    return ColoredBox(
      color: theme.primaryBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Menu in bolla (come body/AI): margin Sm su l/t/b, NIENTE destra (il
          // gap col body lo dà il padding-left del body → evita doppio). Card
          // arrotondata secondaryBackground; larghezza animata sidebar↔rail.
          Builder(
            builder: (_) {
              final menuW = collapsed ? widget.config.railWidth : widget.config.sidebarWidth;
              return Padding(
                padding: const EdgeInsets.only(left: CLShellSizes.gapSm, top: CLShellSizes.gapSm, bottom: CLShellSizes.gapSm),
                child: AnimatedContainer(
                  duration: theme.durationBase,
                  curve: Curves.easeInOut,
                  width: menuW,
                  // Sfondo TRASPARENTE dietro le voci. ClipRect RETTANGOLARE (non
                  // arrotondato): il menu è trasparente e le bolle frost hanno il
                  // proprio radius → un ClipRRect qui taglierebbe gli angoli delle
                  // bolle a filo. Serve solo a clippare la larghezza animata.
                  child: ClipRect(
                    // OverflowBox: impagina il contenuto alla larghezza FINALE (menuW),
                    // così durante l'animazione non fa reflow (niente overflow delle
                    // voci/header estesi); il ClipRRect rivela la larghezza animata.
                    child: OverflowBox(
                      minWidth: menuW,
                      maxWidth: menuW,
                      alignment: Alignment.centerLeft,
                      child: _navPanel(
                        theme,
                        isCompact: false,
                        frosted: true,
                        showRightBorder: false,
                        collapsed: collapsed,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Bolla centrale: header frost fisso + body scroll. Gutter Sm su tutti i
          // lati (il left dà il gap col menu, il right col bordo/AI).
          Expanded(
            child: Padding(padding: const EdgeInsets.all(CLShellSizes.gapSm), child: _bubbleCenter(context, theme)),
          ),
          // Assistente in bolla a destra. Anima SOLO la bolla (reveal della
          // larghezza, apertura+chiusura, durata da token): il contenuto è
          // impaginato alla larghezza FINALE dentro un OverflowBox → non slitta
          // né fa reflow, viene solo rivelato dal clip. `_retainedTrailing` tiene
          // il child montato durante il collasso (widget.trailing torna null).
          if (_retainedTrailing != null)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: widget.trailing != null ? 1.0 : 0.0),
              duration: theme.durationBase,
              curve: Curves.easeInOutCubic,
              onEnd: () {
                // Collasso completato → smonta il child ritenuto.
                if (widget.trailing == null && mounted) setState(() => _retainedTrailing = null);
              },
              builder: (context, v, child) {
                if (v <= 0) return const SizedBox.shrink();
                final full = widget.config.trailingWidth;
                return Padding(
                  padding: const EdgeInsets.only(top: CLShellSizes.gapSm, bottom: CLShellSizes.gapSm, right: CLShellSizes.gapSm),
                  child: SizedBox(
                    width: full * v,
                    child: ClipRect(
                      child: OverflowBox(
                        minWidth: full,
                        maxWidth: full,
                        alignment: Alignment.centerRight,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: widget.config.trailingWidth,
                child: _sideCard(context, child: _retainedTrailing!),
              ),
            ),
        ],
      ),
    );
  }

  /// Bolla centrale di [_bubbleDesktop]: card arrotondata (clip) con header
  /// frosted fisso in cima e contenuto scrollabile sotto. Il contenuto riceve
  /// top inset = altezza header (+ gutter) via MediaQuery, così scorre SOTTO il
  /// vetro dell'header senza esserne tagliato. Angoli clippati → il blur e il
  /// contenuto restano dentro la bolla.
  Widget _bubbleCenter(BuildContext context, CLShellTokens theme, {bool withMenuButton = false}) {
    // Dentro la bolla non c'è system inset in cima: header = altezza base.
    final headerH = theme.buttonHeightDefault + theme.gapLg * 2;
    final mq = MediaQuery.of(context);
    // Bolla centrale shell → radiusBubble (coerente con menu/AI/bottom bar).
    final radius = BorderRadius.circular(CLShellSizes.radiusBubble);
    // bg behind; ClipRRect clips the Stack (rounds corners + contains the header
    // BackdropFilter); border in foregroundDecoration → painted OVER the child,
    // so the frosted header's white doesn't cover the top/side border.
    return Container(
      decoration: BoxDecoration(color: theme.secondaryBackground, borderRadius: radius),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: theme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // z0 — contenuto che scorre sotto l'header. Inset via MediaQuery.
            Positioned.fill(
              child: MediaQuery(
                data: mq.copyWith(
                  padding: mq.padding.copyWith(
                    // top = clearance header esatta (niente gapLg extra); bottom 0.
                    // La pagina non deve ereditare respiro verticale che taglia in
                    // scroll — lo aggiunge lei se serve. Gutter solo orizzontale.
                    top: headerH,
                    bottom: 0,
                    left: theme.gapLg,
                    right: theme.gapLg,
                  ),
                ),
                child: _scopedBody(),
              ),
            ),
            // z1 — header frosted fisso in cima alla bolla. removeTop: dentro la
            // bolla non c'è system inset (SafeArea del header lo aggiungerebbe →
            // header troppo alto, hairline sfasato).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Builder(
                  builder: (ctx) =>
                      _frostedHeader(ctx, theme, withMenuButton: withMenuButton, mode: CLNavMode.sidebar),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Variante mobile/tablet del layout a bolle: canvas grigio, menu nel drawer
  /// (hamburger nell'header frosted), body = stessa bolla del desktop. Adatta i
  /// tier rail/bottom-bar al look desktop quando `config.bubbleBody`.
  Widget _bubbleScaffold(BuildContext context, CLShellTokens theme) {
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.primaryBackground,
      onDrawerChanged: (open) {
        if (!open && _drawerExpandKey != null) setState(() => _drawerExpandKey = null);
      },
      drawer: Drawer(
        width: drawerWidth,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true, forceExpandedKey: _drawerExpandKey)),
      ),
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CLShellSizes.gapSm),
          child: _bubbleCenter(context, theme, withMenuButton: true),
        ),
      ),
    );
  }

  // ── Tablet (rail icon-only) ────────────────────────────────────────────────
  /// Rail in bolla FULL-HEIGHT a sinistra (come la sidebar desktop) + header solo
  /// sopra il contenuto + body. Il drawer resta come overlay: aprendolo da una
  /// voce di gruppo della rail mostra il menu completo.
  Widget _buildRail(BuildContext context) {
    final theme = CLShellTokens.of(context);
    if (widget.config.bubbleBody) {
      return _bubbleScaffold(context, theme);
    }
    if (widget.config.frostedFullBleed) {
      return _frostedRail(context, theme);
    }
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    return Scaffold(
      key: _scaffoldKey,
      // Shell content = page bg (#F6F5F4).
      // Drawer chiuso → azzera il gruppo forzato (apertura da avatar parte pulita).
      onDrawerChanged: (open) {
        if (!open && _drawerExpandKey != null) setState(() => _drawerExpandKey = null);
      },
      drawer: Drawer(
        width: drawerWidth,
        // Menu drawer = L0.
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true, forceExpandedKey: _drawerExpandKey)),
      ),
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rail in bolla full-height. Margine esterno Lg su tutti i lati.
          Padding(
            padding: const EdgeInsets.all(CLShellSizes.gapLg),
            child: _sideCard(
              context,
              child: CLNavRail(
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
                frosted: true,
              ),
            ),
          ),
          // Colonna destra: header solo sopra il contenuto, poi corpo + assistente.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerStrip(context, theme, child: _composedHeader(context, mode: CLNavMode.rail)),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _scopedBody()),
                      if (widget.trailing != null)
                        SizedBox(width: widget.config.trailingWidth, child: widget.trailing!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tablet full-bleed (opt-in) ──────────────────────────────────────────────
  /// Come [_frostedSidebar] ma con la rail icon-only al posto del menu esteso.
  /// Stack: contenuto full-bleed sotto header blur FULL WIDTH, rail card sopra
  /// (ombra mai clippata). Scaffold per il drawer (tap su gruppo → drawer esteso).
  Widget _frostedRail(BuildContext context, CLShellTokens theme) {
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    return Scaffold(
      key: _scaffoldKey,
      onDrawerChanged: (open) {
        if (!open && _drawerExpandKey != null) setState(() => _drawerExpandKey = null);
      },
      drawer: Drawer(
        width: drawerWidth,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true, forceExpandedKey: _drawerExpandKey)),
      ),
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      body: _frostedBody(
        context,
        theme,
        navCard: _sideCard(
          context,
          child: CLNavRail(
            destinations: widget.destinations,
            selectedKey: widget.selectedKey,
            onSelect: _onSelect,
            onOpenGroup: (d) {
              setState(() => _drawerExpandKey = d.key);
              _scaffoldKey.currentState?.openDrawer();
            },
            header: widget.railHeader,
            footer: widget.railFooter,
            width: widget.config.railWidth,
            frosted: true,
          ),
        ),
        cardWidth: widget.config.railWidth,
        headerMode: CLNavMode.rail,
      ),
    );
  }

  // ── Mobile (drawer + bottom bar) ───────────────────────────────────────────
  /// Shell mobile: due rami selezionati da [CLShellConfig.frostedFullBleed].
  ///
  /// **Legacy (false):** Column → header in alto, body in mezzo, barra in
  /// basso. Il body sta in flusso tra le barre → le pagine non insettano.
  ///
  /// **Frosted full-bleed (true):** `Scaffold(extendBody: true,
  /// extendBodyBehindAppBar: true)` con `appBar:` e `bottomNavigationBar:`.
  /// Flutter misura la bottom bar (altezza variabile) e inietta l'inset nel
  /// MediaQuery del body → le pagine non devono calcolare manualmente il padding.
  Widget _buildScaffold(BuildContext context, {required bool withBottomBar}) {
    final theme = CLShellTokens.of(context);

    // Mobile (bottomBar): SEMPRE il layout frosted con bottom bar — sia con
    // bubbleBody sia con frostedFullBleed. Su mobile non c'è la "bolla" desktop:
    // serve la bottom bar (menu/AI/ricerca) + area contestuale. Il vecchio
    // _bubbleScaffold rendeva solo header desktop (mode sidebar) senza bottom bar.
    if (widget.config.bubbleBody || widget.config.frostedFullBleed) {
      return _frostedScaffold(context, theme, withBottomBar: withBottomBar);
    }

    // ── Legacy: Column in flusso ─────────────────────────────────────────────
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    final drawer = Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(child: _navPanel(theme, isCompact: true)),
    );

    return Scaffold(
      key: _scaffoldKey,
      // Shell content = page bg (#F6F5F4).
      drawer: drawer,
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      body: Column(
        children: [
          _mobileHeaderStrip(context, theme),
          Expanded(child: _scopedBody()),
          _mobileBottomStrip(context, theme, withBottomBar: withBottomBar),
        ],
      ),
    );
  }

  /// Ramo frosted full-bleed: Scaffold con `extendBody`/`extendBodyBehindAppBar`
  /// veri così Flutter calcola gli inset della bottom bar (altezza variabile) e
  /// li inietta nel MediaQuery del body automaticamente.
  Widget _frostedScaffold(BuildContext context, CLShellTokens theme, {required bool withBottomBar}) {
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    final drawer = Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(child: _navPanel(theme, isCompact: true)),
    );

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawer: drawer,
      endDrawer: widget.endDrawer,
      endDrawerEnableOpenDragGesture: false,
      // Hamburger nell'header solo se il menu NON è già nella bottom bar custom.
      appBar: _frostedHeader(context, theme, withMenuButton: widget.bottomBarItems == null),
      bottomNavigationBar: _frostedBottom(context, theme, withBottomBar: withBottomBar),
      // Builder → legge il MediaQuery iniettato dallo Scaffold (top header / bottom
      // bolla) e aggiunge il gutter orizzontale (gapLg). Le pagine consumano tutto
      // da MediaQuery.padding senza hardcodare, coerente col desktop.
      body: Builder(
        builder: (context) {
          final bodyMq = MediaQuery.of(context);
          return MediaQuery(
            data: bodyMq.copyWith(
              padding: bodyMq.padding.copyWith(
                // Scaffold inietta top=header, bottom=bolla. Aggiungo il gutter (gapLg)
                // su tutti i lati per spaziatura uniforme col desktop.
                top: bodyMq.padding.top + theme.gapLg,
                bottom: bodyMq.padding.bottom + theme.gapLg,
                left: theme.gapLg,
                right: theme.gapLg,
              ),
            ),
            child: _scopedBody(),
          );
        },
      ),
    );
  }

  /// AppBar frosted: altezza `buttonHeightDefault + gapLg * 2 + topInset`,
  /// hamburger + header composto. Blur vetro smerigliato via ClipRect +
  /// BackdropFilter + sfondo traslucente (secondaryBackground @ alpha 0.72) così
  /// il contenuto che scrolla sotto rimane visibile (blurred). Il topInset
  /// (notch/status bar) è incluso nell'altezza preferred così la SafeArea
  /// interna lo consuma senza clippare il contenuto.
  /// [withMenuButton] — true (mobile): hamburger che apre il drawer. false
  /// (desktop): nessun hamburger (menu sempre visibile), il contenuto header
  /// parte dopo [leftInset] (area menu) così non finisce sotto la card menu.
  PreferredSizeWidget _frostedHeader(
    BuildContext context,
    CLShellTokens theme, {
    bool withMenuButton = true,
    double leftInset = 0,
    CLNavMode mode = CLNavMode.bottomBar,
    // Inset destro simmetrico a [leftInset]: riserva lo spazio della card AI (che
    // galleggia z3 sopra l'header full-bleed) → il contenuto header finisce
    // allineato al contenuto pagina, mai sotto la bolla AI.
    double rightInset = 0,
    bool bottomBorder = false,
  }) {
    final topInset = MediaQuery.paddingOf(context).top;
    final height = theme.buttonHeightDefault + theme.gapLg * 2 + topInset;
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: ClipRect(
        child: _frostBlur(
          child: DecoratedBox(
            decoration: BoxDecoration(
              // Vetro smerigliato bianco (come la bolla bottom), non il canvas grigio.
              // Hairline bottom opt-in (bolla): separa header dal contenuto che scorre.
              color: theme.secondaryBackground.withValues(alpha: 0.6),
              border: bottomBorder ? Border(bottom: BorderSide(color: theme.borderColor)) : null,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(theme.gapLg),
                child: SizedBox(
                  height: theme.buttonHeightDefault,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (withMenuButton) ...[
                        ShadIconButton.ghost(
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          icon: Icon(Icons.menu),
                          iconSize: CLShellSizes.iconSizeDefault,
                        ),
                        SizedBox(width: theme.gapLg),
                      ] else if (leftInset > 0)
                        SizedBox(width: leftInset),
                      Expanded(child: _composedHeader(context, mode: mode)),
                      // Riserva lo spazio della card AI (z3) → contenuto header a
                      // filo del body, mai sotto la bolla AI.
                      if (rightInset > 0) SizedBox(width: rightInset),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom bar frosted: bolla traslucente con vetro smerigliato. Stessa logica
  /// del [_frostedHeader]: ClipRect + BackdropFilter (sigma 18) + sfondo
  /// secondaryBackground @ alpha 0.78. Angoli [theme.radiusBubble], margine
  /// esterno Lg, SafeArea bottom per l'home indicator.
  Widget _frostedBottom(BuildContext context, CLShellTokens theme, {required bool withBottomBar}) {
    return SafeArea(
      top: false,
      // Margine esterno bolla: NO top. Lo Scaffold misura tutta la
      // bottomNavigationBar per l'inset del body; un top qui verrebbe conteggiato
      // come clearance ma è solo spazio trasparente sotto cui il contenuto scorre.
      child: Padding(
        padding: EdgeInsets.only(left: theme.gapLg, right: theme.gapLg, bottom: theme.gapLg),
        // Bolla frosted rounded, come le bolle desktop (_frostedMenuBar): bordo
        // crisp via foregroundDecoration (non tagliato dal clip) + ClipRRect per
        // il vetro + DecoratedBox per lo sfondo traslucido. Capsule = radiusBubble.
        child: Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusBubble),
            border: Border.all(color: theme.borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusBubble),
            child: _frostBlur(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground.withValues(alpha: 0.66),
                  borderRadius: BorderRadius.circular(theme.radiusBubble),
                ),
                child: Padding(
                  padding: EdgeInsets.all(theme.gapLg),
                  child: _bubbleInner(context, theme, withBottomBar: withBottomBar, applyNavGating: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Contenuto interno della bolla bottom (area contestuale + nav). Estratto
  /// per evitare duplicazione tra [_mobileBottomStrip] e [_frostedBottom].
  ///
  /// [applyNavGating] — solo il path frosted nasconde la nav quando un pannello
  /// è aperto o la selezione bulk è attiva. Il path legacy non gata mai la nav
  /// (comportamento invariato rispetto a prima di Task 5).
  Widget _bubbleInner(
    BuildContext context,
    CLShellTokens theme, {
    required bool withBottomBar,
    bool applyNavGating = false,
  }) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        final hasContext = _hasContent(s);
        final panelOpen = _panelId != null;
        final selecting = s.selectionBar != null;
        // Legacy (applyNavGating=false): showNav = withBottomBar (old behavior).
        // Frosted (applyNavGating=true): nasconde nav se pannello aperto o selezione.
        final showNav = withBottomBar && (!applyNavGating || (!panelOpen && !selecting));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _mobileContextArea(context, frosted: true),
            if (hasContext && showNav) SizedBox(height: theme.gapLg),
            if (showNav)
              CLBottomBar(
                destinations: widget.bottomDestinations ?? widget.destinations,
                selectedKey: widget.selectedKey,
                onSelect: _onSelect,
                onOpenGroup: (_) => _scaffoldKey.currentState?.openDrawer(),
                onOverflow: () => _scaffoldKey.currentState?.openDrawer(),
                maxItems: widget.config.maxBottomBarItems,
                // Custom: barra fissa [menu, dashboard, AI, profilo, ricerca].
                items: widget.bottomBarItems,
                topBorder: true,
                floating: true,
              ),
          ],
        );
      },
    );
  }

  /// Striscia header full-width (no bolla, no margine): sfondo primaryBackground
  /// solido, SafeArea top + padding Lg. Condivisa dai 3 viewport: il [child] cambia
  /// (mobile: hamburger+header; desktop/rail: header).
  Widget _headerStrip(BuildContext context, CLShellTokens theme, {required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.primaryBackground),
      child: SafeArea(
        bottom: false,
        child: Padding(padding: const EdgeInsets.all(CLShellSizes.gapLg), child: child),
      ),
    );
  }

  /// Header mobile: striscia frosted con hamburger + header composto (titolo/
  /// ricerca/AI). Hamburger su secondaryBackground + ombra soft così "galleggia"
  /// sulla striscia (come la global search e il bottone AI).
  Widget _mobileHeaderStrip(BuildContext context, CLShellTokens theme) {
    return _headerStrip(
      context,
      theme,
      // Altezza pinnata ai controlli: il titolo (heading6, line-height alto)
      // gonfierebbe la Row oltre buttonHeightDefault dimezzando l'hit-box del
      // hamburger. Pin → hit == visibile.
      child: SizedBox(
        height: theme.buttonHeightDefault,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hamburger solo se il menu non è già nella bottom bar custom.
            if (widget.bottomBarItems == null) ...[
              ShadIconButton.ghost(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: Icon(Icons.menu),
                iconSize: CLShellSizes.iconSizeDefault,
              ),
              const SizedBox(width: CLShellSizes.gapLg),
            ],
            Expanded(child: _composedHeader(context, mode: CLNavMode.bottomBar)),
          ],
        ),
      ),
    );
  }

  /// Bottom bar in BOLLA: card (secondaryBackground + ombra soft) con margine esterno
  /// su sx/dx/bottom — niente top (flush col contenuto sopra) — e SafeArea bottom per
  /// l'home indicator. Dentro: area contestuale (azioni/controlli tabella) + nav,
  /// separate da un divider quando coesistono.
  Widget _mobileBottomStrip(BuildContext context, CLShellTokens theme, {required bool withBottomBar}) {
    return SafeArea(
      top: false,
      child: Padding(
        // Bolla bottom bar: margine esterno Lg su tutti i lati.
        padding: const EdgeInsets.all(CLShellSizes.gapLg),
        child: _sideCard(
          context,
          child: Padding(
            // Padding interno Lg; gap Md tra gli elementi (context area · nav).
            padding: const EdgeInsets.all(CLShellSizes.gapLg),
            child: _bubbleInner(context, theme, withBottomBar: withBottomBar),
          ),
        ),
      ),
    );
  }
}

/// Riporta la dimensione renderizzata del [child] via [onChange] dopo il layout.
/// Usato dallo shell per misurare le barre frosted del menu e riservare il
/// padding della lista.
/// Maniglia di resize sul bordo basso dell'header nav: strip full-width con drag
/// verticale (cursore resizeUpDown) che notifica il delta dy; grabber pill
/// visibile SOLO su hover (discoverability senza cromatura fissa). Il drag resta
/// attivo su tutta la strip anche senza hover.
class _NavHeaderHandle extends StatelessWidget {
  const _NavHeaderHandle({super.key, required this.onDrag});

  /// Delta verticale (px) di ogni update di drag.
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final t = CLShellTokens.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (d) => onDrag(d.delta.dy),
        child: SizedBox(
          height: 16,
          child: Center(
            // Grabber sempre visibile, identico alla resize handle: pill borderColor
            // (radius 4, padding H3/V1) con icona gripHorizontal (asse verticale).
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(color: t.borderColor, borderRadius: BorderRadius.circular(4)),
              child: Icon(LucideIcons.gripHorizontal, size: 10, color: t.secondaryText),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _old;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = context.size;
      if (size != null && size != _old) {
        _old = size;
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}
