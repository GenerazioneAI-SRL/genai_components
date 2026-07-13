// IconData col peso è costruito a runtime (font-family variabile) → i suoi
// argomenti non sono const. È voluto: rompe `--tree-shake-icons`, quindi la app
// va buildata con `--no-tree-shake-icons`.
// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/widgets.dart';

/// Package Flutter delle icone Lucide: discrimina i glifi rimappabili per peso.
const String _kLucidePackage = 'lucide_icons_flutter';

/// Pesi Lucide bundlati nel package (`Lucide100`…`Lucide600`). 700–900 NON
/// sono negli asset → esclusi. Ogni peso è una font-family separata a parità di
/// codepoint: cambiare peso = cambiare `fontFamily` dello stesso glifo.
const Set<int> _kLucideWeights = {100, 200, 300, 400, 500, 600};

/// Peso icone valido più vicino a [w] (clamp all'insieme bundlato).
int _resolveLucideWeight(int w) {
  if (_kLucideWeights.contains(w)) return w;
  final sorted = _kLucideWeights.toList()..sort();
  if (w <= sorted.first) return sorted.first;
  if (w >= sorted.last) return sorted.last;
  return sorted.reduce((a, b) => (w - a).abs() <= (w - b).abs() ? a : b);
}

/// Fornisce il peso icone di default a un sottoalbero. Il widget [GenTheme] lo
/// installa da [GenThemeData.iconWeight]; con `ShadApp`+`toShad()` va montato a
/// mano (es. `GenIconTheme(weight: 300, child: ...)`).
class GenIconTheme extends InheritedWidget {
  const GenIconTheme({super.key, required this.weight, required super.child});

  /// Peso Lucide (100–600). Valori fuori range vengono clampati.
  final int weight;

  static int weightOf(BuildContext context) {
    final t = context.dependOnInheritedWidgetOfExactType<GenIconTheme>();
    return t?.weight ?? 400;
  }

  @override
  bool updateShouldNotify(GenIconTheme oldWidget) => weight != oldWidget.weight;
}

/// Icona Gen: applica il peso Lucide del [GenIconTheme] ancestrale (override via
/// [weight]) rimappando la `fontFamily` dell'`IconData`. Icone NON-Lucide (es.
/// Material `Icons.*`) passano invariate: il remap tocca solo i glifi Lucide.
///
/// Nota: le icone disegnate internamente da widget Shad (check di checkbox,
/// chevron di select) NON passano da qui → il peso globale copre solo le icone
/// che l'app costruisce con [GenIcon].
class GenIcon extends StatelessWidget {
  const GenIcon(this.icon, {super.key, this.size, this.color, this.weight});

  final IconData icon;
  final double? size;
  final Color? color;

  /// Override esplicito del peso; se null usa il [GenIconTheme] ancestrale.
  final int? weight;

  @override
  Widget build(BuildContext context) {
    if (icon.fontPackage != _kLucidePackage) return Icon(icon, size: size, color: color);
    final w = _resolveLucideWeight(weight ?? GenIconTheme.weightOf(context));
    final weighted = IconData(
      icon.codePoint,
      fontFamily: 'Lucide$w',
      fontPackage: _kLucidePackage,
      matchTextDirection: icon.matchTextDirection,
    );
    return Icon(weighted, size: size, color: color);
  }
}
