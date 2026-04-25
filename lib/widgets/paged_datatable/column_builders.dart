import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'paged_datatable.dart';

/// Lightweight action descriptor consumed by [TableColumnBuilder.actionColumn].
///
/// Wraps an icon, optional tooltip and tap handler that receives the row item.
class TableRowAction<T> {
  /// Icon rendered inside the [IconButton].
  final IconData icon;

  /// Optional tooltip displayed on hover/long-press.
  final String? tooltip;

  /// Callback invoked with the row item when the action is tapped.
  final void Function(T) onPressed;

  const TableRowAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
}

/// Convenience builders for the most common [TableColumn] shapes used inside
/// [PagedDataTable]. Reduces boilerplate when declaring column lists.
extension TableColumnBuilder on BuildContext {
  /// Build a simple text column.
  ///
  /// [title] is the header label, [value] extracts the string to render from
  /// the row item. [sizeFactor] follows the same semantics as the underlying
  /// [TableColumn.sizeFactor] (fraction of the available width).
  TableColumn<T> textColumn<T extends Object>({
    required String title,
    required String Function(T) value,
    double sizeFactor = .1,
    bool sortable = false,
    String? id,
    bool isMain = false,
  }) {
    return TableColumn<T>(
      id: id,
      title: Text(title),
      cellBuilder: (item) => Text(value(item)),
      sizeFactor: sizeFactor,
      sortable: sortable,
      isMain: isMain,
    );
  }

  /// Color-coded status badge column.
  ///
  /// Renders a rounded chip whose background is a translucent variant of
  /// [color] and whose foreground reuses the same [color] for the [label].
  TableColumn<T> statusColumn<T extends Object>({
    required String title,
    required String Function(T) label,
    required Color Function(T) color,
    double sizeFactor = .1,
    String? id,
    bool isMain = false,
  }) {
    return TableColumn<T>(
      id: id,
      title: Text(title),
      cellBuilder: (item) {
        final c = color(item);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label(item),
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        );
      },
      sizeFactor: sizeFactor,
      isMain: isMain,
    );
  }

  /// Date column rendered with [DateFormat] using [pattern].
  ///
  /// When [value] returns `null` the cell shows an em-dash placeholder.
  TableColumn<T> dateColumn<T extends Object>({
    required String title,
    required DateTime? Function(T) value,
    String pattern = 'dd/MM/yyyy',
    double sizeFactor = .1,
    bool sortable = false,
    String? id,
    bool isMain = false,
  }) {
    final formatter = DateFormat(pattern);
    return TableColumn<T>(
      id: id,
      title: Text(title),
      cellBuilder: (item) {
        final d = value(item);
        return Text(d == null ? '—' : formatter.format(d));
      },
      sizeFactor: sizeFactor,
      sortable: sortable,
      isMain: isMain,
    );
  }

  /// Action column rendering a horizontal row of [IconButton]s.
  ///
  /// Use [TableRowAction] entries to declare icon, tooltip and tap callback
  /// per action. Suited for edit/delete/inspect inline operations.
  TableColumn<T> actionColumn<T extends Object>({
    required String title,
    required List<TableRowAction<T>> actions,
    double sizeFactor = .1,
    String? id,
  }) {
    return TableColumn<T>(
      id: id,
      title: Text(title),
      cellBuilder: (item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map((a) => IconButton(
                  icon: Icon(a.icon, size: 18),
                  tooltip: a.tooltip,
                  onPressed: () => a.onPressed(item),
                ))
            .toList(),
      ),
      sizeFactor: sizeFactor,
    );
  }
}
