import 'package:flutter/foundation.dart';

/// Registry per mappare i nomi delle route ai loro path completi
class RouteRegistry {
  static final RouteRegistry _instance = RouteRegistry._internal();

  /// Singleton accessor (alias del costruttore factory).
  ///
  /// Esiste per allinearsi all'API tipica `RouteRegistry.instance` usata
  /// dalle estensioni e dai consumer esterni del framework, senza modificare
  /// la factory storica.
  static RouteRegistry get instance => _instance;

  factory RouteRegistry() => _instance;

  RouteRegistry._internal();

  // Cambiato: ora mappiamo name -> List<path> per gestire duplicati
  final Map<String, List<String>> _nameToPath = {};

  /// Registra una route con il suo nome e path completo.
  ///
  /// Se il nome esiste già con un path **diverso**, emette un warning via
  /// [debugPrint] (in modalità debug) per segnalare un potenziale conflitto
  /// di nomi nel grafo delle route. Tutte le varianti restano comunque
  /// memorizzate per retro-compatibilità: la risoluzione resta deterministica
  /// tramite [getPathByName] (path più specifico o miglior prefisso comune).
  void registerRoute(String name, String fullPath) {
    if (_nameToPath.containsKey(name)) {
      final existing = _nameToPath[name]!;
      // Aggiungi solo se non esiste già questo path
      if (!existing.contains(fullPath)) {
        assert(() {
          debugPrint(
            '[RouteRegistry] WARNING: route name "$name" already registered '
            'with different path. Existing: ${existing.join(", ")}, new: $fullPath',
          );
          return true;
        }());
        existing.add(fullPath);
        // Ordina per lunghezza decrescente (path più specifici prima)
        existing.sort((a, b) => b.length.compareTo(a.length));
      }
    } else {
      _nameToPath[name] = [fullPath];
    }
  }

  /// Restituisce `true` se [nameOrPath] è registrato come nome di route
  /// oppure compare tra i path completi memorizzati.
  ///
  /// Usato dalle estensioni `BuildContext.isRouteDefined` /
  /// `BuildContext.goIfDefined` per verificare l'esistenza di una route
  /// senza esporre la mappa interna.
  bool has(String nameOrPath) {
    if (_nameToPath.containsKey(nameOrPath)) return true;
    for (final paths in _nameToPath.values) {
      if (paths.contains(nameOrPath)) return true;
    }
    return false;
  }

  /// Ottiene il path completo da un nome di route
  /// Se ci sono più path con lo stesso nome, cerca quello più pertinente al contextPath
  /// altrimenti restituisce il più specifico (più lungo)
  String? getPathByName(String name, {String? contextPath}) {
    final paths = _nameToPath[name];
    if (paths == null || paths.isEmpty) return null;

    if (paths.length == 1) return paths.first;

    // Se c'è un contextPath, cerca il path che condivide il prefisso più lungo
    if (contextPath != null && contextPath.isNotEmpty) {
      String bestMatch = paths.first;
      int maxCommonLength = 0;

      for (final path in paths) {
        // Calcola il prefisso comune
        int commonLength = 0;
        final minLength = path.length < contextPath.length ? path.length : contextPath.length;
        for (int i = 0; i < minLength; i++) {
          if (path[i] == contextPath[i]) {
            commonLength++;
          } else {
            break;
          }
        }

        if (commonLength > maxCommonLength) {
          maxCommonLength = commonLength;
          bestMatch = path;
        }
      }

      return bestMatch;
    }

    // Fallback: restituisce il path più lungo (più specifico)
    return paths.first;
  }

  /// Pulisce il registry (utile per i test)
  void clear() {
    _nameToPath.clear();
  }

  /// Ottiene tutte le route registrate (per debug)
  Map<String, List<String>> getAllRoutes() {
    return Map.unmodifiable(_nameToPath);
  }

  /// Stampa tutte le route registrate (per debug)
}
