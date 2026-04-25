part of 'paged_datatable.dart';

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

  Future<void> _handleTap() async {
    HapticFeedback.selectionClick();
    final hasExpandedBuilder = widget.expandedRowBuilder != null;
    if (hasExpandedBuilder) {
      if (_isExpanded) {
        setState(() => _isExpanded = false);
      } else {
        setState(() {
          _isExpanded = true;
          _isLoadingExpanded = true;
        });
        if (widget.onRowExpanded != null) {
          await widget.onRowExpanded!(widget.model.item);
        }
        if (mounted) setState(() => _isLoadingExpanded = false);
      }
    }
    widget.onItemTap?.call(widget.model.item);
  }

  ({Color rowColor, Color leftBorderColor, double leftBorderWidth}) _resolveRowDecoration(CLTheme theme, bool isSelected) {
    if (isSelected) {
      return (
        rowColor: theme.primary.withValues(alpha: 0.08),
        leftBorderColor: theme.primary,
        leftBorderWidth: 2.5,
      );
    }
    if (_isHovered) {
      return (
        rowColor: theme.primaryText.withValues(alpha: 0.025),
        leftBorderColor: theme.primary.withValues(alpha: 0.3),
        leftBorderWidth: 2.5,
      );
    }
    return (
      rowColor: Colors.transparent,
      leftBorderColor: Colors.transparent,
      leftBorderWidth: 2.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey iconKey = GlobalKey();
    final model = widget.model;
    final state = widget.state;
    final theme = CLTheme.of(context);
    final actions = widget.actionsBuilder?.call(model.item) ?? widget.tableActions;
    final showControls = _isHovered || model._isSelected || _isDialogOpen;
    final hasExpandedBuilder = widget.expandedRowBuilder != null;
    final isSelected = model._isSelected;
    final deco = _resolveRowDecoration(theme, isSelected);

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
            onTap: _handleTap,
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
                  color: deco.rowColor,
                  border: Border(
                    left: BorderSide(
                      color: deco.leftBorderColor,
                      width: deco.leftBorderWidth,
                    ),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasExpandedBuilder)
                        _ExpandIcon(isExpanded: _isExpanded, theme: theme),
                      if (widget.rowsSelectable)
                        _RowSelectionCell<TKey, TResultId, TResult>(
                          model: model,
                          state: state,
                          visible: showControls || isSelected,
                        ),
                      ...state.columns.map(
                        (column) => _DataTableCell<TResultId, TResult>(
                          column: column,
                          model: model,
                          width: column.sizeFactor == null ? state._nullSizeFactorColumnsWidth : widget.width * column.sizeFactor!,
                        ),
                      ),
                      const Spacer(),
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
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: _isExpanded && hasExpandedBuilder
              ? _ExpandedRowContent(
                  isLoading: _isLoadingExpanded,
                  rowsSelectable: widget.rowsSelectable,
                  child: widget.expandedRowBuilder!(context, model.item),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ExpandIcon extends StatelessWidget {
  final bool isExpanded;
  final CLTheme theme;

  const _ExpandIcon({required this.isExpanded, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Sizes.padding - 2.5),
      child: SizedBox(
        width: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedRotation(
            turns: isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isExpanded ? theme.primary : theme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowSelectionCell<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final _PagedDataTableRowState<TResultId, TResult> model;
  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final bool visible;

  const _RowSelectionCell({required this.model, required this.state, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Sizes.padding - 2.5),
      child: SizedBox(
        width: 32,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: visible ? 1.0 : 0.0,
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
    );
  }
}

class _DataTableCell<TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final BaseTableColumn<TResult> column;
  final _PagedDataTableRowState<TResultId, TResult> model;
  final double width;

  const _DataTableCell({required this.column, required this.model, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.75),
      width: width,
      child: Align(
        alignment: column.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: column.buildCell(model.item, model.index),
      ),
    );
  }
}

class _ExpandedRowContent extends StatelessWidget {
  final bool isLoading;
  final bool rowsSelectable;
  final Widget child;

  const _ExpandedRowContent({required this.isLoading, required this.rowsSelectable, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.5),
        border: Border(
          left: BorderSide(color: theme.primary.withValues(alpha: 0.4), width: 2.5),
          bottom: BorderSide(color: theme.borderColor, width: 1),
        ),
      ),
      margin: EdgeInsets.only(left: rowsSelectable ? 56 : 0),
      padding: const EdgeInsets.all(Sizes.padding),
      child: isLoading
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
          : child,
    );
  }
}
