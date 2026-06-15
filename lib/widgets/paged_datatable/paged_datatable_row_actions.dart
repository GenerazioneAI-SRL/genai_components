part of 'paged_datatable.dart';

/// Action button (kebab menu) shown at the end of a row.
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
        borderRadius: BorderRadius.circular(theme.radiusControl),
        hoverColor: theme.muted,
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
    // Popover unificato (CLPopupMenu): stile "Altre azioni" + hairline divider.
    onDialogStateChange(true);
    await CLPopupMenu.show(
      context: context,
      anchorKey: iconKey,
      title: actionsTitle?.call(model.item) ?? 'Azioni',
      items: actions
          .map((a) => CLPopupMenuItem(content: a.content, onTap: () => a.onTap(model.item)))
          .toList(),
    );
    onDialogStateChange(false);
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
        activeColor: _effectiveTablePrimary(context),
        checkColor: Colors.white,
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? _effectiveTablePrimary(context) : theme.borderColor,
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
