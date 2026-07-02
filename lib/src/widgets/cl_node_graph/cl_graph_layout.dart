import 'package:flutter/widgets.dart';
import 'cl_graph_models.dart';

const double _colWidth = 300;
const double _rowHeight = 130;

/// Layout gerarchico L→R deterministico: la colonna è la profondità nella
/// gerarchia di contenimento; la y di un nodo è la media delle y dei suoi
/// figli (foglie impilate in ordine stabile). Gli archi `link` sono ignorati.
Map<String, Offset> clHierarchicalLayout(List<CLGraphNode> nodes, List<CLGraphEdge> edges) {
  final children = <String, List<String>>{};
  final hasParent = <String>{};
  final byId = {for (final n in nodes) n.id: n};
  for (final e in edges) {
    if (e.kind != CLGraphEdgeKind.containment) continue;
    if (!byId.containsKey(e.fromNodeId) || !byId.containsKey(e.toNodeId)) continue;
    (children[e.fromNodeId] ??= []).add(e.toNodeId);
    hasParent.add(e.toNodeId);
  }

  final positions = <String, Offset>{};
  var rowCursor = 0;

  double place(String id, int depth) {
    final kids = children[id] ?? const [];
    final double y;
    if (kids.isEmpty) {
      y = rowCursor * _rowHeight;
      rowCursor++;
    } else {
      final ys = [for (final k in kids) place(k, depth + 1)];
      y = ys.reduce((a, b) => a + b) / ys.length;
    }
    positions[id] = Offset(depth * _colWidth, y);
    return y;
  }

  // root = nodi senza padre di contenimento, in ordine stabile della lista.
  for (final n in nodes) {
    if (!hasParent.contains(n.id)) place(n.id, 0);
  }
  // eventuali nodi non raggiunti (dati incoerenti): impilali a destra.
  for (final n in nodes) {
    if (!positions.containsKey(n.id)) {
      positions[n.id] = Offset(_colWidth, rowCursor * _rowHeight);
      rowCursor++;
    }
  }
  return positions;
}

/// Ruolo di un link tracciato dall'utente, in base alle porte coinvolte.
enum CLGraphLinkRole { containment, link, invalid }

/// Porte del nodo CL (vedi CLNodeGraph): contenimento = parent(in)/children(out),
/// propedeuticità = requires(in)/unlocks(out).
({CLGraphLinkRole role, bool sourceIsFrom}) classifyGraphLink(String fromPortId, String toPortId) {
  const containment = {'children', 'parent'};
  const link = {'unlocks', 'requires'};
  final pair = {fromPortId, toPortId};
  if (pair.length == 2 && pair.containsAll(containment)) {
    // sorgente = il nodo lato 'children' (il padre)
    return (role: CLGraphLinkRole.containment, sourceIsFrom: fromPortId == 'children');
  }
  if (pair.length == 2 && pair.containsAll(link)) {
    // sorgente = il nodo lato 'unlocks' (il prerequisito)
    return (role: CLGraphLinkRole.link, sourceIsFrom: fromPortId == 'unlocks');
  }
  return (role: CLGraphLinkRole.invalid, sourceIsFrom: false);
}
