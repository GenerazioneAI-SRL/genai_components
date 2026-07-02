import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_layout.dart';

CLGraphNode _n(String id, String type) => CLGraphNode(id: id, type: type, title: id);
CLGraphEdge _c(String from, String to) =>
    CLGraphEdge(id: 'c:$from>$to', fromNodeId: from, toNodeId: to, kind: CLGraphEdgeKind.containment);

void main() {
  final nodes = [_n('m', 'module'), _n('c1', 'course'), _n('l1', 'lesson'), _n('l2', 'lesson'), _n('e1', 'exam')];
  final edges = [_c('m', 'c1'), _c('c1', 'l1'), _c('c1', 'l2'), _c('m', 'e1')];

  test('parent is left of its children (column by containment depth)', () {
    final pos = clHierarchicalLayout(nodes, edges);
    expect(pos['m']!.dx, lessThan(pos['c1']!.dx));
    expect(pos['c1']!.dx, lessThan(pos['l1']!.dx));
    expect(pos['m']!.dx, lessThan(pos['e1']!.dx));
    expect(pos['c1']!.dx, equals(pos['e1']!.dx)); // stessa profondità
  });

  test('deterministic: same input -> identical output', () {
    expect(clHierarchicalLayout(nodes, edges), equals(clHierarchicalLayout(nodes, edges)));
  });

  test('every node gets a position', () {
    final pos = clHierarchicalLayout(nodes, edges);
    for (final n in nodes) {
      expect(pos.containsKey(n.id), isTrue, reason: 'manca ${n.id}');
    }
  });
}
