import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Top app bar (§6.6.6).
class GenaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final List<Widget> actions;
  final Widget? bottom;
  final double height;

  const GenaiAppBar({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.height = 64,
  });

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom == null ? 0 : 48));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceCard,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.borderDefault)),
            ),
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                if (title != null || subtitle != null)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          DefaultTextStyle.merge(
                            style: context.typography.headingSm.copyWith(color: colors.textPrimary),
                            child: title!,
                          ),
                        if (subtitle != null)
                          DefaultTextStyle.merge(
                            style: context.typography.bodySm.copyWith(color: colors.textSecondary),
                            child: subtitle!,
                          ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  actions[i],
                ],
              ],
            ),
          ),
          if (bottom != null) SizedBox(height: 48, child: bottom!),
        ],
      ),
    );
  }
}
