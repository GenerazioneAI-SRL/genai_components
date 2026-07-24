import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Voce di una [CLStatStrip]: icona tinta + valore + label, opzionalmente
/// tappabile.
class CLStatStripItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const CLStatStripItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });
}

/// Strip di statistiche a TUTTA larghezza: un'unica card orizzontale con N
/// segmenti equi (icona tinta + valore in evidenza + label), separati da
/// divider verticali. Nata per le fasce dashboard (KPI di oggi, "da
/// approvare", totali periodo) al posto di N card affiancate: stessa
/// informazione, una sola riga di altezza, larghezza piena.
///
/// Sotto [wrapBreakpoint] i segmenti si dispongono su più righe (2 per riga).
class CLStatStrip extends StatelessWidget {
  final List<CLStatStripItem> items;

  /// Larghezza sotto la quale la strip va a capo (2 segmenti per riga).
  final double wrapBreakpoint;

  const CLStatStrip({super.key, required this.items, this.wrapBreakpoint = 640});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();

    Widget segment(CLStatStripItem it) {
      final content = Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapMd),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: it.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(theme.radiusControl),
              ),
              child: Icon(it.icon, size: 18, color: it.color),
            ),
            SizedBox(width: theme.gapMd),
            // Valore e label INLINE sulla stessa riga (2026-07-23, richiesta
            // utente): "12 Presenti oggi", non numero sopra e scritta sotto.
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    it.value,
                    style: theme.heading4.copyWith(color: theme.primaryText, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: theme.gapSm),
                  Flexible(
                    child: Text(
                      it.label,
                      style: theme.bodyLabel.copyWith(color: theme.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      if (it.onTap == null) return content;
      return InkWell(
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        onTap: it.onTap,
        child: content,
      );
    }

    final divider = Container(width: 1, height: 40, color: theme.borderColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth.isFinite && constraints.maxWidth < wrapBreakpoint;
        // Segmenti per riga: tutti su una riga, o 2 per riga su schermi stretti.
        final perRow = narrow ? 2 : items.length;
        final rows = <List<CLStatStripItem>>[];
        for (var i = 0; i < items.length; i += perRow) {
          rows.add(items.sublist(i, (i + perRow).clamp(0, items.length)));
        }
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(Sizes.radiusCard),
              border: Border.all(color: theme.borderColor),
            ),
            child: Column(
              children: [
                for (var r = 0; r < rows.length; r++) ...[
                  if (r > 0) Container(height: 1, color: theme.borderColor),
                  Row(
                    children: [
                      for (var i = 0; i < rows[r].length; i++) ...[
                        if (i > 0) divider,
                        Expanded(child: segment(rows[r][i])),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
