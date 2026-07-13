import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// Loading placeholder animato stile shadcn.
/// Usa [CLSkeleton] per nuovi componenti; CLShimmer rimane per retrocompatibilità.
class CLSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CLSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius = 4.0,
  });

  /// Shortcut per un blocco rettangolare (es. card, immagine).
  const CLSkeleton.box({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6.0,
  });

  /// Shortcut per un avatar circolare.
  const CLSkeleton.circle({super.key, double size = 40})
      : width = size,
        height = size,
        borderRadius = size / 2;

  @override
  State<CLSkeleton> createState() => _CLSkeletonState();
}

class _CLSkeletonState extends State<CLSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.muted,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
