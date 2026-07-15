part of 'paged_datatable.dart';

/// Action button (kebab) shown at the end of a row. Il tap apre un
/// [GenContextMenu] (ShadContextMenu) ancorato al bottone con le azioni riga.
class _ActionButton<TResultId extends Comparable, TResult extends Object> extends StatefulWidget {
  final List<TableAction<TResult>> actions;
  final _PagedDataTableRowState<TResultId, TResult> model;

  const _ActionButton({required this.actions, required this.model});

  @override
  State<_ActionButton<TResultId, TResult>> createState() => _ActionButtonState<TResultId, TResult>();
}

class _ActionButtonState<TResultId extends Comparable, TResult extends Object>
    extends State<_ActionButton<TResultId, TResult>> {
  final GenPopoverController _menu = GenPopoverController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    // Menu ancorato: menu.topRight su bottone.bottomRight → scende sotto, allineato
    // a destra (ShadAnchor ha i nomi invertiti: childAlignment = punto sul menu,
    // overlayAlignment = punto sul bottone).
    return GenContextMenu(
      controller: _menu,
      anchor: const GenAnchor(
        childAlignment: Alignment.topRight,
        overlayAlignment: Alignment.bottomRight,
        offset: Offset(0, GenSizes.gapXs),
      ),
      items: [
        for (final a in widget.actions)
          GenContextMenuItem(
            onPressed: () {
              _menu.hide();
              a.onTap(widget.model.item);
            },
            child: a.content,
          ),
      ],
      child: GenIconButton.ghost(
        onPressed: _menu.toggle,
        icon: Icon(Icons.more_vert_rounded, color: theme.secondaryText),
        iconSize: theme.iconSizeCompact,
        width: theme.buttonHeightCompact,
        height: theme.buttonHeightCompact,
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
    return GenCheckbox(
      value: isSelected,
      onChanged: (v) => setSelected(v),
    );
  }
}
