part of '../chat_overlay.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Scrollable messages list, with empty state, typing indicator, action feed.
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatMessages extends StatelessWidget {
  final AiAssistantController controller;
  final ScrollController scrollController;

  const _ChatMessages({
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        final msgs = controller.messages;
        if (msgs.isEmpty && !controller.isProcessing) {
          return _EmptyState(controller: controller);
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: msgs.length + (controller.isProcessing ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == msgs.length) {
              return controller.isActionFeedVisible
                  ? ActionFeedOverlay(controller: controller)
                  : const _TypingRow();
            }
            return _MessageEntrance(
              child: ChatBubble(
                message: msgs[i],
                onButtonTap: controller.handleButtonTap,
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AiAssistantController controller;
  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clean avatar with subtle glow.
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_accent, _glow],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.config.assistantName,
              style: const TextStyle(
                color: _textH,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chiedimi informazioni su presenze, turni,\nanomalìe o naviga nelle sezioni.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textD, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            // Suggestion cards styled like dashboard stat chips.
            if (controller.config.initialSuggestions.isNotEmpty)
              Column(
                children:
                    controller.config.initialSuggestions
                        .map(
                          (chip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SuggestionCard(
                              icon: chip.icon,
                              label: chip.label,
                              subtitle: chip.message,
                              onTap:
                                  () => controller.sendSuggestion(
                                    chip.label,
                                    chip.message,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _miniAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _bgMid,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _glassBorder, width: 0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                SizedBox(width: 5),
                _TypingDot(delay: 150),
                SizedBox(width: 5),
                _TypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _miniAvatar() => Container(
    width: 28,
    height: 28,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: [_accent, _glow]),
    ),
    child: const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Message entrance animation — scale + fade.
// ═══════════════════════════════════════════════════════════════════════════════

class _MessageEntrance extends StatefulWidget {
  final Widget child;
  const _MessageEntrance({required this.child});

  @override
  State<_MessageEntrance> createState() => _MessageEntranceState();
}

class _MessageEntranceState extends State<_MessageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return FadeTransition(
      opacity: curve,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
        alignment: Alignment.bottomLeft,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Typing indicator dots.
// ═══════════════════════════════════════════════════════════════════════════════

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
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
      builder:
          (_, __) => Transform.translate(
            offset: Offset(0, -3 * _c.value),
            child: Opacity(
              opacity: 0.3 + _c.value * 0.7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_accent, _glow]),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Suggestion chip for empty state.
// ═══════════════════════════════════════════════════════════════════════════════

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _bgMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: _accentAlt),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _textH,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _textD, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: _textD.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
