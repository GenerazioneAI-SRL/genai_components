import 'package:flutter/services.dart';
import 'cl_graph_attributes.dart';

// Formattazione, controllo e lettura dei valori degli attributi: funzioni pure
// condivise da modello (validate), campi della card e misure del testo.

/// "2.0" ⇒ "2", "2.5" ⇒ "2.5".
String clGraphFormatNum(num n) {
  final s = n.toString();
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

/// Testo di un valore in sola lettura (e nel bottone del menu di scelta).
String clGraphDisplayValue(Object? v) => switch (v) {
      null => '—',
      final bool b => b ? 'Sì' : 'No',
      final num n => clGraphFormatNum(n),
      _ => v.toString(),
    };

final RegExp _time = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// true se [s] è un orario completo "HH:MM" (00:00–23:59).
bool clGraphIsValidTime(String s) => _time.hasMatch(s);

final RegExp _scheme = RegExp(r'^[a-z][a-z0-9+.\-]*://', caseSensitive: false);
final RegExp _host = RegExp(r'^(?:[a-z0-9](?:[a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$');
final RegExp _space = RegExp(r'\s');

/// Aggiunge `https://` a un link scritto senza schema ("www.sito.it").
String clGraphNormalizeUrl(String s) {
  final t = s.trim();
  if (t.isEmpty || _scheme.hasMatch(t)) return t;
  return 'https://$t';
}

/// true se [s] è un link http/https con un dominio (almeno un punto e un
/// dominio di primo livello di lettere, "www." da solo non basta: "www.sito"
/// no, "www.sito.it" sì), senza spazi né credenziali.
bool clGraphIsValidUrl(String s) {
  if (_space.hasMatch(s)) return false;
  final uri = Uri.tryParse(s);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return false;
  if (uri.userInfo.isNotEmpty) return false;
  final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
  return _host.hasMatch(host);
}

/// Esito della lettura del testo di un campo attributo: il valore da emettere
/// ([error] null) oppure l'errore. [deferred] = testo non ancora completo
/// (orario a metà, link senza dominio, obbligatorio vuoto): il campo lo segnala
/// solo quando perde il focus, per non accendere l'errore a ogni tasto.
typedef CLGraphParsedText = ({Object? value, String? error, bool deferred});

CLGraphParsedText _ok(Object? value) => (value: value, error: null, deferred: false);
CLGraphParsedText _later(String error) => (value: null, error: error, deferred: true);

final RegExp _partialTime = RegExp(r'^\d{1,2}(:\d?)?$');
final RegExp _decimalSep = RegExp(',');

/// Legge il testo di un campo string/numeric/time/url: converte (virgola
/// decimale, `https://` mancante) e applica [CLGraphNodeAttribute.validate].
CLGraphParsedText clGraphParseText(CLGraphNodeAttribute a, String text) {
  final t = text.trim();
  if (t.isEmpty) return a.nullable ? _ok(null) : _later('Obbligatorio');
  final Object value;
  switch (a.type) {
    case CLGraphAttributeType.string:
      value = text;
    case CLGraphAttributeType.numeric:
      var n = num.tryParse(t.replaceAll(_decimalSep, '.'));
      if (n == null || !n.isFinite) return _later('Numero non valido');
      if (a.integer && n is double && n == n.truncateToDouble()) n = n.toInt();
      value = n;
    case CLGraphAttributeType.time:
      if (!clGraphIsValidTime(t) && _partialTime.hasMatch(t)) return _later('Completa l\'orario (HH:MM)');
      value = t;
    case CLGraphAttributeType.url:
      final url = clGraphNormalizeUrl(t);
      if (!clGraphIsValidUrl(url)) return _later('Link non valido (es. www.sito.it)');
      value = url;
    case CLGraphAttributeType.enumeration:
    case CLGraphAttributeType.boolean:
      value = text; // non sono campi di testo: validate lo rifiuta se serve
  }
  final error = a.validate(value);
  return error == null ? _ok(value) : (value: null, error: error, deferred: false);
}

/// Completa un orario lasciato a metà quando il campo perde il focus: "9" o
/// "09" ⇒ "09:00". Altro testo invariato.
String clGraphCompleteTime(String text) {
  final t = text.trim();
  if (!RegExp(r'^\d{1,2}$').hasMatch(t) || int.parse(t) > 23) return text;
  return '${t.padLeft(2, '0')}:00';
}

/// Maschera orario "HH:MM": si scrivono solo le cifre e i due punti arrivano da
/// soli. Un'ora che non può iniziare con quella cifra prende lo zero davanti
/// ("9" ⇒ "09", minuti "7" ⇒ "07"), le ore oltre 23 non si possono scrivere e
/// un separatore dopo una sola cifra completa l'ora ("9:" ⇒ "09"). Vale anche
/// per testo incollato o che sostituisce tutto; le cancellazioni invece
/// riformattano senza aggiungere nulla (altrimenti lo zero e i due punti
/// tornerebbero subito).
class CLGraphTimeInputFormatter extends TextInputFormatter {
  const CLGraphTimeInputFormatter();

  static final RegExp _nonDigit = RegExp(r'\D');
  static final RegExp _hourThenSeparator = RegExp(r'^\d[:.,]$');

  /// [now] è [old] con un tratto contiguo rimosso (backspace, canc, taglia).
  static bool _isDeletion(String old, String now) {
    if (now.length >= old.length) return false;
    var p = 0;
    while (p < now.length && now.codeUnitAt(p) == old.codeUnitAt(p)) {
      p++;
    }
    return old.endsWith(now.substring(p));
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(_nonDigit, '');
    if (!_isDeletion(oldValue.text, newValue.text)) {
      if (_hourThenSeparator.hasMatch(newValue.text)) digits = '0$digits';
      if (digits.length > 4) return oldValue;
      if (digits.isNotEmpty && int.parse(digits[0]) > 2) digits = '0$digits';
      if (digits.length >= 3 && int.parse(digits[2]) > 5) {
        digits = '${digits.substring(0, 2)}0${digits.substring(2)}';
      }
      if (digits.length > 4) return oldValue;
      if (digits.length >= 2 && int.parse(digits.substring(0, 2)) > 23) return oldValue;
    }
    final text = digits.length > 2 ? '${digits.substring(0, 2)}:${digits.substring(2)}' : digits;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
