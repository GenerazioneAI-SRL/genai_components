import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenTable] (= GenTable), la tabella STATICA semplice
/// (NON il GenDataTable). Usa il costruttore `GenTable.list` con una matrice
/// di [GenTableCell] (nessun alias Gen per la cella → si usa GenTableCell).
///
/// GenTable è uno scrollable 2D (TableView): richiede vincoli limitati, quindi
/// ogni esempio è racchiuso in un [SizedBox] con width/height espliciti.
class TableShowcase extends StatelessWidget {
  const TableShowcase({super.key});

  // Dati demo condivisi.
  static const _rows = [
    ['INV001', 'Pagato', 'Bonifico', '250 €'],
    ['INV002', 'In attesa', 'PayPal', '150 €'],
    ['INV003', 'Non pagato', 'Bonifico', '350 €'],
    ['INV004', 'Pagato', 'Carta', '450 €'],
  ];

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    // Larghezze colonna (FixedTableSpanExtent) per un layout leggibile.
    TableSpanExtent? colExtent(int col) => switch (col) {
          0 => const FixedTableSpanExtent(110),
          3 => const FixedTableSpanExtent(90),
          _ => const FixedTableSpanExtent(130),
        };

    return DemoPage(
      children: [
        // ── Base: header + righe ────────────────────────────────────────────
        DemoGroup(
          title: 'Base',
          description:
              'GenTable.list con header (Iterable<GenTableCell>) + matrice di '
              'righe. GenTableCell.header per l\'intestazione, GenTableCell '
              'per le celle dati.',
          items: [
            DemoTile(
              label: 'Header + 4 righe',
              width: 480,
              child: SizedBox(
                width: 480,
                height: 5 * 48,
                child: GenTable.list(
                  columnSpanExtent: colExtent,
                  header: const [
                    GenTableCell.header(child: Text('Fattura')),
                    GenTableCell.header(child: Text('Stato')),
                    GenTableCell.header(child: Text('Metodo')),
                    GenTableCell.header(child: Text('Totale')),
                  ],
                  children: [
                    for (final r in _rows)
                      [for (final c in r) GenTableCell(child: Text(c))],
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Celle allineate ─────────────────────────────────────────────────
        DemoGroup(
          title: 'Allineamento celle',
          description:
              'GenTableCell.alignment (AlignmentGeometry) allinea il contenuto. '
              'Qui l\'ultima colonna (Totale) è allineata a destra, header '
              'incluso.',
          items: [
            DemoTile(
              label: 'Ultima colonna a destra',
              width: 480,
              child: SizedBox(
                width: 480,
                height: 5 * 48,
                child: GenTable.list(
                  columnSpanExtent: colExtent,
                  header: const [
                    GenTableCell.header(child: Text('Fattura')),
                    GenTableCell.header(child: Text('Stato')),
                    GenTableCell.header(child: Text('Metodo')),
                    GenTableCell.header(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('Totale'),
                    ),
                  ],
                  children: [
                    for (final r in _rows)
                      [
                        GenTableCell(child: Text(r[0])),
                        GenTableCell(child: Text(r[1])),
                        GenTableCell(child: Text(r[2])),
                        GenTableCell(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(r[3]),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Con footer ──────────────────────────────────────────────────────
        DemoGroup(
          title: 'Con footer',
          description:
              'footer (Iterable<GenTableCell>) con GenTableCell.footer: riga '
              'riepilogo evidenziata in fondo. Qui somma dei totali.',
          items: [
            DemoTile(
              label: 'Header + righe + footer',
              width: 480,
              child: SizedBox(
                width: 480,
                height: 6 * 48,
                child: GenTable.list(
                  columnSpanExtent: colExtent,
                  header: const [
                    GenTableCell.header(child: Text('Fattura')),
                    GenTableCell.header(child: Text('Stato')),
                    GenTableCell.header(child: Text('Metodo')),
                    GenTableCell.header(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('Totale'),
                    ),
                  ],
                  footer: const [
                    GenTableCell.footer(child: Text('Totale')),
                    GenTableCell.footer(child: Text('')),
                    GenTableCell.footer(child: Text('')),
                    GenTableCell.footer(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('1200 €'),
                    ),
                  ],
                  children: [
                    for (final r in _rows)
                      [
                        GenTableCell(child: Text(r[0])),
                        GenTableCell(child: Text(r[1])),
                        GenTableCell(child: Text(r[2])),
                        GenTableCell(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(r[3]),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Contenuto ricco nelle celle ─────────────────────────────────────
        DemoGroup(
          title: 'Celle con widget',
          description:
              'La cella accetta qualsiasi widget: icone (GenIcon), badge di '
              'stato colorati, testo formattato.',
          items: [
            DemoTile(
              label: 'Icona di stato + colore',
              width: 480,
              child: SizedBox(
                width: 480,
                height: 5 * 48,
                child: GenTable.list(
                  columnSpanExtent: colExtent,
                  header: const [
                    GenTableCell.header(child: Text('Fattura')),
                    GenTableCell.header(child: Text('Stato')),
                    GenTableCell.header(child: Text('Metodo')),
                    GenTableCell.header(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('Totale'),
                    ),
                  ],
                  children: [
                    for (final r in _rows)
                      [
                        GenTableCell(child: Text(r[0])),
                        GenTableCell(
                          child: _StatusBadge(status: r[1]),
                        ),
                        GenTableCell(child: Text(r[2])),
                        GenTableCell(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            r[3],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: t.primaryText,
                            ),
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Badge di stato colorato: icona + label, colore derivato dallo stato.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final (color, icon) = switch (status) {
      'Pagato' => (t.primary, LucideIcons.circleCheck),
      'In attesa' => (t.accentForeground, LucideIcons.clock),
      _ => (t.danger, LucideIcons.circleX),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: color)),
      ],
    );
  }
}
