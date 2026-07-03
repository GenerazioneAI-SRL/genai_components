import 'package:flutter/widgets.dart';

/// Nodo del grafo, indipendente dal motore di rendering.
class CLGraphNode {
  final String id;
  final String type; // libero: 'module' | 'course' | 'lesson' | 'exam' | 'resource' | ...
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accent;
  final Object? data; // payload opaco per il consumer

  const CLGraphNode({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent,
    this.data,
  });
}

/// Tipo di arco: contenimento (gerarchia), propedeuticità o ordine.
enum CLGraphEdgeKind { containment, prerequisite, order }

class CLGraphEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final CLGraphEdgeKind kind;

  const CLGraphEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.kind,
  });
}

/// Strategia di posizionamento: da nodi+archi a coordinate.
typedef CLGraphLayout = Map<String, Offset> Function(
  List<CLGraphNode> nodes,
  List<CLGraphEdge> edges,
);
