import '../layout/constants/sizes.constant.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pdfrx/pdfrx.dart';
import '../cl_theme.dart';
import 'cl_container.widget.dart';

class CLPdfViewer extends StatelessWidget {
  final String pdfUrl;
  final Future<void> Function()? onDownload;

  const CLPdfViewer({
    super.key,
    required this.pdfUrl,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfViewerController();

    return Center(
      child: CLContainer(
        contentPadding: const EdgeInsets.all(Sizes.padding),
        width: MediaQuery.of(context).size.width * .5,
        height: MediaQuery.of(context).size.height - 200,
        child: Column(
          children: [
            // 🔹 Barra superiore
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Controlli navigazione PDF
                Row(
                  children: [
                    _PdfActionButton(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      tooltip: 'Prima pagina',
                      onPressed: () {
                        if (pdfController.isReady) {
                          pdfController.goToPage(pageNumber: 1);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    _PdfActionButton(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      tooltip: 'Ultima pagina',
                      onPressed: () {
                        if (pdfController.isReady) {
                          pdfController.goToPage(pageNumber: pdfController.pageCount);
                        }
                      },
                    ),
                    const SizedBox(width: Sizes.small),
                    _PdfActionButton(
                      icon: HugeIcons.strokeRoundedZoomOutArea,
                      tooltip: 'Zoom out',
                      onPressed: () {
                        if (pdfController.isReady) pdfController.zoomDown();
                      },
                    ),
                    const SizedBox(width: 4),
                    _PdfActionButton(
                      icon: HugeIcons.strokeRoundedZoomInArea,
                      tooltip: 'Zoom in',
                      onPressed: () {
                        if (pdfController.isReady) pdfController.zoomUp();
                      },
                    ),
                  ],
                ),

                // Pulsanti destra: Download e Chiudi
                Row(
                  children: [
                    _PdfActionButton(
                      icon: HugeIcons.strokeRoundedDownload04,
                      tooltip: 'Scarica PDF',
                      onPressed: () async {
                        if (onDownload != null) await onDownload!();
                      },
                    ),
                    const SizedBox(width: 4),
                    _PdfActionButton(
                      icon: HugeIcons.strokeRoundedCancel01,
                      tooltip: 'Chiudi',
                      isDestructive: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: Sizes.padding),

            // 🔹 Viewer
            Expanded(
              child: PdfViewer.uri(
                Uri.parse(pdfUrl),
                controller: pdfController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget separato per i pulsanti azione del PDF
class _PdfActionButton extends StatefulWidget {
  final dynamic icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _PdfActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  State<_PdfActionButton> createState() => _PdfActionButtonState();
}

class _PdfActionButtonState extends State<_PdfActionButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(Sizes.small / 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? (widget.isDestructive ? CLTheme.of(context).danger.withAlpha(26) : CLTheme.of(context).primary.withAlpha(26))
                  : CLTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
              border: Border.all(
                color: isHovered
                    ? (widget.isDestructive ? CLTheme.of(context).danger : CLTheme.of(context).primary)
                    : CLTheme.of(context).borderColor,
                width: 1,
              ),
            ),
            child: HugeIcon(
              icon: widget.icon,
              color: isHovered
                  ? (widget.isDestructive ? CLTheme.of(context).danger : CLTheme.of(context).primary)
                  : CLTheme.of(context).primaryText,
              size: Sizes.medium,
            ),
          ),
        ),
      ),
    );
  }
}

