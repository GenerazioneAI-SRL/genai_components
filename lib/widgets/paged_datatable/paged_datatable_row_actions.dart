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
            border: !widget.isLast
                ? Border(
                    bottom: BorderSide(color: theme.borderColor, width: 1),
                  )
                : null,
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
