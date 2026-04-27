part of 'paged_datatable.dart';

class _PagedDataTableRows<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final bool rowsSelectable;
  final double width;
  final CustomRowBuilder<TResult> customRowBuilder;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final Function(TResult)? onItemTap;
  final bool isInSnippet;
  final Function(TResult)? actionsTitle;
  final int initialPageSize;
  final bool showShimmerLoading;
  final Widget Function(BuildContext context, TResult item)? expandedRowBuilder;
  final Future<void> Function(TResult item)? onRowExpanded;

  const _PagedDataTableRows(
    this.rowsSelectable,
    this.onItemTap,
    this.isInSnippet,
    this.customRowBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.width,
    this.actionsTitle,
    this.tableActions,
    this.actionsBuilder,
    this.initialPageSize,
    this.showShimmerLoading,
    this.expandedRowBuilder,
    this.onRowExpanded,
  );

  @override
  Widget build(BuildContext context) {
    final theme = PagedDataTableTheme.of(context);

    return Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
      selector: (context, model) => model._rowsChange,
      builder: (context, _, child) {
        var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();

        if (showShimmerLoading && state.tableState == _TableState.loading && state._rowsState.isEmpty) {
          return _ShimmerRows<TKey, TResultId, TResult>(
            state: state,
            itemCount: initialPageSize,
            rowsSelectable: rowsSelectable,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: AnimatedOpacity(
            key: ValueKey(state.tableState == _TableState.loading ? 'loading' : 'content_${state._rowsChange}'),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: state.tableState == _TableState.loading ? 0.5 : 1,
            child: DefaultTextStyle(overflow: TextOverflow.ellipsis, style: theme.rowsTextStyle, child: _build(context, state, theme)),
          ),
        );
      },
    );
  }

  Widget _build(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, PagedDataTableThemeData theme) {
    final clTheme = CLTheme.of(context);

    if (state._rowsState.isEmpty && state.tableState == _TableState.displaying) {
      return noItemsFoundBuilder?.call(context) ?? const _EmptyState();
    }

    if (state.tableState == _TableState.error) {
      return errorBuilder?.call(state.currentError!) ?? _ErrorState(error: state.currentError);
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (_, __) => theme.dividerColor == null
          ? Divider(height: 0, color: clTheme.borderColor, thickness: 1)
          : const SizedBox.shrink(),
      itemCount: state._rowsState.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => ChangeNotifierProvider<_PagedDataTableRowState<TResultId, TResult>>.value(
        value: state._rowsState[index],
        child: Consumer<_PagedDataTableRowState<TResultId, TResult>>(
          builder: (context, model, child) {
            return _HoverableRow<TKey, TResultId, TResult>(
              model: model,
              state: state,
              rowsSelectable: rowsSelectable,
              onItemTap: onItemTap,
              width: width,
              tableActions: tableActions,
              actionsBuilder: actionsBuilder,
              actionsTitle: actionsTitle,
              expandedRowBuilder: expandedRowBuilder,
              onRowExpanded: onRowExpanded,
              isEven: index % 2 == 0,
            );
          },
        ),
      ),
    );
  }
}
