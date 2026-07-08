import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_models.dart';
import 'cl_graph_collapse.dart';
import 'cl_graph_layout.dart';
import 'cl_graph_edge_painter.dart';
import 'cl_graph_geometry.dart';

const double kCardW = 220;
const double kCardH = 96; // include la pill badge (modulo) sopra titolo+sottotitolo
const double _pad = 60; // margine attorno al bounding box
const double _kDotSize = 16; // diametro del pallino di connessione prereq
const double _kDotInset = 4; // gap del pallino dal bordo inferiore della card
const double _kChevron = 24; // area cliccabile chevron collasso (top-left card)
const double _kActionSize = 24; // area cliccabile di ogni icona azione (top-right card) — mirror _kChevron
const double _kActionGap = 4; // gap orizzontale tra icone azione adiacenti
// _kTriDy vive in cl_graph_models.dart (kTriDy) — condiviso col painter.
const double _kTrashR = 14; // raggio hit del cestino attorno al midpoint dell'arco

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
enum _Mode { none, node, port, chevron, action, edge, trash, pan }

/// Canvas a nodi data-driven: render nodi+archi da `nodes`/`edges`, tap→select,
/// drag-porta (dx→sx) per creare prereq, drag-corpo per spostare il nodo
/// (effimero), hover arco→cestino per eliminare, "Ordina" per risnappare al
/// layout. Nessun motore imperativo: si ridisegna dalle props.
///
/// Gesture: UN solo [Listener] raw a livello viewport. Su pointer-down un
/// hit-test manuale (in coord canvas) decide il [_Mode]; move/up smistano di
/// conseguenza. Zoom con rotella. Niente InteractiveViewer, niente
/// GestureDetector annidati → interazione deterministica.
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
  Offset? _pendingCursor; // posizione cursore canvas-local (destinazione linea pending)
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
  List<({String id, Offset a, Offset b})> _segments = const [];
  List<CLGraphNode> _visibleNodes = const [];

  /// "Ordina": svuota le posizioni manuali → i nodi tornano al layout calcolato.
  void _arrange() => setState(() => _manualPos.clear());

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
      for (final s in _segments) {
        if (s.id != active) continue;
        final mid = Offset((s.a.dx + s.b.dx) / 2, (s.a.dy + s.b.dy) / 2);
        if ((cp - mid).distance <= _kTrashR) return (mode: _Mode.trash, id: active);
        break;
      }
    }
    // 2) Nodi, dal più in alto (ultimo disegnato) al più in basso: prima porta
    //    OUT, poi chevron, poi corpo.
    for (var i = _visibleNodes.length - 1; i >= 0; i--) {
      final n = _visibleNodes[i];
      final r = _rects[n.id];
      if (r == null) continue;
      if (widget.canConnect?.call(n) == true) {
        final c = _outAnchor(r);
        if ((cp - c).distance <= _kDotSize / 2 + 4) return (mode: _Mode.port, id: n.id);
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
    if (_mode == _Mode.port) {
      setState(() {
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
        setState(() {
          final base = _manualPos[id] ?? _rects[id]?.topLeft ?? cp;
          _manualPos[id] = base + (cp - _lastCanvas);
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
        break; // il tap-selezione è del GestureDetector sulla card; qui solo il drag
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
          widget.onEdgeDelete?.call(_targetId!, CLGraphEdgeKind.prerequisite);
          setState(() {
            _hoveredEdgeId = null;
            _selectedEdgeId = null;
          });
        }
      case _Mode.pan:
        if (!moved) setState(() => _selectedEdgeId = null); // tap nel vuoto ⇒ deseleziona
      case _Mode.none:
        break;
    }
    _resetGesture();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _activePointer) return;
    if (_mode == _Mode.port) {
      setState(() {
        _pendingFromId = null;
        _pendingCursor = null;
      });
    }
    _resetGesture();
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
      effectiveEdges.add(CLGraphEdge(id: e.id, fromNodeId: a, toNodeId: b, kind: e.kind));
    }

    final positions = _layout(visibleNodes, effectiveEdges); // top-left per id

    // Rect di ogni card + bounding box del canvas. La posizione manuale
    // (drag-move effimero) fa override del layout calcolato.
    final rects = <String, Rect>{};
    var maxX = 0.0, maxY = 0.0;
    for (final n in visibleNodes) {
      final p = _manualPos[n.id] ?? positions[n.id];
      if (p == null) continue;
      final r = Rect.fromLTWH(p.dx, p.dy, kCardW, kCardH);
      rects[n.id] = r;
      maxX = maxX > r.right ? maxX : r.right;
      maxY = maxY > r.bottom ? maxY : r.bottom;
    }
    final canvasSize = Size(maxX + _pad, maxY + _pad);
    final segments = prereqSegments(rects, effectiveEdges);

    // Geometria letta dagli handler pointer per l'hit-test del prossimo gesto.
    _rects = rects;
    _segments = segments;
    _visibleNodes = visibleNodes;

    final activeEdge = _hoveredEdgeId ?? _selectedEdgeId;

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
                selectedEdgeId: activeEdge,
              ),
            ),
          ),
          // linea pending (sopra gli archi): dal pallino sorgente al cursore
          if (_pendingFromId != null && _pendingCursor != null && rects[_pendingFromId] != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _PendingEdgePainter(
                  from: _outAnchor(rects[_pendingFromId]!),
                  to: _pendingCursor!,
                  color: theme.danger,
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
                height: kCardH,
                child: _nodeCard(context, theme, n),
              ),
          // Cestino dell'arco attivo al midpoint — visuale pura (il click è
          // gestito dal Listener via hit-test). Sopra le card.
          if (activeEdge != null) ..._edgeDeleteVisual(segments, activeEdge, theme),
        ],
      ),
    );

    // Un solo Listener (pointer-raw, non-arena) a livello viewport: opaco ⇒
    // riceve il pointer su TUTTA l'area (pan anche nei margini vuoti oltre il
    // canvas scalato). Transform pilotato da `_tc` per pan/zoom.
    return LayoutBuilder(
      builder: (context, constraints) {
        _applyInitialFit(constraints.biggest, canvasSize);
        return Stack(
          children: [
            Positioned.fill(
              child: Listener(
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
                  child: Transform(
                    transform: _matrix,
                    alignment: Alignment.topLeft,
                    child: canvas,
                  ),
                ),
              ),
            ),
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
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _zoom(1.2, constraints.biggest.center(Offset.zero)),
                        child: SizedBox(height: 40, child: Center(child: Icon(Icons.add, size: theme.iconSizeCompact, color: theme.primaryText))),
                      ),
                      Divider(height: 1, thickness: 1, color: theme.borderColor),
                      InkWell(
                        onTap: () => _zoom(1 / 1.2, constraints.biggest.center(Offset.zero)),
                        child: SizedBox(height: 40, child: Center(child: Icon(Icons.remove, size: theme.iconSizeCompact, color: theme.primaryText))),
                      ),
                      Divider(height: 1, thickness: 1, color: theme.borderColor),
                      InkWell(
                        onTap: () => _fitView(constraints.biggest, canvasSize),
                        child: SizedBox(height: 40, child: Center(child: Icon(Icons.crop_free, size: theme.iconSizeCompact, color: theme.primaryText))),
                      ),
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
  List<Widget> _edgeDeleteVisual(List<({String id, Offset a, Offset b})> segments, String edgeId, CLTheme theme) {
    final seg = segments.where((s) => s.id == edgeId);
    if (seg.isEmpty) return const [];
    final s = seg.first;
    final mid = Offset((s.a.dx + s.b.dx) / 2, (s.a.dy + s.b.dy) / 2);
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

  /// Card del nodo: visuale pura (nessun gesture). Tap/drag/porte/chevron sono
  /// gestiti dal Listener antenato via hit-test geometrico.
  Widget _nodeCard(BuildContext context, CLTheme theme, CLGraphNode n) {
    final accent = n.accent ?? theme.primary;
    final selected = n.id == widget.selectedNodeId;
    final card = Container(
      padding: EdgeInsets.all(theme.gapMd),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.radiusCard),
        border: Border.all(color: selected ? accent : theme.cardBorder, width: selected ? 2 : 1),
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
                padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: 2),
                decoration: BoxDecoration(
                  color: (n.badgeColor ?? n.accent ?? theme.primary).withValues(alpha: theme.opacitySoft),
                  borderRadius: BorderRadius.circular(theme.radiusChip),
                ),
                child: Text(n.badge!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.smallText.copyWith(color: n.badgeColor ?? n.accent ?? theme.primary)),
              ),
            ),
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
              SizedBox(width: theme.gapIconText),
              if (n.icon != null) ...[Icon(n.icon, size: theme.iconSizeCompact, color: accent), SizedBox(width: theme.gapIconText)],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyText),
                    if (n.subtitle != null && n.subtitle!.isNotEmpty)
                      Text(n.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.smallText.copyWith(color: theme.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final children = <Widget>[
      Positioned.fill(
        // Tap = selezione via gesture STANDARD (non la pipeline pointer-raw):
        // onTapDown scatta alla pressione ed è affidabile su web, dove il "click"
        // del trackpad può derivare oltre kTouchSlop e la rilevazione manuale lo
        // scarterebbe (visto come drag). Il drag/pan resta gestito dal Listener.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => widget.onNodeTap?.call(n.id),
          child: card,
        ),
      ),
    ];

    // Porte di connessione prereq, a cavallo del bordo (metà dentro/fuori) come
    // in fl_nodes. I nodi connettibili hanno OUT (dx) + IN (sx); i nodi con solo
    // `showOutPort` (es. modulo) hanno il solo pallino OUT decorativo.
    final connectable = widget.canConnect?.call(n) == true;
    if (connectable || widget.showOutPort?.call(n) == true) {
      children.add(Positioned(
        right: -_kDotSize / 2,
        top: (kCardH - _kDotSize) / 2,
        child: _connDot(theme, active: n.id == _pendingFromId),
      ));
    }
    if (connectable) {
      children.add(Positioned(
        left: -_kDotSize / 2,
        top: (kCardH - _kDotSize) / 2,
        child: _connDot(theme, active: false),
      ));
    }
    // Triangolino handle link-lezione (dx, sotto il pallino OUT): è l'ancora degli
    // archi CLGraphEdgeKind.lessonLink verso i nodi-lezione (il painter usa lo stesso
    // kTriDy). Il pallino OUT sopra resta riservato alla propedeuticità.
    if (widget.showLessonPort?.call(n) == true) {
      children.add(Positioned(
        right: -_kDotSize / 2,
        top: kCardH / 2 + kTriDy - _kDotSize / 2,
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

    if (children.length == 1) return card;
    return Stack(clipBehavior: Clip.none, children: children);
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

  /// Rilascio del drag-connect: se il cursore è sopra un nodo connettibile diverso
  /// dalla sorgente, crea l'arco prereq (source OUT → target IN). Altrimenti annulla.
  void _completeConnectAtCursor(Map<String, Rect> rects) {
    final from = _pendingFromId, cursor = _pendingCursor;
    if (from == null || cursor == null) {
      setState(() {
        _pendingFromId = null;
        _pendingCursor = null;
      });
      return;
    }
    String? targetId;
    for (final e in rects.entries) {
      if (e.key == from) continue;
      if (e.value.contains(cursor)) {
        targetId = e.key;
        break;
      }
    }
    if (targetId != null) {
      final target = _nodeById(targetId);
      if (target != null && widget.canConnect?.call(target) == true) {
        widget.onEdgeCreate?.call(from, targetId, CLGraphEdgeKind.prerequisite);
      }
    }
    setState(() {
      _pendingFromId = null;
      _pendingCursor = null;
    });
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
