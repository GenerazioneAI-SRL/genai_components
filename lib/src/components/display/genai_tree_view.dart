import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

class GenaiTreeNode<T> {
  final T value;
  final String label;
  final IconData? icon;
  final List<GenaiTreeNode<T>> children;
  final bool initiallyExpanded;

  const GenaiTreeNode({
    required this.value,
    required this.label,
    this.icon,
    this.children = const [],
    this.initiallyExpanded = false,
  });
}

/// Hierarchical tree view (§6.7.8 extended).
class GenaiTreeView<T> extends StatefulWidget {
  final List<GenaiTreeNode<T>> nodes;
  final ValueChanged<T>? onNodeTap;
  final T? selectedValue;
  final double indent;

  const GenaiTreeView({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.selectedValue,
    this.indent = 20,
  });

  @override
  State<GenaiTreeView<T>> createState() => _GenaiTreeViewState<T>();
}

class _GenaiTreeViewState<T> extends State<GenaiTreeView<T>> {
  late Set<T> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {};
    void walk(List<GenaiTreeNode<T>> ns) {
      for (final n in ns) {
        if (n.initiallyExpanded) _expanded.add(n.value);
        walk(n.children);
      }
    }

    walk(widget.nodes);
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final n in widget.nodes) {
      _walk(n, 0, rows);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  void _walk(GenaiTreeNode<T> node, int depth, List<Widget> out) {
    final hasChildren = node.children.isNotEmpty;
    final expanded = _expanded.contains(node.value);
    out.add(_TreeRow<T>(
      node: node,
      depth: depth,
      indent: widget.indent,
      isExpanded: expanded,
      hasChildren: hasChildren,
      isSelected: widget.selectedValue == node.value,
      onToggle: hasChildren
          ? () {
              setState(() {
                if (expanded) {
                  _expanded.remove(node.value);
                } else {
                  _expanded.add(node.value);
                }
              });
            }
          : null,
      onTap: () => widget.onNodeTap?.call(node.value),
    ));
    if (expanded) {
      for (final c in node.children) {
        _walk(c, depth + 1, out);
      }
    }
  }
}

class _TreeRow<T> extends StatefulWidget {
  final GenaiTreeNode<T> node;
  final int depth;
  final double indent;
  final bool isExpanded;
  final bool hasChildren;
  final bool isSelected;
  final VoidCallback? onToggle;
  final VoidCallback onTap;

  const _TreeRow({
    required this.node,
    required this.depth,
    required this.indent,
    required this.isExpanded,
    required this.hasChildren,
    required this.isSelected,
    required this.onToggle,
    required this.onTap,
  });

  @override
  State<_TreeRow<T>> createState() => _TreeRowState<T>();
}

class _TreeRowState<T> extends State<_TreeRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: GenaiDurations.hover,
          padding: EdgeInsets.only(left: 8 + widget.depth * widget.indent, right: 8, top: 6, bottom: 6),
          color: widget.isSelected ? colors.colorPrimarySubtle : (_hovered ? colors.surfaceHover : Colors.transparent),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: widget.hasChildren
                    ? GestureDetector(
                        onTap: widget.onToggle,
                        child: AnimatedRotation(
                          turns: widget.isExpanded ? 0.25 : 0,
                          duration: GenaiDurations.accordionOpen,
                          child: Icon(LucideIcons.chevronRight, size: 16, color: colors.textSecondary),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (widget.node.icon != null) ...[
                const SizedBox(width: 4),
                Icon(widget.node.icon, size: 16, color: colors.textSecondary),
              ],
              const SizedBox(width: 6),
              Expanded(
                child: Text(widget.node.label,
                    style: ty.bodySm.copyWith(
                      color: colors.textPrimary,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
