part of 'alert_manager.dart';
class DefaultAlertListener extends StatefulWidget {
  final Widget child;
  const DefaultAlertListener({super.key, required this.child});

  @override
  State<DefaultAlertListener> createState() => _DefaultAlertListenerState();
}

class _DefaultAlertListenerState extends State<DefaultAlertListener> {
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (context) {
          // Qui siamo sicuri di avere un Overlay attivo
          return ChangeNotifierProvider(
            create: (_) => _AlertState(),
            child: Consumer<_AlertState>(
              builder: (context, alertState, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (alertState.alert != null) {
                    _handleAlert(
                      alertState,
                      alertState.alert,
                          () => _showAlert(alertState, context, alertState.alert),
                          () => alertState.consumeAlert(),
                    );
                  }
                });
                return widget.child;
              },
            ),
          );
        }),
      ],
    );
  }

  void _handleAlert(_AlertState alertState, _Alert? alert, VoidCallback showAlert, VoidCallback consume) {
    if (alert != null) {
      showAlert();
      consume();
    }
  }

  void _showAlert(_AlertState alertState, BuildContext context, _Alert? alert) {
    if (alert == null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _OverlayBody(
        title: alert.title,
        message: alert.message,
        alertPosition: alert.alertPosition,
        alertType: alert.alertType,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        onTap: alert.onTap,
        closeOnTap: alert.closeOnTap,
        downloadPercentageStream: alert.downloadPercentageStream,
        onClosed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}