
part of 'alert_manager.dart';

class _Alert {
  final String title;
  final String message;
  final AlertPosition alertPosition;
  final AlertType alertType;

  final Function()? onTap;
  final BehaviorSubject<double>? downloadPercentageStream;
  final bool closeOnTap;

  _Alert(
      {required this.title,
        required this.message,
        required this.alertPosition,
        required this.alertType,
        this.onTap,
        this.downloadPercentageStream,
        required this.closeOnTap});

}

class _ConsumableAlert {
  final _Alert alert;
  bool _consumed = false;

  _ConsumableAlert(this.alert);

  bool get isConsumed => _consumed;

  void consume() {
    _consumed = true;
  }
}
