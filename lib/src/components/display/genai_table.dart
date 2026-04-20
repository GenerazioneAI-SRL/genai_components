import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';
import '../feedback/genai_empty_state.dart';
import '../feedback/genai_error_state.dart';
import '../feedback/genai_skeleton.dart';
import '../feedback/genai_spinner.dart';
import '../inputs/genai_checkbox.dart';
import '../inputs/genai_select.dart';
import '../inputs/genai_text_field.dart';

// ───────── Models ─────────

enum GenaiSortDirection { asc, desc }

enum GenaiTableDensity { compact, normal, comfortable }

enum GenaiColumnAlignment { start, center, end }

class GenaiSortState {
  final String columnId;
  final GenaiSortDirection direction;
  const GenaiSortState({required this.columnId, required this.direction});

  GenaiSortState toggled() => GenaiSortState(
        columnId: columnId,
        direction: direction == GenaiSortDirection.asc ? GenaiSortDirection.desc : GenaiSortDirection.asc,
      );
}

/// Page request: `pageKey` is the cursor (null on first page),
/// `pageSize` is rows per page, `sort` and `filters` are applied state.
class GenaiPageRequest {
  final Object? pageKey;
  final int pageSize;
  final GenaiSortState? sort;
  final Map<String, Object?> filters;
  final String search;

  const GenaiPageRequest({
    this.pageKey,
    required this.pageSize,
    this.sort,
    this.filters = const {},
    this.search = '',
  });
}

class GenaiPageResponse<T> {
  final List<T> items;
  final Object? nextPageKey;
  final int? totalItems;

  const GenaiPageResponse({
    required this.items,
    this.nextPageKey,
    this.totalItems,
  });
}

typedef GenaiTableFetcher<T> = Future<GenaiPageResponse<T>> Function(GenaiPageRequest request);

class GenaiColumn<T> {
  final String id;
  final String title;
  final Widget Function(BuildContext, T) cellBuilder;
  final double? width;
  final double? minWidth;
  final bool sortable;
  final GenaiColumnAlignment align;
  final bool initiallyVisible;
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

abstract class GenaiTableFilter {
  String get id;
  String get label;
  Widget buildEditor(BuildContext context, Object? value, ValueChanged<Object?> onChanged);
  String formatValue(Object? value);
}

class GenaiTextFilter implements GenaiTableFilter {
  @override
  final String id;
  @override
  final String label;
  final String? hint;

  const GenaiTextFilter({required this.id, required this.label, this.hint});

  @override
  Widget buildEditor(BuildContext context, Object? value, ValueChanged<Object?> onChanged) {
    return GenaiTextField(
      hint: hint ?? label,
      initialValue: value as String?,
      onChanged: (v) => onChanged(v.isEmpty ? null : v),
      size: GenaiSize.sm,
    );
  }

  @override
  String formatValue(Object? value) => value == null ? '' : '$label: "$value"';
}

class GenaiOptionsFilter<V> implements GenaiTableFilter {
  @override
  final String id;
  @override
  final String label;
  final List<GenaiSelectOption<V>> options;

  const GenaiOptionsFilter({
    required this.id,
    required this.label,
    required this.options,
  });

  @override
  Widget buildEditor(BuildContext context, Object? value, ValueChanged<Object?> onChanged) {
    return GenaiSelect<V>(
      hint: label,
      options: options,
      value: value as V?,
      onChanged: (v) => onChanged(v),
      clearable: true,
      size: GenaiSize.sm,
    );
  }

  @override
  String formatValue(Object? value) {
    if (value == null) return '';
    final opt = options.where((o) => o.value == value).firstOrNull;
    return '$label: ${opt?.label ?? value}';
  }
}

class GenaiTableAction {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const GenaiTableAction({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });
}

class GenaiBulkAction<T> {
  final String label;
  final IconData? icon;
  final void Function(Set<T> selected) onPressed;
  final bool isDestructive;

