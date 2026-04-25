import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_divider.dart';

/// Page section with heading + optional description — v3 design system.
///
/// Mirrors the `.section-h` pattern from the Forma LMS Dashboard: H2 (15/600)
/// left, optional trailing "s" subtitle or action link right, `sectionGap`
/// rhythm vertically. Optional [divider] replaces the bottom margin with a
/// [GenaiDivider].
class GenaiSection extends StatelessWidget {
  /// Required heading (renders with `sectionTitle` 15/600).
  final String title;

  /// Optional description below [title].
  final String? description;

  /// Optional trailing widget next to the heading (e.g. action button / link).
  final Widget? trailing;

  /// Main content.
  final Widget child;

  /// Add a bottom divider after content.
  final bool divider;

  /// Override outer padding.
  final EdgeInsetsGeometry? padding;

  const GenaiSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.trailing,
    this.divider = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style:
                            ty.sectionTitle.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    if (description != null) ...[
                      SizedBox(height: spacing.s4),
                      Text(
                        description!,
                        style: ty.bodySm.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: spacing.s12),
                trailing!,
              ],
            ],
          ),
          SizedBox(height: spacing.s14),
          child,
          if (divider) ...[
            SizedBox(height: spacing.sectionGap),
            const GenaiDivider(),
          ],
        ],
      ),
    );
  }
}
