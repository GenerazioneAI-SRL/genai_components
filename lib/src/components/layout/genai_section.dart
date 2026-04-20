import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Section header + body (§6.3.4).
///
/// Use to group related content with a title, optional description and
/// optional trailing actions.
class GenaiSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GenaiSection({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: ty.headingSm.copyWith(color: colors.textPrimary)),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(description!, style: ty.bodyMd.copyWith(color: colors.textSecondary)),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
