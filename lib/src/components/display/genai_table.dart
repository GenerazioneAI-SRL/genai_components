import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

// ───────── Models ─────────

/// Sort order applied to a column.
enum GenaiSortDirection {
  /// Ascending (A→Z, 0→9).
  asc,

  /// Descending (Z→A, 9→0).
  desc,
}

/// Row height preset for a [GenaiTable].
enum GenaiTableDensity {
  /// Tight rows — maximum information density.
  compact,

  /// Default row height.
  normal,

  /// Roomy rows — more breathing space.
  comfortable,
}

/// Horizontal alignment of a column's cells.
enum GenaiColumnAlignment {
  /// Left / start alignment (default for text).
  start,

  /// Center alignment.
  center,

  /// Right / end alignment (default for numeric columns).
  end,
}

/// Active sort state — column id + direction.
class GenaiSortState {
  /// Id of the sorted column (matches [GenaiColumn.id]).
  final String columnId;

  /// Sort order.
  final GenaiSortDirection direction;

  const GenaiSortState({required this.columnId, required this.direction});

  /// Returns a new state with [direction] flipped.
  GenaiSortState toggled() => GenaiSortState(
        columnId: columnId,
        direction: direction == GenaiSortDirection.asc
            ? GenaiSortDirection.desc
            : GenaiSortDirection.asc,
      );
}

/// Async page request for [GenaiTableFetcher].
class GenaiPageRequest {
  /// Opaque cursor. Null on first page.
  final Object? pageKey;

  /// Rows per page.
  final int pageSize;

  /// Active sort.
  final GenaiSortState? sort;

  /// Active filters (filter id → value).
  final Map<String, Object?> filters;

  /// Current search string.
  final String search;

  const GenaiPageRequest({
    this.pageKey,
    required this.pageSize,
    this.sort,
    this.filters = const {},
    this.search = '',
  });
}

/// Response from [GenaiTableFetcher].
class GenaiPageResponse<T> {
  /// Rows returned for the requested page.
  final List<T> items;

  /// Opaque cursor for the next page. `null` terminates pagination.
  final Object? nextPageKey;

  /// Total rows when known — enables paginator "x of y" hints.
  final int? totalItems;

  const GenaiPageResponse({
    required this.items,
    this.nextPageKey,
    this.totalItems,
  });
}

/// Signature of the async loader driving a [GenaiTable].
typedef GenaiTableFetcher<T> = Future<GenaiPageResponse<T>> Function(
    GenaiPageRequest request);

/// Describes a column inside a [GenaiTable].
class GenaiColumn<T> {
  /// Stable id (used for sort / visibility state).
  final String id;

  /// Header label.
  final String title;

  /// Builds the cell for a row.
  final Widget Function(BuildContext, T) cellBuilder;

  /// Optional fixed width in logical px.
  final double? width;

  /// Optional minimum width.
  final double? minWidth;

  /// Whether the header shows a sort affordance and triggers
  /// `controller.setSort`.
  final bool sortable;

  /// Cell alignment.
  final GenaiColumnAlignment align;

  /// Whether visible on first render. Users can toggle at runtime.
  final bool initiallyVisible;

  /// Whether the column is pinned (currently advisory — renderer does not
  /// yet split pinned / unpinned scroll regions).
  final bool pinned;

  const GenaiColumn({
    required this.id,
    required this.title,
    required this.cellBuilder,
    this.width,
    this.minWidth,
    this.sortable = false,
    this.align = GenaiColumnAlignment.start,
    this.initiallyVisible = true,
    this.pinned = false,
  });
}

/// Base interface for a filter applied to a [GenaiTable].
abstract class GenaiTableFilter {
  /// Stable id — matches the key in `GenaiPageRequest.filters`.
  String get id;

  /// Human-readable label.
  String get label;

  /// Builds the editor widget for this filter.
  Widget buildEditor(
    BuildContext context,
    Object? value,
    ValueChanged<Object?> onChanged,
  );

  /// Formats the active value for display (e.g. as a chip).
  String formatValue(Object? value);
}

/// Free-text filter backed by a plain Material [TextField].
class GenaiTextFilter implements GenaiTableFilter {
  @override
  final String id;

  @override
  final String label;

  /// Optional placeholder.
  final String? hint;

