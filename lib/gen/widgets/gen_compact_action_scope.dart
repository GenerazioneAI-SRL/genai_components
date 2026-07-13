import 'package:flutter/widgets.dart';

/// Scope che chiede ai bottoni discendenti (`GenButton`, `GenOutlineButton`) di
/// collassare a tondo icon-only quando [iconOnly] è true.
///
/// Mantiene lo stile del bottone (sfondo/bordo/colore icona): un primary resta
/// pieno con icona bianca, un outlined resta trasparente col suo bordo. Solo il
/// testo sparisce e la forma diventa circolare.
///
/// Usato dalle toolbar tabella su telefono per evitare overflow orizzontale.
/// Un bottone collassa solo se ha un'icona (e non è `fullWidth`/`width` fissa).
class GenCompactActionScope extends InheritedWidget {
  final bool iconOnly;

  const GenCompactActionScope({
    super.key,
    required this.iconOnly,
    required super.child,
  });

  /// True se un antenato [GenCompactActionScope] chiede il collasso icon-only.
  static bool iconOnlyOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GenCompactActionScope>();
    return scope?.iconOnly ?? false;
  }

  @override
  bool updateShouldNotify(GenCompactActionScope oldWidget) => oldWidget.iconOnly != iconOnly;
}
