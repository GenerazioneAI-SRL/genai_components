part of 'paged_datatable.dart';

class _PagedDataTableRows<TKey extends Comparable, TResultId extends Comparable,
    TResult extends Object> extends StatelessWidget {
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

  /// Se true le righe scorrono da sole nello spazio (bounded) assegnato.
  final bool fillHeight;

  /// Shimmer geometry: mirrors the data/header leading + trailing envelope.
  final bool hasExpandIcon;
  final double actionsColumnWidth;

  /// Infinite scroll: carica la pagina successiva avvicinandosi al fondo +
  /// loader in coda.
  final bool infiniteScroll;

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
    this.fillHeight,
    this.hasExpandIcon,
    this.actionsColumnWidth,
    this.infiniteScroll,
  );

  @override
  Widget build(BuildContext context) {
    final theme = PagedDataTableTheme.of(context);

    return Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
      selector: (context, model) => model._rowsChange,
      builder: (context, _, child) {
        var state =
            context.read<_PagedDataTableState<TKey, TResultId, TResult>>();

        if (showShimmerLoading &&
            state.tableState == _TableState.loading &&
            state._rowsState.isEmpty) {
          return _ShimmerRows<TKey, TResultId, TResult>(
            state: state,
            itemCount: initialPageSize,
            rowsSelectable: rowsSelectable,
            hasExpandIcon: hasExpandIcon,
            actionsColumnWidth: actionsColumnWidth,
          );
        }

        // Infinite scroll: l'append tiene lo stato `loading` → niente dim né
        // fade-swap dell'intera lista (key stabile, opacità piena); il feedback
        // è solo il loader in coda.
        return AnimatedSwitcher(
          duration: CLTheme.of(context).durationBase,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: AnimatedOpacity(
            key: ValueKey(infiniteScroll
                ? 'content'
                : state.tableState == _TableState.loading
                    ? 'loading'
                    : 'content_${state._rowsChange}'),
            duration: CLTheme.of(context).durationBase,
            curve: Curves.easeOut,
            opacity:
                (state.tableState == _TableState.loading && !infiniteScroll)
                    ? CLTheme.of(context).opacityDisabled
                    : 1,
            child: DefaultTextStyle(
                overflow: TextOverflow.ellipsis,
                style: theme.rowsTextStyle,
                child: _build(context, state, theme)),
          ),
        );
      },
    );
  }

  Widget _build(
      BuildContext context,
      _PagedDataTableState<TKey, TResultId, TResult> state,
      PagedDataTableThemeData theme) {
    final clTheme = CLTheme.of(context);

    if (state._rowsState.isEmpty &&
        state.tableState == _TableState.displaying) {
      final empty = noItemsFoundBuilder?.call(context) ?? const _EmptyState();
      // In fillHeight lo stato vuoto si centra nello spazio disponibile.
      return fillHeight ? Center(child: empty) : empty;
    }

    if (state.tableState == _TableState.error) {
      final error = errorBuilder?.call(state.currentError!) ??
          _ErrorState(error: state.currentError);
      return fillHeight ? Center(child: error) : error;
    }

    final rowCount = state._rowsState.length;
    // In infinite scroll una voce in coda: loader se c'è altro, messaggio di
    // fine lista altrimenti.
    final showTail = infiniteScroll && rowCount > 0;
    final list = ListView.separated(
      // In fillHeight la lista scorre da sola nello spazio assegnato.
      physics: fillHeight
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      primary: false,
      padding: EdgeInsets.zero,
      separatorBuilder: (_, index) => theme.dividerColor == null
          ? Divider(height: 0, color: clTheme.secondaryBackground, thickness: 1)
          : const SizedBox.shrink(),
      itemCount: rowCount + (showTail ? 1 : 0),
      shrinkWrap: !fillHeight,
      itemBuilder: (context, index) {
        if (index >= rowCount) {
          return state.hasNextPage
              ? const _InfiniteScrollLoader()
              : const _InfiniteScrollEnd();
        }
        return ChangeNotifierProvider<
            _PagedDataTableRowState<TResultId, TResult>>.value(
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
        );
      },
    );
    // Trigger interno solo se la lista possiede lo scroll (fillHeight). In
    // page-scroll (infiniteScroll senza fillHeight) è la pagina a chiamare
    // controller.loadNextPage; qui renderizziamo solo righe + loader.
    return (infiniteScroll && fillHeight)
        ? _InfiniteScrollListener(state: state, child: list)
        : list;
  }
}

/// Loader in coda alla lista durante il fetch della pagina successiva.
class _InfiniteScrollLoader extends StatelessWidget {
  const _InfiniteScrollLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.gapLg),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _effectiveTablePrimary(context),
          ),
        ),
      ),
    );
  }
}

/// Messaggio di fine lista (infinite scroll, nessun'altra pagina).
class _InfiniteScrollEnd extends StatelessWidget {
  const _InfiniteScrollEnd();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    // Stessa impronta di una riga (padding card), testo centrato: occupa lo
    // spazio di una riga aggiuntiva, niente vuoto extra sotto.
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.all(Sizes.gapLg),
      alignment: Alignment.center,
      child: Text(
        'Non ci sono altri risultati',
        style: theme.smallLabel.copyWith(color: theme.secondaryText),
      ),
    );
  }
}

/// Avvolge la lista scrollabile: quando ci si avvicina al fondo carica la pagina
/// successiva in append. Guard su `hasNextPage` + stato non-loading → niente
/// fetch multipli concorrenti (`_dispatchCallback` setta loading in modo sincrono).
class _InfiniteScrollListener<
    TKey extends Comparable,
    TResultId extends Comparable,
    TResult extends Object> extends StatelessWidget {
  const _InfiniteScrollListener({required this.state, required this.child});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.axis == Axis.vertical &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 240 &&
            state.hasNextPage &&
            state.tableState != _TableState.loading) {
          state.nextPage(isInfiniteScroll: true);
        }
        return false;
      },
      child: child,
    );
  }
}
