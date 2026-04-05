import 'package:cl_components/router/go_router_modular/page_transition_enum.dart';
import 'package:flutter/material.dart';

class Transition {
  Transition._();
  static Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
  builder({
    required PageTransition pageTransition,
    VoidCallback? onTransitionStart,
  }) {
    return (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      onTransitionStart?.call();
      switch (pageTransition) {
        case PageTransition.noTransition:
          return child; // Nessuna transizione, cambio istantaneo

        case PageTransition.slideUp:
          return SlideTransition(
            position: Tween(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );

        case PageTransition.slideDown:
          return SlideTransition(
            position: Tween(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );

        case PageTransition.slideLeft:
          return SlideTransition(
            position: Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );

        case PageTransition.slideRight:
          return SlideTransition(
            position: Tween(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );

        case PageTransition.fade:
          // Effetto sequenziale: prima fadeOut completo, poi fadeIn
          // La pagina entrante appare solo dopo che quella uscente è scomparsa
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                // Il fadeIn inizia al 40% dell'animazione (dopo che il fadeOut è quasi completo)
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  // Il fadeOut completa entro il 50% dell'animazione
                  curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
                ),
              ),
              child: child,
            ),
          );

        case PageTransition.scale:
          return ScaleTransition(scale: animation, child: child);

        case PageTransition.rotation:
          return RotationTransition(turns: animation, child: child);
      }
    };
  }
}
