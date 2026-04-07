import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:genai_components/widgets/cl_ai_assistant/flutter_ai_assistant.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import 'constants/sizes.constant.dart';

/// Chat drawer per l'Assistente AI in stile "bolla glass",
/// coerente con il menu e l'header dell'app.
class AiChatDrawer extends StatefulWidget {
  const AiChatDrawer({super.key});

  @override
  State<AiChatDrawer> createState() => _AiChatDrawerState();
}

class _AiChatDrawerState extends State<AiChatDrawer> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  AiAssistantController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final ctrl = AiAssistant.read(context);
      if (_controller != ctrl) {
        _controller?.removeListener(_onControllerChanged);
        _controller = ctrl;
        _controller!.addListener(_onControllerChanged);
      }
    } catch (_) {}
  }

  void _onControllerChanged() {
    if (!mounted) return;
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

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = width > 600 ? 380.0 : width * 0.85;
    final p = Sizes.padding;

    // Usiamo un Drawer con sfondo trasparente: il contenuto vero è
    // la "bolla" glass con padding dal bordo.
    return Drawer(
      width: drawerWidth + p,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: p, bottom: p, right: p),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: drawerWidth,
                decoration: BoxDecoration(
                  color: isDark ? theme.primaryBackground.withValues(alpha: 0.85) : theme.secondaryBackground.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(Sizes.borderRadius * 1.5),
                  border: Border.all(color: theme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(theme),
                    Expanded(child: _buildMessages(theme, isDark)),
                    _buildInput(theme, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CLTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.padding,
        vertical: Sizes.padding * 0.75,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAiChat02,
              color: theme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistente AI',
                  style: theme.title.copyWith(fontSize: 15),
                ),
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
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(CLTheme theme, bool isDark) {
    final messages = _controller?.messages ?? [];

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.padding * 2),
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
              const SizedBox(height: 8),
              Text(
                'Chiedimi di navigare, trovare informazioni o eseguire azioni nell\'app.',
                style: theme.bodyLabel.copyWith(color: theme.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.padding,
        vertical: Sizes.padding / 2,
      ),
      itemCount: messages.length + (_controller!.isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildTypingIndicator(theme);
        }

        final msg = messages[index];
        final isUser = msg.role == AiMessageRole.user;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, size: 16, color: theme.primary),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark ? theme.primaryBackground : theme.primaryBackground.withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
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
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(CLTheme theme) {
    final progressText = _controller?.progressText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome, size: 16, color: theme.primary),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    width: 16,
                    height: 16,
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

  Widget _buildInput(CLTheme theme, bool isDark) {
    final isProcessing = _controller?.isProcessing ?? false;

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
                color: isDark ? theme.primaryBackground : theme.primaryBackground.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.borderColor.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: !isProcessing,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: theme.bodyText.copyWith(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: isProcessing ? 'Attendi la risposta...' : 'Scrivi un messaggio...',
                  hintStyle: theme.bodyLabel.copyWith(
                    color: theme.secondaryText,
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: isProcessing ? theme.secondaryText.withValues(alpha: 0.3) : theme.primary,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isProcessing ? () => _controller?.requestStop() : _send,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  isProcessing ? Icons.stop_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
