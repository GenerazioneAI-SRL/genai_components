import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/utils/shared_manager.util.dart';

class AppState extends ChangeNotifier {
  late BehaviorSubject<bool> refreshList = BehaviorSubject<bool>.seeded(false);
  bool _hasError = false;
  ThemeMode _themeMode = CLTheme.themeMode;
  bool fromNotification = false;
  bool isInitialized = false;
  bool maintenanceMode = false;

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

  void reset() {
    _shouldRefresh = false;
  }

  void changeEndDrawer(bool value) {
    fromNotification = value;
    notifyListeners();
  }

  void resetError() {
    _hasError = false;
    notifyListeners();
  }

  void changeTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    SharedManager.remove(kThemeModeKey);
    notifyListeners();
  }

  void updateLocale(BuildContext context, Locale locale) {
    //context.setLocale(locale);
    notifyListeners();
  }
}
