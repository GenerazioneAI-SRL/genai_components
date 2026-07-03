import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_geometry.dart';

void main() {
  test('distanceToSegment: punto sul segmento = 0', () {
    expect(distanceToSegment(const Offset(5, 0), const Offset(0, 0), const Offset(10, 0)), closeTo(0, 0.001));
  });
  test('distanceToSegment: perpendicolare', () {
    expect(distanceToSegment(const Offset(5, 3), const Offset(0, 0), const Offset(10, 0)), closeTo(3, 0.001));
  });
  test('distanceToSegment: oltre l\'estremo usa la distanza dall\'estremo', () {
    expect(distanceToSegment(const Offset(-4, 0), const Offset(0, 0), const Offset(10, 0)), closeTo(4, 0.001));
  });
  test('distanceToSegment: segmento degenere (a==b) = distanza dal punto', () {
    expect(distanceToSegment(const Offset(3, 4), const Offset(0, 0), const Offset(0, 0)), closeTo(5, 0.001));
  });

  final segs = [
    (id: 'e1', a: const Offset(0, 0), b: const Offset(100, 0)),
    (id: 'e2', a: const Offset(0, 50), b: const Offset(100, 50)),
  ];
  test('nearestEdgeId: sceglie il più vicino entro soglia', () {
    expect(nearestEdgeId(const Offset(50, 2), segs), 'e1');
    expect(nearestEdgeId(const Offset(50, 48), segs), 'e2');
  });
  test('nearestEdgeId: null se oltre soglia', () {
    expect(nearestEdgeId(const Offset(50, 25), segs, threshold: 5), isNull);
  });
}
