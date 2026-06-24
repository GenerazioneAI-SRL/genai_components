import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
    this.headerLeading,
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

  /// Logo dell'app, mostrato in cima al menu (nav panel) su tutti i breakpoint —
  /// sidebar desktop e drawer tablet/mobile. Mai nell'header. `null` = assente.
  final Widget? headerLeading;
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

  Widget _navPanel(CLTheme theme, {required bool isCompact, String? forceExpandedKey, bool frosted = false}) {
    return Container(
      // Menu = L0 (primaryBackground) + bordo destro. In card (bolla desktop): bg/
      // bordo li dà la card esterna → qui trasparente.
      decoration: frosted
          ? null
          : BoxDecoration(
              color: theme.primaryBackground,
              border: Border(right: BorderSide(color: theme.borderColor)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo dell'app in cima al menu (tutti i breakpoint): allineato a sinistra,
          // gap sotto verso la tenant card. Mai nell'header → vive solo qui.
          if (widget.headerLeading != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Sizes.gapLg, Sizes.gapLg, Sizes.gapLg, 0),
              child: Align(alignment: Alignment.centerLeft, child: widget.headerLeading!),
            ),
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

        // Due gruppi con space-between in mezzo: leading [back · breadcrumbs] a
        // sinistra, trailing [pageActions · G3 ricerca/AI] a destra. Lo Spacer tra i
        // due si accorcia restringendo la finestra.
        final leading = <Widget>[];
        // Il logo vive in cima al menu (tutti i breakpoint), mai nell'header → qui
        // niente logo: leading parte da back + breadcrumbs.
        if (s.back != null && !bottomBar) {
          leading.add(CLIconButton(
            onTap: s.back!.onTap,
            iconData: Icons.chevron_left,
            backgroundColor: theme.secondaryBackground,
            boxShadow: theme.cardShadowSoft,
            iconColor: theme.primaryText,
            size: theme.buttonHeightDefault,
            iconSize: Sizes.iconSizeDefault,
            tooltip: s.back!.tooltip ?? 'Indietro',
          ));
        }
        if (s.breadcrumbs.isNotEmpty) {
          if (mode != CLNavMode.sidebar) {
            // Tablet/mobile: solo titolo (ultimo crumb), Flexible → ellissi su
            // header stretto (niente overflow).
            leading.add(Flexible(
              child: Text(
                s.breadcrumbs.last.label,
                style: theme.heading4,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ));
          } else {
            // Desktop: path completo intrinseco.
            leading.add(_breadcrumbs(theme, s.breadcrumbs));
          }
        }

        final trailing = <Widget>[];
        if (!bottomBar) {
          for (final a in s.pageActions) {
            trailing.add(_actionButton(context, theme, a));
          }
        }
        // G3 (ricerca + AI + profilo): sempre presente.
        trailing.add(widget.header);

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
      // Azione secondaria nella bolla: flat su primaryBackground, niente ombra.
      backgroundColor: theme.primaryBackground,
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
  Widget _mobileContextArea(BuildContext context, {bool frosted = false}) {
    return AnimatedBuilder(
      animation: _slots,
      builder: (context, _) {
        final s = _slots.slots;
        // Cambio contenuto = snap istantaneo (nessuna transizione).
        if (!_hasContent(s)) return const SizedBox.shrink();
        final theme = CLTheme.of(context);
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
      s.selectionBar != null || s.contextControls.isNotEmpty || s.back != null || s.pageActions.isNotEmpty || s.contextOverflow != null;

  /// Contenuto dell'area per un dato pannello: selezione attiva → SOLO la barra
  /// bulk (priorità); altrimenti `null`/id-non-trovato → le due righe di
  /// controlli; altrimenti il pannello reveal corrispondente.
  Widget _areaContent(BuildContext context, ShellSlots s, CLTheme theme, String? id) {
    // Selezione tabella: la barra bulk sostituisce controlli + pageActions.
    if (s.selectionBar != null) return s.selectionBar!;
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
                    CLIconButton(
                      onTap: s.back!.onTap,
                      iconData: Icons.chevron_left,
                      backgroundColor: theme.primaryBackground,
                      iconColor: theme.primaryText,
                      size: theme.buttonHeightDefault,
                      iconSize: Sizes.iconSizeDefault,
                      tooltip: s.back!.tooltip ?? 'Indietro',
                    ),
                    SizedBox(width: theme.gapMd),
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
                                  if (i > 0) SizedBox(width: theme.gapMd),
                                  _actionButton(context, theme, s.pageActions[i]),
                                ],
                              ],
                            ),
                          ),
                  ),
                  // Azioni secondarie a destra del primario (solo se c'è un primario).
                  if (primary != null)
                    for (final a in others) ...[
                      SizedBox(width: theme.gapMd),
                      _actionButton(context, theme, a),
                    ],
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
              backgroundColor: theme.primaryBackground,
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
      backgroundColor: active ? theme.primary.withValues(alpha: 0.12) : theme.primaryBackground,
      boxShadow: null,
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
    // Stessa resa della search desktop della tabella (paged_datatable_filter,
    // isMainFilter): recess tertiaryBackground, pill, icona Lucide primaryText con
    // left-pad esplicito, TextField collapsed con tipografia di sistema.
    return Expanded(
      child: Container(
        height: theme.inputHeight,
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusPill),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: theme.gapMd, right: theme.gapSm),
              child: Icon(LucideIcons.search, color: theme.primaryText, size: Sizes.iconSizeDefault),
            ),
            Expanded(
              child: TextField(
                controller: search.controller,
                onChanged: search.onChanged,
                maxLines: 1,
                style: theme.bodyText.copyWith(fontWeight: FontWeight.w400, height: 1.0, color: theme.primaryText),
                cursorColor: theme.primary,
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: search.hint,
                  hintStyle: theme.bodyText.copyWith(color: theme.secondaryText, height: 1.0),
                ),
              ),
            ),
            SizedBox(width: theme.gapMd),
          ],
        ),
      ),
    );
  }

  /// Card bianca (bolla menu desktop): secondaryBackground, angoli card, ombra soft,
  /// clip.
  Widget _sideCard(BuildContext context, {required Widget child}) {
    final theme = CLTheme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        boxShadow: theme.cardShadowSoft,
      ),
      child: child,
    );
  }

  // ── Desktop ──────────────────────────────────────────────────────────────
  /// Menu in bolla FULL-HEIGHT a sinistra (logo in cima + nav), con padding esterno;
  /// a destra, in Column: header frosted (solo sopra il contenuto) · shell ·
  /// assistente. Il logo vive nel menu, non nell'header.
  Widget _buildSidebar(BuildContext context) {
    final theme = CLTheme.of(context);
    return ColoredBox(
      // Shell content bg = primaryBackground (uguale a header/footer strip).
      color: theme.primaryBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Menu in bolla full-height. Margine esterno Lg su tutti i lati.
          Padding(
            padding: const EdgeInsets.all(Sizes.gapLg),
            child: SizedBox(
              width: widget.config.sidebarWidth,
              child: _sideCard(
                context,
                child: _navPanel(theme, isCompact: false, frosted: true),
              ),
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
              padding: const EdgeInsets.all(Sizes.gapLg),
              child: SizedBox(
                width: widget.config.trailingWidth,
                child: _sideCard(context, child: widget.trailing!),
              ),
            ),
        ],
      ),
    );
  }

  // ── Tablet (rail icon-only) ────────────────────────────────────────────────
  /// Rail in bolla FULL-HEIGHT a sinistra (come la sidebar desktop) + header solo
  /// sopra il contenuto + body. Il drawer resta come overlay: aprendolo da una
  /// voce di gruppo della rail mostra il menu completo.
  Widget _buildRail(BuildContext context) {
    final theme = CLTheme.of(context);
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;
    return Scaffold(
      key: _scaffoldKey,
      // Shell content = page bg (#F6F5F4).
      backgroundColor: theme.primaryBackground,
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
          // Rail in bolla full-height. Margine esterno Lg su tutti i lati.
          Padding(
            padding: const EdgeInsets.all(Sizes.gapLg),
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
                      if (widget.trailing != null) SizedBox(width: widget.config.trailingWidth, child: widget.trailing!),
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

  // ── Mobile (drawer + bottom bar) ───────────────────────────────────────────
  /// Shell mobile: Column → header (striscia frosted) in alto, body in mezzo, barra
  /// contestuale/nav (bolla frosted) in basso. Niente stack/full-bleed: il body sta
  /// in flusso tra le barre → le pagine non devono insettare il contenuto.
  Widget _buildScaffold(BuildContext context, {required bool withBottomBar}) {
    final theme = CLTheme.of(context);
    final drawerWidth = MediaQuery.of(context).size.width * widget.config.drawerWidthFactor;

    return Scaffold(
      key: _scaffoldKey,
      // Shell content = page bg (#F6F5F4).
      backgroundColor: theme.primaryBackground,
      drawer: Drawer(
        width: drawerWidth,
        // Menu drawer = L0.
        backgroundColor: theme.primaryBackground,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(child: _navPanel(theme, isCompact: true)),
      ),
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

  /// Striscia header full-width (no bolla, no margine): sfondo primaryBackground
  /// solido, SafeArea top + padding Lg. Condivisa dai 3 viewport: il [child] cambia
  /// (mobile: hamburger+header; desktop/rail: header).
  Widget _headerStrip(BuildContext context, CLTheme theme, {required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.primaryBackground),
      child: SafeArea(
        bottom: false,
        child: Padding(padding: const EdgeInsets.all(Sizes.gapLg), child: child),
      ),
    );
  }

  /// Header mobile: striscia frosted con hamburger + header composto (titolo/
  /// ricerca/AI). Hamburger su secondaryBackground + ombra soft così "galleggia"
  /// sulla striscia (come la global search e il bottone AI).
  Widget _mobileHeaderStrip(BuildContext context, CLTheme theme) {
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
            CLIconButton(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              iconData: Icons.menu,
              backgroundColor: theme.secondaryBackground,
              boxShadow: theme.cardShadowSoft,
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
    );
  }

  /// Bottom bar in BOLLA: card (secondaryBackground + ombra soft) con margine esterno
  /// su sx/dx/bottom — niente top (flush col contenuto sopra) — e SafeArea bottom per
  /// l'home indicator. Dentro: area contestuale (azioni/controlli tabella) + nav,
  /// separate da un divider quando coesistono.
  Widget _mobileBottomStrip(BuildContext context, CLTheme theme, {required bool withBottomBar}) {
    return SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: _slots,
        builder: (context, _) {
          // Con azioni sopra → divider (indent Lg) le separa dalla nav; nav da
          // sola → niente divider. La nav tiene sempre top padding Lg
          // (`topBorder: true`) → respiro sotto il divider e quando è da sola.
          final hasContext = _hasContent(_slots.slots);
          return Padding(
            // Bolla bottom bar: margine esterno Lg su tutti i lati.
            padding: const EdgeInsets.all(Sizes.gapLg),
            child: _sideCard(
              context,
              child: Padding(
                // Padding interno Lg; gap Md tra gli elementi (context area · nav).
                padding: const EdgeInsets.all(Sizes.gapLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _mobileContextArea(context, frosted: true),
                    if (hasContext && withBottomBar) const SizedBox(height: Sizes.gapMd),
                    if (withBottomBar)
                      CLBottomBar(
                        destinations: widget.bottomDestinations ?? widget.destinations,
                        selectedKey: widget.selectedKey,
                        onSelect: _onSelect,
                        onOpenGroup: (_) => _scaffoldKey.currentState?.openDrawer(),
                        onOverflow: () => _scaffoldKey.currentState?.openDrawer(),
                        maxItems: widget.config.maxBottomBarItems,
                        topBorder: true,
                        floating: true,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
