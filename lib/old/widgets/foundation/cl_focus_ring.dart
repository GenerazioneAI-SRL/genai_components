import 'package:flutter/material.dart';

/// Focus ring stile shadcn: anello arrotondato disegnato VERSO L'ESTERNO del
/// controllo (gap + spessore), senza occupare spazio nel layout → nessun salto
/// del contenuto quando appare/scompare. Usato dai bottoni CL come
/// `foregroundPainter`, mostrato solo su focus da tastiera (traversal).
class CLFocusRingPainter extends CustomPainter {
  const CLFocusRingPainter({
    required this.color,
    required this.radius,
    this.gap = 2.0,
    this.strokeWidth = 2.0,
    this.inset = false,
  });

  final Color color;
  final double radius;
  final double gap;
  final double strokeWidth;

  /// `true` = anello disegnato **verso l'interno**, a filo del bordo del box
  /// (nessun overflow) → non viene mai tagliato da un ancestor che clippa
  /// (es. campo a filo dentro un `SingleChildScrollView` che scrolla). Usato
  /// dai campi (CLTextField) dove l'halo esterno verrebbe ritagliato.
  final bool inset;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect;
    final double rr;
    if (inset) {
      // Stroke a filo interno: bordo esterno dell'anello sul bordo del box.
      final d = strokeWidth / 2;
      rect = (Offset.zero & size).deflate(d);
      rr = (radius - d).clamp(0.0, radius);
    } else {
      final inflate = gap + strokeWidth / 2;
      rect = (Offset.zero & size).inflate(inflate);
      rr = radius + inflate;
    }
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rr));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CLFocusRingPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth ||
      old.inset != inset;
}
