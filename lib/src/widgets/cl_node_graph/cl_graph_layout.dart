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
  final placed = <String>{};
  var rowCursor = 0;

  double place(String id, int depth) {
    if (placed.contains(id)) return positions[id]?.dy ?? rowCursor * _rowHeight;
    placed.add(id);
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

const double _flowColStep = 300;
const double _flowRowStep = 130;

/// Layout "flusso prereq": colonna = profondità nella catena prereq (longest-path
/// dai root senza prereq); riga = impilamento greedy in ordine d'input evitando
/// collisioni per colonna. I nodi vanno passati GIÀ ordinati per `order`
/// (indice in lista = order). Ignora archi non-prerequisite. Deterministico.
Map<String, Offset> clPrereqFlowLayout(List<CLGraphNode> nodes, List<CLGraphEdge> edges) {
  final byId = {for (final n in nodes) n.id: n};
  final incoming = <String, List<String>>{for (final n in nodes) n.id: <String>[]};
  for (final e in edges) {
    if (e.kind != CLGraphEdgeKind.prerequisite) continue;
    if (!byId.containsKey(e.fromNodeId) || !byId.containsKey(e.toNodeId)) continue;
    incoming[e.toNodeId]!.add(e.fromNodeId); // from = prereq (source) di to
  }

  // Colonna = longest path dai root, con guardia cicli.
  final col = <String, int>{};
  final visiting = <String>{};
  int computeCol(String id) {
    final cached = col[id];
    if (cached != null) return cached;
    if (!visiting.add(id)) return 0; // ciclo → fallback col 0
    var c = 0;
    for (final p in incoming[id]!) {
      final pc = computeCol(p) + 1;
      if (pc > c) c = pc;
    }
    visiting.remove(id);
    return col[id] = c;
  }
  for (final n in nodes) {
    computeCol(n.id);
  }

  // Riga = greedy in ordine d'input, una cella (col,row) per nodo.
  final row = <String, int>{};
  final used = <String>{}; // "col:row"
  int firstFreeRow(int c) {
    var r = 0;
    while (used.contains('$c:$r')) {
      r++;
    }
    return r;
  }
  for (final n in nodes) {
    final c = col[n.id]!;
    final preds = incoming[n.id]!;
    int r;
    if (preds.isEmpty) {
      r = firstFreeRow(c);
    } else {
      var best = preds.first;
      for (final p in preds) {
        if ((col[p] ?? 0) > (col[best] ?? 0)) best = p;
      }
      final inherited = row[best] ?? firstFreeRow(c);
      r = used.contains('$c:$inherited') ? firstFreeRow(c) : inherited;
    }
    row[n.id] = r;
    used.add('$c:$r');
  }

  return {for (final n in nodes) n.id: Offset(col[n.id]! * _flowColStep, row[n.id]! * _flowRowStep)};
}

/// Layout a bande per modulo: ogni nodo con figli di containment è la TESTA di
/// una banda (colonna 0, centrato verticalmente); i suoi figli (risorse) fluiscono
/// a destra per prereq (colonna = 1 + profondità catena calcolata sui SOLI prereq
/// intra-modulo), impilati per ordine d'input evitando collisioni. Bande impilate
/// verticalmente in ordine d'input dei moduli. Nodi senza modulo → in coda.
/// Deterministico. Usa containment (modulo→risorsa) + prerequisite (risorsa→risorsa).
Map<String, Offset> clModuleFlowLayout(List<CLGraphNode> nodes, List<CLGraphEdge> edges) {
  final byId = {for (final n in nodes) n.id: n};
  final childrenOf = <String, List<String>>{};
  for (final e in edges) {
    if (e.kind != CLGraphEdgeKind.containment) continue;
    if (!byId.containsKey(e.fromNodeId) || !byId.containsKey(e.toNodeId)) continue;
    (childrenOf[e.fromNodeId] ??= []).add(e.toNodeId);
  }
  // Profondità di colonna: sia i prereq (risorsa→risorsa) sia i link-lezione
  // (corso→lezione) spingono il target a destra del source. Il link-lezione parte
  // da una porta diversa (triangolino) ma per il layout conta come una catena.
  final incoming = <String, List<String>>{for (final n in nodes) n.id: <String>[]};
  for (final e in edges) {
    if (e.kind != CLGraphEdgeKind.prerequisite && e.kind != CLGraphEdgeKind.lessonLink) continue;
    if (!byId.containsKey(e.fromNodeId) || !byId.containsKey(e.toNodeId)) continue;
    incoming[e.toNodeId]!.add(e.fromNodeId);
  }

  final positions = <String, Offset>{};
  var bandBase = 0; // riga base (globale) della banda corrente

  for (final module in nodes) {
    final kids = childrenOf[module.id];
    if (kids == null || kids.isEmpty) continue;
    final kidSet = kids.toSet();

    // Colonna dei figli = 1 + profondità catena prereq INTRA-modulo (guardia cicli).
    final col = <String, int>{};
    final visiting = <String>{};
    int computeCol(String id) {
      final cached = col[id];
      if (cached != null) return cached;
      if (!visiting.add(id)) return 0;
      var c = 0;
      for (final p in incoming[id]!) {
        if (!kidSet.contains(p)) continue; // solo prereq tra figli dello stesso modulo
        final pc = computeCol(p) + 1;
        if (pc > c) c = pc;
      }
      visiting.remove(id);
      return col[id] = c;
    }
    for (final k in kids) {
      computeCol(k);
    }

    // Riga greedy dentro la banda (una cella per figlio).
    final row = <String, int>{};
    final used = <String>{};
    int firstFreeRow(int c) {
      var r = 0;
      while (used.contains('$c:$r')) {
        r++;
      }
      return r;
    }
    for (final k in kids) {
      final c = col[k]!;
      final preds = [for (final p in incoming[k]!) if (kidSet.contains(p)) p];
      int r;
      if (preds.isEmpty) {
        r = firstFreeRow(c);
      } else {
        var best = preds.first;
        for (final p in preds) {
          if ((col[p] ?? 0) > (col[best] ?? 0)) best = p;
        }
        final inherited = row[best] ?? firstFreeRow(c);
        r = used.contains('$c:$inherited') ? firstFreeRow(c) : inherited;
      }
      row[k] = r;
      used.add('$c:$r');
    }
    var bandRows = 0;
    for (final r in row.values) {
      if (r + 1 > bandRows) bandRows = r + 1;
    }
    if (bandRows == 0) bandRows = 1;

    // Figli: colonna +1 (col 0 riservata al modulo); riga = base banda + riga locale.
    for (final k in kids) {
      positions[k] = Offset((col[k]! + 1) * _flowColStep, (bandBase + row[k]!) * _flowRowStep);
    }
    // Modulo: colonna 0, centrato verticalmente sulla banda.
    positions[module.id] = Offset(0, (bandBase + (bandRows - 1) / 2.0) * _flowRowStep);

    bandBase += bandRows;
  }

  // Nodi non posizionati (senza modulo / orfani) → impilali in coda a sinistra.
  for (final n in nodes) {
    if (positions.containsKey(n.id)) continue;
    positions[n.id] = Offset(0, bandBase * _flowRowStep);
    bandBase++;
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
