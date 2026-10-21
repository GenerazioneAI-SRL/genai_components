import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genai_components/cl_theme.dart';

import 'cl_force_layout.dart';

/// Un nodo di [CLForceGraph]: id, etichetta, gruppo (il colore), grado (la dimensione), [muted] per i nodi «da scrivere».
@immutable
class CLForceNode {
  const CLForceNode({required this.id, required this.label, this.group, this.degree = 0, this.muted = false, this.data});

  final String id;
  final String label;

  /// Il gruppo di colore (es. la cartella di primo livello o il progetto): stesso gruppo, stesso colore.
  final String? group;

  /// Quanti archi ha: il cerchio cresce col grado (e respinge di più).
  final int degree;

  /// Un nodo tenue (un collegamento irrisolto, un elemento fuori filtro).
  final bool muted;

  /// Un dato opaco di chi usa il grafo.
  final Object? data;
}

/// Un arco di [CLForceGraph] (non orientato nel disegno); [dashed] per un tipo secondario (es. gli embed).
@immutable
class CLForceEdge {
  const CLForceEdge(this.from, this.to, {this.dashed = false});
  final String from;
  final String to;
  final bool dashed;
}

/// **Grafo a forze** esplorativo (famiglia «Org chart e Node graph»): migliaia di nodi su un `CustomPaint`, posizioni da una
/// simulazione a forze (Barnes-Hut a passi, [CLForceLayout]) e un quadtree per il tocco. Non è [CLNodeGraph] (card, layout
/// gerarchici, editing degli archi): qui i nodi sono cerchi che crescono col grado, le etichette compaiono con lo zoom (oltre
/// [labelScale], e sempre per il nodo evidenziato e i suoi vicini), i colori vengono dai token di `CLTheme` (il gruppo con
/// [groupColor], di serie `CLTheme.generateColorFromText`).
///
/// Interazioni: rotella e pizzico per lo zoom, trascinamento del fondo per spostarsi, passaggio del mouse che evidenzia il nodo e i
/// suoi vicini, tocco che chiama [onNodeTap], trascinamento di un nodo che lo **fissa** dove lo si lascia (doppio tocco lo libera).
/// [animate] spento = la simulazione si assesta subito, senza ticker (test, stampe).
class CLForceGraph extends StatefulWidget {
  const CLForceGraph({
    super.key,
    required this.nodes,
    required this.edges,
    this.onNodeTap,
    this.selectedId,
    this.groupColor,
    this.labelScale = 1.1,
    this.animate = true,
    this.maxSteps = 500,
    this.seed = 7,
    this.emptyText = 'Nessun nodo da mostrare',
  });

  final List<CLForceNode> nodes;
  final List<CLForceEdge> edges;
  final void Function(String id)? onNodeTap;

  /// Il nodo scelto (bordo nel colore primario, etichetta sempre visibile).
  final String? selectedId;

  /// Il colore di un gruppo; di serie `CLTheme.generateColorFromText(group)`.
  final Color Function(String group)? groupColor;

  /// Da che zoom si vedono tutte le etichette.
  final double labelScale;
  final bool animate;
  final int maxSteps;
  final int seed;
  final String emptyText;

  @override
  State<CLForceGraph> createState() => CLForceGraphState();
}

class CLForceGraphState extends State<CLForceGraph> with SingleTickerProviderStateMixin {
  late CLForceLayout _layout;
  Ticker? _ticker;
  int _steps = 0;
  double _scale = 1;
  Offset _pan = Offset.zero;
  Size _size = Size.zero;
  bool _fitted = false;
  String? _hovered;
  String? _dragging;
  Offset? _focal;
  double _startScale = 1;
  Map<String, Set<String>> _neighbors = const {};
  Map<String, CLForceNode> _byId = const {};

  @visibleForTesting
  CLForceLayout get layout => _layout;

  /// Dove sta il nodo [id] sullo schermo (coordinate locali del widget), per i test e per chi vuole un popover.
  Offset? screenPositionOf(String id) {
    final b = _layout.bodies[id];
    return b == null ? null : _toScreen(b.position);
  }

  @override
  void initState() {
    super.initState();
    _build(null);
  }

