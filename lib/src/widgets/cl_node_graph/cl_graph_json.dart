import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'cl_graph_attributes.dart';
import 'cl_graph_layout.dart';
import 'cl_graph_models.dart';

/// Stato di vista che l'app può salvare insieme al grafo. Non fa parte del
/// grafo: posizioni trascinate, zoom e pan restano interni al widget e non si
/// esportano.
class CLGraphView {
  /// Nome del layout, es. una chiave di [CLGraphJson.builtInLayouts]
  /// ('prereqFlow') o un nome scelto dall'app per un layout suo.
  final String? layout;
  final String? selectedNodeId;
  final List<String> collapsedNodeIds;

  const CLGraphView({this.layout, this.selectedNodeId, this.collapsedNodeIds = const []});
}

/// Grafo esportabile/importabile: nodi e archi come li riceve `CLNodeGraph`,
/// più lo stato di vista facoltativo.
class CLGraphDocument {
  final List<CLGraphNode> nodes;
  final List<CLGraphEdge> edges;
  final CLGraphView? view;
  final DateTime? exportedAt;

  /// Solo in lettura: problemi che non impediscono di usare il documento
  /// (icona non presente nel registro, valore di attributo non valido, vista
  /// che nomina nodi inesistenti). Vuoto ⇒ letto senza perdite.
  final List<String> warnings;

  const CLGraphDocument({
    required this.nodes,
    required this.edges,
    this.view,
    this.exportedAt,
    this.warnings = const [],
  });
}

/// Export/import dei grafi in JSON (formato [format], versione [version]).
///
/// Il JSON ricalca le classi della libreria (stesse chiavi, enum col loro
/// nome). Quattro cose non sono dati JSON e hanno una codifica dedicata:
/// - icone: codePoint + font; in lettura si ritrovano in [icons], perché
///   `IconData` non si ricostruisce da un codePoint (le icone non costanti
///   rompono il tree-shaking dei font);
/// - colori: stringa `#AARRGGBB`;
/// - controlli personalizzati degli attributi: si salva il nome sotto cui la
///   funzione è registrata in [validators];
/// - `data` del nodo e valori degli attributi: devono essere già JSON
///   (null, bool, numeri finiti, stringhe, liste, mappe con chiavi stringa).
///
/// La scrittura è deterministica (stesse chiavi, stesso ordine, ogni chiave
/// sempre presente) e la lettura la inverte: `encode(decode(encode(doc)))`
/// dà lo stesso JSON. La lettura tollera le chiavi facoltative mancanti
/// (valgono i default) e ignora quelle sconosciute.
class CLGraphJson {
  static const String format = 'cl_node_graph';
  static const int version = 1;

  /// I layout della libreria per nome, da usare in [CLGraphView.layout].
  static const Map<String, CLGraphLayout> builtInLayouts = {
    'hierarchical': clHierarchicalLayout,
    'prereqFlow': clPrereqFlowLayout,
    'moduleFlow': clModuleFlowLayout,
  };

  /// Nome di un layout della libreria, o null se è un layout dell'app.
  static String? layoutName(CLGraphLayout? layout) {
    for (final e in builtInLayouts.entries) {
      if (identical(e.value, layout)) return e.key;
    }
    return null;
  }

  const CLGraphJson({this.icons = const [], this.validators = const {}});

  /// Icone che la lettura sa ricostruire (confronto su codePoint e font).
  final Iterable<IconData> icons;

  /// Controlli personalizzati degli attributi per nome: la scrittura salva il
  /// nome, la lettura ritrova la funzione. Un controllo non registrato è un
  /// errore in entrambe le direzioni (perderlo allenterebbe la validazione).
  final Map<String, CLGraphAttributeValidator> validators;

  // ── Scrittura ────────────────────────────────────────────────────────────

  /// Documento come mappa JSON. Lancia [ArgumentError] se `data` o un valore
  /// di attributo non è JSON, o se un attributo usa un controllo non
  /// registrato in [validators].
  Map<String, Object?> encode(CLGraphDocument doc) => {
        'format': format,
        'version': version,
        'exportedAt': doc.exportedAt?.toUtc().toIso8601String(),
        'nodes': [for (var i = 0; i < doc.nodes.length; i++) _node(doc.nodes[i], 'nodes[$i]')],
        'edges': [for (final e in doc.edges) _edge(e)],
        'view': doc.view == null ? null : _view(doc.view!),
      };

  /// Documento come testo JSON ([pretty]: indentato di due spazi).
  String encodeString(CLGraphDocument doc, {bool pretty = true}) =>
      (pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder()).convert(encode(doc));

