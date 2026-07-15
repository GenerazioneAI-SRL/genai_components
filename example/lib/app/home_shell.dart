import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import 'package:go_router/go_router.dart';

import '../modules/users/constants/users_routes.dart';
import '../shell/app_header.dart';
import '../shell/nav_slots.dart';
import 'sections.dart';

/// Shell adattivo dell'app. È il builder della ShellRoute: riceve la `location`
/// corrente e il `child` (pagina della route), costruisce la sidebar dai
/// [showcaseSections] + la voce modulo Users, e naviga con `context.go(path)`.
/// Pubblica breadcrumb/back sul canale nav dello shell in base alla location.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.location,
    required this.child,
    this.detailTitle,
  });

  final String location;
  final Widget child;

  /// Nome del record per il breadcrumb del dettaglio (passato via GoRouter extra).
  final String? detailTitle;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _slots = ShellSlotsController();

  /// Voce sidebar del modulo "esempio" Users (route proprie fuori dallo showcase).
  static const _usersDest = (path: UsersRoutes.listPath, label: 'Utenti', icon: Icons.table_rows);

  /// Path showcase raccolti sotto il gruppo demo "Overlays" (per mostrare i
  /// dropdown: inline in sidebar desktop, flyout GenContextMenu nel rail).
  static const _overlayPaths = {'/dialog', '/sheet', '/popover', '/context-menu', '/menubar'};

  /// Albero destinazioni: le voci flat dello showcase, ma con gli overlay
  /// raccolti in un gruppo (con un sotto-gruppo annidato "Menu avanzati" per
  /// dimostrare i submenu del flyout). Solo l'albero della sidebar cambia: route
  /// e breadcrumb restano su [showcaseSections].
  List<GenDestination> _destinations() {
    GenDestination leaf(String path) {
      final s = showcaseSections.firstWhere((s) => s.path == path);
      return GenDestination(key: s.path, label: s.label, icon: s.icon);
    }

    final overlays = GenDestination(
      key: '/overlays',
      label: 'Overlays',
      icon: Icons.layers_outlined,
      children: [
        leaf('/dialog'),
        leaf('/sheet'),
        leaf('/popover'),
        GenDestination(
          key: '/overlays/menu',
          label: 'Menu avanzati',
          icon: Icons.menu_open,
          children: [leaf('/context-menu'), leaf('/menubar')],
        ),
      ],
    );

    final out = <GenDestination>[];
    var groupInserted = false;
    for (final s in showcaseSections) {
      if (_overlayPaths.contains(s.path)) {
        if (!groupInserted) {
          out.add(overlays); // il gruppo prende il posto del primo overlay
          groupInserted = true;
        }
        continue;
      }
      out.add(GenDestination(key: s.path, label: s.label, icon: s.icon));
    }
    out.add(GenDestination(key: _usersDest.path, label: _usersDest.label, icon: _usersDest.icon));
    return out;
  }

  /// Palette ricerca globale aperta → evita di impilarne un'altra su ⌘K ripetuto.
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _publishNav());
    // ⌘K (macOS) / Ctrl+K (win/linux): apre la ricerca globale. Handler globale
    // su HardwareKeyboard → funziona indipendentemente dal focus corrente.
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
  }

  bool _onGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isK = event.logicalKey == LogicalKeyboardKey.keyK;
    final hasMod = HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed;
    if (!isK || !hasMod || _searchOpen) return false;
    _searchOpen = true;
    openGlobalSearch(context, onAskAi: _slots.openAi).whenComplete(() => _searchOpen = false);
    return true; // consumato
  }

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location || oldWidget.detailTitle != widget.detailTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _publishNav());
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _slots.dispose();
    super.dispose();
  }

  // ── Assistente AI (bolla trailing, stato UI demo) ───────────────────────────
  bool _aiOpen = false;
  bool _aiProcessing = false;
  final List<GenChatMessage> _messages = [];
  final List<GenChatConversation> _conversations = [
    const GenChatConversation(id: 'c1', title: 'Riepilogo presenze', subtitle: 'Ieri'),
    const GenChatConversation(id: 'c2', title: 'Bozza email cliente', subtitle: '2 giorni fa'),
  ];

  String? _convTitle;

  void _toggleAi() => setState(() => _aiOpen = !_aiOpen);

  void _newChat() => setState(() {
        _messages.clear();
        _convTitle = null;
      });

  void _openConv(String id) => setState(() {
        _messages.clear();
        _convTitle = _conversations.firstWhere((c) => c.id == id).title;
      });

  /// Echo demo: aggiunge il messaggio utente + una risposta finta dopo un delay.
  void _onSendAi(String text) {
    setState(() {
      _messages.add(GenChatMessage(role: GenChatRole.user, content: text));
      _aiProcessing = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(GenChatMessage(role: GenChatRole.assistant, content: 'Ho ricevuto: "$text" (risposta demo).'));
        _aiProcessing = false;
      });
    });
  }

  bool get _isUsers => widget.location.startsWith(UsersRoutes.listPath);
  bool get _isUserDetail => _isUsers && widget.location != UsersRoutes.listPath;

  /// Chiave della destination selezionata: le sotto-rotte Users mappano sulla
  /// voce '/users'; le showcase sulla propria path.
  String get _selectedKey => _isUsers ? UsersRoutes.listPath : widget.location;

  /// Pubblica breadcrumb (+ back sul dettaglio) sul canale nav dello shell.
  void _publishNav() {
    if (!mounted) return;
    final crumbs = <ShellCrumb>[ShellCrumb('Home', onTap: () => context.go(showcaseSections.first.path))];
    ShellBack? back;
    if (_isUserDetail) {
      crumbs
        ..add(ShellCrumb('Utenti', onTap: () => context.go(UsersRoutes.listPath)))
        ..add(ShellCrumb(widget.detailTitle ?? 'Dettaglio'));
      back = ShellBack(onTap: () => context.go(UsersRoutes.listPath), tooltip: 'Torna agli utenti');
    } else if (_isUsers) {
      crumbs.add(const ShellCrumb('Utenti'));
    } else {
      final s = showcaseSections.firstWhere((s) => s.path == widget.location, orElse: () => showcaseSections.first);
      crumbs.add(ShellCrumb(s.label));
    }
    _slots.setNav(back: back, breadcrumbs: crumbs);
  }

  /// Assistente AI (demo echo). Riusato in due contenitori: bolla `trailing`
  /// (desktop/tablet) ed `endDrawer` (mobile). [onClose] chiude il contenitore.
  Widget _aiAssistant({required VoidCallback onClose}) => GenAiAssistant(
        messages: _messages,
        onSend: _onSendAi,
        isProcessing: _aiProcessing,
        onClose: onClose,
        onNewChat: _newChat,
        conversationTitle: _convTitle,
        conversations: _conversations,
        onOpenConversation: _openConv,
        onDeleteConversation: (id) => setState(() => _conversations.removeWhere((c) => c.id == id)),
        greetingName: 'Davide',
        suggestions: const [
          GenChatSuggestion(icon: LucideIcons.fileText, label: 'Riepilogo', message: 'Fammi un riepilogo.'),
          GenChatSuggestion(icon: LucideIcons.listChecks, label: 'To-do', message: 'Crea una to-do list.'),
          GenChatSuggestion(icon: LucideIcons.sparkles, label: 'Idee', message: 'Dammi 3 idee.'),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return GenAdaptiveShell(
      config: const GenShellConfig(bubbleBody: true, resizableNavHeader: true),
      slotsController: _slots,
      destinations: _destinations(),
      selectedKey: _selectedKey,
      onSelect: (d) => context.go(d.key),
      navHeader: const NavHeader(),
      // Voci cliente in slot dedicato: con resizableNavHeader diventano la parte
      // scrollabile del pannello header (azienda pinnata sopra).
      navSecondary: const ClientContextMenu(),
      navFooter: const NavFooter(),
      railHeader: const NavHeaderRail(),
      // Voci cliente icon-only nel rail: con resizableNavHeader la bolla header
      // si allunga con queste icone (scroll + drag) anche su tablet.
      railSecondary: const ClientContextMenuRail(),
      railFooter: const NavFooterRail(),
      header: AppHeader(onToggleAi: _toggleAi),
      // Mobile: azioni globali nella bottom bar → [Menu · AI (centrale, gradient
      // brand) · Cerca]. Menu apre il drawer nav, AI l'endDrawer, Cerca la palette.
      bottomBarItems: [
        GenBottomBarItem(icon: LucideIcons.menu, label: 'Menu', onTap: _slots.openMenu),
        GenBottomBarItem(
          icon: LucideIcons.sparkles,
          label: 'AI',
          onTap: _slots.openAi,
          iconGradient: LinearGradient(colors: [t.primary, const Color(0xFF4F46E5)]),
        ),
        GenBottomBarItem(
          icon: LucideIcons.search,
          label: 'Cerca',
          onTap: () => openGlobalSearch(context, onAskAi: _slots.openAi),
        ),
      ],
      // AI su mobile: endDrawer (pannello da destra), aperto da slots.openAi().
      // Builder per prendere il context sotto lo Scaffold e chiudere l'endDrawer.
      // Superficie opaca sotto l'assistente (endDrawer mobile): senza, lo Stack
      // dell'AI è trasparente e il body sottostante traspare. Su desktop il bg lo
      // dà `_sideCard`; qui lo diamo noi.
      endDrawer: Builder(
        builder: (ctx) => Material(
          color: GenTokens.of(ctx).secondaryBackground,
          child: SafeArea(child: _aiAssistant(onClose: () => Scaffold.of(ctx).closeEndDrawer())),
        ),
      ),
      // Bolla assistente AI accanto al body (desktop/tablet bubble). Aperta/chiusa
      // dal pulsante AI dell'header; stato/messaggi posseduti qui (demo echo).
      trailing: _aiOpen ? _aiAssistant(onClose: _toggleAi) : null,
      body: widget.child,
    );
  }
}
