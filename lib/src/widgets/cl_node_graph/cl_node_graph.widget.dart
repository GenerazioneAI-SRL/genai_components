import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/src/vendor/fl_nodes/fl_nodes.dart';
import 'cl_graph_models.dart';
import 'cl_graph_layout.dart';

/// Widget data-driven costruito sopra il motore vendored `fl_nodes`.
///
/// Il consumer passa `nodes`/`edges` e riceve callback; porte ed eventi del
/// motore restano nascosti. Gli archi sono SEMPRE ricreati dai dati: le azioni
/// utente (link/rimozione) sono notificate ai callback, che aggiornano i dati,
/// che a loro volta ricostruiscono il grafo canonico.
class CLNodeGraph extends StatefulWidget {
  final List<CLGraphNode> nodes;
  final List<CLGraphEdge> edges;
  final String? selectedNodeId;
  final void Function(String nodeId)? onNodeTap;
  final Future<bool> Function(String fromNodeId, String toNodeId)? onLinkCreate;
  final void Function(String edgeId)? onLinkDelete;
  final Future<bool> Function(String childNodeId, String newParentNodeId)? onReparent;
  final CLGraphLayout? layout;

  const CLNodeGraph({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNodeId,
    this.onNodeTap,
    this.onLinkCreate,
    this.onLinkDelete,
    this.onReparent,
    this.layout,
  });

  @override
  State<CLNodeGraph> createState() => _CLNodeGraphState();
}

class _CLNodeGraphState extends State<CLNodeGraph> {
  late final FlNodesController _controller;
  final Map<String, String> _flByCl = {};
  final Map<String, CLGraphNode> _clNodeById = {};
  final Map<String, String> _edgeByFlLink = {};

  /// Guard anti-feedback-loop. NON basta un flag booleano sincrono: l'`eventBus`
  /// è uno `StreamController.broadcast`, quindi consegna gli eventi in modo
  /// ASINCRONO (microtask), DOPO che `_rebuildGraph`/`_applySelection` sono già
  /// tornati e il flag sarebbe già stato riabbassato. Riconciliamo perciò per
  /// identità: teniamo gli id dei link creati/rimossi da noi e ignoriamo i
  /// relativi eventi; per la selezione usiamo il flag `isSideEffect` che
  /// impostiamo sulle selezioni programmatiche.
  final Set<String> _ownAddedLinkIds = {};
  final Set<String> _ownRemovedLinkIds = {};

  CLGraphLayout get _layout => widget.layout ?? clHierarchicalLayout;

  @override
  void initState() {
    super.initState();
    _controller = FlNodesController(
      appVersion: '1.0.0',
      config: const FlNodesConfig(
        enableSnapToGrid: false,
        autoBuildGraph: false,
        autoExecGraph: false,
      ),
    );
    _controller.registerNodePrototype(
      FlNodePrototype(
        idName: 'cl.node',
        displayName: (_) => 'Node',
        description: (_) => '',
        portPrototypes: [
          FlGenericPortPrototype(
            idName: 'parent',
            displayName: (_) => '',
            geometricOrientation: FlPortGeometricOrientation.left,
          ),
          FlGenericPortPrototype(
            idName: 'requires',
            displayName: (_) => '',
            geometricOrientation: FlPortGeometricOrientation.left,
          ),
          FlGenericPortPrototype(
            idName: 'children',
            displayName: (_) => '',
            geometricOrientation: FlPortGeometricOrientation.right,
          ),
          FlGenericPortPrototype(
            idName: 'unlocks',
            displayName: (_) => '',
            geometricOrientation: FlPortGeometricOrientation.right,
          ),
        ],
        onExecute: (ports, fields, state, forward, put) async {},
      ),
    );
    _controller.eventBus.events.listen(_onEngineEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildGraph());
  }

  @override
  void didUpdateWidget(covariant CLNodeGraph old) {
    super.didUpdateWidget(old);
    if (_graphChanged(old)) {
      _rebuildGraph();
    } else if (old.selectedNodeId != widget.selectedNodeId) {
      _applySelection();
    }
  }

  bool _graphChanged(CLNodeGraph old) {
    if (old.nodes.length != widget.nodes.length || old.edges.length != widget.edges.length) {
      return true;
    }
    for (var i = 0; i < widget.nodes.length; i++) {
      final a = old.nodes[i], b = widget.nodes[i];
      if (a.id != b.id || a.title != b.title || a.subtitle != b.subtitle || a.accent != b.accent) {
        return true;
      }
    }
    for (var i = 0; i < widget.edges.length; i++) {
      if (old.edges[i].id != widget.edges[i].id) return true;
    }
    return false;
  }

