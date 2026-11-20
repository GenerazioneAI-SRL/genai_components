// Controlla che le traduzioni della libreria (`lib/src/i18n/`) siano complete e coerenti:
// per ogni namespace, ogni lingua ha le stesse chiavi dell'italiano (la base)
// e ogni testo usa gli stessi parametri (`$nome`, `${nome}`).
//
//   dart run tool/i18n_check.dart            tutte le lingue
//   dart run tool/i18n_check.dart chat       solo i namespace indicati
//
// Esce con 1 se qualcosa non torna, con l'elenco. slang da solo non lo dice:
// con `fallback_strategy: base_locale` una chiave che manca mostra l'italiano
// in silenzio, e un parametro dimenticato in una traduzione sparisce dal testo.
// Lo stesso controllo gira nei test (`test/i18n/i18n_keys_test.dart`), quindi in CI.
//
// Copiato da `tool/i18n_check.dart` del kit di Ops (skillera_ops_kit), uguale.
import 'dart:convert';
import 'dart:io';

const _base = 'it';
const _root = 'lib/src/i18n';
const _suffix = '.i18n.json';
const _pluralForms = {'zero', 'one', 'two', 'few', 'many', 'other'};

/// Le lingue che il kit deve avere tutte (README, «Traduzioni»).
const i18nLocales = ['it', 'en', 'de', 'fr', 'es'];

final _param = RegExp(r'(?<!\\)\$\{?([A-Za-z_][A-Za-z0-9_]*)');

void main(List<String> args) {
  final report = i18nCheck(only: args.toSet());
  if (report.problems.isEmpty) {
    stdout.writeln('i18n: ${report.namespaces} namespace, ${report.keys} testi, ${report.locales} lingue — tutto a posto.');
    return;
  }
  report.problems.forEach(stdout.writeln);
  stdout.writeln('\ni18n: ${report.problems.length} problemi.');
  exit(1);
}

/// Il risultato del controllo: i problemi (vuoto = tutto a posto) e quanti namespace, testi e lingue ha visto.
typedef I18nReport = ({List<String> problems, int namespaces, int keys, int locales});

/// Controlla le traduzioni di [root] (di serie `lib/src/i18n`, relativa alla radice del repo). [only]: solo quei namespace.
I18nReport i18nCheck({Set<String> only = const {}, String root = _root}) {
  final problems = <String>[];
  if (!Directory(root).existsSync()) {
    return (problems: ['Manca la cartella delle traduzioni: $root'], namespaces: 0, keys: 0, locales: 0);
  }
  final locales = Directory(root)
      .listSync()
      .whereType<Directory>()
      .map((d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last)
      .toList()
    ..sort();
  for (final want in i18nLocales) {
    if (!locales.contains(want)) problems.add('Manca la cartella della lingua «$want»: $root/$want');
  }
  if (!locales.contains(_base)) {
    return (problems: problems, namespaces: 0, keys: 0, locales: locales.length);
  }
  final namespaces = _namespaces(root, _base).where((n) => only.isEmpty || only.contains(n)).toList()..sort();
  var keys = 0;

  for (final ns in namespaces) {
    final base = _load(root, _base, ns, problems);
    if (base == null) continue;
    keys += base.length;
    for (final locale in locales.where((l) => l != _base)) {
      final other = _load(root, locale, ns, problems);
      if (other == null) continue;
      for (final key in base.keys) {
        if (!other.containsKey(key)) {
          problems.add('$locale/$ns: manca «$key»');
          continue;
        }
        final want = base[key]!;
        final got = other[key]!;
        if (!_sameParams(want, got)) {
          problems.add('$locale/$ns: «$key» ha i parametri ${_fmt(got)}, la base ${_fmt(want)}');
        }
      }
      for (final key in other.keys) {
        if (!base.containsKey(key)) problems.add('$locale/$ns: «$key» non esiste nella base');
      }
    }
  }
  // Un file che esiste in una lingua ma non nella base.
  for (final locale in locales.where((l) => l != _base)) {
    for (final ns in _namespaces(root, locale)) {
      if (only.isNotEmpty && !only.contains(ns)) continue;
      if (!File('$root/$_base/$ns$_suffix').existsSync()) {
        problems.add('$locale/$ns: il namespace non esiste nella base');
      }
    }
  }
  return (problems: problems, namespaces: namespaces.length, keys: keys, locales: locales.length);
}

List<String> _namespaces(String root, String locale) => Directory('$root/$locale')
    .listSync()
    .whereType<File>()
    .map((f) => f.uri.pathSegments.last)
    .where((n) => n.endsWith(_suffix))
    .map((n) => n.substring(0, n.length - _suffix.length))
    .toList();

/// Le foglie del file: percorso → insieme dei parametri. Un nodo di plurale
/// (`one`/`other`…) è una foglia sola: le lingue hanno forme diverse, i
/// parametri devono essere gli stessi.
Map<String, Set<String>>? _load(String root, String locale, String ns, List<String> problems) {
  final file = File('$root/$locale/$ns$_suffix');
  if (!file.existsSync()) {
    problems.add('$locale/$ns: manca il file ${file.path}');
    return null;
  }
  final Object? json;
  try {
    json = jsonDecode(file.readAsStringSync());
  } on FormatException catch (e) {
    problems.add('$locale/$ns: JSON non valido (${e.message})');
    return null;
  }
  if (json is! Map) {
    problems.add('$locale/$ns: la radice non è un oggetto');
    return null;
  }
  final out = <String, Set<String>>{};
  void walk(String path, Object? node) {
    if (node is Map) {
      final names = node.keys.map((k) => '$k').toSet();
      if (names.isNotEmpty && names.every(_pluralForms.contains) && node.values.every((v) => v is String)) {
        if (!names.contains('other')) problems.add('$locale/$ns: il plurale «$path» non ha la forma «other»');
        // `n` è il numero del plurale: c'è sempre, anche se una forma non lo scrive.
        out[path] = {for (final v in node.values) ..._params('$v')}..add('n');
        return;
      }
      node.forEach((k, v) => walk(path.isEmpty ? '$k' : '$path.$k', v));
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        walk('$path[$i]', node[i]);
      }
    } else if (node is String) {
      out[path] = _params(node);
      if (node.trim().isEmpty) problems.add('$locale/$ns: «$path» è vuoto');
    } else {
      problems.add('$locale/$ns: «$path» non è un testo');
    }
  }

  walk('', json);
  return out;
}

Set<String> _params(String text) => _param.allMatches(text).map((m) => m.group(1)!).toSet();

bool _sameParams(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

String _fmt(Set<String> params) => params.isEmpty ? '(nessuno)' : (params.toList()..sort()).map((p) => '\$$p').join(' ');
