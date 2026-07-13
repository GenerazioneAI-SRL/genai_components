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
        // ── Sinistra: page size + totale ─────────────────────────
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Range risultati al posto del label "Righe per pagina" (rimosso),
              // come testo semplice (niente pill).
              Flexible(
                child: AnimatedSwitcher(
                  duration: t.durationBase,
                  child: Text(
                    state.totalElement > 0
                        ? '${state.rangeStart} – ${state.rangeEnd} di ${state.totalElement}'
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
              SizedBox(width: t.gapLg),
              _PageSizeControls(
                  pageSizes: pageSizes,
                  currentPageSize: state._pageSize,
                  onChanged: (size) => state.setPageSize(size),
                  theme: t),
            ],
          ),
        ),

        // ── Destra: paginazione ───────────────────────────────────
        _PaginationControls(state: state, theme: t),
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
// PAGE SIZE CONTROLS — segmented control iOS: track pill grigio, segmento
// selezionato pill scuro. Token-only, zero magic number.
// ═══════════════════════════════════════════════════════════════════════════

class _PageSizeControls extends StatelessWidget {
  const _PageSizeControls(
      {required this.pageSizes, required this.currentPageSize, required this.onChanged, required this.theme});

  final List<int> pageSizes;
  final int currentPageSize;
  final void Function(int) onChanged;
  final GenTokens theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: EdgeInsets.all(t.gapXs),
      decoration: BoxDecoration(
        color: t.primaryBackground,
        borderRadius: BorderRadius.circular(t.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final size in pageSizes)
            _PageSizeSegment(
              size: size,
              selected: size == currentPageSize,
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(size);
              },
              theme: t,
            ),
        ],
      ),
    );
  }
}

/// Singolo segmento. Selezionato = pill `secondaryBackground` con label
/// `primaryText`, si auto-inverte tra tema chiaro/scuro.
class _PageSizeSegment extends StatefulWidget {
  final int size;
  final bool selected;
  final VoidCallback onTap;
  final GenTokens theme;

  const _PageSizeSegment({
    required this.size,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_PageSizeSegment> createState() => _PageSizeSegmentState();
}

class _PageSizeSegmentState extends State<_PageSizeSegment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final selected = widget.selected;

    return MouseRegion(
      cursor: selected ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: selected ? null : (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: selected ? null : widget.onTap,
        child: Container(
          height: t.buttonHeightCompact,
          constraints: BoxConstraints(minWidth: t.buttonHeightCompact),
          padding: EdgeInsets.symmetric(horizontal: t.gapMd),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? t.secondaryBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(t.radiusPill),
          ),
          child: Text(
            '${widget.size}',
            style: t.smallLabel.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? t.primaryText : (_hovered ? t.primaryText : t.secondaryText),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGINATION CONTROLS
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
