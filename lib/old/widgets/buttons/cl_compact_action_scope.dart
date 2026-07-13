import 'package:flutter/widgets.dart';

/// Scope che chiede ai bottoni discendenti (`CLButton`, `CLOutlineButton`) di
/// collassare a tondo icon-only quando [iconOnly] è true.
///
/// Mantiene lo stile del bottone (sfondo/bordo/colore icona): un primary resta
/// pieno con icona bianca, un outlined resta trasparente col suo bordo. Solo il
/// testo sparisce e la forma diventa circolare.
///
/// Usato dalle toolbar tabella su telefono per evitare overflow orizzontale.
/// Un bottone collassa solo se ha un'icona (e non è `fullWidth`/`width` fissa).
class CLCompactActionScope extends InheritedWidget {
  final bool iconOnly;

  const CLCompactActionScope({
    super.key,
    required this.iconOnly,
    required super.child,
  });

  /// True se un antenato [CLCompactActionScope] chiede il collasso icon-only.
  static bool iconOnlyOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CLCompactActionScope>();
    return scope?.iconOnly ?? false;
  }

  @override
  bool updateShouldNotify(CLCompactActionScope oldWidget) => oldWidget.iconOnly != iconOnly;
}
