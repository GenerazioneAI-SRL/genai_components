import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';
import 'package:genai_components/widgets/buttons/cl_button.widget.dart';
import 'package:genai_components/widgets/buttons/cl_soft_button.widget.dart';
import 'package:genai_components/widgets/dialogs/_dialog_chrome.dart';
import 'package:genai_components/widgets/cl_ai_assistant/flutter_ai_assistant.dart';

// ---------------------------------------------------------------------------
// Mode enum (private)
// ---------------------------------------------------------------------------

enum _CLAiAssistantMode { panel, drawer, trigger }

// ---------------------------------------------------------------------------
// CLAiAssistant
// ---------------------------------------------------------------------------

/// Reusable AI-assistant widget for the Skillera Design System.
///
/// Three named constructors cover all placement scenarios:
///
/// • [CLAiAssistant.panel]   — bare Column chat surface (desktop/tablet slot)
/// • [CLAiAssistant.drawer]  — Drawer-wrapped chat surface (mobile)
/// • [CLAiAssistant.trigger] — header button that opens the chat
class CLAiAssistant extends StatefulWidget {
  // ── shared ────────────────────────────────────────────────────────────────
  final _CLAiAssistantMode _mode;

  // ── panel / drawer ────────────────────────────────────────────────────────
  final VoidCallback? onClose;

  // ── trigger ───────────────────────────────────────────────────────────────
  final VoidCallback? onTap;
  final bool compact;
  final bool active;

  // ── panel constructor ─────────────────────────────────────────────────────

  /// Bare Column chat surface. Use inside a shell side-slot on desktop/tablet.
  /// [onClose] is called when the user taps the close (×) button.
  const CLAiAssistant.panel({
    super.key,
    this.onClose,
  })  : _mode = _CLAiAssistantMode.panel,
        onTap = null,
        compact = false,
        active = false;

  // ── drawer constructor ────────────────────────────────────────────────────

  /// Drawer-wrapped chat surface. Use as `endDrawer:` on mobile.
  /// [onClose] overrides the default `Navigator.of(context).pop()`.
  const CLAiAssistant.drawer({
    super.key,
    this.onClose,
  })  : _mode = _CLAiAssistantMode.drawer,
        onTap = null,
        compact = false,
        active = false;

  // ── trigger constructor ───────────────────────────────────────────────────

  /// Header AI button.
  ///
  /// [compact] `true` → mobile icon-only [CLIconButton].
  /// [compact] `false` → desktop pill [CLButton] with "Skillera Ai" label.
  /// [active] marks the panel as already open (kept in sync by the shell).
  /// Internal hover is tracked by the widget itself.
  const CLAiAssistant.trigger({
    super.key,
    required VoidCallback this.onTap,
    this.compact = false,
    this.active = false,
  })  : _mode = _CLAiAssistantMode.trigger,
        onClose = null;

