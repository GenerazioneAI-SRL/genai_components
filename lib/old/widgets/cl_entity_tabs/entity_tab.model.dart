import 'package:flutter/material.dart';
import 'entity_domain.dart';

/// Descrittore dichiarativo di una singola tab di dettaglio entità.
///
/// Pensato per essere registrato in una lista e passato a `CLEntityTabs`, che
/// filtra per [guard] e delega il rendering a `CLTabView`. Il contenuto è
/// costruito pigramente tramite [builder]: viene invocato solo quando la tab
/// viene effettivamente montata.
class EntityTab {
  /// Identificatore stabile della tab (es. `'profile'`, `'contracts'`).
  final String key;

  /// Etichetta mostrata nella tab bar.
  final String label;

  /// Dominio applicativo di provenienza.
  final EntityDomain domain;

  /// Icona opzionale mostrata accanto alla label.
  final IconData? icon;

  /// Gate di visibilità basato sui permessi.
  /// `null` => sempre visibile; altrimenti la tab è mostrata solo quando
  /// la callback ritorna `true`.
  final bool Function()? guard;

  /// Costruttore pigro del contenuto della tab.
  final Widget Function() builder;

  const EntityTab({
    required this.key,
    required this.label,
    required this.domain,
    required this.builder,
    this.icon,
    this.guard,
  });
}
