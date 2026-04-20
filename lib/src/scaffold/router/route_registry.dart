/// Registry per mappare i nomi delle route ai loro path completi
class RouteRegistry {
  static final RouteRegistry _instance = RouteRegistry._internal();

  factory RouteRegistry() => _instance;

  RouteRegistry._internal();

  // Cambiato: ora mappiamo name -> List<path> per gestire duplicati
  final Map<String, List<String>> _nameToPath = {};

  /// Registra una route con il suo nome e path completo
  /// Se il nome esiste già, mantiene tutte le varianti
  void registerRoute(String name, String fullPath) {
    if (_nameToPath.containsKey(name)) {
      // Aggiungi solo se non esiste già questo path
      if (!_nameToPath[name]!.contains(fullPath)) {
        _nameToPath[name]!.add(fullPath);
        // Ordina per lunghezza decrescente (path più specifici prima)
        _nameToPath[name]!.sort((a, b) => b.length.compareTo(a.length));
      }
    } else {
      _nameToPath[name] = [fullPath];
    }
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
