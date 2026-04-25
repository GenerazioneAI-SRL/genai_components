part of '../menu.layout.dart';

/// Card tenant — mostra workspace corrente con due azioni esplicite
class _TenantCard extends StatelessWidget {
  const _TenantCard({required this.authState, required this.isMobile, required this.onTap, this.onSwitch});

  final CLAuthState authState;
  final bool isMobile;
  final VoidCallback onTap;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyName = authState.currentTenant!.name;
    final vatNumber = authState.currentTenant!.rawData['vatNumber'];
    final subtitle = vatNumber != null ? 'P.IVA $vatNumber' : 'Workspace attivo';

    final cardBg = isDark ? theme.secondaryBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.55);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.padding * 0.6, vertical: isMobile ? 2 : 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Info azienda ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
                ),
                child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedBuilding04, color: theme.primary, size: 15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(subtitle, style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Bottoni azione ────────────────────────────────
          Row(
            children: [
              // Vai all'azienda
              Expanded(
                child: _TenantActionButton(
                  label: 'La mia azienda',
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  isPrimary: true,
                  onTap: onTap,
                  theme: theme,
                ),
              ),
              // Cambia azienda (solo multi-tenant)
              if (onSwitch != null) ...[
                const SizedBox(width: 6),
                _TenantActionButton(
                  label: 'Cambia',
                  icon: HugeIcons.strokeRoundedRepeat,
                  isPrimary: false,
                  onTap: onSwitch!,
                  theme: theme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottone azione compatto usato dentro _TenantCard
class _TenantActionButton extends StatefulWidget {
  const _TenantActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final dynamic icon;
  final bool isPrimary;
  final VoidCallback onTap;
  final CLTheme theme;

  @override
  State<_TenantActionButton> createState() => _TenantActionButtonState();
}

class _TenantActionButtonState extends State<_TenantActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final color = widget.isPrimary ? t.primary : t.secondaryText;
    final bg = widget.isPrimary ? (_hovered ? t.primary.withValues(alpha: 0.14) : t.primary.withValues(alpha: 0.08)) : Colors.transparent;
    final border =
        widget.isPrimary ? Border.all(color: Colors.transparent) : Border.all(color: _hovered ? t.borderColor.withValues(alpha: 0.8) : t.borderColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(7),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isPrimary) ...[
                Flexible(
                  child: Text(
                    widget.label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11, fontFamily: 'Inter'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                HugeIcon(icon: widget.icon, size: 11, color: color),
              ] else ...[
                Text(widget.label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 11, fontFamily: 'Inter')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
