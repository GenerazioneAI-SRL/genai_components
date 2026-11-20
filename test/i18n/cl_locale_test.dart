import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';
import 'package:genai_components/src/i18n/l10n.dart';
import 'package:slang/slang.dart';
// La lingua comune di slang: è quella che cambia l'app quando usa slang per i suoi testi.
// ignore: implementation_imports
import 'package:slang/src/api/state.dart';

/// La libreria segue la lingua dell'app: con [CLLocale.set], che carica la lingua e la imposta; una lingua già caricata
/// la segue anche quando la cambia l'app con slang (la lingua di slang è comune).
void main() {
  // I test possono girare nello stesso isolate: si torna sempre all'italiano.
  tearDown(() => CLLocale.set('it'));

  test('di serie è l\'italiano, la base', () {
    expect(CLLocale.supported, ['it', 'de', 'en', 'es', 'fr']);
    expect(CLLocale.current, 'it');
    expect(clL10n.common.actions.cancel, 'Annulla');
    expect(clL10n.table.endOfList, 'Non ci sono altri risultati');
  });

  test('set: la lingua, anche con la regione', () async {
    await CLLocale.set('en');
    expect(CLLocale.current, 'en');
    expect(clL10n.dropdown.placeholder, 'Select…');
    await CLLocale.set('fr-CA');
    expect(clL10n.common.actions.cancel, 'Annuler');
    await CLLocale.set('de_DE');
    expect(clL10n.common.actions.cancel, 'Abbrechen');
    await CLLocale.set('ES');
    expect(clL10n.common.actions.cancel, 'Cancelar');
  });

  test('una lingua che la libreria non ha non cambia la lingua comune', () async {
    await CLLocale.set('en');
    await CLLocale.set('pt');
    expect(CLLocale.current, 'en');
  });

  test('una lingua già caricata la segue anche se la imposta un altro pacchetto con slang (l\'app); una che non ha diventa l\'italiano', () async {
    await CLLocale.set('de'); // la carica
    await CLLocale.set('it');
    GlobalLocaleState.instance.setLocale(FakeAppLocale(languageCode: 'de'));
    expect(clL10n.common.actions.cancel, 'Abbrechen');
    GlobalLocaleState.instance.setLocale(FakeAppLocale(languageCode: 'pt'));
    expect(CLLocale.current, 'it');
    expect(clL10n.common.actions.cancel, 'Annulla');
  });

  test('i plurali e i valori di serie in italiano', () async {
    expect(clL10n.table.selectedCount(n: 1), '1 selezionato');
    expect(clL10n.table.selectedCount(n: 3), '3 selezionati');
    expect(clDefault('Conferma', 'Conferma', clL10n.common.actions.confirm), 'Conferma');
    await CLLocale.set('en');
    expect(clDefault('Conferma', 'Conferma', clL10n.common.actions.confirm), 'Confirm');
    expect(clDefault('Apri', 'Conferma', clL10n.common.actions.confirm), 'Apri');
  });
}
