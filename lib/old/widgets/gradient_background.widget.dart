import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// Widget per il background con gradiente radiale e cerchi decorativi.
///
/// Ottimizzato: meno layer, RepaintBoundary per isolare il background
/// dal contenuto, TweenAnimationBuilder per transizione fluida al cambio modulo.
class GradientBackgroundWidget extends StatelessWidget {
  const GradientBackgroundWidget({
    super.key,
    this.child,
    this.showDecorativeCircles = true,
  });

  final Widget? child;
  final bool showDecorativeCircles;

  static const _animDuration = Duration(milliseconds: 400);
  static const _animCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: theme.primary),
      duration: _animDuration,
      curve: _animCurve,
      builder: (context, animPrimary, _) {
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: theme.secondary),
          duration: _animDuration,
          curve: _animCurve,
          builder: (context, animSecondary, _) {
            final primary = animPrimary ?? theme.primary;
            final secondary = animSecondary ?? theme.secondary;
            return _buildBackground(context, theme, primary, secondary);
          },
        );
      },
    );
  }

  Widget _buildBackground(BuildContext context, CLTheme theme, Color primary, Color secondary) {
    return Stack(
      children: [
        // Background statico — isolato dal repaint del contenuto
        RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  theme.secondaryBackground,
                  theme.primaryBackground,
                  theme.primaryBackground,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Gradiente primary in alto a sinistra
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [
                          primary.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
                // Gradiente secondary in basso a destra
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomRight,
                        radius: 1.2,
                        colors: [
                          secondary.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cerchi decorativi — solo se richiesto
        if (showDecorativeCircles)
          RepaintBoundary(
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -120,
                  child: _circle(350, primary.withValues(alpha: 0.06)),
                ),
                Positioned(
                  bottom: -160,
                  right: -160,
                  child: _circle(400, secondary.withValues(alpha: 0.06)),
                ),
              ],
            ),
          ),

        // Widget figlio
        if (child != null) child!,
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
