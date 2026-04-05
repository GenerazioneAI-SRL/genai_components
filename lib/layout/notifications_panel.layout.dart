import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:cl_components/providers/notifications_panel_provider.dart';
import 'package:cl_components/cl_theme.dart';
import 'package:cl_components/layout/constants/sizes.constant.dart';

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsPanelProvider>(
      builder: (context, notificationsPanelProvider, child) {
        if (!notificationsPanelProvider.isOpen) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 340,
          decoration: BoxDecoration(
            color: CLTheme.of(context).secondaryBackground,
            border: Border(left: BorderSide(color: CLTheme.of(context).borderColor, width: 1)),
          ),
          child: Column(
            children: [
              // Header del pannello
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding / 2),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: CLTheme.of(context).borderColor, width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notificationsPanelProvider.currentSection == PanelSection.notifications ? 'Notifiche' : 'Assistente AI',
                      style: CLTheme.of(context).title,
                    ),
                    IconButton(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: CLTheme.of(context).primaryText, size: Sizes.medium),
                      onPressed: () {
                        notificationsPanelProvider.close();
                      },
                    ),
                  ],
                ),
              ),
              // Contenuto del pannello
              Expanded(
                child:
                    notificationsPanelProvider.currentSection == PanelSection.notifications
                        ? _buildNotificationsContent(context)
                        : _buildChatbotContent(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsContent(BuildContext context) {
    return Center(child: Text('Nessuna notifica', style: CLTheme.of(context).bodyLabel));
  }

  Widget _buildChatbotContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.padding),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedAiChat02, color: CLTheme.of(context).secondaryText, size: 48),
                  SizedBox(height: Sizes.padding),
                  Text('Assistente AI', style: CLTheme.of(context).heading6),
                  SizedBox(height: Sizes.padding / 2),
                  Text('Inizia una conversazione', style: CLTheme.of(context).bodyLabel, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          // Area di input (placeholder per futura implementazione)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.padding / 2, vertical: Sizes.padding / 2),
            decoration: BoxDecoration(
              color: CLTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(color: CLTheme.of(context).borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Scrivi un messaggio...', style: CLTheme.of(context).bodyLabel.override(color: CLTheme.of(context).secondaryText)),
                ),
                HugeIcon(icon: HugeIcons.strokeRoundedSent, color: CLTheme.of(context).secondaryText, size: Sizes.medium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
