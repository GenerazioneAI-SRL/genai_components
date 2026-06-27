part of 'paged_datatable.dart';

class _PagedDataTableBoxed<
    TKey extends Comparable,
    TResultId extends Comparable,
    TResult extends Object> extends StatelessWidget {
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final double width;
  final CustomRowBuilder<TResult> customRowBuilder;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final Function(TResult)? onItemTap;
  final bool isInSnippet;
  final bool rowsSelectable;
  final Function(TResult)? actionsTitle;

  /// Se true le card scorrono da sole nello spazio (bounded) assegnato.
  final bool fillHeight;

  /// Infinite scroll: carica la pagina successiva avvicinandosi al fondo +
  /// loader in coda.
  final bool infiniteScroll;

  const _PagedDataTableBoxed(
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
    this.fillHeight,
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

        // Shimmer loading for mobile
        if (state.tableState == _TableState.loading &&
            state._rowsState.isEmpty) {
          return _buildMobileShimmer(context);
        }

        // Infinite scroll: l'append tiene lo stato `loading` → niente dim né
        // fade-swap dell'intera lista (key stabile, opacità piena); il feedback
        // è solo il loader in coda.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
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

  Widget _buildMobileShimmer(BuildContext context) {
    final theme = CLTheme.of(context);
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(
            top: index == 0 ? 0 : Sizes.small * 0.5,
            bottom: Sizes.small * 0.5,
          ),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(Sizes.radiusCard),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              Container(
                padding: const EdgeInsets.all(Sizes.padding),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: theme.borderColor, width: 1)),
                ),
                child: Row(
                  children: [
                    CLShimmer(width: 40, height: 40, borderRadius: 20),
                    const SizedBox(width: Sizes.small),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CLShimmer(width: 140, height: 14, borderRadius: 4),
                          const SizedBox(height: 6),
                          CLShimmer(width: 90, height: 10, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body shimmer
              Padding(
                padding: const EdgeInsets.all(Sizes.padding),
                child: Column(
                  children: List.generate(
                      2,
                      (i) => Padding(
                            padding: EdgeInsets.only(
                                bottom: i == 1 ? 0 : Sizes.small),
                            child: Row(
                              children: [
                                CLShimmer(
                                    width: 80, height: 10, borderRadius: 4),
                                const Spacer(),
                                CLShimmer(
                                    width: 100, height: 10, borderRadius: 4),
                              ],
                            ),
                          )),
                ),
              ),
            ],
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
      final empty = noItemsFoundBuilder?.call(context) ??
          _buildEmptyState(context, clTheme);
      // In fillHeight lo stato vuoto si centra nello spazio disponibile.
      return fillHeight ? Center(child: empty) : empty;
    }

    if (state.tableState == _TableState.error) {
      final error = errorBuilder?.call(state.currentError!) ??
          _buildErrorState(context, clTheme, state.currentError);
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
      itemCount: rowCount + (showTail ? 1 : 0),
      shrinkWrap: !fillHeight,
      separatorBuilder: (context, index) => Divider(
          height: 1, thickness: 1, color: CLTheme.of(context).secondaryBackground),
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
              if (customRowBuilder.shouldUse(context, model.item)) {
                return SizedBox(
                    height: theme.configuration.rowHeight,
                    child: customRowBuilder.builder(context, model.item));
              }
              return _MobileCard<TKey, TResultId, TResult>(
                model: model,
                state: state,
                index: index,
                rowsSelectable: rowsSelectable,
                onItemTap: onItemTap,
                actionsTitle: actionsTitle,
                tableActions: tableActions,
                actionsBuilder: actionsBuilder,
                isInSnippet: isInSnippet,
                width: width,
              );
            },
          ),
        );
      },
    );
    // Trigger interno solo se la lista possiede lo scroll (fillHeight). In
    // page-scroll (infiniteScroll senza fillHeight) è la pagina a chiamare
    // controller.loadNextPage; qui solo righe + loader.
    return (infiniteScroll && fillHeight)
        ? _InfiniteScrollListener(state: state, child: list)
        : list;
  }

  Widget _buildEmptyState(BuildContext context, CLTheme theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        // Niente card mobile: solo il contenuto, padding Lg attorno.
        padding: const EdgeInsets.all(Sizes.gapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _effectiveTablePrimary(context)
                    .withValues(alpha: theme.opacitySubtle),
                borderRadius: BorderRadius.circular(Sizes.radiusSurface),
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 26,
                  color: _effectiveTablePrimary(context)
                      .withValues(alpha: theme.opacityDisabled)),
            ),
            const SizedBox(height: Sizes.padding),
            Text('Nessun elemento trovato',
                style: theme.bodyText.copyWith(
                    fontWeight: FontWeight.w600, color: theme.secondaryText)),
            const SizedBox(height: Sizes.small * 0.5),
            Text('Prova a modificare i filtri',
                style: theme.smallLabel.copyWith(
                    color: theme.secondaryText.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, CLTheme theme, dynamic error) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: Sizes.padding * 2, horizontal: Sizes.padding),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(Sizes.radiusCard),
          border: Border.all(color: theme.borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 24, color: theme.danger.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: Sizes.padding),
            Text('Errore di caricamento',
                style: theme.bodyText.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: Sizes.small * 0.5),
            Text(error?.toString() ?? 'Errore sconosciuto',
                style: theme.smallLabel.copyWith(
                    color: theme.secondaryText.withValues(alpha: 0.7)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MobileCard<TKey extends Comparable, TResultId extends Comparable,
    TResult extends Object> extends StatefulWidget {
  final _PagedDataTableRowState<TResultId, TResult> model;
  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final int index;
  final bool rowsSelectable;
  final Function(TResult)? onItemTap;
  final Function(TResult)? actionsTitle;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final bool isInSnippet;
  final double width;

  const _MobileCard({
    required this.model,
    required this.state,
    required this.index,
    required this.rowsSelectable,
    required this.onItemTap,
    required this.actionsTitle,
    required this.tableActions,
    required this.actionsBuilder,
    required this.isInSnippet,
    required this.width,
  });

  @override
  State<_MobileCard<TKey, TResultId, TResult>> createState() =>
      _MobileCardState<TKey, TResultId, TResult>();
}

class _MobileCardState<TKey extends Comparable, TResultId extends Comparable,
        TResult extends Object>
    extends State<_MobileCard<TKey, TResultId, TResult>> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final model = widget.model;
    final state = widget.state;
    final actions =
        widget.actionsBuilder?.call(model.item) ?? widget.tableActions;

    // Ruoli mobile: titolo = colonna isMain (fallback: prima colonna); sottotitolo = colonna isSubtitle.
    final cols = state.columns;
    BaseTableColumn<TResult>? titleColumn;
    for (final c in cols) {
      if (c.isMain == true) {
        titleColumn = c;
        break;
      }
    }
    titleColumn ??= cols.isNotEmpty ? cols.first : null;
    BaseTableColumn<TResult>? subtitleColumn;
    for (final c in cols) {
      if (c.isSubtitle) {
        subtitleColumn = c;
        break;
      }
    }

    return Selector<_PagedDataTableState<TKey, TResultId, TResult>, bool>(
      selector: (_, m) => m.mobileSelectionMode,
      builder: (context, selectionMode, _) {
        // Mobile: le azioni inline (es. Modifica/Elimina) si rivelano con lo
        // swipe a sinistra (_SwipeActionsReveal); le non-inline restano nel ⋮.
        final inlineActions = actions.where((a) => a.inline).toList();
        final menuActions = actions.where((a) => !a.inline).toList();

        void handleTap() {
          HapticFeedback.selectionClick();
          if (selectionMode && widget.rowsSelectable) {
            if (model._isSelected) {
              state.unselectRow(model.itemId);
            } else {
              state.selectRow(model.itemId);
            }
          } else {
            widget.onItemTap?.call(model.item);
          }
        }

        final VoidCallback? handleLongPress = widget.rowsSelectable
            ? () {
                if (!selectionMode) {
                  HapticFeedback.mediumImpact();
                  state.enterMobileSelectionMode();
                  state.selectRow(model.itemId);
                }
              }
            : null;

        final inner = AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          color: model._isSelected
              // Tint opaco su tertiaryBackground (grigio zebra scuro): resta sopra le righe.
              ? Color.alphaBlend(_effectiveTablePrimary(context).withValues(alpha: 0.10), theme.tertiaryBackground)
              // Zebra identica a desktop: pari primaryBackground, dispari secondaryBackground (bianco).
              : (widget.index % 2 == 0 ? theme.primaryBackground : theme.secondaryBackground),
          padding: const EdgeInsets.all(Sizes.gapLg),
          child: Row(
            children: [
              if (selectionMode && widget.rowsSelectable) ...[
                Transform.scale(
                  scale: 0.85,
                  child: Checkbox(
                    value: model._isSelected,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    activeColor: _effectiveTablePrimary(context),
                    checkColor: Colors.white,
                    side: BorderSide(color: theme.borderColor, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (value) {
                      if (value == true) {
                        state.selectRow(model.itemId);
                      } else {
                        state.unselectRow(model.itemId);
                      }
                    },
                  ),
                ),
                const SizedBox(width: Sizes.small),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (titleColumn != null)
                      titleColumn.buildCell(model.item, model.index),
                    if (subtitleColumn != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: theme.bodyLabel
                            .copyWith(color: theme.secondaryText, fontSize: 12),
                        child:
                            subtitleColumn.buildCell(model.item, model.index),
                      ),
                    ],
                  ],
                ),
              ),
              if (menuActions.isNotEmpty) ...[
                const SizedBox(width: Sizes.small),
                CLIconButton(
                  onTap: () => _showActionsSheet(context, menuActions, model),
                  iconData: Icons.more_vert_rounded,
                  backgroundColor: theme.controlFill,
                  iconColor: theme.primaryText,
                  size: Sizes.buttonHeightDefault,
                  iconSize: Sizes.iconSizeDefault,
                  tooltip: 'Azioni',
                ),
              ],
            ],
          ),
        );

        // In selection mode lo swipe è disattivato (la riga gestisce il check).
        if (inlineActions.isNotEmpty && !selectionMode) {
          return _SwipeActionsReveal<TResultId, TResult>(
            actions: inlineActions,
            model: model,
            onTap: handleTap,
            onLongPress: handleLongPress,
            child: inner,
          );
        }
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onLongPress: handleLongPress,
          onTap: handleTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: inner,
          ),
        );
      },
    );
  }

  void _showActionsSheet(
      BuildContext context,
      List<TableAction<TResult>> actions,
      _PagedDataTableRowState<TResultId, TResult> model) {
    final theme = CLTheme.of(context);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(Sizes.padding),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(Sizes.radiusModal),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: Sizes.small * 0.75),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.secondaryText.withValues(alpha: theme.opacityMedium),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(Sizes.padding,
                    Sizes.padding * 0.75, Sizes.padding, Sizes.padding * 0.75),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: theme.borderColor, width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.actionsTitle?.call(model.item) ?? 'Azioni',
                        style: theme.bodyText
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.secondaryText.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(Sizes.radiusControl),
                        ),
                        child: Icon(Icons.close_rounded,
                            size: Sizes.iconSizeCompact, color: theme.secondaryText),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions list
              ...actions.map((action) => InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      action.onTap.call(model.item);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.padding,
                          vertical: Sizes.padding * 0.75),
                      child: action.content,
                    ),
                  )),

              // Safe area bottom
              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + Sizes.small),
            ],
          ),
        );
      },
    );
  }
}
