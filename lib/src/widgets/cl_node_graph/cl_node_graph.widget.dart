import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_models.dart';
import 'cl_graph_layout.dart';
import 'cl_graph_edge_painter.dart';
import 'cl_graph_geometry.dart';

const double kCardW = 220;
const double kCardH = 84;
const double _pad = 60; // margine attorno al bounding box

/// Canvas a nodi data-driven (MVP): render nodi+archi da `nodes`/`edges`,
/// tap→select, drag nodo→nodo per propedeuticità/reparent, tap arco→× per
/// eliminare. Nessun motore imperativo: si ridisegna dalle props.
class CLNodeGraph extends StatefulWidget {
  final List<CLGraphNode> nodes;
  final List<CLGraphEdge> edges;
  final String? selectedNodeId;
  final void Function(String nodeId)? onNodeTap;
  final Future<bool> Function(String fromNodeId, String toNodeId)? onLinkCreate; // from=prereq
  final void Function(String edgeId)? onLinkDelete;
  final Future<bool> Function(String childNodeId, String newParentNodeId)? onReparent;
  final CLGraphLayout? layout;

  const CLNodeGraph({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNodeId,
    this.onNodeTap,
    this.onLinkCreate,
    this.onLinkDelete,
    this.onReparent,
    this.layout,
  });

  @override
  State<CLNodeGraph> createState() => _CLNodeGraphState();
}

class _CLNodeGraphState extends State<CLNodeGraph> {
  String? _selectedEdgeId;
  String? _dragHoverId; // nodo bersaglio corrente sotto il ghost (highlight)
  final GlobalKey _canvasKey = GlobalKey(); // per global→canvas-local del drop

  CLGraphLayout get _layout => widget.layout ?? clHierarchicalLayout;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final byId = {for (final n in widget.nodes) n.id: n};
    final positions = _layout(widget.nodes, widget.edges); // top-left per clId

    // Rect di ogni card + bounding box del canvas.
    final rects = <String, Rect>{};
    var maxX = 0.0, maxY = 0.0;
    for (final n in widget.nodes) {
      final p = positions[n.id];
      if (p == null) continue;
      final r = Rect.fromLTWH(p.dx, p.dy, kCardW, kCardH);
      rects[n.id] = r;
      maxX = maxX > r.right ? maxX : r.right;
      maxY = maxY > r.bottom ? maxY : r.bottom;
    }
    final canvasSize = Size(maxX + _pad, maxY + _pad);
    final segments = linkSegments(rects, widget.edges);

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
          final id = _resolveTargetId(d.offset, rects, d.data);
          if (_dragHoverId != null) setState(() => _dragHoverId = null);
          if (id == null) return; // drop nel vuoto o sul sorgente stesso
          final target = byId[id];
          if (target != null) _onDrop(d.data, target, byId);
        },
        builder: (context, cand, rej) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (d) {
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
                      edges: widget.edges,
                      containmentColor: theme.borderColor,
                      linkColor: theme.primary,
                      selectedColor: theme.danger,
                      selectedEdgeId: _selectedEdgeId,
                    ),
                  ),
                ),
              ),
              // card nodo sopra (solo Draggable: nessun DragTarget per-card)
              for (final n in widget.nodes)
                if (rects[n.id] != null)
                  Positioned(
                    left: rects[n.id]!.left,
                    top: rects[n.id]!.top,
                    width: kCardW,
                    height: kCardH,
                    child: _nodeCard(context, theme, n),
                  ),
              // × dell'arco selezionato (tappabile) al midpoint — sopra le card
              if (_selectedEdgeId != null)
                ..._deleteHandle(segments),
            ],
          ),
        ),
      ),
    );

    // Scroll 2-assi (niente pan/zoom).
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: canvas,
        ),
      ),
    );
  }

  List<Widget> _deleteHandle(List<({String id, Offset a, Offset b})> segments) {
    final seg = segments.where((s) => s.id == _selectedEdgeId);
    if (seg.isEmpty) return const [];
    final s = seg.first;
    final mid = Offset((s.a.dx + s.b.dx) / 2, (s.a.dy + s.b.dy) / 2);
    return [
      Positioned(
        left: mid.dx - 11,
        top: mid.dy - 11,
        width: 22,
        height: 22,
        child: GestureDetector(
          onTap: () {
            widget.onLinkDelete?.call(_selectedEdgeId!);
            setState(() => _selectedEdgeId = null);
          },
          child: const SizedBox.expand(), // area tap sopra la × disegnata
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
    // Ghost geometricamente identico al child (kCardW×kCardH) + anchor esplicito
    // `childDragAnchorStrategy` ⇒ top-left del feedback = pointer - grabPoint, così
    // il ghost segue il cursore sotto il punto di presa (fix "ghost sfasato").
    return Draggable<String>(
      data: n.id,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.85, child: SizedBox(width: kCardW, height: kCardH, child: card))),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: GestureDetector(
        onTap: () {
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
      ),
    );
  }

  /// [sourceId] trascinato su [target]. Lezione→corso = reparent; altrimenti link (from=prereq).
  void _onDrop(String sourceId, CLGraphNode target, Map<String, CLGraphNode> byId) {
    final source = byId[sourceId];
    if (source == null || source.id == target.id) return;
    if (source.type == 'lesson' && target.type == 'course') {
      widget.onReparent?.call(source.id, target.id);
    } else {
      widget.onLinkCreate?.call(source.id, target.id); // from=source=prereq, to=target=dipendente
    }
  }
}
