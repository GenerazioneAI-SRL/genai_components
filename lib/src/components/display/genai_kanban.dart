import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single column in a [GenaiKanban].
class GenaiKanbanColumn<T> {
  /// Unique column id — returned to `onReorder`.
  final String id;

  /// Column title rendered in the header.
  final String title;

  /// Cards in order.
  final List<T> items;

  /// Optional accent dot color next to the title.
  final Color? accent;

  /// Optional WIP limit — when exceeded, the count badge turns warning.
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

/// Kanban board — v3 design system.
///
/// Horizontally scrollable list of columns with drag-and-drop reordering
/// across columns. The consumer owns the data model and reacts to
/// `onReorder` callbacks to mutate it.
class GenaiKanban<T> extends StatefulWidget {
  /// Columns rendered left-to-right.
  final List<GenaiKanbanColumn<T>> columns;

  /// Builder for an individual card.
  final Widget Function(BuildContext, T) cardBuilder;

  /// Fires when an item is dropped onto a different column.
  final void Function(T item, String fromColumnId, String toColumnId)?
      onReorder;

  /// Column width. Defaults to 280.
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
    final spacing = context.spacing;
    return Semantics(
      container: true,
      label: 'Kanban board',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final col in widget.columns)
              Padding(
                padding: EdgeInsets.only(right: spacing.s12),
                child: SizedBox(
                  width: widget.columnWidth,
                  child: _buildColumn(col),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(GenaiKanbanColumn<T> col) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
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
          widget.onReorder?.call(
            details.data.item,
            details.data.fromColumnId,
            col.id,
          );
        }
      },
      builder: (ctx, candidate, rejected) {
        return Semantics(
          container: true,
          label: '${col.title} - ${col.items.length} elementi',
          child: Container(
            decoration: BoxDecoration(
              color: _hoveringColumn == col.id
                  ? colors.colorInfoSubtle
                  : colors.surfaceHover,
              borderRadius: BorderRadius.circular(radius.xl),
              border: Border.all(
                color: _hoveringColumn == col.id
                    ? colors.colorInfo
                    : colors.borderDefault,
                width: _hoveringColumn == col.id
                    ? sizing.focusRingWidth
                    : sizing.dividerThickness,
              ),
            ),
            padding: EdgeInsets.all(spacing.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (col.accent != null) ...[
                      Container(
                        width: spacing.s8,
                        height: spacing.s8,
                        decoration: BoxDecoration(
                          color: col.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: spacing.s8),
                    ],
                    Expanded(
                      child: Text(
                        col.title,
                        style: ty.cardTitle.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    _CountBadge(
                      count: col.items.length,
                      danger: overWip,
                    ),
                  ],
                ),
                if (col.wipLimit != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s4),
                    child: Text(
                      'Limite WIP: ${col.wipLimit}',
                      style: ty.labelSm.copyWith(
                        color: overWip
                            ? colors.colorWarningText
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                SizedBox(height: spacing.s8),
                for (final item in col.items)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.s8),
                    child: LongPressDraggable<({T item, String fromColumnId})>(
                      data: (item: item, fromColumnId: col.id),
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.85,
                          child: SizedBox(
                            width: widget.columnWidth - spacing.s16,
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
                    padding: EdgeInsets.all(spacing.s16),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.inbox,
                            size: sizing.iconSize,
                            color: colors.textSecondary,
                          ),
                          SizedBox(width: spacing.s6),
                          Text(
                            'Vuoto',
                            style: ty.labelSm
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool danger;
  const _CountBadge({required this.count, required this.danger});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final bg = danger ? colors.colorWarningSubtle : colors.surfaceCard;
    final fg = danger ? colors.colorWarningText : colors.textPrimary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s6,
        vertical: spacing.s2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.pill),
        border: Border.all(
          color: danger ? colors.colorWarning : colors.borderDefault,
        ),
      ),
      child: Text(
        '$count',
        style: ty.monoSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
