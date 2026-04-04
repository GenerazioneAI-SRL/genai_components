import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_data.dart';
import '../theme/cl_theme_provider.dart';

/// A single step in a [CLLifecycleProgress] bar.
class CLLifecycleStep {
  final String label;
  final String? description;
  final IconData icon;
  final Color color;

  const CLLifecycleStep({
    required this.label,
    this.description,
    required this.icon,
    required this.color,
  });
}

/// Horizontal progress bar that shows the steps of a flow with state.
///
/// Each step has an icon, label and color. The current step is highlighted.
///
/// ```dart
/// CLLifecycleProgress(
///   currentIndex: 1,
///   steps: [
///     CLLifecycleStep(label: 'Draft', icon: FontAwesomeIcons.pen, color: Colors.blue),
///     CLLifecycleStep(label: 'Review', icon: FontAwesomeIcons.eye, color: Colors.orange),
///     CLLifecycleStep(label: 'Done', icon: FontAwesomeIcons.check, color: Colors.green),
///   ],
/// )
/// ```
class CLLifecycleProgress extends StatelessWidget {
  final List<CLLifecycleStep> steps;
  final int currentIndex;

  const CLLifecycleProgress({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: theme.lg, horizontal: theme.lg),
      decoration: BoxDecoration(
        color: isDark ? theme.surface : Colors.white,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final isDone = stepBefore < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone
                    ? steps[stepBefore].color
                    : theme.border.withValues(alpha: 0.3),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final step = steps[stepIndex];
          final isCurrent = stepIndex == currentIndex;
          final isDone = stepIndex < currentIndex;
          final isFuture = stepIndex > currentIndex;

          return _CLStepDot(
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

class _CLStepDot extends StatelessWidget {
  final CLLifecycleStep step;
  final bool isCurrent;
  final bool isDone;
  final bool isFuture;
  final CLThemeData theme;
  final bool isDark;

  const _CLStepDot({
    required this.step,
    required this.isCurrent,
    required this.isDone,
    required this.isFuture,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isFuture ? theme.textSecondary.withValues(alpha: 0.4) : step.color;

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
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : FaIcon(
                    step.icon,
                    color: color,
                    size: isCurrent ? 16 : 12,
                  ),
          ),
        ),
        SizedBox(height: theme.sm - 2),
        Text(
          step.label,
          style: TextStyle(
            fontSize: isCurrent ? 11 : 10,
            fontWeight: isCurrent
                ? FontWeight.w700
                : (isDone ? FontWeight.w500 : FontWeight.w400),
            color: isFuture
                ? theme.textSecondary.withValues(alpha: 0.4)
                : color,
          ),
          textAlign: TextAlign.center,
        ),
        if (isCurrent && step.description != null) ...[
          const SizedBox(height: 2),
          Text(
            step.description!,
            style: TextStyle(fontSize: 9, color: theme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
