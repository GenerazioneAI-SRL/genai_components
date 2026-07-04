import 'dart:ui';

/// Distanza euclidea dal punto [p] al segmento [a]-[b] (clampata agli estremi).
double distanceToSegment(Offset p, Offset a, Offset b) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final lenSq = dx * dx + dy * dy;
  if (lenSq == 0) return (p - a).distance; // segmento degenere
  var t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / lenSq;
  t = t.clamp(0.0, 1.0);
  final proj = Offset(a.dx + t * dx, a.dy + t * dy);
  return (p - proj).distance;
}

/// Id del segmento più vicino a [p] entro [threshold] px, o null.
String? nearestEdgeId(
  Offset p,
  List<({String id, Offset a, Offset b})> segments, {
  double threshold = 12.0,
}) {
  String? best;
  var bestDist = threshold;
  for (final s in segments) {
    final d = distanceToSegment(p, s.a, s.b);
    if (d <= bestDist) {
      bestDist = d;
      best = s.id;
    }
  }
  return best;
}