  Map<String, Object?> _node(CLGraphNode n, String path) => {
        'id': n.id,
        'type': n.type,
        'title': n.title,
        'subtitle': n.subtitle,
        'icon': n.icon == null ? null : _icon(n.icon!),
        'accent': n.accent == null ? null : _color(n.accent!),
        'badge': n.badge,
        'badgeColor': n.badgeColor == null ? null : _color(n.badgeColor!),
        'data': _checkJson(n.data, '$path.data'),
        'actions': [for (final a in n.actions) _action(a)],
        'attributes': [for (var i = 0; i < n.attributes.length; i++) _attribute(n.attributes[i], '$path.attributes[$i]')],
        'attributeValues': {
          for (final e in n.attributeValues.entries) e.key: _checkJson(e.value, '$path.attributeValues.${e.key}'),
        },
        'connectionRules': _rules(n.connectionRules),
      };

  Map<String, Object?> _action(CLGraphNodeAction a) => {
        'id': a.id,
        'icon': a.icon == null ? null : _icon(a.icon!),
        'label': a.label,
        'tooltip': a.tooltip,
        'interactive': a.interactive,
      };

  Map<String, Object?> _attribute(CLGraphNodeAttribute a, String path) => {
        'name': a.name,
        'type': a.type.name,
        'nullable': a.nullable,
        'defaultValue': _checkJson(a.defaultValue, '$path.defaultValue'),
        'options': a.options,
        'min': a.min,
        'max': a.max,
        'integer': a.integer,
        'maxLength': a.maxLength,
        'validator': a.validator == null ? null : _validatorName(a.validator!, path),
      };

  Map<String, Object?> _rules(CLGraphConnectionRules r) => {
        'inputTypes': r.inputTypes?.toList(),
        'outputTypes': r.outputTypes?.toList(),
        'minInputs': r.minInputs,
        'maxInputs': r.maxInputs,
        'minOutputs': r.minOutputs,
        'maxOutputs': r.maxOutputs,
      };

  Map<String, Object?> _edge(CLGraphEdge e) => {
        'id': e.id,
        'fromNodeId': e.fromNodeId,
        'toNodeId': e.toNodeId,
        'kind': e.kind.name,
        'hidden': e.hidden,
        if (!e.deletable) 'deletable': false,
      };

  Map<String, Object?> _view(CLGraphView v) => {
        'layout': v.layout,
        'selectedNodeId': v.selectedNodeId,
        'collapsedNodeIds': v.collapsedNodeIds,
      };

  Map<String, Object?> _icon(IconData icon) => {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'matchTextDirection': icon.matchTextDirection,
      };

  String _color(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  String _validatorName(CLGraphAttributeValidator v, String path) {
    for (final e in validators.entries) {
      if (identical(e.value, v) || e.value == v) return e.key;
    }
    throw ArgumentError('$path.validator: controllo non registrato in CLGraphJson.validators');
  }

  /// [value] così com'è se è JSON, altrimenti [ArgumentError] con il percorso.
  Object? _checkJson(Object? value, String path) {
    switch (value) {
      case null || bool() || String():
        return value;
      case num n:
        if (!n.isFinite) throw ArgumentError('$path: numero non finito ($n)');
        return value;
      case List<Object?> list:
        for (var i = 0; i < list.length; i++) {
          _checkJson(list[i], '$path[$i]');
        }
        return value;
      case Map<Object?, Object?> map:
        for (final e in map.entries) {
          if (e.key is! String) throw ArgumentError('$path: chiave non stringa (${e.key})');
          _checkJson(e.value, '$path.${e.key}');
        }
        return value;
      default:
        throw ArgumentError('$path: ${value.runtimeType} non è un valore JSON');
    }
  }

  // ── Lettura ──────────────────────────────────────────────────────────────

  /// Documento da testo JSON. Lancia [FormatException] (col percorso della
  /// chiave) se il documento non è valido.
  CLGraphDocument decodeString(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw FormatException('JSON non valido: ${e.message}', source, e.offset);
    }
    return decode(json);
  }

