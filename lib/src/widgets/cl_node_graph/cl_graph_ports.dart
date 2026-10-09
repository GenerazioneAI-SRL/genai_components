import 'package:flutter/widgets.dart';

/// Porta con nome di un nodo (`CLGraphNode.inputPorts` / `outputPorts`): un
/// punto d'aggancio sul bordo della card, a sinistra per gli ingressi e a
/// destra per le uscite, con l'etichetta accanto (es. `sì`/`no`, `ok`/`errore`,
/// una per caso di uno SWITCH). Gli archi [CLGraphEdgeKind.flow] partono da una
/// porta d'uscita e arrivano a una porta d'ingresso.
class CLGraphPort {
  /// Id della porta, unico sul suo lato del nodo (es. 'yes', 'no', 'in').
  final String id;

  /// Etichetta disegnata accanto alla porta. Null ⇒ solo il pallino. Se
  /// nessuna porta del nodo ha etichetta, le porte si distribuiscono sul bordo
  /// senza righe aggiuntive (la card resta alta come senza porte).
  final String? label;

  /// Tooltip del pallino. Null ⇒ [label].
  final String? tooltip;

  /// Colore del pallino. Null ⇒ colore delle porte del grafo.
  final Color? color;

  /// Massimo di archi su questa porta. Null ⇒ illimitati.
  final int? maxConnections;

  const CLGraphPort({required this.id, this.label, this.tooltip, this.color, this.maxConnections});
}

/// Riferimento a una porta: nodo + porta. Usato da `onFlowEdgeCreate` e
/// `canConnectPorts`.
@immutable
class CLGraphPortRef {
  final String nodeId;
  final String portId;
  const CLGraphPortRef(this.nodeId, this.portId);

  @override
  bool operator ==(Object other) => other is CLGraphPortRef && other.nodeId == nodeId && other.portId == portId;

  @override
  int get hashCode => Object.hash(nodeId, portId);

  @override
  String toString() => '$nodeId.$portId';
}

/// Stato di esecuzione di un nodo, passato dall'host (`CLNodeGraph.nodeStatuses`):
/// decora la card con bordo e icona.
enum CLGraphNodeStatus {
  /// Eseguito (bordo e icona `success`).
  done,

  /// In attesa: il discente è fermo qui (bordo e icona `warning`).
  waiting,

  /// Errore durante l'esecuzione (bordo e icona `danger`).
  error,

  /// Saltato: ramo non percorso (card attenuata, icona `mutedForeground`).
  skipped,
}

/// Etichette italiane di default degli stati (tooltip e lettore di schermo).
String clGraphNodeStatusLabel(CLGraphNodeStatus s) => switch (s) {
      CLGraphNodeStatus.done => 'Fatto',
      CLGraphNodeStatus.waiting => 'In attesa',
      CLGraphNodeStatus.error => 'Errore',
      CLGraphNodeStatus.skipped => 'Saltato',
    };
