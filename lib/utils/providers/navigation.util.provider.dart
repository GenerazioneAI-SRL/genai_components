import 'package:flutter/material.dart';
import '../models/breadcrumb_item.model.dart';

/// Gestisce lo stato dei breadcrumb e il nome della pagina corrente.
///
/// I breadcrumb sono gestiti automaticamente dal [GoRouterBreadcrumbObserver].
/// Non è necessario manipolarli manualmente dai moduli.
class NavigationState extends ChangeNotifier {
  final List<BreadcrumbItem> _breadcrumbs = [];
  bool _disposed = false;

  List<BreadcrumbItem> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  String pageName = "";

  /// Route iniziale salvata prima che l'app sia pronta (deep-link).
  String? initialRoute;

  /// Diventa true quando il CLPageHeader è scrollato fuori dallo schermo.
  /// L'HeaderLayout lo usa per mostrare il titolo con fade-in.
  @Deprecated('Use HeaderVisibilityState — will be removed in 5.0')
  final ValueNotifier<bool> headerTitleVisible = ValueNotifier<bool>(false);

  /// Imposta la visibilità del titolo nell'header.
  /// API additiva — `headerTitleVisible` resta accessibile per backward compat.
  @Deprecated('Use HeaderVisibilityState — will be removed in 5.0')
  void setHeaderTitleVisibility(bool visible) {
    if (headerTitleVisible.value == visible) return;
    headerTitleVisible.value = visible;
  }

  /// Aggiunge un breadcrumb allo stack.
  ///
  /// Logica:
  /// 1. Se il path è già nello stack → tronca tutto dopo (navigazione ciclica)
  /// 2. Se è un modulo e cambia rispetto all'ultimo → reset + aggiungi
  /// 3. Se è un modulo nested dell'ultimo → aggiungi
  /// 4. Se è una pagina → aggiungi al modulo corrente
  void addBreadcrumb(BreadcrumbItem item, {String? parentModuleName, String? parentModulePath}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageName = item.name;

      // 1. Se il path esiste già → tronca tutto dopo
      final existingIdx = _breadcrumbs.indexWhere((b) => b.path == item.path);
      if (existingIdx != -1) {
        if (existingIdx + 1 < _breadcrumbs.length) {
          _breadcrumbs.removeRange(existingIdx + 1, _breadcrumbs.length);
        }
        notifyListeners();
        return;
      }

      if (item.isModule) {
        _addModule(item);
      } else {
        _addPage(item, parentModuleName: parentModuleName, parentModulePath: parentModulePath);
      }

      notifyListeners();
    });
  }

  /// Aggiunge un modulo ai breadcrumb.
  void _addModule(BreadcrumbItem item) {
    final lastModIdx = _breadcrumbs.lastIndexWhere((b) => b.isModule);

    if (lastModIdx != -1) {
      final lastMod = _breadcrumbs[lastModIdx];
      final isNested = item.path.startsWith('${lastMod.path}/');

      if (!isNested) {
        // Modulo diverso → reset tranne root
        _clearExceptRoot();
      }
    } else if (_breadcrumbs.length > 1) {
      _clearExceptRoot();
    }

    _breadcrumbs.add(item);
  }

  /// Aggiunge una pagina ai breadcrumb.
  void _addPage(BreadcrumbItem item, {String? parentModuleName, String? parentModulePath}) {
    // Se c'è un parent module specificato, assicurati che sia nei breadcrumb
    if (parentModuleName != null && parentModulePath != null) {
      final parentIdx = _breadcrumbs.indexWhere((b) => b.path == parentModulePath);

      if (parentIdx != -1) {
        // Parent trovato → tronca tutto dopo
        if (parentIdx < _breadcrumbs.length - 1) {
          _breadcrumbs.removeRange(parentIdx + 1, _breadcrumbs.length);
        }
      } else {
        // Parent non trovato → reset e aggiungi il modulo
        _clearExceptRoot();
        _breadcrumbs.add(BreadcrumbItem(
          name: parentModuleName,
          path: parentModulePath,
          isModule: true,
          isClickable: false,
        ));
      }
    } else {
      // Nessun parent module → gestisci rispetto all'ultimo modulo
      final lastModIdx = _breadcrumbs.lastIndexWhere((b) => b.isModule);

      if (lastModIdx != -1) {
        final lastMod = _breadcrumbs[lastModIdx];
        if (!item.path.startsWith('${lastMod.path}/')) {
          // Pagina fuori dal modulo corrente → reset
          _clearExceptRoot();
        }
      }
    }

    _breadcrumbs.add(item);
  }

  /// Tronca tutto ciò che segue targetPath.
  void removeUntil(String targetPath) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idx = _breadcrumbs.indexWhere((b) => b.path == targetPath);
      if (idx != -1 && idx < _breadcrumbs.length - 1) {
        _breadcrumbs.removeRange(idx + 1, _breadcrumbs.length);
        pageName = _breadcrumbs.last.name;
        notifyListeners();
      }
    });
  }

  /// Rimuove l'ultimo breadcrumb.
  void removeLastBreadcrumb() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_breadcrumbs.length > 1) {
        _breadcrumbs.removeLast();
        pageName = _breadcrumbs.last.name;
        notifyListeners();
      }
    });
  }

  /// Svuota tutti i breadcrumb.
  void clearBreadcrumbs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _breadcrumbs.clear();
      pageName = "";
      notifyListeners();
    });
  }

  /// NON tocca mai l'indice 0 (Dashboard/root)
  void _clearExceptRoot() {
    if (_breadcrumbs.length > 1) {
      _breadcrumbs.removeRange(1, _breadcrumbs.length);
    }
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    headerTitleVisible.dispose();
    super.dispose();
  }
}
