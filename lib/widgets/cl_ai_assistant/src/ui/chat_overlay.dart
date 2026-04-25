import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/ai_assistant_controller.dart';
import 'action_feed_overlay.dart';
import 'chat_bubble.dart';

part 'chat_overlay_parts/holo_background.dart';
part 'chat_overlay_parts/chat_header.dart';
part 'chat_overlay_parts/chat_messages.dart';
part 'chat_overlay_parts/chat_input_bar.dart';
part 'chat_overlay_parts/action_mode_transition.dart';

// ─── JARVIS-inspired dark AI palette ─────────────────────────────────────────
const _bgDeep = Color(0xFF040412);
const _bgMid = Color(0xFF0A0A20);
const _accent = Color(0xFF7C6AFF);
const _accentAlt = Color(0xFF9B8AFF);
const _glow = Color(0xFFAE9CFF);
const _cyan = Color(0xFF00E5FF);
const _textH = Color(0xFFF2F0FF);
const _textB = Color(0xFFB0ADCC);
const _textD = Color(0xFF6E6B8A);
const _glassBorder = Color(0x1AFFFFFF);
const _green = Color(0xFF5AE89E);
const _red = Color(0xFFFF6B8A);

/// Full-screen JARVIS-inspired chat overlay with holographic background,
/// rotating arc rings, floating particles, and glassmorphism effects.
class ChatOverlay extends StatefulWidget {
  final AiAssistantController controller;
  const ChatOverlay({super.key, required this.controller});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay>
    with TickerProviderStateMixin {
  final _textC = TextEditingController();
  final _scrollC = ScrollController();
  final _focus = FocusNode();

  late final AnimationController _fadeCtrl;
  late final AnimationController _bgCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _actionModeCtrl;

  AiAssistantController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _actionModeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _ctrl.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    // Auto-scroll chat to bottom on new messages.
    if (mounted && _scrollC.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollC.hasClients) return;
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }

    // Drive action mode animation based on controller state.
    if (_ctrl.isActionMode) {
      _actionModeCtrl.forward();
    } else {
      _actionModeCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _fadeCtrl.dispose();
    _bgCtrl.dispose();
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    _actionModeCtrl.dispose();
    _textC.dispose();
    _scrollC.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final t = _textC.text.trim();
    if (t.isEmpty) return;
    _textC.clear();
    _ctrl.sendMessage(t);
  }

  Future<void> _close() async {
    // During any processing (including ask_user), stop the agent first.
    if (_ctrl.isProcessing) {
      _ctrl.requestStop();
    }
    await _fadeCtrl.reverse();
    if (mounted) _ctrl.hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Material(
          color: Colors.transparent,
          child: SizedBox.expand(
            child: _ActionModeTransition(
              animation: _actionModeCtrl,
              bgAnimation: _bgCtrl,
              header: _ChatHeader(
                controller: _ctrl,
                ringAnimation: _ringCtrl,
                onClose: _close,
              ),
              messages: _ChatMessages(
                controller: _ctrl,
                scrollController: _scrollC,
              ),
              inputBar: _ChatInputBar(
                controller: _ctrl,
                textController: _textC,
                focusNode: _focus,
                ringAnimation: _ringCtrl,
                onSend: _send,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
