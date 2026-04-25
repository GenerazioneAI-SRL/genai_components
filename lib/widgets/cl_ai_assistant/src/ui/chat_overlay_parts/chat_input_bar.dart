part of '../chat_overlay.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Bottom input bar: live partial transcription, voice mic toggle, animated
// glowing TextField, and send/stop button.
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatInputBar extends StatelessWidget {
  final AiAssistantController controller;
  final TextEditingController textController;
  final FocusNode focusNode;

  /// Looping ticker (0..1) used for the field's animated sweep gradient
  /// border. Owned by parent.
  final Animation<double> ringAnimation;

  /// Send the current text content.
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.ringAnimation,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: _bgDeep.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: _glassBorder, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live partial transcription display.
          ListenableBuilder(
            listenable: controller,
            builder: (_, __) {
              final partial = controller.partialTranscription;
              if (partial == null || partial.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 14,
                      color: _red.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        partial,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textB.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            children: [
              if (controller.config.voiceEnabled)
                ListenableBuilder(
                  listenable: controller,
                  builder:
                      (_, __) => _CircleBtn(
                        icon:
                            controller.isListening ? Icons.mic : Icons.mic_none,
                        color: controller.isListening ? _red : _textD,
                        onTap:
                            (controller.isProcessing &&
                                    !controller.isWaitingForUserResponse)
                                ? null
                                : controller.toggleVoiceInput,
                      ),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: _InputField(
                  controller: controller,
                  textController: textController,
                  focusNode: focusNode,
                  ringAnimation: ringAnimation,
                  onSend: onSend,
                ),
              ),
              const SizedBox(width: 6),
              ListenableBuilder(
                listenable: controller,
                builder: (_, __) {
                  if (controller.isProcessing &&
                      !controller.isWaitingForUserResponse) {
                    return _StopButton(onTap: controller.requestStop);
                  }
                  return _SendButton(onTap: onSend);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final AiAssistantController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Animation<double> ringAnimation;
  final VoidCallback onSend;

  const _InputField({
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.ringAnimation,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (_, __) {
        final waiting = controller.isWaitingForUserResponse;
        final focused = focusNode.hasFocus;
        final showGlow = focused || waiting;

        // Always use the same widget structure to avoid reparenting the
        // TextField when focus changes. Switching between Container and
        // AnimatedBuilder caused Flutter to unmount/remount the field,
        // losing focus on the first tap.
        return AnimatedBuilder(
          animation: ringAnimation,
          builder:
              (_, child) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient:
                      showGlow
                          ? SweepGradient(
                            colors: const [
                              _accent,
                              _cyan,
                              _accent,
                              _cyan,
                              _accent,
                            ],
                            transform: GradientRotation(
                              ringAnimation.value * 2 * math.pi,
                            ),
                          )
                          : null,
                  border:
                      showGlow
                          ? null
                          : Border.all(color: _glassBorder, width: 0.5),
                  color: showGlow ? null : _bgMid,
                ),
                child: Container(
                  margin:
                      showGlow ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: _bgMid,
                    borderRadius: BorderRadius.circular(showGlow ? 24.5 : 26),
                  ),
                  child: child,
                ),
              ),
          child: TextField(
            controller: textController,
            focusNode: focusNode,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            enabled:
                !controller.isProcessing || controller.isWaitingForUserResponse,
            style: const TextStyle(color: _textH, fontSize: 14),
            cursorColor: _cyan,
            decoration: InputDecoration(
              hintText:
                  waiting
                      ? 'Type your response...'
                      : 'Ask me to do something...',
              hintStyle: TextStyle(
                color:
                    waiting
                        ? _cyan.withValues(alpha: 0.5)
                        : _textD.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              isDense: true,
            ),
          ),
        );
      },
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_accent, _glow],
          ),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _red.withValues(alpha: 0.15),
          border: Border.all(color: _red.withValues(alpha: 0.3)),
        ),
        child: Icon(
          Icons.stop_rounded,
          size: 20,
          color: _red.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CircleBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _bgMid,
          border: Border.all(color: _glassBorder, width: 0.5),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? color.withValues(alpha: 0.3) : color,
        ),
      ),
    );
  }
}
