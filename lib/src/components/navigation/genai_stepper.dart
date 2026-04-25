import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Layout direction for a [GenaiStepper].
enum GenaiStepperOrientation { horizontal, vertical }

/// Single step descriptor.
@immutable
class GenaiStepperStep {
  /// Step title rendered next to the indicator.
  final String title;

  /// Optional secondary copy rendered below the title.
  final String? description;

  /// Optional icon rendered inside the indicator instead of the numeric index.
  final IconData? icon;

  /// When true the step is drawn with danger tokens.
  final bool hasError;

  const GenaiStepperStep({
    required this.title,
    this.description,
    this.icon,
    this.hasError = false,
  });
}

/// Stepper / wizard — v3 design system.
///
/// Completed steps use `colorPrimary` (ink); the active step is filled; error
/// steps use `colorDanger`; upcoming steps render on `borderDefault`.
class GenaiStepper extends StatelessWidget {
  /// Ordered step list.
  final List<GenaiStepperStep> steps;

  /// Index of the currently active step (0-based).
  final int currentStep;

  /// Layout direction.
  final GenaiStepperOrientation orientation;

  /// Fires when the user taps a step indicator.
  final ValueChanged<int>? onStepTap;

  /// Accessibility override.
  final String? semanticLabel;

  const GenaiStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.orientation = GenaiStepperOrientation.horizontal,
    this.onStepTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return Semantics(
      container: true,
      label: semanticLabel ?? 'Stepper',
      child: orientation == GenaiStepperOrientation.horizontal
          ? _buildHorizontal(context)
          : _buildVertical(context),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      children.add(
        _StepIndicator(
          index: i,
          step: steps[i],
          currentStep: currentStep,
          onTap: onStepTap,
          totalSteps: steps.length,
          compact: false,
        ),
      );
      if (i < steps.length - 1) {
        children.add(
          Expanded(
            child: Container(
              height: sizing.dividerThickness,
              color:
                  i < currentStep ? colors.colorPrimary : colors.borderDefault,
              margin: EdgeInsets.symmetric(horizontal: spacing.s4),
            ),
          ),
        );
      }
    }
    return Row(children: children);
  }

  Widget _buildVertical(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
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
                    _StepIndicator(
                      index: i,
                      step: steps[i],
                      currentStep: currentStep,
                      onTap: onStepTap,
                      totalSteps: steps.length,
                      compact: true,
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          width: sizing.dividerThickness,
                          color: i < currentStep
                              ? colors.colorPrimary
                              : colors.borderDefault,
                          margin: EdgeInsets.symmetric(vertical: spacing.s4),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i == steps.length - 1 ? 0 : spacing.s16,
                    ),
                    child: _StepLabel(
                      step: steps[i],
                      index: i,
                      currentStep: currentStep,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int index;
  final GenaiStepperStep step;
  final int currentStep;
  final int totalSteps;
  final bool compact;
  final ValueChanged<int>? onTap;

  const _StepIndicator({
    required this.index,
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final sizing = context.sizing;

    final done = index < currentStep;
    final active = index == currentStep;
    final error = step.hasError;

    Color bg;
    Color fg;
    Color border;
    if (error) {
      bg = colors.colorDangerSubtle;
      fg = colors.colorDangerText;
      border = colors.colorDanger;
    } else if (done) {
      bg = colors.colorPrimary;
      fg = colors.textOnPrimary;
      border = colors.colorPrimary;
    } else if (active) {
      bg = colors.colorInfoSubtle;
      fg = colors.colorInfo;
      border = colors.colorInfo;
    } else {
      bg = colors.surfaceCard;
      fg = colors.textTertiary;
      border = colors.borderDefault;
    }

    final size = sizing.iconSize + 12;

    final iconOrNumber = error
        ? Icon(LucideIcons.triangleAlert, size: sizing.iconSize - 2, color: fg)
        : done
            ? Icon(LucideIcons.check, size: sizing.iconSize - 2, color: fg)
            : step.icon != null
                ? Icon(step.icon, size: sizing.iconSize - 2, color: fg)
                : Text(
                    '${index + 1}',
                    style: ty.label.copyWith(color: fg),
                  );

    final indicator = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: sizing.dividerThickness + 1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: iconOrNumber,
    );

    final row = compact
        ? indicator
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              SizedBox(width: context.spacing.s8),
              _StepLabel(step: step, index: index, currentStep: currentStep),
            ],
          );

    return Semantics(
      button: onTap != null,
      selected: active,
      label: 'Step ${index + 1} of $totalSteps, ${step.title}',
      child: MouseRegion(
        cursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap == null ? null : () => onTap!(index),
          child: row,
        ),
      ),
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
    final error = step.hasError;
    final titleColor = error
        ? colors.colorDangerText
        : (active ? colors.textPrimary : colors.textSecondary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: ty.label.copyWith(
            color: titleColor,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        if (step.description != null) ...[
          SizedBox(height: context.spacing.s2),
          Text(
            step.description!,
            style: ty.bodySm.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }
}
