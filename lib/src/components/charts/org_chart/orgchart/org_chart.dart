import 'package:flutter/material.dart';
import '../common/custom_animated_positioned.dart';
import '../common/node.dart';
import '../common/node_builder_details.dart';
import 'org_chart_controller.dart';
import '../base/base_graph.dart';
import 'edge_painter.dart';

/// A widget that displays an organizational chart
class GenaiOrgChart<E> extends GenaiBaseGraph<E> {
  final void Function(E dragged, E target, bool isTargetSubnode)? onDrop;

  /// The size of each node box (width, height). If null and autoSize is false, uses controller default.
  final Size? boxSize;

  /// Horizontal spacing between nodes
  final double? spacing;

  /// Vertical spacing between levels
  final double? runSpacing;

  /// If true, nodes will auto-size based on their content.
  /// When enabled, boxSize is used as minimum/reference size for layout calculations.
  final bool autoSize;

  GenaiOrgChart({
    super.key,
    required GenaiOrgChartController<E> super.controller,
    required super.builder,
    super.isDraggable,
    super.curve,
    super.duration,
    super.linePaint,
    super.cornerRadius,
    super.arrowStyle,
    super.lineEndingType,
    super.optionsBuilder,
    super.onOptionSelect,
    super.viewerController,
    super.interactionConfig,
    super.keyboardConfig,
    super.zoomConfig,
    super.focusNode,
    this.onDrop,
    this.boxSize,
    this.spacing,
    this.runSpacing,
    this.autoSize = false,
  });

  @override
  OrgChartState<E> createState() => OrgChartState<E>();
}

class OrgChartState<E> extends BaseGraphState<E, GenaiOrgChart<E>> {
  late OrgChartEdgePainter<E> _edgePainter;

  @override
  void initState() {
    super.initState();

    // Apply widget parameters to controller if provided
    if (widget.boxSize != null) {
      controller.boxSize = widget.boxSize!;
    }
    if (widget.spacing != null) {
      controller.spacing = widget.spacing!;
    }
    if (widget.runSpacing != null) {
      controller.runSpacing = widget.runSpacing!;
    }

    // NON chiamare calculatePosition qui - il viewport non ha ancora dimensioni
    // Il controller calcola già le posizioni quando viene creato

    _edgePainter = OrgChartEdgePainter<E>(
      controller: controller,
      linePaint: widget.linePaint,
      arrowStyle: widget.arrowStyle,
      cornerRadius: widget.cornerRadius,
      lineEndingType: widget.lineEndingType,
    );
  }

  @override
  List<Widget> buildGraphElements(BuildContext context) {
    return [
      buildEdges(),
      ...buildNodes(context)..sort((a, b) => a.isBeingDragged ? 1 : -1),
    ];
  }

  void finishDragging(Node<E> node) {
    // Do a final overlap check
    overlapping = widget.controller.getOverlapping(node);

    if (overlapping.isNotEmpty) {
      widget.onDrop?.call(node.data, overlapping.first.data,
          controller.isSubNode(node, overlapping.first));
    }
    draggedID = null;
    overlapping = [];
    lastDraggedNode = null;
    setState(() {});
  }

  @override
  Widget buildEdges() {
    return CustomPaint(
      painter: _edgePainter,
      child: SizedBox.shrink(),
    );
  }

  @override
  List<CustomAnimatedPositioned> buildNodes(BuildContext context,
      {List<Node<E>>? nodesToDraw, bool hidden = false, int level = 1}) {
    final nodes = nodesToDraw ?? controller.roots;
    final List<CustomAnimatedPositioned> nodeWidgets = [];

    for (Node<E> node in nodes) {
      final String nodeId = controller.idProvider(node.data);

      // Build the node content widget
      final nodeContent = widget.builder(
        NodeBuilderDetails(
          item: node.data,
          level: level,
          hideNodes: ({hide, center = true}) =>
              toggleHideNodes(node, hide, center),
          nodesHidden: node.hideNodes,
          isBeingDragged: nodeId == draggedID,
          isOverlapped: overlappingNodes.isNotEmpty &&
              overlappingNodes.first.data == node.data,
        ),
      );

      nodeWidgets.add(
        CustomAnimatedPositioned(
          key: ValueKey(nodeId),
          isBeingDragged: nodeId == draggedID,
          duration: nodeId == draggedID ? Duration.zero : widget.duration,
          curve: widget.curve,
          left: node.position.dx,
          top: node.position.dy,
          // When autoSize is true, don't constrain width/height
          width: widget.autoSize ? null : controller.boxSize.width,
          height: widget.autoSize ? null : controller.boxSize.height,
          child: RepaintBoundary(
            child: Visibility(
              visible: !hidden,
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: GestureDetector(
                onTapDown: handleTapDown,
                // TODO Implement onSecondaryTap
                onSecondaryTap: () => showNodeMenu(context, node),
                onLongPress: () => showNodeMenu(context, node),
                onPanStart:
                    widget.isDraggable ? (_) => startDragging(node) : null,
                onPanUpdate: widget.isDraggable
                    ? (details) => updateDragging(node, details)
                    : null,
                onPanEnd:
                    widget.isDraggable ? (_) => finishDragging(node) : null,
                child: nodeContent,
              ),
            ),
          ),
        ),
      );

      if (!node.hideNodes) {
        final subNodes = controller.getSubNodes(node);
        nodeWidgets.addAll(
          buildNodes(
            context,
            nodesToDraw: subNodes,
            level: level + 1,
          ),
        );
      }
    }

    return nodeWidgets;
  }

  @override
  GenaiOrgChartController<E> get controller =>
      widget.controller as GenaiOrgChartController<E>;
}
