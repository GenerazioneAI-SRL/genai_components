import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

class GenaiRadioOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool isDisabled;

  const GenaiRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.isDisabled = false,
  });
}

/// Single-choice radio group (§6.1.5).
class GenaiRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<GenaiRadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final Axis direction;
  final bool isDisabled;
  final GenaiSize size;

  const GenaiRadioGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.direction = Axis.vertical,
    this.isDisabled = false,
    this.size = GenaiSize.sm,
  });

  @override
  Widget build(BuildContext context) {
    final children = options
        .map((o) => _GenaiRadioTile<T>(
              option: o,
              selected: o.value == value,
              isGroupDisabled: isDisabled,
              onTap: () => onChanged?.call(o.value),
            ))
        .toList();

    if (direction == Axis.horizontal) {
      return Wrap(spacing: 16, runSpacing: 8, children: children);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          children[i],
        ],
      ],
    );
  }
}

class _GenaiRadioTile<T> extends StatefulWidget {
  final GenaiRadioOption<T> option;
  final bool selected;
  final bool isGroupDisabled;
  final VoidCallback? onTap;

  const _GenaiRadioTile({
    required this.option,
    required this.selected,
    required this.isGroupDisabled,
    this.onTap,
  });

  @override
  State<_GenaiRadioTile<T>> createState() => _GenaiRadioTileState<T>();
}

class _GenaiRadioTileState<T> extends State<_GenaiRadioTile<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final disabled = widget.isGroupDisabled || widget.option.isDisabled;
    final ringColor = widget.selected ? colors.colorPrimary : colors.borderStrong;

    Widget radio = AnimatedContainer(
      duration: GenaiDurations.checkboxCheck,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: GenaiDurations.checkboxCheck,
        width: widget.selected ? 8 : 0,
        height: widget.selected ? 8 : 0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.colorPrimary,
        ),
      ),
    );

    if (_focused && !disabled) {
      radio = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderFocus, width: 2),
        ),
        child: radio,
      );
    }

    return Opacity(
      opacity: disabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : widget.onTap,
            child: Semantics(
              checked: widget.selected,
              inMutuallyExclusiveGroup: true,
              label: widget.option.label,
              enabled: !disabled,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  radio,
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.option.label, style: ty.label.copyWith(color: colors.textPrimary)),
                        if (widget.option.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(widget.option.description!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
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
    );
  }
}
