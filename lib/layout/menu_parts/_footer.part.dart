part of '../menu.layout.dart';

/// Mini switch visivo per il toggle tema nel footer del menu
class _ThemeToggleSwitch extends StatelessWidget {
  const _ThemeToggleSwitch({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 20,
      decoration: BoxDecoration(color: isDark ? theme.primary.withValues(alpha: 0.8) : theme.borderColor, borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isDark ? 18.0 : 2.0,
            top: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Toggle tema isolato — Selector su isDarkMode così la UI del toggle
/// si ridisegna SOLO al cambio tema, non quando il menu padre rebuilda
/// (es. cambio rotta, tenant). Due stili: footer desktop full-width
/// e icona compatta per la testata mobile.
class _MenuThemeToggle extends StatelessWidget {
  const _MenuThemeToggle({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, bool>(
      selector: (_, p) => p.isDarkMode,
      builder: (context, isDarkNow, _) {
        final theme = CLTheme.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themeProvider = context.read<ThemeProvider>();

        if (compact) {
          // Variante compatta — usata nella testata drawer mobile.
          return Tooltip(
            message: isDarkNow ? 'Modalità chiara' : 'Modalità scura',
            child: GestureDetector(
              onTap: () async => await themeProvider.toggleTheme(),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDarkNow ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: isDarkNow ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun03,
                      color: isDarkNow ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Variante footer desktop — full-width con label e switch.
        return Padding(
          padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, Sizes.padding * 0.75),
          child: GestureDetector(
            onTap: () async => await themeProvider.toggleTheme(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.75, vertical: Sizes.padding * 0.5),
                decoration: BoxDecoration(
                  color: isDark ? theme.secondaryBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? theme.borderColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDarkNow ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: isDarkNow ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun03,
                          color: isDarkNow ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isDarkNow ? 'Modalità scura' : 'Modalità chiara',
                        style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                    _ThemeToggleSwitch(isDark: isDarkNow),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pulsante AI nel footer del menu — visibile solo se [AppState.showAiButton]
/// è true e la posizione è [AiButtonPosition.menu]. Watch su AppState per
/// reagire a toggle di visibilità/posizione runtime.
class _MenuAiButton extends StatelessWidget {
  const _MenuAiButton();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.showAiButton || appState.aiButtonPosition != AiButtonPosition.menu) {
      return const SizedBox.shrink();
    }
    final theme = CLTheme.of(context);
    onPressed() => appState.toggleAiChat();
    if (appState.aiButtonBuilder != null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, 8),
        child: appState.aiButtonBuilder!(context, onPressed),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, 8),
      child: GestureDetector(
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.75, vertical: Sizes.padding * 0.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary.withValues(alpha: 0.12), theme.secondary.withValues(alpha: 0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(7)),
                  child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedAiChat02, color: theme.primary, size: 15)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Assistente AI',
                    style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: theme.primary),
                  ),
                ),
                HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: theme.primary, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card profilo utente nel footer del menu — visibile solo se
/// [AppState.profilePosition] è [ProfilePosition.menu]. Apre un popup con
/// azioni Profilo / Esci.
class _MenuUserProfile extends StatelessWidget {
  const _MenuUserProfile();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final authState = context.watch<CLAuthState>();
    if (appState.profilePosition != ProfilePosition.menu) {
      return const SizedBox.shrink();
    }
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final email = authState.currentUserInfo?.email ?? '';
    final fullName = authState.currentUserInfo?.fullName ?? '';
    final displayName = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : email;

    return Padding(
      padding: EdgeInsets.fromLTRB(Sizes.padding * 0.6, 0, Sizes.padding * 0.6, 8),
      child: CLPopupMenu(
        titleWidget: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              CLAvatarWidget(medias: const [], name: displayName, iconSize: 38, fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : (email.isNotEmpty ? email : 'Utente'),
                      style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty)
                      Text(email,
                          style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        alignment: CLPopupAlignment.start,
        minWidth: 230,
        maxWidth: 270,
        items: [
          CLPopupMenuItem(
            content: Row(children: [
              HugeIcon(icon: HugeIcons.strokeRoundedUser, color: theme.primaryText, size: Sizes.medium),
              const SizedBox(width: 12),
              Text('Profilo', style: theme.bodyText),
            ]),
            onTap: () {},
          ),
          CLPopupMenuItem(
            content: Row(children: [
              HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: theme.danger, size: Sizes.medium),
              const SizedBox(width: 12),
              Text('Esci', style: theme.bodyText.copyWith(color: theme.danger)),
            ]),
            onTap: () => authState.signOut(),
          ),
        ],
        builder: (context, open) => GestureDetector(
          onTap: open,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.padding * 0.75, vertical: Sizes.padding * 0.5),
            decoration: BoxDecoration(
              color: isDark ? theme.secondaryBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? theme.borderColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                CLAvatarWidget(medias: const [], name: displayName, iconSize: 28, fontSize: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fullName.isNotEmpty ? fullName : (email.isNotEmpty ? email : 'Utente'),
                        style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty)
                        Text(email,
                            style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, color: theme.secondaryText, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Etichetta versione app (es. "v1.2.3 (45)") usata nel footer del menu.
/// Stesso stile su mobile/desktop, cambia solo il padding inferiore.
class _MenuVersionLabel extends StatelessWidget {
  const _MenuVersionLabel({required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final info = snapshot.data!;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Text(
            'v${info.version} (${info.buildNumber})',
            textAlign: TextAlign.center,
            style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 10),
          ),
        );
      },
    );
  }
}
