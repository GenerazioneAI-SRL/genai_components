import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '_dialog_chrome.dart';

/// A dialog that displays a QR code rendered from [data] along with the
/// raw textual payload for accessibility and copy/paste.
///
/// Note: `qr_flutter` is not currently a dependency of `genai_components`.
/// The QR area renders a stylized placeholder. Replace the placeholder with
/// `QrImageView(data: data, size: size)` once `qr_flutter` is added to
/// `pubspec.yaml`.
class QRCodeDialog extends StatelessWidget {
  /// The payload encoded into the QR code (and shown as selectable text).
  final String data;

  /// Optional dialog title. Defaults to `'QR Code'`.
  final String? title;

  /// Optional subtitle/description shown above the QR.
  final String? subtitle;

  /// Edge length in logical pixels of the QR rendering area.
  final double size;

  /// Creates a [QRCodeDialog].
  const QRCodeDialog({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return DialogShell(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: title ?? 'QR Code',
            subtitle: subtitle,
            leading: IconBadge(
              icon: Icons.qr_code_2_rounded,
              color: cl.primary,
              size: 44,
              iconSize: 22,
            ),
            trailing: DialogCloseButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CLSizes.gap2Xl,
              0,
              CLSizes.gap2Xl,
              CLSizes.gap2Xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QRFrame(size: size, data: data),
                const SizedBox(height: CLSizes.gapLg),
                _PayloadCard(data: data),
              ],
            ),
          ),
          DialogFooter(
            actions: [
              CLDialogButton(
                label: 'Copia',
                icon: Icons.copy_rounded,
                tone: CLDialogButtonTone.ghost,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: data));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Codice copiato'),
                        backgroundColor: cl.primary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              CLDialogButton(
                label: 'Chiudi',
                tone: CLDialogButtonTone.primary,
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QRFrame extends StatelessWidget {
  final double size;
  final String data;

  const _QRFrame({required this.size, required this.data});

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(CLSizes.gapLg),
        decoration: BoxDecoration(
          color: cl.secondaryBackground,
          borderRadius: BorderRadius.circular(CLSizes.radiusCard),
          border: Border.all(color: cl.borderColor, width: 1),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Placeholder grid hint — replace with QrImageView once qr_flutter lands.
              CustomPaint(
                size: Size(size, size),
                painter: _QRPlaceholderPainter(
                  baseColor: cl.primaryText.withValues(alpha: 0.12),
                  accentColor: cl.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CLSizes.gapMd,
                  vertical: CLSizes.gapSm,
                ),
                decoration: BoxDecoration(
                  color: cl.secondaryBackground,
                  borderRadius: BorderRadius.circular(CLSizes.radiusChip),
                  border: Border.all(color: cl.borderColor, width: 1),
                ),
                child: Text(
                  'QR',
                  style: cl.heading4.copyWith(
                    color: cl.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QRPlaceholderPainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;

  _QRPlaceholderPainter({required this.baseColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = baseColor;
    final cell = size.width / 21; // mock 21x21 grid
    for (var x = 0; x < 21; x++) {
      for (var y = 0; y < 21; y++) {
        final on = ((x * 31 + y * 17 + (x & y)) & 3) == 0;
        if (on) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cell, y * cell, cell, cell),
              Radius.circular(cell * 0.18),
            ),
            paint,
          );
        }
      }
    }
    // Three corner finder squares (typical QR anchor).
    final anchor = Paint()..color = accentColor.withValues(alpha: 0.85);
    final anchorBg = Paint()..color = accentColor.withValues(alpha: 0.12);
    void drawAnchor(double cx, double cy) {
      final outer = cell * 6;
      final mid = cell * 4.4;
      final inner = cell * 2.4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: outer, height: outer),
          Radius.circular(cell * 1.2),
        ),
        anchorBg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: mid, height: mid),
          Radius.circular(cell * 0.9),
        ),
        Paint()..color = baseColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: inner, height: inner),
          Radius.circular(cell * 0.5),
        ),
        anchor,
      );
    }

    final off = cell * 4;
    drawAnchor(off, off);
    drawAnchor(size.width - off, off);
    drawAnchor(off, size.height - off);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PayloadCard extends StatelessWidget {
  final String data;
  const _PayloadCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: CLSizes.gapLg,
        vertical: CLSizes.gapMd,
      ),
      decoration: BoxDecoration(
        color: cl.muted,
        borderRadius: BorderRadius.circular(CLSizes.radiusControl),
        border: Border.all(color: cl.borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.tag_rounded, size: 14, color: cl.mutedForeground),
          const SizedBox(width: CLSizes.gapSm),
          Expanded(
            child: SelectableText(
              data,
              maxLines: 2,
              style: cl.smallText.copyWith(
                color: cl.secondaryText,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
