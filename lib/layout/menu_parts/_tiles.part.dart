part of '../menu.layout.dart';

/// Voce di menu principale con pill indicatore, sfondo e hover
class _MenuTile extends StatefulWidget {
  const _MenuTile({required this.label, required this.selected, required this.isMobile, required this.onTap, this.icon});

  final String label;
  final Widget? icon;
  final bool selected;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hovered = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = widget.isMobile ? 42.0 : 40.0;

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _hovered = true),
      onExit: (_) => _safeSetState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: h,
          child: Stack(
            children: [
              // Box colorato con margine sinistro dal bordo del menu
              Positioned.fill(
                top: 1.5,
                bottom: 1.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? theme.primary.withValues(alpha: 0.12)
                        : _hovered
                            ? theme.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Contenuto: icona e testo restano alla posizione originale (left: 12)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: widget.icon != null ? Center(child: widget.icon!) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: theme.bodyLabel.override(
                          color: widget.selected ? theme.primary : theme.secondaryText,
                          fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: widget.isMobile ? 13 : 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Voce figlia indentata sotto un gruppo espandibile
class _MenuSubTile extends StatefulWidget {
  const _MenuSubTile({required this.label, required this.selected, required this.isMobile, required this.onTap, this.depth = 0});

  final String label;
  final bool selected;
  final bool isMobile;
  final VoidCallback onTap;
  final int depth;

  @override
  State<_MenuSubTile> createState() => _MenuSubTileState();
}

class _MenuSubTileState extends State<_MenuSubTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = widget.isMobile ? 38.0 : 36.0;
    // Allineamento testo: 32 (area icona) + 10 (padding) = 42px
    // Identico a _MenuTile e _MenuGroup header (12 + 20 + 10 = 42px)
    const double boxLeftMargin = 32.0;

    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _hovered = false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          height: h,
          child: Padding(
            padding: EdgeInsets.only(left: boxLeftMargin, top: 1, bottom: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: widget.selected
                    ? theme.primary.withValues(alpha: 0.1)
                    : _hovered
                        ? theme.primary.withValues(alpha: 0.04)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
                style: theme.bodyText.copyWith(
                  color: widget.selected ? theme.primary : theme.secondaryText,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: widget.isMobile ? 13 : 13.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Voce logout per il menu mobile — con colore danger
class _MobileLogoutTile extends StatefulWidget {
  const _MobileLogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MobileLogoutTile> createState() => _MobileLogoutTileState();
}

class _MobileLogoutTileState extends State<_MobileLogoutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    const h = 42.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                top: 1.5,
                bottom: 1.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: _hovered ? theme.danger.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Center(
                        child: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: theme.danger, size: 19),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: theme.bodyLabel.copyWith(
                        color: theme.danger,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