  /// Documento da JSON già decodificato. Errori (documento rifiutato):
  /// formato o versione sconosciuti, chiavi obbligatorie mancanti o del tipo
  /// sbagliato, valori enum sconosciuti, id di nodi o archi duplicati, archi
  /// verso nodi inesistenti, definizioni di attributi o regole incoerenti,
  /// controlli non registrati. Il resto finisce in [CLGraphDocument.warnings].
  CLGraphDocument decode(Object? json) {
    final warnings = <String>[];
    final root = _R(json, '').map();
    final fmt = root.req<String>('format');
    if (fmt != format) root.fail('format', 'atteso "$format", trovato "$fmt"');
    final ver = root.req<int>('version');
    if (ver < 1 || ver > version) root.fail('version', 'versione $ver non supportata (massimo $version)');
    final exportedAtText = root.opt<String>('exportedAt');
    DateTime? exportedAt;
    if (exportedAtText != null) {
      exportedAt = DateTime.tryParse(exportedAtText);
      if (exportedAt == null) root.fail('exportedAt', 'data ISO 8601 non valida');
    }

    final nodes = <CLGraphNode>[];
    final nodeIds = <String>{};
    final nodesJson = root.list('nodes', required: true);
    for (var i = 0; i < nodesJson.length; i++) {
      final n = _readNode(nodesJson[i], warnings);
      if (!nodeIds.add(n.id)) nodesJson[i].fail('id', 'id "${n.id}" duplicato');
      nodes.add(n);
    }

    final edges = <CLGraphEdge>[];
    final edgeIds = <String>{};
    for (final r in root.list('edges', required: true)) {
      final e = _readEdge(r);
      if (!edgeIds.add(e.id)) r.fail('id', 'id "${e.id}" duplicato');
      if (!nodeIds.contains(e.fromNodeId)) r.fail('fromNodeId', 'nodo "${e.fromNodeId}" inesistente');
      if (!nodeIds.contains(e.toNodeId)) r.fail('toNodeId', 'nodo "${e.toNodeId}" inesistente');
      edges.add(e);
    }

    CLGraphView? view;
    final viewJson = root.child('view');
    if (viewJson != null) {
      view = CLGraphView(
        layout: viewJson.opt<String>('layout'),
        selectedNodeId: viewJson.opt<String>('selectedNodeId'),
        collapsedNodeIds: [for (final r in viewJson.list('collapsedNodeIds')) r.value<String>()],
      );
      for (final id in [if (view.selectedNodeId != null) view.selectedNodeId!, ...view.collapsedNodeIds]) {
        if (!nodeIds.contains(id)) warnings.add('view: nodo "$id" inesistente');
      }
    }

    return CLGraphDocument(nodes: nodes, edges: edges, view: view, exportedAt: exportedAt, warnings: warnings);
  }

  CLGraphNode _readNode(_R r, List<String> warnings) {
    final m = r.map();
    final id = m.req<String>('id');
    if (id.isEmpty) m.fail('id', 'id vuoto');
    final attributes = [for (final a in m.list('attributes')) _readAttribute(a)];
    final valuesJson = m.child('attributeValues')?.map();
    final values = <String, Object?>{
      if (valuesJson != null)
        for (final k in valuesJson.keys) k: valuesJson.any(k),
    };
    final rulesJson = m.child('connectionRules')?.map();
    final node = CLGraphNode(
      id: id,
      type: m.req<String>('type'),
      title: m.req<String>('title'),
      subtitle: m.opt<String>('subtitle'),
      icon: _readIcon(m.child('icon'), warnings),
      accent: _readColor(m, 'accent'),
      badge: m.opt<String>('badge'),
      badgeColor: _readColor(m, 'badgeColor'),
      data: m.any('data'),
      actions: [for (final a in m.list('actions')) _readAction(a, warnings)],
      attributes: attributes,
      attributeValues: values,
      connectionRules: rulesJson == null ? CLGraphConnectionRules.any : _readRules(rulesJson),
    );
    final problem = node.attributesProblem;
    if (problem != null) r.fail(null, problem);
    for (final a in attributes) {
      if (!values.containsKey(a.name)) continue;
      final error = a.validate(values[a.name]);
      if (error != null) warnings.add('${r.path}.attributeValues.${a.name}: $error (vale il default)');
    }
    return node;
  }

  CLGraphNodeAction _readAction(_R r, List<String> warnings) {
    final m = r.map();
    final icon = _readIcon(m.child('icon'), warnings);
    var label = m.opt<String>('label');
    if (icon == null && label == null) {
      if (m.child('icon') == null) m.fail(null, 'serve icon o label');
      label = '?'; // icona fuori registro: segnaposto visibile invece di un'azione senza contenuto
    }
    return CLGraphNodeAction(
      id: m.req<String>('id'),
      icon: icon,
      label: label,
      tooltip: m.opt<String>('tooltip'),
      interactive: m.opt<bool>('interactive') ?? true,
    );
  }

  CLGraphNodeAttribute _readAttribute(_R r) {
    final m = r.map();
    final validatorName = m.opt<String>('validator');
    final validator = validatorName == null ? null : validators[validatorName];
    if (validatorName != null && validator == null) {
      m.fail('validator', 'controllo "$validatorName" non registrato in CLGraphJson.validators');
    }
    return CLGraphNodeAttribute(
      name: m.req<String>('name'),
      type: m.enumValue('type', CLGraphAttributeType.values),
      nullable: m.opt<bool>('nullable') ?? false,
      defaultValue: m.any('defaultValue'),
      options: [for (final o in m.list('options')) o.value<String>()],
      min: m.opt<num>('min'),
      max: m.opt<num>('max'),
      integer: m.opt<bool>('integer') ?? false,
      maxLength: m.opt<int>('maxLength'),
      validator: validator,
    );
  }

