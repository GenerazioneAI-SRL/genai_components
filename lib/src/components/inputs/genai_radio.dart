import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// A single option inside a [GenaiRadio] group.
class GenaiRadioOption<T> {
  /// The value this option represents.
  final T value;

  /// Primary label.
  final String label;

  /// Optional secondary line under [label].
  final String? description;

  /// When true, this option is disabled regardless of the group's state.
  final bool isDisabled;

  const GenaiRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.isDisabled = false,
  });
}

/// Single-choice radio group — v3 Forma LMS (§5 field rules).
///
/// Renders a vertical (default) or horizontal cluster of [GenaiRadioOption]s
/// with a shared [value] + [onChanged] pair. Options announce themselves as
/// being in a mutually-exclusive group for assistive tech.
class GenaiRadio<T> extends StatelessWidget {
  /// Currently selected value. `null` means nothing is selected.
  final T? value;

  /// Options to render.
  final List<GenaiRadioOption<T>> options;

  /// Fired with the picked value.
  final ValueChanged<T>? onChanged;

  /// Disables the whole group.
  final bool isDisabled;

  /// Error state — danger ring on every option.
  final bool hasError;

  /// Layout axis; defaults to vertical.
  final Axis direction;

  const GenaiRadio({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.isDisabled = false,
    this.hasError = false,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final tiles = options
        .map((o) => _GenaiRadioTile<T>(
              option: o,
              selected: o.value == value,
              disabled: isDisabled || o.isDisabled,
              hasError: hasError,
              onTap: () => onChanged?.call(o.value),
            ))
        .toList();

    final Widget layout = direction == Axis.horizontal
        ? Wrap(
            spacing: spacing.s16,
            runSpacing: spacing.s8,
            children: tiles,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) SizedBox(height: spacing.s8),
                tiles[i],
              ],
            ],
          );

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: layout,
      ),
    );
  }
}

class _GenaiRadioTile<T> extends StatefulWidget {
  final GenaiRadioOption<T> option;
  final bool selected;
  final bool disabled;
  final bool hasError;
  final VoidCallback onTap;

  const _GenaiRadioTile({
    required this.option,
    required this.selected,
    required this.disabled,
    required this.hasError,
    required this.onTap,
  });

  @override
  State<_GenaiRadioTile<T>> createState() => _GenaiRadioTileState<T>();
}

class _GenaiRadioTileState<T> extends State<_GenaiRadioTile<T>> {
  bool _focused = false;
  bool _hovered = false;

  // Task spec §5: 18 px circle, ink border, dot `colorPrimary`.
  static const double _outer = 18;
  static const double _inner = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;

    final ringColor = widget.selected
        ? (widget.hasError ? colors.colorDanger : colors.colorPrimary)
        : (widget.hasError
            ? colors.colorDanger
            : _hovered && !widget.disabled
                ? colors.colorPrimaryHover
                : colors.textPrimary);

    final dotColor = widget.hasError ? colors.colorDanger : colors.colorPrimary;

    Widget radio = AnimatedContainer(
      duration: motion.press.duration,
      curve: motion.press.curve,
      width: _outer,
      height: _outer,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: motion.press.duration,
        curve: motion.press.curve,
        width: widget.selected ? _inner : 0,
        height: widget.selected ? _inner : 0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dotColor,
        ),
      ),
    );

    if (_focused && !widget.disabled) {
      radio = Container(
        padding: EdgeInsets.all(sizing.focusRingOffset),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.hasError ? colors.colorDanger : colors.borderFocus,
            width: sizing.focusRingWidth,
          ),
        ),
        child: radio,
      );
    }

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1.0,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: widget.disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.disabled ? null : widget.onTap,
            child: Semantics(
              checked: widget.selected,
              inMutuallyExclusiveGroup: true,
              label: widget.option.label,
              hint: widget.option.description,
              enabled: !widget.disabled,
              focused: _focused,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    radio,
                    SizedBox(width: spacing.iconLabelGap),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.option.label,
                              style: ty.label.copyWith(
                                color: widget.disabled
                                    ? colors.textDisabled
                                    : colors.textPrimary,
                              )),
                          if (widget.option.description != null)
                            Padding(
                              padding: EdgeInsets.only(top: spacing.s2),
                              child: Text(widget.option.description!,
                                  style: ty.bodySm
                                      .copyWith(color: colors.textTertiary)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
