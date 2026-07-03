import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cl_graph_models.dart';

/// Estremi (centri card) di ogni arco `link`, per painter e hit-test.
List<({String id, Offset a, Offset b})> linkSegments(
  Map<String, Rect> nodeRects,
  List<CLGraphEdge> edges,
) {
  final out = <({String id, Offset a, Offset b})>[];
  for (final e in edges) {
    if (e.kind != CLGraphEdgeKind.link) continue;
    final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
    if (from == null || to == null) continue;
    out.add((id: e.id, a: from.center, b: to.center));
  }
  return out;
}

class CLGraphEdgePainter extends CustomPainter {
  final Map<String, Rect> nodeRects;
  final List<CLGraphEdge> edges;
  final Color containmentColor;
  final Color linkColor;
  final Color selectedColor;
  final String? selectedEdgeId;

  CLGraphEdgePainter({
    required this.nodeRects,
    required this.edges,
    required this.containmentColor,
    required this.linkColor,
    required this.selectedColor,
    this.selectedEdgeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) contenimento (sotto, neutro, no freccia)
    final cPaint = Paint()
      ..color = containmentColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.containment) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      canvas.drawLine(from.center, to.center, cPaint);
    }
    // 2) propedeuticità (freccia; selezionato evidenziato + ×)
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.link) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      final selected = e.id == selectedEdgeId;
      final paint = Paint()
        ..color = selected ? selectedColor : linkColor
        ..strokeWidth = selected ? 2.5 : 1.8
        ..style = PaintingStyle.stroke;
      final a = from.center, b = to.center;
      canvas.drawLine(a, b, paint);
      _drawArrowHead(canvas, a, b, paint);
      if (selected) _drawDeleteX(canvas, Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2), selectedColor);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset a, Offset b, Paint paint) {
    const size = 9.0;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    // punta arretrata di ~18px dal centro target per non finire dentro la card
    final tip = Offset(b.dx - 18 * math.cos(angle), b.dy - 18 * math.sin(angle));
    final p1 = Offset(tip.dx - size * math.cos(angle - math.pi / 7), tip.dy - size * math.sin(angle - math.pi / 7));
    final p2 = Offset(tip.dx - size * math.cos(angle + math.pi / 7), tip.dy - size * math.sin(angle + math.pi / 7));
    canvas.drawLine(tip, p1, paint);
    canvas.drawLine(tip, p2, paint);
  }

  void _drawDeleteX(Canvas canvas, Offset c, Color color) {
    const r = 9.0;
    final bg = Paint()..color = color;
    canvas.drawCircle(c, r + 2, bg);
    final x = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-4, -4), c + const Offset(4, 4), x);
    canvas.drawLine(c + const Offset(-4, 4), c + const Offset(4, -4), x);
  }

  @override
  bool shouldRepaint(covariant CLGraphEdgePainter old) =>
      old.nodeRects != nodeRects ||
      old.edges != edges ||
      old.selectedEdgeId != selectedEdgeId ||
      old.linkColor != linkColor ||
      old.selectedColor != selectedColor ||
      old.containmentColor != containmentColor;
}