  void _rebuildGraph() {
    if (!mounted) return;
    // Gli id dei link che stiamo per distruggere con `project.clear()` erano
    // nostri: memorizziamoli così l'evento (async) di rimozione non venga letto
    // come una cancellazione utente.
    _ownRemovedLinkIds.addAll(_edgeByFlLink.keys);
    _controller.project.clear();
    _flByCl.clear();
    _clNodeById.clear();
    _edgeByFlLink.clear();

    final positions = _layout(widget.nodes, widget.edges);
    for (final n in widget.nodes) {
      _clNodeById[n.id] = n;
      final fl = _controller.addNode(
        'cl.node',
        offset: positions[n.id] ?? Offset.zero,
        customData: {'clId': n.id},
      );
      _flByCl[n.id] = fl.id;
    }
    for (final e in widget.edges) {
      final from = _flByCl[e.fromNodeId], to = _flByCl[e.toNodeId];
      if (from == null || to == null) continue;
      final link = e.kind == CLGraphEdgeKind.containment
          ? _controller.addLink(from, 'children', to, 'parent')
          : _controller.addLink(from, 'unlocks', to, 'requires');
      if (link != null) {
        _edgeByFlLink[link.id] = e.id;
        _ownAddedLinkIds.add(link.id); // link creato da noi: ignora il suo FlAddLinkEvent
      }
    }
    _applySelection();
    if (mounted) setState(() {});
  }

  void _applySelection() {
    final flId = widget.selectedNodeId == null ? null : _flByCl[widget.selectedNodeId];
    if (flId != null) {
      // isSideEffect: true marca l'evento di selezione come programmatico
      // (riconosciuto in _onEngineEvent per non chiamare onNodeTap).
      _controller.selectNodesById({flId}, isSideEffect: true);
    } else {
      _controller.clearSelection();
    }
  }

  Future<void> _onEngineEvent(dynamic event) async {
    if (event is FlNodeSelectionEvent &&
        event.type == FlSelectionEventType.select &&
        !event.isSideEffect &&
        event.nodeIds.isNotEmpty) {
      final fl = _controller.getNodeById(event.nodeIds.first);
      final clId = fl?.customData['clId'] as String?;
      if (clId != null) widget.onNodeTap?.call(clId);
      return;
    }

    if (event is FlAddLinkEvent) {
      final link = event.link;
      // Link creato da noi durante _rebuildGraph: non è un'azione utente.
      if (_ownAddedLinkIds.remove(link.id)) return;
      final fromPort = link.ports.$1.portId;
      final toPort = link.ports.$2.portId;
      final fromCl = _controller.getNodeById(link.ports.$1.nodeId)?.customData['clId'] as String?;
      final toCl = _controller.getNodeById(link.ports.$2.nodeId)?.customData['clId'] as String?;
      // Il link tracciato dall'utente è transitorio: i dati sono la fonte di verità.
      _ownRemovedLinkIds.add(link.id); // la rimozione qui sotto è nostra, non utente
      _controller.removeLinkById(link.id);
      if (fromCl == null || toCl == null) return;

      final cls = classifyGraphLink(fromPort, toPort);
      if (cls.role == CLGraphLinkRole.containment) {
        // sorgente = padre; l'altro = figlio
        final parent = cls.sourceIsFrom ? fromCl : toCl;
        final child = cls.sourceIsFrom ? toCl : fromCl;
        await widget.onReparent?.call(child, parent);
      } else if (cls.role == CLGraphLinkRole.link) {
        // sorgente = prerequisito; l'altro = dipendente
        final prereq = cls.sourceIsFrom ? fromCl : toCl;
        final dependent = cls.sourceIsFrom ? toCl : fromCl;
        await widget.onLinkCreate?.call(prereq, dependent);
      }
      return;
    }

    if (event is FlRemoveLinkEvent) {
      // Rimozione fatta da noi (clear del rebuild o cleanup del link transitorio):
      // non è un'azione utente.
      if (_ownRemovedLinkIds.remove(event.link.id)) return;
      final edgeId = _edgeByFlLink[event.link.id];
      if (edgeId != null) widget.onLinkDelete?.call(edgeId);
      return;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return FlNodesWidget(
      controller: _controller,
      expandToParent: true,
      nodeBuilder: (node, controller) => _clNode(context, node, theme),
      showPortContextMenu: (_, __, ___, ____) {},
      showCanvasContextMenu: (_, __, ___, ____) {},
      showNodeCreationMenu: (_, __, ___, ____, _____) {},
      showLinkContextMenu: (_, __, ___, ____) {},
    );
  }

  Widget _clNode(BuildContext context, FlNodeDataModel node, CLTheme theme) {
    final cl = _clNodeById[node.customData['clId']];
    final accent = cl?.accent ?? theme.primary;
    final selected = node.state.isSelected;
    return Container(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      padding: EdgeInsets.all(theme.gapMd),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.radiusCard),
        border: Border.all(color: selected ? accent : theme.cardBorder, width: selected ? 2 : 1),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              SizedBox(width: theme.gapIconText),
              if (cl?.icon != null) ...[
                Icon(cl!.icon, size: theme.iconSizeCompact, color: accent),
                SizedBox(width: theme.gapIconText),
              ],
              Flexible(
                child: Text(
                  cl?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyText,
                ),
              ),
            ],
          ),
          if (cl?.subtitle != null && cl!.subtitle!.isNotEmpty) ...[
            SizedBox(height: theme.gapXs),
            Text(
              cl.subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.smallText.copyWith(color: theme.mutedForeground),
            ),
          ],
        ],
      ),
    );
  }
}
