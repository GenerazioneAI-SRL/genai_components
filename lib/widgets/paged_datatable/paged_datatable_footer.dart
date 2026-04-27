part of 'paged_datatable.dart';

class _PagedDataTableFooter<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final PagedDataTableThemeData themeData;

  const _PagedDataTableFooter({required this.themeData});

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final hPadding = Sizes.padding;

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
            const SizedBox(width: Sizes.padding),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.primaryText.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
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
                color: t.primaryText.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
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
    return Container(
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(CLSizes.radiusControl), border: Border.all(color: t.borderColor, width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageSizes.length, (i) {
          final size = pageSizes[i];
          final selected = size == currentPageSize;
          final isFirst = i == 0;
          final isLast = i == pageSizes.length - 1;

          return _PageSizeButton(
            size: size,
            selected: selected,
            isFirst: isFirst,
            isLast: isLast,
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(size);
            },
            theme: t,
          );
        }),
      ),
    );
  }
}

/// Individual page size button with hover state
class _PageSizeButton extends StatefulWidget {
  final int size;
  final bool selected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final CLTheme theme;

  const _PageSizeButton({
    required this.size,
    required this.selected,
    required this.isFirst,
    required this.isLast,
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
                ? t.primary.withValues(alpha: 0.12)
                : _isHovered
                    ? t.primary.withValues(alpha: 0.04)
                    : Colors.transparent,
            border: !widget.isFirst ? Border(left: BorderSide(color: t.borderColor, width: 1)) : null,
          ),
          child: Center(
            child: Text(
              '${widget.size}',
              style: t.smallLabel.copyWith(
                fontSize: 12,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.normal,
                color: widget.selected ? t.primary : (_isHovered ? t.primaryText : t.secondaryText),
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
    final canPrev = state.hasPreviousPage && state.tableState != _TableState.loading;
    final canNext = state.hasNextPage && state.tableState != _TableState.loading;

    return Container(
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(CLSizes.radiusControl), border: Border.all(color: t.borderColor, width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Prev ───────────────────────────────────────────────
          _PaginationButton(
            onTap: canPrev ? () {
              HapticFeedback.lightImpact();
              state.previousPage();
            } : null,
            enabled: canPrev,
            isFirst: true,
            theme: t,
            child: Icon(LucideIcons.chevronLeft, color: canPrev ? t.primaryText : t.secondaryText.withValues(alpha: 0.3), size: 15),
          ),

          // ── Pagina corrente ─────────────────────────────────────
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: t.borderColor, width: 1),
              ),
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
                  style: t.smallLabel.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: t.primaryText),
                ),
              ),
            ),
          ),

          // ── Next ────────────────────────────────────────────────
          _PaginationButton(
            onTap: canNext ? () {
              HapticFeedback.lightImpact();
              state.nextPage();
            } : null,
            enabled: canNext,
            isFirst: false,
            theme: t,
            child: Icon(LucideIcons.chevronRight, color: canNext ? t.primaryText : t.secondaryText.withValues(alpha: 0.3), size: 15),
          ),
        ],
      ),
    );
  }
}

/// Pagination button with hover state
class _PaginationButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final bool isFirst;
  final CLTheme theme;
  final Widget child;

  const _PaginationButton({
    required this.onTap,
    required this.enabled,
    required this.isFirst,
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
    final t = widget.theme;

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
            color: _isHovered && widget.enabled
                ? t.primary.withValues(alpha: 0.06)
                : Colors.transparent,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
