import 'cl_graph_models.dart';

/// "1 uscita" / "2 uscite".
String _count(int n, String one, String many) => n == 1 ? '1 $one' : '$n $many';

bool _isFlow(CLGraphEdge e) => e.kind == CLGraphEdgeKind.prerequisite;

/// Motivo per cui da [from] non può partire nessun nuovo arco di flusso
/// (nessuna uscita ammessa o massimo raggiunto), o null.
String? clGraphOutputProblem(CLGraphNode from, List<CLGraphEdge> edges) {
  final out = from.connectionRules;
  if (!out.acceptsOutputs) return '«${from.title}» non ha uscite';
  final outs = edges.where((e) => _isFlow(e) && e.fromNodeId == from.id).length;
  if (out.maxOutputs != null && outs >= out.maxOutputs!) {
    return '«${from.title}» ha già ${_count(outs, 'uscita', 'uscite')} (massimo ${out.maxOutputs})';
  }
  return null;
}

/// Motivo per cui non si può creare l'arco di flusso [from] → [to], o null se
/// le regole dei due nodi ([CLGraphNode.connectionRules]) lo ammettono.
/// Rifiuta anche l'arco verso se stesso e quello già presente. [typeLabel]
/// traduce i tipi di nodo nei messaggi (default: il tipo così com'è).
String? clGraphConnectionProblem(
  CLGraphNode from,
  CLGraphNode to,
  List<CLGraphEdge> edges, {
  String Function(String type)? typeLabel,
}) {
  final label = typeLabel ?? (String t) => t;
  final out = from.connectionRules;
  final inn = to.connectionRules;
  if (from.id == to.id) return 'Un blocco non si può collegare a se stesso';
  if (edges.any((e) => _isFlow(e) && e.fromNodeId == from.id && e.toNodeId == to.id)) {
    return '«${from.title}» è già collegato a «${to.title}»';
  }
  final outputProblem = clGraphOutputProblem(from, edges);
  if (outputProblem != null) return outputProblem;
  if (out.outputTypes != null && !out.outputTypes!.contains(to.type)) {
    return '«${from.title}» può proseguire solo verso: ${out.outputTypes!.map(label).join(', ')}';
  }
  if (!inn.acceptsInputs) return '«${to.title}» non accetta ingressi';
  final ins = edges.where((e) => _isFlow(e) && e.toNodeId == to.id).length;
  if (inn.maxInputs != null && ins >= inn.maxInputs!) {
    return '«${to.title}» ha già ${_count(ins, 'ingresso', 'ingressi')} (massimo ${inn.maxInputs})';
  }
  if (inn.inputTypes != null && !inn.inputTypes!.contains(from.type)) {
    return '«${to.title}» accetta ingressi solo da: ${inn.inputTypes!.map(label).join(', ')}';
  }
  return null;
}

/// Avvisi sui collegamenti di ogni nodo rispetto alle sue regole: minimi non
/// raggiunti, massimi superati, archi da o verso tipi non ammessi (es. dati
/// caricati da fuori). Contiene solo i nodi con almeno un avviso; i nodi senza
/// regole non ne hanno mai. Gli archi verso nodi assenti da [nodes] contano nei
/// minimi e nei massimi ma non nel controllo dei tipi.
Map<String, List<String>> clGraphConnectionWarnings(List<CLGraphNode> nodes, List<CLGraphEdge> edges) {
  final byId = {for (final n in nodes) n.id: n};
  final incoming = <String, List<CLGraphEdge>>{};
  final outgoing = <String, List<CLGraphEdge>>{};
  for (final e in edges) {
    if (!_isFlow(e)) continue;
    (outgoing[e.fromNodeId] ??= []).add(e);
    (incoming[e.toNodeId] ??= []).add(e);
  }
  final result = <String, List<String>>{};
  for (final n in nodes) {
    final r = n.connectionRules;
    final ins = incoming[n.id] ?? const <CLGraphEdge>[];
    final outs = outgoing[n.id] ?? const <CLGraphEdge>[];
    final warnings = <String>[
      if (ins.length < r.minInputs)
        r.minInputs == 1 ? 'Manca il collegamento in ingresso' : 'Servono almeno ${r.minInputs} ingressi (ora ${ins.length})',
      if (outs.length < r.minOutputs)
        r.minOutputs == 1 ? 'Manca il collegamento in uscita' : 'Servono almeno ${r.minOutputs} uscite (ora ${outs.length})',
      if (r.maxInputs != null && ins.length > r.maxInputs!) 'Troppi ingressi: ${ins.length} (massimo ${r.maxInputs})',
      if (r.maxOutputs != null && outs.length > r.maxOutputs!) 'Troppe uscite: ${outs.length} (massimo ${r.maxOutputs})',
      for (final e in ins)
        if (byId[e.fromNodeId] case final src? when r.inputTypes != null && !r.inputTypes!.contains(src.type))
          'Ingresso non ammesso da «${src.title}»',
      for (final e in outs)
        if (byId[e.toNodeId] case final dst? when r.outputTypes != null && !r.outputTypes!.contains(dst.type))
          'Uscita non ammessa verso «${dst.title}»',
    ];
    if (warnings.isNotEmpty) result[n.id] = warnings;
  }
  return result;
}
