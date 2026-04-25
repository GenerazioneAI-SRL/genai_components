part of '../menu.layout.dart';

/// Gruppo espandibile con stile coerente
class _MenuGroup extends StatefulWidget {
  const _MenuGroup({
    required this.title,
    required this.isSelected,
    required this.isMobile,
    required this.icon,
    required this.children,
    this.depth = 0,
  });

  final String title;
  final bool isSelected;
  final bool isMobile;
  final Widget icon;
  final List<Widget> children;
  final int depth;

  @override
  State<_MenuGroup> createState() => _MenuGroupState();
}

class _MenuGroupState extends State<_MenuGroup> with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _rotationCtrl;
  bool _hovered = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();
    _expanded = widget.isSelected;
    _rotationCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: _expanded ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _rotationCtrl.forward() : _rotationCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isNested = widget.depth > 0;

    // Stile diverso per gruppi annidati
    if (isNested) {
      return _buildNestedGroup(theme);
    }
    return _buildTopLevelGroup(theme);
  }

  /// Gruppo di primo livello (depth == 0) — contenitore visivo raggruppato
  Widget _buildTopLevelGroup(CLTheme theme) {
    final h = widget.isMobile ? 42.0 : 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => _safeSetState(() => _hovered = true),
          onExit: (_) => _safeSetState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _toggle,
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
                        color: _hovered ? theme.primary.withValues(alpha: 0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Contenuto: icona e testo restano alla posizione originale (left: 12)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 20, child: Center(child: widget.icon)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.bodyLabel.override(
                              color: widget.isSelected ? theme.primary : theme.secondaryText,
                              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: widget.isMobile ? 13 : 13.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 0.25).animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              size: 15,
                              color: widget.isSelected ? theme.primary : theme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Stack(
                    children: [
                      // Linea verticale allineata al centro dell'icona del parent (left 12 + 10 = 22px)
                      Positioned(
                        left: 21,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1.5,
                          color: theme.borderColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Gruppo annidato (depth >= 1) — stile indentato con contenitore visivo
  Widget _buildNestedGroup(CLTheme theme) {
    final h = widget.isMobile ? 42.0 : 40.0;
    // Primo livello di nesting: 38px (allinea con sub-tile hover box a 32px + margine)
    // Ogni livello successivo: +16px incrementali
    final nestedPadding = widget.depth == 1 ? 38.0 : 16.0;

    return Padding(
      padding: EdgeInsets.only(left: nestedPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) {
              if (mounted) setState(() => _hovered = true);
            },
            onExit: (_) {
              if (mounted) setState(() => _hovered = false);
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: h,
                decoration: BoxDecoration(
                  color: _hovered ? theme.primary.withValues(alpha: 0.04) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Spaziatura icona identica al top-level (12+20+10=42px per il testo)
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 20,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFolder01,
                          size: 16,
                          color: widget.isSelected ? theme.primary : theme.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.bodyLabel.override(
                          color: widget.isSelected ? theme.primary : theme.secondaryText,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: widget.isMobile ? 13 : 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.25).animate(CurvedAnimation(parent: _rotationCtrl, curve: Curves.easeInOut)),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 14,
                          color: widget.isSelected ? theme.primary : theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
