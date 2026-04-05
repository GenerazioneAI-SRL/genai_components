part of 'paged_datatable.dart';

/// [_PagedDataTableState] represents the "current" state of the table.
class _PagedDataTableState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends ChangeNotifier {
  int _pageSize;
  SortBy? _sortModel;
  Object? _currentError;
  _TableState _state = _TableState.loading;
  List<TResult> itemList = [];
  bool isNewSearchSort = false;

  // A map that contains the state of the rows in the current resultset
  List<_PagedDataTableRowState<TResultId, TResult>> _rowsState = const [];

  /// Maps an item id with its index in the [_rowsState] list.
  Map<TResultId, int> _rowsStateMapper = const {};

  /// The list of items in the current resulset.
  List<TResult> _items = const [];

  /// The list of pagination keys used
  Map<int, TKey> _paginationKeys;

  /// The current page token
  int _currentPageIndex = 0;

  /// Indicates if there is another page after [_currentPageIndex]
  bool _hasNextPage = false;

  // the available width for the table
  double _availableWidth = 0;

  // the width applied to every column that has sizeFactor = null
  double _nullSizeFactorColumnsWidth = 0;

  // an int which changes when the sort column should update
  int _sortChange = 0;
  int _rowsChange = 0;
  int _rowsSelectionChange = 0;
  StreamSubscription? _refreshListenerSubscription;
  int totalElement = 0;
  final TKey initialPage;
  late TKey nextPageIndex;

