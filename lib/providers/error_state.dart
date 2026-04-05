import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ErrorState extends ChangeNotifier {
  int? _errorCode;
  String? _errorMessage;
  String? _errorDetail;
  String? _attemptedRoute;

  int? get errorCode => _errorCode;
  String? get errorMessage => _errorMessage;
  String? get errorDetail => _errorDetail;
  String? get attemptedRoute => _attemptedRoute;
  bool get hasError => _errorCode != null;

  void setError(int code, String route) {
    _errorCode = code;
    _attemptedRoute = route;
    notifyListeners();
  }

  void clearError() {
    _errorCode = null;
    _errorMessage = null;
    _errorDetail = null;
    _attemptedRoute = null;
    notifyListeners();
  }
}
