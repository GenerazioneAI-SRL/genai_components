import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cl_graph_models.dart';

/// Ancora porta OUT (destra, "sblocca") del source — sul bordo destro della card
/// (il pallino è a cavallo del bordo). Coerente con la porta renderizzata.
Offset _outAnchor(Rect r) => Offset(r.right, r.center.dy);
/// Ancora porta IN (sinistra, "richiede") del target — sul bordo sinistro.
Offset _inAnchor(Rect r) => Offset(r.left, r.center.dy);
/// Ancora porta triangolino "link-lezione" del source — bordo destro, [kTriDy]px
/// sotto il centro (allineata al triangolino renderizzato dal widget). Il pallino
/// OUT (centro) resta per la propedeuticità; il link-lezione parte da qui.
Offset _lessonAnchor(Rect r) => Offset(r.right, r.center.dy + kTriDy);

/// Offset di controllo del bezier: adattivo alla distanza (stile fl_nodes),
/// clamp 40–320. OUT esce verso destra, IN entra da sinistra.
double _ctrlOffset(Offset a, Offset b) {
  final dist = (b - a).distance;
  return dist < 800 ? (dist / 2).clamp(40.0, 320.0) : 320.0;
}

/// Percorso curvo OUT(dx)→IN(sx): cubic bezier con control point orizzontali.
Path clLinkPath(Offset a, Offset b) {
  final c = _ctrlOffset(a, b);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..cubicTo(a.dx + c, a.dy, b.dx - c, b.dy, b.dx, b.dy);
}

/// Estremi (porta OUT del source → porta IN del target) di ogni arco
/// `prerequisite`, per hit-test del cestino (segmento retto: la curva è quasi
/// orizzontale su span brevi, la soglia di hover è ampia). Il midpoint retto
/// coincide col punto t=0.5 del bezier simmetrico → cestino resta sulla curva.
List<({String id, Offset a, Offset b})> prereqSegments(
  Map<String, Rect> nodeRects,
  List<CLGraphEdge> edges,
) {
  final out = <({String id, Offset a, Offset b})>[];
  for (final e in edges) {
    if (e.kind != CLGraphEdgeKind.prerequisite) continue;
    final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
    if (from == null || to == null) continue;
    out.add((id: e.id, a: _outAnchor(from), b: _inAnchor(to)));
  }
  return out;
}

class CLGraphEdgePainter extends CustomPainter {
  final Map<String, Rect> nodeRects;
  final List<CLGraphEdge> edges;
  final Color containmentColor;
  final Color linkColor;
  final Color orderColor;
  final Color selectedColor;
  final String? selectedEdgeId;

  CLGraphEdgePainter({
    required this.nodeRects,
    required this.edges,
    required this.containmentColor,
    required this.linkColor,
    required this.orderColor,
    required this.selectedColor,
    this.selectedEdgeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) contenimento (modulo→risorsa): curva leggera dalla porta OUT del
    // modulo alla porta IN della risorsa.
    final cPaint = Paint()
      ..color = containmentColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.containment || e.hidden) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      final a = _outAnchor(from), b = _inAnchor(to);
      canvas.drawPath(clLinkPath(a, b), cPaint);
    }
    // 2) ordine (tratteggiata grigia retta, freccia — NON selezionabile)
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.order) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      final paint = Paint()
        ..color = orderColor
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, from.center, to.center, paint);
      _arrowHead(canvas, to.center, math.atan2(to.center.dy - from.center.dy, to.center.dx - from.center.dx), paint);
    }
    // 3) prerequisito (curva piena; selezionato evidenziato)
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.prerequisite) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      final selected = e.id == selectedEdgeId;
      final paint = Paint()
        ..color = selected ? selectedColor : linkColor
        ..strokeWidth = selected ? 2.5 : 1.8
        ..style = PaintingStyle.stroke;
      final a = _outAnchor(from), b = _inAnchor(to);
      canvas.drawPath(clLinkPath(a, b), paint);
    }
    // 4) link-lezione (curva piena rossa come il prereq, ma dalla porta triangolino
    // del source — non dal pallino OUT). Non selezionabile (no cestino).
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.lessonLink || e.hidden) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      final paint = Paint()
        ..color = linkColor
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(clLinkPath(_lessonAnchor(from), _inAnchor(to)), paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0, gap = 4.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * (d + dash).clamp(0.0, total);
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  /// Punta di freccia con vertice in [tip] orientata lungo [angle] (rad).
  void _arrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
    const size = 9.0;
    final p1 = Offset(tip.dx - size * math.cos(angle - math.pi / 7), tip.dy - size * math.sin(angle - math.pi / 7));
    final p2 = Offset(tip.dx - size * math.cos(angle + math.pi / 7), tip.dy - size * math.sin(angle + math.pi / 7));
    canvas.drawLine(tip, p1, paint);
    canvas.drawLine(tip, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CLGraphEdgePainter old) =>
      old.nodeRects != nodeRects ||
      old.edges != edges ||
      old.selectedEdgeId != selectedEdgeId ||
      old.linkColor != linkColor ||
      old.orderColor != orderColor ||
      old.selectedColor != selectedColor ||
      old.containmentColor != containmentColor;
}
