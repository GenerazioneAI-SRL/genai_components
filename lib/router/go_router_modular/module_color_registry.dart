import 'package:flutter/material.dart';

/// Registry globale per le tinte dei moduli.
///
/// Popolato al bootstrap da `CLApp.run` iterando le shell routes che sono
/// `ModuleRoute` con `color` non null. Consumato da widget come
/// `CLPageHeader` per derivare la tinta del modulo corrente senza che ogni
/// pagina debba passare manualmente il colore.
class ModuleColorRegistry {
  ModuleColorRegistry._();

  static final Map<String, Color> _byPath = {};

  /// Registra (o sovrascrive) il colore per il [path] di un modulo.
  static void register(String path, Color color) {
    _byPath[path] = color;
  }

  /// Lookup per [path] esatto.
  static Color? colorFor(String path) => _byPath[path];

  /// Lookup per il match di prefisso più lungo di [location].
  ///
  /// Esempio: registry contiene `/hr` e `/hr/attendance`; con
  /// `location = '/hr/attendance/123'` ritorna il colore di
  /// `/hr/attendance`.
  static Color? colorForLocation(String location) {
    String? bestMatch;
    for (final path in _byPath.keys) {
      if (location == path || location.startsWith('$path/') || location.startsWith(path)) {
        if (bestMatch == null || path.length > bestMatch.length) {
          bestMatch = path;
        }
      }
    }
    return bestMatch == null ? null : _byPath[bestMatch];
  }

  /// Pulisce il registry (utile in test).
  @visibleForTesting
  static void clear() => _byPath.clear();
}
