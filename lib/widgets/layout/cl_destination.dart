import 'package:flutter/widgets.dart';

/// Destinazione di navigazione neutra: nessuna dipendenza da router/Modular.
/// L'app converte il proprio albero route in `List<CLDestination>` (adapter).
@immutable
class CLDestination {
  /// Id univoco e stabile (tipicamente il path assoluto o il route name).
  /// Usato per selezione (`selectedKey`) e callback `onSelect`.
  final String key;
  final String label;

  /// Icona come `IconData` (compatibile sia con Lucide sia con HugeIcons,
  /// che espongono costanti `IconData`). Resa con `Icon(icon)`.
  final IconData? icon;
  final IconData? selectedIcon;

  /// Figli → gruppo espandibile in sidebar/drawer. Vuoto = foglia.
  final List<CLDestination> children;

  /// Bottom bar: valore più alto = scelto prima tra le voci principali.
  final int priority;

  final bool isVisible;

  /// Label di sezione (non tappabile): rende un'intestazione collassabile
  /// con i `children` come voci sotto. Equivale a `onlyShowLabel`.
  /// Nota: una sezione senza figli ha sia `hasChildren` sia `isLeaf` false
  /// (categoria a sé, non una foglia).
  final bool isSectionHeader;

  /// Tinta opzionale del modulo. Consumata dall'adapter app (es. admin mappa
  /// `ModuleRoute.color` → `tint` per i moduli colorati).
  final Color? tint;

  const CLDestination({
    required this.key,
    required this.label,
    this.icon,
    this.selectedIcon,
    this.children = const [],
    this.priority = 0,
    this.isVisible = true,
    this.isSectionHeader = false,
    this.tint,
  });

  bool get hasChildren => children.isNotEmpty;
  bool get isLeaf => !hasChildren && !isSectionHeader;

  /// True se `key` corrisponde a questa destinazione o a un suo discendente.
  /// Usato per evidenziare/espandere gruppi quando un figlio è attivo.
  bool containsKey(String? k) {
    if (k == null) return false;
    if (k == key) return true;
    for (final c in children) {
      if (c.containsKey(k)) return true;
    }
    return false;
  }
}
