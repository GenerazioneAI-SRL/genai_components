import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Generic elevated card with optional clickable hover/press feedback.
///
/// Public API preserved: same constructor signature, same named params,
/// same field types. Visual upgrade only.
class CLCard extends StatefulWidget {
  final Color color;
  final String title;
  final String subtitle;
  final Function()? onTap;
  final IconData icon;
  final bool vertical;

  const CLCard({
    super.key,
    required this.color,
    required this.title,
    this.onTap,
    required this.icon,
    required this.vertical,
    required this.subtitle,
  });

  @override
  State<CLCard> createState() => _CLCardState();
}

class _CLCardState extends State<CLCard> {
  bool _hovering = false;
  bool _pressed = false;

  static const Duration _kAnim = Duration(milliseconds: 160);
  static const Curve _kCurve = Curves.easeOutCubic;

  void _setHover(bool v) {
    if (widget.onTap == null) return;
    if (_hovering == v) return;
    setState(() => _hovering = v);
  }

  void _setPressed(bool v) {
    if (widget.onTap == null) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final clickable = widget.onTap != null;

    // Hover lift: stronger shadow when hovered.
    final List<BoxShadow> shadow = clickable && _hovering
        ? <BoxShadow>[
            for (final s in theme.cardShadow)
              BoxShadow(
                color: s.color,
                blurRadius: s.blurRadius * 1.6,
                offset: Offset(s.offset.dx, s.offset.dy + 2),
                spreadRadius: s.spreadRadius,
              ),
          ]
        : theme.cardShadow;

    final double scale = _pressed
        ? 0.99
        : (clickable && _hovering ? 1.005 : 1.0);

    Widget content = AnimatedContainer(
      duration: _kAnim,
      curve: _kCurve,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(CLSizes.gapXl),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(CLSizes.radiusCard),
        border: Border.all(color: theme.cardBorder),
        boxShadow: shadow,
      ),
      child: widget.vertical
          ? _VerticalContent(
              color: widget.color,
              icon: widget.icon,
              title: widget.title,
              subtitle: widget.subtitle,
            )
          : _HorizontalContent(
              color: widget.color,
              icon: widget.icon,
              title: widget.title,
              subtitle: widget.subtitle,
            ),
    );

    content = AnimatedScale(
      duration: _kAnim,
      curve: _kCurve,
      scale: scale,
      child: content,
    );

    if (!clickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) {
        _setHover(false);
        _setPressed(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}

class _VerticalContent extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _VerticalContent({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IconBadge(color: color, icon: icon),
          const SizedBox(height: CLSizes.gapLg),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CLSizes.gapXs),
              Text(
                subtitle,
                style: theme.bodyLabel,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HorizontalContent extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _HorizontalContent({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _IconBadge(color: color, icon: icon),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: CLSizes.gapLg,
              right: CLSizes.gapSm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.title,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: CLSizes.gapXs),
                Text(
                  subtitle,
                  style: theme.bodyLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IconBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CLSizes.gapMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CLSizes.radiusControl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.18) ?? color,
          ],
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: CLSizes.iconSizeLarge,
      ),
    );
  }
}
