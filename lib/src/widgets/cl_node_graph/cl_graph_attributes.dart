import 'cl_graph_models.dart';
import 'cl_graph_values.dart';

/// Tipo di valore di un [CLGraphNodeAttribute]. `enumeration` = scelta fra
/// alternative fisse ([CLGraphNodeAttribute.options]); `enum` è parola riservata.
/// `time` = orario "HH:MM" (stringa), `url` = link http/https (stringa).
enum CLGraphAttributeType { string, numeric, enumeration, boolean, time, url }

/// Controllo aggiuntivo su un valore già valido per tipo e vincoli: messaggio
/// d'errore (mostrato sotto il campo) o null se il valore va bene. Con un
/// costruttore `const` serve una funzione top-level o statica.
typedef CLGraphAttributeValidator = String? Function(Object value);

/// Attributo definito dall'utente su un nodo: nome, tipo, nullabilità, default,
/// vincoli e (solo per `enumeration`) le alternative ammesse. È la
/// *definizione*: il valore corrente vive in `CLGraphNode.attributeValues[name]`.
///
/// La card mostra una riga per attributo sotto l'intestazione (etichetta sopra,
/// campo sotto, testo mai troncato); con `CLNodeGraph.onAttributeChanged` il
/// campo è un input (testo, numero, orario, link, menu di scelta, checkbox) che
/// emette solo valori che passano [validate] e mostra l'errore sotto di sé.
///
/// Valori ammessi per tipo: `string` → `String`, `numeric` → `num` finito,
/// `enumeration` → una delle [options], `boolean` → `bool`, `time` → `String`
/// "HH:MM", `url` → `String` http/https; `null` solo se [nullable]. Una
/// stringa vuota (o di soli spazi) conta come valore mancante.
class CLGraphNodeAttribute {
  final String name; // chiave in attributeValues (univoca nel nodo) ed etichetta della riga
  final CLGraphAttributeType type;
  final bool nullable; // true ⇒ null è un valore ammesso (campo svuotabile, checkbox a tre stati)
  final Object? defaultValue; // valore quando attributeValues non contiene [name]
  final List<String> options; // solo enumeration: alternative ammesse, nell'ordine del menu
  final num? min; // solo numeric: minimo incluso
  final num? max; // solo numeric: massimo incluso
  final bool integer; // solo numeric: niente decimali
  final int? maxLength; // solo string: lunghezza massima in caratteri
  final CLGraphAttributeValidator? validator; // controllo extra dopo quelli di tipo

  /// Costruttore generico (es. da JSON). Preferire i costruttori tipizzati, che
  /// vincolano il tipo del default a compile time.
  const CLGraphNodeAttribute({
    required this.name,
    required this.type,
    this.nullable = false,
    this.defaultValue,
    this.options = const [],
    this.min,
    this.max,
    this.integer = false,
    this.maxLength,
    this.validator,
  });

  const CLGraphNodeAttribute.string({
    required this.name,
    this.nullable = false,
    String? this.defaultValue,
    this.maxLength,
    this.validator,
  })  : type = CLGraphAttributeType.string,
        options = const [],
        min = null,
        max = null,
        integer = false;

  const CLGraphNodeAttribute.numeric({
    required this.name,
    this.nullable = false,
    num? this.defaultValue,
    this.min,
    this.max,
    this.integer = false,
    this.validator,
  })  : type = CLGraphAttributeType.numeric,
        options = const [],
        maxLength = null;

  const CLGraphNodeAttribute.enumeration({
    required this.name,
    required this.options,
    this.nullable = false,
    String? this.defaultValue,
  })  : type = CLGraphAttributeType.enumeration,
        min = null,
        max = null,
        integer = false,
        maxLength = null,
        validator = null;

  const CLGraphNodeAttribute.boolean({
    required this.name,
    this.nullable = false,
    bool? this.defaultValue,
  })  : type = CLGraphAttributeType.boolean,
        options = const [],
        min = null,
        max = null,
        integer = false,
        maxLength = null,
        validator = null;

  /// Orario "HH:MM". Nel campo si scrivono solo le cifre: i due punti si
  /// inseriscono da soli.
  const CLGraphNodeAttribute.time({
    required this.name,
    this.nullable = false,
    String? this.defaultValue,
    this.validator,
  })  : type = CLGraphAttributeType.time,
        options = const [],
        min = null,
        max = null,
        integer = false,
        maxLength = null;

  /// Link http/https. Nel campo si può omettere lo schema: "www.sito.it"
  /// diventa "https://www.sito.it".
  const CLGraphNodeAttribute.url({
    required this.name,
    this.nullable = false,
    String? this.defaultValue,
    this.validator,
  })  : type = CLGraphAttributeType.url,
        options = const [],
        min = null,
        max = null,
        integer = false,
        maxLength = null;