  const GenaiTextFilter({required this.id, required this.label, this.hint});

  @override
  Widget buildEditor(
    BuildContext context,
    Object? value,
    ValueChanged<Object?> onChanged,
  ) {
    return _FallbackTextFilter(
      label: label,
      hint: hint,
      initial: value as String?,
      onChanged: (v) => onChanged(v.isEmpty ? null : v),
    );
  }

  @override
  String formatValue(Object? value) => value == null ? '' : '$label: "$value"';
}

/// Single-select options filter.
class GenaiOptionsFilter<V> implements GenaiTableFilter {
  @override
  final String id;

  @override
  final String label;

  /// Available options shown in a dropdown.
  final List<({String label, V value})> options;

  const GenaiOptionsFilter({
    required this.id,
    required this.label,
    required this.options,
  });

  @override
  Widget buildEditor(
    BuildContext context,
    Object? value,
    ValueChanged<Object?> onChanged,
  ) {
    return _FallbackOptionsFilter<V>(
      label: label,
      options: options,
      value: value as V?,
      onChanged: onChanged,
    );
  }

  @override
  String formatValue(Object? value) {
    if (value == null) return '';
    final opt = options.where((o) => o.value == value).firstOrNull;
    return '$label: ${opt?.label ?? value}';
  }
}

/// Table-scoped toolbar action.
///
/// Generic [T] is carried for API symmetry with [GenaiBulkAction]; the
/// value type is not used by this class directly.
class GenaiTableAction<T> {
  /// Button label.
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Tap callback.
  final VoidCallback onPressed;

  /// Whether the button uses the primary visual.
  final bool isPrimary;

  const GenaiTableAction({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });
}

/// Action that operates on the current selection (e.g. "Delete selected").
class GenaiBulkAction<T> {
  /// Button label.
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Fires with the current selection.
  final void Function(Set<T> selected) onPressed;

  /// Whether the button uses the destructive visual.
  final bool isDestructive;

