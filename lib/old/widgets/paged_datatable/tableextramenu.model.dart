part of 'paged_datatable.dart';

class TableExtraMenu<T extends Object> {
  final Widget content;
  final void Function() onTap;

  TableExtraMenu({
    required this.content,
    required this.onTap,
  }) ;
}