  @override
  void didUpdateWidget(covariant CLForceGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.nodes, widget.nodes) || !identical(oldWidget.edges, widget.edges)) _build(_layout);
  }

  @override
  void dispose() {
    // Fermo prima di liberarlo: il mixin vuole un ticker spento allo smontaggio.
    _ticker?.stop();
    _ticker?.dispose();
    super.dispose();
  }

  void _build(CLForceLayout? previous) {
    _byId = {for (final n in widget.nodes) n.id: n};
    final bodies = [
      for (final n in widget.nodes)
        CLForceBody(n.id, degree: n.degree, position: previous?.bodies[n.id]?.position)..pinned = previous?.bodies[n.id]?.pinned ?? false,
    ];
    final edges = [
      for (final e in widget.edges)
        if (_byId.containsKey(e.from) && _byId.containsKey(e.to)) (e.from, e.to),
    ];
    _neighbors = {for (final n in widget.nodes) n.id: <String>{}};
    for (final (a, b) in edges) {
      _neighbors[a]!.add(b);
      _neighbors[b]!.add(a);
    }
    _layout = CLForceLayout(bodies: bodies, edges: edges, seed: widget.seed);
    _steps = 0;
    if (!widget.animate) {
      _layout.settle(maxSteps: widget.maxSteps);
      _fitted = false;
      return;
    }
    _ticker ??= createTicker(_tick);
    if (!_ticker!.isActive) _ticker!.start();
  }

  void _tick(Duration _) {
    var e = 0.0;
    for (var i = 0; i < 3; i++) {
      e = _layout.step();
      _steps++;
    }
    if (!_fitted && _size != Size.zero && _steps > 60) _fit();
    if (e < 0.02 || _steps >= widget.maxSteps) {
      _ticker?.stop();
      if (!_fitted) _fit();
    }
    if (mounted) setState(() {});
  }

  /// Inquadra tutti i nodi.
  void _fit() {
    if (_size == Size.zero) return;
    final b = _layout.bounds.inflate(40);
    final s = math.min(_size.width / math.max(b.width, 1), _size.height / math.max(b.height, 1)).clamp(0.05, 2.5);
    _scale = s;
    _pan = Offset(_size.width / 2, _size.height / 2) - b.center * s;
    _fitted = true;
  }

  Offset _toScreen(Offset p) => p * _scale + _pan;
  Offset _toGraph(Offset p) => (p - _pan) / _scale;

  double _radius(CLTheme theme, CLForceBody b) => theme.gapXs * (1.2 + 0.6 * math.sqrt(b.degree.toDouble())).clamp(1.2, 5.0);

  String? _hit(Offset local, CLTheme theme) {
    final tree = CLForceQuadTree.of(_layout.bodies.values);
    final b = tree.hit(_toGraph(local), (b) => _radius(theme, b), slop: 6 / _scale);
    return b?.id;
  }

  void _zoomAt(Offset focal, double factor) {
    final next = (_scale * factor).clamp(0.05, 6.0);
    final g = _toGraph(focal);
    _scale = next;
    _pan = focal - g * _scale;
  }

  void _restart() {
    if (!widget.animate) return;
    _steps = math.min(_steps, widget.maxSteps - 120);
    if (!(_ticker?.isActive ?? false)) _ticker?.start();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    if (widget.nodes.isEmpty) {
      return Center(child: Text(widget.emptyText, style: theme.bodyText.copyWith(color: theme.secondaryText)));
    }
    return LayoutBuilder(
      builder: (context, c) {
        _size = c.biggest;
        if (!_fitted && (!widget.animate || _steps >= widget.maxSteps)) _fit();
        return Listener(
          onPointerSignal: (e) {
            if (e is PointerScrollEvent) setState(() => _zoomAt(e.localPosition, e.scrollDelta.dy > 0 ? 0.9 : 1.1));
          },
          child: MouseRegion(
            onHover: (e) {
              final id = _hit(e.localPosition, theme);
              if (id != _hovered) setState(() => _hovered = id);
            },
            onExit: (_) => setState(() => _hovered = null),
            cursor: _hovered != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final id = _hit(d.localPosition, theme);
                if (id != null) widget.onNodeTap?.call(id);
              },
              onDoubleTapDown: (d) {
                final id = _hit(d.localPosition, theme);
                if (id != null) {
                  setState(() => _layout.pin(id, pinned: false));
                  _restart();
                }
              },
              onScaleStart: (d) {
                _dragging = d.pointerCount == 1 ? _hit(d.localFocalPoint, theme) : null;
                _focal = d.localFocalPoint;
                _startScale = _scale;
              },
              onScaleUpdate: (d) {
                setState(() {
                  final dragged = _dragging;
                  if (dragged != null) {
                    _layout.pin(dragged, position: _toGraph(d.localFocalPoint));
                  } else {
                    if (d.pointerCount > 1) {
                      final g = _toGraph(d.localFocalPoint);
                      _scale = (_startScale * d.scale).clamp(0.05, 6.0);
                      _pan = d.localFocalPoint - g * _scale;
                    } else {
                      _pan += d.localFocalPoint - (_focal ?? d.localFocalPoint);
                    }
                  }
                  _focal = d.localFocalPoint;
                });
                if (_dragging != null) _restart();
              },
              onScaleEnd: (_) => _dragging = null,
              child: CustomPaint(
                size: Size.infinite,
                painter: _CLForcePainter(
                  layout: _layout,
                  nodes: _byId,
                  edges: widget.edges,
                  neighbors: _neighbors,
                  theme: theme,
                  scale: _scale,
                  pan: _pan,
                  hovered: _hovered,
                  selected: widget.selectedId,
                  labelScale: widget.labelScale,
                  groupColor: widget.groupColor,
                  radius: (b) => _radius(theme, b),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CLForcePainter extends CustomPainter {
  _CLForcePainter({
    required this.layout,
    required this.nodes,
    required this.edges,
    required this.neighbors,
    required this.theme,
    required this.scale,
    required this.pan,
    required this.hovered,
    required this.selected,
    required this.labelScale,
    required this.groupColor,
    required this.radius,
  });

  final CLForceLayout layout;
  final Map<String, CLForceNode> nodes;
  final List<CLForceEdge> edges;
  final Map<String, Set<String>> neighbors;
  final CLTheme theme;
  final double scale;
  final Offset pan;
  final String? hovered;
  final String? selected;
  final double labelScale;
  final Color Function(String group)? groupColor;
  final double Function(CLForceBody b) radius;

  Offset _s(Offset p) => p * scale + pan;

  @override
  void paint(Canvas canvas, Size size) {
    final focus = hovered ?? selected;
    final near = focus == null ? const <String>{} : {focus, ...?neighbors[focus]};
    bool dim(String id) => focus != null && !near.contains(id);
    final view = Offset.zero & size;
    final edgePaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (final e in edges) {
      final a = layout.bodies[e.from];
      final b = layout.bodies[e.to];
      if (a == null || b == null) continue;
      final p1 = _s(a.position);
      final p2 = _s(b.position);
      if (!view.inflate(40).contains(p1) && !view.inflate(40).contains(p2)) continue;
      final lit = focus != null && (e.from == focus || e.to == focus);
      edgePaint.color = lit ? theme.primary : theme.borderColor.withValues(alpha: dim(e.from) && dim(e.to) ? 0.25 : 0.9);
      edgePaint.strokeWidth = lit ? 1.6 : 1;
      if (e.dashed) {
        final d = p2 - p1;
        final len = d.distance;
        if (len == 0) continue;
        final dir = d / len;
        for (var t = 0.0; t < len; t += 8) {
          canvas.drawLine(p1 + dir * t, p1 + dir * math.min(t + 4, len), edgePaint);
        }
      } else {
        canvas.drawLine(p1, p2, edgePaint);
      }
    }
    final allLabels = scale >= labelScale;
    for (final b in layout.bodies.values) {
      final n = nodes[b.id];
      if (n == null) continue;
      final p = _s(b.position);
      final r = radius(b) * math.sqrt(scale).clamp(0.6, 2.0);
      if (!view.inflate(r + 60).contains(p)) continue;
      final base = n.muted ? theme.secondaryText : (n.group == null ? theme.primary : (groupColor?.call(n.group!) ?? theme.generateColorFromText(n.group!)));
      final faded = dim(b.id);
      canvas.drawCircle(p, r, Paint()..color = base.withValues(alpha: faded ? 0.25 : (n.muted ? 0.55 : 1)));
      if (b.id == selected || b.id == hovered) {
        canvas.drawCircle(
          p,
          r + 2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = theme.primary,
        );
      }
      if (b.pinned) canvas.drawCircle(p, math.max(r / 3, 1.5), Paint()..color = theme.secondaryBackground);
      final showLabel = (allLabels && !faded) || near.contains(b.id) || b.id == selected;
      if (showLabel) {
        final tp = TextPainter(
          text: TextSpan(text: n.label, style: theme.smallText.copyWith(color: faded ? theme.secondaryText : theme.primaryText)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: 180);
        tp.paint(canvas, p + Offset(-tp.width / 2, r + 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CLForcePainter old) => true;
}
