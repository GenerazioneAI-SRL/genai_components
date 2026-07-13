import 'package:flutter/widgets.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

/// Preset di brand: variano il colore primario (ring/selection derivati),
/// mantenendo la palette neutra skillera. `null` primary = default skillera.
enum ThemePreset {
  skillera('Skillera', null),
  ocean('Ocean Breeze', Color(0xFF4F46E5)),
  emerald('Emerald', Color(0xFF059669)),
  rose('Rose', Color(0xFFE11D48));

  const ThemePreset(this.label, this.primary);
  final String label;
  final Color? primary;
}

/// Raggio globale ([GenThemeData.radius]).
enum ThemeRadius {
  none('Nessuno', 0),
  sm('SM', 6),
  md('MD', 12),
  lg('LG', 16),
  xl('XL', 24);

  const ThemeRadius(this.label, this.value);
  final String label;
  final double value;
}

/// Scala UI (via [TextScaler]).
enum ThemeScale {
  none('Nessuna', 1.0),
  xs('XS', 0.9),
  lg('LG', 1.15);

  const ThemeScale(this.label, this.factor);
  final String label;
  final double factor;
}

/// Stato del theme playground: unica sorgente della config Gen, mutata dal
/// customizer nell'header e osservata da `ExampleApp` per ricostruire il tema.
class ThemeController extends ChangeNotifier {
  ThemePreset preset = ThemePreset.skillera;
  ThemeRadius radius = ThemeRadius.md;
  ThemeScale scale = ThemeScale.none;
  Brightness brightness = Brightness.light;

  bool get isDark => brightness == Brightness.dark;
  double get textScale => scale.factor;

  /// Config Gen per una data brightness (preset + radius applicati a entrambi).
  GenThemeData dataFor(Brightness b) {
    final base = genSkilleraColorScheme(b == Brightness.dark);
    final p = preset.primary;
    final scheme = p == null
        ? base
        : base.copyWith(
            primary: p,
            primaryForeground: const Color(0xFFFFFFFF),
            ring: p,
            selection: p.withValues(alpha: 0.25),
          );
    return GenThemeData(
      brightness: b,
      colorScheme: scheme,
      radius: BorderRadius.all(Radius.circular(radius.value)),
      iconWeight: 300,
    );
  }

  void setPreset(ThemePreset v) => _set(() => preset = v);
  void setRadius(ThemeRadius v) => _set(() => radius = v);
  void setScale(ThemeScale v) => _set(() => scale = v);
  void setBrightness(Brightness v) => _set(() => brightness = v);
  void toggleBrightness() => setBrightness(isDark ? Brightness.light : Brightness.dark);

  void reset() => _set(() {
        preset = ThemePreset.skillera;
        radius = ThemeRadius.md;
        scale = ThemeScale.none;
        brightness = Brightness.light;
      });

  void _set(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}
