import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

/// Header sidebar (slot navHeader dello shell): azienda corrente (logo + nome +
/// P.IVA) + "Cambia azienda". [extra] = slot custom sotto (futuro: voci menu
/// dell'utente impersonato).
class NavHeader extends StatelessWidget {
  const NavHeader({super.key, this.extra});

  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(t.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Placeholder (banner/logo azienda futuro).
          const Placeholder(fallbackHeight: 56),
          SizedBox(height: t.gapMd),
          // Nome azienda + P.IVA (senza icona).
          Text('Acme S.p.A.', style: t.bodyLabel.copyWith(color: t.primaryText), overflow: TextOverflow.ellipsis),
          Text('P.IVA IT01234567890',
              style: t.smallText.copyWith(color: t.secondaryText), overflow: TextOverflow.ellipsis),
          SizedBox(height: t.gapMd),
          GenButton.outline(
            onPressed: () {},
            width: double.infinity,
            size: GenButtonSize.sm,
            leading: const GenIcon(LucideIcons.repeat),
            child: const Text('Cambia azienda'),
          ),
          if (extra != null) extra!,
        ],
      ),
    );
  }
}

/// Voci menu contestuali del cliente impersonato (contesto "consulente del
/// lavoro"): simula il blocco skillera `/cdl-client/*` — sezione + 6 voci
/// (Presenze, Correzioni, Assenze, Dipendenti, Strutture, Export Paghe).
/// Va nell'`extra` di [NavHeader]. Voci statiche (demo, onTap no-op).
class ClientContextMenu extends StatelessWidget {
  const ClientContextMenu({super.key});

  static const _items = <(IconData, String)>[
    (LucideIcons.calendarCheck, 'Elenco Presenze'),
    (LucideIcons.squarePen, 'Correzioni Timbrature'),
    (LucideIcons.calendarX, 'Richieste Assenza'),
    (LucideIcons.users, 'I miei dipendenti'),
    (LucideIcons.building2, 'Strutture'),
    (LucideIcons.fileSpreadsheet, 'Export Paghe'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    // horizontal gapLg: allinea voci/pill all'inset dell'azienda (NavHeader ha
    // Padding all gapLg). Il separator sopra è pinnato dallo shell (full-width).
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: t.gapLg),
          Padding(
            padding: EdgeInsets.only(left: t.gapSm, bottom: t.gapXs),
            child: Text('Gestione cliente', style: t.smallLabel.copyWith(color: t.secondaryText)),
          ),
          // Stesse voci desktop della sidebar: GenNavTile (ghost, hover nativo).
          for (final (icon, label) in _items)
            GenNavTile(
              label: label,
              onTap: () {},
              iconBuilder: (color, size) => GenIcon(icon, size: size, color: color),
            ),
        ],
      ),
    );
  }
}

/// Voci cliente ICON-ONLY per il rail (slot railSecondary): stesse voci di
/// [ClientContextMenu] come icone centrate con tooltip. Con resizableNavHeader
/// diventano la parte scrollabile della bolla header rail (sotto l'azienda).
class ClientContextMenuRail extends StatelessWidget {
  const ClientContextMenuRail({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Padding(
      // Solo top: il clearance sotto l'ultima voce lo dà già lo scroll dello
      // shell (SingleChildScrollView bottom gapLg) — un bottom qui si sommerebbe.
      padding: EdgeInsets.only(top: t.gapSm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stesse voci rail della sidebar: GenNavRailTile (ghost + tooltip).
          for (final (icon, label) in ClientContextMenu._items)
            GenNavRailTile(
              tooltip: label,
              onTap: () {},
              tooltipOffset: const Offset(4, 0),
              iconBuilder: (color, size) => GenIcon(icon, size: size, color: color),
            ),
        ],
      ),
    );
  }
}

/// Header sidebar COLLASSATA (slot railHeader): Placeholder logo azienda +
/// sotto il pulsante "Cambia azienda" icon-only (con tooltip).
class NavHeaderRail extends StatelessWidget {
  const NavHeaderRail({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(t.gapLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 40, height: 40, child: Placeholder()),
          SizedBox(height: t.gapMd),
          GenTooltip(
            // ShadAnchor mappa i nomi invertiti (childAlignment→follower/overlay,
            // overlayAlignment→target/child) → per uscire a DESTRA vanno scambiati.
            anchor: const GenAnchor(
              childAlignment: Alignment.centerLeft,
              overlayAlignment: Alignment.centerRight,
              offset: Offset(4, 0),
            ),
            builder: (_) => const Text('Cambia azienda'),
            child: GenIconButton.outline(
              onPressed: () {},
              width: t.buttonHeightCompact,
              height: t.buttonHeightCompact,
              iconSize: t.iconSizeCompact,
              icon: const GenIcon(LucideIcons.repeat),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer sidebar COLLASSATA (slot railFooter): avatar, centrato. Padding gapLg
/// coerente con l'header rail e le bolle desktop.
class NavFooterRail extends StatelessWidget {
  const NavFooterRail({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(t.gapLg),
      child: Center(child: _UserAvatar(t: t)),
    );
  }
}

/// Avatar utente (iniziali su primary), via GenAvatar.
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.t});

  final GenTokens t;

  @override
  Widget build(BuildContext context) => GenAvatar(
        '',
        size: const Size.square(32),
        backgroundColor: t.primary,
        placeholder: Text('DS', style: t.smallLabel.copyWith(color: Colors.white)),
      );
}

/// Footer sidebar (slot navFooter dello shell): profilo utente.
class NavFooter extends StatelessWidget {
  const NavFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(t.gapLg),
      child: Row(
        children: [
          _UserAvatar(t: t),
          SizedBox(width: t.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Davide Sgravo', style: t.bodyLabel.copyWith(color: t.primaryText), overflow: TextOverflow.ellipsis),
                Text('davide@generazioneai.it',
                    style: t.smallText.copyWith(color: t.secondaryText), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GenIcon(LucideIcons.ellipsisVertical, size: t.iconSizeCompact, color: t.secondaryText),
        ],
      ),
    );
  }
}
