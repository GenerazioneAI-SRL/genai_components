import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_models.dart';
import 'cl_graph_collapse.dart';
import 'cl_graph_layout.dart';
import 'cl_graph_edge_painter.dart';
import 'cl_graph_geometry.dart';
import 'cl_graph_attribute_fields.dart';
import 'cl_graph_card_metrics.dart';
import 'cl_graph_connections.dart';
import 'cl_graph_ports.dart';
import 'cl_node_palette.widget.dart';

// kCardW / kCardH vivono in cl_graph_models.dart: condivisi con le misure delle card.
const double _pad = 60; // margine attorno al bounding box
const double _kDotSize = 16; // diametro del pallino di connessione prereq
const double _kDiamond = 12; // lato del rombo (porta propedeuticità), prima della rotazione
const double _kDotInset = 4; // gap del pallino dal bordo inferiore della card
const double _kChevron = 24; // area cliccabile chevron collasso (top-left card)
const double _kActionSize = 24; // area cliccabile di ogni icona azione (top-right card) — mirror _kChevron
const double _kActionGap = 4; // gap orizzontale tra icone azione adiacenti
// _kTriDy vive in cl_graph_models.dart (kTriDy) — condiviso col painter.
const double _kTrashR = 14; // raggio hit del cestino attorno al midpoint dell'arco
const double _kDimmed = 0.35; // opacità dei bersagli non ammessi durante un collegamento
const double _kStatusBadge = 20; // diametro del bollino di stato / errori sull'angolo della card
const double _kZoomButton = 40; // lato dei pulsanti zoom

/// Sotto vincoli stretti il canvas prende la misura della viewport invece della
/// propria: le card che (in coordinate canvas) cadono oltre quella misura non
/// ricevono l'hit-test standard, quindi i campi attributo non si potrebbero
/// toccare. L'OverflowBox lascia al Transform la misura naturale del canvas.
/// Attivo solo quando ci sono attributi, così i grafi senza restano identici.
Widget _naturalCanvasSize({required bool enabled, required Widget child}) => enabled
    ? OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: child,
      )
    : child;

/// Riposiziona in verticale le card dopo il layout quando alcune sono più alte
/// di [kCardH] (testo a capo, avvisi, attributi): [heights] = altezza di ogni
/// card per id. I layout ragionano su righe da [kCardH]: ogni "riga" (nodi con
/// la stessa y) scende della somma delle altezze extra delle righe sopra, così
/// le righe restano allineate e le distanze originali si conservano. Le x non
/// cambiano. Se nessuna card supera [kCardH] restituisce [positions] invariato.
Map<String, Offset> clSeparateTallNodes(Map<String, Offset> positions, Map<String, double> heights) {
  final extraByRow = <double, double>{for (final p in positions.values) p.dy: 0};
  var any = false;
  for (final e in heights.entries) {
    final p = positions[e.key];
    if (p == null) continue;
    final extra = e.value - kCardH;
    if (extra <= 0) continue;
    any = true;
    if (extra > extraByRow[p.dy]!) extraByRow[p.dy] = extra;
  }
  if (!any) return positions;
  final rows = extraByRow.keys.toList()..sort();
  final shift = <double, double>{};
  var acc = 0.0;
  for (final y in rows) {
    shift[y] = acc;
    acc += extraByRow[y]!;
  }
  return {for (final e in positions.entries) e.key: e.value.translate(0, shift[e.value.dy]!)};
}

/// Ancora porta OUT (destra, "sblocca"): sul bordo destro della card (il pallino
/// è disegnato a cavallo del bordo). Sorgente della linea pending. Stesso
/// spazio-coordinate di `rects` (canvas-local).
Offset _outAnchor(Rect r) => Offset(r.right, r.center.dy);

/// X (card-local, dal bordo sinistro) dello slot dell'azione `i` su `n` azioni,
/// ancorate a destra: le icone formano una riga in alto a destra. Unica formula
/// per render (in `_nodeCard`) e hit-test (in `_hitTest`) ⇒ allineamento
/// pixel-perfetto, come il chevron condivide `_kDotInset`/`_kChevron`.
double _actionSlotLeft(int i, int n) =>
    kCardW - _kDotInset - _kActionSize - (n - 1 - i) * (_kActionSize + _kActionGap);

/// Cosa c'è sotto il pointer al momento del down. Determina l'interazione:
/// una sola pipeline pointer-raw hit-testa e smista — nessun GestureDetector
/// annidato, quindi nessuna arena da vincere (era la causa del "a volte muove
/// la card, a volte tutto il canvas").
enum _Mode { none, node, port, chevron, action, edge, trash, pan, input }

/// Canvas a nodi data-driven: render nodi+archi da `nodes`/`edges`, tap→select,
/// drag-porta (dx→sx) per creare prereq, drag-corpo per spostare il nodo
/// (effimero), hover arco→cestino per eliminare, "Ordina" per risnappare al
/// layout. Nessun motore imperativo: si ridisegna dalle props.
///
/// Collegamenti: le regole di ogni nodo (`CLGraphNode.connectionRules`)
/// decidono quali porte mostrare e quali archi si possono creare. Durante un
/// collegamento i bersagli non ammessi si attenuano e il motivo compare
/// accanto al cursore; al rilascio su un bersaglio non ammesso scatta
/// [onConnectionRejected] invece di [onEdgeCreate]. I minimi non rispettati
/// compaiono come avviso nella card.
///
/// Testo: titolo, sottotitolo, etichette, valori ed errori vanno a capo e la
/// card si allunga (larghezza fissa [kCardW]), niente puntini di troncamento.
///
/// Gesture: UN solo [Listener] raw a livello viewport. Su pointer-down un
/// hit-test manuale (in coord canvas) decide il [_Mode]; move/up smistano di
/// conseguenza. Zoom con rotella. Niente InteractiveViewer, niente
/// GestureDetector annidati → interazione deterministica.
///
/// **Editor a porte con nome** (opt-in, dal 5.14.0): nodi con
/// `CLGraphNode.inputPorts`/`outputPorts`, archi [CLGraphEdgeKind.flow] da porta
/// a porta ([onFlowEdgeCreate], [canConnectPorts]), posizioni salvate
/// dall'host ([nodePositions], [onNodeMoved], [onArrange]), rilascio dalla
/// `CLNodePalette` ([onNodeDrop]), stato di esecuzione ed errori di
/// validazione sui nodi ([nodeStatuses], [nodeErrors]), cammino percorso
/// ([highlightedEdgeIds]). Senza questi parametri il widget si comporta come
/// prima.
class CLNodeGraph extends StatefulWidget {
  final List<CLGraphNode> nodes;
  final List<CLGraphEdge> edges;
  final String? selectedNodeId;
  final void Function(String nodeId)? onNodeTap;
  final void Function(String fromNodeId, String toNodeId, CLGraphEdgeKind kind)? onEdgeCreate; // from=sorgente handle
  final void Function(String edgeId, CLGraphEdgeKind kind)? onEdgeDelete;
  final Future<bool> Function(String childNodeId, String newParentNodeId)? onReparent; // DEPRECATO: reparent rimosso, no-op (compat consumer)
  final bool Function(CLGraphNode node)? canDrag; // DEPRECATO: il corpo ora sposta il nodo, no-op (compat consumer)
  final bool Function(CLGraphNode node)? canConnect; // true ⇒ mostra le porte di connessione prereq
  final bool Function(CLGraphNode node)? showOutPort; // true ⇒ solo il pallino OUT (dx) decorativo (es. modulo), senza connect
  final bool Function(CLGraphNode node)? showLessonPort; // true ⇒ triangolino (dx, sotto OUT) handle link-lezione (es. corso)
  final CLGraphLayout? layout;
  final bool showArrangeButton; // true ⇒ pulsante "Ordina" (svuota le posizioni manuali → snap al layout)
  final Set<String>? collapsedNodeIds; // nodi collassati ⇒ discendenti nascosti, archi re-anchored
  final void Function(String nodeId)? onToggleCollapse; // tap sul chevron
  final bool Function(CLGraphNode node)? canCollapse; // true ⇒ mostra il chevron di collasso
  /// Tap su un'icona azione della card (`CLGraphNode.actions`). `globalPos` = la
  /// posizione globale del pointer al rilascio (per ancorare un popup lato host).
  final void Function(String nodeId, String actionId, Offset globalPos)? onNodeAction;
  /// Modifica di un attributo dalla card (`CLGraphNode.attributes`): nuovo
  /// valore, già valido per il tipo (`null` solo se l'attributo è nullable).
  /// Il widget non aggiorna il nodo: l'host lo sostituisce, es. con
  /// `node.withAttributeValue(attributeName, value)`. Null ⇒ attributi in sola lettura.
  final void Function(String nodeId, String attributeName, Object? value)? onAttributeChanged;
  /// Rilascio di un collegamento su un bersaglio che le regole non ammettono
  /// (o già collegato): nessun arco creato, [reason] è il messaggio mostrato.
  final void Function(String fromNodeId, String toNodeId, String reason)? onConnectionRejected;
  /// Nome leggibile di un tipo di nodo nei messaggi sui collegamenti (es.
  /// 'action' ⇒ 'Azione'). Null ⇒ il tipo così com'è.
  final String Function(String type)? typeLabel;
  /// true ⇒ il nodo ha le porte a ROMBO della propedeuticità (OUT a destra e IN
  /// a sinistra, [kPropDy] sopra il centro), distinte dal pallino di flusso.
  /// Trascinando dal rombo di A sul nodo B scatta `onEdgeCreate(A, B,
  /// CLGraphEdgeKind.propaedeutic)`: «A è propedeutica a B». Null ⇒ nessuna porta.
  final bool Function(CLGraphNode node)? canConnectPropaedeutic;
  /// Motivo per cui [to] non può ricevere la propedeuticità da [from] (es. ambito
  /// diverso), o null se ammessa. Il bersaglio si attenua e il motivo compare
  /// accanto al cursore, come per le regole di flusso. Self e duplicati li
  /// rifiuta già il widget.
  final String? Function(CLGraphNode from, CLGraphNode to)? propaedeuticProblem;
  /// Tooltip della porta a rombo.
  final String propaedeuticTooltip;
  /// Colore di porte e archi della propedeuticità. Null ⇒ `theme.info`.
  final Color? propaedeuticColor;

