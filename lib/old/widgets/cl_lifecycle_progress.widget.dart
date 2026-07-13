import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLLifecycleProgress — barra orizzontale che mostra gli step di un flusso con stato.
///
/// Ogni step ha un'icona, label e colore. Lo step corrente è evidenziato.
class CLLifecycleProgress extends StatelessWidget {
  final List<LifecycleStep> steps;
  final int currentIndex;

  const CLLifecycleProgress({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Sizes.padding, horizontal: Sizes.padding),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepBefore = i ~/ 2;
            final isDone = stepBefore < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? steps[stepBefore].color : theme.borderColor.withValues(alpha: 0.3),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final step = steps[stepIndex];
          final isCurrent = stepIndex == currentIndex;
          final isDone = stepIndex < currentIndex;
          final isFuture = stepIndex > currentIndex;

          return _StepDot(
            step: step,
            isCurrent: isCurrent,
            isDone: isDone,
            isFuture: isFuture,
            theme: theme,
            isDark: isDark,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final LifecycleStep step;
  final bool isCurrent;
  final bool isDone;
  final bool isFuture;
  final CLTheme theme;
  final bool isDark;

  const _StepDot({
    required this.step,
    required this.isCurrent,
    required this.isDone,
    required this.isFuture,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFuture ? theme.secondaryText.withValues(alpha: 0.4) : step.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 40 : 32,
          height: isCurrent ? 40 : 32,
          decoration: BoxDecoration(
            color: isDone
                ? color
                : isCurrent
                    ? color.withValues(alpha: 0.15)
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isCurrent ? 2.5 : 1.5,
            ),
            boxShadow: isCurrent
                ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, spreadRadius: 1)]
                : null,
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, color: Colors.white, size: Sizes.iconSizeCompact)
                : HugeIcon(icon: step.icon, color: color, size: isCurrent ? 18 : 14),
          ),
        ),
        SizedBox(height: theme.gapIconText),
        Text(
          step.label,
          style: TextStyle(
            fontSize: isCurrent ? 11 : 10,
            fontWeight: isCurrent ? FontWeight.w700 : (isDone ? FontWeight.w500 : FontWeight.w400),
            color: isFuture ? theme.secondaryText.withValues(alpha: 0.4) : color,
          ),
          textAlign: TextAlign.center,
        ),
        if (isCurrent && step.description != null) ...[
          const SizedBox(height: 2),
          Text(
            step.description!,
            style: TextStyle(fontSize: 9, color: theme.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class LifecycleStep {
  final String label;
  final String? description;
  final dynamic icon;
  final Color color;

  const LifecycleStep({
    required this.label,
    this.description,
    required this.icon,
    required this.color,
  });
}

