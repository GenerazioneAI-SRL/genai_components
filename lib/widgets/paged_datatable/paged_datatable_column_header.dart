part of 'paged_datatable.dart';

class _PagedDataTableHeaderRow<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final bool rowsSelectable;
  final double width;
  final ModelIdGetter<TResultId, TResult> idGetter;
  final bool hasActions;
  final bool hasExpandIcon;
  final double actionsColumnWidth;
  final bool selectAllInHeader;

  const _PagedDataTableHeaderRow(this.rowsSelectable, this.width, this.idGetter, this.hasActions, this.hasExpandIcon, this.actionsColumnWidth,
      this.selectAllInHeader);

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);
    final clTheme = CLTheme.of(context);
    // Same leading/trailing geometry as data rows (single source of truth).
    final m = PagedDataTableRowMetrics.of(context);

    Widget child = Container(
      // Niente divider sotto: dall'header row alla bolla resta solo il gap Lg.
      decoration: BoxDecoration(
        color: _tableHeaderBg(context),
      ),
      height: theme.configuration.columnsHeaderHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /* COLUMNS */
          Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
            selector: (context, state) => state._sortChange,
            builder: (context, _, child) {
              var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
              return Padding(
                // Match left border offset from rows
                padding: EdgeInsets.only(left: m.leftBorderWidth),
                child: Row(
                  children: [
                    // Expand icon placeholder - same space as rows
                    if (hasExpandIcon)
                      Padding(
                        padding: EdgeInsets.only(left: m.expandLeftPad),
                        child: SizedBox(width: m.expandSlot),
                      ),

                    // Checkbox header - slot centered on the search-field prefix-icon center.
                    // selectAllInHeader=false: mantieni lo slot (allineamento colonne
                    // con le righe che hanno checkbox) ma niente checkbox select-all.
                    if (rowsSelectable && !selectAllInHeader)
                      Padding(
                        padding: EdgeInsets.only(left: m.checkboxLeftPad, right: m.checkboxRightGap),
                        child: SizedBox(width: m.checkboxSlot),
                      ),
                    if (rowsSelectable && selectAllInHeader)
                      Padding(
                        padding: EdgeInsets.only(left: m.checkboxLeftPad, right: m.checkboxRightGap),
                        child: SizedBox(
                          width: m.checkboxSlot,
                          child: Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
                            selector: (context, model) => model._rowsSelectionChange,
                            builder: (context, value, child) {
                              final isAllSelected =
                                  state._items.isNotEmpty && state._items.every((item) => state.selectedRows.containsKey(idGetter(item)));
                              // Usa solo gli item della pagina corrente per determinare se c'è una selezione parziale,
                              // evitando che selezioni su altre pagine influenzino il checkbox header
                              final hasCurrentPageSelection = state._items.any((item) => state.selectedRows.containsKey(idGetter(item)));

                              return Align(
                                alignment: Alignment.center,
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: isAllSelected ? true : (hasCurrentPageSelection ? null : false),
                                    tristate: true,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    hoverColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                                    activeColor: clTheme.primary,
                                    checkColor: clTheme.primaryForeground,
                                    side: BorderSide(color: clTheme.borderColor, width: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(clTheme.radiusXs)),
                                    onChanged: (_) {
                                      if (isAllSelected) {
                                        // Tutti selezionati → deseleziona solo la pagina corrente
                                        state.unselectAllRows();
                                      } else {
                                        // Nessuno o parziale → seleziona tutti sulla pagina corrente
                                        state.selectAllRows();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Column headers — fixed width to match rows
                    ...state.columns.map((column) {
                      final isSorted = state.hasSortModel && state._sortModel!.columnId == column.id;

                      return SizedBox(
                        width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : width * column.sizeFactor!,
                        child: _ColumnHeader(
                          column: column,
                          isSorted: isSorted,
                          isDescending: isSorted ? state._sortModel!._descending : false,
                          onSort: column.sortable ? () => state.swapSortBy(column.id!) : null,
                        ),
                      );
                    }),

                    // Spacer to match rows
                    const Spacer(),

                    // Actions placeholder to match rows (inline buttons + popup 40 + right padding)
                    if (hasActions) SizedBox(width: actionsColumnWidth),
                  ],
                ),
              );
            },
          ),

          /* LOADING INDICATOR */
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Selector<_PagedDataTableState<TKey, TResultId, TResult>, _TableState>(
              selector: (context, state) => state._state,
              builder: (context, tableState, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: tableState == _TableState.loading ? 2 : 0,
                  child: LinearProgressIndicator(
                    color: clTheme.primary,
                    backgroundColor: clTheme.primary.withValues(alpha: 0.15),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (theme.headerBackgroundColor != null) {
      child = DecoratedBox(decoration: BoxDecoration(color: theme.headerBackgroundColor), child: child);
    }

    if (theme.headerTextStyle != null) {
      child = DefaultTextStyle(style: theme.headerTextStyle!, child: child);
    }

    return child;
  }
}

// Widget separato per column header con hover state
class _ColumnHeader<TResult extends Object> extends StatefulWidget {
  final BaseTableColumn<TResult> column;
  final bool isSorted;
  final bool isDescending;
  final VoidCallback? onSort;

  const _ColumnHeader({
    required this.column,
    required this.isSorted,
    required this.isDescending,
    this.onSort,
  });

  @override
  State<_ColumnHeader<TResult>> createState() => _ColumnHeaderState<TResult>();
}

class _ColumnHeaderState<TResult extends Object> extends State<_ColumnHeader<TResult>> {
  bool _isHovered = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final canSort = widget.onSort != null;

    return MouseRegion(
      cursor: canSort ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: canSort ? (_) => _safeSetState(() => _isHovered = true) : null,
      onExit: canSort ? (_) => _safeSetState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onSort,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg),
          decoration: BoxDecoration(
            color: _isHovered && canSort ? theme.primaryText.withValues(alpha: 0.02) : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.column.isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: DefaultTextStyle(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: theme.bodyLabelTableHead.copyWith(
                    fontWeight: widget.isSorted ? FontWeight.w700 : FontWeight.w600,
                    color: widget.isSorted ? _effectiveTablePrimary(context) : theme.secondaryText,
                  ),
                  child: widget.column.title,
                ),
              ),

              // Sort indicator — always hint sortability on hover
              if (canSort) ...[
                const SizedBox(width: Sizes.gapXs),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: widget.isSorted ? 1.0 : (_isHovered ? 0.5 : 0.15),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    turns: widget.isDescending ? 0.5 : 0,
                    child: Icon(
                      LucideIcons.arrowUp,
                      size: theme.iconSizeCompact,
                      color: widget.isSorted ? _effectiveTablePrimary(context) : theme.secondaryText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
