// custom_alert_listener.dart
part of 'alert_manager.dart';

class CustomAlertListener extends StatelessWidget {
  final Widget child;
  final void Function(_Alert alert) showPrimary;
  final void Function(_Alert alert) showSecondary;
  final void Function(_Alert alert) showSuccess;
  final void Function(_Alert alert) showDanger;
  final void Function(_Alert alert) showWarning;
  final void Function(_Alert alert) showInfo;
  final void Function(_Alert alert) showNotification;

  const CustomAlertListener({
    super.key,
    required this.child,
    required this.showPrimary,
    required this.showSecondary,
    required this.showSuccess,
    required this.showDanger,
    required this.showWarning,
    required this.showInfo,
    required this.showNotification,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _AlertState(),
      child: Consumer<_AlertState>(
        builder: (context, alertState, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (alertState.alert?.alertType) {
              case AlertType.primary:
                _handleAlert(alertState.alert, showPrimary, () => alertState.consumeAlert());
                break;
              case AlertType.secondary:
                _handleAlert(alertState.alert, showSecondary, () => alertState.consumeAlert());
                break;
              case AlertType.success:
                _handleAlert(alertState.alert, showSuccess, () => alertState.consumeAlert());
                break;
              case AlertType.danger:
                _handleAlert(alertState.alert, showDanger, () => alertState.consumeAlert());
                break;
              case AlertType.warning:
                _handleAlert(alertState.alert, showWarning, () => alertState.consumeAlert());
                break;
              case AlertType.info:
                _handleAlert(alertState.alert, showInfo, () => alertState.consumeAlert());
                break;
              case AlertType.notification:
                _handleAlert(alertState.alert, showNotification, () => alertState.consumeAlert());
                break;
              default:
                _handleAlert(alertState.alert, showPrimary, () => alertState.consumeAlert());
                break;
            }
          });

          return child!;
        },
        child: child,
      ),
    );
  }

  void _handleAlert(_Alert? alert, void Function(_Alert alert) showAlert, VoidCallback consume) {
    if (alert != null) {
      showAlert(alert);
      consume();
    }
  }
}
