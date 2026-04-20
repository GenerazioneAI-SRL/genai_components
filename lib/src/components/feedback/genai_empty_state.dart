import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Empty state with optional illustration/icon, title, description and CTAs
/// (§6.4.3).
///
/// Variants:
/// - default ([GenaiEmptyState.new]) — plain icon
/// - [GenaiEmptyState.firstUse] — onboarding tone
/// - [GenaiEmptyState.noResults] — search filter empty
class GenaiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final EdgeInsetsGeometry padding;

  const GenaiEmptyState({
    super.key,
    this.icon = LucideIcons.inbox,
    required this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding = const EdgeInsets.all(32),
  });

  const GenaiEmptyState.firstUse({
    super.key,
    this.icon = LucideIcons.sparkles,
    required this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding = const EdgeInsets.all(32),
  });

  const GenaiEmptyState.noResults({
    super.key,
    this.icon = LucideIcons.searchX,
    required this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceHover,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(title, style: ty.headingSm.copyWith(color: colors.textPrimary), textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(description!, style: ty.bodyMd.copyWith(color: colors.textSecondary), textAlign: TextAlign.center),
              ),
            ],
            if (primaryAction != null || secondaryAction != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (secondaryAction != null) secondaryAction!,
                  if (primaryAction != null) primaryAction!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
