import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// App-level state: theme, AI chat toggle, initialization, errors.
class GenaiAppState extends ChangeNotifier {
  late BehaviorSubject<bool> refreshList = BehaviorSubject<bool>.seeded(false);
  bool _hasError = false;
  ThemeMode _themeMode = ThemeMode.light;
  bool fromNotification = false;
  bool isInitialized = false;
  bool maintenanceMode = false;
  bool _aiChatOpen = false;

  bool get aiChatOpen => _aiChatOpen;

  void toggleAiChat() {
    _aiChatOpen = !_aiChatOpen;
    notifyListeners();
  }

  void completeInitialization() {
    if (!isInitialized) {
      isInitialized = true;
      notifyListeners();
    }
  }

  void setMaintenanceMode(bool value) {
    maintenanceMode = value;
    notifyListeners();
  }

  ThemeMode get theme => _themeMode;

  bool get hasError => _hasError;
  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void markForRefresh() {
    _shouldRefresh = true;
    refreshList.add(true);
    notifyListeners();
  }

  void reset() => _shouldRefresh = false;

  void changeEndDrawer(bool value) {
    fromNotification = value;
    notifyListeners();
  }

  void resetError() {
    _hasError = false;
    notifyListeners();
  }

  void changeTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
