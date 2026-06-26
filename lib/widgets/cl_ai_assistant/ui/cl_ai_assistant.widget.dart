import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';
import 'package:genai_components/widgets/buttons/cl_button.widget.dart';
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

  // ── trigger hover state ────────────────────────────────────────────────────
  bool _aiHovered = false;

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

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
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
    return Column(
      children: [
        _chatHeader(context, theme),
        Expanded(child: _chatMessages(context, theme, isDark)),
        _chatInputBar(context, theme, isDark),
      ],
    );
  }

  // ── drawer ─────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = width > 600 ? 380.0 : width * 0.85;
    return Drawer(
      width: drawerWidth,
      backgroundColor: theme.secondaryBackground,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            _chatHeader(context, theme),
            Expanded(child: _chatMessages(context, theme, isDark)),
            _chatInputBar(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  // ── trigger ────────────────────────────────────────────────────────────────

  Widget _buildTrigger(BuildContext context) {
    final theme = CLTheme.of(context);
    if (widget.compact) {
      // Mobile: icon-only button
      return CLIconButton(
        onTap: widget.onTap!,
        iconData: LucideIcons.sparkle300,
        backgroundColor: theme.secondaryBackground,
        boxShadow: theme.cardShadowSoft,
        border: Border.all(color: theme.primary, width: 1),
        iconColor: theme.primary,
        size: theme.buttonHeightDefault,
        iconSize: Sizes.iconSizeDefault,
        tooltip: 'Skillera Ai',
      );
    }
    // Desktop: pill button with hover highlight
    final highlight = _aiHovered || widget.active;
    return MouseRegion(
      onEnter: (_) => setState(() => _aiHovered = true),
      onExit: (_) => setState(() => _aiHovered = false),
      child: CLButton(
        context: context,
        border: Border.all(color: theme.primary, width: 1),
        boxShadow: theme.cardShadowSoft,
        onTap: widget.onTap!,
        iconData: LucideIcons.sparkle300,
        textStyle: theme.bodyLabel.override(
          fontWeight: FontWeight.w500,
          color: highlight ? Colors.white : theme.primary,
        ),
        backgroundColor: highlight ? theme.primary : theme.secondaryBackground,
        iconColor: highlight ? Colors.white : theme.primary,
        iconSize: Sizes.iconSizeDefault,
        borderRadius: theme.radiusPill,
        iconAlignment: IconAlignment.start,
        text: 'Skillera Ai',
      ),
    );
  }

  // ── shared chat body: header ───────────────────────────────────────────────

  Widget _chatHeader(BuildContext context, CLTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.gapLg,
        vertical: Sizes.gapLg,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.gapSm),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: theme.opacitySoft),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAiChat02,
              color: theme.primary,
              size: Sizes.iconSizeCompact,
            ),
          ),
          const SizedBox(width: Sizes.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistente AI', style: theme.title),
                if (_controller != null && _controller!.isProcessing)
                  Text(
                    'Sta pensando...',
                    style: theme.smallLabel.copyWith(color: theme.primary),
                  )
                else
                  Text('Chiedimi qualcosa', style: theme.smallLabel),
              ],
            ),
          ),
          if (_controller != null && _controller!.messages.isNotEmpty)
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: theme.secondaryText,
                size: 18,
              ),
              tooltip: 'Cancella conversazione',
              onPressed: () {
                _controller!.clearConversation();
                setState(() {});
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              color: theme.secondaryText,
              size: 18,
            ),
            onPressed: () => _handleClose(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  // ── shared chat body: messages list ───────────────────────────────────────

  Widget _chatMessages(BuildContext context, CLTheme theme, bool isDark) {
    final messages = _controller?.messages ?? [];

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.gap3Xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAiChat02,
                color: theme.secondaryText.withValues(alpha: 0.4),
                size: 48,
              ),
              const SizedBox(height: Sizes.padding),
              Text(
                'Assistente AI',
                style: theme.heading6.copyWith(color: theme.secondaryText),
              ),
              const SizedBox(height: Sizes.gapSm),
              Text(
                "Chiedimi di navigare, trovare informazioni o eseguire azioni nell'app.",
                style: theme.bodyLabel.copyWith(color: theme.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final showTyping =
        _controller!.isProcessing && !_controller!.isWaitingForUserResponse;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.padding,
        vertical: Sizes.padding / 2,
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

    return Container(
      padding: const EdgeInsets.all(Sizes.padding * 0.75),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.primaryBackground
                    : theme.primaryBackground.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(Sizes.radiusModal),
                border: Border.all(
                  color: theme.borderColor.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: canType,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: theme.bodyText.copyWith(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: isWaiting
                      ? 'Rispondi...'
                      : isProcessing
                          ? 'Attendi la risposta...'
                          : 'Scrivi un messaggio...',
                  hintStyle: theme.bodyLabel.copyWith(
                    color: theme.secondaryText,
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Sizes.gapLg,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: Sizes.gapSm),
          Material(
            color: showStop
                ? theme.secondaryText.withValues(alpha: 0.3)
                : theme.primary,
            borderRadius: BorderRadius.circular(Sizes.radiusModal - 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(Sizes.radiusModal - 4),
              onTap: showStop ? () => _controller?.requestStop() : _send,
              child: Container(
                width: Sizes.buttonHeightDefault,
                height: Sizes.buttonHeightDefault,
                alignment: Alignment.center,
                child: Icon(
                  showStop ? Icons.stop_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: Sizes.iconSizeDefault,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
