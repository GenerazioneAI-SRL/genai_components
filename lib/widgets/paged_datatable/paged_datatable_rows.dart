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
          return _buildShimmerRows(context, state);
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

  Widget _buildShimmerRows(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) {
    final clTheme = CLTheme.of(context);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: initialPageSize,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.5),
        child: Divider(height: 0, color: clTheme.borderColor, thickness: 1),
      ),
      itemBuilder: (context, index) {
        // Stagger widths per row for more realistic look
        final widthMultiplier = [0.7, 0.5, 0.85, 0.6, 0.75][index % 5];
        return Container(
          height: 52,
          padding: const EdgeInsets.only(left: 2.5), // Same as left border in rows
          child: Row(
            children: [
              if (rowsSelectable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
                  child: CLShimmer(width: 18, height: 18, borderRadius: 4),
                ),
              ...List.generate(state.columns.length, (colIndex) {
                final col = state.columns[colIndex];
                final factor = col.sizeFactor ?? (1.0 / state.columns.length);
                return Expanded(
                  flex: (factor * 100).round(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.verticalPadding),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CLShimmer(
                        width: colIndex == 0 ? double.infinity : 60.0 + (40.0 * widthMultiplier),
                        height: 14,
                        borderRadius: 6,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _build(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, PagedDataTableThemeData theme) {
    final clTheme = CLTheme.of(context);

    // Empty state migliorato
    if (state._rowsState.isEmpty && state.tableState == _TableState.displaying) {
      return noItemsFoundBuilder?.call(context) ?? _buildEmptyState(context, clTheme);
    }

    // Error state migliorato
    if (state.tableState == _TableState.error) {
      return errorBuilder?.call(state.currentError!) ?? _buildErrorState(context, clTheme, state.currentError);
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (_, __) => theme.dividerColor == null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.5),
               child: Divider(height: 0, color: clTheme.borderColor, thickness: 1),
            )
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

  Widget _buildEmptyState(BuildContext context, CLTheme theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Sizes.padding * 3, horizontal: Sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(Sizes.borderRadius + 4),
                border: Border.all(color: theme.primary.withValues(alpha: 0.1)),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 28,
                color: theme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: Sizes.padding),
            Text(
              'Nessun elemento trovato',
              style: theme.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: Sizes.small * 0.5),
            Text(
              'Prova a modificare i filtri di ricerca',
              style: theme.smallLabel.copyWith(
                color: theme.secondaryText.withValues(alpha: 0.6),
              ),
            ),
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
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Sizes.padding * 2, horizontal: Sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Sizes.borderRadius + 2),
                border: Border.all(color: theme.danger.withValues(alpha: 0.15)),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 26,
                color: theme.danger.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: Sizes.padding),
            Text(
              'Si è verificato un errore',
              style: theme.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: Sizes.small * 0.5),
            Text(
              error?.toString() ?? 'Errore sconosciuto',
              style: theme.smallLabel.copyWith(color: theme.secondaryText.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableRow<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatefulWidget {
  final _PagedDataTableRowState<TResultId, TResult> model;
  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final bool rowsSelectable;
  final Function(TResult)? onItemTap;
  final double width;
  final List<TableAction<TResult>> tableActions;
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;
  final Function(TResult)? actionsTitle;
  final Widget Function(BuildContext context, TResult item)? expandedRowBuilder;
  final Future<void> Function(TResult item)? onRowExpanded;
  final bool isEven;

  const _HoverableRow({
    required this.model,
    required this.state,
    required this.rowsSelectable,
    required this.onItemTap,
    required this.width,
    required this.tableActions,
    required this.actionsBuilder,
    required this.actionsTitle,
    this.expandedRowBuilder,
    this.onRowExpanded,
    this.isEven = false,
  });

  @override
  State<_HoverableRow<TKey, TResultId, TResult>> createState() => _HoverableRowState<TKey, TResultId, TResult>();
}

class _HoverableRowState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends State<_HoverableRow<TKey, TResultId, TResult>> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isDialogOpen = false;
  bool _isExpanded = false;
  bool _isLoadingExpanded = false;
  bool _isPressed = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey iconKey = GlobalKey();
    final model = widget.model;
    final state = widget.state;
    final theme = CLTheme.of(context);
    final actions = widget.actionsBuilder?.call(model.item) ?? widget.tableActions;
    final showControls = _isHovered || model._isSelected || _isDialogOpen;
    final hasExpandedBuilder = widget.expandedRowBuilder != null;
    final isActive = model._isSelected || _isHovered || _isExpanded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: widget.onItemTap != null || hasExpandedBuilder ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => _safeSetState(() => _isHovered = true),
          onExit: (_) => _safeSetState(() {
            if (!_isDialogOpen) _isHovered = false;
          }),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () async {
              HapticFeedback.selectionClick();
              if (hasExpandedBuilder) {
                if (_isExpanded) {
                  setState(() => _isExpanded = false);
                } else {
                  setState(() {
                    _isExpanded = true;
                    _isLoadingExpanded = true;
                  });
                  if (widget.onRowExpanded != null) {
                    await widget.onRowExpanded!(model.item);
                  }
                  if (mounted) setState(() => _isLoadingExpanded = false);
                }
              }
              widget.onItemTap?.call(model.item);
            },
            child: AnimatedScale(
              scale: _isPressed ? 0.995 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minHeight: 52),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.primary.withValues(alpha: 0.04)
                      : _isHovered
                          ? theme.primaryText.withValues(alpha: 0.015)
                          : Colors.transparent,
                  border: Border(
                    left: BorderSide(
                      color: isActive ? theme.primary : Colors.transparent,
                      width: isActive ? 2.5 : 2.5,
                    ),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Expand icon
                      if (hasExpandedBuilder)
                        Padding(
                          padding: const EdgeInsets.only(left: Sizes.padding - 2.5),
                          child: SizedBox(
                            width: 24,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedRotation(
                                turns: _isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: _isExpanded ? theme.primary : theme.secondaryText.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Checkbox
                      if (widget.rowsSelectable)
                        Padding(
                          padding: const EdgeInsets.only(left: Sizes.padding - 2.5),
                          child: SizedBox(
                            width: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: showControls ? 1.0 : 0.0,
                                child: _RowSelectorCheckbox(
                                  isSelected: model._isSelected,
                                  setSelected: (newValue) {
                                    if (newValue) {
                                      state.selectRow(model.itemId);
                                    } else {
                                      state.unselectRow(model.itemId);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Columns
                      ...state.columns.map(
                        (column) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.75),
                          width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : widget.width * column.sizeFactor!,
                          child: Align(
                            alignment: column.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                            child: column.buildCell(model.item, model.index),
                          ),
                        ),
                      ),

                      // Fill remaining space
                      const Spacer(),

                      // Actions button
                      if (actions.isNotEmpty)
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: showControls ? 1.0 : 0.0,
                              child: _ActionButton(
                                iconKey: iconKey,
                                actions: actions,
                                model: model,
                                actionsTitle: widget.actionsTitle,
                                onDialogStateChange: (isOpen) {
                                  setState(() {
                                    _isDialogOpen = isOpen;
                                    if (!isOpen) _isHovered = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Expanded content
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: _isExpanded && hasExpandedBuilder
              ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground.withValues(alpha: 0.5),
                    border: Border(
                      left: BorderSide(color: theme.primary.withValues(alpha: 0.4), width: 2.5),
                      bottom: BorderSide(color: theme.borderColor, width: 1),
                    ),
                  ),
                  margin: EdgeInsets.only(left: widget.rowsSelectable ? 56 : 0),
                  padding: const EdgeInsets.all(Sizes.padding),
                  child: _isLoadingExpanded
                      ? Padding(
                          padding: const EdgeInsets.all(Sizes.padding),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.primary,
                              ),
                            ),
                          ),
                        )
                      : widget.expandedRowBuilder!(context, model.item),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// Action button separato per migliore gestione
class _ActionButton<TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final GlobalKey iconKey;
  final List<TableAction<TResult>> actions;
  final _PagedDataTableRowState<TResultId, TResult> model;
  final Function(TResult)? actionsTitle;
  final void Function(bool) onDialogStateChange;

  const _ActionButton({
    required this.iconKey,
    required this.actions,
    required this.model,
    required this.actionsTitle,
    required this.onDialogStateChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showActionsMenu(context),
        child: Container(
          key: iconKey,
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: theme.secondaryText,
          ),
        ),
      ),
    );
  }

  void _showActionsMenu(BuildContext context) async {
    final theme = CLTheme.of(context);
    final RenderBox renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final openUpwards = position.dy + 200 > screenHeight;

    onDialogStateChange(true);

    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, openUpwards ? 0.05 : -0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              right: 50,
              top: !openUpwards ? position.dy + 40 : null,
              bottom: openUpwards ? screenHeight - position.dy + 40 - renderBox.size.height : null,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(Sizes.borderRadius),
                    border: Border.all(color: theme.borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.borderRadius),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.65),
                          decoration: BoxDecoration(
                            color: theme.primaryBackground,
                            border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
                          ),
                          child: Text(
                            actionsTitle?.call(model.item) ?? 'Azioni',
                            style: theme.smallLabel.copyWith(
                              color: theme.secondaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Actions
                        ...actions.asMap().entries.map((entry) {
                          final action = entry.value;
                          final isLast = entry.key == actions.length - 1;

                          return _ActionMenuItem(
                            action: action,
                            model: model,
                            isLast: isLast,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    onDialogStateChange(false);
  }
}

/// Action menu item with hover state
class _ActionMenuItem<TResultId extends Comparable, TResult extends Object> extends StatefulWidget {
  final TableAction<TResult> action;
  final _PagedDataTableRowState<TResultId, TResult> model;
  final bool isLast;

  const _ActionMenuItem({
    required this.action,
    required this.model,
    required this.isLast,
  });

  @override
  State<_ActionMenuItem<TResultId, TResult>> createState() => _ActionMenuItemState<TResultId, TResult>();
}

class _ActionMenuItemState<TResultId extends Comparable, TResult extends Object>
    extends State<_ActionMenuItem<TResultId, TResult>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          widget.action.onTap.call(widget.model.item);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.padding,
            vertical: Sizes.padding * 0.6,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? theme.primary.withValues(alpha: 0.04) : Colors.transparent,
            border: !widget.isLast ? Border(
              bottom: BorderSide(color: theme.borderColor, width: 1),
            ) : null,
          ),
          child: widget.action.content,
        ),
      ),
    );
  }
}

class _RowSelectorCheckbox<TResultId extends Comparable, TResult extends Object> extends HookWidget {
  final bool isSelected;
  final void Function(bool newValue) setSelected;

  const _RowSelectorCheckbox({required this.isSelected, required this.setSelected});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Transform.scale(
      scale: 0.9,
      child: Checkbox(
        value: isSelected,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        activeColor: theme.primary,
        checkColor: Colors.white,
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? theme.primary : theme.borderColor,
            width: states.contains(WidgetState.selected) ? 0 : 1,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        tristate: false,
        onChanged: (newValue) => setSelected(newValue ?? false),
      ),
    );
  }
}