  final Stream? refreshListener;
  final ScrollController filterChipsScrollController = ScrollController();
  final PagedDataTableController<TKey, TResultId, TResult> controller;
  final Future<dynamic> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) fetchCallback;
  List<BaseTableColumn<TResult>> columns;
  final Map<String, TableFilterState> filters;
  final Future Function({Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})? downloadCallback;
  final ModelIdGetter<TResultId, TResult> idGetter;
  final GlobalKey<FormState> filtersFormKey = GlobalKey();
  final GlobalKey filterButtonKey = GlobalKey();
  final GlobalKey extraMenuButtonKey = GlobalKey();
  final bool rowsSelectable;
  final bool showShimmerLoading;
  late final double columnsSizeFactor;
  late final int lengthColumnsWithoutSizeFactor;
  int lastPage = 1;

  /// Contains a list of selected rows. If the page changes, this remain untouched.
  final Map<TResultId, int> selectedRows = {};

  _TableState get tableState => _state;

  bool get hasSortModel => _sortModel != null;

  int get currentPage => _currentPageIndex < lastPage ? _currentPageIndex : _currentPageIndex - 1;

  Object? get currentError => _currentError;

  bool get hasPreviousPage => _currentPageIndex > 0;

  bool get hasNextPage => _hasNextPage;
  bool _initialized = false;
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  set availableWidth(double newWidth) {
    _availableWidth = newWidth;

    // subtract all the columns that has a specific sizeFactor
    _availableWidth = _availableWidth - (_availableWidth * columnsSizeFactor);
    _nullSizeFactorColumnsWidth = _availableWidth / lengthColumnsWithoutSizeFactor; // equally distributed
  }

  _PagedDataTableState({
    required this.fetchCallback,
    required this.initialPage,
    required this.downloadCallback,
    required this.columns,
    required this.idGetter,
    required this.rowsSelectable,
    required this.showShimmerLoading,
    required TextTableFilter? mainFilter,
    required List<TableFilter>? extraFilters,
    required PagedDataTableController<TKey, TResultId, TResult>? controller,
    required this.refreshListener,
    required int pageSize,
  })  : controller = controller ?? PagedDataTableController(),
        _pageSize = pageSize,
        _paginationKeys = {0: initialPage},
        filters = (mainFilter != null ? {mainFilter.id: TableFilterState._internal(mainFilter)} : {}) {
    // Aggiungi extraFilters a filters
    if (extraFilters != null) {
      for (var v in extraFilters) {
        filters[v.id] = TableFilterState._internal(v);
      }
    }
    _init();
  }

  Future downloadResult(SortBy? sortModel, Filtering filtering) async {
    Map<String, dynamic> searchParams = filtering.getAllFilters().map((key, value) {
      // Gestione speciale per DateTimeRange
      if (value.value is DateTimeRange) {
        final dateRange = value.value as DateTimeRange;
        String startIso = dateRange.start.toUtc().toIso8601String();
        String endIso = dateRange.end.toUtc().toIso8601String();

        // Assicuriamo che termini con Z
        if (!startIso.endsWith('Z')) startIso += 'Z';
        if (!endIso.endsWith('Z')) endIso += 'Z';

        return MapEntry(key, {'gte': startIso, 'lte': endIso});
      }
      return MapEntry(key, value.value);
    }).cast<String, dynamic>();

    searchParams.removeWhere((key, value) => value == null);
    Map<String, dynamic> sortMap = sortModel != null ? {"columnId": sortModel.columnId, "mode": sortModel.descending ? "DESC" : "ASC"} : {};
    if (this.downloadCallback != null) {
      await this.downloadCallback!(searchBy: searchParams, orderBy: sortMap);
    }
  }

  Future<void> _dispatchDownloadCallback() async {
    _state = _TableState.loading;
    notifyListeners();
    try {
      // fetch elements
      await downloadResult(_sortModel, Filtering._internal(filters));
      _state = _TableState.displaying;
      notifyListeners();
    } catch (err, stack) {
      notifyListeners();
    }
  }

  void setPageSize(int pageSize) {
    _pageSize = pageSize;
    notifyListeners();
    _resetPagination();
    isNewSearchSort = true;
    _dispatchCallback();
  }

  void setSortBy(String columnId, bool descending) {
    if (_sortModel?.columnId == columnId && _sortModel?.descending == descending) {
      return;
    }

    _sortModel = SortBy._internal(columnId: columnId, descending: descending);
    _sortChange++;
  }

  void swapSortBy(String columnId) {
    if (_sortModel != null && _sortModel!.columnId == columnId) {
      _sortModel!._descending = !_sortModel!.descending;
    } else {
      _sortModel = SortBy._internal(columnId: columnId, descending: true);
    }
    _sortChange++;
    notifyListeners();
    _resetPagination();
    isNewSearchSort = true;
    _dispatchCallback();
  }

  void applyFilters({String? columnId, bool? descending}) {
    bool sorted = false;
    if (columnId != null && descending != null) {
      setSortBy(columnId, descending);
      sorted = true;
    }
    if (filters.values.any((element) => element.hasValue) || sorted) {
      notifyListeners();
      _resetPagination();
      isNewSearchSort = true;
      _dispatchCallback();
    }
  }

  void applyFilter(String filterId, dynamic value) {
    var filter = filters[filterId];
    if (filter == null) {
      throw TableError("Filter $filterId not found.");
    }

    filter.value = value;
    notifyListeners();
    _resetPagination();
    isNewSearchSort = true;
    _dispatchCallback();
  }

  void removeSort() {
    _sortModel = null;
    notifyListeners();
    _resetPagination();
    isNewSearchSort = true;
    _dispatchCallback();
  }

  void resetFilterSort() {
    _sortModel = null;
    for (var filterState in filters.values) {
      if (filterState.hasValue) {
        filterState.value = null;
      }
    }
    notifyListeners();
    _resetPagination();
    isNewSearchSort = true;
    _dispatchCallback();
  }

  void removeFilters() {
    bool changed = false;
    for (var filterState in filters.values) {
      if (filterState.hasValue) {
        filterState.value = null;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
      _resetPagination();
      isNewSearchSort = true;
      _dispatchCallback();
    }
  }

  void removeFilter(String filterId) {
    filters[filterId]?.value = null;
    notifyListeners();
    _resetPagination();
    isNewSearchSort = true;
    _dispatchCallback();
  }

  void selectRow(TResultId itemId) {
    final itemIndex = _rowsStateMapper[itemId];
    if (itemIndex == null) {
      return;
    }
    selectedRows[itemId] = itemIndex;
    _rowsState[itemIndex].selected = true;
    _rowsSelectionChange = itemIndex;
    notifyListeners();
  }

  void unselectRow(TResultId itemId) {
    final itemIndex = _rowsStateMapper[itemId];
    if (itemIndex == null) {
      return;
    }

    selectedRows.remove(itemId);
    _rowsState[itemIndex].selected = false;
    _rowsSelectionChange = itemIndex;
    notifyListeners();
  }

  void selectAllRows() {
    for (var element in _rowsState) {
      if (!selectedRows.containsKey(element.itemId)) {
        selectedRows[element.itemId] = element.index;
      }
      element.selected = true;
    }
    _rowsSelectionChange = -1;
    notifyListeners();
  }

  void unselectAllRows() {
    for (var element in _rowsState) {
      selectedRows.remove(element.itemId);
      element.selected = false;
    }
    _rowsSelectionChange = -2;
    notifyListeners();
  }

  Future<void> nextPage({bool isInfiniteScroll = false}) => _dispatchCallback(page: _currentPageIndex + 1, isInfiniteScroll: isInfiniteScroll);

  Future<void> previousPage() => _dispatchCallback(page: _currentPageIndex - 1);

  Future<void> goFirstPage() => _dispatchCallback(page: 0);

  Future<void> goLastPage() => _dispatchCallback(page: lastPage);

  Future<void> goToPage(int page) => _dispatchCallback(page: page);

  @override
  void dispose() {
    _disposed = true;
    filterChipsScrollController.dispose();
    _refreshListenerSubscription?.cancel();
    // Dispose risorse dei filtri (controller, focusNode, debounce timer)
    for (final filterState in filters.values) {
      final filter = filterState._filter;
      if (filter is TextTableFilter) {
        filter._debounceTimer?.cancel();
        filter._debounceTimer = null;
        filter._controller?.dispose();
        filter._controller = null;
        filter._focusNode?.dispose();
        filter._focusNode = null;
      }
    }
    super.dispose();
  }

  Future<PaginationResult<TKey, TResult>> fetchResult(lookupKey, pageSize, SortBy? sortModel, Filtering filtering) async {
    Map<String, dynamic> searchParams = filtering.getAllFilters().map((key, value) {
      // Gestione speciale per DateTimeRange
      if (value.value is DateTimeRange) {
        final dateRange = value.value as DateTimeRange;
        String startIso = dateRange.start.toUtc().toIso8601String();
        String endIso = dateRange.end.toUtc().toIso8601String();

        // Assicuriamo che termini con Z
        if (!startIso.endsWith('Z')) startIso += 'Z';
        if (!endIso.endsWith('Z')) endIso += 'Z';

        return MapEntry(key, {'gte': startIso, 'lte': endIso});
      }

      // Gestione speciale per CLDropdownTableFilterAsync e CLDropdownTableFilterSync
      var filterValue = value.value;
      if (value._filter is CLDropdownTableFilterAsync) {
        final dropdownFilter = value._filter as CLDropdownTableFilterAsync;
        filterValue = dropdownFilter.getValueForBackend(value.value);
      } else if (value._filter is CLDropdownTableFilterSync) {
        final dropdownFilter = value._filter as CLDropdownTableFilterSync;
        filterValue = dropdownFilter.getValueForBackend(value.value);
      }

      return MapEntry(key, filterValue);
    }).cast<String, dynamic>();
    searchParams.removeWhere((key, value) => value == null);
    Map<String, dynamic> sortMap = sortModel != null ? {"columnId": sortModel.columnId, "mode": sortModel.descending ? "DESC" : "ASC"} : {};
    int currentPage = int.parse(lookupKey);
    var (elements, pagination) = await fetchCallback(page: currentPage, perPage: pageSize, searchBy: searchParams, orderBy: sortMap);
    itemList = elements;
    return PaginationResult.items(elements: itemList, paginationInfo: pagination);
  }

  /// Calls [fetchCallback].
  ///
  /// [page] indicates the index of the page in the [_paginationKeys] list.
  Future<void> _dispatchCallback({int page = 0, bool? isInfiniteScroll = false}) async {
    _state = _TableState.loading;
    _rowsChange++;
    _currentError = null;
    final random = Random();
    _rowsSelectionChange = 0 + random.nextInt(100 - 0 + 1);

    //selectedRows.clear();
    notifyListeners();

    TKey? lookupKey = _paginationKeys[page];
    lookupKey ??= (page).toString() as TKey?;
    try {
      // fetch elements
      var pageIndicator = await fetchResult(lookupKey, _pageSize, _sortModel, Filtering._internal(filters));

      // if has errors, throw it and let "catch" handle it
      if (pageIndicator.hasError) {
        throw pageIndicator.error;
      }

      if (pageIndicator.hasNextPageToken) {
        _paginationKeys[page + 1] = pageIndicator.nextPageToken!;
      }
      _hasNextPage = pageIndicator.hasNextPageToken;

      lastPage = int.tryParse(pageIndicator.lastPageToken.toString()) ?? 1;
      totalElement = pageIndicator.paginationInfo?.total ?? 0;
      _currentPageIndex = page;

      // change state and notify listeners of update
      _state = _TableState.displaying;
      _rowsChange++;
      _rowsState = [];
      _rowsStateMapper = {};

      if (!isInfiniteScroll!) {
        _items = pageIndicator.elements;
      } else {
        _items.addAll(pageIndicator.elements);
      }

      int index = 0;
      for (final item in _items) {
        final itemId = idGetter(item);
        bool isSelected = selectedRows.containsKey(itemId);
        _rowsState.add(_PagedDataTableRowState(index, item, itemId)..selected = isSelected);
        _rowsStateMapper[itemId] = index;
        index++;
      }
      notifyListeners();
    } catch (err, stack) {
      // store the error so the errorBuilder can display it
      _state = _TableState.error;
      _rowsChange++;
      _currentError = err;
      notifyListeners();
    }
  }

  /// Refreshes the datatable
  Future<void> _refresh({bool initial = false}) {
    if (initial) {
      _resetPagination();
    }
    return _dispatchCallback();
  }

  @pragma("vm:prefer-inline")
  void _init() {
    if (!_initialized) {
      controller._state = this;
      _initialized = false;
    }
    _initSizes();
    _setDefaultFilters();
    _dispatchCallback();

    if (refreshListener != null) {
      _refreshListenerSubscription = refreshListener!.listen((event) {
        _refresh();
      });
    }
  }

  @pragma("vm:prefer-inline")
  void _setDefaultFilters() {
    for (var filter in filters.values) {
      if (filter._filter.defaultValue != null) {
        filter.value = filter._filter.defaultValue;
      }
    }
  }

  @pragma("vm:prefer-inline")
  void _initSizes() {
    int withoutSizeFactor = rowsSelectable ? 1 : 0;
    double sizeFactorSum = 0;

    for (var column in columns) {
      if (column.sizeFactor == null) {
        withoutSizeFactor++;
      } else {
        sizeFactorSum += column.sizeFactor!;
      }
    }

    columnsSizeFactor = sizeFactorSum;
    lengthColumnsWithoutSizeFactor = withoutSizeFactor;
    assert(columnsSizeFactor <= 1, "the sum of all sizeFactor must be less than or equals to 1, given $columnsSizeFactor");
  }

  @pragma("vm:prefer-inline")
  void _resetPagination() {
    _paginationKeys = {0: initialPage};
    _currentPageIndex = 0;
  }
}

/// Represents the current state of the rows itself
enum _TableState {
  loading, // for loading elements
  error, // when the table broke due to an error
  displaying, // when showing elements
}

class TableFilterState<TValue> {
  final TableFilter<TValue> _filter;
  dynamic value;

  bool get hasValue => value != null;

  TableFilterState._internal(this._filter);
}
