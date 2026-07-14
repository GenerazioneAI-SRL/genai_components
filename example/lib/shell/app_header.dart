import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import 'package:go_router/go_router.dart';

import '../app/sections.dart';
import '../modules/users/constants/users_routes.dart';
import 'theme_customizer.dart';

/// Apre la ricerca globale ([GenCommandPalette]) con le sezioni showcase + Utenti.
/// Condivisa tra l'header desktop e il pulsante "Cerca" della bottom bar mobile.
/// [onAskAi] è invocato dall'azione "chiedi all'AI" della palette.
void openGlobalSearch(BuildContext context, {required VoidCallback onAskAi}) {
  GenCommandPalette.show(
    context,
    items: [
      for (final s in showcaseSections)
        GenCommandItem(id: s.path, label: s.label, icon: s.icon, group: 'Componenti', onSelect: () => context.go(s.path)),
      GenCommandItem(
        id: UsersRoutes.listPath,
        label: 'Utenti',
        icon: Icons.table_rows,
        group: 'Esempi',
        onSelect: () => context.go(UsersRoutes.listPath),
      ),
    ],
    onAskAi: (_) => onAskAi(),
  );
}

/// Cluster G3 dell'header (a destra): ricerca globale · AI · impostazioni tema.
/// La pill apre [GenCommandPalette] (ricerca globale, estetica GenSelect+search);
/// il pulsante AI apre/chiude la bolla assistente ([onToggleAi]); il gear apre
/// il theme playground ([ThemeCustomizer]).
class AppHeader extends StatefulWidget {
  const AppHeader({super.key, required this.onToggleAi});

  final VoidCallback onToggleAi;

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final _themePopover = GenPopoverController();

  @override
  void dispose() {
    _themePopover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlobalSearchPill(onTap: () => openGlobalSearch(context, onAskAi: widget.onToggleAi)),
        SizedBox(width: theme.gapSm),
        // Pulsante AI: GenIconButton con gradient brand + glow → toggle bolla AI.
        GenIconButton(
          onPressed: widget.onToggleAi,
          icon: Icon(LucideIcons.sparkles, size: theme.iconSizeDefault),
          iconSize: theme.iconSizeDefault,
          gradient: LinearGradient(colors: [theme.primary, const Color(0xFF4F46E5)]),
          shadows: theme.primaryGlow,
        ),
        SizedBox(width: theme.gapSm),
        // Gear → popover theme playground (preset/scale/radius/color mode/reset).
        GenPopover(
          controller: _themePopover,
          popover: (context) => const ThemeCustomizer(),
          child: GenIconButton.ghost(
            onPressed: _themePopover.toggle,
            icon: Icon(LucideIcons.settings2, size: theme.iconSizeDefault),
          ),
        ),
      ],
    );
  }
}

/// Trigger ricerca globale (UI-only), porting Gen di `CLGlobalSearch`: pill
/// `secondaryBackground` + label + chip scorciatoia `⌘K`. onTap apre la palette.
class _GlobalSearchPill extends StatelessWidget {
  const _GlobalSearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: theme.buttonHeightDefault,
        width: 240,
        padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusPill),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.search, size: theme.iconSizeCompact),
            SizedBox(width: theme.gapSm),
            Expanded(
                child: Text('Cerca…',
                    style: theme.bodyText.copyWith(color: theme.mutedForeground), overflow: TextOverflow.ellipsis)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: theme.gapXs, vertical: 2),
              decoration: BoxDecoration(color: theme.controlFill, borderRadius: BorderRadius.circular(theme.radiusChip)),
              child: Text('⌘K', style: theme.smallLabel.copyWith(color: theme.mutedForeground)),
            ),
          ],
        ),
      ),
    );
  }
}