  const GenaiBulkAction({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
}

// ───────── Controller ─────────

/// Controls a [GenaiTable]: triggers refresh, exposes current page items.
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

  List<T> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  Object? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int? get totalItems => _totalItems;
  bool get hasNext => _nextPageKey != null;
  GenaiSortState? get sort => _sort;
  Map<String, Object?> get filters => Map.unmodifiable(_filters);
  String get search => _search;

  GenaiTableFetcher<T>? _fetcher;
  void attach(GenaiTableFetcher<T> fetcher, int initialPageSize) {
    _fetcher = fetcher;
    _pageSize = initialPageSize;
    refresh();
  }

  Future<void> refresh() async {
    if (_fetcher == null) return;
    _items.clear();
    _nextPageKey = null;
    _currentPage = 0;
    _totalItems = null;
    await _loadPage(reset: true);
  }

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

  void setSort(GenaiSortState? sort) {
    _sort = sort;
    refresh();
  }

  void setFilter(String id, Object? value) {
    if (value == null) {
      _filters.remove(id);
    } else {
      _filters[id] = value;
    }
    refresh();
  }

  void clearFilters() {
    _filters.clear();
    _search = '';
    refresh();
  }

  void setSearch(String value) {
    _search = value;
    refresh();
  }

  void setPageSize(int size) {
    _pageSize = size;
    refresh();
  }
}

// ───────── Widget ─────────

class GenaiTable<T> extends StatefulWidget {
  final List<GenaiColumn<T>> columns;
  final GenaiTableController<T> controller;
  final GenaiTableFetcher<T> fetcher;
  final List<GenaiTableFilter> filters;
  final List<GenaiTableAction> actions;
  final List<GenaiBulkAction<T>> bulkActions;
  final List<int> pageSizes;
  final int initialPageSize;
  final bool selectable;
  final bool searchable;
  final String title;
  final String? description;
  final GenaiTableDensity initialDensity;
  final Widget Function(BuildContext, T)? mobileCardBuilder;
  final Widget Function(BuildContext, T)? expandedRowBuilder;
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
    this.mobileCardBuilder,
    this.expandedRowBuilder,
  });

  @override
  State<GenaiTable<T>> createState() => _GenaiTableState<T>();
}

class _GenaiTableState<T> extends State<GenaiTable<T>> {
  late GenaiTableDensity _density;
  late Set<String> _visibleColumns;
  final Set<Object> _selectedKeys = {};
  final Set<Object> _expandedKeys = {};
  Timer? _searchDebounce;
  String _searchValue = '';

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

  double _rowVerticalPadding() => switch (_density) {
        GenaiTableDensity.compact => 6,
        GenaiTableDensity.normal => 10,
        GenaiTableDensity.comfortable => 14,
      };

