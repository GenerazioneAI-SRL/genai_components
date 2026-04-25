part of '../chat_overlay.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Holographic background: animated CustomPaint with grid + particles + scanline.
// Subscribes to an externally-owned ticker (the chat overlay's _bgCtrl).
// ═══════════════════════════════════════════════════════════════════════════════

class _HoloBackground extends StatelessWidget {
  /// Ticker driving the animation (0..1 looping). Owned by the parent.
  final Animation<double> animation;

  /// Render the expensive grid/particles/scanline effects. When false, only
  /// the base gradient is drawn (used when background is mostly transparent
  /// in action mode, for performance).
  final bool drawEffects;

  const _HoloBackground({required this.animation, required this.drawEffects});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder:
            (_, __) => CustomPaint(
              painter: _HoloPainter(animation.value, drawEffects: drawEffects),
              size: Size.infinite,
            ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Holographic background: grid + particles + scan line (CustomPainter).
// ═══════════════════════════════════════════════════════════════════════════════

class _HoloPainter extends CustomPainter {
  final double t;

  /// When false, skip grid/particles/scanline for performance (used when
  /// the background is mostly transparent during action mode).
  final bool drawEffects;
  _HoloPainter(this.t, {this.drawEffects = true});

  static final _rngGrid = math.Random(7);
  static final _gridGlowPoints = List.generate(
    15,
    (_) => [_rngGrid.nextDouble(), _rngGrid.nextDouble()],
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Solid deep background.
    canvas.drawRect(Offset.zero & size, Paint()..color = _bgDeep);

    // Subtle radial gradient glow in upper area.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            const Color(0xFF0D0D28).withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    if (drawEffects) {
      _drawGrid(canvas, size);
      _drawParticles(canvas, size);
      _drawScanLine(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    const spacing = 50.0;
    final paint =
        Paint()
          ..color = _cyan.withValues(alpha: 0.015)
          ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Glow dots at select grid intersections.
    final glowPaint = Paint()..color = _cyan.withValues(alpha: 0.06);
    for (final pt in _gridGlowPoints) {
      final ix = (pt[0] * (size.width / spacing)).floor() * spacing;
      final iy = (pt[1] * (size.height / spacing)).floor() * spacing;
      canvas.drawCircle(Offset(ix, iy), 2.0, glowPaint);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < 28; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.2 + rng.nextDouble() * 0.8;
      final phase = rng.nextDouble() * math.pi * 2;

      final x = baseX + math.sin(t * speed * math.pi * 2 + phase) * 30;
      final y = baseY + math.cos(t * speed * math.pi * 2 * 0.7 + phase) * 20;
      final opacity =
          0.12 + math.sin(t * math.pi * 2 * speed + phase).abs() * 0.2;
      final radius = 1.0 + rng.nextDouble() * 2.0;
      final color = i % 3 == 0 ? _cyan : _accent;

      final pos = Offset(x % size.width, y % size.height);
      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = color.withValues(alpha: opacity),
      );

      // Glow halo for larger particles.
      if (radius > 1.8) {
        canvas.drawCircle(
          pos,
          radius * 3.5,
          Paint()..color = color.withValues(alpha: opacity * 0.12),
        );
      }
    }
  }

  void _drawScanLine(Canvas canvas, Size size) {
    final scanPhase = (t * 3) % 1.0;
    final scanY = scanPhase * (size.height + 80) - 40;

    canvas.drawRect(
      Rect.fromLTWH(0, scanY, size.width, 40),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            _cyan.withValues(alpha: 0.035),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, scanY, size.width, 40)),
    );
  }

  @override
  bool shouldRepaint(_HoloPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Rotating segmented arc rings around the avatar.
// ═══════════════════════════════════════════════════════════════════════════════

class _ArcRingsPainter extends CustomPainter {
  final double t;
  final double ringRadius;
  final int ringCount;

  _ArcRingsPainter({
    required this.t,
    required this.ringRadius,
    this.ringCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // [radiusOffset, speed, color, segments, opacity, strokeWidth]
    final configs = <List<Object>>[
      [0.0, 1.0, _cyan, 3, 0.3, 1.2],
      [-7.0, -0.7, _accent, 4, 0.45, 1.5],
      if (ringCount >= 3) [-14.0, 0.4, _glow, 2, 0.2, 1.0],
    ];

    for (final c in configs) {
      final radius = ringRadius + (c[0] as double);
      final speed = c[1] as double;
      final color = c[2] as Color;
      final segments = c[3] as int;
      final opacity = c[4] as double;
      final strokeW = c[5] as double;

      final paint =
          Paint()
            ..color = color.withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW
            ..strokeCap = StrokeCap.round;

      final segArc = math.pi / (segments * 1.5);
      final gapArc = (2 * math.pi - segArc * segments) / segments;

      for (int i = 0; i < segments; i++) {
        final start = t * speed * 2 * math.pi + i * (segArc + gapArc);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          segArc,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ArcRingsPainter old) => old.t != t;
}
