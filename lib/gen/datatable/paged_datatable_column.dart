part of 'paged_datatable.dart';

abstract class BaseTableColumn<TType extends Object> {
  final String? id;
  final Widget title;
  final Widget Function(BuildContext context)? titleBuilder;
  final bool sortable;
  final bool isNumeric;
  final double? sizeFactor;
  final bool? isMain;

  /// Mobile: se true, questa colonna fa da sottotitolo nella card. Default false.
  final bool isSubtitle;

  const BaseTableColumn(
      {required this.id,
      required this.title,
      required this.titleBuilder,
      required this.sortable,
      required this.isNumeric,
      required this.sizeFactor,
      required this.isMain,
      this.isSubtitle = false});

  Widget buildCell(TType item, int rowIndex);
}

/// Defines a [BaseTableColumn] that allows the content of a cell to be modified, updating the underlying
/// item too.
abstract class EditableTableColumn<TType extends Object, TValue extends Object> extends BaseTableColumn<TType> {
  /// Function called when the value of the cell changes, and must update the underlying [TType], returning
  /// true if it could be updated, otherwise, false.
  final Setter<TType, TValue> setter;

  /// A function that returns the value that is going to be edited.
  final Getter<TType, TValue> getter;

  const EditableTableColumn(
      {required this.setter,
      required this.getter,
      required super.id,
      required super.title,
      required super.titleBuilder,
      required super.sortable,
      required super.isNumeric,
      required super.sizeFactor,
      required super.isMain,
      super.isSubtitle = false});
}

/// Defines a simple [BaseTableColumn] that renders a cell based on [cellBuilder]
class TableColumn<TType extends Object> extends BaseTableColumn<TType> {
  final Widget Function(TType) cellBuilder;

  const TableColumn({required super.title, required this.cellBuilder, super.sizeFactor = .1, super.isNumeric = false, super.sortable = false, super.id, super.isMain = false, super.isSubtitle = false})
      : assert(!sortable || id != null, "sortable columns must define an id"),
        super(titleBuilder: null);

  @override
  Widget buildCell(TType item, int rowIndex) => cellBuilder(item);
}
