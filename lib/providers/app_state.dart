import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../cl_theme.dart';
import '../utils/shared_manager.util.dart';

import '../app/cl_app_config.dart';

class AppState extends ChangeNotifier {
  late BehaviorSubject<bool> refreshList = BehaviorSubject<bool>.seeded(false);
  bool _hasError = false;
  ThemeMode _themeMode = CLTheme.themeMode;
  Locale? _locale;
  bool fromNotification = false;
  bool isInitialized = false;
  @Deprecated('Use MaintenanceState — will be removed in 5.0')
  bool maintenanceMode = false;
  bool showAiButton = false;
  AiButtonPosition aiButtonPosition = AiButtonPosition.header;
  Widget Function(BuildContext context, VoidCallback onPressed)? aiButtonBuilder;
  ProfilePosition profilePosition = ProfilePosition.header;
  bool _aiChatOpen = false;
  bool _disposed = false;

  @Deprecated('Use UiToggleState — will be removed in 5.0')
  bool get aiChatOpen => _aiChatOpen;

  @Deprecated('Use UiToggleState — will be removed in 5.0')
  set aiChatOpen(bool value) {
    if (_aiChatOpen == value) return;
    _aiChatOpen = value;
    notifyListeners();
  }

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

  @Deprecated('Use AppThemeState — will be removed in 5.0')
  ThemeMode get themeMode => _themeMode;

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
    if (_locale == locale) return;
    _locale = locale;
    //context.setLocale(locale);
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
    refreshList.close();
    super.dispose();
  }
}
