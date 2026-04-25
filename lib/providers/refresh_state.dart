import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Granular state for cross-module list refresh signaling.
///
/// Exposes a [BehaviorSubject] that emits `true` whenever a consumer requests
/// a refresh. Independent from `AppState.refreshList`: AppState retains its own
/// (deprecated) subject for backward compatibility; new code should subscribe
/// to this state instead.
class RefreshState extends ChangeNotifier {
  /// Stream of refresh signals, seeded with `false`.
  final BehaviorSubject<bool> refreshList = BehaviorSubject<bool>.seeded(false);

  bool _shouldRefresh = false;
  bool _disposed = false;

  /// Whether a refresh has been requested since the last [reset].
  bool get shouldRefresh => _shouldRefresh;

  /// Signal that listeners should refresh their data.
  void markForRefresh() {
    _shouldRefresh = true;
    refreshList.add(true);
    notifyListeners();
  }

  /// Clear the [shouldRefresh] flag. Does not notify listeners.
  void reset() {
    _shouldRefresh = false;
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
