import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Error state placeholder — v3 design system.
///
/// Used on screens that fail to load. Always includes a retry affordance
/// where possible. Announced via live region so assistive tech hears the
/// failure on mount.
///
/// v3 layout mirrors [GenaiEmptyState] but paints the icon in danger and
/// tightens to an explicit retry slot.
class GenaiErrorState extends StatelessWidget {
  /// Heading. Typically a short sentence ("Qualcosa è andato storto").
  final String title;

  /// Optional longer description of the failure.
  final String? description;

  /// Error icon. Defaults to [LucideIcons.circleAlert].
  final IconData icon;

  /// Optional retry action (typically a `GenaiButton`).
  final Widget? retryAction;

  /// Optional secondary action (typically "Contatta supporto").
  final Widget? secondaryAction;

  const GenaiErrorState({
    super.key,
    required this.title,
    this.description,
    this.icon = LucideIcons.circleAlert,
    this.retryAction,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    return Semantics(
      container: true,
      liveRegion: true,
      label: title,
      value: description,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(spacing.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: sizing.iconEmptyState,
                  color: colors.colorDanger,
                ),
                SizedBox(height: spacing.s16),
                Text(
                  title,
                  style: ty.cardTitle.copyWith(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                if (description != null) ...[
                  SizedBox(height: spacing.s6),
                  Text(
                    description!,
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (retryAction != null || secondaryAction != null) ...[
                  SizedBox(height: spacing.s20),
                  Wrap(
                    spacing: spacing.s8,
                    runSpacing: spacing.s8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (retryAction != null) retryAction!,
                      if (secondaryAction != null) secondaryAction!,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
