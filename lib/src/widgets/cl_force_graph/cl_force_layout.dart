import 'dart:math' as math;
import 'dart:ui';

// La **simulazione a forze** di `CLForceGraph`: repulsione fra tutti i nodi con Barnes-Hut (un quadtree a ogni passo, θ = 0,9),
// molle sugli archi, gravità verso il centro, smorzamento. Pura (niente widget): passi a mano con [CLForceLayout.step], o tutti
// insieme con [CLForceLayout.settle]. Le posizioni iniziali sono deterministiche (da [seed]), così due disegni dello stesso grafo
// si somigliano e i test sono ripetibili. Un nodo fissato ([pin]) non si muove ma spinge e tira gli altri.

/// Un nodo per la simulazione: id e grado (i nodi con più archi respingono di più).
class CLForceBody {
  CLForceBody(this.id, {this.degree = 0, Offset? position}) : position = position ?? Offset.zero;

  final String id;
  final int degree;
  Offset position;
  Offset velocity = Offset.zero;
  bool pinned = false;
}

/// Il quadtree dei nodi: per la repulsione (Barnes-Hut) e per trovare il nodo sotto un punto.
class CLForceQuadTree {
  CLForceQuadTree._(this.bounds);

  /// Costruisce l'albero dei [bodies] (vuoto = nessun nodo).
  factory CLForceQuadTree.of(Iterable<CLForceBody> bodies) {
    final list = bodies.toList();
    if (list.isEmpty) return CLForceQuadTree._(Rect.zero);
    var minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    for (final b in list) {
      minX = math.min(minX, b.position.dx);
      minY = math.min(minY, b.position.dy);
      maxX = math.max(maxX, b.position.dx);
      maxY = math.max(maxY, b.position.dy);
    }
    final size = math.max(math.max(maxX - minX, maxY - minY), 1.0) + 2;
    final tree = CLForceQuadTree._(Rect.fromLTWH(minX - 1, minY - 1, size, size));
    for (final b in list) {
      tree._insert(b, 0);
    }
    return tree;
  }

  final Rect bounds;
  CLForceBody? _body;
  List<CLForceQuadTree>? _children;
  double mass = 0;
  Offset _weighted = Offset.zero;

  Offset get center => mass == 0 ? bounds.center : _weighted / mass;

  void _insert(CLForceBody b, int depth) {
    final weight = 1.0 + b.degree;
    mass += weight;
    _weighted += b.position * weight;
    if (_children == null && _body == null) {
      _body = b;
      return;
    }
    // Troppi livelli (nodi sovrapposti): restano insieme in questa foglia.
    if (depth > 24) return;
    if (_children == null) {
      final half = bounds.width / 2;
      _children = [
        CLForceQuadTree._(Rect.fromLTWH(bounds.left, bounds.top, half, half)),
        CLForceQuadTree._(Rect.fromLTWH(bounds.left + half, bounds.top, half, half)),
        CLForceQuadTree._(Rect.fromLTWH(bounds.left, bounds.top + half, half, half)),
        CLForceQuadTree._(Rect.fromLTWH(bounds.left + half, bounds.top + half, half, half)),
      ];
      final old = _body!;
      _body = null;
      _childFor(old.position)._insert(old, depth + 1);
    }
    _childFor(b.position)._insert(b, depth + 1);
  }

  CLForceQuadTree _childFor(Offset p) {
    final c = bounds.center;
    final i = (p.dx >= c.dx ? 1 : 0) + (p.dy >= c.dy ? 2 : 0);
    return _children![i];
  }

  /// La spinta su [b] da tutti gli altri nodi ([strength] per unità di massa, approssimazione con [theta]).
  Offset repulsion(CLForceBody b, double strength, {double theta = 0.9}) {
    if (mass == 0) return Offset.zero;
    if (_children == null) {
      final other = _body;
      if (other == null || identical(other, b)) return Offset.zero;
      return _push(b.position, other.position, (1.0 + other.degree) * strength);
    }
    final d = (center - b.position).distance;
    if (d > 0 && bounds.width / d < theta) return _push(b.position, center, mass * strength);
    var f = Offset.zero;
    for (final c in _children!) {
      f += c.repulsion(b, strength, theta: theta);
    }
    return f;
  }

  static Offset _push(Offset at, Offset from, double k) {
    var delta = at - from;
    var d2 = delta.distanceSquared;
    if (d2 < 0.01) {
      // Due nodi nello stesso punto: una spinta fissa, sempre nello stesso verso, per separarli.
      delta = const Offset(0.1, 0.07);
      d2 = delta.distanceSquared;
    }
    return delta / math.sqrt(d2) * (k / math.max(d2, 25));
  }

