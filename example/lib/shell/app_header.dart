import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import 'package:go_router/go_router.dart';

import '../app/sections.dart';
import '../modules/users/constants/users_routes.dart';
import '../modules/users/models/user.model.dart';
import 'theme_customizer.dart';

/// Apre la ricerca globale ([GenCommandPalette]).
///
/// - **items** (ricerca statica locale): sezioni showcase + pagina Utenti.
/// - **previewItems** (a query vuota): set curato di scorciatoie invece dell'intera
///   lista componenti (che sarebbe lunghissima appena aperta).
/// - **asyncSearch**: cerca gli UTENTI (nome/email) con delay simulato → ogni voce
///   naviga al dettaglio. Dimostra la ricerca globale async nella palette.
/// - **onAskAi**: a 0 risultati con query non vuota apre l'assistente.
Future<void> openGlobalSearch(BuildContext context, {required VoidCallback onAskAi}) {
  GenCommandItem sectionItem(dynamic s) =>
      GenCommandItem(id: s.path, label: s.label, icon: s.icon, group: 'Componenti', onSelect: () => context.go(s.path));

  final usersItem = GenCommandItem(
    id: UsersRoutes.listPath,
    label: 'Utenti',
    icon: Icons.table_rows,
    group: 'Esempi',
    onSelect: () => context.go(UsersRoutes.listPath),
  );

  return GenCommandPalette.show(
    context,
    items: [
      for (final s in showcaseSections) sectionItem(s),
      usersItem,
    ],
    // A vuoto: Utenti + prime 6 sezioni → lista corta e utile.
    previewItems: [
      usersItem,
      for (final s in showcaseSections.take(6)) sectionItem(s),
    ],
    // Ricerca async utenti (nome/email) → naviga al dettaglio.
    asyncSearch: (q) async {
      await Future<void>.delayed(const Duration(milliseconds: 300)); // simula rete
      final ql = q.toLowerCase();
      return demoUsers
          .where((u) => u.name.toLowerCase().contains(ql) || u.email.toLowerCase().contains(ql))
          .take(8)
          .map(
            (u) => GenCommandItem(
              id: 'user-${u.id}',
              label: u.name,
              description: u.email,
              icon: Icons.person_outline,
              group: 'Utenti',
              onSelect: () => context.go(UsersRoutes.detailOf(u.id), extra: u.name),
            ),
          )
          .toList();
    },
    // Footer legenda tasti (slot footer della palette).
    footer: Builder(
      builder: (context) {
        final t = GenTokens.of(context);
        final style = t.smallLabel.copyWith(color: t.secondaryText);
        return Row(
          children: [
            Text('↑↓ naviga', style: style),
            SizedBox(width: t.gapMd),
            Text('↵ apri', style: style),
            SizedBox(width: t.gapMd),
            Text('esc chiudi', style: style),
          ],
        );
      },
    ),
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
        SizedBox(width: theme.gapLg),
        // Pulsante AI: GenIconButton con gradient brand + glow → toggle bolla AI.
        GenIconButton(
          onPressed: widget.onToggleAi,
          icon: Icon(LucideIcons.sparkles, size: theme.iconSizeDefault),
          iconSize: theme.iconSizeDefault,
          gradient: LinearGradient(colors: [theme.primary, const Color(0xFF4F46E5)]),
          shadows: theme.primaryGlow,
        ),
        SizedBox(width: theme.gapLg),
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

/// Trigger ricerca globale (UI-only): campo cliccabile con feedback HOVER (bg →
/// accent, come il trigger di GenCalendar/date-picker). Label + chip scorciatoia
/// `⌘K`. onTap apre la palette.
class _GlobalSearchPill extends StatefulWidget {
  const _GlobalSearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_GlobalSearchPill> createState() => _GlobalSearchPillState();
}

class _GlobalSearchPillState extends State<_GlobalSearchPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: theme.durationBase,
          height: theme.buttonHeightDefault,
          width: 240,
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
          decoration: BoxDecoration(
            // Hover: superficie → accent (stesso feedback del trigger GenCalendar).
            color: _hovered ? theme.accent : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(theme.radiusControl),
            border: Border.all(color: theme.borderColor),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.search, size: theme.iconSizeCompact),
              SizedBox(width: theme.gapSm),
              Expanded(
                  child: Text('Cerca…',
                      style: theme.bodyText.copyWith(color: theme.mutedForeground),
                      // Non applicare il line-height (1.6) all'ascendente/discendente
                      // della riga → il box del testo = box del font, così la Row lo
                      // centra verticalmente nel campo (come il trigger GenDatePicker).
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      overflow: TextOverflow.ellipsis)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: theme.gapXs, vertical: 2),
                decoration:
                    BoxDecoration(color: theme.controlFill, borderRadius: BorderRadius.circular(theme.radiusChip)),
                child: Text('⌘K', style: theme.smallLabel.copyWith(color: theme.mutedForeground)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
