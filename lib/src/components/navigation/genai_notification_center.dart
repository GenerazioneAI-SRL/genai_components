import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';
import '../feedback/genai_empty_state.dart';
import '../indicators/genai_status_badge.dart';
import '../../tokens/sizing.dart';

enum GenaiNotificationLevel { info, success, warning, error }

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

/// Notification center panel (§6.6.11). Designed to be hosted inside a drawer
/// or popover.
class GenaiNotificationCenter extends StatelessWidget {
  final List<GenaiNotificationItem> notifications;
  final VoidCallback? onMarkAllRead;
  final ValueChanged<String>? onDismiss;
  final ValueChanged<String>? onMarkRead;

  const GenaiNotificationCenter({
    super.key,
    required this.notifications,
    this.onMarkAllRead,
    this.onDismiss,
    this.onMarkRead,
  });

  String _format(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'ora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
    if (diff.inHours < 24) return '${diff.inHours} h fa';
    if (diff.inDays < 7) return '${diff.inDays} g fa';
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
  }

  GenaiStatusType _statusFor(GenaiNotificationLevel l) => switch (l) {
        GenaiNotificationLevel.info => GenaiStatusType.info,
        GenaiNotificationLevel.success => GenaiStatusType.success,
        GenaiNotificationLevel.warning => GenaiStatusType.warning,
        GenaiNotificationLevel.error => GenaiStatusType.error,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final unread = notifications.where((n) => !n.isRead).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Text('Notifiche', style: ty.headingSm.copyWith(color: colors.textPrimary)),
              const SizedBox(width: 8),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.colorPrimary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$unread', style: ty.caption.copyWith(color: colors.textOnPrimary, fontWeight: FontWeight.w600)),
                ),
              const Spacer(),
              if (onMarkAllRead != null)
                GenaiButton.ghost(
                  label: 'Segna tutto come letto',
                  size: GenaiSize.sm,
                  onPressed: onMarkAllRead,
                ),
            ],
          ),
        ),
        if (notifications.isEmpty)
          const GenaiEmptyState(
            icon: LucideIcons.bell,
            title: 'Nessuna notifica',
          )
        else
          for (final n in notifications) _buildItem(n, colors, ty),
      ],
    );
  }

  Widget _buildItem(GenaiNotificationItem n, dynamic colors, dynamic ty) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          n.onTap?.call();
          if (!n.isRead) onMarkRead?.call(n.id);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: n.isRead ? null : colors.colorPrimarySubtle,
            border: Border(bottom: BorderSide(color: colors.borderDefault)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiStatusBadge(label: '', status: _statusFor(n.level)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              style: ty.label.copyWith(color: colors.textPrimary, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w600)),
                        ),
                        Text(_format(n.timestamp), style: ty.caption.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                    if (n.body != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(n.body!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                      ),
                  ],
                ),
              ),
              if (onDismiss != null)
                GenaiIconButton(
                  icon: LucideIcons.x,
                  size: GenaiSize.xs,
                  semanticLabel: 'Chiudi notifica',
                  onPressed: () => onDismiss!(n.id),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
