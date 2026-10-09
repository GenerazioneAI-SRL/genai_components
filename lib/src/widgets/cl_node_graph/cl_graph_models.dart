import 'package:flutter/widgets.dart';
import 'cl_graph_attributes.dart';
import 'cl_graph_ports.dart';

/// Azione/indicatore su una card del grafo, resa come slot in alto a destra.
/// Di norma un'icona tappabile (es. frecce ordine ▲▼); con [label] mostra invece
/// un testo (es. numero d'ordine corrente) e con [interactive] `false` diventa
/// puro display (nessun hotspot, non tappabile).
class CLGraphNodeAction {
  final String id;
  final IconData? icon; // usato quando [label] è null
  final String? label; // testo al posto dell'icona (es. posizione corrente)
  final String? tooltip;
  final bool interactive; // false ⇒ solo visuale, nessun hit-test (non tappabile)
  const CLGraphNodeAction({
    required this.id,
    this.icon,
    this.label,
    this.tooltip,
    this.interactive = true,
  }) : assert(icon != null || label != null, 'CLGraphNodeAction richiede icon o label');
}

/// Regole di collegamento di un nodo per gli archi di flusso
/// ([CLGraphEdgeKind.prerequisite]: porta OUT della sorgente → porta IN del
/// bersaglio): da quali tipi di nodo può ricevere archi, verso quali tipi può
/// proseguire e quanti archi deve/può avere per lato. I tipi sono i valori di
/// `CLGraphNode.type`.
///
/// Il widget le applica mentre si collega: i bersagli non ammessi si
/// attenuano, il motivo compare accanto al cursore e `onEdgeCreate` non
/// scatta. I minimi non si possono imporre durante la modifica: un nodo che
/// non li rispetta mostra un avviso nella card (vedi `clGraphConnectionWarnings`).
class CLGraphConnectionRules {
  /// Tipi ammessi come sorgente di un arco in ingresso. null ⇒ qualsiasi tipo;
  /// vuoto ⇒ nessun ingresso (la card non mostra la porta IN).
  final Set<String>? inputTypes;

  /// Tipi ammessi come bersaglio di un arco in uscita. null ⇒ qualsiasi tipo;
  /// vuoto ⇒ nessuna uscita (la card non mostra la porta OUT).
  final Set<String>? outputTypes;

  final int minInputs; // 0 ⇒ ingresso facoltativo
  final int? maxInputs; // null ⇒ illimitati
  final int minOutputs; // 0 ⇒ uscita facoltativa
  final int? maxOutputs; // null ⇒ illimitate

  const CLGraphConnectionRules({
    this.inputTypes,
    this.outputTypes,
    this.minInputs = 0,
    this.maxInputs,
    this.minOutputs = 0,
    this.maxOutputs,
  });

  /// Nessun vincolo: il comportamento dei nodi senza regole.
  static const any = CLGraphConnectionRules();

  /// Il nodo può ricevere almeno un arco in ingresso.
  bool get acceptsInputs => maxInputs != 0 && (inputTypes == null || inputTypes!.isNotEmpty);

  /// Il nodo può avere almeno un arco in uscita.
  bool get acceptsOutputs => maxOutputs != 0 && (outputTypes == null || outputTypes!.isNotEmpty);

  /// Problema nella definizione (minimi negativi o maggiori del massimo, minimo
  /// su un lato che non ammette archi), o null se coerente.
  String? get definitionProblem {
    if (minInputs < 0 || minOutputs < 0) return 'minimi negativi';
    if (maxInputs != null && maxInputs! < minInputs) return 'maxInputs < minInputs';
    if (maxOutputs != null && maxOutputs! < minOutputs) return 'maxOutputs < minOutputs';
    if (minInputs > 0 && !acceptsInputs) return 'minInputs > 0 ma nessun ingresso ammesso';
    if (minOutputs > 0 && !acceptsOutputs) return 'minOutputs > 0 ma nessuna uscita ammessa';
    return null;
  }
}

/// Nodo del grafo, indipendente dal motore di rendering.
class CLGraphNode {
  final String id;
  final String type; // libero: 'module' | 'course' | 'lesson' | 'exam' | 'resource' | ...
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accent;
  final String? badge; // pill in alto (es. nome modulo)
  final Color? badgeColor; // colore della pill (default: accent)
  final Object? data; // payload opaco per il consumer
  /// Azioni immediate: icone tappabili in alto a destra della card (es. frecce
  /// ordine ▲▼). Vuoto ⇒ nessuna icona. L'host cabla il comportamento via
  /// `CLNodeGraph.onNodeAction`.
  final List<CLGraphNodeAction> actions;
  /// Attributi definiti dall'utente (nome, tipo, nullable, default, vincoli):
  /// una riga ciascuno sotto l'intestazione, la card si allunga. Vuoto ⇒ card
  /// classica 220×96, comportamento invariato. Modificabili via
  /// `CLNodeGraph.onAttributeChanged`.
  final List<CLGraphNodeAttribute> attributes;
  /// Valori correnti degli attributi, per nome. Chiave assente ⇒ default
  /// dell'attributo (vedi `CLGraphNodeAttributes.attributeValue`).
  final Map<String, Object?> attributeValues;
  /// Quali nodi può avere in ingresso e in uscita. Default: nessun vincolo.
  final CLGraphConnectionRules connectionRules;
  /// Porte d'ingresso con nome, sul bordo sinistro (vedi [CLGraphPort]). Vuoto
  /// (default) ⇒ nessuna porta con nome: la card si comporta come prima.
  final List<CLGraphPort> inputPorts;
  /// Porte d'uscita con nome, sul bordo destro (es. `sì`/`no`).
  final List<CLGraphPort> outputPorts;

