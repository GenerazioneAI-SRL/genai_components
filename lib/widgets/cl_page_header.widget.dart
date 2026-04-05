import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Header contestuale da usare in ogni pagina.
///
/// Supporta:
/// - [leading]: widget opzionale all'inizio (prima dell'icona)
/// - [icon]: icona HugeIcon con container colorato e animazione pulse
/// - [title] / [titleWidget]: titolo come stringa o widget custom
/// - [subtitle] / [subtitleWidget]: sottotitolo come stringa o widget custom
/// - [trailing] / [actions]: widget a destra (spaceBetween con il resto)
/// - [color]: colore base per gradiente e icona (default: theme.primary)
/// - [showOnDesktop]: se mostrare su desktop (default: false)
/// - [animate]: se abilitare le animazioni (default: true)
class CLPageHeader extends StatefulWidget {
  const CLPageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.trailing,
    this.actions,
    this.color,
    this.scrollController,
    this.showOnDesktop = true,
    this.animate = false,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final dynamic icon;
  final Widget? leading;
  final Widget? trailing;
  final Widget? actions;
  final Color? color;
  final ScrollController? scrollController;
  final bool showOnDesktop;
  final bool animate;

  @override
  State<CLPageHeader> createState() => _CLPageHeaderState();
}

class _CLPageHeaderState extends State<CLPageHeader> with TickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  bool _isVisible = true;

  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibility());

    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.1, 0.9, curve: Curves.easeOut)));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    if (widget.animate) {
      _entryController.forward();
      _pulseController.repeat(reverse: true);
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CLPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _entryController.dispose();
    _pulseController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      try {
        context.read<NavigationState>().headerTitleVisible.value = false;
      } catch (_) {}
    });
    super.dispose();
  }

  void _onScroll() => _updateVisibility();

  void _updateVisibility() {
    if (!mounted) return;
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final cardBottom = pos.dy + box.size.height;
    final isVisible = cardBottom > Sizes.headerOffset;

    if (isVisible != _isVisible) {
      setState(() => _isVisible = isVisible);
      try {
        context.read<NavigationState>().headerTitleVisible.value = !isVisible;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    if (isDesktop && !widget.showOnDesktop) return const SizedBox.shrink();

    final theme = CLTheme.of(context);

    return _buildHeader(context: context, theme: theme, isMobile: !isDesktop);
  }

  Widget _buildHeader({required BuildContext context, required CLTheme theme, required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = widget.color ?? theme.primary;

    // ── Dimensioni più bilanciate ──
    final iconBoxSize = isMobile ? 44.0 : 52.0;
    final iconSize = isMobile ? 22.0 : 26.0;
    final hPadding = isMobile ? Sizes.padding : Sizes.padding * 1.25;
    final vPadding = isMobile ? Sizes.padding : Sizes.padding * 1.1;

    final trailingWidget = widget.trailing ?? widget.actions;

    final container = AnimatedContainer(
      key: _cardKey,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [baseColor.withValues(alpha: 0.12), baseColor.withValues(alpha: 0.04)]
                  : [baseColor.withValues(alpha: 0.08), baseColor.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border.all(color: theme.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Leading ──
          if (widget.leading != null) ...[widget.leading!, SizedBox(width: isMobile ? Sizes.padding * 0.75 : Sizes.padding)],

          // ── Icona ──
          if (widget.icon != null) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.animate ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [baseColor.withValues(alpha: isDark ? 0.35 : 0.18), baseColor.withValues(alpha: isDark ? 0.2 : 0.08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Sizes.borderRadius - 2),
                    ),
                    child: Center(child: HugeIcon(icon: widget.icon, color: isDark ? baseColor.withValues(alpha: 0.9) : baseColor, size: iconSize)),
                  ),
                );
              },
            ),
            SizedBox(width: isMobile ? Sizes.padding * 0.85 : Sizes.padding * 1.1),
          ],

          // ── Titolo + Sottotitolo ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.titleWidget != null)
                  widget.titleWidget!
                else if (widget.title != null && widget.title!.isNotEmpty)
                  Text(
                    widget.title!,
                    style: (isMobile ? theme.heading6 : theme.heading5).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: theme.primaryText,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                if (widget.subtitleWidget != null) ...[
                  SizedBox(height: isMobile ? 4 : 6),
                  widget.subtitleWidget!,
                ] else if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    widget.subtitle!,
                    style: theme.bodyLabel.copyWith(
                      color: theme.secondaryText.withValues(alpha: 0.8),
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),

          // ── Trailing / Actions ──
          if (trailingWidget != null) ...[
            SizedBox(width: isMobile ? Sizes.padding * 0.75 : Sizes.padding),
            trailingWidget,
          ],
        ],
      ),
    );

    // Entry animation
    Widget animatedContainer = AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: ScaleTransition(scale: _scaleAnimation, child: child)),
        );
      },
      child: container,
    );

    if (isMobile) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isVisible ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          offset: _isVisible ? Offset.zero : const Offset(0, -0.1),
          child: animatedContainer,
        ),
      );
    }

    return animatedContainer;
  }
}

