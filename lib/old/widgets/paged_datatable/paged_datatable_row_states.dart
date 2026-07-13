part of 'paged_datatable.dart';

/// Shimmer placeholder rows shown during initial load.
class _ShimmerRows<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final int itemCount;
  final bool rowsSelectable;
  final bool hasExpandIcon;
  final double actionsColumnWidth;

  const _ShimmerRows({
    required this.state,
    required this.itemCount,
    required this.rowsSelectable,
    required this.hasExpandIcon,
    required this.actionsColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final clTheme = CLTheme.of(context);
    final m = PagedDataTableRowMetrics.of(context);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      separatorBuilder: (_, __) => Divider(height: 0, color: clTheme.borderColor, thickness: 1),
      itemBuilder: (context, index) {
        final widthMultiplier = [0.7, 0.5, 0.85, 0.6, 0.75][index % 5];
        return Container(
          height: 52,
          padding: EdgeInsets.only(left: m.leftBorderWidth),
          child: Row(
            children: [
              if (hasExpandIcon)
                Padding(
                  padding: EdgeInsets.only(left: m.expandLeftPad),
                  child: SizedBox(width: m.expandSlot),
                ),
              if (rowsSelectable)
                Padding(
                  padding: EdgeInsets.only(left: m.checkboxLeftPad),
                  child: SizedBox(
                    width: m.checkboxSlot,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CLShimmer(width: 18, height: 18, borderRadius: Sizes.radiusChip),
                    ),
                  ),
                ),
              ...List.generate(state.columns.length, (colIndex) {
                final col = state.columns[colIndex];
                final factor = col.sizeFactor ?? (1.0 / state.columns.length);
                return Expanded(
                  flex: (factor * 100).round(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.gapLg, vertical: Sizes.verticalPadding),
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
              SizedBox(width: actionsColumnWidth),
            ],
          ),
        );
      },
    );
  }
}

/// Empty state shown when there are no items.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
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
                color: _effectiveTablePrimary(context).withValues(alpha: theme.opacitySubtle),
                borderRadius: BorderRadius.circular(Sizes.radiusCard),
                border: Border.all(color: _effectiveTablePrimary(context).withValues(alpha: theme.opacitySoft)),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 28,
                color: _effectiveTablePrimary(context).withValues(alpha: theme.opacityDisabled),
              ),
            ),
            const SizedBox(height: Sizes.padding),
            Text(
              'Nessun elemento trovato',
              style: theme.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
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
}

/// Error state shown when the table fails to load.
class _ErrorState extends StatelessWidget {
  final dynamic error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
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
                borderRadius: BorderRadius.circular(Sizes.radiusCard),
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