  const GenaiBulkAction({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
}

// ───────── Controller ─────────

/// Controls a [GenaiTable]: triggers refresh and exposes pagination state.
class GenaiTableController<T> extends ChangeNotifier {
  final List<T> _items = [];
  Object? _nextPageKey;
  int? _totalItems;
  int _currentPage = 0;
  int _pageSize = 25;
  GenaiSortState? _sort;
  final Map<String, Object?> _filters = {};
  String _search = '';

  bool _loading = false;
  Object? _error;

  /// Items currently loaded (across all fetched pages).
  List<T> get items => List.unmodifiable(_items);

  /// Whether a fetch is in-flight.
  bool get loading => _loading;

  /// Last error, if any.
  Object? get error => _error;

  /// 0-based page index of the most recently loaded page.
  int get currentPage => _currentPage;

  /// Active page size.
  int get pageSize => _pageSize;

  /// Total rows in the dataset when reported by the fetcher.
  int? get totalItems => _totalItems;

  /// Whether more pages remain.
  bool get hasNext => _nextPageKey != null;

  /// Current sort.
  GenaiSortState? get sort => _sort;

  /// Active filters.
  Map<String, Object?> get filters => Map.unmodifiable(_filters);

  /// Current search value.
  String get search => _search;

  GenaiTableFetcher<T>? _fetcher;

  /// Binds the controller to a fetcher and kicks off the first fetch.
  void attach(GenaiTableFetcher<T> fetcher, int initialPageSize) {
    _fetcher = fetcher;
    _pageSize = initialPageSize;
    refresh();
  }

  /// Resets paging and refetches from the beginning.
  Future<void> refresh() async {
    if (_fetcher == null) return;
    _items.clear();
    _nextPageKey = null;
    _currentPage = 0;
    _totalItems = null;
    await _loadPage(reset: true);
  }

  /// Loads the next page and appends its rows to [items].
  Future<void> nextPage() async {
    if (!hasNext || _loading) return;
    await _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_fetcher == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _fetcher!(GenaiPageRequest(
        pageKey: reset ? null : _nextPageKey,
        pageSize: _pageSize,
        sort: _sort,
        filters: _filters,
        search: _search,
      ));
      if (reset) {
        _items
          ..clear()
          ..addAll(res.items);
        _currentPage = 0;
      } else {
        _items.addAll(res.items);
        _currentPage++;
      }
      _nextPageKey = res.nextPageKey;
      _totalItems = res.totalItems;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Updates sort and refetches.
  void setSort(GenaiSortState? sort) {
    _sort = sort;
    refresh();
  }

  /// Sets (or clears on null) a single filter and refetches.
  void setFilter(String id, Object? value) {
    if (value == null) {
      _filters.remove(id);
    } else {
      _filters[id] = value;
    }
    refresh();
  }

  /// Clears all filters and search, then refetches.
  void clearFilters() {
    _filters.clear();
    _search = '';
    refresh();
  }

  /// Updates the search string and refetches.
  void setSearch(String value) {
    _search = value;
    refresh();
  }

  /// Updates page size and refetches.
  void setPageSize(int size) {
    _pageSize = size;
    refresh();
  }
}

// ───────── Widget ─────────

/// Async data table — v3 design system.
///
/// Hairline-framed card with uppercase tiny header row (11.5 / 500 tracking),
/// bodySm cell copy, 14 / 20 row padding, `surfaceHover` row-hover bg.
/// Toolbar, bulk-action bar, and footer all use v3 tokens.
class GenaiTable<T> extends StatefulWidget {
  /// Column definitions.
  final List<GenaiColumn<T>> columns;

  /// External controller — drives refresh and exposes state.
  final GenaiTableController<T> controller;

  /// Async loader invoked with the current page request.
  final GenaiTableFetcher<T> fetcher;

  /// Filters available in the toolbar.
  final List<GenaiTableFilter> filters;

  /// Toolbar actions (right-aligned in the header).
  final List<GenaiTableAction<T>> actions;

  /// Bulk actions surfaced when rows are selected.
  final List<GenaiBulkAction<T>> bulkActions;

  /// Available page sizes.
  final List<int> pageSizes;

  /// Initial page size.
  final int initialPageSize;

  /// Whether row selection is enabled (renders a checkbox column).
  final bool selectable;

  /// Whether the toolbar shows a search field.
  final bool searchable;

  /// Table title.
  final String title;

  /// Optional subtitle.
  final String? description;

  /// Initial density.
  final GenaiTableDensity initialDensity;

  /// Stable key extractor — used for selection identity.
  final Object Function(T item) rowKey;

  const GenaiTable({
    super.key,
    required this.columns,
    required this.controller,
    required this.fetcher,
    required this.rowKey,
    this.filters = const [],
    this.actions = const [],
    this.bulkActions = const [],
    this.pageSizes = const [10, 25, 50, 100],
    this.initialPageSize = 25,
    this.selectable = false,
    this.searchable = true,
    this.title = '',
    this.description,
    this.initialDensity = GenaiTableDensity.normal,
  });

  @override
  State<GenaiTable<T>> createState() => _GenaiTableState<T>();
}

class _GenaiTableState<T> extends State<GenaiTable<T>> {
  late GenaiTableDensity _density;
  late Set<String> _visibleColumns;
  final Set<Object> _selectedKeys = {};
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _density = widget.initialDensity;
    _visibleColumns = {
      for (final c in widget.columns)
        if (c.initiallyVisible) c.id
    };
    widget.controller.addListener(_onControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.attach(widget.fetcher, widget.initialPageSize);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  double _rowVerticalPadding(BuildContext context) {
    final s = context.spacing;
    return switch (_density) {
      GenaiTableDensity.compact => s.s6,
      GenaiTableDensity.normal => s.s14,
      GenaiTableDensity.comfortable => s.s18,
    };
  }

  List<GenaiColumn<T>> get _activeColumns =>
      widget.columns.where((c) => _visibleColumns.contains(c.id)).toList();

  T? _itemForKey(Object key) {
    for (final i in widget.controller.items) {
      if (widget.rowKey(i) == key) return i;
    }
    return null;
  }

  Set<T> get _selectedItems {
    final out = <T>{};
    for (final k in _selectedKeys) {
      final item = _itemForKey(k);
      if (item != null) out.add(item);
    }
    return out;
  }

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedKeys
          ..clear()
          ..addAll(widget.controller.items.map(widget.rowKey));
      } else {
        _selectedKeys.clear();
      }
    });
  }

