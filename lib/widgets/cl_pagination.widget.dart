import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLPagination — paginazione refined editorial Skillera.
///
/// [currentPage]  pagina corrente (0-based)
/// [totalPages]   numero totale di pagine
/// [totalItems]   numero totale di elementi (per l'etichetta info)
/// [onPageChanged] callback quando l'utente cambia pagina
/// [itemLabel]    etichetta singolare/plurale dell'elemento (default 'elementi')
class CLPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final String itemLabel;

  const CLPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    this.itemLabel = 'elementi',
  });

  // Build sequence of page tokens: int = page index, null = ellipsis.
  List<int?> _buildPageTokens() {
    if (totalPages <= 1) return [0];
    const window = 1; // pages around current
    final tokens = <int?>[];
    final last = totalPages - 1;

    // always show first
    tokens.add(0);

    final start = (currentPage - window).clamp(1, last);
    final end = (currentPage + window).clamp(1, last - 1);

    if (start > 1) tokens.add(null); // leading ellipsis

    for (int i = start; i <= end; i++) {
      if (i > 0 && i < last) tokens.add(i);
    }

    if (end < last - 1) tokens.add(null); // trailing ellipsis

    if (last > 0) tokens.add(last);
    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final canPrev = currentPage > 0;
    final canNext = currentPage < totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Info totale (smallLabel mutedForeground) ──
        Flexible(
          child: Text(
            '$totalItems $itemLabel · pag. ${currentPage + 1}/$totalPages',
            style: theme.smallLabel.copyWith(
              color: theme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: CLSizes.gapMd),

        // ── Controlli paginazione ──
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prev
            _PageTile(
              theme: theme,
              enabled: canPrev,
              onTap: canPrev
                  ? () {
                      HapticFeedback.lightImpact();
                      onPageChanged(currentPage - 1);
                    }
                  : null,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                color: canPrev ? theme.primaryText : theme.mutedForeground,
                size: CLSizes.iconSizeCompact,
              ),
            ),
            const SizedBox(width: CLSizes.gapXs),

            // Page tokens
            ..._buildPageTokens().expand((tok) sync* {
              yield tok == null
                  ? _Ellipsis(theme: theme)
                  : _PageTile(
                      theme: theme,
                      enabled: true,
                      selected: tok == currentPage,
                      onTap: tok == currentPage
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              onPageChanged(tok);
                            },
                      child: Text(
                        '${tok + 1}',
                        style: theme.smallText.copyWith(
                          fontSize: 12,
                          fontWeight: tok == currentPage ? FontWeight.w700 : FontWeight.w500,
                          color: tok == currentPage ? Colors.white : theme.primaryText,
                        ),
                      ),
                    );
              yield const SizedBox(width: CLSizes.gapXs);
            }).toList()
              ..removeLast(),

            const SizedBox(width: CLSizes.gapXs),
            // Next
            _PageTile(
              theme: theme,
              enabled: canNext,
              onTap: canNext
                  ? () {
                      HapticFeedback.lightImpact();
                      onPageChanged(currentPage + 1);
                    }
                  : null,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: canNext ? theme.primaryText : theme.mutedForeground,
                size: CLSizes.iconSizeCompact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE TILE — square 32px, hover/selected/disabled states, keyboard
// ═══════════════════════════════════════════════════════════════════════════

class _PageTile extends StatefulWidget {
  final CLTheme theme;
  final bool enabled;
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;

  const _PageTile({
    required this.theme,
    required this.enabled,
    required this.child,
    this.selected = false,
    this.onTap,
  });

  @override
  State<_PageTile> createState() => _PageTileState();
}

class _PageTileState extends State<_PageTile> {
  bool _hovered = false;
  bool _focused = false;

  void _handleKey(KeyEvent ev) {
    if (ev is KeyDownEvent &&
        (ev.logicalKey == LogicalKeyboardKey.enter ||
            ev.logicalKey == LogicalKeyboardKey.space)) {
      if (widget.enabled) widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final disabled = !widget.enabled;

    final Color bg;
    final Color border;
    if (widget.selected) {
      bg = t.primary;
      border = t.primary;
    } else if (_hovered && !disabled) {
      bg = t.muted;
      border = t.borderColor;
    } else {
      bg = Colors.transparent;
      border = t.borderColor;
    }

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(
        minWidth: CLSizes.buttonHeightCompact,
        minHeight: CLSizes.buttonHeightCompact,
      ),
      padding: const EdgeInsets.symmetric(horizontal: CLSizes.gapSm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(CLSizes.radiusControl),
        border: Border.all(
          color: _focused ? t.ring : border,
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: Center(child: widget.child),
    );

    if (disabled) {
      tile = Opacity(opacity: 0.4, child: tile);
    }

    return Focus(
      onKeyEvent: (_, ev) {
        _handleKey(ev);
        return KeyEventResult.ignored;
      },
      onFocusChange: (f) => setState(() => _focused = f),
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : (widget.onTap == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click),
        onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onTap : null,
          child: tile,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ELLIPSIS — three muted dots
// ═══════════════════════════════════════════════════════════════════════════

class _Ellipsis extends StatelessWidget {
  final CLTheme theme;

  const _Ellipsis({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CLSizes.buttonHeightCompact,
      height: CLSizes.buttonHeightCompact,
      child: Center(
        child: Text(
          '···',
          style: theme.smallText.copyWith(
            color: theme.mutedForeground,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
