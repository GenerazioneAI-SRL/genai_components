part of '../menu.layout.dart';

/// Header del menu: logo + (mobile only: tema toggle + close button)
class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.authState, required this.isMobile, required this.onClose, this.logoBuilder});

  final CLAuthState authState;
  final bool isMobile;
  final VoidCallback onClose;
  final Widget Function(BuildContext context)? logoBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Sizes.padding,
        isMobile ? Sizes.padding * 0.8 : Sizes.padding * 0.75,
        isMobile ? Sizes.padding * 0.5 : Sizes.padding,
        0,
      ),
      child: Row(
        children: [
          // Toggle tema (solo mobile) — a sinistra del logo
          if (isMobile) ...[
            const _MenuThemeToggle(compact: true),
            const SizedBox(width: 8),
          ],
          // Logo — custom o default
          Expanded(
            child: logoBuilder != null ? logoBuilder!(context) : LogoWidget(height: isMobile ? 22 : 24, dark: false, color: theme.primary),
          ),
          // Close button (solo mobile) — a destra del logo
          if (isMobile) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: theme.borderColor),
                ),
                child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: theme.secondaryText, size: 17)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
