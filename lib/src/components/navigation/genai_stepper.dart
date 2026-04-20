import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

enum GenaiStepperOrientation { horizontal, vertical }

class GenaiStepperStep {
  final String title;
  final String? description;
  final IconData? icon;
  final bool hasError;

  const GenaiStepperStep({
    required this.title,
    this.description,
    this.icon,
    this.hasError = false,
  });
}

/// Stepper / wizard (§6.6.4).
class GenaiStepper extends StatelessWidget {
  final List<GenaiStepperStep> steps;
  final int currentStep;
  final GenaiStepperOrientation orientation;
  final ValueChanged<int>? onStepTap;

  const GenaiStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.orientation = GenaiStepperOrientation.horizontal,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation == GenaiStepperOrientation.horizontal) {
      return _buildHorizontal(context);
    }
    return _buildVertical(context);
  }

  Widget _buildHorizontal(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _Indicator(
            index: i,
            step: steps[i],
            currentStep: currentStep,
            onTap: onStepTap,
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < currentStep ? colors.colorPrimary : colors.borderDefault,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildVertical(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _Indicator(
                      index: i,
                      step: steps[i],
                      currentStep: currentStep,
                      onTap: onStepTap,
                      compact: true,
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: i < currentStep ? colors.colorPrimary : colors.borderDefault,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 16),
                    child: _StepLabel(step: steps[i], index: i, currentStep: currentStep),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  final int index;
  final GenaiStepperStep step;
  final int currentStep;
  final ValueChanged<int>? onTap;
  final bool compact;

  const _Indicator({
    required this.index,
    required this.step,
    required this.currentStep,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final completed = index < currentStep;
    final active = index == currentStep;
    Color bg;
    Color fg = Colors.white;
    if (step.hasError) {
      bg = colors.colorError;
    } else if (completed) {
      bg = colors.colorPrimary;
    } else if (active) {
      bg = colors.colorPrimary;
    } else {
      bg = colors.surfaceCard;
      fg = colors.textSecondary;
    }

    Widget circle = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: !completed && !active && !step.hasError ? Border.all(color: colors.borderDefault, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: completed
          ? Icon(LucideIcons.check, size: 16, color: fg)
          : (step.hasError
              ? Icon(LucideIcons.x, size: 16, color: fg)
              : Text('${index + 1}', style: ty.label.copyWith(color: fg, fontWeight: FontWeight.w600))),
    );

    if (onTap != null) {
      circle = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: () => onTap!(index), child: circle),
      );
    }

    if (compact) return circle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(width: 8),
        _StepLabel(step: step, index: index, currentStep: currentStep),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  final GenaiStepperStep step;
  final int index;
  final int currentStep;
  const _StepLabel({
    required this.step,
    required this.index,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final active = index == currentStep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(step.title,
            style: ty.label.copyWith(
                color: step.hasError ? colors.colorError : (active ? colors.textPrimary : colors.textSecondary),
                fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
        if (step.description != null) Text(step.description!, style: ty.caption.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}
