part of 'paged_datatable.dart';

class _PagedDataTableHeaderRow<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final bool rowsSelectable;
  final double width;
  final ModelIdGetter<TResultId, TResult> idGetter;
  final bool hasActions;
  final bool hasExpandIcon;

  const _PagedDataTableHeaderRow(this.rowsSelectable, this.width, this.idGetter, this.hasActions, this.hasExpandIcon);

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);
    final clTheme = CLTheme.of(context);
    // Same left border width as rows (2.5px) for alignment
    const double leftBorderWidth = 2.5;

    Widget child = Container(
      decoration: BoxDecoration(
        color: clTheme.primaryBackground.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Sizes.borderRadius),
          topRight: Radius.circular(Sizes.borderRadius),
        ),
        border: Border(
          bottom: BorderSide(color: clTheme.borderColor, width: 1),
        ),
      ),
      height: theme.configuration.columnsHeaderHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /* COLUMNS */
          Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
            selector: (context, state) => state._sortChange,
            builder: (context, isSorted, child) {
              var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
              return Padding(
                // Match left border offset from rows
                padding: const EdgeInsets.only(left: leftBorderWidth),
                child: Row(
                  children: [
                    // Expand icon placeholder - same space as rows
                    if (hasExpandIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: Sizes.padding - leftBorderWidth),
                        child: const SizedBox(width: 24),
                      ),

                    // Checkbox header - same layout as rows
                    if (rowsSelectable)
                      Padding(
                        padding: const EdgeInsets.only(left: Sizes.padding - leftBorderWidth),
                        child: SizedBox(
                          width: 32,
                          child: Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
                            selector: (context, model) => model._rowsSelectionChange,
                            builder: (context, value, child) {
                              final isAllSelected = state._items.isNotEmpty &&
                                  state._items.every((item) => state.selectedRows.containsKey(idGetter(item)));
                              final hasSelection = state.selectedRows.isNotEmpty;

                              return Center(
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: isAllSelected ? true : (hasSelection ? null : false),
                                    tristate: true,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    hoverColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                                    activeColor: clTheme.primary,
                                    checkColor: Colors.white,
                                    side: BorderSide(color: clTheme.borderColor, width: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (newValue) {
                                      if (newValue == true || newValue == null) {
                                        if (isAllSelected) {
                                          state.unselectAllRows();
                                        } else {
                                          state.selectAllRows();
                                        }
                                      } else {
                                        state.unselectAllRows();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Column headers — flexible to avoid overflow
                    ...state.columns.map((column) {
                      final isSorted = state.hasSortModel && state._sortModel!.columnId == column.id;
                      final flex = ((column.sizeFactor ?? 0.1) * 1000).round();

                      return Flexible(
                        flex: flex,
                        child: _ColumnHeader(
                          column: column,
                          isSorted: isSorted,
                          isDescending: isSorted ? state._sortModel!._descending : false,
                          onSort: column.sortable ? () => state.swapSortBy(column.id!) : null,
                        ),
                      );
                    }),

                    // Actions placeholder to match rows
                    if (hasActions)
                      const SizedBox(width: 40),
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
          padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: widget.column.isNumeric ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Header content with optional pill
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: widget.isSorted
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: widget.isSorted
                      ? theme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: widget.column.isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: DefaultTextStyle(
                        style: theme.smallLabel.copyWith(
                          fontWeight: widget.isSorted ? FontWeight.w700 : FontWeight.w600,
                          color: widget.isSorted ? theme.primary : theme.secondaryText,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                        child: widget.column.title,
                      ),
                    ),

                    // Sort indicator
                    if (canSort) ...[
                      const SizedBox(width: 4),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: widget.isSorted ? 1.0 : (_isHovered ? 0.4 : 0.0),
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          turns: widget.isDescending ? 0.5 : 0,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 13,
                            color: widget.isSorted ? theme.primary : theme.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Animated underline on hover
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                height: 2,
                width: _isHovered && canSort ? 24 : 0,
                decoration: BoxDecoration(
                  color: _isHovered ? theme.primary.withValues(alpha: 0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
