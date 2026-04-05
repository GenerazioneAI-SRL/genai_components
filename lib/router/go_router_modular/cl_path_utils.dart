/// Utility per la normalizzazione dei path delle route.
///
/// Unifica la logica precedentemente duplicata in Module._buildPath
/// e ChildRoute._buildPath.
class CLPathUtils {
  CLPathUtils._();

  /// Normalizza un path rimuovendo slash doppi e trailing slash.
  ///
  /// Esempi:
  /// - `"/foo/"` → `"/foo"`
  /// - `"//foo//bar//"` → `"/foo/bar"`
  /// - `"/"` → `"/"`
  static String buildPath(String path) {
    if (!path.endsWith('/')) {
      path = '$path/';
    }
    path = path.replaceAll(RegExp(r'/+'), '/');
    if (path == '/') return path;
    return path.substring(0, path.length - 1);
  }

  /// Normalizza un path per go_router, rimuovendo lo slash iniziale
  /// per le route non top-level (tranne quelle con parametri tipo `/:id`).
  static String normalizePath({required String path, required bool topLevel}) {
    if (path.startsWith("/") && !topLevel && !path.startsWith("/:")) {
      path = path.substring(1);
    }
    return buildPath(path);
  }

  /// Restituisce true se il path rappresenta la route radice di un modulo.
  /// Considera `"/"` e path che iniziano con `"/:"` (es. `"/:id"`) come root.
  static bool isRootRoute(String path) {
    return path == '/' || path.startsWith('/:');
  }
}

