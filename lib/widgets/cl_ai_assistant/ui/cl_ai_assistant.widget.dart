import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  AiAssistantController? _controller;
  bool _prevWaitingForUserResponse = false;
  bool _inputFocused = false;

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
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (_focusNode.hasFocus != _inputFocused) {
      setState(() => _inputFocused = _focusNode.hasFocus);
    }
  }

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
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty || _controller == null) return;
    _textController.clear();
    _controller!.sendMessage(text);
    _focusNode.requestFocus();
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
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _scrollController.dispose();
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.secondaryBackground.withValues(alpha: 0.72),
            border: Border(
              top: top ? BorderSide.none : BorderSide(color: theme.borderColor),
              bottom: top ? BorderSide(color: theme.borderColor) : BorderSide.none,
            ),
          ),
          child: child,
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg, vertical: Sizes.gapSm),
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
              Text('Skillera Ai',
                  style: theme.bodyLabel.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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

  // ── shared chat body: messages list ───────────────────────────────────────

  // ── empty state: saluto gradiente + chip ancorate in basso ────────────────

  Widget _emptyState(BuildContext context, CLTheme theme, {required double topInset, required double bottomInset}) {
    final gradient = LinearGradient(colors: [theme.primary, theme.accentPurple]);
    final rawName = _controller?.config.userNameProvider?.call()?.trim();
    final hasName = rawName != null && rawName.isNotEmpty;
    final suggestions = _controller?.config.initialSuggestions ?? const [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final padTop = topInset + Sizes.gap2Xl;
        final padBottom = bottomInset + Sizes.padding;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(Sizes.gap2Xl, padTop, Sizes.gap2Xl, padBottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - padTop - padBottom),
            child: Column(
              // Tutto ancorato in basso: saluto subito sopra le chip rapide.
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => gradient.createShader(Offset.zero & b.size),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        hasName ? 'Ciao $rawName' : 'Ciao',
                        style: theme.heading2.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: Sizes.gapXs),
                    Text(
                      'Come posso aiutarti oggi?',
                      style: theme.heading2.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: Sizes.gapLg),
                  Wrap(
                    spacing: Sizes.gapSm,
                    runSpacing: Sizes.gapSm,
                    children: [
                      for (final chip in suggestions)
                        CLSoftButton.primary(
                          text: chip.label,
                          icon: chip.icon,
                          context: context,
                          borderRadius: theme.radiusPill,
                          onTap: () {
                            _controller!.sendSuggestion(chip.label, chip.message);
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatMessages(BuildContext context, CLTheme theme, bool isDark,
      {double topInset = 0, double bottomInset = 0}) {
    final messages = _controller?.messages ?? [];

    if (messages.isEmpty) {
      return _emptyState(context, theme, topInset: topInset, bottomInset: bottomInset);
    }

    final showTyping =
        _controller!.isProcessing && !_controller!.isWaitingForUserResponse;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        Sizes.padding,
        topInset + Sizes.padding / 2,
        Sizes.padding,
        bottomInset + Sizes.padding / 2,
      ),
      itemCount: messages.length + (showTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _chatTypingIndicator(theme);
        }
        final msg = messages[index];
        final isUser = msg.role == AiMessageRole.user;
        return Padding(
          padding: const EdgeInsets.only(bottom: Sizes.gapMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(Sizes.radiusControl),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: Sizes.iconSizeCompact,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: Sizes.gapSm),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.gapMd + 2,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.primary
                            .withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark
                            ? theme.primaryBackground
                            : theme.primaryBackground
                                .withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(Sizes.gap2Xl / 1.5),
                      topRight: const Radius.circular(Sizes.gap2Xl / 1.5),
                      bottomLeft: Radius.circular(isUser ? Sizes.gap2Xl / 1.5 : 4),
                      bottomRight:
                          Radius.circular(isUser ? 4 : Sizes.gap2Xl / 1.5),
                    ),
                    border: Border.all(
                      color: theme.borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SelectableText(
                    msg.content,
                    style: theme.bodyText.copyWith(
                      fontSize: 13.5,
                      height: 1.45,
                      color: theme.primaryText,
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: Sizes.gapSm),
            ],
          ),
        );
      },
    );
  }

  // ── shared chat body: typing indicator ────────────────────────────────────

  Widget _chatTypingIndicator(CLTheme theme) {
    final progressText = _controller?.progressText;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.gapMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Sizes.radiusControl),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: Sizes.iconSizeCompact,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: Sizes.gapSm),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.gapMd + 2,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: theme.borderColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: Sizes.iconSizeCompact,
                    height: Sizes.iconSizeCompact,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      progressText ?? 'Sto elaborando...',
                      style: theme.bodyLabel.copyWith(
                        color: theme.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── shared chat body: input bar ────────────────────────────────────────────

  Widget _chatInputBar(BuildContext context, CLTheme theme, bool isDark) {
    final isProcessing = _controller?.isProcessing ?? false;
    final isWaiting = _controller?.isWaitingForUserResponse ?? false;
    final canType = !isProcessing || isWaiting;
    final showStop = isProcessing && !isWaiting;

    final canSend = _textController.text.trim().isNotEmpty && canType;

    return Padding(
      padding: const EdgeInsets.all(Sizes.padding * 0.75),
      // Text area sopra, tasto invio FUORI dal box, in basso a destra.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text area custom: focus = ring 1px gradiente blu/viola, no glow.
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: _inputFocused
                  ? LinearGradient(colors: [theme.primary, theme.accentPurple])
                  : null,
              color: _inputFocused ? null : theme.borderColor,
              borderRadius: BorderRadius.circular(theme.radiusModal),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg, vertical: Sizes.gapMd),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(theme.radiusModal - 1),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: canType,
                minLines: 2,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => setState(() {}),
                style: theme.bodyText.copyWith(fontSize: 13.5),
                cursorColor: theme.primary,
                decoration: InputDecoration(
                  hintText: isWaiting
                      ? 'Rispondi...'
                      : isProcessing
                          ? 'Attendi la risposta...'
                          : 'Scrivi un messaggio...',
                  hintStyle: theme.bodyLabel.copyWith(color: theme.secondaryText, fontSize: 13.5),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: Sizes.gapSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: showStop
                    ? theme.secondaryText.withValues(alpha: 0.3)
                    : (canSend ? theme.primary : theme.primary.withValues(alpha: 0.4)),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: showStop ? () => _controller?.requestStop() : (canSend ? _send : null),
                  child: SizedBox(
                    width: Sizes.buttonHeightDefault,
                    height: Sizes.buttonHeightDefault,
                    child: Center(
                      child: Icon(
                        showStop ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: Sizes.iconSizeDefault,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sizes.gapSm),
          // Informativa privacy Skillera AI.
          Text.rich(
            TextSpan(
              style: theme.smallLabel.copyWith(color: theme.secondaryText),
              children: const [
                TextSpan(
                  text: 'Skillera AI opera nel rispetto dei tuoi permessi e del GDPR. '
                      'Verifica sempre le risposte.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  String _relative(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'oggi';
    final diff = now.difference(d).inDays;
    if (diff <= 1) return 'ieri';
    if (diff < 7) return '${diff}g fa';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
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
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(Sizes.padding),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snap.data ?? const [];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(Sizes.padding),
            child: Text('Nessuna conversazione salvata',
                style: theme.bodyLabel.copyWith(color: theme.secondaryText)),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: theme.borderColor),
          itemBuilder: (c, i) {
            final conv = items[i];
            return ListTile(
              title: Text(conv.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyText),
              subtitle: Text(_relative(conv.updatedAt),
                  style: theme.smallLabel.copyWith(color: theme.secondaryText)),
              trailing: IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: theme.secondaryText, size: 18),
                tooltip: 'Elimina',
                onPressed: () async {
                  await widget.controller.deleteConversation(conv.id);
                  _reload();
                },
              ),
              onTap: () async {
                await widget.controller.loadConversation(conv.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            );
          },
        );
      },
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
            Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxHeight: maxH), child: _convList(context, theme))),
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
