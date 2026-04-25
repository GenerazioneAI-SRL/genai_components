import 'package:flutter/foundation.dart';

/// Stato dedicato alla visibilità dell'header dell'app.
///
/// Estende [ValueNotifier] di `bool` per esporre la visibilità corrente.
/// Pensato per sostituire `NavigationState.headerTitleVisible` a partire
/// dalla versione 5.0 del pacchetto `genai_components`.
///
/// Uso tipico:
/// ```dart
/// final headerVisibility = HeaderVisibilityState();
/// headerVisibility.hide();
/// headerVisibility.show();
/// headerVisibility.toggle();
/// ```
class HeaderVisibilityState extends ValueNotifier<bool> {
  /// Crea lo stato con un valore [initial] di default a `true`.
  HeaderVisibilityState({bool initial = true}) : super(initial);

  /// Imposta la visibilità a `true`.
  void show() => value = true;

  /// Imposta la visibilità a `false`.
  void hide() => value = false;

  /// Inverte il valore corrente della visibilità.
  void toggle() => value = !value;
}
