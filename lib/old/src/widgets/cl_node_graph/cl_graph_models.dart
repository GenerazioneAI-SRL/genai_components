import 'package:flutter/widgets.dart';

/// Azione/indicatore su una card del grafo, resa come slot in alto a destra.
/// Di norma un'icona tappabile (es. frecce ordine ▲▼); con [label] mostra invece
/// un testo (es. numero d'ordine corrente) e con [interactive] `false` diventa
/// puro display (nessun hotspot, non tappabile).
class CLGraphNodeAction {
  final String id;
  final IconData? icon; // usato quando [label] è null
  final String? label; // testo al posto dell'icona (es. posizione corrente)
  final String? tooltip;
  final bool interactive; // false ⇒ solo visuale, nessun hit-test (non tappabile)
  const CLGraphNodeAction({
    required this.id,
    this.icon,
    this.label,
    this.tooltip,
    this.interactive = true,
  }) : assert(icon != null || label != null, 'CLGraphNodeAction richiede icon o label');
}

/// Nodo del grafo, indipendente dal motore di rendering.
class CLGraphNode {
  final String id;
  final String type; // libero: 'module' | 'course' | 'lesson' | 'exam' | 'resource' | ...
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accent;
  final String? badge; // pill in alto (es. nome modulo)
  final Color? badgeColor; // colore della pill (default: accent)
  final Object? data; // payload opaco per il consumer
  /// Azioni immediate: icone tappabili in alto a destra della card (es. frecce
  /// ordine ▲▼). Vuoto ⇒ nessuna icona. L'host cabla il comportamento via
  /// `CLNodeGraph.onNodeAction`.
  final List<CLGraphNodeAction> actions;

  const CLGraphNode({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent,
    this.badge,
    this.badgeColor,
    this.data,
    this.actions = const [],
  });
}

/// Offset verticale (sotto il centro del bordo destro) della porta triangolino
/// "link-lezione". Condiviso tra il widget (che disegna il triangolino) e il
/// painter (che ancora gli archi [CLGraphEdgeKind.lessonLink] a quel punto), così
/// la porta e l'arco restano allineati da un'unica sorgente di verità.
const double kTriDy = 26;

/// Tipo di arco: contenimento (gerarchia), propedeuticità, ordine, o link-lezione.
/// [lessonLink] parte dalla porta triangolino (non dal pallino prereq): il pallino
/// resta riservato alla propedeuticità.
enum CLGraphEdgeKind { containment, prerequisite, order, lessonLink }

class CLGraphEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final CLGraphEdgeKind kind;
  /// Arco strutturale (conta per il layout) ma NON disegnato. Utile per il
  /// containment verso risorse già collegate visivamente da una freccia prereq.
  final bool hidden;

  const CLGraphEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.kind,
    this.hidden = false,
  });
}

/// Strategia di posizionamento: da nodi+archi a coordinate.
typedef CLGraphLayout = Map<String, Offset> Function(
  List<CLGraphNode> nodes,
  List<CLGraphEdge> edges,
);
