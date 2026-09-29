import 'cl_graph_models.dart';

/// Altezza di una riga attributo nella card: la card di un nodo con N
/// attributi è alta `kCardH + N * kGraphAttributeRowH` (vedi `clGraphNodeHeight`).
const double kGraphAttributeRowH = 32;

/// Tipo di valore di un [CLGraphNodeAttribute]. `enumeration` = scelta fra
/// alternative fisse ([CLGraphNodeAttribute.options]); `enum` è parola riservata.
enum CLGraphAttributeType { string, numeric, enumeration, boolean }

/// Attributo definito dall'utente su un nodo: nome, tipo, nullabilità, default
/// e (solo per `enumeration`) le alternative ammesse. È la *definizione*: il
/// valore corrente vive in `CLGraphNode.attributeValues[name]`.
///
/// La card mostra una riga per attributo sotto l'intestazione; con
/// `CLNodeGraph.onAttributeChanged` la riga diventa un input (campo testo,
/// campo numerico, menu di scelta, checkbox).
///
/// Valori ammessi per tipo: `string` → `String`, `numeric` → `num` finito,
/// `enumeration` → una delle [options], `boolean` → `bool`; `null` solo se
/// [nullable].
class CLGraphNodeAttribute {
  final String name; // chiave in attributeValues (univoca nel nodo) ed etichetta della riga
  final CLGraphAttributeType type;
  final bool nullable; // true ⇒ null è un valore ammesso (campo svuotabile, checkbox a tre stati)
  final Object? defaultValue; // valore quando attributeValues non contiene [name]
  final List<String> options; // solo enumeration: alternative ammesse, nell'ordine del menu

  /// Costruttore generico (es. da JSON). Preferire i costruttori tipizzati, che
  /// vincolano il tipo del default a compile time.
  const CLGraphNodeAttribute({
    required this.name,
    required this.type,
    this.nullable = false,
    this.defaultValue,
    this.options = const [],
  });

  const CLGraphNodeAttribute.string({
    required this.name,
    this.nullable = false,
    String? this.defaultValue,
  })  : type = CLGraphAttributeType.string,
        options = const [];

  const CLGraphNodeAttribute.numeric({
    required this.name,
    this.nullable = false,
    num? this.defaultValue,
  })  : type = CLGraphAttributeType.numeric,
        options = const [];

  const CLGraphNodeAttribute.enumeration({
    required this.name,
    required this.options,
    this.nullable = false,
    String? this.defaultValue,
  }) : type = CLGraphAttributeType.enumeration;

  const CLGraphNodeAttribute.boolean({
    required this.name,
    this.nullable = false,
    bool? this.defaultValue,
  })  : type = CLGraphAttributeType.boolean,
        options = const [];

  /// true se [value] è un valore valido per questo attributo.
  bool accepts(Object? value) {
    if (value == null) return nullable;
    switch (type) {
      case CLGraphAttributeType.string:
        return value is String;
      case CLGraphAttributeType.numeric:
        return value is num && value.isFinite;
      case CLGraphAttributeType.enumeration:
        return value is String && options.contains(value);
      case CLGraphAttributeType.boolean:
        return value is bool;
    }
  }

  /// Problema nella definizione (default non valido, alternative mancanti o
  /// duplicate), o null se la definizione è coerente.
  String? get definitionProblem {
    if (name.isEmpty) return 'nome vuoto';
    if (type == CLGraphAttributeType.enumeration) {
      if (options.isEmpty) return '"$name": enumeration senza alternative';
      if (options.toSet().length != options.length) return '"$name": alternative duplicate';
    } else if (options.isNotEmpty) {
      return '"$name": options ammesse solo per enumeration';
    }
    if (defaultValue != null && !accepts(defaultValue)) {
      return '"$name": default $defaultValue non valido per ${type.name}';
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
  /// valido per il tipo, altrimenti il default. Null se l'attributo non esiste.
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
      );

  /// Problema nelle definizioni degli attributi del nodo (nomi duplicati o
  /// definizione incoerente), o null. Controllato in debug dal widget.
  String? get attributesProblem {
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
      if (a.accepts(v)) return v;
    }
    return a.accepts(a.defaultValue) ? a.defaultValue : null;
  }
}