  /// Il nodo più vicino a [p] entro [radius] (`radiusOf` dà il raggio di ogni nodo, per un tocco sul bordo).
  CLForceBody? hit(Offset p, double Function(CLForceBody b) radiusOf, {double slop = 4}) {
    CLForceBody? best;
    var bestD = double.infinity;
    void visit(CLForceQuadTree t) {
      if (t.mass == 0) return;
      // Le foglie possono avere un nodo vicino al bordo: si allarga il rettangolo del raggio più grande ragionevole.
      if (!t.bounds.inflate(64).contains(p)) return;
      final b = t._body;
      if (b != null) {
        final d = (b.position - p).distance;
        if (d <= radiusOf(b) + slop && d < bestD) {
          best = b;
          bestD = d;
        }
      }
      for (final c in t._children ?? const <CLForceQuadTree>[]) {
        visit(c);
      }
    }

    visit(this);
    return best;
  }
}

/// La simulazione di un grafo.
class CLForceLayout {
  CLForceLayout({
    required List<CLForceBody> bodies,
    required List<(String, String)> edges,
    this.springLength = 70,
    this.springStrength = 0.04,
    this.repulsion = 2600,
    this.gravity = 0.012,
    this.damping = 0.82,
    int seed = 7,
  }) : bodies = {for (final b in bodies) b.id: b},
       edges = [
         for (final e in edges)
           if (e.$1 != e.$2) e,
       ] {
    // Posizioni iniziali su una spirale (deterministica), con un po' di rumore dal seme.
    final rnd = math.Random(seed);
    var i = 0;
    for (final b in this.bodies.values) {
      if (b.position != Offset.zero) continue;
      final a = i * 2.399963; // angolo aureo
      final r = 12.0 * math.sqrt(i + 1);
      b.position = Offset(math.cos(a) * r + rnd.nextDouble(), math.sin(a) * r + rnd.nextDouble());
      i++;
    }
  }

  final Map<String, CLForceBody> bodies;
  final List<(String, String)> edges;
  final double springLength;
  final double springStrength;
  final double repulsion;
  final double gravity;
  final double damping;

  /// L'energia cinetica dell'ultimo passo (si ferma quando è bassa).
  double energy = double.infinity;

  /// Un passo della simulazione; restituisce l'energia.
  double step() {
    if (bodies.isEmpty) return energy = 0;
    final tree = CLForceQuadTree.of(bodies.values);
    final force = <String, Offset>{for (final id in bodies.keys) id: Offset.zero};
    for (final b in bodies.values) {
      force[b.id] = force[b.id]! + tree.repulsion(b, repulsion) - b.position * gravity;
    }
    for (final (from, to) in edges) {
      final a = bodies[from];
      final b = bodies[to];
      if (a == null || b == null) continue;
      final delta = b.position - a.position;
      final d = math.max(delta.distance, 0.01);
      final f = delta / d * ((d - springLength) * springStrength);
      force[a.id] = force[a.id]! + f;
      force[b.id] = force[b.id]! - f;
    }
    var e = 0.0;
    for (final b in bodies.values) {
      if (b.pinned) {
        b.velocity = Offset.zero;
        continue;
      }
      var v = (b.velocity + force[b.id]!) * damping;
      // Un tetto alla velocità: niente esplosioni al primo passo.
      final speed = v.distance;
      if (speed > 40) v = v / speed * 40;
      b.velocity = v;
      b.position += v;
      e += v.distanceSquared;
    }
    return energy = e / bodies.length;
  }

  /// Passi fino a un'energia sotto [threshold], al più [maxSteps]. Restituisce quanti.
  int settle({int maxSteps = 400, double threshold = 0.02}) {
    var n = 0;
    while (n < maxSteps && step() > threshold) {
      n++;
    }
    return n;
  }

  /// Fissa (o libera) un nodo in [position].
  void pin(String id, {Offset? position, bool pinned = true}) {
    final b = bodies[id];
    if (b == null) return;
    if (position != null) b.position = position;
    b.pinned = pinned;
    b.velocity = Offset.zero;
  }

  /// Il rettangolo che contiene tutti i nodi.
  Rect get bounds {
    if (bodies.isEmpty) return Rect.zero;
    var r = Rect.fromCenter(center: bodies.values.first.position, width: 0, height: 0);
    for (final b in bodies.values) {
      r = r.expandToInclude(Rect.fromCenter(center: b.position, width: 0, height: 0));
    }
    return r;
  }
}
