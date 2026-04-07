import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:genai_components/core_utils/extension.util.dart';
import 'package:genai_components/utils/providers/navigation.util.provider.dart';
import 'package:genai_components/auth/cl_auth_state.dart';
import '../widgets/avatar.widget.dart';
import '../widgets/cl_popup_menu.widget.dart';
import 'breadcrumbs.layout.dart';
import 'constants/sizes.constant.dart';
import '../cl_theme.dart';

class HeaderLayout extends StatefulWidget {
  const HeaderLayout({super.key, this.headerColor, this.headerHeight, this.iconColor, this.iconSize});

  final Color? headerColor;
  final double? headerHeight;
  final Color? iconColor;
  final double? iconSize;

  @override
  State<HeaderLayout> createState() => _HeaderLayoutState();
}

class _HeaderLayoutState extends State<HeaderLayout> {
  GlobalKey profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<CLAuthState>();
    final navigationState = context.watch<NavigationState>();
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;

    return Container(
      height: widget.headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.padding * 0.75 : Sizes.padding,
        vertical: isMobile ? Sizes.padding * 0.4 : Sizes.padding / 2,
      ),
      color: widget.headerColor ?? Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Hamburger (mobile) ─────────────────────────
          if (isMobile) ...[
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: CLTheme.of(context).primaryText, size: 20),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            SizedBox(width: Sizes.padding * 0.5),
          ],

          // ── Breadcrumbs (desktop) / Titolo fade (mobile) ──
          Expanded(child: isMobile ? _buildMobileTitle(context, navigationState) : BreadcrumbsLayout()),

          SizedBox(width: isMobile ? Sizes.padding * 0.5 : Sizes.padding),

          // ── Assistente AI ──────────────────────────────
          /*_buildAiButton(context),

          SizedBox(width: isMobile ? Sizes.padding * 0.5 : Sizes.padding * 0.75),*/

          // ── Profilo utente ─────────────────────────────
          _buildUserProfile(context, authState, isMobile),
        ],
      ),
    );
  }

  /// Titolo mobile con fade-in quando CLPageHeader è scrollata via
  Widget _buildMobileTitle(BuildContext context, NavigationState navigationState) {
    return ValueListenableBuilder<bool>(
      valueListenable: navigationState.headerTitleVisible,
      builder: (context, visible, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            offset: visible ? Offset.zero : const Offset(0, 0.3),
            child: Text(
              navigationState.pageName,
              style: CLTheme.of(
                context,
              ).heading6.copyWith(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2, color: CLTheme.of(context).primary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }

  /// Pulsante Assistente AI
  /*Widget _buildAiButton(BuildContext context) {
    final theme = CLTheme.of(context);
    return Tooltip(
      message: 'Assistente AI',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
          onTap: () => Scaffold.of(context).openEndDrawer(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
            ),
            child: HugeIcon(icon: HugeIcons.strokeRoundedAiChat02, color: theme.primary, size: 20),
          ),
        ),
      ),
    );
  }*/

  /// Profilo utente
  Widget _buildUserProfile(BuildContext context, CLAuthState authState, bool isMobile) {
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final fullName = authState.currentUserInfo?.fullName ?? '';

    if (isMobile) {
      return InkWell(
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        onTap: () => _showProfileBottomSheet(context, authState),
        child: SizedBox(height: 36, width: 36, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
      );
    }

    return CLPopupMenu(
      title: 'Account',
      alignment: CLPopupAlignment.end,
      minWidth: 220,
      maxWidth: 260,
      items: [
        CLPopupMenuItem(
          content: Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedUser, color: CLTheme.of(context).primaryText, size: Sizes.medium),
              const SizedBox(width: 12),
              Text('Profilo', style: CLTheme.of(context).bodyText),
            ],
          ),
          onTap: () => context.customGoNamed('Profilo Utente'),
        ),
        CLPopupMenuItem(
          content: Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: CLTheme.of(context).danger, size: Sizes.medium),
              const SizedBox(width: 12),
              Text('Logout', style: CLTheme.of(context).bodyText.override(color: CLTheme.of(context).danger)),
            ],
          ),
          onTap: () async => await authState.signOut(),
        ),
      ],
      builder: (context, open) {
        return InkWell(
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
          onTap: open,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 36, width: 36, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
              SizedBox(width: Sizes.padding / 2),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$firstName $lastName", style: CLTheme.of(context).bodyText),
                  Text(authState.currentUserInfo?.email ?? '', style: CLTheme.of(context).smallLabel),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bottom sheet profilo mobile
  void _showProfileBottomSheet(BuildContext context, CLAuthState authState) {
    final email = authState.currentUserInfo?.email ?? '';
    final fullName = authState.currentUserInfo?.fullName ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final t = CLTheme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(width: 36, height: 4, decoration: BoxDecoration(color: t.borderColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 4),
                  // Hero profilo
                  Container(
                    margin: const EdgeInsets.fromLTRB(Sizes.padding, Sizes.padding * 0.75, Sizes.padding, 0),
                    padding: const EdgeInsets.all(Sizes.padding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [t.primary.withValues(alpha: 0.12), t.secondary.withValues(alpha: 0.06)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 52, height: 52, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
                        const SizedBox(width: Sizes.padding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: t.heading6.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: 12, color: t.secondaryText),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Azioni
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Sizes.padding, Sizes.padding * 0.75, Sizes.padding, 0),
                    child: Column(
                      children: [
                        _ProfileAction(
                          icon: HugeIcons.strokeRoundedUserAccount,
                          label: 'Profilo',
                          subtitle: 'Visualizza e modifica il profilo',
                          color: t.primary,
                          onTap: () {
                            Navigator.pop(ctx);
                            context.customGoNamed('Profilo Utente');
                          },
                        ),
                        const SizedBox(height: 8),
                        _ProfileAction(
                          icon: HugeIcons.strokeRoundedLogout01,
                          label: 'Logout',
                          subtitle: "Esci dall'account",
                          color: t.danger,
                          onTap: () async {
                            Navigator.pop(ctx);
                            await authState.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sizes.padding),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Voce azione nel bottom sheet del profilo
class _ProfileAction extends StatefulWidget {
  const _ProfileAction({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  final dynamic icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ProfileAction> createState() => _ProfileActionState();
}

class _ProfileActionState extends State<_ProfileAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.75),
        decoration: BoxDecoration(
          color: _pressed ? widget.color.withValues(alpha: 0.1) : theme.primaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _pressed ? widget.color.withValues(alpha: 0.3) : theme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(child: HugeIcon(icon: widget.icon, size: 19, color: widget.color)),
            ),
            const SizedBox(width: Sizes.padding * 0.75),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: theme.bodyLabel.copyWith(fontWeight: FontWeight.w600, color: widget.color, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(widget.subtitle, style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 11)),
                ],
              ),
            ),
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 16, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }
}