  // ── Porte con nome e archi flow ─────────────────────────────────────────
  /// Trascinamento da una porta d'uscita con nome a una porta d'ingresso con
  /// nome (rilascio sulla porta o sulla card: vale la porta d'ingresso più
  /// vicina al cursore). Null ⇒ si usa [onEdgeCreate] con
  /// [CLGraphEdgeKind.flow]. Senza nessuno dei due le porte sono decorative.
  final void Function(CLGraphPortRef from, CLGraphPortRef to)? onFlowEdgeCreate;
  /// Motivo per cui l'arco flow [from] → [to] non è ammesso, o null. Chiamato
  /// al volo durante il trascinamento: il bersaglio si attenua e il motivo
  /// compare accanto al cursore. Self, duplicati e `CLGraphPort.maxConnections`
  /// li controlla già il widget.
  final String? Function(CLGraphPortRef from, CLGraphPortRef to)? canConnectPorts;
  /// Colore di porte con nome e archi flow. Null ⇒ `theme.mutedForeground`.
  final Color? flowColor;

  // ── Posizioni salvate ───────────────────────────────────────────────────
  /// Posizioni (angolo in alto a sinistra) dei nodi decise dall'host, per id.
  /// I nodi presenti qui non seguono [layout]; quelli assenti sì. Valori
  /// negativi ammessi (il canvas si allarga).
  final Map<String, Offset>? nodePositions;
  /// Fine del trascinamento di un nodo, con la posizione nuova nelle stesse
  /// coordinate di [nodePositions]. Con [nodePositions] il nodo resta dove
  /// l'host lo mette (se l'host non aggiorna la mappa torna indietro).
  final void Function(String nodeId, Offset position)? onNodeMoved;
  /// Pulsante «Ordina» ([showArrangeButton]): posizioni nuove calcolate con
  /// [layout] per tutti i nodi visibili, da salvare in [nodePositions].
  final void Function(Map<String, Offset> positions)? onArrange;

  // ── Palette ─────────────────────────────────────────────────────────────
  /// Rilascio di una voce della `CLNodePalette` sul canvas: [type] del nodo e
  /// posizione (angolo in alto a sinistra, coordinate di [nodePositions]) con
  /// la card centrata sul puntatore. Null ⇒ il canvas non accetta rilasci.
  final void Function(String type, Offset position)? onNodeDrop;

  // ── Stato ───────────────────────────────────────────────────────────────
  /// Stato di esecuzione per nodo: bordo colorato e bollino sull'angolo in alto
  /// a sinistra con tooltip; [CLGraphNodeStatus.skipped] attenua la card.
  final Map<String, CLGraphNodeStatus>? nodeStatuses;
  /// Errori di validazione per nodo: bordo `danger` e bollino «!» sull'angolo
  /// in alto a destra con i messaggi nel tooltip.
  final Map<String, List<String>>? nodeErrors;
  /// Archi del cammino percorso, disegnati più spessi in [highlightColor].
  final Set<String>? highlightedEdgeIds;
  /// Colore del cammino percorso. Null ⇒ `theme.success`.
  final Color? highlightColor;
  /// Etichetta di uno stato (tooltip e lettore di schermo). Null ⇒
  /// [clGraphNodeStatusLabel].
  final String Function(CLGraphNodeStatus status)? statusLabel;

  // ── Selezione ───────────────────────────────────────────────────────────
  /// Tocco nel vuoto del canvas (es. per chiudere il pannello del nodo).
  final VoidCallback? onBackgroundTap;

  const CLNodeGraph({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNodeId,
    this.onNodeTap,
    this.onEdgeCreate,
    this.onEdgeDelete,
    this.onReparent,
    this.canDrag,
    this.canConnect,
    this.showOutPort,
    this.showLessonPort,
    this.layout,
    this.showArrangeButton = false,
    this.collapsedNodeIds,
    this.onToggleCollapse,
    this.canCollapse,
    this.onNodeAction,
    this.onAttributeChanged,
    this.onConnectionRejected,
    this.typeLabel,
    this.canConnectPropaedeutic,
    this.propaedeuticProblem,
    this.propaedeuticTooltip = 'Propedeuticità',
    this.propaedeuticColor,
    this.onFlowEdgeCreate,
    this.canConnectPorts,
    this.flowColor,
    this.nodePositions,
    this.onNodeMoved,
    this.onArrange,
    this.onNodeDrop,
    this.nodeStatuses,
    this.nodeErrors,
    this.highlightedEdgeIds,
    this.highlightColor,
    this.statusLabel,
    this.onBackgroundTap,
  });

  @override
  State<CLNodeGraph> createState() => _CLNodeGraphState();
}

class _CLNodeGraphState extends State<CLNodeGraph> {
  String? _selectedEdgeId;
  String? _hoveredEdgeId; // arco prereq sotto il cursore ⇒ evidenziato + cestino
  // Connessione DRAG-TO-CONNECT (prereq): drag dalla porta OUT (dx) di A → pending
  // da A; la linea segue il cursore fino al rilascio sulla porta IN (sx) di B che
  // crea l'arco, o al rilascio nel vuoto che annulla. Coord canvas-local.
  String? _pendingFromId; // sorgente della connessione in corso
  CLGraphEdgeKind _pendingKind = CLGraphEdgeKind.prerequisite; // flusso (pallino) o propedeuticità (rombo)
  CLGraphEdgeKind _hitPortKind = CLGraphEdgeKind.prerequisite; // porta colpita dall'ultimo hit-test
  Offset? _pendingCursor; // posizione cursore canvas-local (destinazione linea pending)
  String? _pendingPortId; // porta d'uscita con nome della connessione flow in corso
  String? _hitPortId; // porta con nome colpita dall'ultimo hit-test
  final Map<String, Offset> _manualPos = {}; // override effimero del layout (drag-move)
  Matrix4 _matrix = Matrix4.identity(); // pan/zoom — aggiornata via setState (stesso path del drag-nodo)
  bool _fitApplied = false; // fit iniziale applicato una sola volta

  // --- Stato della pipeline pointer-raw (nessuna arena) ---
  _Mode _mode = _Mode.none;
  String? _targetId; // nodo (node/chevron/action) o arco (edge/trash) del gesto corrente
  String? _pendingActionId; // azione colpita dall'hit-test (per _Mode.action) → callback su pointer-up
  int? _activePointer; // pointer che ha iniziato il gesto (ignora i secondari)
  Offset _downViewport = Offset.zero; // per la soglia tap↔drag
  Offset _lastViewport = Offset.zero; // per il delta di pan (screen space)
  Offset _lastCanvas = Offset.zero; // per il delta di drag-nodo (canvas space)
  bool _moved = false; // superata la soglia ⇒ è un drag, non un tap
  // Discrimine tap↔drag robusto per trackpad force-touch: la sola soglia
  // kTouchSlop scarta un "click" che sul force-touch può viaggiare decine di px
  // (drift della pressione). Un tap è un rilascio RAPIDO o con spostamento netto
  // contenuto — non solo `!_moved`.
  double _lastPinchScale = 1.0; // scala cumulativa dell'ultimo campione pinch (trackpad)

  // Geometria dell'ultimo frame, letta dagli handler pointer per l'hit-test.
  Map<String, Rect> _rects = const {};
  Map<String, double> _sectionTops = const {}; // inizio (card-local) della sezione attributi
  List<({String id, Offset a, Offset b})> _segments = const [];
  List<CLGraphNode> _visibleNodes = const [];
  Map<String, Offset> _edgeMids = const {}; // punto medio (cestino) di ogni arco selezionabile
  Map<String, Map<String, Offset>> _inPortAnchors = const {}; // porte d'ingresso con nome, canvas-local
  Map<String, Map<String, Offset>> _outPortAnchors = const {}; // porte d'uscita con nome, canvas-local
  Offset _shift = Offset.zero; // coordinate host (nodePositions) → canvas: canvas = host + _shift
  List<CLGraphEdge> _effectiveEdges = const []; // archi del frame (per «Ordina» con onArrange)
  Map<String, double> _heights = const {}; // altezze delle card del frame
  Size _viewport = Size.zero; // misura del viewport (zoom da tastiera)
  final GlobalKey _viewportKey = GlobalKey(); // per convertire il punto di rilascio della palette
  final FocusNode _focus = FocusNode(debugLabel: 'CLNodeGraph');
  bool _dropHover = false; // una voce della palette è sopra il canvas

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  CLGraphCardMetrics? _metrics; // ricreato solo se cambiano tema, stile base, textScaler o direzione
  /// Testi dei campi non (ancora) validi, per nodo e attributo: la card li
  /// misura (campo più alto, riga d'errore) invece del valore dell'host.
  final Map<String, Map<String, CLGraphFieldDraft>> _drafts = {};

