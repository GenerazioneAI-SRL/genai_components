import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:genai_components/core_utils/extension.util.dart';
import 'package:genai_components/utils/providers/navigation.util.provider.dart';
import 'package:genai_components/auth/cl_auth_state.dart';
import '../widgets/avatar.widget.dart';
import '../widgets/cl_popup_menu.widget.dart';
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
  // ── Helpers ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<CLAuthState>();
    final navigationState = context.watch<NavigationState>();
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);

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
          // ── Hamburger (mobile) ─────────────────────────────
          if (isMobile) ...[
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: theme.primaryText, size: 20),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            SizedBox(width: Sizes.padding * 0.5),
          ],

          // ── Titolo / Breadcrumbs ────────────────────────────
          Expanded(
            child: isMobile ? _buildMobileTitle(context, navigationState, theme) : _buildDesktopBreadcrumbs(context, navigationState, theme),
          ),

          SizedBox(width: isMobile ? Sizes.padding * 0.5 : Sizes.padding * 0.75),

          // ── Profilo utente ─────────────────────────────────
          isMobile ? _buildMobileProfile(context, authState, theme) : _buildDesktopProfile(context, authState, theme),
        ],
      ),
    );
  }

  /// Desktop: breadcrumb navigabili; se vuoti, cade back sul nome pagina
  Widget _buildDesktopBreadcrumbs(BuildContext context, NavigationState navigationState, CLTheme theme) {
    if (navigationState.breadcrumbs.isEmpty) {
      return Text(
        navigationState.pageName,
        style: theme.heading6.copyWith(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.3),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    return BreadCrumb(
      items: navigationState.breadcrumbs.asMap().entries.map((entry) {
        final segment = entry.value;
        final isLast = navigationState.breadcrumbs.last.name == segment.name;
        Widget content;
        if (isLast) {
          content = Text(segment.name, style: theme.bodyText.copyWith(color: theme.primary, fontWeight: FontWeight.w600));
        } else {
          content = Text(segment.name, style: theme.bodyLabel.copyWith(color: theme.secondaryText));
        }
        return BreadCrumbItem(
          content: content,
          onTap: segment.isClickable && !isLast ? () => context.go(segment.path) : null,
        );
      }).toList(),
      divider: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: Sizes.small, color: theme.secondaryText.withValues(alpha: 0.5)),
      ),
    );
  }

  /// Titolo mobile con fade-in quando CLPageHeader è scrollata via
  Widget _buildMobileTitle(BuildContext context, NavigationState navigationState, CLTheme theme) {
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
              style: theme.heading6.copyWith(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2, color: theme.primary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }

  /// Profilo utente — CLAvatarWidget pill con nome+email (desktop) e CLAvatarWidget che apre un bottom sheet (mobile)
  Widget _buildDesktopProfile(BuildContext context, CLAuthState authState, CLTheme theme) {
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final email = authState.currentUserInfo?.email ?? '';
    final fullName = authState.currentUserInfo?.fullName ?? '';
    final displayName = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : email;

    final popupHeader = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          CLAvatarWidget(medias: const [], name: displayName, iconSize: 36, fontSize: 14),
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
                  Text(email, style: theme.smallLabel.copyWith(color: theme.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );

    return CLPopupMenu(
      titleWidget: popupHeader,
      alignment: CLPopupAlignment.end,
      minWidth: 230,
      maxWidth: 270,
      items: [
        CLPopupMenuItem(
          content: Row(children: [
            HugeIcon(icon: HugeIcons.strokeRoundedUser, color: theme.primaryText, size: Sizes.medium),
            const SizedBox(width: 12),
            Text('Profilo', style: theme.bodyText)
          ]),
          onTap: () => context.customGoNamed('Profilo Utente'),
        ),
        CLPopupMenuItem(
          content: Row(children: [
            HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: theme.danger, size: Sizes.medium),
            const SizedBox(width: 12),
            Text('Logout', style: theme.bodyText.override(color: theme.danger))
          ]),
          onTap: () async => await authState.signOut(),
        ),
      ],
      builder: (context, open) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: open,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.borderColor)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CLAvatarWidget(medias: const [], name: displayName, iconSize: 26, fontSize: 10),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      fullName.isNotEmpty ? fullName : displayName,
                      style: theme.bodyText.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 11, color: theme.secondaryText),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileProfile(BuildContext context, CLAuthState authState, CLTheme theme) {
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final email = authState.currentUserInfo?.email ?? '';
    final fullName = authState.currentUserInfo?.fullName ?? '';
    final displayName = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : email;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => _showProfileBottomSheet(context, authState, displayName, fullName, email),
        child: CLAvatarWidget(medias: const [], name: displayName, iconSize: 34, fontSize: 13),
      ),
    );
  }

  void _showProfileBottomSheet(BuildContext context, CLAuthState authState, String displayName, String fullName, String email) {
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
                  const SizedBox(height: 8),
                  // Hero profilo
                  Container(
                    margin: const EdgeInsets.fromLTRB(Sizes.padding, Sizes.padding * 0.5, Sizes.padding, 0),
                    padding: const EdgeInsets.all(Sizes.padding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [t.primary.withValues(alpha: 0.1), t.secondary.withValues(alpha: 0.05)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.primary.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        CLAvatarWidget(medias: const [], name: displayName, iconSize: 48, fontSize: 18),
                        const SizedBox(width: Sizes.padding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(fullName.isNotEmpty ? fullName : 'Utente',
                                  style: t.heading6.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(children: [
                                  HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: 12, color: t.secondaryText),
                                  const SizedBox(width: 4),
                                  Expanded(
                                      child: Text(email,
                                          style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ]),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Azioni
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Sizes.padding, Sizes.padding * 0.75, Sizes.padding, Sizes.padding),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Voce azione nel bottom sheet del profilo mobile
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
