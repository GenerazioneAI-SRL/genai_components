import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Empty state placeholder — v3 design system.
///
/// Used on screens that load successfully but yield zero records. Always
/// includes an action affordance where possible (primary or secondary).
///
/// v3 layout: centered column, 48 px icon (`iconEmptyState`), 14 / 600 title,
/// `bodySm` / `ink-2` description, optional action row.
class GenaiEmptyState extends StatelessWidget {
  /// Heading. Typically a short sentence ("Nessun risultato").
  final String title;

  /// Optional longer description.
  final String? description;

  /// Illustrative icon. Defaults to [LucideIcons.inbox].
  final IconData icon;

  /// Optional primary action button (typically a `GenaiButton`).
  final Widget? primaryAction;

  /// Optional secondary action button.
  final Widget? secondaryAction;

  const GenaiEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = LucideIcons.inbox,
    this.primaryAction,
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
                  color: colors.textTertiary,
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
                if (primaryAction != null || secondaryAction != null) ...[
                  SizedBox(height: spacing.s20),
                  Wrap(
                    spacing: spacing.s8,
                    runSpacing: spacing.s8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (primaryAction != null) primaryAction!,
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
