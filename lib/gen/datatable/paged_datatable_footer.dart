part of 'paged_datatable.dart';

class _PagedDataTableFooter<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  final PagedDataTableThemeData themeData;

  /// Embedded → gutter orizzontale 0 (lo dà la pagina host). Verticale invariato.
  final bool embedded;

  const _PagedDataTableFooter({required this.themeData, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = _isTableCompact(context);
    final vPad = GenTokens.of(context).gapLg;
    final hPad = embedded ? 0.0 : vPad;

    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, _) {
        Widget child = Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: themeData.headerBackgroundColor ?? GenTokens.of(context).primaryBackground,
          ),
          child: isMobile ? _buildMobileFooter(context, state) : _buildDesktopFooter(context, state),
        );

        if (themeData.footerTextStyle != null) {
          child = DefaultTextStyle(style: themeData.footerTextStyle!, child: child);
        }

        return child;
      },
    );
  }

  // ── Desktop ──────────────────────────────────────────────────────────────

  Widget _buildDesktopFooter(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) {
    final t = GenTokens.of(context);
    final pageSizes = themeData.configuration.pageSizes ?? [5, 25, 50, 100];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Sinistra: totale risultati + page size (dropdown) ─────
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Range risultati come testo semplice (niente pill).
              Flexible(
                child: AnimatedSwitcher(
                  duration: t.durationBase,
                  child: Text(
                    state.totalElement > 0
                        ? 'Risultati: ${state.rangeStart} – ${state.rangeEnd} di ${state.totalElement}'
                        : '0 risultati',
                    key: ValueKey('${state.rangeStart}-${state.rangeEnd}-${state.totalElement}'),
                    style: t.smallLabel.copyWith(
                      color: t.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ),
              SizedBox(width: t.gapMd),
              // Dropdown righe-per-pagina (GenSelect).
              GenSelect<int>(
                initialValue: state._pageSize,
                minWidth: 72,
                options: [for (final s in pageSizes) ShadOption<int>(value: s, child: Text('$s'))],
                selectedOptionBuilder: (context, value) => Text('$value'),
                onChanged: (v) {
                  if (v == null) return;
                  HapticFeedback.lightImpact();
                  state.setPageSize(v);
                },
              ),
            ],
          ),
        ),

        // ── Destra: paginazione numerata ──────────────────────────
        _NumberedPagination(state: state, theme: t),
      ],
    );
  }

  // ── Mobile ───────────────────────────────────────────────────────────────

  Widget _buildMobileFooter(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) {
    final t = GenTokens.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: _PaginationControls(state: state, theme: t),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NUMBERED PAGINATION (desktop) — chevron outline · pulsanti pagina numerati
// (corrente = primary pieno, altre = outline) · ellissi per range lunghi.
// Tutto con componenti Gen (GenIconButton/GenButton).
// ═══════════════════════════════════════════════════════════════════════════

class _NumberedPagination<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  const _NumberedPagination({required this.state, required this.theme});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final GenTokens theme;

  /// Finestra di pagine da mostrare (0-based). `null` = ellissi. Fino a 7 pagine
  /// le mostra tutte; oltre, comprime con prima/ultima + intorno alla corrente.
  List<int?> _pageWindow(int current, int count) {
    if (count <= 7) return [for (var i = 0; i < count; i++) i];
    const window = 1; // pagine a sinistra/destra della corrente
    final left = max(1, current - window);
    final right = min(count - 2, current + window);
    return [
      0,
      if (left > 1) null,
      for (var i = left; i <= right; i++) i,
      if (right < count - 2) null,
      count - 1,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final loading = state.tableState == _TableState.loading;
    final canPrev = state.hasPreviousPage && !loading;
    final canNext = state.hasNextPage && !loading;
    final pageSize = state._pageSize;
    final total = state.totalElement;
    final current = state.currentPage; // 0-based
    // Numero pagine dal totale; fallback (paginazione a cursore senza totale):
    // corrente + 1, + un'altra se c'è next.
    final pageCount =
        total > 0 && pageSize > 0 ? (total / pageSize).ceil() : (current + (canNext ? 2 : 1));
    final pages = _pageWindow(current, pageCount);

    Widget navBtn(IconData icon, bool enabled, VoidCallback onTap) => GenIconButton.outline(
          icon: Icon(icon, size: t.iconSizeCompact),
          iconSize: t.iconSizeCompact,
          width: t.buttonHeightCompact,
          height: t.buttonHeightCompact,
          onPressed: enabled ? onTap : null,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        navBtn(LucideIcons.chevronLeft, canPrev, () {
          HapticFeedback.lightImpact();
          state.previousPage();
        }),
        SizedBox(width: t.gapXs),
        for (final p in pages) ...[
          if (p == null)
            SizedBox(
              width: t.buttonHeightCompact,
              height: t.buttonHeightCompact,
              child: Center(child: Text('…', style: t.smallLabel.copyWith(color: t.secondaryText))),
            )
          else
            _PageNumberButton(
              page: p,
              selected: p == current,
              theme: t,
              onTap: () {
                if (p == current) return;
                HapticFeedback.lightImpact();
                state.goToPage(p);
              },
            ),
          SizedBox(width: t.gapXs),
        ],
        navBtn(LucideIcons.chevronRight, canNext, () {
          HapticFeedback.lightImpact();
          state.nextPage();
        }),
      ],
    );
  }
}

