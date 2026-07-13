part of 'paged_datatable.dart';

/// Contains a set of elements and optionally a next page token
class PaginationResult<TPaginationKey extends Object, TResult extends Object> {
  final Pagination? paginationInfo;
  final List<TResult>? _elements;
  final Object? _error;
  final int? _length;

  bool get hasError => _error != null;

  bool get hasNextPageToken => paginationInfo?.next != null;

  bool get hasElements => _elements != null;

  int get length => _length ?? _elements!.length;

  Object get error => _error!;

  List<TResult> get elements => _elements!;

  TPaginationKey? get nextPageToken => paginationInfo?.next.toString() as TPaginationKey;

  Object get lastPageToken => paginationInfo?.lastPage??"" as TPaginationKey;

  PaginationResult.items({required List<TResult> elements, required this.paginationInfo})
      : _elements = List.from(elements),
        _length = elements.length,
        _error = null;

  PaginationResult.error({required Object? error})
      : paginationInfo = null,
        _elements = null,
        _length = null,
        _error = error;
}
