import 'package:flutter/widgets.dart';

/// Destinazione di navigazione neutra: nessuna dipendenza da router/Modular.
/// L'app converte il proprio albero route in `List<CLDestination>` (adapter).
@immutable
class CLDestination {
  /// Id univoco e stabile (tipicamente il path assoluto o il route name).
  /// Usato per selezione (`selectedKey`) e callback `onSelect`.
  final String key;
  final String label;

  /// Icona come `IconData` (es. Lucide, Material). Resa con `Icon(icon)`.
  final IconData? icon;

  /// Builder icona avanzato, per icone che NON sono `IconData` (es. HugeIcon,
  /// SVG). Riceve colore+dimensione e ritorna il widget icona; ha precedenza
  /// su `icon`. L'adapter app lo usa per delegare a `route.buildIcon`.
  final Widget? Function(Color color, double size)? iconBuilder;

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
    this.iconBuilder,
    this.children = const [],
    this.priority = 0,
    this.isVisible = true,
    this.isSectionHeader = false,
    this.tint,
  });

  bool get hasChildren => children.isNotEmpty;
  bool get isLeaf => !hasChildren && !isSectionHeader;

  /// Costruisce l'icona col colore/size dati: `iconBuilder` se presente,
  /// altrimenti `Icon(icon)`, altrimenti null.
  Widget? buildIcon(Color color, double size) {
    if (iconBuilder != null) return iconBuilder!(color, size);
    if (icon != null) return Icon(icon, color: color, size: size);
    return null;
  }

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
