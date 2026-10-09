import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cl_graph_card_metrics.dart' show kGraphPortDot;
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
/// Ancore delle porte a rombo della propedeuticità: [kPropDy] px sopra il centro,
/// OUT sul bordo destro della sorgente, IN sul bordo sinistro del bersaglio.
Offset clPropOutAnchor(Rect r) => Offset(r.right, r.center.dy - kPropDy);
Offset clPropInAnchor(Rect r) => Offset(r.left, r.center.dy - kPropDy);

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
    if (!e.deletable) continue; // né hover né cestino
    final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
    if (from == null || to == null) continue;
    if (e.kind == CLGraphEdgeKind.prerequisite) {
      out.add((id: e.id, a: _outAnchor(from), b: _inAnchor(to)));
    } else if (e.kind == CLGraphEdgeKind.propaedeutic) {
      out.add((id: e.id, a: clPropOutAnchor(from), b: clPropInAnchor(to)));
    }
  }
  return out;
}

/// Estremi di un arco [CLGraphEdgeKind.flow]: porta d'uscita → porta d'ingresso
/// (coordinate canvas), calcolati dal widget che conosce la geometria delle porte.
typedef CLGraphFlowEnds = ({Offset a, Offset b});

/// Campiona la curva di [clLinkPath] in [steps] segmenti retti (stesso id),
/// per l'hit-test di archi che non sono quasi orizzontali (porte a righe
/// diverse): il segmento unico a→b si scosterebbe troppo dalla curva.
List<({String id, Offset a, Offset b})> clSampledLinkSegments(String id, Offset a, Offset b, {int steps = 12}) {
  final c = _ctrlOffset(a, b);
  final p1 = Offset(a.dx + c, a.dy), p2 = Offset(b.dx - c, b.dy);
  Offset at(double t) {
    final u = 1 - t;
    return a * (u * u * u) + p1 * (3 * u * u * t) + p2 * (3 * u * t * t) + b * (t * t * t);
  }

  final out = <({String id, Offset a, Offset b})>[];
  var prev = a;
  for (var i = 1; i <= steps; i++) {
    final next = at(i / steps);
    out.add((id: id, a: prev, b: next));
    prev = next;
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
  /// Colore degli archi [CLGraphEdgeKind.propaedeutic] (tratteggiati). Null ⇒ [linkColor].
  final Color? propaedeuticColor;
  final String? selectedEdgeId;
  /// Estremi degli archi [CLGraphEdgeKind.flow], per id. Un arco flow senza
  /// estremi qui non si disegna.
  final Map<String, CLGraphFlowEnds> flowEnds;
  /// Colore degli archi flow. Null ⇒ [orderColor].
  final Color? flowColor;
  /// Colore dell'arco flow selezionato o sotto il cursore. Null ⇒ [selectedColor].
  final Color? flowSelectedColor;
  /// Archi del cammino percorso: disegnati più spessi in [highlightColor].
  final Set<String> highlightedEdgeIds;
  /// Colore del cammino percorso. Null ⇒ [selectedColor].
  final Color? highlightColor;

  CLGraphEdgePainter({
    required this.nodeRects,
    required this.edges,
    required this.containmentColor,
    required this.linkColor,
    required this.orderColor,
    required this.selectedColor,
    this.propaedeuticColor,
    this.selectedEdgeId,
    this.flowEnds = const {},
    this.flowColor,
    this.flowSelectedColor,
    this.highlightedEdgeIds = const {},
    this.highlightColor,
  });

  bool _hl(CLGraphEdge e) => highlightedEdgeIds.contains(e.id);

  /// Pennello di un arco del cammino percorso (sostituisce quello normale).
  Paint _hlPaint() => Paint()
    ..color = highlightColor ?? selectedColor
    ..strokeWidth = 3.2
    ..style = PaintingStyle.stroke;

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
      canvas.drawPath(clLinkPath(a, b), _hl(e) ? _hlPaint() : cPaint);
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
      final paint = _hl(e)
          ? _hlPaint()
          : (Paint()
            ..color = selected ? selectedColor : linkColor
            ..strokeWidth = selected ? 2.5 : 1.8
            ..style = PaintingStyle.stroke);
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
    // 5) propedeuticità (curva TRATTEGGIATA dalle porte a rombo, freccia sul
    // bersaglio; selezionabile ed eliminabile come il prereq).
    for (final e in edges) {
      if (e.kind != CLGraphEdgeKind.propaedeutic) continue;
      final from = nodeRects[e.fromNodeId], to = nodeRects[e.toNodeId];
      if (from == null || to == null) continue;
      final selected = e.id == selectedEdgeId;
      final color = propaedeuticColor ?? linkColor;
      final paint = Paint()
        ..color = color
        ..strokeWidth = selected ? 2.6 : 1.8
        ..style = PaintingStyle.stroke;
      final a = clPropOutAnchor(from), b = clPropInAnchor(to);
      _drawDashedPath(canvas, clLinkPath(a, b), paint);
      // La curva entra orizzontale nel bersaglio ⇒ freccia verso destra.
      _arrowHead(canvas, b, 0, paint);
    }
    // 6) flusso generico (porta con nome → porta con nome): curva piena con
    // freccia; il cammino percorso sta sopra gli altri (disegnato per ultimo).
    for (final pass in const [false, true]) {
      for (final e in edges) {
        if (e.kind != CLGraphEdgeKind.flow || e.hidden || _hl(e) != pass) continue;
        final ends = flowEnds[e.id];
        if (ends == null) continue;
        final selected = e.id == selectedEdgeId;
        final paint = pass
            ? _hlPaint()
            : (Paint()
              ..color = selected ? (flowSelectedColor ?? selectedColor) : (flowColor ?? orderColor)
              ..strokeWidth = selected ? 2.6 : 1.8
              ..style = PaintingStyle.stroke);
        canvas.drawPath(clLinkPath(ends.a, ends.b), paint);
        // Punta appena fuori dal pallino d'ingresso, che la coprirebbe.
        _arrowHead(canvas, ends.b.translate(-kGraphPortDot / 2, 0), 0, paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 7.0, gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
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
      old.propaedeuticColor != propaedeuticColor ||
      old.containmentColor != containmentColor ||
      old.flowEnds != flowEnds ||
      old.flowColor != flowColor ||
      old.flowSelectedColor != flowSelectedColor ||
      old.highlightedEdgeIds != highlightedEdgeIds ||
      old.highlightColor != highlightColor;
}
