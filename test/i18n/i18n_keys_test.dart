import 'package:flutter_test/flutter_test.dart';

import '../../tool/i18n_check.dart';

/// Le traduzioni della libreria sono complete: ogni lingua (it, en, de, fr, es) ha le chiavi dell'italiano, coi suoi
/// stessi parametri. È `dart run tool/i18n_check.dart` dentro i test: una chiave dimenticata in una lingua non rompe la
/// build (slang mostra l'italiano), quindi senza questo test passerebbe in silenzio.
void main() {
  test('ogni lingua ha tutte le chiavi dell\'italiano, con gli stessi parametri', () {
    final report = i18nCheck();
    expect(report.problems, isEmpty, reason: 'dart run tool/i18n_check.dart per l\'elenco');
    expect(report.locales, i18nLocales.length);
    expect(report.namespaces, greaterThan(0), reason: 'lib/src/i18n/it/ ha almeno un namespace (il test non passa a vuoto)');
  });
}
