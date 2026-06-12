part of 'paged_datatable.dart';

class _PagedDataTableFooter<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final PagedDataTableThemeData themeData;

  const _PagedDataTableFooter({required this.themeData});

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final hPadding = CLTheme.of(context).pagePadX;

    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, child) {
        Widget child = Container(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: hPadding * 0.65),
          decoration: BoxDecoration(
            color: themeData.headerBackgroundColor ?? CLTheme.of(context).primaryBackground,
            border: Border(top: BorderSide(color: CLTheme.of(context).borderColor, width: 1)),
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
    final t = CLTheme.of(context);
    final pageSizes = themeData.configuration.pageSizes ?? [5, 25, 50, 100];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Sinistra: page size + totale ─────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Righe per pagina:', style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 12)),
            const SizedBox(width: 10),
            _PageSizeControls(pageSizes: pageSizes, currentPageSize: state._pageSize, onChanged: (size) => state.setPageSize(size), theme: t),
            SizedBox(width: CLTheme.of(context).pagePadX),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.muted,
                borderRadius: BorderRadius.circular(t.radiusControl),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  state.totalElement > 0
                      ? '${state.rangeStart}–${state.rangeEnd} di ${state.totalElement}'
                      : '0 risultati',
                  key: ValueKey('${state.rangeStart}-${state.rangeEnd}-${state.totalElement}'),
                  style: t.smallLabel.copyWith(
                    color: t.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Destra: paginazione ───────────────────────────────────
        _PaginationControls(state: state, theme: t),
      ],
    );
  }

  // ── Mobile ───────────────────────────────────────────────────────────────

  Widget _buildMobileFooter(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) {
    final t = CLTheme.of(context);
    final pageSizes = themeData.configuration.pageSizes ?? [5, 25, 50, 100];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Riga 1: page size + totale ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Righe:', style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 11)),
                const SizedBox(width: 6),
                _PageSizeControls(pageSizes: pageSizes, currentPageSize: state._pageSize, onChanged: (size) => state.setPageSize(size), theme: t),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: t.muted,
                borderRadius: BorderRadius.circular(t.radiusControl),
              ),
              child: Text(
                state.totalElement > 0
                    ? '${state.rangeStart}–${state.rangeEnd} di ${state.totalElement}'
                    : '0 risultati',
                style: t.smallLabel.copyWith(fontWeight: FontWeight.w500, fontSize: 11, color: t.secondaryText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ── Riga 2: paginazione centrata ──────────────────────────
        Center(
          child: _PaginationControls(state: state, theme: t),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE SIZE CONTROLS — bottoni stile paginazione, nessun overlay
// ═══════════════════════════════════════════════════════════════════════════

class _PageSizeControls extends StatelessWidget {
  const _PageSizeControls({required this.pageSizes, required this.currentPageSize, required this.onChanged, required this.theme});

  final List<int> pageSizes;
  final int currentPageSize;
  final void Function(int) onChanged;
  final CLTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    // Plain: nessun box bordato, solo l'elemento selezionato ha fill tinted.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < pageSizes.length; i++) ...[
          if (i > 0) SizedBox(width: t.gapXs),
          _PageSizeButton(
            size: pageSizes[i],
            selected: pageSizes[i] == currentPageSize,
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(pageSizes[i]);
            },
            theme: t,
          ),
        ],
      ],
    );
  }
}

/// Individual page size button with hover state
class _PageSizeButton extends StatefulWidget {
  final int size;
  final bool selected;
  final VoidCallback onTap;
  final CLTheme theme;

  const _PageSizeButton({
    required this.size,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_PageSizeButton> createState() => _PageSizeButtonState();
}

class _PageSizeButtonState extends State<_PageSizeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final primary = _effectiveTablePrimary(context);

    return MouseRegion(
      cursor: widget.selected ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: widget.selected ? null : (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.selected ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          constraints: const BoxConstraints(minWidth: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.selected
                ? primary.withValues(alpha: 0.1)
                : _isHovered
                    ? t.muted
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(t.radiusControl),
          ),
          child: Center(
            child: Text(
              '${widget.size}',
              style: t.smallLabel.copyWith(
                fontSize: 12,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.normal,
                color: widget.selected ? primary : (_isHovered ? t.primaryText : t.secondaryText),
              ),
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

class _PaginationControls<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  const _PaginationControls({required this.state, required this.theme});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final CLTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final primary = _effectiveTablePrimary(context);
    final canPrev = state.hasPreviousPage && state.tableState != _TableState.loading;
    final canNext = state.hasNextPage && state.tableState != _TableState.loading;

    // Plain: niente box bordato; solo la pagina corrente ha fill tinted primary.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Prev ───────────────────────────────────────────────
        _PaginationButton(
          onTap: canPrev ? () {
            HapticFeedback.lightImpact();
            state.previousPage();
          } : null,
          enabled: canPrev,
          theme: t,
          child: Icon(LucideIcons.chevronLeft, color: canPrev ? t.secondaryText : t.secondaryText.withValues(alpha: 0.3), size: 15),
        ),
        SizedBox(width: t.gapXs),

        // ── Pagina corrente ─────────────────────────────────────
        Container(
          height: 36,
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(t.radiusControl),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
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
                style: t.smallLabel.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: primary),
              ),
            ),
          ),
        ),
        SizedBox(width: t.gapXs),

        // ── Next ────────────────────────────────────────────────
        _PaginationButton(
          onTap: canNext ? () {
            HapticFeedback.lightImpact();
            state.nextPage();
          } : null,
          enabled: canNext,
          theme: t,
          child: Icon(LucideIcons.chevronRight, color: canNext ? t.secondaryText : t.secondaryText.withValues(alpha: 0.3), size: 15),
        ),
      ],
    );
  }
}

/// Pagination button with hover state
class _PaginationButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final CLTheme theme;
  final Widget child;

  const _PaginationButton({
    required this.onTap,
    required this.enabled,
    required this.theme,
    required this.child,
  });

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isHovered && widget.enabled ? widget.theme.muted : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.theme.radiusControl),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
