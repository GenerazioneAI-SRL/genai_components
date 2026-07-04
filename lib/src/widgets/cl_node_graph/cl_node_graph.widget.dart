import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_models.dart';
import 'cl_graph_collapse.dart';
import 'cl_graph_layout.dart';
import 'cl_graph_edge_painter.dart';
import 'cl_graph_geometry.dart';

const double kCardW = 220;
const double kCardH = 84;
const double _pad = 60; // margine attorno al bounding box
const double _kDotSize = 16; // diametro del pallino di connessione prereq
const double _kDotInset = 4; // gap del pallino dal bordo inferiore della card

/// Ancora porta OUT (destra, "sblocca"): centro-destra della card, dentro il box.
/// Sorgente della linea pending. Stesso spazio-coordinate di `rects` (canvas-local).
Offset _outAnchor(Rect r) => Offset(r.right - _kDotInset - _kDotSize / 2, r.center.dy);

/// Canvas a nodi data-driven (MVP): render nodi+archi da `nodes`/`edges`,
/// tap→select, drag nodo→nodo per propedeuticità/reparent, tap arco→× per
/// eliminare. Nessun motore imperativo: si ridisegna dalle props.
class CLNodeGraph extends StatefulWidget {
  final List<CLGraphNode> nodes;
  final List<CLGraphEdge> edges;
  final String? selectedNodeId;
  final void Function(String nodeId)? onNodeTap;
  final void Function(String fromNodeId, String toNodeId, CLGraphEdgeKind kind)? onEdgeCreate; // from=sorgente handle
  final void Function(String edgeId, CLGraphEdgeKind kind)? onEdgeDelete;
  final Future<bool> Function(String childNodeId, String newParentNodeId)? onReparent;
  final bool Function(CLGraphNode node)? canDrag; // false ⇒ card NON trascinabile per reparent (default: trascinabile)
  final bool Function(CLGraphNode node)? canConnect; // true ⇒ mostra il pallino di connessione prereq
  final CLGraphLayout? layout;
  final Set<String>? collapsedNodeIds; // nodi collassati ⇒ discendenti nascosti, archi re-anchored
  final void Function(String nodeId)? onToggleCollapse; // tap sul chevron
  final bool Function(CLGraphNode node)? canCollapse; // true ⇒ mostra il chevron di collasso

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
    this.layout,
    this.collapsedNodeIds,
    this.onToggleCollapse,
    this.canCollapse,
  });

  @override
  State<CLNodeGraph> createState() => _CLNodeGraphState();
}

class _CLNodeGraphState extends State<CLNodeGraph> {
  String? _selectedEdgeId;
  String? _hoveredEdgeId; // arco prereq sotto il cursore ⇒ evidenziato + cestino
  String? _dragHoverId; // nodo bersaglio corrente sotto il ghost (highlight)
  // Connessione CLICK-TO-CONNECT (prereq): tap sul pallino di A → pending da A;
  // la linea segue il cursore fino al secondo tap (card/pallino B) che crea
  // l'arco, o al tap nel vuoto/su A che annulla. Coord canvas-local (post-transform).
  String? _pendingFromId; // sorgente della connessione in corso
  Offset? _pendingCursor; // posizione cursore canvas-local (destinazione linea pending)
  final GlobalKey _canvasKey = GlobalKey(); // per global→canvas-local del drop
  final TransformationController _tc = TransformationController(); // pan/zoom
  bool _fitApplied = false; // fit iniziale applicato una sola volta

