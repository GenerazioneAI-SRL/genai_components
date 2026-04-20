import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

class GenaiKanbanColumn<T> {
  final String id;
  final String title;
  final List<T> items;
  final Color? accent;
  final int? wipLimit;

  const GenaiKanbanColumn({
    required this.id,
    required this.title,
    required this.items,
    this.accent,
    this.wipLimit,
  });

  GenaiKanbanColumn<T> copyWith({List<T>? items}) => GenaiKanbanColumn(
        id: id,
        title: title,
        items: items ?? this.items,
        accent: accent,
        wipLimit: wipLimit,
      );
}

/// Kanban board (§6.7.7) — drag & drop rearrange across columns.
class GenaiKanban<T> extends StatefulWidget {
  final List<GenaiKanbanColumn<T>> columns;
  final Widget Function(BuildContext, T) cardBuilder;
  final void Function(T item, String fromColumnId, String toColumnId)? onReorder;
  final double columnWidth;

  const GenaiKanban({
    super.key,
    required this.columns,
    required this.cardBuilder,
    this.onReorder,
    this.columnWidth = 280,
  });

  @override
  State<GenaiKanban<T>> createState() => _GenaiKanbanState<T>();
}

class _GenaiKanbanState<T> extends State<GenaiKanban<T>> {
  String? _hoveringColumn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final col in widget.columns)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(width: widget.columnWidth, child: _buildColumn(col)),
            ),
        ],
      ),
    );
  }

  Widget _buildColumn(GenaiKanbanColumn<T> col) {
    final colors = context.colors;
    final ty = context.typography;
    final overWip = col.wipLimit != null && col.items.length > col.wipLimit!;

    return DragTarget<({T item, String fromColumnId})>(
      onWillAcceptWithDetails: (_) {
        setState(() => _hoveringColumn = col.id);
        return true;
      },
      onLeave: (_) => setState(() => _hoveringColumn = null),
      onAcceptWithDetails: (details) {
        setState(() => _hoveringColumn = null);
        if (details.data.fromColumnId != col.id) {
          widget.onReorder?.call(details.data.item, details.data.fromColumnId, col.id);
        }
      },
      builder: (ctx, candidate, rejected) {
        return Container(
          decoration: BoxDecoration(
            color: _hoveringColumn == col.id ? colors.colorPrimarySubtle : colors.surfaceHover,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hoveringColumn == col.id ? colors.colorPrimary : colors.borderDefault,
              width: _hoveringColumn == col.id ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (col.accent != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: col.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(col.title, style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                  ),
                  GenaiBadge.count(
                    count: col.items.length,
                    variant: overWip ? GenaiBadgeVariant.filled : GenaiBadgeVariant.subtle,
                    color: overWip ? colors.colorWarning : null,
                  ),
                ],
              ),
              if (col.wipLimit != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Limite WIP: ${col.wipLimit}', style: ty.caption.copyWith(color: overWip ? colors.colorWarning : colors.textSecondary)),
                ),
              const SizedBox(height: 8),
              for (final item in col.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LongPressDraggable<({T item, String fromColumnId})>(
                    data: (item: item, fromColumnId: col.id),
                    feedback: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.85,
                        child: SizedBox(
                          width: widget.columnWidth - 16,
                          child: widget.cardBuilder(context, item),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: widget.cardBuilder(context, item),
                    ),
                    child: widget.cardBuilder(context, item),
                  ),
                ),
              if (col.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.inbox, size: 16, color: colors.textSecondary),
                        const SizedBox(width: 6),
                        Text('Vuoto', style: ty.caption.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
