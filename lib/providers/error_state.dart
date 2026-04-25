import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ErrorState extends ChangeNotifier {
  int? _errorCode;
  String? _errorMessage;
  String? _errorDetail;
  String? _attemptedRoute;
  bool _disposed = false;

  int? get errorCode => _errorCode;
  String? get errorMessage => _errorMessage;
  String? get errorDetail => _errorDetail;
  String? get attemptedRoute => _attemptedRoute;
  bool get hasError => _errorCode != null;

  void setError(int code, String route, {String? message, String? detail}) {
    _errorCode = code;
    _attemptedRoute = route;
    _errorMessage = message;
    _errorDetail = detail;
    notifyListeners();
  }

  void clearError() {
    _errorCode = null;
    _errorMessage = null;
    _errorDetail = null;
    _attemptedRoute = null;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
