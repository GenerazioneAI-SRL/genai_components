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
    final theme = GenTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.radiusControl),
        hoverColor: theme.muted,
        onTap: () => _showActionsMenu(context),
        child: Container(
          key: iconKey,
          padding: EdgeInsets.all(GenSizes.gapSm),
          child: Icon(
            Icons.more_vert_rounded,
            size: theme.iconSizeCompact,
            color: theme.secondaryText,
          ),
        ),
      ),
    );
  }

  void _showActionsMenu(BuildContext context) async {
    // Popover unificato (GenPopupMenu): stile "Altre azioni" + hairline divider.
    onDialogStateChange(true);
    await GenPopupMenu.show(
      context: context,
      anchorKey: iconKey,
      title: actionsTitle?.call(model.item) ?? 'Azioni',
      items: actions
          .map((a) => GenPopupMenuItem(content: a.content, onTap: () => a.onTap(model.item)))
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
    return GenCheckbox(
      value: isSelected,
      onChanged: (v) => setSelected(v),
    );
  }
}