  CLGraphConnectionRules _readRules(_R m) {
    Set<String>? types(String key) {
      if (m.child(key) == null) return null;
      return {for (final t in m.list(key)) t.value<String>()};
    }

    return CLGraphConnectionRules(
      inputTypes: types('inputTypes'),
      outputTypes: types('outputTypes'),
      minInputs: m.opt<int>('minInputs') ?? 0,
      maxInputs: m.opt<int>('maxInputs'),
      minOutputs: m.opt<int>('minOutputs') ?? 0,
      maxOutputs: m.opt<int>('maxOutputs'),
    );
  }

  CLGraphEdge _readEdge(_R r) {
    final m = r.map();
    return CLGraphEdge(
      id: m.req<String>('id'),
      fromNodeId: m.req<String>('fromNodeId'),
      toNodeId: m.req<String>('toNodeId'),
      kind: m.enumValue('kind', CLGraphEdgeKind.values),
      hidden: m.opt<bool>('hidden') ?? false,
      deletable: m.opt<bool>('deletable') ?? true,
    );
  }

  IconData? _readIcon(_R? r, List<String> warnings) {
    if (r == null) return null;
    final m = r.map();
    final codePoint = m.req<int>('codePoint');
    final family = m.opt<String>('fontFamily');
    final package = m.opt<String>('fontPackage');
    for (final icon in icons) {
      if (icon.codePoint == codePoint && icon.fontFamily == family && icon.fontPackage == package) return icon;
    }
    warnings.add('${r.path}: icona 0x${codePoint.toRadixString(16)} ($family) non presente in CLGraphJson.icons, omessa');
    return null;
  }

  static final RegExp _hexColor = RegExp(r'^#[0-9A-Fa-f]{8}$');

  Color? _readColor(_R m, String key) {
    final s = m.opt<String>(key);
    if (s == null) return null;
    if (!_hexColor.hasMatch(s)) m.fail(key, 'colore atteso come #AARRGGBB, trovato "$s"');
    return Color(int.parse(s.substring(1), radix: 16));
  }
}

/// Lettore con percorso: ogni errore dice dove (`nodes[2].attributes[0].type`).
class _R {
  _R(this._json, this.path);

  final Object? _json;
  final String path;

  String _at(String? key) => key == null ? path : (path.isEmpty ? key : '$path.$key');

  Never fail(String? key, String message) {
    final where = _at(key);
    throw FormatException(where.isEmpty ? message : '$where: $message');
  }

  _R map() {
    if (_json is! Map<String, Object?>) fail(null, 'atteso un oggetto');
    return this;
  }

  Map<String, Object?> get _m => _json as Map<String, Object?>;

  Iterable<String> get keys => _m.keys;

  T value<T>() {
    final v = _json;
    if (v is! T) fail(null, 'atteso ${_typeName<T>()}');
    return v;
  }

  T req<T>(String key) {
    final v = _m[key];
    if (v == null) fail(key, 'obbligatorio');
    if (v is! T) fail(key, 'atteso ${_typeName<T>()}');
    return v as T;
  }

  T? opt<T>(String key) {
    final v = _m[key];
    if (v == null) return null;
    if (v is! T) fail(key, 'atteso ${_typeName<T>()}');
    return v as T;
  }

  /// Qualsiasi valore JSON (data, default, valori degli attributi).
  Object? any(String key) => _m[key];

  _R? child(String key) => _m[key] == null ? null : _R(_m[key], _at(key));

  List<_R> list(String key, {bool required = false}) {
    final v = _m[key];
    if (v == null) {
      if (required) fail(key, 'obbligatorio');
      return const [];
    }
    if (v is! List) fail(key, 'atteso un array');
    return [for (var i = 0; i < v.length; i++) _R(v[i], '${_at(key)}[$i]')];
  }

  E enumValue<E extends Enum>(String key, List<E> values) {
    final name = req<String>(key);
    for (final v in values) {
      if (v.name == name) return v;
    }
    fail(key, 'valore "$name" sconosciuto (ammessi: ${values.map((v) => v.name).join(', ')})');
  }

  static String _typeName<T>() => switch (T) {
        const (String) => 'una stringa',
        const (int) => 'un intero',
        const (num) => 'un numero',
        const (bool) => 'un booleano',
        _ => '$T',
      };
}
