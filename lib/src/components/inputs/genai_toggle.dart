import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// On/off switch (§6.1.6).
class GenaiToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final bool isDisabled;
  final GenaiSize size;

  const GenaiToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isDisabled = false,
    this.size = GenaiSize.sm,
  });

  @override
  State<GenaiToggle> createState() => _GenaiToggleState();
}

class _GenaiToggleState extends State<GenaiToggle> {
  bool _focused = false;

  void _toggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    HapticFeedback.lightImpact();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    final trackW = 36.0;
    final trackH = 20.0;
    final thumbSize = 16.0;

    final trackColor = widget.value ? colors.colorPrimary : colors.borderStrong;

    Widget toggle = AnimatedContainer(
      duration: GenaiDurations.toggleSlide,
      curve: GenaiCurves.toggle,
      width: trackW,
      height: trackH,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(trackH / 2),
      ),
      alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: thumbSize,
        height: thumbSize,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );

    if (_focused && !widget.isDisabled) {
      toggle = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(trackH / 2 + 2),
          border: Border.all(color: colors.borderFocus, width: 2),
        ),
        child: toggle,
      );
    }

    final hasText = widget.label != null || widget.description != null;
    Widget content = toggle;
    if (hasText) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(width: 12),
          toggle,
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
              toggled: widget.value,
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
