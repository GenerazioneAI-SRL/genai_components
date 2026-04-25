import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Horizontal paginated slider — v3 design system.
///
/// Renders one page at a time with optional peek of neighbouring items
/// (`viewportFraction`), arrow navigation on desktop, indicator dots, and
/// auto-play. Keyboard `←` / `→` shifts pages when focused.
///
/// Auto-play and page animation are disabled when the user prefers reduced
/// motion (§5).
class GenaiCarousel extends StatefulWidget {
  /// Pages rendered inside the viewport.
  final List<Widget> items;

  /// Fraction of the viewport taken by each page. Use `<1` to peek at
  /// neighbours. Must be in `(0, 1]`.
  final double viewportFraction;

  /// Auto-advance on a timer.
  final bool autoPlay;

  /// Interval between auto-advances. Ignored when [autoPlay] is false.
  final Duration autoPlayInterval;

  /// Whether to render the indicator dots below the viewport.
  final bool showIndicators;

  /// Whether to render chevron arrows (desktop window sizes only).
  final bool showArrows;

  /// Notifies on every page change.
  final ValueChanged<int>? onPageChanged;

  /// Accessibility label. Falls back to a generic descriptor.
  final String? semanticLabel;

  const GenaiCarousel({
    super.key,
    required this.items,
    this.viewportFraction = 0.9,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.showArrows = true,
    this.onPageChanged,
    this.semanticLabel,
  }) : assert(
          viewportFraction > 0 && viewportFraction <= 1,
          'viewportFraction must be in (0, 1]',
        );

  @override
  State<GenaiCarousel> createState() => _GenaiCarouselState();
}

class _GenaiCarouselState extends State<GenaiCarousel> {
  late final PageController _controller;
  late final FocusNode _focusNode;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
    _focusNode = FocusNode(debugLabel: 'GenaiCarousel');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _restartAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant GenaiCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    if (!widget.autoPlay) return;
    if (GenaiResponsive.reducedMotion(context)) return;
    if (widget.items.length < 2) return;
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      final next = (_currentPage + 1) % widget.items.length;
      _animateTo(next);
    });
  }

  void _animateTo(int index) {
    if (!mounted) return;
    final reduced = GenaiResponsive.reducedMotion(context);
    final motion = context.motion.page;
    if (reduced) {
      _controller.jumpToPage(index);
      return;
    }
    _controller.animateToPage(
      index,
      duration: motion.duration,
      curve: motion.curve,
    );
  }

  void _goPrev() {
    final i = _currentPage == 0 ? widget.items.length - 1 : _currentPage - 1;
    _animateTo(i);
  }

  void _goNext() {
    final i = (_currentPage + 1) % widget.items.length;
    _animateTo(i);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _goPrev();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _goNext();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final isDesktop = !context.isCompact;
    final showArrows =
        widget.showArrows && isDesktop && widget.items.length > 1;

    Widget arrow({required bool isLeft}) {
      final icon = isLeft ? LucideIcons.chevronLeft : LucideIcons.chevronRight;
      return Semantics(
        button: true,
        label: isLeft ? 'Precedente' : 'Successivo',
        child: InkWell(
          onTap: isLeft ? _goPrev : _goNext,
          borderRadius: BorderRadius.circular(radius.pill),
          child: Container(
            width: sizing.minTouchTarget,
            height: sizing.minTouchTarget,
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              border: Border.all(color: colors.borderDefault),
              shape: BoxShape.circle,
              boxShadow: context.elevation.layer2,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: sizing.iconSize, color: colors.textPrimary),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Carousel',
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: widget.items.length,
                    onPageChanged: (i) {
                      setState(() => _currentPage = i);
                      widget.onPageChanged?.call(i);
                    },
                    itemBuilder: (ctx, i) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s8),
                      child: widget.items[i],
                    ),
                  ),
                  if (showArrows)
                    Positioned(
                      left: spacing.s8,
                      top: 0,
                      bottom: 0,
                      child: Center(child: arrow(isLeft: true)),
                    ),
                  if (showArrows)
                    Positioned(
                      right: spacing.s8,
                      top: 0,
                      bottom: 0,
                      child: Center(child: arrow(isLeft: false)),
                    ),
                ],
              ),
            ),
            if (widget.showIndicators && widget.items.length > 1) ...[
              SizedBox(height: spacing.s8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s2),
                      child: AnimatedContainer(
                        duration: context.motion.hover.duration,
                        curve: context.motion.hover.curve,
                        width: _currentPage == i ? spacing.s16 : spacing.s8,
                        height: spacing.s8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? colors.textPrimary
                              : colors.borderDefault,
                          borderRadius: BorderRadius.circular(radius.pill),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