  @override
  void didUpdateWidget(covariant CLNodeGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_drafts.isEmpty) return;
    final ids = {for (final n in widget.nodes) n.id};
    _drafts.removeWhere((id, _) => !ids.contains(id));
  }

  CLGraphCardMetrics _metricsFor(BuildContext context, CLTheme theme) {
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final m = _metrics;
    if (m != null && m.sameInputs(theme, base, scaler, direction)) return m;
    return _metrics = CLGraphCardMetrics(theme: theme, baseStyle: base, textScaler: scaler, textDirection: direction);
  }

  void _onDraftChanged(String nodeId, String name, CLGraphFieldDraft? draft) {
    if (!mounted) return;
    setState(() {
      final drafts = _drafts[nodeId] ??= {};
      if (draft == null) {
        drafts.remove(name);
        if (drafts.isEmpty) _drafts.remove(nodeId);
      } else {
        drafts[name] = draft;
      }
    });
  }

  /// Motivo per cui [target] non può ricevere l'arco dalla sorgente [from], o
  /// null se il collegamento è ammesso.
  String? _targetProblem(CLGraphNode from, CLGraphNode target) {
    if (_pendingKind == CLGraphEdgeKind.flow) return _flowNodeProblem(from, target);
    if (_pendingKind == CLGraphEdgeKind.propaedeutic) return _propTargetProblem(from, target);
    if (widget.canConnect?.call(target) != true) return '«${target.title}» non si può collegare';
    return clGraphConnectionProblem(from, target, widget.edges, typeLabel: widget.typeLabel);
  }

  /// Come [_targetProblem] per la propedeuticità (porta a rombo).
  String? _propTargetProblem(CLGraphNode from, CLGraphNode target) {
    if (!_hasPropPort(target)) return '«${target.title}» non può avere propedeuticità';
    if (from.id == target.id) return 'Un blocco non può essere propedeutico a se stesso';
    if (widget.edges.any((e) => e.kind == CLGraphEdgeKind.propaedeutic && e.fromNodeId == from.id && e.toNodeId == target.id)) {
      return '«${from.title}» è già propedeutico a «${target.title}»';
    }
    return widget.propaedeuticProblem?.call(from, target);
  }

  // ── Porte con nome ───────────────────────────────────────────────────────

  /// Le porte con nome si possono trascinare (c'è chi riceve l'arco).
  bool get _portsConnectable => widget.onFlowEdgeCreate != null || widget.onEdgeCreate != null;

  Color _flowColor(CLTheme theme) => widget.flowColor ?? theme.mutedForeground;

  /// Porta effettiva di un estremo flow: quella dichiarata dall'arco o la prima del lato.
  static String? _resolvedPort(List<CLGraphPort> ports, String? id) =>
      id ?? (ports.isEmpty ? null : ports.first.id);

  /// Archi flow sulla porta [portId] di [nodeId] ([output]: in uscita).
  int _portEdgeCount(CLGraphNode node, String portId, {required bool output}) {
    var n = 0;
    for (final e in widget.edges) {
      if (e.kind != CLGraphEdgeKind.flow) continue;
      if (output) {
        if (e.fromNodeId == node.id && _resolvedPort(node.outputPorts, e.fromPortId) == portId) n++;
      } else {
        if (e.toNodeId == node.id && _resolvedPort(node.inputPorts, e.toPortId) == portId) n++;
      }
    }
    return n;
  }

  static String _portName(CLGraphPort p) => p.label ?? p.id;

  /// Motivo per cui dalla porta [portId] di [from] non può partire un arco, o null.
  String? _flowSourceProblem(CLGraphNode from, String portId) {
    final port = from.outputPort(portId);
    if (port?.maxConnections case final max?) {
      if (_portEdgeCount(from, portId, output: true) >= max) {
        return 'L\'uscita «${_portName(port!)}» di «${from.title}» è già collegata';
      }
    }
    return null;
  }

  /// Motivo per cui l'arco flow [from].[fromPort] → [to].[toPort] non è ammesso, o null.
  String? _flowProblem(CLGraphNode from, String fromPort, CLGraphNode to, CLGraphPort toPort) {
    if (from.id == to.id) return 'Un blocco non si può collegare a se stesso';
    final src = _flowSourceProblem(from, fromPort);
    if (src != null) return src;
    final dup = widget.edges.any((e) =>
        e.kind == CLGraphEdgeKind.flow &&
        e.fromNodeId == from.id &&
        e.toNodeId == to.id &&
        _resolvedPort(from.outputPorts, e.fromPortId) == fromPort &&
        _resolvedPort(to.inputPorts, e.toPortId) == toPort.id);
    if (dup) return '«${from.title}» è già collegato a «${to.title}»';
    if (toPort.maxConnections case final max?) {
      if (_portEdgeCount(to, toPort.id, output: false) >= max) {
        return 'L\'ingresso «${_portName(toPort)}» di «${to.title}» è già collegato';
      }
    }
    return widget.canConnectPorts?.call(CLGraphPortRef(from.id, fromPort), CLGraphPortRef(to.id, toPort.id));
  }

  /// Per l'attenuazione: null se almeno una porta d'ingresso di [to] accetta l'arco.
  String? _flowNodeProblem(CLGraphNode from, CLGraphNode to) {
    if (to.inputPorts.isEmpty) return '«${to.title}» non ha ingressi';
    final fromPort = _pendingPortId;
    if (fromPort == null) return '«${from.title}» non ha uscite';
    String? first;
    for (final p in to.inputPorts) {
      final problem = _flowProblem(from, fromPort, to, p);
      if (problem == null) return null;
      first ??= problem;
    }
    return first;
  }

  /// Porta d'ingresso di [to] più vicina (in verticale) al cursore [cp], o null.
  CLGraphPort? _inPortAt(CLGraphNode to, Offset cp) {
    if (to.inputPorts.isEmpty) return null;
    final anchors = _inPortAnchors[to.id] ?? const {};
    CLGraphPort? best;
    var bestD = double.infinity;
    for (final p in to.inputPorts) {
      final a = anchors[p.id];
      final d = a == null ? double.infinity : (a.dy - cp.dy).abs();
      if (best == null || d < bestD) {
        best = p;
        bestD = d;
      }
    }
    return best;
  }

  /// Motivo del bersaglio [to] per il cursore [cp] (porta più vicina).
  String? _flowHoverProblem(CLGraphNode from, CLGraphNode to, Offset cp) {
    final port = _inPortAt(to, cp);
    if (port == null) return '«${to.title}» non ha ingressi';
    return _flowProblem(from, _pendingPortId!, to, port);
  }

  /// Porte a rombo della propedeuticità (OUT e IN).
  bool _hasPropPort(CLGraphNode n) => widget.canConnectPropaedeutic?.call(n) == true;

  Color _propColor(CLTheme theme) => widget.propaedeuticColor ?? theme.info;

  /// Ancora di partenza della linea pending: rombo o pallino OUT.
  Offset _pendingAnchor(Rect r) {
    if (_pendingKind == CLGraphEdgeKind.flow) {
      final a = _outPortAnchors[_pendingFromId]?[_pendingPortId];
      if (a != null) return a;
    }
    return _pendingKind == CLGraphEdgeKind.propaedeutic ? clPropOutAnchor(r) : _outAnchor(r);
  }

  /// Porta OUT attiva (si può trascinare per collegare).
  bool _hasOutPort(CLGraphNode n) => widget.canConnect?.call(n) == true && n.connectionRules.acceptsOutputs;

  /// Porta IN attiva (bersaglio di un collegamento).
  bool _hasInPort(CLGraphNode n) => widget.canConnect?.call(n) == true && n.connectionRules.acceptsInputs;

  /// "Ordina": svuota le posizioni manuali → i nodi tornano al layout calcolato.
  /// Con [CLNodeGraph.onArrange] restituisce all'host le posizioni del layout.
  void _arrange() {
    setState(() => _manualPos.clear());
    final cb = widget.onArrange;
    if (cb == null) return;
    cb(clSeparateTallNodes(_layout(_visibleNodes, _effectiveEdges), _heights));
  }

  /// Posizione host (coordinate di [CLNodeGraph.nodePositions]) di un punto canvas.
  Offset _toHost(Offset canvas) => canvas - _shift;

  CLGraphLayout get _layout => widget.layout ?? clHierarchicalLayout;

  /// viewport → canvas-local. `_matrix` contiene solo scala uniforme +
  /// traslazione (fit, pan, zoom non introducono rotazione) ⇒ inversa analitica
  /// dai termini della matrice: canvas = (viewport − t) / s. Robusto e senza deps.
  Offset _toCanvas(Offset vp) {
    final st = _matrix.storage;
    final sx = st[0], sy = st[5];
    final tx = st[12], ty = st[13];
    return Offset((vp.dx - tx) / (sx == 0 ? 1 : sx), (vp.dy - ty) / (sy == 0 ? 1 : sy));
  }

  /// canvas-local → viewport (inversa di [_toCanvas]).
  Offset _toViewport(Offset cp) {
    final st = _matrix.storage;
    return Offset(cp.dx * st[0] + st[12], cp.dy * st[5] + st[13]);
  }

  /// Messaggio del collegamento non ammesso, accanto al cursore [vp] (viewport):
  /// a destra/sotto se c'è spazio, altrimenti a sinistra/sopra.
  Widget _connectBubble(CLTheme theme, CLGraphCardMetrics metrics, String message, Offset vp, Size viewport) {
    const gap = 14.0;
    final leftSide = vp.dx > viewport.width / 2;
    final above = vp.dy > viewport.height - 80;
    return Positioned(
      left: leftSide ? null : vp.dx + gap,
      right: leftSide ? viewport.width - vp.dx + gap : null,
      top: above ? null : vp.dy + gap,
      bottom: above ? viewport.height - vp.dy + gap : null,
      child: IgnorePointer(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: theme.gapXs),
            decoration: BoxDecoration(
              color: theme.danger,
              borderRadius: BorderRadius.circular(theme.radiusChip),
              boxShadow: theme.cardShadowSoft,
            ),
            child: Text(message, style: metrics.smallStyle.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  /// Fit iniziale (una volta): al primo frame utile fa entrare tutto il grafo
  /// nel viewport e centra. Poi l'utente naviga liberamente con pan/zoom.
  void _applyInitialFit(Size viewport, Size content) {
    if (_fitApplied) return;
    if (viewport.isEmpty || content.isEmpty) return;
    _fitApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitView(viewport, content);
    });
  }

  /// Imposta `_matrix` per contenere e centrare `content` in `viewport`
  /// (contain, clamp 0.2–1.5). Usato dal fit iniziale e dal reset vista.
  void _fitView(Size viewport, Size content) {
    if (viewport.isEmpty || content.isEmpty) return;
    final scaleW = viewport.width / content.width;
    final scaleH = viewport.height / content.height;
    final s = (scaleW < scaleH ? scaleW : scaleH).clamp(0.2, 1.5);
    final tx = ((viewport.width - content.width * s) / 2).clamp(0.0, double.infinity);
    final ty = ((viewport.height - content.height * s) / 2).clamp(0.0, double.infinity);
    setState(() {
      _matrix = Matrix4.identity()
        ..setEntry(0, 0, s)
        ..setEntry(1, 1, s)
        ..setEntry(0, 3, tx)
        ..setEntry(1, 3, ty);
    });
  }

  /// Zoom di fattore `k` attorno al punto viewport `focal` (stesso spazio di
  /// `_matrix`). Clamp scala 0.2–3.0. Usato da rotella e pulsanti +/−.
  void _zoom(double k, Offset focal) {
    final z = Matrix4.identity()
      ..multiply(Matrix4.translationValues(focal.dx, focal.dy, 0))
      ..multiply(Matrix4.diagonal3Values(k, k, 1))
      ..multiply(Matrix4.translationValues(-focal.dx, -focal.dy, 0));
    final m = z.multiplied(_matrix);
    final s = m.getMaxScaleOnAxis();
    if (s >= 0.2 && s <= 3.0) setState(() => _matrix = m);
  }

  // ── Pipeline pointer-raw ─────────────────────────────────────────────────
  // Il Listener è un antenato non-arena: riceve SEMPRE gli eventi e decide da
  // solo cosa fare in base a `_hitTest`. Nessun altro recognizer compete.

  ({_Mode mode, String? id}) _hitTest(Offset cp) {
    _pendingActionId = null; // azzera: verrà settato solo se colpita un'azione
    // 1) Cestino dell'arco attivo (hover o selezione): ha priorità perché è
    //    reso sopra le card e piccolo.
    final active = _hoveredEdgeId ?? _selectedEdgeId;
    if (active != null) {
      final mid = _edgeMids[active];
      if (mid != null && (cp - mid).distance <= _kTrashR) return (mode: _Mode.trash, id: active);
    }
    // 2) Nodi, dal più in alto (ultimo disegnato) al più in basso: prima porta
    //    OUT, poi chevron, poi corpo.
    for (var i = _visibleNodes.length - 1; i >= 0; i--) {
      final n = _visibleNodes[i];
      final r = _rects[n.id];
      if (r == null) continue;
      // Porte d'uscita con nome (trascinabili solo se c'è chi riceve l'arco).
      if (_portsConnectable && n.outputPorts.isNotEmpty) {
        final anchors = _outPortAnchors[n.id] ?? const {};
        for (final p in n.outputPorts) {
          final c = anchors[p.id];
          if (c != null && (cp - c).distance <= kGraphPortDot / 2 + 5) {
            _hitPortKind = CLGraphEdgeKind.flow;
            _hitPortId = p.id;
            return (mode: _Mode.port, id: n.id);
          }
        }
      }
      if (_hasPropPort(n)) {
        final c = clPropOutAnchor(r);
        if ((cp - c).distance <= _kDiamond / 2 + 5) {
          _hitPortKind = CLGraphEdgeKind.propaedeutic;
          return (mode: _Mode.port, id: n.id);
        }
      }
      if (_hasOutPort(n)) {
        final c = _outAnchor(r);
        if ((cp - c).distance <= _kDotSize / 2 + 4) {
          _hitPortKind = CLGraphEdgeKind.prerequisite;
          return (mode: _Mode.port, id: n.id);
        }
      }
      if (widget.canCollapse?.call(n) == true) {
        final ch = Rect.fromLTWH(r.left + _kDotInset, r.top + _kDotInset, _kChevron, _kChevron);
        if (ch.contains(cp)) return (mode: _Mode.chevron, id: n.id);
      }
      // Icone azione (top-right): stessa formula del render (`_actionSlotLeft`),
      // testate PRIMA del corpo così il tap sull'icona non fa scattare onNodeTap.
      if (n.actions.isNotEmpty) {
        for (var a = 0; a < n.actions.length; a++) {
          if (!n.actions[a].interactive) continue; // indicatore display-only (es. numero ordine)
          final ar = Rect.fromLTWH(
            r.left + _actionSlotLeft(a, n.actions.length),
            r.top + _kDotInset,
            _kActionSize,
            _kActionSize,
          );
          if (ar.contains(cp)) {
            _pendingActionId = n.actions[a].id;
            return (mode: _Mode.action, id: n.id);
          }
        }
      }
      // Sezione attributi modificabili: il pointer va agli input (campo, menu,
      // checkbox) e non trascina il nodo.
      final sectionTop = _sectionTops[n.id];
      if (widget.onAttributeChanged != null && sectionTop != null) {
        if (Rect.fromLTRB(r.left, r.top + sectionTop, r.right, r.bottom).contains(cp)) {
          return (mode: _Mode.input, id: n.id);
        }
      }
      if (r.contains(cp)) return (mode: _Mode.node, id: n.id);
    }
    // 3) Arco prereq nel vuoto tra le card.
    final e = nearestEdgeId(cp, _segments);
    if (e != null) return (mode: _Mode.edge, id: e);
    // 4) Vuoto ⇒ pan del canvas.
    return (mode: _Mode.pan, id: null);
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_activePointer != null) return; // gesto già in corso: ignora pointer extra
    // Click-to-connect: se una sorgente è già armata (primo click su porta OUT),
    // QUESTO click chiude la connessione sul nodo bersaglio (o la annulla nel vuoto).
    if (_pendingFromId != null) {
      _pendingCursor = _toCanvas(e.localPosition);
      _completeConnectAtCursor(_rects); // resetta _pendingFromId/_pendingCursor
      return;
    }
    _activePointer = e.pointer;
    _downViewport = e.localPosition;
    _lastViewport = e.localPosition;
    final cp = _toCanvas(e.localPosition);
    _lastCanvas = cp;
    _moved = false;
    final hit = _hitTest(cp);
    _mode = hit.mode;
    _targetId = hit.id;
    // Fuoco da tastiera (Esc, Canc, +/−), ma non sugli input degli attributi.
    if (_mode != _Mode.input && !_focus.hasFocus) _focus.requestFocus();
    if (_mode == _Mode.port) {
      setState(() {
        _pendingKind = _hitPortKind;
        _pendingPortId = _hitPortKind == CLGraphEdgeKind.flow ? _hitPortId : null;
        _pendingFromId = hit.id;
        _pendingCursor = cp;
        _selectedEdgeId = null;
      });
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _activePointer) return;
    final vp = e.localPosition;
    final cp = _toCanvas(vp);
    if (!_moved && (vp - _downViewport).distance > kTouchSlop) _moved = true;
    switch (_mode) {
      case _Mode.node:
        final id = _targetId!;
        // Con posizioni salvate il nodo non esce dal canvas a sinistra/in alto.
        final clamp = widget.nodePositions != null || widget.onNodeMoved != null;
        setState(() {
          final base = _manualPos[id] ?? _rects[id]?.topLeft ?? cp;
          final next = base + (cp - _lastCanvas);
          _manualPos[id] = clamp ? Offset(next.dx < 0 ? 0 : next.dx, next.dy < 0 ? 0 : next.dy) : next;
        });
      case _Mode.port:
        setState(() => _pendingCursor = cp);
      case _Mode.pan:
        final d = vp - _lastViewport;
        setState(() => _matrix = Matrix4.translationValues(d.dx, d.dy, 0)..multiply(_matrix));
      case _Mode.chevron:
      case _Mode.action:
      case _Mode.edge:
      case _Mode.trash:
      case _Mode.none:
      case _Mode.input:
        break; // target puntuale: il movimento non trascina nulla
    }
    _lastViewport = vp;
    _lastCanvas = cp;
  }

  void _onPointerUp(PointerUpEvent e) {
    if (e.pointer != _activePointer) return;
    final moved = _moved;
    switch (_mode) {
      case _Mode.node:
        // il tap-selezione è del GestureDetector sulla card; qui solo il drag
        final id = _targetId!;
        final pos = _manualPos[id];
        if (moved && pos != null && widget.onNodeMoved != null) {
          widget.onNodeMoved!(id, _toHost(pos));
          // Posizioni dell'host: da qui in poi vale la sua mappa.
          if (widget.nodePositions != null) setState(() => _manualPos.remove(id));
        }
      case _Mode.port:
        // Drag-connect: chiude al rilascio. Click semplice (nessun drag): lascia
        // la sorgente ARMATA → il prossimo click sul bersaglio chiude (click-to-connect).
        if (moved) _completeConnectAtCursor(_rects);
      case _Mode.chevron:
        if (!moved) widget.onToggleCollapse?.call(_targetId!);
      case _Mode.action:
        // Tap su icona azione: `e.position` è la posizione globale del pointer
        // (l'host la usa per ancorare un popup). Ha precedenza sul tap-nodo.
        if (!moved && _pendingActionId != null) {
          widget.onNodeAction?.call(_targetId!, _pendingActionId!, e.position);
        }
      case _Mode.edge:
        if (!moved) setState(() => _selectedEdgeId = _targetId);
      case _Mode.trash:
        if (!moved) {
          widget.onEdgeDelete?.call(_targetId!, _edgeKind(_targetId!));
          setState(() {
            _hoveredEdgeId = null;
            _selectedEdgeId = null;
          });
        }
      case _Mode.pan:
        if (!moved) {
          setState(() => _selectedEdgeId = null); // tap nel vuoto ⇒ deseleziona
          widget.onBackgroundTap?.call();
        }
      case _Mode.none:
        break;
      case _Mode.input:
        break; // gestito dagli input della sezione attributi
    }
    _resetGesture();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _activePointer) return;
    if (_mode == _Mode.port) _cancelPending();
    _resetGesture();
  }

  void _cancelPending() => setState(() {
        _pendingFromId = null;
        _pendingCursor = null;
        _pendingPortId = null;
      });

  /// Tastiera (canvas a fuoco): Esc annulla il collegamento in corso e
  /// deseleziona l'arco; Canc/Backspace elimina l'arco flow selezionato; +/−
  /// zoom attorno al centro.
  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.escape) {
      if (_pendingFromId == null && _selectedEdgeId == null) return KeyEventResult.ignored;
      _cancelPending();
      setState(() => _selectedEdgeId = null);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.delete || k == LogicalKeyboardKey.backspace) {
      final id = _selectedEdgeId;
      if (id == null || widget.onEdgeDelete == null) return KeyEventResult.ignored;
      final edge = widget.edges.where((x) => x.id == id).firstOrNull;
      if (edge == null || edge.kind != CLGraphEdgeKind.flow || !edge.deletable) return KeyEventResult.ignored;
      widget.onEdgeDelete!(id, edge.kind);
      setState(() {
        _selectedEdgeId = null;
        _hoveredEdgeId = null;
      });
      return KeyEventResult.handled;
    }
    final center = _viewport.center(Offset.zero);
    if (k == LogicalKeyboardKey.equal || k == LogicalKeyboardKey.add || k == LogicalKeyboardKey.numpadAdd) {
      _zoom(1.2, center);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.minus || k == LogicalKeyboardKey.numpadSubtract) {
      _zoom(1 / 1.2, center);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Rilascio di una voce della palette: punto globale del puntatore → canvas
  /// → coordinate host, con la card centrata sul puntatore.
  void _onPaletteDrop(DragTargetDetails<CLNodePaletteItem> d) {
    setState(() => _dropHover = false);
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final cp = _toCanvas(box.globalToLocal(d.offset));
    widget.onNodeDrop?.call(d.data.type, _toHost(cp - const Offset(kCardW / 2, kCardH / 2)));
  }

  void _resetGesture() {
    _mode = _Mode.none;
    _targetId = null;
    _pendingActionId = null;
    _activePointer = null;
    _moved = false;
  }

  /// Hover del mouse (nessun bottone premuto): evidenzia l'arco sotto il cursore
  /// e mostra il cestino. Il pointer-raw arriva anche sopra le card ⇒ hit-test
  /// dell'arco affidabile nonostante l'occlusione.
  void _onPointerHover(PointerHoverEvent e) {
    if (_activePointer != null) return; // durante un drag niente hover
    // Sorgente armata (click-to-connect): la linea pending segue il cursore.
    if (_pendingFromId != null) {
      setState(() => _pendingCursor = _toCanvas(e.localPosition));
      return;
    }
    final hit = nearestEdgeId(_toCanvas(e.localPosition), _segments, threshold: 16);
    if (hit != _hoveredEdgeId) setState(() => _hoveredEdgeId = hit);
  }

  /// Zoom con la rotella del mouse attorno al puntatore.
  void _onPointerSignal(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;
    _zoom(e.scrollDelta.dy < 0 ? 1.1 : 1 / 1.1, e.localPosition);
  }

  // Gesti trackpad (macOS/precision touchpad): il due-dita NON arriva come
  // PointerScrollEvent ma come sequenza PointerPanZoom — pinch (`scale`) → zoom,
  // due-dita-drag (`panDelta`) → pan. Senza questi handler il trackpad è inerte.
  void _onPanZoomStart(PointerPanZoomStartEvent e) => _lastPinchScale = 1.0;

  void _onPanZoomUpdate(PointerPanZoomUpdateEvent e) {
    // Pan a due dita (panDelta è già incrementale, screen space).
    if (e.panDelta != Offset.zero) {
      setState(() => _matrix = Matrix4.translationValues(e.panDelta.dx, e.panDelta.dy, 0)..multiply(_matrix));
    }
    // Zoom pinch: `scale` è cumulativo dallo start ⇒ rapporto vs ultimo campione.
    if (e.scale != _lastPinchScale && _lastPinchScale != 0) {
      _zoom(e.scale / _lastPinchScale, e.localPosition);
      _lastPinchScale = e.scale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    // --- Collasso sottoalberi: pruning nodi nascosti + re-anchor archi. ---
    final hidden = hiddenNodeIds(widget.edges, widget.collapsedNodeIds ?? const {});
    final visibleNodes = [for (final n in widget.nodes) if (!hidden.contains(n.id)) n];
    final parents = containmentParents(widget.edges);
    String vis(String id) => resolveVisibleEndpoint(id, hidden, parents);
    final effectiveEdges = <CLGraphEdge>[];
    for (final e in widget.edges) {
      if (e.kind == CLGraphEdgeKind.containment) {
        if (hidden.contains(e.fromNodeId) || hidden.contains(e.toNodeId)) continue;
        effectiveEdges.add(e);
        continue;
      }
      final a = vis(e.fromNodeId), b = vis(e.toNodeId);
      if (a == b) continue; // entrambi gli estremi collassati nello stesso antenato
      effectiveEdges.add(CLGraphEdge(
        id: e.id,
        fromNodeId: a,
        toNodeId: b,
        kind: e.kind,
        deletable: e.deletable,
        fromPortId: e.fromPortId,
        toPortId: e.toPortId,
        label: e.label,
      ));
    }

    // Altezza di ogni card misurata sul testo (a capo, mai troncato), sugli
    // avvisi dei collegamenti e sugli attributi con le loro bozze.
    final metrics = _metricsFor(context, theme);
    final editable = widget.onAttributeChanged != null;
    final warnings = clGraphConnectionWarnings(widget.nodes, widget.edges);
    final cards = {
      for (final n in visibleNodes)
        n.id: metrics.layout(
          n,
          warnings: warnings[n.id] ?? const [],
          drafts: _drafts[n.id] ?? const {},
          editable: editable,
        ),
    };

    // top-left per id; con card allungate le righe sotto scendono. Con le
    // posizioni dell'host il layout serve solo ai nodi che non ne hanno.
    final heights = {for (final e in cards.entries) e.key: e.value.height};
    final host = widget.nodePositions;
    final needsLayout = host == null || visibleNodes.any((n) => !host.containsKey(n.id));
    final layoutPositions = needsLayout ? clSeparateTallNodes(_layout(visibleNodes, effectiveEdges), heights) : const <String, Offset>{};
    // Posizioni host negative: tutto il canvas scorre di _shift (riportato
    // indietro in onNodeMoved / onNodeDrop).
    var minX = 0.0, minY = 0.0;
    if (host != null) {
      for (final n in visibleNodes) {
        final p = host[n.id];
        if (p == null) continue;
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
      }
    }
    final shift = Offset(-minX, -minY);
    final positions = <String, Offset>{
      for (final n in visibleNodes)
        if (host?[n.id] case final p?) n.id: p + shift else if (layoutPositions[n.id] case final p?) n.id: p,
    };

    // Rect di ogni card + bounding box del canvas. La posizione manuale
    // (drag-move effimero) fa override del layout calcolato.
    final rects = <String, Rect>{};
    var maxX = 0.0, maxY = 0.0;
    for (final n in visibleNodes) {
      final p = _manualPos[n.id] ?? positions[n.id];
      if (p == null) continue;
      final r = Rect.fromLTWH(p.dx, p.dy, kCardW, cards[n.id]!.height);
      rects[n.id] = r;
      maxX = maxX > r.right ? maxX : r.right;
      maxY = maxY > r.bottom ? maxY : r.bottom;
    }
    final canvasSize = Size(maxX + _pad, maxY + _pad);
    final segments = prereqSegments(rects, effectiveEdges);
    final edgeMids = <String, Offset>{
      for (final s in segments) s.id: Offset((s.a.dx + s.b.dx) / 2, (s.a.dy + s.b.dy) / 2),
    };

    // Porte con nome: ancore (bordo sinistro/destro, centro della porta).
    final inAnchors = <String, Map<String, Offset>>{};
    final outAnchors = <String, Map<String, Offset>>{};
    for (final n in visibleNodes) {
      final r = rects[n.id];
      if (r == null || !n.hasNamedPorts) continue;
      final card = cards[n.id]!;
      inAnchors[n.id] = {
        for (var i = 0; i < n.inputPorts.length; i++)
          n.inputPorts[i].id: Offset(r.left, r.top + card.portY(theme, i, n.inputPorts.length)),
      };
      outAnchors[n.id] = {
        for (var i = 0; i < n.outputPorts.length; i++)
          n.outputPorts[i].id: Offset(r.right, r.top + card.portY(theme, i, n.outputPorts.length)),
      };
    }
    // Archi flow: dalla porta d'uscita alla porta d'ingresso (o dal bordo se il
    // nodo non ha porte con nome); hit-test sulla curva campionata.
    final flowEnds = <String, CLGraphFlowEnds>{};
    final byIdVisible = {for (final n in visibleNodes) n.id: n};
    for (final e in effectiveEdges) {
      if (e.kind != CLGraphEdgeKind.flow || e.hidden) continue;
      final from = rects[e.fromNodeId], to = rects[e.toNodeId];
      final fromNode = byIdVisible[e.fromNodeId], toNode = byIdVisible[e.toNodeId];
      if (from == null || to == null || fromNode == null || toNode == null) continue;
      final outPort = _resolvedPort(fromNode.outputPorts, e.fromPortId);
      final inPort = _resolvedPort(toNode.inputPorts, e.toPortId);
      final a = outAnchors[e.fromNodeId]?[outPort] ?? _outAnchor(from);
      final b = inAnchors[e.toNodeId]?[inPort] ?? Offset(to.left, to.center.dy);
      flowEnds[e.id] = (a: a, b: b);
      if (!e.deletable) continue;
      segments.addAll(clSampledLinkSegments(e.id, a, b));
      edgeMids[e.id] = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    }

    // Geometria letta dagli handler pointer per l'hit-test del prossimo gesto.
    _rects = rects;
    _sectionTops = {
      for (final n in visibleNodes)
        if (n.attributes.isNotEmpty) n.id: cards[n.id]!.sectionTop(theme),
    };
    _segments = segments;
    _visibleNodes = visibleNodes;
    _edgeMids = edgeMids;
    _inPortAnchors = inAnchors;
    _outPortAnchors = outAnchors;
    _shift = shift;
    _effectiveEdges = effectiveEdges;
    _heights = heights;

    final activeEdge = _hoveredEdgeId ?? _selectedEdgeId;

    // Collegamento in corso: per ogni altro nodo visibile il motivo per cui non
    // può essere il bersaglio (null ⇒ ammesso). Sotto il cursore: il nodo
    // puntato, il cui motivo (o quello della sorgente senza uscite libere)
    // compare in un fumetto.
    final source = _pendingFromId == null ? null : _nodeById(_pendingFromId!);
    final targetProblems = <String, String?>{
      if (source != null)
        for (final n in visibleNodes)
          if (n.id != source.id) n.id: _targetProblem(source, n),
    };
    final hoverTargetId = source == null || _pendingCursor == null ? null : _targetAt(rects, _pendingCursor!, except: source.id);
    final flowPending = source != null && _pendingKind == CLGraphEdgeKind.flow && _pendingPortId != null;
    // Flow: il motivo sotto il cursore è quello della porta d'ingresso più vicina.
    final hoverProblem = hoverTargetId == null
        ? null
        : flowPending
            ? _flowHoverProblem(source, _nodeById(hoverTargetId)!, _pendingCursor!)
            : targetProblems[hoverTargetId];
    final connectMessage = source == null
        ? null
        : hoverTargetId != null
            ? hoverProblem
            : flowPending
                ? _flowSourceProblem(source, _pendingPortId!)
                : _pendingKind == CLGraphEdgeKind.propaedeutic
                    ? null
                    : clGraphOutputProblem(source, widget.edges);

    // Il canvas (dimensione naturale): SOLO rendering, nessun gesture — tutto
    // l'input passa dal Listener antenato.
    final canvas = SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // archi sotto
          Positioned.fill(
            child: CustomPaint(
              painter: CLGraphEdgePainter(
                nodeRects: rects,
                edges: effectiveEdges,
                containmentColor: theme.danger, // modulo→testa rosso come i prereq
                linkColor: theme.danger, // prereq rossi come i pallini di connessione
                orderColor: theme.mutedForeground,
                selectedColor: theme.danger,
                propaedeuticColor: _propColor(theme),
                selectedEdgeId: activeEdge,
                flowEnds: flowEnds,
                flowColor: _flowColor(theme),
                flowSelectedColor: theme.primary,
                highlightedEdgeIds: widget.highlightedEdgeIds ?? const {},
                highlightColor: widget.highlightColor ?? theme.success,
              ),
            ),
          ),
          // Etichette degli archi flow a metà arco (nascoste sotto il cestino).
          for (final e in effectiveEdges)
            if (e.kind == CLGraphEdgeKind.flow && e.label != null && e.label!.isNotEmpty && e.id != activeEdge)
              if (flowEnds[e.id] case final ends?) _edgeLabel(theme, metrics, e.label!, ends),
          // linea pending (sopra gli archi): dal pallino sorgente al cursore
          if (_pendingFromId != null && _pendingCursor != null && rects[_pendingFromId] != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _PendingEdgePainter(
                  from: _pendingAnchor(rects[_pendingFromId]!),
                  to: _pendingCursor!,
                  color: connectMessage != null
                      ? theme.mutedForeground
                      : switch (_pendingKind) {
                          CLGraphEdgeKind.propaedeutic => _propColor(theme),
                          CLGraphEdgeKind.flow => theme.primary,
                          _ => theme.danger,
                        },
                ),
              ),
            ),
          // card nodo sopra (visuali pure)
          for (final n in visibleNodes)
            if (rects[n.id] != null)
              Positioned(
                left: rects[n.id]!.left,
                top: rects[n.id]!.top,
                width: kCardW,
                height: rects[n.id]!.height,
                child: _nodeCard(
                  context,
                  theme,
                  n,
                  metrics: metrics,
                  card: cards[n.id]!,
                  warnings: warnings[n.id] ?? const [],
                  // Durante un collegamento: attenuato se non ammesso, evidenziato se puntato e ammesso.
                  dimmed: source != null && n.id != source.id && targetProblems[n.id] != null,
                  connectTarget: n.id == hoverTargetId && hoverProblem == null,
                  hoverPortId: n.id == hoverTargetId && flowPending && hoverProblem == null
                      ? _inPortAt(n, _pendingCursor!)?.id
                      : null,
                ),
              ),
          // Cestino dell'arco attivo al midpoint — visuale pura (il click è
          // gestito dal Listener via hit-test). Sopra le card.
          if (activeEdge != null) ..._edgeDeleteVisual(edgeMids, activeEdge, theme),
        ],
      ),
    );

    // Un solo Listener (pointer-raw, non-arena) a livello viewport: opaco ⇒
    // riceve il pointer su TUTTA l'area (pan anche nei margini vuoti oltre il
    // canvas scalato). Transform pilotato da `_tc` per pan/zoom.
    return LayoutBuilder(
      builder: (context, constraints) {
        _applyInitialFit(constraints.biggest, canvasSize);
        _viewport = constraints.biggest;
        Widget viewport = Listener(
                key: _viewportKey,
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                onPointerHover: _onPointerHover,
                onPointerSignal: _onPointerSignal,
                onPointerPanZoomStart: _onPanZoomStart,
                onPointerPanZoomUpdate: _onPanZoomUpdate,
                child: ClipRect(
                  child: _naturalCanvasSize(
                    enabled: visibleNodes.any((n) => n.attributes.isNotEmpty),
                    child: Transform(
                      transform: _matrix,
                      alignment: Alignment.topLeft,
                      child: canvas,
                    ),
                  ),
                ),
              );
        // Rilascio dalla palette: il canvas accetta le voci di CLNodePalette.
        if (widget.onNodeDrop != null) {
          final inner = viewport;
          viewport = DragTarget<CLNodePaletteItem>(
            onWillAcceptWithDetails: (_) {
              if (!_dropHover) setState(() => _dropHover = true);
              return true;
            },
            onLeave: (_) => setState(() => _dropHover = false),
            onAcceptWithDetails: _onPaletteDrop,
            builder: (context, candidates, rejected) => Stack(children: [
              Positioned.fill(child: inner),
              if (_dropHover)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: theme.opacityFaint),
                        border: Border.all(color: theme.primary, width: kGraphCardBorderMax),
                      ),
                    ),
                  ),
                ),
            ]),
          );
        }
        return Stack(
          children: [
            Positioned.fill(
              child: Focus(
                focusNode: _focus,
                onKeyEvent: _onKey,
                child: viewport,
              ),
            ),
            // Fumetto accanto al cursore: perché il collegamento non si può
            // fare. In coordinate viewport (dimensione fissa a ogni zoom) e
            // dal lato del cursore verso il centro, così non esce dal bordo.
            if (connectMessage != null && _pendingCursor != null)
              _connectBubble(theme, metrics, connectMessage, _toViewport(_pendingCursor!), constraints.biggest),
            // "Ordina": snap dei nodi al layout calcolato (svuota _manualPos).
            if (widget.showArrangeButton)
              Positioned(
                top: theme.gapMd,
                right: theme.gapMd,
                child: Material(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(theme.radiusControl),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(theme.radiusControl),
                    onTap: _arrange,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.auto_awesome_motion_outlined, size: theme.iconSizeCompact, color: theme.primaryText),
                        SizedBox(width: theme.gapIconText),
                        Text('Ordina', style: theme.smallText),
                      ]),
                    ),
                  ),
                ),
              ),
            // Controlli zoom (bottom-right): + / − attorno al centro viewport,
            // reset-vista (fit). Il pan resta il drag sullo spazio vuoto.
            Positioned(
              bottom: theme.gapMd,
              right: theme.gapMd,
              child: Material(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(theme.radiusControl),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: SizedBox(
                  width: _kZoomButton,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _zoomButton(theme, Icons.add, 'Ingrandisci', () => _zoom(1.2, constraints.biggest.center(Offset.zero))),
                      Divider(height: 1, thickness: 1, color: theme.borderColor),
                      _zoomButton(theme, Icons.remove, 'Riduci', () => _zoom(1 / 1.2, constraints.biggest.center(Offset.zero))),
                      Divider(height: 1, thickness: 1, color: theme.borderColor),
                      _zoomButton(theme, Icons.crop_free, 'Adatta alla vista', () => _fitView(constraints.biggest, canvasSize)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Cestino (visuale) al midpoint dell'arco [edgeId]. Il click è intercettato
  /// dal Listener (hit-test `_Mode.trash`); qui solo il disegno + il cursore.
  List<Widget> _edgeDeleteVisual(Map<String, Offset> mids, String edgeId, CLTheme theme) {
    final mid = mids[edgeId];
    if (mid == null) return const [];
    return [
      Positioned(
        left: mid.dx - 12,
        top: mid.dy - 12,
        width: 24,
        height: 24,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(color: theme.danger, shape: BoxShape.circle, boxShadow: theme.cardShadowSoft),
            child: const Icon(Icons.delete_outline, size: 15, color: Colors.white),
          ),
        ),
      ),
    ];
  }

  Widget _zoomButton(CLTheme theme, IconData icon, String tooltip, VoidCallback onTap) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: _kZoomButton,
            child: Center(child: Icon(icon, size: theme.iconSizeCompact, color: theme.primaryText, semanticLabel: tooltip)),
          ),
        ),
      );

  /// Etichetta di un arco flow, centrata a metà curva. Visuale pura.
  Widget _edgeLabel(CLTheme theme, CLGraphCardMetrics metrics, String label, CLGraphFlowEnds ends) {
    final mid = Offset((ends.a.dx + ends.b.dx) / 2, (ends.a.dy + ends.b.dy) / 2);
    return Positioned(
      left: mid.dx,
      top: mid.dy,
      child: IgnorePointer(
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kCardW / 2),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: kGraphBadgePadV),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(theme.radiusChip),
                border: Border.all(color: theme.cardBorder),
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: metrics.smallStyle.copyWith(color: theme.mutedForeground)),
            ),
          ),
        ),
      ),
    );
  }

  /// Card del nodo: visuale pura (nessun gesture). Tap/drag/porte/chevron sono
  /// gestiti dal Listener antenato via hit-test geometrico. Altezze da [card]
  /// (misurate da [metrics] con gli stessi stili usati qui): il testo va a capo.
  /// [dimmed] = bersaglio non ammesso del collegamento in corso; [connectTarget]
  /// = bersaglio ammesso sotto il cursore.
  Widget _nodeCard(
    BuildContext context,
    CLTheme theme,
    CLGraphNode n, {
    required CLGraphCardMetrics metrics,
    required CLGraphCardLayout card,
    required List<String> warnings,
    required bool dimmed,
    required bool connectTarget,
    String? hoverPortId,
  }) {
    final accent = n.accent ?? theme.primary;
    final selected = n.id == widget.selectedNodeId;
    final titleLine = metrics.textHeight('Ag', metrics.titleStyle, double.infinity);
    final status = widget.nodeStatuses?[n.id];
    final errors = widget.nodeErrors?[n.id] ?? const <String>[];
    // Colore di stato del bordo: errori di validazione, poi stato di esecuzione.
    final stateColor = errors.isNotEmpty
        ? theme.danger
        : switch (status) {
            CLGraphNodeStatus.done => theme.success,
            CLGraphNodeStatus.waiting => theme.warning,
            CLGraphNodeStatus.error => theme.danger,
            CLGraphNodeStatus.skipped || null => null,
          };
    final border = selected || connectTarget || stateColor != null ? kGraphCardBorderMax : kGraphCardBorder;
    final body = Container(
      // Il bordo più spesso mangia il padding, non il testo: stesse righe da selezionata.
      padding: EdgeInsets.all(theme.gapMd + kGraphCardBorder - border),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.radiusCard),
        border: Border.all(
          color: connectTarget ? theme.success : (selected ? accent : (stateColor ?? theme.cardBorder)),
          width: border,
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill del modulo (tag): colore = badgeColor ?? accent, fondo tonale soft.
          if (n.badge != null && n.badge!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: theme.gapXs),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: kGraphBadgePadV),
                decoration: BoxDecoration(
                  color: (n.badgeColor ?? n.accent ?? theme.primary).withValues(alpha: theme.opacitySoft),
                  borderRadius: BorderRadius.circular(theme.radiusChip),
                ),
                child: Text(n.badge!, maxLines: 1, overflow: TextOverflow.ellipsis, style: metrics.smallStyle.copyWith(color: n.badgeColor ?? n.accent ?? theme.primary)),
              ),
            ),
          // Pallino e icona allineati alla prima riga del titolo, che va a capo.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: (titleLine - kGraphDot) / 2),
                child: Container(width: kGraphDot, height: kGraphDot, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
              ),
              SizedBox(width: theme.gapIconText),
              if (n.icon != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: (titleLine - theme.iconSizeCompact) / 2),
                  child: Icon(n.icon, size: theme.iconSizeCompact, color: accent),
                ),
                SizedBox(width: theme.gapIconText),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title, style: metrics.titleStyle),
                    if (n.subtitle != null && n.subtitle!.isNotEmpty)
                      Text(n.subtitle!, style: metrics.smallStyle.copyWith(color: theme.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
          // Avvisi sui collegamenti (minimi non raggiunti, archi non ammessi).
          if (warnings.isNotEmpty) ...[
            SizedBox(height: theme.gapSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: (metrics.smallLineHeight - kGraphWarningIcon) / 2),
                  child: Icon(Icons.warning_amber_rounded, size: kGraphWarningIcon, color: theme.danger),
                ),
                SizedBox(width: theme.gapXs),
                Expanded(child: Text(warnings.join('\n'), style: metrics.smallStyle.copyWith(color: theme.danger))),
              ],
            ),
          ],
        ],
      ),
    );

    // Tap = selezione via gesture STANDARD (non la pipeline pointer-raw):
    // onTapDown scatta alla pressione ed è affidabile su web, dove il "click"
    // del trackpad può derivare oltre kTouchSlop e la rilevazione manuale lo
    // scarterebbe (visto come drag). Il drag/pan resta gestito dal Listener.
    final tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => widget.onNodeTap?.call(n.id),
      child: body,
    );
    final children = <Widget>[Positioned.fill(child: tappable)];

    // Sezione attributi sotto l'intestazione: con `onAttributeChanged` è fatta
    // di input (l'hit-test le riserva _Mode.input), altrimenti mostra i valori.
    final cardH = card.height;
    if (n.attributes.isNotEmpty) {
      children.add(Positioned(
        left: 0,
        right: 0,
        top: card.sectionTop(theme),
        bottom: 0,
        child: CLGraphAttributesSection(
          node: n,
          metrics: metrics,
          drafts: _drafts[n.id] ?? const {},
          onChanged: widget.onAttributeChanged == null
              ? null
              : (name, value) => widget.onAttributeChanged!(n.id, name, value),
          onDraftChanged: (name, draft) => _onDraftChanged(n.id, name, draft),
          onInteract: () => widget.onNodeTap?.call(n.id),
        ),
      ));
    }

    // Porte di connessione prereq, a cavallo del bordo (metà dentro/fuori) come
    // in fl_nodes. I nodi connettibili hanno OUT (dx) + IN (sx), ciascuna solo
    // se le regole del nodo ammettono archi su quel lato; i nodi con solo
    // `showOutPort` (es. modulo) hanno il solo pallino OUT decorativo.
    if (_hasOutPort(n) || widget.showOutPort?.call(n) == true) {
      children.add(Positioned(
        right: -_kDotSize / 2,
        top: (cardH - _kDotSize) / 2,
        child: _connDot(theme, active: n.id == _pendingFromId && _pendingKind == CLGraphEdgeKind.prerequisite),
      ));
    }
    if (_hasInPort(n)) {
      children.add(Positioned(
        left: -_kDotSize / 2,
        top: (cardH - _kDotSize) / 2,
        child: _connDot(theme, active: connectTarget && _pendingKind == CLGraphEdgeKind.prerequisite),
      ));
    }
    // Porte a rombo della propedeuticità, [kPropDy] sopra il pallino: OUT (dx,
    // con tooltip) e IN (sx). Stesse ancore del painter (clPropOutAnchor/InAnchor).
    if (_hasPropPort(n)) {
      const box = _kDiamond * 1.5; // il rombo ruotato occupa ~lato·√2
      children.add(Positioned(
        right: -box / 2,
        top: cardH / 2 - kPropDy - box / 2,
        width: box,
        height: box,
        child: Tooltip(
          message: widget.propaedeuticTooltip,
          child: Center(child: _propDiamond(theme, active: n.id == _pendingFromId && _pendingKind == CLGraphEdgeKind.propaedeutic)),
        ),
      ));
      children.add(Positioned(
        left: -box / 2,
        top: cardH / 2 - kPropDy - box / 2,
        width: box,
        height: box,
        child: Center(child: _propDiamond(theme, active: connectTarget && _pendingKind == CLGraphEdgeKind.propaedeutic)),
      ));
    }
    // Triangolino handle link-lezione (dx, sotto il pallino OUT): è l'ancora degli
    // archi CLGraphEdgeKind.lessonLink verso i nodi-lezione (il painter usa lo stesso
    // kTriDy). Il pallino OUT sopra resta riservato alla propedeuticità.
    if (widget.showLessonPort?.call(n) == true) {
      children.add(Positioned(
        right: -_kDotSize / 2,
        top: cardH / 2 + kTriDy - _kDotSize / 2,
        child: Icon(Icons.play_arrow, size: _kDotSize + 2, color: theme.danger),
      ));
    }

    // Chevron di collasso (top-left): visuale pura.
    if (widget.canCollapse?.call(n) == true) {
      final collapsed = widget.collapsedNodeIds?.contains(n.id) == true;
      children.add(Positioned(
        top: _kDotInset,
        left: _kDotInset,
        child: Icon(
          collapsed ? Icons.chevron_right : Icons.expand_more,
          size: theme.iconSizeCompact,
          color: theme.mutedForeground,
        ),
      ));
    }

    // Icone azione (top-right): riga orizzontale di icone tappabili (es. frecce
    // ordine ▲▼) — visuali pure, il tap passa dal Listener (hit-test _Mode.action)
    // con la STESSA formula `_actionSlotLeft`. Angolo libero: il badge è
    // left-aligned, il chevron è top-left, le porte OUT/IN e il triangolino
    // link-lezione stanno a metà/sotto sul bordo destro.
    if (n.actions.isNotEmpty) {
      for (var i = 0; i < n.actions.length; i++) {
        final a = n.actions[i];
        Widget ic = a.label != null
            ? Text(a.label!, style: theme.smallText.copyWith(color: theme.mutedForeground, fontWeight: FontWeight.w700))
            : Icon(a.icon, size: theme.iconSizeCompact, color: theme.mutedForeground);
        if (a.tooltip != null) ic = Tooltip(message: a.tooltip!, child: ic);
        children.add(Positioned(
          left: _actionSlotLeft(i, n.actions.length),
          top: _kDotInset,
          width: _kActionSize,
          height: _kActionSize,
          child: Center(child: ic),
        ));
      }
    }

    // Porte con nome: pallini a cavallo del bordo (ingressi a sinistra, uscite
    // a destra) con l'etichetta all'interno; stesse ancore di hit-test e archi
    // (`CLGraphCardLayout.portY`).
    if (n.hasNamedPorts) _addNamedPorts(children, theme, metrics, card, n, hoverPortId: hoverPortId);

    // Bollini sugli angoli: stato (sinistra) ed errori (destra), con tooltip.
    if (status != null) {
      final label = (widget.statusLabel ?? clGraphNodeStatusLabel)(status);
      final (icon, color) = switch (status) {
        CLGraphNodeStatus.done => (Icons.check, theme.success),
        CLGraphNodeStatus.waiting => (Icons.hourglass_empty, theme.warning),
        CLGraphNodeStatus.error => (Icons.close, theme.danger),
        CLGraphNodeStatus.skipped => (Icons.skip_next, theme.mutedForeground),
      };
      children.add(Positioned(
        left: -_kStatusBadge / 2,
        top: -_kStatusBadge / 2,
        child: _cornerBadge(theme, icon, color, label),
      ));
    }
    if (errors.isNotEmpty) {
      children.add(Positioned(
        right: -_kStatusBadge / 2,
        top: -_kStatusBadge / 2,
        child: _cornerBadge(theme, Icons.priority_high, theme.danger, errors.join('\n')),
      ));
    }

    Widget result = children.length == 1 ? tappable : Stack(clipBehavior: Clip.none, children: children);
    if (status == CLGraphNodeStatus.skipped) result = Opacity(opacity: theme.opacityDisabled, child: result);
    // Lettore di schermo: titolo, stato, numero di errori, selezione.
    if (status != null || errors.isNotEmpty || n.hasNamedPorts) {
      final parts = [
        n.title,
        if (status != null) (widget.statusLabel ?? clGraphNodeStatusLabel)(status),
        if (errors.isNotEmpty) errors.length == 1 ? '1 errore' : '${errors.length} errori',
      ];
      result = Semantics(container: true, label: parts.join(', '), selected: selected, child: result);
    }
    return dimmed ? Opacity(opacity: _kDimmed, child: result) : result;
  }

  /// Bollino rotondo sull'angolo della card, con tooltip.
  Widget _cornerBadge(CLTheme theme, IconData icon, Color color, String tooltip) => Tooltip(
        message: tooltip,
        child: Container(
          width: _kStatusBadge,
          height: _kStatusBadge,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: theme.secondaryBackground, width: kGraphCardBorderMax),
            boxShadow: theme.cardShadowSoft,
          ),
          child: Icon(icon, size: theme.iconSizeCompact - theme.gapXs, color: theme.primaryForeground),
        ),
      );

  /// Pallini ed etichette delle porte con nome di [n].
  void _addNamedPorts(
    List<Widget> children,
    CLTheme theme,
    CLGraphCardMetrics metrics,
    CLGraphCardLayout card,
    CLGraphNode n, {
    String? hoverPortId,
  }) {
    final labelStyle = metrics.smallStyle.copyWith(color: theme.mutedForeground);
    final rowH = card.portRowHeight;
    for (final output in const [false, true]) {
      final ports = output ? n.outputPorts : n.inputPorts;
      for (var i = 0; i < ports.length; i++) {
        final p = ports[i];
        final y = card.portY(theme, i, ports.length);
        final active = output
            ? (n.id == _pendingFromId && _pendingKind == CLGraphEdgeKind.flow && p.id == _pendingPortId)
            : p.id == hoverPortId;
        Widget dot = Container(
          width: kGraphPortDot,
          height: kGraphPortDot,
          decoration: BoxDecoration(
            color: p.color ?? _flowColor(theme),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? theme.primaryText : theme.secondaryBackground,
              width: active ? 2.5 : 1.5,
            ),
            boxShadow: theme.cardShadowSoft,
          ),
        );
        final tip = p.tooltip ?? p.label;
        if (tip != null && tip.isNotEmpty) dot = Tooltip(message: tip, child: dot);
        dot = Semantics(label: '${output ? 'Uscita' : 'Ingresso'} ${_portName(p)}', child: dot);
        children.add(Positioned(
          left: output ? null : -kGraphPortDot / 2,
          right: output ? -kGraphPortDot / 2 : null,
          top: y - kGraphPortDot / 2,
          child: dot,
        ));
        if (p.label != null && rowH > 0) {
          children.add(Positioned(
            left: output ? null : kGraphPortDot / 2 + theme.gapXs,
            right: output ? kGraphPortDot / 2 + theme.gapXs : null,
            top: y - rowH / 2,
            width: metrics.portLabelWidth,
            height: rowH,
            child: IgnorePointer(
              child: Align(
                alignment: output ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  p.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: output ? TextAlign.right : TextAlign.left,
                  style: labelStyle,
                ),
              ),
            ),
          ));
        }
      }
    }
  }

  /// Porta di connessione prereq (sx IN / dx OUT): ~16px, tinta `danger`.
  /// [active] = questa card è la sorgente pending ⇒ evidenziato (bordo forte).
  Widget _connDot(CLTheme theme, {required bool active}) => Container(
        width: _kDotSize,
        height: _kDotSize,
        decoration: BoxDecoration(
          color: theme.danger,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? theme.primaryText : theme.secondaryBackground,
            width: active ? 2.5 : 1.5,
          ),
          boxShadow: theme.cardShadowSoft,
        ),
      );

  /// Porta della propedeuticità: rombo [_kDiamond] nel colore della
  /// propedeuticità. [active] = sorgente o bersaglio del collegamento in corso.
  Widget _propDiamond(CLTheme theme, {required bool active}) => Transform.rotate(
        angle: 0.785398, // π/4
        child: Container(
          width: _kDiamond,
          height: _kDiamond,
          decoration: BoxDecoration(
            color: _propColor(theme),
            border: Border.all(
              color: active ? theme.primaryText : theme.secondaryBackground,
              width: active ? 2.5 : 1.5,
            ),
            boxShadow: theme.cardShadowSoft,
          ),
        ),
      );

  /// Tipo dell'arco [edgeId] (per `onEdgeDelete`).
  CLGraphEdgeKind _edgeKind(String edgeId) {
    for (final e in widget.edges) {
      if (e.id == edgeId) return e.kind;
    }
    return CLGraphEdgeKind.prerequisite;
  }

  /// Rilascio del drag-connect: se il cursore è sopra un nodo diverso dalla
  /// sorgente e le regole lo ammettono, crea l'arco prereq (source OUT → target
  /// IN); se non lo ammettono lo segnala con `onConnectionRejected`. Nel vuoto annulla.
  void _completeConnectAtCursor(Map<String, Rect> rects) {
    final from = _pendingFromId, cursor = _pendingCursor;
    if (from == null || cursor == null) {
      setState(() {
        _pendingFromId = null;
        _pendingCursor = null;
      });
      return;
    }
    final targetId = _targetAt(rects, cursor, except: from);
    final source = _nodeById(from);
    final target = targetId == null ? null : _nodeById(targetId);
    if (_pendingKind == CLGraphEdgeKind.flow) {
      final fromPort = _pendingPortId;
      if (source != null && target != null && fromPort != null) {
        final toPort = _inPortAt(target, cursor);
        final problem = toPort == null ? '«${target.title}» non ha ingressi' : _flowProblem(source, fromPort, target, toPort);
        if (problem != null) {
          widget.onConnectionRejected?.call(from, target.id, problem);
        } else if (widget.onFlowEdgeCreate != null) {
          widget.onFlowEdgeCreate!(CLGraphPortRef(from, fromPort), CLGraphPortRef(target.id, toPort!.id));
        } else {
          widget.onEdgeCreate?.call(from, target.id, CLGraphEdgeKind.flow);
        }
      }
      _cancelPending();
      return;
    }
    if (source != null && target != null) {
      final problem = _targetProblem(source, target);
      if (problem == null) {
        widget.onEdgeCreate?.call(from, target.id, _pendingKind);
      } else {
        widget.onConnectionRejected?.call(from, target.id, problem);
      }
    }
    setState(() {
      _pendingFromId = null;
      _pendingCursor = null;
    });
  }

  /// Bersaglio del collegamento in corso sotto [p]: la card, oppure (flow) il
  /// nodo di una porta d'ingresso con nome entro il raggio del pallino, che
  /// sporge per metà fuori dalla card.
  String? _targetAt(Map<String, Rect> rects, Offset p, {required String except}) {
    final card = _cardAt(rects, p, except: except);
    if (card != null || _pendingKind != CLGraphEdgeKind.flow) return card;
    for (final e in _inPortAnchors.entries) {
      if (e.key == except) continue;
      for (final a in e.value.values) {
        if ((p - a).distance <= kGraphPortDot / 2 + 5) return e.key;
      }
    }
    return null;
  }

  /// Card sotto [p] (la più in alto se si sovrappongono), esclusa [except].
  String? _cardAt(Map<String, Rect> rects, Offset p, {required String except}) {
    String? hit;
    for (final e in rects.entries) {
      if (e.key != except && e.value.contains(p)) hit = e.key; // l'ultima disegnata sta sopra
    }
    return hit;
  }

  CLGraphNode? _nodeById(String id) {
    for (final n in widget.nodes) {
      if (n.id == id) return n;
    }
    return null;
  }
}

/// Linea della connessione prereq in corso: dal pallino sorgente [from] al
/// cursore [to] (canvas-local), stile arco prereq (piena, [color], freccia
/// verso il cursore). Riproduce lo stile freccia del painter degli archi.
class _PendingEdgePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;

  _PendingEdgePainter({required this.from, required this.to, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant _PendingEdgePainter old) =>
      old.from != from || old.to != to || old.color != color;
}
