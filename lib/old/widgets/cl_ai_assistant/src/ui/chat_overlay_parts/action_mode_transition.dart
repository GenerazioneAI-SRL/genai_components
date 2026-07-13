part of '../chat_overlay.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Animates the transition between the full-screen chat layout and the
// compact bottom-sheet "action mode" (revealing the app behind it).
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionModeTransition extends StatelessWidget {
  /// Animation 0..1 where 0 = full chat, 1 = bottom-sheet action mode.
  /// Owned by parent.
  final Animation<double> animation;

  /// Animated holographic background ticker (0..1 looping). Owned by parent.
  final Animation<double> bgAnimation;

  /// Built once and reused across rebuilds (header / messages / input).
  final Widget header;
  final Widget messages;
  final Widget inputBar;

  const _ActionModeTransition({
    required this.animation,
    required this.bgAnimation,
    required this.header,
    required this.messages,
    required this.inputBar,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final kb = mq.viewInsets.bottom;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final actionT = Curves.easeInOut.transform(animation.value);
        // In action mode, the background fades out to reveal the app.
        final bgOpacity = 1.0 - actionT;
        // Content slides to the bottom ~40% of the screen.
        final topFraction = actionT * 0.55;

        return Stack(
          children: [
            // Holographic background with animated opacity.
            if (bgOpacity > 0.01)
              Opacity(
                opacity: bgOpacity,
                child: _HoloBackground(
                  animation: bgAnimation,
                  drawEffects: bgOpacity > 0.3,
                ),
              ),

            // Content: slides down in action mode to become a compact
            // bottom-sheet, letting the user see the app above.
            Positioned(
              top: mq.size.height * topFraction,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  // Semi-transparent scrim behind compact area for readability.
                  if (actionT > 0.01)
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: _bgDeep.withValues(alpha: 0.7 * actionT),
                            blurRadius: 20,
                            spreadRadius: 10,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20 * actionT),
                      ),
                      child: Container(
                        color:
                            actionT > 0.01
                                ? _bgDeep.withValues(
                                  alpha: 0.88 + 0.12 * (1 - actionT),
                                )
                                : Colors.transparent,
                        padding: EdgeInsets.only(
                          top: actionT > 0.01 ? 0 : mq.padding.top,
                          bottom: kb > 0 ? kb : mq.padding.bottom,
                        ),
                        child: Column(
                          children: [
                            header,
                            Expanded(child: messages),
                            inputBar,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
