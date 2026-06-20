part of 'paged_datatable.dart';

class _HoverableRow<TKey extends Comparable, TResultId extends Comparable,
    TResult extends Object> extends StatefulWidget {
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
  State<_HoverableRow<TKey, TResultId, TResult>> createState() =>
      _HoverableRowState<TKey, TResultId, TResult>();
}

class _HoverableRowState<TKey extends Comparable, TResultId extends Comparable,
        TResult extends Object>
    extends State<_HoverableRow<TKey, TResultId, TResult>>
    with SingleTickerProviderStateMixin {
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

  ({Color rowColor, Color leftBorderColor}) _resolveRowDecoration(
    CLTheme theme,
    Color primary,
    bool isSelected,
  ) {
    if (isSelected) {
      return (
        rowColor: primary.withValues(alpha: 0.08),
        leftBorderColor: primary,
      );
    }
    if (_isHovered) {
      return (
        rowColor: theme.primaryText.withValues(alpha: 0.025),
        leftBorderColor: primary,
      );
    }
    return (
      rowColor: Colors.transparent,
      leftBorderColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey iconKey = GlobalKey();
    final model = widget.model;
    final state = widget.state;
    final theme = CLTheme.of(context);
    final m = PagedDataTableRowMetrics.of(context);
    final allActions =
        widget.actionsBuilder?.call(model.item) ?? widget.tableActions;
    final inlineActions = allActions.where((a) => a.inline).toList();
    final actions = allActions.where((a) => !a.inline).toList();
    // Mobile: le azioni inline NON si mostrano nella riga, si rivelano con lo
    // swipe a sinistra (_SwipeActionsReveal). Desktop/tablet: inline invariate.
    final useSwipe = _isTableCompact(context) && inlineActions.isNotEmpty;
    final hasExpandedBuilder = widget.expandedRowBuilder != null;
    final isSelected = model._isSelected;
    final tablePrimary = _effectiveTablePrimary(context);
    final deco = _resolveRowDecoration(theme, tablePrimary, isSelected);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: widget.onItemTap != null || hasExpandedBuilder
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => _safeSetState(() => _isHovered = true),
          onExit: (_) => _safeSetState(() {
            if (!_isDialogOpen) _isHovered = false;
          }),
          child: _wrapRow(
            useSwipe: useSwipe,
            inlineActions: inlineActions,
            rowVisual: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 52),
              width: double.infinity,
              decoration: BoxDecoration(
                color: deco.rowColor,
                border: Border(
                  left: BorderSide(
                    color: deco.leftBorderColor,
                    width: m.leftBorderWidth,
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
                        visible: true,
                      ),
                    ...state.columns.map(
                      (column) => _DataTableCell<TResultId, TResult>(
                        column: column,
                        model: model,
                        width: column.sizeFactor == null
                            ? state._nullSizeFactorColumnsWidth
                            : widget.width * column.sizeFactor!,
                      ),
                    ),
                    const Spacer(),
                    if (!useSwipe && inlineActions.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < inlineActions.length; i++) ...[
                            if (i > 0) SizedBox(width: m.gap),
                            _InlineActionButton<TResultId, TResult>(
                              action: inlineActions[i],
                              model: model,
                            ),
                          ],
                        ],
                      ),
                    if (actions.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          left: inlineActions.isNotEmpty
                              ? m.popupLeftGapWithInline
                              : 0,
                          right: m.popupRightGap,
                        ),
                        child: SizedBox(
                          width: m.popupButtonSlot,
                          child: Center(
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
                      )
                    else if (inlineActions.isNotEmpty)
                      SizedBox(width: m.popupRightGap),
                  ],
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

  /// Avvolge il visual della riga: su mobile (useSwipe) lo swipe-reveal possiede
  /// tap + drag; su desktop/tablet il GestureDetector classico (tap + press-scale).
  Widget _wrapRow({
    required bool useSwipe,
    required List<TableAction<TResult>> inlineActions,
    required Widget rowVisual,
  }) {
    if (useSwipe) {
      return _SwipeActionsReveal<TResultId, TResult>(
        actions: inlineActions,
        model: widget.model,
        onTap: _handleTap,
        child: rowVisual,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.995 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: rowVisual,
      ),
    );
  }
}

class _ExpandIcon extends StatelessWidget {
  final bool isExpanded;
  final CLTheme theme;

  const _ExpandIcon({required this.isExpanded, required this.theme});

  @override
  Widget build(BuildContext context) {
    final m = PagedDataTableRowMetrics.of(context);
    return Padding(
      padding: EdgeInsets.only(left: m.expandLeftPad),
      child: SizedBox(
        width: m.expandSlot,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedRotation(
            turns: isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isExpanded
                  ? _effectiveTablePrimary(context)
                  : theme.secondaryText.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowSelectionCell<TKey extends Comparable, TResultId extends Comparable,
    TResult extends Object> extends StatelessWidget {
  final _PagedDataTableRowState<TResultId, TResult> model;
  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final bool visible;

  const _RowSelectionCell(
      {required this.model, required this.state, required this.visible});

  @override
  Widget build(BuildContext context) {
    final m = PagedDataTableRowMetrics.of(context);
    return Padding(
      // Slot centered on the search-field prefix-icon center (see metrics).
      padding: EdgeInsets.only(left: m.checkboxLeftPad),
      child: SizedBox(
        width: m.checkboxSlot,
        child: Align(
          alignment: Alignment.center,
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

class _DataTableCell<TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  final BaseTableColumn<TResult> column;
  final _PagedDataTableRowState<TResultId, TResult> model;
  final double width;

  const _DataTableCell(
      {required this.column, required this.model, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: CLTheme.of(context).gapLg,
          vertical: CLTheme.of(context).pagePadX * 0.75),
      width: width,
      child: Align(
        alignment:
            column.isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: column.buildCell(model.item, model.index),
      ),
    );
  }
}

class _ExpandedRowContent extends StatelessWidget {
  final bool isLoading;
  final bool rowsSelectable;
  final Widget child;

  const _ExpandedRowContent(
      {required this.isLoading,
      required this.rowsSelectable,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final m = PagedDataTableRowMetrics.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.5),
        border: Border(
          left: BorderSide(
              color: _effectiveTablePrimary(context).withValues(alpha: 0.4),
              width: m.leftBorderWidth),
          bottom: BorderSide(color: theme.borderColor, width: 1),
        ),
      ),
      margin: EdgeInsets.only(
          left: rowsSelectable ? m.checkboxAreaWidth + m.leftBorderWidth : 0),
      padding: EdgeInsets.all(theme.pagePadX),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.all(theme.pagePadX),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _effectiveTablePrimary(context),
                  ),
                ),
              ),
            )
          : child,
    );
  }
}

/// Inline action rendered in a row as a `CLIconButton` muted tondo — stesso
/// linguaggio del pulsante "Cambia azienda" (fill `muted`, icona `primaryText`,
/// size compact da `m.inlineButtonSide`, raggio pill). Used when `TableAction.inline == true`.
/// L'icona usa il colore semantico se dichiarato (`action.color`,
/// es. `theme.danger` per "Elimina" → icona rossa), altrimenti `primaryText`.
class _InlineActionButton<TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  final TableAction<TResult> action;
  final _PagedDataTableRowState<TResultId, TResult> model;

  const _InlineActionButton({required this.action, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final m = PagedDataTableRowMetrics.of(context);
    final semantic = action.color;
    final iconColor = (semantic == null || semantic == theme.primary)
        ? theme.primaryText
        : semantic;

    // size from the SAME metric the reservation math uses (reserve == render).
    return CLIconButton(
      onTap: () => action.onTap(model.item),
      iconData: action.icon,
      backgroundColor: theme.muted,
      iconColor: iconColor,
      size: m.inlineButtonSide,
      iconSize: theme.iconSizeCompact,
      tooltip: action.label,
    );
  }
}

/// Swipe-to-reveal delle azioni di riga su mobile (stile chat). Swipe a sinistra
/// rivela i bottoni [actions] sulla destra; restano aperti (reveal + tap). Tap su
/// un bottone esegue e richiude; tap sulla riga: chiusa → [onTap] (naviga),
/// aperta → richiude. Usato SOLO su breakpoint compact (vedi `_isTableCompact`);
/// su desktop/tablet i bottoni inline restano renderizzati nella riga.
class _SwipeActionsReveal<TResultId extends Comparable, TResult extends Object>
    extends StatefulWidget {
  const _SwipeActionsReveal({
    required this.child,
    required this.actions,
    required this.model,
    required this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final List<TableAction<TResult>> actions;
  final _PagedDataTableRowState<TResultId, TResult> model;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_SwipeActionsReveal<TResultId, TResult>> createState() =>
      _SwipeActionsRevealState<TResultId, TResult>();
}

class _SwipeActionsRevealState<TResultId extends Comparable,
        TResult extends Object>
    extends State<_SwipeActionsReveal<TResultId, TResult>>
    with SingleTickerProviderStateMixin {
  // value 0 = chiuso · 1 = aperto (azioni rivelate).
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  // Tile azione quadrato (icona + testo in colonna), stile swipe iOS/chat.
  static const double _tileSize = 64;

  bool get _isOpen => _ctrl.value > 0.5;
  void _open() => _ctrl.animateTo(1, curve: Curves.easeOut);
  void _close() => _ctrl.animateTo(0, curve: Curves.easeOut);

  double _revealWidth(PagedDataTableRowMetrics m) {
    // n tile a contatto (no gap, no padding esterno): full-bleed fino al bordo.
    return widget.actions.length * _tileSize;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final m = PagedDataTableRowMetrics.of(context);
    final revealW = _revealWidth(m);

    return ClipRect(
      child: AnimatedBuilder(
        animation: _ctrl,
        // child (la riga) NON viene ricostruito a ogni tick.
        child: widget.child,
        builder: (context, child) {
          return Stack(
            children: [
              // Sfondo: tile azione a contatto, allineati a destra e full-height
              // (crossAxisAlignment.stretch), a filo del bordo.
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final a in widget.actions) _revealTile(theme, a),
                  ],
                ),
              ),
              // Primo piano: la riga, traslata di -revealW*value. Drag + tap.
              Transform.translate(
                offset: Offset(-revealW * _ctrl.value, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) {
                    _ctrl.value = (_ctrl.value - d.primaryDelta! / revealW)
                        .clamp(0.0, 1.0);
                  },
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v < -300) {
                      _open();
                    } else if (v > 300) {
                      _close();
                    } else {
                      _ctrl.value > 0.5 ? _open() : _close();
                    }
                  },
                  onTap: () => _isOpen ? _close() : widget.onTap(),
                  onLongPress: _isOpen ? null : widget.onLongPress,
                  // Fill opaco = superficie tabella: copre i bottoni rivelati
                  // quando è chiuso (la tint hover/selected resta sopra).
                  child: ColoredBox(
                    color: theme.secondaryBackground,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Tile azione quadrato grigio: icona sopra, label sotto. L'icona/testo usano
  /// il colore semantico se dichiarato (`action.color`, es. danger per Elimina).
  Widget _revealTile(CLTheme theme, TableAction<TResult> a) {
    final semantic = a.color;
    final fg = (semantic == null || semantic == theme.primary)
        ? theme.primaryText
        : semantic;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _close();
        a.onTap(widget.model.item);
      },
      child: Container(
        // Larghezza fissa; altezza = stretch alla riga (full-height, no raggio).
        width: _tileSize,
        alignment: Alignment.center,
        color: a.backgroundColor ?? theme.muted,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(a.icon, size: theme.iconSizeDefault, color: fg),
            if (a.label != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  a.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.smallLabel.copyWith(
                      color: fg, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
