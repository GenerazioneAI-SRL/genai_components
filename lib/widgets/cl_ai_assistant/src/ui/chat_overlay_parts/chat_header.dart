part of '../chat_overlay.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Chat overlay header: avatar with rotating arc rings, title, status, actions.
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatHeader extends StatelessWidget {
  final AiAssistantController controller;

  /// Looping ticker (0..1) driving arc-ring rotation. Owned by parent.
  final Animation<double> ringAnimation;

  /// Header close action (animated dismissal).
  final VoidCallback onClose;

  const _ChatHeader({
    required this.controller,
    required this.ringAnimation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _bgDeep.withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: _glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar with rotating arc ring.
          SizedBox(
            width: 42,
            height: 42,
            child: AnimatedBuilder(
              animation: ringAnimation,
              builder:
                  (_, __) => CustomPaint(
                    painter: _ArcRingsPainter(
                      t: ringAnimation.value,
                      ringRadius: 21,
                      ringCount: 2,
                    ),
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_accent, _glow],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.config.assistantName,
                  style: const TextStyle(
                    color: _textH,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                ListenableBuilder(
                  listenable: controller,
                  builder: (_, __) => _StatusRow(controller: controller),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder:
                (_, __) =>
                    _HeaderActions(controller: controller, onClose: onClose),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final AiAssistantController controller;
  const _StatusRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final String label;

    if (controller.isWaitingForUserResponse) {
      dotColor = _cyan;
      label = 'Waiting for you...';
    } else if (controller.isProcessing) {
      dotColor = _accentAlt;
      label = 'Processing...';
    } else {
      dotColor = _green;
      label = 'Ready';
    }

    return Row(
      children: [
        _StatusDot(color: dotColor, animate: controller.isProcessing),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: dotColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final AiAssistantController controller;
  final VoidCallback onClose;
  const _HeaderActions({required this.controller, required this.onClose});

  Widget _hdrBtn(IconData ic, Color c, VoidCallback? onTap) => IconButton(
    icon: Icon(ic, size: 22),
    color: onTap == null ? _textD.withValues(alpha: 0.3) : c,
    onPressed: onTap,
    visualDensity: VisualDensity.compact,
  );

  @override
  Widget build(BuildContext context) {
    // Teammate change (origin/main): the inline stop+close header pair was
    // removed during processing — stop is now exposed via the input bar
    // (_stopButtonInline). The header keeps only Clear + Close, and Clear
    // is hidden while the agent is busy to avoid mid-flow conversation wipes.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!controller.isProcessing && controller.messages.isNotEmpty)
          _hdrBtn(Icons.delete_outline, _textB, controller.clearConversation),
        _hdrBtn(Icons.keyboard_arrow_down_rounded, _textB, onClose),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Status dot with pulse animation.
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusDot extends StatefulWidget {
  final Color color;
  final bool animate;
  const _StatusDot({required this.color, this.animate = false});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.animate) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.animate && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final v = _c.value;
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow:
                widget.animate
                    ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3 + v * 0.4),
                        blurRadius: 4 + v * 4,
                        spreadRadius: v * 2,
                      ),
                    ]
                    : null,
          ),
        );
      },
    );
  }
}
