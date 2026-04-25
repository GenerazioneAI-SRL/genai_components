import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Thin themed scrollbar wrapper — v3 design system.
///
/// Renders a 2 px idle thumb that expands to 8 px on hover. The thumb color
/// follows `borderStrong` (`--line-2`) idle and `textTertiary` (`--ink-3`)
/// on hover, matching the `.scroll-area` treatment in the Forma LMS HTML.
/// Pass a scrollable child; if none is provided, a [SingleChildScrollView]
/// is composed around [child].
class GenaiScrollArea extends StatefulWidget {
  /// Scrollable (or non-scrollable) child.
  final Widget child;

  /// Scroll axis. Defaults to vertical.
  final Axis axis;

  /// When true, wraps [child] in a [SingleChildScrollView]; when false the
  /// consumer provides a scrollable (ListView, CustomScrollView, …) directly.
  final bool wrapWithScrollView;

  /// Optional controller — only used when [wrapWithScrollView] is true.
  final ScrollController? controller;

  /// Interior padding when wrapping in a scroll view.
  final EdgeInsetsGeometry? padding;

  const GenaiScrollArea({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.wrapWithScrollView = false,
    this.controller,
    this.padding,
  });

  @override
  State<GenaiScrollArea> createState() => _GenaiScrollAreaState();
}

class _GenaiScrollAreaState extends State<GenaiScrollArea> {
  late ScrollController _controller;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
  }

  @override
  void didUpdateWidget(GenaiScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? ScrollController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    final child = widget.wrapWithScrollView
        ? SingleChildScrollView(
            controller: _controller,
            scrollDirection: widget.axis,
            padding: widget.padding,
            child: widget.child,
          )
        : widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: RawScrollbar(
        controller: widget.wrapWithScrollView ? _controller : null,
        thumbVisibility: _hovered,
        trackVisibility: _hovered,
        thickness: _hovered ? 8 : 2,
        radius: Radius.circular(radius.pill),
        thumbColor: _hovered ? colors.textTertiary : colors.borderStrong,
        trackColor: colors.surfaceHover,
        trackBorderColor: Colors.transparent,
        fadeDuration: const Duration(milliseconds: 300),
        timeToFade: const Duration(seconds: 1),
        pressDuration: Duration.zero,
        child: child,
      ),
    );
  }
}
