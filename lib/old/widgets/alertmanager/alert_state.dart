// alert_state.dart

part of 'alert_manager.dart';

class _AlertState extends ChangeNotifier {
  _ConsumableAlert? _alert;

  _Alert? get alert =>
      _alert != null && !_alert!.isConsumed ? _alert!.alert : null;

  void notify(_Alert alert) {
    _alert = _ConsumableAlert(alert);
    notifyListeners();
  }

  void consumeAlert() => _alert?.consume();
}