  /// Messaggio d'errore per [value] (tipo, obbligatorietà, vincoli, poi
  /// [validator]), o null se il valore è valido.
  String? validate(Object? value) {
    if (value == null || (value is String && value.trim().isEmpty && type != CLGraphAttributeType.string)) {
      return nullable ? null : 'Obbligatorio';
    }
    switch (type) {
      case CLGraphAttributeType.string:
        if (value is! String) return 'Testo non valido';
        if (!nullable && value.trim().isEmpty) return 'Obbligatorio';
        final length = value.runes.length;
        if (maxLength != null && length > maxLength!) return 'Massimo $maxLength caratteri (ora $length)';
      case CLGraphAttributeType.numeric:
        if (value is! num || !value.isFinite) return 'Numero non valido';
        if (integer && value != value.truncateToDouble()) return 'Serve un numero intero';
        final lo = min, hi = max;
        if (lo != null && hi != null && (value < lo || value > hi)) {
          return 'Valore tra ${clGraphFormatNum(lo)} e ${clGraphFormatNum(hi)}';
        }
        if (lo != null && value < lo) return 'Minimo ${clGraphFormatNum(lo)}';
        if (hi != null && value > hi) return 'Massimo ${clGraphFormatNum(hi)}';
      case CLGraphAttributeType.enumeration:
        if (value is! String || !options.contains(value)) return 'Scelta non valida';
      case CLGraphAttributeType.boolean:
        if (value is! bool) return 'Valore non valido';
      case CLGraphAttributeType.time:
        if (value is! String || !clGraphIsValidTime(value)) return 'Orario non valido (HH:MM)';
      case CLGraphAttributeType.url:
        if (value is! String || !clGraphIsValidUrl(value)) return 'Link non valido (es. www.sito.it)';
    }
    return validator?.call(value);
  }

  /// true se [value] è un valore valido per questo attributo.
  bool accepts(Object? value) => validate(value) == null;

  /// Problema nella definizione (vincoli incoerenti o sul tipo sbagliato,
  /// alternative mancanti o duplicate, default non valido), o null se la
  /// definizione è coerente.
  String? get definitionProblem {
    if (name.isEmpty) return 'nome vuoto';
    if (type == CLGraphAttributeType.enumeration) {
      if (options.isEmpty) return '"$name": enumeration senza alternative';
      if (options.toSet().length != options.length) return '"$name": alternative duplicate';
    } else if (options.isNotEmpty) {
      return '"$name": options ammesse solo per enumeration';
    }
    if (type != CLGraphAttributeType.numeric && (min != null || max != null || integer)) {
      return '"$name": min, max e integer ammessi solo per numeric';
    }
    if (min != null && max != null && min! > max!) return '"$name": min maggiore di max';
    if (maxLength != null && (type != CLGraphAttributeType.string || maxLength! <= 0)) {
      return '"$name": maxLength ammesso solo per string, maggiore di zero';
    }
    if (defaultValue != null) {
      final problem = validate(defaultValue);
      if (problem != null) return '"$name": default $defaultValue non valido ($problem)';
    }
    return null;
  }
}

/// Lettura e aggiornamento dei valori degli attributi di un nodo.
extension CLGraphNodeAttributes on CLGraphNode {
  /// Definizione dell'attributo [name], o null se il nodo non lo ha.
  CLGraphNodeAttribute? attribute(String name) {
    for (final a in attributes) {
      if (a.name == name) return a;
    }
    return null;
  }

  /// Valore effettivo di [name]: quello in `attributeValues` se presente e
  /// valido, altrimenti il default. Null se l'attributo non esiste.
  Object? attributeValue(String name) {
    final a = attribute(name);
    if (a == null) return null;
    return _effectiveValue(a);
  }

  /// Nome → valore effettivo di tutti gli attributi, nell'ordine di [attributes].
  Map<String, Object?> get resolvedAttributeValues => {for (final a in attributes) a.name: _effectiveValue(a)};

  /// Attributi non nullable che non hanno un valore effettivo (nessun valore
  /// valido e nessun default): la card li segna in rosso.
  List<CLGraphNodeAttribute> get missingAttributes =>
      [for (final a in attributes) if (!a.nullable && _effectiveValue(a) == null) a];

  /// Copia del nodo con `attributeValues[name] = value`: è quello che l'host fa
  /// in `CLNodeGraph.onAttributeChanged`.
  CLGraphNode withAttributeValue(String name, Object? value) => CLGraphNode(
        id: id,
        type: type,
        title: title,
        subtitle: subtitle,
        icon: icon,
        accent: accent,
        badge: badge,
        badgeColor: badgeColor,
        data: data,
        actions: actions,
        attributes: attributes,
        attributeValues: {...attributeValues, name: value},
        connectionRules: connectionRules,
      );

  /// Problema nelle definizioni degli attributi o nelle regole di collegamento
  /// del nodo (nomi duplicati, definizioni incoerenti), o null. Controllato in
  /// debug dal widget.
  String? get attributesProblem {
    final rules = connectionRules.definitionProblem;
    if (rules != null) return 'nodo "$id": regole di collegamento, $rules';
    final seen = <String>{};
    for (final a in attributes) {
      if (!seen.add(a.name)) return 'nodo "$id": attributo "${a.name}" duplicato';
      final p = a.definitionProblem;
      if (p != null) return 'nodo "$id": $p';
    }
    return null;
  }

  Object? _effectiveValue(CLGraphNodeAttribute a) {
    if (attributeValues.containsKey(a.name)) {
      final v = attributeValues[a.name];
      if (a.accepts(v)) return v; // anche null esplicito se nullable: svuotato dall'utente
    }
    return a.accepts(a.defaultValue) ? a.defaultValue : null;
  }
}
