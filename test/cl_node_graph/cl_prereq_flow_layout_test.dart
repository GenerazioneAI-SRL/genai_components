import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_layout.dart';

CLGraphNode _n(String id) => CLGraphNode(id: id, type: 'resource', title: id);
CLGraphEdge _p(String from, String to) =>
    CLGraphEdge(id: '$from>$to', fromNodeId: from, toNodeId: to, kind: CLGraphEdgeKind.prerequisite);

void main() {
  test('catena prereq orizzontale, indipendenti in verticale', () {
    // a,b,c per order; a propedeutico a b; c indipendente
    final pos = clPrereqFlowLayout([_n('a'), _n('b'), _n('c')], [_p('a', 'b')]);
    expect(pos['a'], const Offset(0, 0));
    expect(pos['b'], const Offset(300, 0)); // a destra di a (stessa riga)
    expect(pos['c'], const Offset(0, 130)); // non legato → riga sotto
  });

  test('dipendenti multipli dello stesso prereq vanno su righe diverse', () {
    // a propedeutico sia a b sia a c
    final pos = clPrereqFlowLayout([_n('a'), _n('b'), _n('c')], [_p('a', 'b'), _p('a', 'c')]);
    expect(pos['a'], const Offset(0, 0));
    expect(pos['b'], const Offset(300, 0)); // eredita riga di a
    expect(pos['c'], const Offset(300, 130)); // cella (col1,row0) occupata → riga nuova
  });

  test('colonna = profondità catena (longest path)', () {
    final pos = clPrereqFlowLayout([_n('a'), _n('b'), _n('c')], [_p('a', 'b'), _p('b', 'c')]);
    expect(pos['c'], const Offset(600, 0)); // col 2
  });
}
