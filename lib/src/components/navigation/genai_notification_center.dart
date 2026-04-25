import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Severity level of a [GenaiNotificationItem].
enum GenaiNotificationLevel { info, success, warning, danger }

/// Single notification entry.
@immutable
class GenaiNotificationItem {
  final String id;
  final String title;
  final String? body;
  final DateTime timestamp;
  final GenaiNotificationLevel level;
  final bool isRead;
  final VoidCallback? onTap;

  const GenaiNotificationItem({
    required this.id,
    required this.title,
    this.body,
    required this.timestamp,
    this.level = GenaiNotificationLevel.info,
    this.isRead = false,
    this.onTap,
  });
}

/// Notification centre — v3 design system.
///
/// Intended to live inside a popover or drawer. Always pairs level with
/// icon + label (no color alone) per §5.
class GenaiNotificationCenter extends StatelessWidget {
  final List<GenaiNotificationItem> notifications;
  final VoidCallback? onMarkAllRead;
  final ValueChanged<String>? onDismiss;
  final ValueChanged<String>? onMarkRead;
  final String title;
  final String emptyLabel;
  final String markAllLabel;
  final String? semanticLabel;

  const GenaiNotificationCenter({
    super.key,
    required this.notifications,
    this.onMarkAllRead,
    this.onDismiss,
    this.onMarkRead,
    this.title = 'Notifications',
    this.emptyLabel = 'No notifications',
    this.markAllLabel = 'Mark all as read',
    this.semanticLabel,
  });

  String _format(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
  }

  Color _levelColor(BuildContext context, GenaiNotificationLevel l) {
    final c = context.colors;
    return switch (l) {
      GenaiNotificationLevel.info => c.colorInfo,
      GenaiNotificationLevel.success => c.colorSuccess,
      GenaiNotificationLevel.warning => c.colorWarning,
      GenaiNotificationLevel.danger => c.colorDanger,
    };
  }

  IconData _levelIcon(GenaiNotificationLevel l) => switch (l) {
        GenaiNotificationLevel.info => LucideIcons.info,
        GenaiNotificationLevel.success => LucideIcons.checkCheck,
        GenaiNotificationLevel.warning => LucideIcons.triangleAlert,
        GenaiNotificationLevel.danger => LucideIcons.circleX,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final unread = notifications.where((n) => !n.isRead).length;

    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s16,
              spacing.s12,
              spacing.s12,
              spacing.s12,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: ty.cardTitle.copyWith(color: colors.textPrimary),
                ),
                SizedBox(width: spacing.s8),
                if (unread > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.s6,
                      vertical: spacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorDanger,
                      borderRadius: BorderRadius.circular(radius.pill),
                    ),
                    child: Text(
                      '$unread',
                      style: ty.monoSm.copyWith(
                        color: colors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (onMarkAllRead != null && unread > 0)
                  _TextLinkButton(
                    label: markAllLabel,
                    onPressed: onMarkAllRead!,
                  ),
              ],
            ),
          ),
          Container(
            height: sizing.dividerThickness,
            color: colors.borderSubtle,
          ),
          if (notifications.isEmpty)
            Padding(
              padding: EdgeInsets.all(spacing.s32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.bell,
                      size: sizing.iconEmptyState,
                      color: colors.textTertiary,
                    ),
                    SizedBox(height: spacing.s12),
                    Text(
                      emptyLabel,
                      style: ty.body.copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: spacing.s4),
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, __) => Container(
                  height: sizing.dividerThickness,
                  color: colors.borderSubtle,
                  margin: EdgeInsets.symmetric(horizontal: spacing.s16),
                ),
                itemBuilder: (ctx, i) {
                  final n = notifications[i];
                  return _NotificationRow(
                    item: n,
                    levelColor: _levelColor(ctx, n.level),
                    levelIcon: _levelIcon(n.level),
                    timeLabel: _format(n.timestamp),
                    onDismiss: onDismiss,
                    onMarkRead: onMarkRead,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatefulWidget {
  final GenaiNotificationItem item;
  final Color levelColor;
  final IconData levelIcon;
  final String timeLabel;
  final ValueChanged<String>? onDismiss;
  final ValueChanged<String>? onMarkRead;

  const _NotificationRow({
    required this.item,
    required this.levelColor,
    required this.levelIcon,
    required this.timeLabel,
    required this.onDismiss,
    required this.onMarkRead,
  });

  @override
  State<_NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<_NotificationRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final item = widget.item;
    final titleStyle = ty.label.copyWith(
      color: item.isRead ? colors.textSecondary : colors.textPrimary,
      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
    );

    return Semantics(
      button: item.onTap != null,
      label: item.title,
      child: MouseRegion(
        cursor: item.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!item.isRead) widget.onMarkRead?.call(item.id);
            item.onTap?.call();
          },
          child: Container(
            color: _hover ? colors.surfaceHover : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.levelIcon,
                  size: sizing.iconSize,
                  color: widget.levelColor,
                ),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(item.title, style: titleStyle)),
                          SizedBox(width: spacing.s8),
                          Text(
                            widget.timeLabel,
                            style: ty.labelSm.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      if (item.body != null) ...[
                        SizedBox(height: spacing.s2),
                        Text(
                          item.body!,
                          style: ty.bodySm.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_hover && widget.onDismiss != null) ...[
                  SizedBox(width: spacing.s8),
                  _InlineIconButton(
                    icon: LucideIcons.x,
                    label: 'Dismiss',
                    onPressed: () => widget.onDismiss!(item.id),
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

class _InlineIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _InlineIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_InlineIconButton> createState() => _InlineIconButtonState();
}

class _InlineIconButtonState extends State<_InlineIconButton> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;
    final bg = _hover ? colors.surfacePressed : Colors.transparent;

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: Container(
              width: sizing.minTouchTarget - 16,
              height: sizing.minTouchTarget - 16,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius.sm),
                border: _focused
                    ? Border.all(
                        color: colors.borderFocus,
                        width: sizing.focusRingWidth,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                size: sizing.iconSize - 2,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextLinkButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _TextLinkButton({required this.label, required this.onPressed});

  @override
  State<_TextLinkButton> createState() => _TextLinkButtonState();
}

class _TextLinkButtonState extends State<_TextLinkButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s8,
              vertical: spacing.s4,
            ),
            child: Text(
              widget.label,
              style: ty.label.copyWith(
                color: _hover ? colors.colorPrimaryHover : colors.textLink,
                decoration:
                    _hover ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