  @override
  State<CLAiAssistant> createState() => _CLAiAssistantState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _CLAiAssistantState extends State<CLAiAssistant> {
  // ── chat state ─────────────────────────────────────────────────────────────
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  AiAssistantController? _controller;
  bool _prevWaitingForUserResponse = false;

  // Glass bars: header/footer fluttuano sopra la lista; misuro le loro altezze
  // per dare il padding giusto alla lista (i messaggi scorrono sotto il blur).
  final _headerKey = GlobalKey();
  final _footerKey = GlobalKey();
  double _headerH = 64;
  double _footerH = 72;

  void _measureBars() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final h = (_headerKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;
      final f = (_footerKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;
      if ((h != null && h != _headerH) || (f != null && f != _footerH)) {
        setState(() {
          if (h != null) _headerH = h;
          if (f != null) _footerH = f;
        });
      }
    });
  }

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget._mode == _CLAiAssistantMode.trigger) return;
    try {
      final ctrl = AiAssistant.read(context);
      if (_controller != ctrl) {
        _controller?.removeListener(_onControllerChanged);
        _controller = ctrl;
        _controller!.embedMode = true;
        _controller!.addListener(_onControllerChanged);
      }
      // Cambio scope (tenant) → reset + reload conversazioni del tenant corrente.
      _controller?.syncScope();
    } catch (_) {}
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final nowWaiting = _controller?.isWaitingForUserResponse ?? false;
    if (nowWaiting && !_prevWaitingForUserResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
      });
    }
    _prevWaitingForUserResponse = nowWaiting;
    // Lo scroll in fondo lo fa CLAiChatView (solo se l'utente è già in fondo).
    setState(() {});
  }

  void _handleClose(BuildContext context) {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showHistorySheet(BuildContext context) async {
    final controller = _controller;
    if (controller == null) return;
    // Mobile (<600): bottom sheet. Tablet/desktop (≥600): dialog centrato.
    final isCompact = MediaQuery.of(context).size.width < 600;
    if (isCompact) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => _HistorySheet(controller: controller),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (ctx) => _HistorySheet(controller: controller, asDialog: true),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (widget._mode) {
      case _CLAiAssistantMode.panel:
        return _buildPanel(context);
      case _CLAiAssistantMode.drawer:
        return _buildDrawer(context);
      case _CLAiAssistantMode.trigger:
        return _buildTrigger(context);
    }
  }

  // ── panel ──────────────────────────────────────────────────────────────────

  Widget _buildPanel(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _chatBody(context, theme, isDark);
  }

  // ── drawer ─────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Mobile (<600): full-bleed. Tablet (≥600): larghezza come il pannello
    // desktop (~380) invece di tutto schermo.
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = width >= 600 ? 380.0 : width;
    return Drawer(
      width: drawerWidth,
      backgroundColor: theme.secondaryBackground,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: _chatBody(context, theme, isDark),
    );
  }

  // ── shared body: messaggi scrollabili sotto header/footer glass ─────────────

  Widget _chatBody(BuildContext context, CLTheme theme, bool isDark) {
    _measureBars();
    return Stack(
      children: [
        // Lista messaggi: riempie tutto, padding = altezze barre così i messaggi
        // scorrono sotto il blur senza nascondersi.
        Positioned.fill(
          child: _chatMessages(context, theme, isDark, topInset: _headerH, bottomInset: _footerH),
        ),
        // Header glass (in alto).
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: KeyedSubtree(
            key: _headerKey,
            child: _glassBar(
              theme,
              top: true,
              child: SafeArea(bottom: false, child: _chatHeader(context, theme)),
            ),
          ),
        ),
        // Footer glass + input (in basso).
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: KeyedSubtree(
            key: _footerKey,
            child: _glassBar(
              theme,
              top: false,
              child: SafeArea(top: false, child: _chatInputBar(context, theme, isDark)),
            ),
          ),
        ),
      ],
    );
  }

  // Barra glass tipo header shell: blur + velo semi-trasparente + bordo token.
  Widget _glassBar(CLTheme theme, {required bool top, required Widget child}) {
    final Widget veil = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.secondaryBackground.withValues(alpha: 0.72),
        border: Border(
          top: top ? BorderSide.none : BorderSide(color: theme.borderColor),
          bottom: top ? BorderSide(color: theme.borderColor) : BorderSide.none,
        ),
      ),
      child: child,
    );
    // Blur pieno su tutte le piattaforme (web incluso): il bug di input dei
    // TextField era il SemanticsWalker (ensureSemantics permanente), non il
    // BackdropFilter — vedi cl_adaptive_shell._frostBlur.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: veil,
      ),
    );
  }

  // ── trigger ────────────────────────────────────────────────────────────────

  Widget _buildTrigger(BuildContext context) {
    final theme = CLTheme.of(context);
    // Gradiente brand: blu Skillera → viola. Applicato a icona (+ testo) via
    // ShaderMask (figli in bianco → colorati dal gradiente).
    final gradient = LinearGradient(colors: [theme.primary, theme.accentPurple]);
    Widget gradientMask(Widget child) => ShaderMask(
          shaderCallback: (b) => gradient.createShader(Offset.zero & b.size),
          blendMode: BlendMode.srcIn,
          child: child,
        );

    if (widget.compact) {
      // Tablet: bianca + ombra, solo icona gradiente.
      return GestureDetector(
        onTap: widget.onTap!,
        child: Tooltip(
          message: 'Skillera Ai',
          child: Container(
            width: theme.buttonHeightDefault,
            height: theme.buttonHeightDefault,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              shape: BoxShape.circle,
              boxShadow: theme.cardShadowSoft,
            ),
            child: gradientMask(
              const Icon(LucideIcons.sparkle300, color: Colors.white, size: Sizes.iconSizeDefault),
            ),
          ),
        ),
      );
    }

    // Desktop: bianca + ombra, icona + testo gradiente.
    return GestureDetector(
      onTap: widget.onTap!,
      child: Container(
        height: theme.buttonHeightDefault,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusPill),
          boxShadow: theme.cardShadowSoft,
        ),
        child: gradientMask(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkle300, color: Colors.white, size: Sizes.iconSizeDefault),
              const SizedBox(width: Sizes.gapSm),
              Text('Skillera Ai', style: theme.bodyLabel.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── shared chat body: header ───────────────────────────────────────────────

  // Titolo conversazione = primo messaggio utente (troncato), come skillera_test.
  // Vuota → "Nuova conversazione".
  String _conversationTitle() {
    final msgs = _controller?.messages ?? const [];
    for (final m in msgs) {
      if (m.role == AiMessageRole.user) {
        final t = m.content.trim().replaceAll('\n', ' ');
        if (t.isEmpty) continue;
        return t.length > 32 ? '${t.substring(0, 32)}…' : t;
      }
    }
    return 'Nuova conversazione';
  }

  Widget _chatHeader(BuildContext context, CLTheme theme) {
    final isProcessing = _controller?.isProcessing ?? false;
    // Selettore chat sul titolo: chevron + tap → elenco conversazioni (dove vive
    // anche l'eliminazione). Solo con persistenza attiva.
    final hasStore = _controller?.config.conversationStore != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.gapLg,
        vertical: Sizes.gapLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: hasStore
                  ? CLSoftButton.primary(
                      text: _conversationTitle(),
                      onTap: () => _showHistorySheet(context),
                      context: context,
                      icon: LucideIcons.chevronDown,
                      iconAlignment: IconAlignment.end,
                      isCompact: true,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.gapSm),
                      child: Text(
                        _conversationTitle(),
                        style: theme.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
          ),
          if (isProcessing) ...[
            const SizedBox(width: Sizes.gapSm),
            SizedBox(
              width: Sizes.iconSizeCompact,
              height: Sizes.iconSizeCompact,
              child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
            ),
          ],
          const SizedBox(width: Sizes.gapSm),
          CLIconButton(
            iconData: LucideIcons.x,
            backgroundColor: theme.muted,
            iconColor: theme.secondaryText,
            borderRadius: theme.radiusPill,
            tooltip: 'Chiudi',
            onTap: () => _handleClose(context),
          ),
        ],
      ),
    );
  }

  // ── shared chat body: messages list (CLAiChatView senza composer) ─────────

  Widget _chatMessages(BuildContext context, CLTheme theme, bool isDark,
      {double topInset = 0, double bottomInset = 0}) {
    final controller = _controller;
    final rawName = controller?.config.userNameProvider?.call()?.trim();
    final hasName = rawName != null && rawName.isNotEmpty;
    return CLAiChatView(
      showComposer: false,
      padding: EdgeInsets.fromLTRB(theme.gapLg, topInset + theme.gapSm, theme.gapLg, bottomInset + theme.gapSm),
      messages: [
        for (final m in controller?.messages ?? const <AiChatMessage>[])
          CLAiChatMessage(
            id: m.id,
            role: m.role == AiMessageRole.user
                ? MessageRole.user
                : m.role == AiMessageRole.system
                    ? MessageRole.system
                    : MessageRole.assistant,
            text: m.content,
            markdown: m.role != AiMessageRole.user,
            createdAt: m.timestamp,
          ),
      ],
      isThinking: (controller?.isProcessing ?? false) && !(controller?.isWaitingForUserResponse ?? false),
      thinkingLabel: controller?.progressText ?? 'Sto elaborando...',
      emptyTitle: hasName ? 'Ciao $rawName' : 'Ciao',
      suggestions: [
        for (final chip in controller?.config.initialSuggestions ?? const <AiSuggestionChip>[])
          CLAiChatSuggestion(label: chip.label, message: chip.message, icon: chip.icon),
      ],
      onSuggestionTap: (s) {
        controller?.sendSuggestion(s.label, s.text);
        setState(() {});
      },
    );
  }

  // ── shared chat body: input bar (CLAiChatComposer) ────────────────────────

  Widget _chatInputBar(BuildContext context, CLTheme theme, bool isDark) {
    final isProcessing = _controller?.isProcessing ?? false;
    final isWaiting = _controller?.isWaitingForUserResponse ?? false;
    return CLAiChatComposer(
      controller: _textController,
      focusNode: _focusNode,
      enabled: !isProcessing || isWaiting,
      busy: isProcessing && !isWaiting,
      onStop: () => _controller?.requestStop(),
      onSend: _controller == null ? null : (text) => _controller!.sendMessage(text),
      hintText: isWaiting
          ? 'Rispondi...'
          : isProcessing
              ? 'Attendi la risposta...'
              : 'Scrivi un messaggio...',
      // Informativa privacy Skillera AI.
      footer: Text(
        'Skillera AI opera nel rispetto dei tuoi permessi e del GDPR. Verifica sempre le risposte.',
        style: theme.smallLabel.copyWith(color: theme.secondaryText),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Storico conversazioni (carica / elimina / nuova). Bottom sheet su mobile,
/// dialog su tablet/desktop ([asDialog] = true).
class _HistorySheet extends StatefulWidget {
  const _HistorySheet({required this.controller, this.asDialog = false});
  final AiAssistantController controller;
  final bool asDialog;

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  late Future<List<AiConversationSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.listConversations();
  }

  void _reload() {
    final f = widget.controller.listConversations();
    setState(() => _future = f);
  }

  Widget _newButton(BuildContext context) => CLSoftButton.primary(
        text: 'Nuova',
        context: context,
        isCompact: true,
        onTap: () {
          widget.controller.newConversation();
          Navigator.of(context).pop();
        },
      );

  Widget _convList(BuildContext context, CLTheme theme) {
    return FutureBuilder<List<AiConversationSummary>>(
      future: _future,
      builder: (ctx, snap) => CLAiConversationList(
        shrinkWrap: true,
        loading: snap.connectionState != ConnectionState.done,
        items: [
          for (final conv in snap.data ?? const <AiConversationSummary>[])
            CLAiConversationItem(id: conv.id, title: conv.title, updatedAt: conv.updatedAt),
        ],
        onDelete: (id) async {
          await widget.controller.deleteConversation(id);
          _reload();
        },
        onSelect: (id) async {
          await widget.controller.loadConversation(id);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.7;

    // Tablet/desktop: chrome dialog standard (DialogShell + DialogHeader).
    if (widget.asDialog) {
      return DialogShell(
        maxWidth: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // X in alto a destra, sopra tutto.
            Padding(
              padding: EdgeInsets.fromLTRB(theme.gap2Xl, theme.gapLg, theme.gapLg, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: CLIconButton(
                  iconData: LucideIcons.x,
                  backgroundColor: theme.muted,
                  iconColor: theme.secondaryText,
                  borderRadius: theme.radiusPill,
                  tooltip: 'Chiudi',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            // Titolo + Nuova, una riga sotto.
            Padding(
              padding: EdgeInsets.fromLTRB(theme.gap2Xl, theme.gapLg, theme.gap2Xl, theme.gapLg),
              child: Row(
                children: [
                  Expanded(child: Text('Conversazioni', style: theme.title.copyWith(fontWeight: FontWeight.w600))),
                  _newButton(context),
                ],
              ),
            ),
            Flexible(
                child: ConstrainedBox(constraints: BoxConstraints(maxHeight: maxH), child: _convList(context, theme))),
            SizedBox(height: theme.gapLg),
          ],
        ),
      );
    }

    // Mobile: bottom sheet con drag handle.
    return SafeArea(
      top: false,
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusSurface)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Sizes.gapMd),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: theme.borderColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sizes.gapLg, Sizes.gapMd, Sizes.gapLg, Sizes.gapSm),
                child: Row(
                  children: [
                    Expanded(child: Text('Conversazioni', style: theme.title.copyWith(fontWeight: FontWeight.w600))),
                    _newButton(context),
                  ],
                ),
              ),
              Flexible(child: _convList(context, theme)),
              const SizedBox(height: Sizes.gapMd),
            ],
          ),
        ),
      ),
    );
  }
}
