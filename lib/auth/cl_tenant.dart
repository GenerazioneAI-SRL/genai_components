/// Interfaccia generica per un tenant (organizzazione/azienda).
/// Ogni app implementa il proprio modello concreto.
abstract class CLTenant {
  String get id;
  String get name;

  /// Dati raw completi (per accesso a campi custom)
  Map<String, dynamic> get rawData => {};
}

