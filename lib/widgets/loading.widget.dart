import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key, this.size = 48.0, this.color, this.showText = false, this.text = 'Caricamento...'});

  final double size;
  final Color? color;
  final bool showText;
  final String text;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _dotsController;

  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(CurvedAnimation(parent: _rotationController, curve: Curves.linear));

    // Dots animation
    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _rotationController.repeat();
    if (widget.showText) _dotsController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final color = widget.color ?? theme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated loader
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: widget.size + 20,
                  height: widget.size + 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: _ArcPainter(color: color, strokeWidth: 3, startAngle: 0, sweepAngle: math.pi * 1.2),
                        ),
                      ),
                      // Inner ring (opposite direction)
                      Transform.rotate(
                        angle: -_rotationAnimation.value * 0.7,
                        child: CustomPaint(
                          size: Size(widget.size * 0.6, widget.size * 0.6),
                          painter: _ArcPainter(color: color.withValues(alpha: 0.5), strokeWidth: 2, startAngle: math.pi, sweepAngle: math.pi * 0.8),
                        ),
                      ),
                      // Center dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Text with animated dots
          if (widget.showText) ...[
            SizedBox(height: Sizes.padding),
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                final dots = '.' * ((_dotsController.value * 3).floor() + 1);
                return Text(
                  '${widget.text.replaceAll('...', '')}$dots',
                  style: theme.bodyLabel.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// Custom painter for arc
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _ArcPainter({required this.color, required this.strokeWidth, required this.startAngle, required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth || oldDelegate.startAngle != startAngle || oldDelegate.sweepAngle != sweepAngle;
  }
}