  List<GenaiColumn<T>> get _activeColumns => widget.columns.where((c) => _visibleColumns.contains(c.id)).toList();

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
    final ty = context.typography;
    final isCompact = context.isCompact;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final bounded = constraints.maxHeight.isFinite;
        final body =
            isCompact && widget.mobileCardBuilder != null ? _buildMobile(context) : _buildDesktopTable(context, colors, ty, bounded: bounded);
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(context.radius.md),
            border: Border.all(color: colors.borderDefault),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, colors, ty),
              _buildToolbar(context, colors),
              if (_selectedKeys.isNotEmpty && widget.bulkActions.isNotEmpty) _buildBulkBar(context, colors, ty),
              Container(height: 1, color: colors.borderDefault),
              bounded ? Expanded(child: body) : body,
              Container(height: 1, color: colors.borderDefault),
              _buildFooter(context, colors, ty),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic colors, dynamic ty) {
    if (widget.title.isEmpty && widget.description == null && widget.actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title.isNotEmpty) Text(widget.title, style: ty.headingSm.copyWith(color: colors.textPrimary)),
                if (widget.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(widget.description!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                  ),
              ],
            ),
          ),
          for (final a in widget.actions) ...[
            const SizedBox(width: 8),
            a.isPrimary
                ? GenaiButton.primary(label: a.label, icon: a.icon, onPressed: a.onPressed)
                : GenaiButton.secondary(label: a.label, icon: a.icon, onPressed: a.onPressed),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, dynamic colors) {
    final hasFilters = widget.filters.isNotEmpty;
    if (!widget.searchable && !hasFilters) {
      return const SizedBox(height: 12);
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (widget.searchable)
            Expanded(
              child: GenaiTextField.search(
                onChanged: (v) {
                  _searchValue = v;
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(GenaiDurations.searchDebounce, () {
                    widget.controller.setSearch(_searchValue);
                  });
                },
              ),
            ),
          if (hasFilters) ...[
            if (widget.searchable) const SizedBox(width: 8),
            GenaiIconButton(
              icon: LucideIcons.funnel,
              semanticLabel: 'Filtri',
              tooltip: 'Filtri',
              size: GenaiSize.sm,
              badge: widget.controller.filters.isEmpty
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.colorPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${widget.controller.filters.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
              onPressed: _openFilterPanel,
            ),
          ],
          const SizedBox(width: 4),
          GenaiIconButton(
            icon: LucideIcons.columns3,
            semanticLabel: 'Colonne',
            tooltip: 'Colonne visibili',
            size: GenaiSize.sm,
            onPressed: _openColumnPanel,
          ),
          GenaiIconButton(
            icon: _density == GenaiTableDensity.compact ? LucideIcons.rows3 : LucideIcons.rows4,
            semanticLabel: 'Densità',
            tooltip: 'Densità',
            size: GenaiSize.sm,
            onPressed: _cycleDensity,
          ),
          GenaiIconButton(
            icon: LucideIcons.refreshCw,
            semanticLabel: 'Ricarica',
            tooltip: 'Ricarica',
            size: GenaiSize.sm,
            onPressed: widget.controller.refresh,
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
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        final colors = ctx.colors;
        final ty = ctx.typography;
        return Dialog(
          backgroundColor: colors.surfaceCard,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Filtri', style: ty.headingSm.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 12),
                  for (final f in widget.filters) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: f.buildEditor(ctx, temp[f.id], (v) => setState(() => temp[f.id] = v)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GenaiButton.ghost(
                        label: 'Pulisci',
                        onPressed: () {
                          widget.controller.clearFilters();
                          Navigator.of(ctx).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      GenaiButton.primary(
                        label: 'Applica',
                        onPressed: () {
                          for (final f in widget.filters) {
                            widget.controller.setFilter(f.id, temp[f.id]);
                          }
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _openColumnPanel() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        final colors = ctx.colors;
        final ty = ctx.typography;
        return Dialog(
          backgroundColor: colors.surfaceCard,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Colonne visibili', style: ty.headingSm.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 12),
                  for (final c in widget.columns)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GenaiCheckbox(
                        value: _visibleColumns.contains(c.id),
                        label: c.title,
                        onChanged: (v) {
                          this.setState(() {
                            setState(() {
                              if (v == true) {
                                _visibleColumns.add(c.id);
                              } else {
                                _visibleColumns.remove(c.id);
                              }
                            });
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GenaiButton.primary(
                      label: 'Chiudi',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBulkBar(BuildContext context, dynamic colors, dynamic ty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.colorPrimarySubtle,
      child: Row(
        children: [
          Text('${_selectedKeys.length} selezionati', style: ty.label.copyWith(color: colors.colorPrimary)),
          const Spacer(),
          for (final a in widget.bulkActions) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: a.isDestructive
                  ? GenaiButton.destructive(
                      label: a.label,
                      icon: a.icon,
                      size: GenaiSize.sm,
                      onPressed: () => a.onPressed(_selectedItems),
                    )
                  : GenaiButton.secondary(
                      label: a.label,
                      icon: a.icon,
                      size: GenaiSize.sm,
                      onPressed: () => a.onPressed(_selectedItems),
                    ),
            ),
          ],
          const SizedBox(width: 8),
          GenaiIconButton(
            icon: LucideIcons.x,
            semanticLabel: 'Annulla selezione',
            size: GenaiSize.sm,
            onPressed: () => setState(_selectedKeys.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, dynamic colors, dynamic ty, {required bool bounded}) {
    final ctrl = widget.controller;
    if (ctrl.error != null && ctrl.items.isEmpty) {
      return GenaiErrorState(
        title: 'Errore caricamento dati',
        description: ctrl.error.toString(),
        onRetry: ctrl.refresh,
      );
    }
    if (ctrl.loading && ctrl.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < 6; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: GenaiSkeleton.rect(height: 36),
              ),
          ],
        ),
      );
    }
    if (ctrl.items.isEmpty) {
      return GenaiEmptyState.noResults(
        title: 'Nessun risultato',
        description: 'Modifica i filtri o la ricerca per trovare elementi.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        if (bounded) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderRow(context, colors, ty),
                  Container(height: 1, color: colors.borderDefault),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ctrl.items.length,
                      itemBuilder: (ctx, i) => _buildBodyRow(ctx, ctrl.items[i], i, colors, ty),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableWidth),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderRow(context, colors, ty),
                  Container(height: 1, color: colors.borderDefault),
                  for (var i = 0; i < ctrl.items.length; i++) _buildBodyRow(context, ctrl.items[i], i, colors, ty),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context, dynamic colors, dynamic ty) {
    final allSelected = widget.controller.items.isNotEmpty && _selectedKeys.length == widget.controller.items.length;
    final someSelected = _selectedKeys.isNotEmpty && !allSelected;

    return Container(
      color: colors.surfaceHover,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: _rowVerticalPadding()),
      child: Row(
        children: [
          if (widget.selectable) ...[
            GenaiCheckbox(
              value: someSelected ? null : allSelected,
              onChanged: _toggleAll,
            ),
            const SizedBox(width: 12),
          ],
          if (widget.expandedRowBuilder != null) const SizedBox(width: 28),
          for (final c in _activeColumns) _buildHeaderCell(context, c, colors, ty),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, GenaiColumn<T> col, dynamic colors, dynamic ty) {
    final sort = widget.controller.sort;
    final isSorted = sort?.columnId == col.id;
    final align = switch (col.align) {
      GenaiColumnAlignment.start => MainAxisAlignment.start,
      GenaiColumnAlignment.center => MainAxisAlignment.center,
      GenaiColumnAlignment.end => MainAxisAlignment.end,
    };
    Widget header = Row(
      mainAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(col.title, overflow: TextOverflow.ellipsis, style: ty.label.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        if (col.sortable) ...[
          const SizedBox(width: 4),
          AnimatedRotation(
            turns: isSorted && sort!.direction == GenaiSortDirection.desc ? 0.5 : 0,
            duration: GenaiDurations.sortArrow,
            child: Icon(
              LucideIcons.arrowUp,
              size: 14,
              color: isSorted ? colors.colorPrimary : colors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (col.sortable) {
      header = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isSorted) {
            widget.controller.setSort(sort!.toggled());
          } else {
            widget.controller.setSort(GenaiSortState(columnId: col.id, direction: GenaiSortDirection.asc));
          }
        },
        child: MouseRegion(cursor: SystemMouseCursors.click, child: header),
      );
    }

    return _buildCellContainer(col, header);
  }

  Widget _buildCellContainer(GenaiColumn<T> col, Widget child) {
    if (col.width != null) {
      return SizedBox(width: col.width, child: child);
    }
    return Expanded(
      flex: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: col.minWidth ?? 0),
        child: child,
      ),
    );
  }

  Widget _buildBodyRow(BuildContext context, T item, int index, dynamic colors, dynamic ty) {
    final key = widget.rowKey(item);
    final selected = _selectedKeys.contains(key);
    final expanded = _expandedKeys.contains(key);
    final zebra = index.isOdd ? colors.surfaceCard : colors.surfacePage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: selected ? colors.colorPrimarySubtle : zebra,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: _rowVerticalPadding()),
          child: Row(
            children: [
              if (widget.selectable) ...[
                GenaiCheckbox(
                  value: selected,
                  onChanged: (_) => _toggleRow(item),
                ),
                const SizedBox(width: 12),
              ],
              if (widget.expandedRowBuilder != null)
                SizedBox(
                  width: 28,
                  child: GenaiIconButton(
                    icon: expanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    semanticLabel: expanded ? 'Comprimi' : 'Espandi',
                    size: GenaiSize.xs,
                    onPressed: () => setState(() {
                      if (expanded) {
                        _expandedKeys.remove(key);
                      } else {
                        _expandedKeys.add(key);
                      }
                    }),
                  ),
                ),
              for (final c in _activeColumns)
                _buildCellContainer(
                  c,
                  Align(
                    alignment: switch (c.align) {
                      GenaiColumnAlignment.start => Alignment.centerLeft,
                      GenaiColumnAlignment.center => Alignment.center,
                      GenaiColumnAlignment.end => Alignment.centerRight,
                    },
                    child: c.cellBuilder(context, item),
                  ),
                ),
            ],
          ),
        ),
        if (expanded && widget.expandedRowBuilder != null)
          Container(
            color: colors.surfaceHover,
            padding: const EdgeInsets.all(16),
            child: widget.expandedRowBuilder!(context, item),
          ),
        Container(height: 1, color: colors.borderDefault),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    final ctrl = widget.controller;
    if (ctrl.loading && ctrl.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: GenaiSpinner(),
      );
    }
    if (ctrl.items.isEmpty) {
      return const GenaiEmptyState(title: 'Nessun risultato');
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in ctrl.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: widget.mobileCardBuilder!(context, item),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, dynamic colors, dynamic ty) {
    final ctrl = widget.controller;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            ctrl.totalItems != null ? '${ctrl.items.length} di ${ctrl.totalItems}' : '${ctrl.items.length} elementi',
            style: ty.caption.copyWith(color: colors.textSecondary),
          ),
          const Spacer(),
          Text('Per pagina:', style: ty.caption.copyWith(color: colors.textSecondary)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: GenaiSelect<int>(
              options: [
                for (final s in widget.pageSizes) GenaiSelectOption(value: s, label: '$s'),
              ],
              value: ctrl.pageSize,
              onChanged: (v) {
                if (v != null) ctrl.setPageSize(v);
              },
              size: GenaiSize.sm,
            ),
          ),
          const SizedBox(width: 12),
          GenaiIconButton(
            icon: LucideIcons.chevronRight,
            semanticLabel: 'Carica altri',
            size: GenaiSize.sm,
            onPressed: ctrl.hasNext ? ctrl.nextPage : null,
          ),
        ],
      ),
    );
  }
}
