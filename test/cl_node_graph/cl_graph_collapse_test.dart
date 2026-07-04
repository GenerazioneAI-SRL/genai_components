import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_collapse.dart';

CLGraphEdge _c(String from, String to) =>
    CLGraphEdge(id: '$from>$to', fromNodeId: from, toNodeId: to, kind: CLGraphEdgeKind.containment);

void main() {
  // plan -> m1 -> s1 -> l1 ; m1 -> s2 ; plan -> m2 -> s3
  final edges = [_c('plan', 'm1'), _c('m1', 's1'), _c('s1', 'l1'), _c('m1', 's2'), _c('plan', 'm2'), _c('m2', 's3')];

  test('containmentParents maps child to parent', () {
    final p = containmentParents(edges);
    expect(p['m1'], 'plan');
    expect(p['s1'], 'm1');
    expect(p['l1'], 's1');
    expect(p['s3'], 'm2');
    expect(p.containsKey('plan'), isFalse);
  });

  test('hiddenNodeIds: collapsing m1 hides its whole subtree but not m1', () {
    final h = hiddenNodeIds(edges, {'m1'});
    expect(h, containsAll(['s1', 'l1', 's2']));
    expect(h.contains('m1'), isFalse);
    expect(h.contains('m2'), isFalse);
    expect(h.contains('s3'), isFalse);
  });

  test('hiddenNodeIds: collapsing a sequence hides only its lessons', () {
    final h = hiddenNodeIds(edges, {'s1'});
    expect(h, equals({'l1'}));
  });

  test('hiddenNodeIds: empty collapsed => nothing hidden', () {
    expect(hiddenNodeIds(edges, {}), isEmpty);
  });

  test('resolveVisibleEndpoint: hidden node resolves to collapsed ancestor', () {
    final h = hiddenNodeIds(edges, {'m1'});
    final p = containmentParents(edges);
    expect(resolveVisibleEndpoint('s1', h, p), 'm1');
    expect(resolveVisibleEndpoint('l1', h, p), 'm1');
  });

  test('resolveVisibleEndpoint: visible node resolves to itself', () {
    final h = hiddenNodeIds(edges, {'m1'});
    final p = containmentParents(edges);
    expect(resolveVisibleEndpoint('s3', h, p), 's3');
    expect(resolveVisibleEndpoint('m1', h, p), 'm1');
  });

  test('hiddenNodeIds cycle-safe', () {
    final cyc = [_c('a', 'b'), _c('b', 'a')];
    expect(() => hiddenNodeIds(cyc, {'a'}), returnsNormally);
  });
}
