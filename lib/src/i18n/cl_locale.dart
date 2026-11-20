import 'strings.g.dart';

/// La lingua dei testi di genai_components (italiano, inglese, tedesco, francese, spagnolo; la base è l'italiano).
///
/// La libreria traduce con slang, come skillera_emp e il kit di Ops. **L'app chiama [set] all'avvio e a ogni cambio di
/// lingua, e aspetta che finisca**: carica i testi di quella lingua (sul web sono un file a parte) e la imposta. Finché una
/// lingua non è caricata la libreria mostra l'italiano. skillera_emp la chiama in `LocaleController`, accanto a
/// `OpsKitLocale.set` e `SkilleraUiLocale.set`; un'app senza slang (l'LMS con easy_localization, skillera-ops-mobile)
/// all'avvio con la lingua scelta o del telefono. Un'app che non la chiama vede i testi in italiano, come prima.
///
/// In slang la lingua è **una sola per tutta l'app**, comune ai pacchetti: una lingua già caricata la libreria la segue
/// anche quando la cambia l'app col suo `LocaleSettings.setLocale`. I componenti leggono il testo in `build`, quindi
/// dopo il cambio basta che l'app si ricostruisca.
abstract final class CLLocale {
  /// Le lingue della libreria, come codici ISO 639-1 (`it`, `en`, …). La prima è la base.
  static List<String> get supported => [for (final l in CLAppLocale.values) l.languageCode];

  /// La lingua in cui la libreria mostra i testi adesso (`it`, `en`, …).
  static String get current => LocaleSettings.currentLocale.languageCode;

  /// Carica i testi della lingua [code] e li mostra: `en`, anche con la regione (`en_GB`, `fr-CA`, conta solo la
  /// lingua).
  ///
  /// Una lingua che la libreria non ha non cambia niente: se l'ha impostata l'app con le sue traduzioni slang, la
  /// libreria mostra già l'italiano da sé, e la lingua comune resta quella dell'app. Per tornare all'italiano:
  /// `set('it')`.
  static Future<void> set(String code) async {
    final locale = _match(code);
    if (locale == null) return;
    await LocaleSettings.setLocale(locale);
  }

  static CLAppLocale? _match(String code) {
    final language = code.trim().split(RegExp('[-_]')).first.toLowerCase();
    for (final l in CLAppLocale.values) {
      if (l.languageCode == language) return l;
    }
    return null;
  }
}
