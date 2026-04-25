import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Split direction for [GenaiResizable].
enum GenaiResizableAxis {
  /// Left/right panes with a vertical drag handle.
  horizontal,

  /// Top/bottom panes with a horizontal drag handle.
  vertical,
}

/// Two-panel split with a draggable divider — v3 design system.
///
/// v3 divergence: idle divider is 1 px `--line`; hover swells to 3 px `--ink`
/// per spec, and drag locks in the focus-blue. Ratio is tracked as the
/// fraction of the **first** pane (0..1). Keyboard: when the divider is
/// focused, arrow keys move the split by 5 %.
class GenaiResizable extends StatefulWidget {
  /// First pane (top or left).
  final Widget first;

  /// Second pane (bottom or right).
  final Widget second;

  /// Axis of the split.
  final GenaiResizableAxis axis;

  /// Initial ratio (0..1) of the first pane.
  final double initialRatio;

  /// Minimum ratio for the first pane (guards against 0-size).
  final double minRatio;

  /// Maximum ratio for the first pane.
  final double maxRatio;

  /// Callback fired when the ratio changes.
  final ValueChanged<double>? onRatioChanged;

  /// Accessible label for the drag handle.
  final String semanticLabel;

  const GenaiResizable({
    super.key,
    required this.first,
    required this.second,
    this.axis = GenaiResizableAxis.horizontal,
    this.initialRatio = 0.5,
    this.minRatio = 0.15,
    this.maxRatio = 0.85,
    this.onRatioChanged,
    this.semanticLabel = 'Resize',
  })  : assert(initialRatio > 0 && initialRatio < 1),
        assert(minRatio >= 0 && minRatio < maxRatio),
        assert(maxRatio > minRatio && maxRatio <= 1);

  @override
  State<GenaiResizable> createState() => _GenaiResizableState();
}

class _GenaiResizableState extends State<GenaiResizable> {
  late double _ratio;
  final FocusNode _focusNode = FocusNode(debugLabel: 'GenaiResizable.handle');
  bool _hovered = false;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setRatio(double next) {
    final clamped = next.clamp(widget.minRatio, widget.maxRatio);
    if (clamped == _ratio) return;
    setState(() => _ratio = clamped);
    widget.onRatioChanged?.call(clamped);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    const step = 0.05;
    final horizontal = widget.axis == GenaiResizableAxis.horizontal;
    if (horizontal && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _setRatio(_ratio - step);
      return KeyEventResult.handled;
    }
    if (horizontal && event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _setRatio(_ratio + step);
      return KeyEventResult.handled;
    }
    if (!horizontal && event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _setRatio(_ratio - step);
      return KeyEventResult.handled;
    }
    if (!horizontal && event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _setRatio(_ratio + step);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = widget.axis == GenaiResizableAxis.horizontal;
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = horizontal ? constraints.maxWidth : constraints.maxHeight;
        final firstSize = total * _ratio;
        final secondSize = total - firstSize - _handleThickness(context);

        final handle = _buildHandle(context, horizontal);

        if (horizontal) {
          return Row(
            children: [
              SizedBox(width: firstSize, child: widget.first),
              handle,
              SizedBox(
                width: secondSize.clamp(0.0, total),
                child: widget.second,
              ),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(height: firstSize, child: widget.first),
            handle,
            SizedBox(
              width: double.infinity,
              height: secondSize.clamp(0.0, total),
              child: widget.second,
            ),
          ],
        );
      },
    );
  }

  double _handleThickness(BuildContext context) =>
      context.spacing.s6; // 6 px visual gutter

  Widget _buildHandle(BuildContext context, bool horizontal) {
    final colors = context.colors;
    final sizing = context.sizing;
    final thickness = _handleThickness(context);

    // Idle = 1 px `--line`; hover = 3 px `--ink`; drag = focus blue.
    final lineThickness = _dragging || _hovered ? 3.0 : sizing.dividerThickness;
    final color = _dragging
        ? colors.borderFocus
        : _hovered
            ? colors.textPrimary
            : colors.borderDefault;

    final handleBody = AnimatedContainer(
      duration: context.motion.hover.duration,
      curve: context.motion.hover.curve,
      width: horizontal ? lineThickness : double.infinity,
      height: horizontal ? double.infinity : lineThickness,
      color: color,
    );

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Semantics(
        slider: true,
        label: widget.semanticLabel,
        value: '${(_ratio * 100).round()}%',
        child: MouseRegion(
          cursor: horizontal
              ? SystemMouseCursors.resizeLeftRight
              : SystemMouseCursors.resizeUpDown,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _focusNode.requestFocus(),
            onHorizontalDragStart: horizontal
                ? (_) {
                    setState(() => _dragging = true);
                    _focusNode.requestFocus();
                  }
                : null,
            onHorizontalDragEnd:
                horizontal ? (_) => setState(() => _dragging = false) : null,
            onHorizontalDragUpdate: horizontal
                ? (details) {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final local =
                        renderBox.globalToLocal(details.globalPosition);
                    final total = renderBox.size.width;
                    if (total > 0) _setRatio(local.dx / total);
                  }
                : null,
            onVerticalDragStart: !horizontal
                ? (_) {
                    setState(() => _dragging = true);
                    _focusNode.requestFocus();
                  }
                : null,
            onVerticalDragEnd:
                !horizontal ? (_) => setState(() => _dragging = false) : null,
            onVerticalDragUpdate: !horizontal
                ? (details) {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final local =
                        renderBox.globalToLocal(details.globalPosition);
                    final total = renderBox.size.height;
                    if (total > 0) _setRatio(local.dy / total);
                  }
                : null,
            child: SizedBox(
              width: horizontal ? thickness : null,
              height: horizontal ? null : thickness,
              child: Center(child: handleBody),
            ),
          ),
        ),
      ),
    );
  }
}
