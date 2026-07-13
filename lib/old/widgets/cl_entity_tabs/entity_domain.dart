import 'package:flutter/material.dart';
import '../../cl_theme.dart';

/// Dominio applicativo a cui appartiene una sezione di dettaglio entità.
///
/// Usato da [EntityTab] per taggare ogni tab con il modulo di provenienza
/// (Anagrafica, HR, Competenze, ...). Serve sia per la label leggibile sia per
/// un eventuale accento cromatico per-dominio.
enum EntityDomain { id, hr, atlas, lms, certet, bill }

/// Etichette it_IT e accento cromatico per [EntityDomain].
extension EntityDomainX on EntityDomain {
  /// Label leggibile (it_IT) del dominio.
  String get label {
    switch (this) {
      case EntityDomain.id:
        return 'Anagrafica';
      case EntityDomain.hr:
        return 'Risorse Umane';
      case EntityDomain.atlas:
        return 'Competenze';
      case EntityDomain.lms:
        return 'Formazione';
      case EntityDomain.certet:
        return 'Certificazione';
      case EntityDomain.bill:
        return 'Billing';
    }
  }

  /// Accento cromatico del dominio, derivato dai colori del [theme].
  /// Tinta brand-adiacente per badge/indicatori, non semantica.
  Color color(CLTheme theme) {
    switch (this) {
      case EntityDomain.id:
        return theme.primary;
      case EntityDomain.hr:
        return theme.accentPurple;
      case EntityDomain.atlas:
        return theme.info;
      case EntityDomain.lms:
        return theme.success;
      case EntityDomain.certet:
        return theme.warning;
      case EntityDomain.bill:
        return theme.secondary;
    }
  }
}
