import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/pageaction.model.dart';
import '../router/go_router_modular/module_color_registry.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Header contestuale editorial per ogni pagina.
///
/// Layout: pill badge leading (icon, opz.) → titolo hero Satoshi → subtitle
/// paragrafo → cluster azioni a destra → bottom divider.
/// Nessuna card chrome: il header siede direttamente sul page background.
///
/// Public API invariata:
/// - [icon]: icona HugeIcon → renderizzata dentro pill leading
/// - [title] / [titleWidget]: titolo hero
/// - [subtitle] / [subtitleWidget]: paragrafo descrittivo sotto al titolo
/// - [trailing]: widget custom a destra (prioritario su pageActions)
/// - [pageActions]: lista [PageAction] right-aligned
/// - [color]: tinta accent del pill (default: theme.primary)
/// - [showOnDesktop]: se mostrare su desktop (default: true)
/// - [animate]: flag preservato (no-op visivo)
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
    this.pageActions,
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
  final List<PageAction>? pageActions;
  final Color? color;
  final ScrollController? scrollController;
  final bool showOnDesktop;
  final bool animate;

  @override
  State<CLPageHeader> createState() => _CLPageHeaderState();
}

class _CLPageHeaderState extends State<CLPageHeader> {
  static const double _narrowBreakpoint = 720.0;

  final GlobalKey _cardKey = GlobalKey();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibility());
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
    try {
      context.read<NavigationState>().headerTitleVisible.value = false;
    } catch (_) {}
    super.dispose();
  }

  void _onScroll() => _updateVisibility();

  void _updateVisibility() {
    if (!mounted) return;
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final cardBottom = pos.dy + box.size.height;
    final isVisible = cardBottom > CLSizes.headerOffset;

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
    final isMobile = !isDesktop;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < _narrowBreakpoint;
        final inner = _buildHeader(theme: theme, isMobile: isMobile, isNarrow: isNarrow);

        if (isMobile) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isVisible ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              offset: _isVisible ? Offset.zero : const Offset(0, -0.1),
              child: inner,
            ),
          );
        }

        return inner;
      },
    );
  }

  Widget _buildHeader({
    required CLTheme theme,
    required bool isMobile,
    required bool isNarrow,
  }) {
    final accent = widget.color ?? _moduleAccent(context) ?? theme.primary;
    final actionsWidget = widget.trailing ?? widget.actions ?? _buildPageActions(context, theme, isMobile);
    final pill = _buildPill(theme: theme, accent: accent);
    final title = _buildTitle(theme: theme, isMobile: isMobile, accent: accent);
    final subtitle = _buildSubtitle(theme: theme);

    return Container(
      key: _cardKey,
      padding: EdgeInsets.fromLTRB(
        0,
        isMobile ? CLSizes.gapXl : CLSizes.gap3Xl,
        0,
        isMobile ? CLSizes.gapLg : CLSizes.gap2Xl,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pill != null || widget.leading != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  SizedBox(width: pill != null ? CLSizes.gapMd : 0),
                ],
                if (pill != null) Flexible(child: pill),
              ],
            ),
            SizedBox(height: isMobile ? CLSizes.gapMd : CLSizes.gapLg),
          ],
          if (isNarrow || actionsWidget == null) ...[
            if (title != null) title,
            if (subtitle != null) ...[
              const SizedBox(height: CLSizes.gapSm),
              subtitle,
            ],
            if (actionsWidget != null) ...[
              SizedBox(height: isMobile ? CLSizes.gapLg : CLSizes.gapXl),
              actionsWidget,
            ],
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) title,
                      if (subtitle != null) ...[
                        const SizedBox(height: CLSizes.gapSm),
                        subtitle,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: CLSizes.gap2Xl),
                actionsWidget,
              ],
            ),
        ],
      ),
    );
  }

  Widget? _buildPill({required CLTheme theme, required Color accent}) {
    final crumbs = _moduleCrumbLabels(context);
    if (crumbs.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSizes.gapMd,
        vertical: CLSizes.gapXs + 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CLSizes.radiusChip + 2),
      ),
      child: Text(
        crumbs.map((s) => s.toUpperCase()).join(' · '),
        style: theme.smallLabel.copyWith(
          color: accent,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  List<String> _moduleCrumbLabels(BuildContext context) {
    try {
      final nav = context.read<NavigationState>();
      final crumbs = nav.breadcrumbs.where((b) => b.isModule).map((b) => b.name).toList();
      return crumbs;
    } catch (_) {
      return const [];
    }
  }

  /// Cerca la tinta del modulo corrente: prima nel breadcrumb (path del modulo
  /// più recente), poi sulla location di GoRouter.
  Color? _moduleAccent(BuildContext context) {
    try {
      final nav = context.read<NavigationState>();
      final modulePaths = nav.breadcrumbs.where((b) => b.isModule).map((b) => b.path).toList();
      for (final path in modulePaths.reversed) {
        final c = ModuleColorRegistry.colorFor(path);
        if (c != null) return c;
      }
    } catch (_) {}
    try {
      final location = GoRouterState.of(context).matchedLocation;
      return ModuleColorRegistry.colorForLocation(location);
    } catch (_) {
      return null;
    }
  }

  Widget? _buildTitle({required CLTheme theme, required bool isMobile, required Color accent}) {
    if (widget.titleWidget != null) return widget.titleWidget!;
    if (widget.title == null || widget.title!.isEmpty) return null;

    final base = isMobile ? theme.heading3 : theme.heading2;
    return Text(
      widget.title!,
      style: base.copyWith(color: theme.primaryText, height: 1.15),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  Widget? _buildSubtitle({required CLTheme theme}) {
    if (widget.subtitleWidget != null) return widget.subtitleWidget!;
    if (widget.subtitle == null || widget.subtitle!.isEmpty) return null;

    return Text(
      widget.subtitle!,
      style: theme.bodyText.copyWith(color: theme.secondaryText, height: 1.5),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Renderizza la lista [pageActions] in una Row con gap [CLSizes.gapMd].
  Widget? _buildPageActions(BuildContext context, CLTheme theme, bool isMobile) {
    final actions = widget.pageActions;
    if (actions == null || actions.isEmpty) return null;

    if (actions.length == 1) {
      return actions.first.toWidget(context);
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: CLSizes.gapMd),
          actions[i].toWidget(context),
        ],
      ],
    );

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: row,
      );
    }

    return row;
  }
}
