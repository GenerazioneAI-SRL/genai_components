// Elenca le stringhe del codice che **sembrano testo per una persona** e non
// passano dalle traduzioni (`l10n.`): serve a chi estrae i testi di una cartella, per
// partire e per controllare cosa è rimasto.
//
//   dart run tool/i18n_scan.dart lib/src/chat
//   dart run tool/i18n_scan.dart --count lib          solo i totali per cartella (README, «Cosa resta»)
//
// È un'euristica, non una regola: stampa candidati da valutare a occhio (un
// valore mandato all'API può avere l'aspetto di una parola italiana). Per
// questo esce sempre con 0.
//
// Segnala anche ciò che fissa l'italiano senza essere un testo: `'it_IT'` e la
// virgola decimale messa a mano.
//
// Copiato da `tool/i18n_scan.dart` del kit di Ops (skillera_ops_kit); cambiano solo i suggerimenti.
import 'dart:io';

final _literal = RegExp(r'''(?<![A-Za-z0-9_])r?(?:'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)")''');
final _word = RegExp(r'[A-Za-zÀ-ÿ]{2,}');
final _technical = RegExp(r'^[a-z0-9_.\-/:]+$');
final _camel = RegExp(r'^[A-Za-z]+[A-Z][a-z]+[A-Za-z]*$');
final _capitalized = RegExp(r'^[A-ZÀ-Ý][a-zà-ÿ]{2,}[.:!?…]?$');
final _namedDatePattern = RegExp(r'^[EMdyHhmsLQ ,.:/\-]+$');

/// Righe che non mostrano niente a nessuno.
final _skipLine = RegExp(
    r'^\s*(//|import |export |part |@)|debugPrint\(|\bprint\(|\blog\(|\bassert\(|\bRegExp\(|\bKey\(|ValueKey\(|\bthrow\b|AppRoute\(');

void main(List<String> args) {
  final countOnly = args.contains('--count');
  final roots = args.where((a) => !a.startsWith('--')).toList();
  if (roots.isEmpty) {
    stderr.writeln('uso: dart run tool/i18n_scan.dart [--count] <cartella o file>…');
    exit(2);
  }
  final perDir = <String, int>{};
  var total = 0;
  for (final root in roots) {
    for (final file in _dartFiles(root)) {
      final lines = file.readAsLinesSync();
      var inRoute = false;
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // `AppRoute(` su più righe: il `name:` è un identificativo, non un testo.
        if (line.contains('AppRoute(')) inRoute = !line.contains(');');
        final routeName = inRoute && line.trimLeft().startsWith('name:');
        if (inRoute && line.contains(');')) inRoute = false;
        for (final hit in _hits(line, skip: routeName)) {
          total++;
          final dir = file.parent.path;
          perDir[dir] = (perDir[dir] ?? 0) + 1;
          if (!countOnly) stdout.writeln('${file.path}:${i + 1}: $hit');
        }
      }
    }
  }
  if (countOnly) {
    final dirs = perDir.keys.toList()..sort();
    for (final d in dirs) {
      stdout.writeln('${perDir[d].toString().padLeft(5)}  $d');
    }
  }
  stdout.writeln('\n$total candidati.');
}

Iterable<File> _dartFiles(String root) sync* {
  if (FileSystemEntity.isFileSync(root)) {
    yield File(root);
    return;
  }
  final files = Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  yield* files;
}

Iterable<String> _hits(String line, {required bool skip}) sync* {
  if (line.contains("replaceAll('.', ',')")) yield "virgola decimale a mano → un formato di numeri della lingua";
  if (skip || _skipLine.hasMatch(line)) return;
  // Il commento in coda alla riga non conta.
  final cut = line.indexOf(' // ');
  final code = cut < 0 ? line : line.substring(0, cut);
  for (final m in _literal.allMatches(code)) {
    final text = m.group(1) ?? m.group(2) ?? '';
    if (text.isEmpty) continue;
    if (text == 'it_IT' || (text == 'it' && code.contains('ocale'))) {
      yield "'$text' → la lingua la dà l'app (CLLocale): togli l'argomento";
      continue;
    }
    if (_namedDatePattern.hasMatch(text)) {
      // Un formato di data: conta solo se scrive nomi di mesi o giorni.
      if (text.contains('MMM') || text.contains('EEE')) yield "'$text' → i nomi di mesi e giorni di clL10n.common.date";
      continue;
    }
    if (_technical.hasMatch(text) || _camel.hasMatch(text) || !_word.hasMatch(text)) continue;
    if (text.contains(' ') || _capitalized.hasMatch(text)) yield "'$text'";
  }
}
