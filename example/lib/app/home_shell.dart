import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _publishNav());
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

  @override
  Widget build(BuildContext context) {
    return GenAdaptiveShell(
      config: const GenShellConfig(bubbleBody: true, resizableNavHeader: true),
      slotsController: _slots,
      destinations: [
        for (final s in showcaseSections) GenDestination(key: s.path, label: s.label, icon: s.icon),
        GenDestination(key: _usersDest.path, label: _usersDest.label, icon: _usersDest.icon),
      ],
      selectedKey: _selectedKey,
      onSelect: (d) => context.go(d.key),
      navHeader: const NavHeader(),
      // Voci cliente in slot dedicato: con resizableNavHeader diventano la parte
      // scrollabile del pannello header (azienda pinnata sopra).
      navSecondary: const ClientContextMenu(),
      navFooter: const NavFooter(),
      railHeader: const NavHeaderRail(),
      railFooter: const NavFooterRail(),
      header: AppHeader(onToggleAi: _toggleAi),
      // Bolla assistente AI accanto al body (solo desktop bubble). Aperta/chiusa
      // dal pulsante AI dell'header; stato/messaggi posseduti qui (demo echo).
      trailing: _aiOpen
          ? GenAiAssistant(
              messages: _messages,
              onSend: _onSendAi,
              isProcessing: _aiProcessing,
              onClose: _toggleAi,
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
            )
          : null,
      body: widget.child,
    );
  }
}