  const CLGraphNode({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent,
    this.badge,
    this.badgeColor,
    this.data,
    this.actions = const [],
    this.attributes = const [],
    this.attributeValues = const {},
    this.connectionRules = CLGraphConnectionRules.any,
    this.inputPorts = const [],
    this.outputPorts = const [],
  });

  /// Il nodo ha porte con nome (su almeno un lato).
  bool get hasNamedPorts => inputPorts.isNotEmpty || outputPorts.isNotEmpty;

  /// Porta d'ingresso [id], o null.
  CLGraphPort? inputPort(String id) {
    for (final p in inputPorts) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Porta d'uscita [id], o null.
  CLGraphPort? outputPort(String id) {
    for (final p in outputPorts) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Larghezza fissa di ogni card (i layout ragionano su colonne larghe così).
const double kCardW = 220;

/// Altezza minima della card: include la pill badge (modulo) sopra titolo e
/// sottotitolo su una riga. Titoli lunghi, avvisi e attributi la allungano.
const double kCardH = 96;

/// Offset verticale (sotto il centro del bordo destro) della porta triangolino
/// "link-lezione". Condiviso tra il widget (che disegna il triangolino) e il
/// painter (che ancora gli archi [CLGraphEdgeKind.lessonLink] a quel punto), così
/// la porta e l'arco restano allineati da un'unica sorgente di verità.
const double kTriDy = 26;

/// Offset verticale (SOPRA il centro, su entrambi i bordi) delle porte a rombo
/// degli archi [CLGraphEdgeKind.propaedeutic]: OUT a destra, IN a sinistra.
/// Condiviso tra widget (porte) e painter (ancore degli archi).
const double kPropDy = 26;

/// Tipo di arco: contenimento (gerarchia), flusso (`prerequisite`, porta a
/// pallino), ordine, link-lezione o propedeuticità.
/// - [prerequisite]: arco di flusso, pallino OUT (dx, centro) → pallino IN (sx, centro);
///   conta per i layout.
/// - [lessonLink]: parte dalla porta triangolino (sotto il pallino).
/// - [propaedeutic]: «A è propedeutica a B», porta a rombo sopra il pallino
///   (vedi [kPropDy]), tratteggiato; NON conta per i layout.
/// - [flow]: arco generico da una porta d'uscita con nome a una porta
///   d'ingresso con nome (`CLGraphEdge.fromPortId`/`toPortId`), con etichetta
///   facoltativa a metà arco; conta per `clFlowLayout`. Non è soggetto a
///   `CLGraphConnectionRules` (si valida con `CLNodeGraph.canConnectPorts`).
enum CLGraphEdgeKind { containment, prerequisite, order, lessonLink, propaedeutic, flow }

class CLGraphEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final CLGraphEdgeKind kind;
  /// Arco strutturale (conta per il layout) ma NON disegnato. Utile per il
  /// containment verso risorse già collegate visivamente da una freccia prereq.
  final bool hidden;
  /// false ⇒ l'arco si disegna ma non si seleziona né si elimina (niente
  /// cestino): per archi derivati dai dati (es. la sequenza da un ordine).
  final bool deletable;
  /// Porta d'uscita della sorgente ([CLGraphEdgeKind.flow]). Null ⇒ prima porta
  /// d'uscita del nodo (o il bordo destro se non ne ha).
  final String? fromPortId;
  /// Porta d'ingresso del bersaglio ([CLGraphEdgeKind.flow]). Null ⇒ prima
  /// porta d'ingresso del nodo (o il bordo sinistro se non ne ha).
  final String? toPortId;
  /// Etichetta a metà arco (solo [CLGraphEdgeKind.flow]), es. la condizione.
  final String? label;

  const CLGraphEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.kind,
    this.hidden = false,
    this.deletable = true,
    this.fromPortId,
    this.toPortId,
    this.label,
  });
}

/// Strategia di posizionamento: da nodi+archi a coordinate.
typedef CLGraphLayout = Map<String, Offset> Function(
  List<CLGraphNode> nodes,
  List<CLGraphEdge> edges,
);
