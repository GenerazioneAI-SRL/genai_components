import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Tri-state checkbox (`null` = indeterminate). §6.1.4
class GenaiCheckbox extends StatefulWidget {
  /// Pass `null` for the indeterminate state.
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? description;
  final bool isDisabled;
  final bool hasError;
  final GenaiSize size;

  const GenaiCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isDisabled = false,
    this.hasError = false,
    this.size = GenaiSize.sm,
  });

  @override
  State<GenaiCheckbox> createState() => _GenaiCheckboxState();
}

class _GenaiCheckboxState extends State<GenaiCheckbox> {
  bool _focused = false;

  void _toggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    final next = widget.value == true ? false : true;
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final box = 16.0;
    final fillColor = widget.hasError ? colors.colorError : colors.colorPrimary;
    final isChecked = widget.value == true;
    final isIndeterminate = widget.value == null;
    final filled = isChecked || isIndeterminate;

    Widget checkbox = AnimatedContainer(
      duration: GenaiDurations.checkboxCheck,
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: filled ? fillColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: filled ? fillColor : (widget.hasError ? colors.borderError : colors.borderStrong),
          width: 1.5,
        ),
      ),
      child: filled
          ? Icon(
              isIndeterminate ? LucideIcons.minus : LucideIcons.check,
              size: 12,
              color: Colors.white,
            )
          : null,
    );

    if (_focused && !widget.isDisabled) {
      checkbox = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.borderFocus, width: 2),
        ),
        child: checkbox,
      );
    }

    final hasText = widget.label != null || widget.description != null;
    Widget content = checkbox;
    if (hasText) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null) Text(widget.label!, style: ty.label.copyWith(color: colors.textPrimary)),
                if (widget.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(widget.description!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Opacity(
      opacity: widget.isDisabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Semantics(
              checked: isChecked,
              mixed: isIndeterminate,
              enabled: !widget.isDisabled,
              label: widget.label,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
