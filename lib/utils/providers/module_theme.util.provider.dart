import 'dart:async';
import 'package:flutter/material.dart';
import '../../cl_theme.dart';

/// Suite principali dell'app Skillera con palette colori dedicate.
///
/// **Nota:** Questo enum è specifico per il progetto Skillera.
/// Per progetti generici, usa [CLThemeProvider] con temi custom.
@Deprecated('Specifico per Skillera. Usa CLThemeProvider con temi custom.')
enum SkilleraModule { concierge, id, hr, cert, lms }

/// Palette colori per una suite (light + dark)
@Deprecated('Specifico per Skillera. Usa CLThemeProvider con temi custom.')
class ModulePalette {
  final Color lightPrimary;
  final Color lightSecondary;
  final Color darkPrimary;
  final Color darkSecondary;

  const ModulePalette({
    required this.lightPrimary,
    required this.lightSecondary,
    required this.darkPrimary,
    required this.darkSecondary,
  });
}

/// Provider che gestisce il cambio palette in base alla suite corrente.
///
/// **Deprecato:** Specifico per il progetto Skillera. Per nuovi progetti usa
/// [CLThemeProvider] che accetta qualsiasi istanza di [CLTheme].
///
/// Due concetti separati:
/// - [currentModule]: la suite della pagina attiva (controlla CLTheme.primary)
/// - [selectedModule]: la suite selezionata nel top bar (controlla la sidebar)
///
/// Quando l'utente clicca un tab nel top bar, cambia solo [selectedModule]
/// (la sidebar si aggiorna). Quando naviga effettivamente in una pagina,
/// [updateFromRoute] aggiorna [currentModule] e il tema cambia.
@Deprecated('Specifico per Skillera. Usa CLThemeProvider con temi custom.')
class ModuleThemeProvider extends ChangeNotifier {
  SkilleraModule _currentModule = SkilleraModule.concierge;
  SkilleraModule _selectedModule = SkilleraModule.concierge;
  Timer? _transitionTimer;

  /// La suite della pagina attiva — controlla CLTheme.primary, bottoni, link.
  SkilleraModule get currentModule => _currentModule;

  /// La suite selezionata nel top bar — controlla la sidebar e il tab attivo.
  SkilleraModule get selectedModule => _selectedModule;

  // ── Palette per suite ──────────────────────────────────────
  static const Map<SkilleraModule, ModulePalette> palettes = {
    SkilleraModule.concierge: ModulePalette(
      lightPrimary: Color(0xFF0C8EC7),
      lightSecondary: Color(0xFF0A7AAD),
      darkPrimary: Color(0xFF3BA8D8),
      darkSecondary: Color(0xFF0C8EC7),
    ),
    SkilleraModule.id: ModulePalette(
      lightPrimary: Color(0xFF0C8EC7),
      lightSecondary: Color(0xFF0A7AAD),
      darkPrimary: Color(0xFF3BA8D8),
      darkSecondary: Color(0xFF0C8EC7),
    ),
    SkilleraModule.hr: ModulePalette(
      lightPrimary: Color(0xFFE8734A),
      lightSecondary: Color(0xFFC85A32),
      darkPrimary: Color(0xFFEF8F6A),
      darkSecondary: Color(0xFFE8734A),
    ),
    SkilleraModule.cert: ModulePalette(
      lightPrimary: Color(0xFF16A34A),
      lightSecondary: Color(0xFF138A3E),
      darkPrimary: Color(0xFF4ADE80),
      darkSecondary: Color(0xFF16A34A),
    ),
    SkilleraModule.lms: ModulePalette(
      lightPrimary: Color(0xFF7C3AED),
      lightSecondary: Color(0xFF6527CC),
      darkPrimary: Color(0xFFA78BFA),
      darkSecondary: Color(0xFF7C3AED),
    ),
  };

  // ── Getter colori attivi (basati su currentModule, non selectedModule) ──
  ModulePalette get _activePalette => palettes[_currentModule]!;

  Color get lightPrimary => _activePalette.lightPrimary;
  Color get lightSecondary => _activePalette.lightSecondary;
  Color get darkPrimary => _activePalette.darkPrimary;
  Color get darkSecondary => _activePalette.darkSecondary;

  // ── Cache istanze CLTheme ──────────────────────────────────
  CLTheme? _cachedLight;
  CLTheme? _cachedDark;

  CLTheme get lightTheme => _cachedLight ??= LightModeTheme(primary: lightPrimary, secondary: lightSecondary);
  CLTheme get darkTheme => _cachedDark ??= DarkModeTheme(primary: darkPrimary, secondary: darkSecondary);

  void _invalidateCache() {
    _cachedLight = null;
    _cachedDark = null;
  }

  /// Chiamato dal top bar: cambia solo la sidebar, non il tema.
  void selectModule(SkilleraModule module) {
    if (module != _selectedModule) {
      _selectedModule = module;
      notifyListeners();
    }
  }

  /// Chiamato ad ogni cambio route: aggiorna il tema E allinea la sidebar.
  void updateFromRoute(String path) {
    final newModule = _moduleFromPath(path);
    bool changed = false;
    if (newModule != _currentModule) {
      _transitionTimer?.cancel();
      _currentModule = newModule;
      _invalidateCache();
      changed = true;
    }
    if (newModule != _selectedModule) {
      _selectedModule = newModule;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  // Kept for backward compat — delegates to selectModule
  void updateFromModule(SkilleraModule newModule) => selectModule(newModule);

  static SkilleraModule _moduleFromPath(String path) {
    if (path.startsWith('/skill-hr')) return SkilleraModule.hr;
    if (path.startsWith('/skill-cert')) return SkilleraModule.cert;
    if (path.startsWith('/skill-lms')) return SkilleraModule.lms;
    if (path.startsWith('/skill-id')) return SkilleraModule.id;
    return SkilleraModule.concierge;
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }
}
