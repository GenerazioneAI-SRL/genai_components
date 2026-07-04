import 'cl_graph_models.dart';

/// child(to) -> parent(from) sugli archi di contenimento.
Map<String, String> containmentParents(List<CLGraphEdge> edges) {
  final parents = <String, String>{};
  for (final e in edges) {
    if (e.kind == CLGraphEdgeKind.containment) parents[e.toNodeId] = e.fromNodeId;
  }
  return parents;
}

/// Tutti i discendenti (containment) dei nodi collassati. I collassati NON sono inclusi.
Set<String> hiddenNodeIds(List<CLGraphEdge> edges, Set<String> collapsedIds) {
  if (collapsedIds.isEmpty) return <String>{};
  final children = <String, List<String>>{};
  for (final e in edges) {
    if (e.kind == CLGraphEdgeKind.containment) {
      (children[e.fromNodeId] ??= <String>[]).add(e.toNodeId);
    }
  }
  final hidden = <String>{};
  final stack = <String>[];
  for (final c in collapsedIds) stack.addAll(children[c] ?? const []);
  while (stack.isNotEmpty) {
    final n = stack.removeLast();
    if (!hidden.add(n)) continue; // già visto → cycle-safe
    stack.addAll(children[n] ?? const []);
  }
  return hidden;
}

/// Nodo visibile su cui agganciare un arco: se nascosto, risale ai parent
/// finché trova un nodo visibile (il collassato che lo nasconde).
String resolveVisibleEndpoint(String nodeId, Set<String> hidden, Map<String, String> parents) {
  var cur = nodeId;
  final seen = <String>{};
  while (hidden.contains(cur) && seen.add(cur)) {
    final p = parents[cur];
    if (p == null) break;
    cur = p;
  }
  return cur;
}
