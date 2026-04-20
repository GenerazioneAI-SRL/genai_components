import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/colors.dart';

/// Continuous-value slider (§6.1.7).
class GenaiSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String Function(double)? tooltipBuilder;
  final bool showLabels;
  final bool isDisabled;

  const GenaiSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.tooltipBuilder,
    this.showLabels = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    final slider = SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: colors.colorPrimary,
        inactiveTrackColor: colors.borderDefault,
        thumbColor: Colors.white,
        thumbShape: _GenaiThumbShape(borderColor: colors.colorPrimary),
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorColor: GenaiColorsPrimitive.neutral900,
        valueIndicatorTextStyle: ty.bodySm.copyWith(color: Colors.white),
        showValueIndicator: ShowValueIndicator.onlyForContinuous,
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: tooltipBuilder?.call(value) ?? value.toStringAsFixed(1),
        onChanged: isDisabled ? null : onChanged,
        onChangeEnd: isDisabled ? null : onChangeEnd,
      ),
    );

    if (!showLabels) return slider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slider,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(min.toStringAsFixed(0), style: ty.caption.copyWith(color: colors.textSecondary)),
              Text(max.toStringAsFixed(0), style: ty.caption.copyWith(color: colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Range (two-thumb) slider.
class GenaiRangeSlider extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final bool isDisabled;

  const GenaiRangeSlider({
    super.key,
    required this.values,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: colors.colorPrimary,
        inactiveTrackColor: colors.borderDefault,
        rangeThumbShape: _GenaiRangeThumbShape(borderColor: colors.colorPrimary),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: RangeSlider(
        values: RangeValues(
          values.start.clamp(min, max),
          values.end.clamp(min, max),
        ),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: isDisabled ? null : onChanged,
        onChangeEnd: isDisabled ? null : onChangeEnd,
      ),
    );
  }
}

class _GenaiThumbShape extends SliderComponentShape {
  final Color borderColor;
  const _GenaiThumbShape({required this.borderColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(10);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final scale = 1 + 0.2 * activationAnimation.value;
    canvas.drawCircle(
      center,
      10 * scale,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      10 * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = borderColor,
    );
  }
}

class _GenaiRangeThumbShape extends RangeSliderThumbShape {
  final Color borderColor;
  const _GenaiRangeThumbShape({required this.borderColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(10);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 10, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = borderColor,
    );
  }
}