  void _toggleRow(T item) {
    final key = widget.rowKey(item);
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;

    return Semantics(
      container: true,
      label: widget.title.isEmpty ? 'Tabella' : widget.title,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.xl),
          border: Border.all(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildToolbar(context),
            if (_selectedKeys.isNotEmpty && widget.bulkActions.isNotEmpty)
              _buildBulkBar(context),
            Container(
              height: sizing.dividerThickness,
              color: colors.borderDefault,
            ),
            _buildTable(context),
            Container(
              height: sizing.dividerThickness,
              color: colors.borderDefault,
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (widget.title.isEmpty &&
        widget.description == null &&
        widget.actions.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = context.colors;
    final ty = context.typography;
    final s = context.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(s.s20, s.s18, s.s20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title.isNotEmpty)
                  Text(
                    widget.title,
                    style: ty.sectionTitle.copyWith(color: colors.textPrimary),
                  ),
                if (widget.description != null)
                  Padding(
                    padding: EdgeInsets.only(top: s.s2),
                    child: Text(
                      widget.description!,
                      style: ty.bodySm.copyWith(color: colors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
          for (final a in widget.actions) ...[
            SizedBox(width: s.s8),
            _ActionButton<T>(action: a),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final hasFilters = widget.filters.isNotEmpty;
    final s = context.spacing;
    if (!widget.searchable && !hasFilters) {
      return SizedBox(height: s.s12);
    }
    return Padding(
      padding: EdgeInsets.all(s.s12),
      child: Row(
        children: [
          if (widget.searchable)
            Expanded(
              child: _FallbackSearch(
                onChanged: (v) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () => widget.controller.setSearch(v),
                  );
                },
              ),
            ),
          if (hasFilters) ...[
            if (widget.searchable) SizedBox(width: s.s8),
            _ToolbarIconButton(
              icon: LucideIcons.funnel,
              tooltip: 'Filtri',
              onTap: _openFilterPanel,
            ),
          ],
          SizedBox(width: s.s4),
          _ToolbarIconButton(
            icon: LucideIcons.columns3,
            tooltip: 'Colonne',
            onTap: _openColumnPanel,
          ),
          _ToolbarIconButton(
            icon: _density == GenaiTableDensity.compact
                ? LucideIcons.rows3
                : LucideIcons.rows4,
            tooltip: 'Densità',
            onTap: _cycleDensity,
          ),
          _ToolbarIconButton(
            icon: LucideIcons.refreshCw,
            tooltip: 'Ricarica',
            onTap: widget.controller.refresh,
          ),
        ],
      ),
    );
  }

  void _cycleDensity() {
    setState(() {
      _density = switch (_density) {
        GenaiTableDensity.compact => GenaiTableDensity.normal,
        GenaiTableDensity.normal => GenaiTableDensity.comfortable,
        GenaiTableDensity.comfortable => GenaiTableDensity.compact,
      };
    });
  }

  Future<void> _openFilterPanel() async {
    final temp = Map<String, Object?>.from(widget.controller.filters);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) {
          final colors = ctx.colors;
          final ty = ctx.typography;
          final s = ctx.spacing;
          return Dialog(
            backgroundColor: colors.surfaceCard,
            child: Padding(
              padding: EdgeInsets.all(s.s20),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filtri',
                      style:
                          ty.sectionTitle.copyWith(color: colors.textPrimary),
                    ),
                    SizedBox(height: s.s12),
                    for (final f in widget.filters)
                      Padding(
                        padding: EdgeInsets.only(bottom: s.s8),
                        child: f.buildEditor(
                          ctx,
                          temp[f.id],
                          (v) => setInner(() => temp[f.id] = v),
                        ),
                      ),
                    SizedBox(height: s.s12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            widget.controller.clearFilters();
                          },
                          child: const Text('Reimposta'),
                        ),
                        SizedBox(width: s.s8),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            for (final e in temp.entries) {
                              widget.controller.setFilter(e.key, e.value);
                            }
                          },
                          child: const Text('Applica'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openColumnPanel() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) {
          final colors = ctx.colors;
          final ty = ctx.typography;
          final s = ctx.spacing;
          return Dialog(
            backgroundColor: colors.surfaceCard,
            child: Padding(
              padding: EdgeInsets.all(s.s20),
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Colonne visibili',
                      style:
                          ty.sectionTitle.copyWith(color: colors.textPrimary),
                    ),
                    SizedBox(height: s.s12),
                    for (final c in widget.columns)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          c.title,
                          style: ty.bodySm.copyWith(color: colors.textPrimary),
                        ),
                        value: _visibleColumns.contains(c.id),
                        onChanged: (v) => setInner(() {
                          setState(() {
                            if (v == true) {
                              _visibleColumns.add(c.id);
                            } else {
                              _visibleColumns.remove(c.id);
                            }
                          });
                        }),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulkBar(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final s = context.spacing;
    return Container(
      color: colors.colorInfoSubtle,
      padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s8),
      child: Row(
        children: [
          Text(
            '${_selectedKeys.length} selezionati',
            style: ty.labelSm.copyWith(color: colors.colorInfoText),
          ),
          const Spacer(),
          for (final a in widget.bulkActions) ...[
            SizedBox(width: s.s4),
            TextButton.icon(
              onPressed: () => a.onPressed(_selectedItems),
              icon: a.icon == null ? const SizedBox.shrink() : Icon(a.icon),
              label: Text(a.label),
              style: TextButton.styleFrom(
                foregroundColor: a.isDestructive
                    ? colors.colorDangerText
                    : colors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final sizing = context.sizing;
    final s = context.spacing;

    if (widget.controller.loading && widget.controller.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(s.s24),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.controller.error != null) {
      return Padding(
        padding: EdgeInsets.all(s.s24),
        child: Center(
          child: Text(
            'Errore: ${widget.controller.error}',
            style: ty.body.copyWith(color: colors.colorDangerText),
          ),
        ),
      );
    }
    if (widget.controller.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(s.s24),
        child: Center(
          child: Text(
            'Nessun elemento',
            style: ty.body.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    final cols = _activeColumns;
    final allSelected = _selectedKeys.isNotEmpty &&
        _selectedKeys.length == widget.controller.items.length;
    final someSelected = _selectedKeys.isNotEmpty && !allSelected;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(colors.surfaceHover),
        dataRowMinHeight: sizing.rowHeight,
        dataRowMaxHeight: sizing.rowHeight + _rowVerticalPadding(context),
        columnSpacing: s.s24,
        horizontalMargin: s.s20,
        dividerThickness: sizing.dividerThickness,
        headingTextStyle: ty.tiny.copyWith(color: colors.textTertiary),
        dataTextStyle: ty.bodySm.copyWith(color: colors.textPrimary),
        columns: [
          if (widget.selectable)
            DataColumn(
              label: Checkbox(
                value: allSelected
                    ? true
                    : someSelected
                        ? null
                        : false,
                tristate: true,
                onChanged: _toggleAll,
              ),
            ),
          for (final c in cols)
            DataColumn(
              label: _HeaderCell<T>(
                column: c,
                sort: widget.controller.sort,
                onSort: c.sortable
                    ? () {
                        final existing = widget.controller.sort;
                        widget.controller.setSort(
                          existing?.columnId == c.id
                              ? existing!.toggled()
                              : GenaiSortState(
                                  columnId: c.id,
                                  direction: GenaiSortDirection.asc,
                                ),
                        );
                      }
                    : null,
              ),
              numeric: c.align == GenaiColumnAlignment.end,
            ),
        ],
        rows: [
          for (final item in widget.controller.items)
            DataRow(
              selected: _selectedKeys.contains(widget.rowKey(item)),
              onSelectChanged:
                  widget.selectable ? (_) => _toggleRow(item) : null,
              cells: [
                if (widget.selectable)
                  DataCell(Checkbox(
                    value: _selectedKeys.contains(widget.rowKey(item)),
                    onChanged: (_) => _toggleRow(item),
                  )),
                for (final c in cols) DataCell(c.cellBuilder(context, item)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final s = context.spacing;
    final controller = widget.controller;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s8),
      child: Row(
        children: [
          Text(
            controller.totalItems != null
                ? '${controller.items.length} di ${controller.totalItems}'
                : '${controller.items.length} elementi',
            style: ty.labelSm.copyWith(color: colors.textSecondary),
          ),
          const Spacer(),
          DropdownButton<int>(
            value: controller.pageSize,
            items: [
              for (final size in widget.pageSizes)
                DropdownMenuItem(value: size, child: Text('$size / pagina')),
            ],
            onChanged: (v) {
              if (v != null) controller.setPageSize(v);
            },
            style: ty.labelSm.copyWith(color: colors.textPrimary),
            underline: const SizedBox.shrink(),
          ),
          SizedBox(width: s.s8),
          TextButton(
            onPressed: controller.hasNext ? controller.nextPage : null,
            child: const Text('Carica altro'),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell<T> extends StatelessWidget {
  final GenaiColumn<T> column;
  final GenaiSortState? sort;
  final VoidCallback? onSort;

  const _HeaderCell({
    required this.column,
    required this.sort,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final s = context.spacing;
    final isSorted = sort?.columnId == column.id;
    final label = Text(
      column.title.toUpperCase(),
      style: ty.tiny.copyWith(color: colors.textTertiary),
    );
    if (!column.sortable) return label;
    final icon = isSorted
        ? (sort!.direction == GenaiSortDirection.asc
            ? LucideIcons.chevronUp
            : LucideIcons.chevronDown)
        : LucideIcons.chevronsUpDown;
    return InkWell(
      onTap: onSort,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          label,
          SizedBox(width: s.s4),
          Icon(icon, size: context.sizing.iconSize, color: colors.textTertiary),
        ],
      ),
    );
  }
}

class _ActionButton<T> extends StatelessWidget {
  final GenaiTableAction<T> action;
  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final s = context.spacing;
    final radius = context.radius;
    return InkWell(
      onTap: action.onPressed,
      borderRadius: BorderRadius.circular(radius.md),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s8),
        decoration: BoxDecoration(
          color: action.isPrimary ? colors.colorPrimary : colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(
            color: action.isPrimary ? colors.colorPrimary : colors.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                size: context.sizing.iconSize,
                color: action.isPrimary
                    ? colors.textOnPrimary
                    : colors.textPrimary,
              ),
              SizedBox(width: s.s4),
            ],
            Text(
              action.label,
              style: ty.label.copyWith(
                color: action.isPrimary
                    ? colors.textOnPrimary
                    : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.md),
        child: Container(
          width: sizing.minTouchTarget,
          height: sizing.minTouchTarget,
          alignment: Alignment.center,
          child: Icon(icon, size: sizing.iconSize, color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _FallbackSearch extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _FallbackSearch({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final sizing = context.sizing;
    return TextField(
      onChanged: onChanged,
      style: ty.bodySm.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Cerca…',
        hintStyle: ty.bodySm.copyWith(color: colors.textTertiary),
        isDense: true,
        filled: true,
        fillColor: colors.surfaceInput,
        prefixIcon: Icon(LucideIcons.search,
            size: sizing.iconSize, color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.md),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.md),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.md),
          borderSide: BorderSide(
            color: colors.borderFocus,
            width: sizing.focusRingWidth,
          ),
        ),
      ),
    );
  }
}

class _FallbackTextFilter extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initial;
  final ValueChanged<String> onChanged;

  const _FallbackTextFilter({
    required this.label,
    required this.hint,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<_FallbackTextFilter> createState() => _FallbackTextFilterState();
}

class _FallbackTextFilterState extends State<_FallbackTextFilter> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return TextField(
      controller: _c,
      onChanged: widget.onChanged,
      style: ty.bodySm.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        isDense: true,
      ),
    );
  }
}

class _FallbackOptionsFilter<V> extends StatelessWidget {
  final String label;
  final List<({String label, V value})> options;
  final V? value;
  final ValueChanged<Object?> onChanged;

  const _FallbackOptionsFilter({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return InputDecorator(
      decoration: InputDecoration(labelText: label, isDense: true),
      child: DropdownButton<V>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem<V>(
            value: null,
            child: Text(
              'Tutti',
              style: ty.bodySm.copyWith(color: colors.textSecondary),
            ),
          ),
          for (final o in options)
            DropdownMenuItem<V>(
              value: o.value,
              child: Text(
                o.label,
                style: ty.bodySm.copyWith(color: colors.textPrimary),
              ),
            ),
        ],
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}
