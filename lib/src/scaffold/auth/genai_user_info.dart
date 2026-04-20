/// Interfaccia generica per le informazioni utente.
/// Ogni app implementa il proprio mapping dai dati raw.
abstract class GenaiUserInfo {
  String get firstName;
  String get lastName;
  String? get email;
  String get fullName => '$firstName $lastName'.trim();

  /// Dati raw completi (per accesso a campi custom)
  Map<String, dynamic> get rawData;
}