/// Pulsante pagina numerato (quadrato compatto). Corrente = [GenButton] primary
/// pieno; le altre = [GenButton.outline].
class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({required this.page, required this.selected, required this.onTap, required this.theme});

  final int page;
  final bool selected;
  final VoidCallback onTap;
  final GenTokens theme;

  @override
  Widget build(BuildContext context) {
    final side = theme.buttonHeightCompact;
    final label = Text('${page + 1}');
    if (selected) {
      return GenButton(
        onPressed: onTap,
        width: side,
        height: side,
        padding: EdgeInsets.zero,
        child: label,
      );
    }
    return GenButton.outline(
      onPressed: onTap,
      width: side,
      height: side,
      padding: EdgeInsets.zero,
      child: label,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGINATION CONTROLS (mobile) — pill compatto prev/pagina/next.
// ═══════════════════════════════════════════════════════════════════════════

class _PaginationControls<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  const _PaginationControls({required this.state, required this.theme});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final GenTokens theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final canPrev = state.hasPreviousPage && state.tableState != _TableState.loading;
    final canNext = state.hasNextPage && state.tableState != _TableState.loading;

    // Stesso linguaggio del segmented page-size: track `muted`, pagina corrente
    // = pill `secondaryBackground`, chevron come segmenti inattivi.
    return Container(
      padding: EdgeInsets.all(t.gapXs),
      decoration: BoxDecoration(
        color: t.primaryBackground,
        borderRadius: BorderRadius.circular(t.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Prev ───────────────────────────────────────────────
          _PaginationButton(
            onTap: canPrev
                ? () {
                    HapticFeedback.lightImpact();
                    state.previousPage();
                  }
                : null,
            enabled: canPrev,
            theme: t,
            child: Icon(LucideIcons.chevronLeft,
                color: canPrev ? t.primaryText : t.mutedForeground, size: t.iconSizeCompact),
          ),
          SizedBox(width: t.gapXs),

          // ── Pagina corrente (solo indicatore, non cliccabile) ───
          Container(
            height: t.buttonHeightCompact,
            constraints: BoxConstraints(minWidth: t.buttonHeightCompact),
            padding: EdgeInsets.symmetric(horizontal: t.gapMd),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: t.durationBase,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                '${state.currentPage + 1}',
                key: ValueKey<int>(state.currentPage),
                style: t.smallLabel.copyWith(fontWeight: FontWeight.w600, color: t.primaryText),
              ),
            ),
          ),
          SizedBox(width: t.gapXs),

          // ── Next ────────────────────────────────────────────────
          _PaginationButton(
            onTap: canNext
                ? () {
                    HapticFeedback.lightImpact();
                    state.nextPage();
                  }
                : null,
            enabled: canNext,
            theme: t,
            child: Icon(LucideIcons.chevronRight,
                color: canNext ? t.primaryText : t.mutedForeground, size: t.iconSizeCompact),
          ),
        ],
      ),
    );
  }
}

/// Pagination button: pill bianco persistente quando cliccabile (è un bottone).
/// Disabilitato = nessun pill, solo chevron muted.
class _PaginationButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final GenTokens theme;
  final Widget child;

  const _PaginationButton({
    required this.onTap,
    required this.enabled,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: theme.buttonHeightCompact,
          height: theme.buttonHeightCompact,
          decoration: BoxDecoration(
            color: enabled ? theme.secondaryBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(theme.radiusPill),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