  CLGraphLayout get _layout => widget.layout ?? clHierarchicalLayout;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  /// Fit iniziale (una volta): scala per far entrare tutto il grafo nel
  /// viewport e centra. Poi l'utente naviga liberamente con pan/zoom.
  void _applyInitialFit(Size viewport, Size content) {
    if (_fitApplied) return;
    if (viewport.isEmpty || content.isEmpty) return;
    final scaleW = viewport.width / content.width;
    final scaleH = viewport.height / content.height;
    final s = (scaleW < scaleH ? scaleW : scaleH).clamp(0.2, 1.5); // contain
    final tx = ((viewport.width - content.width * s) / 2).clamp(0.0, double.infinity);
    final ty = ((viewport.height - content.height * s) / 2).clamp(0.0, double.infinity);
    _fitApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tc.value = Matrix4.identity()
        ..setEntry(0, 0, s)
        ..setEntry(1, 1, s)
        ..setEntry(0, 3, tx)
        ..setEntry(1, 3, ty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    // --- Collasso sottoalberi: pruning nodi nascosti + re-anchor archi. ---
    // Con `collapsedNodeIds` null/vuoto: `hidden` vuoto ⇒ visibleNodes == nodes
    // ed effectiveEdges == edges (stesse istanze per containment, copie 1:1 per
    // prereq/order) → grafo identico al comportamento storico.
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

    final byId = {for (final n in visibleNodes) n.id: n};
    final positions = _layout(visibleNodes, effectiveEdges); // top-left per clId

    // Rect di ogni card + bounding box del canvas (solo nodi visibili).
    final rects = <String, Rect>{};
    var maxX = 0.0, maxY = 0.0;
    for (final n in visibleNodes) {
      final p = positions[n.id];
      if (p == null) continue;
      final r = Rect.fromLTWH(p.dx, p.dy, kCardW, kCardH);
      rects[n.id] = r;
      maxX = maxX > r.right ? maxX : r.right;
      maxY = maxY > r.bottom ? maxY : r.bottom;
    }
    final canvasSize = Size(maxX + _pad, maxY + _pad);
    final segments = prereqSegments(rects, effectiveEdges);

    // Un SOLO DragTarget avvolge l'intero canvas: il bersaglio del drop non è
    // deciso dall'hit-test per-card (fragile dentro lo scroll + ghost sfasato)
    // ma calcolato dal Rect che CONTIENE il centro del ghost, convertito in
    // coordinate canvas-local via [_canvasKey]. Deterministico, immune all'offset.
    final canvas = SizedBox(
      key: _canvasKey,
      width: canvasSize.width,
      height: canvasSize.height,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => true, // il bersaglio reale è risolto per-Rect
        onMove: (d) {
          final id = _resolveTargetId(d.offset, rects, d.data);
          if (id != _dragHoverId) setState(() => _dragHoverId = id);
        },
        onLeave: (_) {
          if (_dragHoverId != null) setState(() => _dragHoverId = null);
        },
        onAcceptWithDetails: (d) {
          // Solo reparent (payload String): logica invariata via _onDrop.
          final sourceId = d.data;
          final id = _resolveTargetId(d.offset, rects, sourceId);
          if (_dragHoverId != null) setState(() => _dragHoverId = null);
          if (id == null) return; // drop nel vuoto o sul sorgente stesso
          final target = byId[id];
          if (target != null) _onDrop(sourceId, target, byId);
        },
        builder: (context, cand, rej) => Listener(
          // translucent ⇒ il Listener resta nel hit-path anche sopra i "vuoti"
          // tra le card (dove il GestureDetector figlio, pur translucent,
          // ritorna false): senza questo, onPointerHover NON scatta proprio
          // sopra il tratto visibile dell'arco (che cade nel gap tra due card).
          behavior: HitTestBehavior.translucent,
          // Cursor-follow della linea pending: SOLO mentre `_pendingFromId != null`
          // aggiorna `_pendingCursor` con la localPosition (canvas-local: origine =
          // top-left di questo box che riempie la SizedBox del canvas, già
          // post-transform dell'InteractiveViewer). onPointerHover = mouse senza
          // bottone premuto → non collide con pan/drag.
          onPointerHover: (e) {
            if (_pendingFromId != null) {
              setState(() => _pendingCursor = e.localPosition);
              return;
            }
            // Hover su un arco prereq → evidenzia + mostra cestino. Soglia più
            // ampia del tap così si aggancia facilmente col mouse. L'evento
            // arriva al Listener (antenato) anche quando il cursore è sopra una
            // card → hit-test dell'arco affidabile nonostante l'occlusione.
            final hit = nearestEdgeId(e.localPosition, segments, threshold: 16);
            if (hit != _hoveredEdgeId) setState(() => _hoveredEdgeId = hit);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (d) {
              // pending attivo → questo tap è "nel vuoto" (le card/pallini vincono
              // l'arena prima): ANNULLA la connessione, NON selezionare un arco.
              if (_pendingFromId != null) {
                setState(() {
                  _pendingFromId = null;
                  _pendingCursor = null;
                });
                return;
              }
              // tap "a vuoto" sul canvas → prova a colpire un arco propedeuticità
              final hit = nearestEdgeId(d.localPosition, segments);
              setState(() => _selectedEdgeId = hit); // null se nessuno → deseleziona
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // archi sotto
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: CLGraphEdgePainter(
                        nodeRects: rects,
                        edges: effectiveEdges,
                        containmentColor: theme.borderColor,
                        linkColor: theme.primary,
                        orderColor: theme.mutedForeground,
                        selectedColor: theme.danger,
                        selectedEdgeId: _hoveredEdgeId ?? _selectedEdgeId,
                      ),
                    ),
                  ),
                ),
                // linea pending (sopra gli archi): dal pallino sorgente al cursore
                if (_pendingFromId != null && _pendingCursor != null && rects[_pendingFromId] != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _PendingEdgePainter(
                          from: _outAnchor(rects[_pendingFromId]!),
                          to: _pendingCursor!,
                          color: theme.danger,
                        ),
                      ),
                    ),
                  ),
                // card nodo sopra (solo Draggable: nessun DragTarget per-card)
                for (final n in visibleNodes)
                  if (rects[n.id] != null)
                    Positioned(
                      left: rects[n.id]!.left,
                      top: rects[n.id]!.top,
                      width: kCardW,
                      height: kCardH,
                      child: _nodeCard(context, theme, n, rects),
                    ),
                // Cestino dell'arco sotto cursore (hover) o selezionato (tap
                // touch) al midpoint — sopra le card, quindi sempre cliccabile
                // anche se il midpoint cade sotto una card.
                if ((_hoveredEdgeId ?? _selectedEdgeId) != null)
                  ..._edgeDeleteHandle(segments, (_hoveredEdgeId ?? _selectedEdgeId)!, theme),
              ],
            ),
          ),
        ),
      ),
    );

    // Pan + zoom per navigare (InteractiveViewer). Fit iniziale automatico
    // (una volta) via _applyInitialFit. `constrained: false` lascia il canvas
    // alla sua dimensione naturale e permette pan libero; il drag delle card
    // (gesture più profonda) vince sull'arena → il pan avviene su spazio vuoto.
    // globalToLocal del drop e la localPosition del tap passano per la transform
    // dell'InteractiveViewer → drag e hit-test archi corretti anche scalati.
    return LayoutBuilder(
      builder: (context, constraints) {
        _applyInitialFit(constraints.biggest, canvasSize);
        return InteractiveViewer(
          transformationController: _tc,
          constrained: false,
          minScale: 0.2,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: canvas,
        );
      },
    );
  }

  /// Cestino cliccabile al midpoint dell'arco [edgeId] (hover o selezione tap).
  /// Reso sopra le card ⇒ sempre cliccabile anche se il midpoint cade sotto una
  /// card. La `MouseRegion.onEnter` mantiene l'hover sull'arco mentre si punta
  /// il cestino (evita che il ridisegno lo faccia sparire prima del click).
  List<Widget> _edgeDeleteHandle(List<({String id, Offset a, Offset b})> segments, String edgeId, CLTheme theme) {
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
          onEnter: (_) {
            if (_hoveredEdgeId != edgeId) setState(() => _hoveredEdgeId = edgeId);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.onEdgeDelete?.call(edgeId, CLGraphEdgeKind.prerequisite);
              setState(() {
                _hoveredEdgeId = null;
                _selectedEdgeId = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(color: theme.danger, shape: BoxShape.circle, boxShadow: theme.cardShadowSoft),
              child: const Icon(Icons.delete_outline, size: 15, color: Colors.white),
            ),
          ),
        ),
      ),
    ];
  }

  /// Risolve il nodo bersaglio da [feedbackTopLeftGlobal] (= `DragTargetDetails.offset`,
  /// che Flutter calcola come `pointerGlobal - dragStartPoint` ⇒ top-left GLOBALE del
  /// feedback kCardW×kCardH). Uso il CENTRO del ghost così il bersaglio coincide con la
  /// card che l'utente vede trascinare, indipendentemente da dove ha afferrato.
  String? _resolveTargetId(Offset feedbackTopLeftGlobal, Map<String, Rect> rects, String sourceId) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final centerLocal = box.globalToLocal(feedbackTopLeftGlobal + const Offset(kCardW / 2, kCardH / 2));
    for (final e in rects.entries) {
      if (e.key == sourceId) continue; // mai il sorgente stesso
      if (e.value.contains(centerLocal)) return e.key;
    }
    return null; // nessun Rect colpito
  }

  Widget _nodeCard(BuildContext context, CLTheme theme, CLGraphNode n, Map<String, Rect> rects) {
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
      child: Row(
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
    );

    // Draggable payload = clId sorgente. Il bersaglio del drop è risolto per-Rect
    // dal DragTarget unico che avvolge il canvas (vedi build/_resolveTargetId):
    // la card NON è più un DragTarget. `hovering` = questa card è sotto il ghost.
    final hovering = n.id == _dragHoverId;
    final tappable = GestureDetector(
      onTap: () {
        // La connessione ora è drag-su-porta: il tap sul corpo seleziona il nodo.
        setState(() => _selectedEdgeId = null);
        widget.onNodeTap?.call(n.id);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radiusCard),
          border: Border.all(color: hovering ? theme.primary : Colors.transparent, width: 2),
        ),
        child: card,
      ),
    );
    // Draggable per reparent SOLO se `canDrag` lo consente (default: trascinabile
    // = comportamento storico). Se non trascinabile, il drag sul corpo diventa
    // pan (InteractiveViewer vince l'arena) e resta il tap-select. Ghost identico
    // al child (kCardW×kCardH) + `childDragAnchorStrategy` ⇒ segue il cursore.
    final body = widget.canDrag?.call(n) == false
        ? tappable
        : Draggable<String>(
            data: n.id,
            dragAnchorStrategy: childDragAnchorStrategy,
            feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.85, child: SizedBox(width: kCardW, height: kCardH, child: card))),
            childWhenDragging: Opacity(opacity: 0.4, child: card),
            child: tappable,
          );

    // Solo i nodi connettibili espongono le due porte di connessione prereq.
    // NOTA layout: il Positioned esterno (build) vincola la card a kCardW×kCardH.
    // Le porte sono inset DENTRO tale box (right/left = _kDotInset) — NON in
    // overflow negativo — così restano interamente hit-testabili (un RenderStack
    // non testa i figli oltre i propri bounds anche con Clip.none). kCardW/kCardH
    // invariati. Sono gli ULTIMI figli dello Stack (sopra il corpo) e opache ⇒ il
    // loro gesto vince su quello del corpo sottostante nella stessa area.
    Widget content = widget.canConnect?.call(n) != true
        ? body
        : Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: body),
              // Porta OUT (destra, "sblocca"): avvia il drag-connect; la linea
              // pending segue il cursore fino al rilascio su una porta IN.
              Positioned(
                right: _kDotInset,
                top: (kCardH - _kDotSize) / 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() {
                    _pendingFromId = n.id;
                    _pendingCursor = _outAnchor(rects[n.id]!);
                    _selectedEdgeId = null;
                  }),
                  onPanUpdate: (d) {
                    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                    if (box != null) setState(() => _pendingCursor = box.globalToLocal(d.globalPosition));
                  },
                  onPanEnd: (_) => _completeConnectAtCursor(rects),
                  child: _connDot(theme, active: n.id == _pendingFromId),
                ),
              ),
              // Porta IN (sinistra, "richiede"): solo bersaglio visivo — il drop è
              // risolto per-Rect da _completeConnectAtCursor.
              Positioned(
                left: _kDotInset,
                top: (kCardH - _kDotSize) / 2,
                child: _connDot(theme, active: false),
              ),
            ],
          );

    // Chevron di collasso (top-left): non collide col pallino prereq (in basso)
    // né col tap-select del corpo (GestureDetector opaco sopra la card). Espanso
    // ⇒ expand_more; collassato ⇒ chevron_right.
    if (widget.canCollapse?.call(n) == true) {
      final collapsed = widget.collapsedNodeIds?.contains(n.id) == true;
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: content),
          Positioned(
            top: _kDotInset,
            left: _kDotInset,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onToggleCollapse?.call(n.id),
              child: Icon(
                collapsed ? Icons.chevron_right : Icons.expand_more,
                size: theme.iconSizeCompact,
                color: theme.mutedForeground,
              ),
            ),
          ),
        ],
      );
    }
    return content;
  }

  /// Porta di connessione prereq (sx IN / dx OUT): ~16px, tinta `danger`.
  /// [active] = questa card è la sorgente pending ⇒ evidenziato (bordo forte).
  /// Usa `secondaryBackground`/`danger`/`primaryText`.
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

  /// [sourceId] trascinato col CORPO su [target]. Unico effetto: reparent
  /// (il consumer decide la validità via onReparent). Le frecce prereq si
  /// creano SOLO via click-to-connect sul pallino → il body-drag non crea
  /// link (niente ambiguità col pan).
  void _onDrop(String sourceId, CLGraphNode target, Map<String, CLGraphNode> byId) {
    final source = byId[sourceId];
    if (source == null || source.id == target.id) return;
    // Reparent domain-agnostico: il widget non conosce i 'type' del dominio.
    // Il consumer valida via onReparent (→ Future<bool>) e rifiuta se non lecito.
    widget.onReparent?.call(source.id, target.id);
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
    // freccia verso il cursore (punta a `to`, nessun arretramento: non c'è card)
    if ((to - from).distance < 1) return;
    const s = 9.0;
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final p1 = Offset(to.dx - s * math.cos(angle - math.pi / 7), to.dy - s * math.sin(angle - math.pi / 7));
    final p2 = Offset(to.dx - s * math.cos(angle + math.pi / 7), to.dy - s * math.sin(angle + math.pi / 7));
    canvas.drawLine(to, p1, paint);
    canvas.drawLine(to, p2, paint);
  }

  @override
  bool shouldRepaint(covariant _PendingEdgePainter old) =>
      old.from != from || old.to != to || old.color != color;
}
