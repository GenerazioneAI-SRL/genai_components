import 'package:flutter/material.dart';

/// Granular state for maintenance / bootstrap-completion flags.
///
/// Part of the AppState decomposition introduced in 4.4.x. Prefer this over
/// `AppState` for new code that gates UI on maintenance mode or app initialization.
class MaintenanceState extends ChangeNotifier {
  bool _maintenanceMode = false;
  bool _isInitialized = false;
  bool _disposed = false;

  /// Whether the backend is currently in maintenance mode.
  bool get maintenanceMode => _maintenanceMode;

  /// Whether the app has completed its bootstrap initialization.
  bool get isInitialized => _isInitialized;

  /// Update maintenance mode flag; notifies only on change.
  set maintenanceMode(bool value) {
    if (_maintenanceMode == value) return;
    _maintenanceMode = value;
    notifyListeners();
  }

  /// Mirror of [AppState.setMaintenanceMode] for compatibility.
  void setMaintenanceMode(bool value) {
    maintenanceMode = value;
  }

  /// Mark bootstrap initialization as complete; idempotent.
  void completeInitialization() {
    if (_isInitialized) return;
    _isInitialized = true;
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
