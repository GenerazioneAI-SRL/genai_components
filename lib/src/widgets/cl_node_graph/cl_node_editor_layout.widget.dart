import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_node_palette.widget.dart';

/// Larghezza di default della colonna della palette.
const double kCLNodePaletteWidth = 240;

/// Larghezza di default del pannello laterale di configurazione.
const double kCLNodePanelWidth = 360;

/// Quota massima dell'altezza occupata dal foglio dal basso (forma compatta).
const double kCLNodeSheetMaxHeightFactor = 0.6;

/// Impaginazione dell'editor a nodi: **palette | canvas | pannello**.
///
/// - [canvas]: di norma un `CLNodeGraph`.
/// - [palette]: di norma una `CLNodePalette`; null ⇒ nessuna colonna.
/// - [panel]: configurazione del nodo selezionato; null ⇒ pannello chiuso (il
///   canvas prende lo spazio). L'host lo passa quando c'è una selezione e lo
///   toglie in [onPanelClose].
///
/// Forma compatta (larghezza disponibile sotto [kCLNodeEditorCompactWidth], o
/// [compact] true): il canvas occupa tutto, la palette diventa un pulsante-menu
/// in alto a sinistra (tramite [CLNodeEditorScope]) e il pannello un foglio
/// dal basso sopra il canvas, alto al massimo [kCLNodeSheetMaxHeightFactor].
class CLNodeEditorLayout extends StatelessWidget {
  final Widget canvas;
  final Widget? palette;
  final Widget? panel;

  /// Titolo dell'intestazione del pannello (es. il nome del nodo).
  final String? panelTitle;

  /// Chiusura del pannello (pulsante ✕). Null ⇒ nessun pulsante.
  final VoidCallback? onPanelClose;
  final String closeTooltip;
  final double paletteWidth;
  final double panelWidth;

  /// Forma compatta forzata. Null ⇒ dalla larghezza disponibile.
  final bool? compact;

  const CLNodeEditorLayout({
    super.key,
    required this.canvas,
    this.palette,
    this.panel,
    this.panelTitle,
    this.onPanelClose,
    this.closeTooltip = 'Chiudi',
    this.paletteWidth = kCLNodePaletteWidth,
    this.panelWidth = kCLNodePanelWidth,
    this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = compact ?? constraints.maxWidth < kCLNodeEditorCompactWidth;
      return CLNodeEditorScope(
        compact: isCompact,
        child: isCompact ? _compact(theme, constraints) : _wide(theme),
      );
    });
  }

  Widget _wide(CLTheme theme) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (palette != null)
            Container(
              width: paletteWidth,
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                border: Border(right: BorderSide(color: theme.borderColor)),
              ),
              child: palette,
            ),
          Expanded(child: ClipRect(child: canvas)),
          if (panel != null)
            Container(
              width: panelWidth,
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                border: Border(left: BorderSide(color: theme.borderColor)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _panelHeader(theme),
                  Expanded(child: panel!),
                ],
              ),
            ),
        ],
      );

  Widget _compact(CLTheme theme, BoxConstraints constraints) {
    final maxSheet = constraints.hasBoundedHeight ? constraints.maxHeight * kCLNodeSheetMaxHeightFactor : double.infinity;
    return Stack(
      children: [
        Positioned.fill(child: ClipRect(child: canvas)),
        if (palette != null) Positioned(top: theme.gapMd, left: theme.gapMd, child: palette!),
        if (panel != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheet),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusModal)),
                  border: Border(top: BorderSide(color: theme.borderColor)),
                  boxShadow: theme.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Maniglia del foglio.
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: theme.gapSm),
                        width: theme.gap3Xl,
                        height: theme.gapXs,
                        decoration: BoxDecoration(
                          color: theme.borderColor,
                          borderRadius: BorderRadius.circular(theme.radiusChip),
                        ),
                      ),
                    ),
                    _panelHeader(theme),
                    Flexible(child: panel!),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _panelHeader(CLTheme theme) {
    if (panelTitle == null && onPanelClose == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(theme.gapLg, theme.gapMd, theme.gapSm, theme.gapSm),
      child: Row(children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(panelTitle ?? '', style: theme.bodyLabel),
          ),
        ),
        if (onPanelClose != null)
          IconButton(
            tooltip: closeTooltip,
            onPressed: onPanelClose,
            iconSize: theme.iconSizeCompact,
            icon: Icon(Icons.close, color: theme.mutedForeground),
          ),
      ]),
    );
  }
}
