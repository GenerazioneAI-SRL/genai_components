import '../api/api_manager.dart';
import '../widgets/alertmanager/alert_manager.dart';
import 'base_viewmodel.dart';

/// Extension on [CLBaseViewModel] that wraps a network call with the standard
/// busy/error pattern used across the app.
///
/// - Toggles `setBusy(true/false)` around the call.
/// - Returns the value produced by [onSuccess] when the response succeeded
///   (HTTP 2xx), otherwise `null`.
/// - On non-2xx or thrown exceptions, optionally shows a danger alert via
///   [AlertManager.showDanger].
///
/// Usage:
/// ```dart
/// final user = await safeCall<UserModel>(
///   call: () => ApiManager.instance.makeApiCall(...),
///   onSuccess: (data) => UserModel.fromJson(data),
///   errorTitle: 'Errore',
///   errorMessage: 'Impossibile caricare utente',
/// );
/// ```
extension SafeCallExtension on CLBaseViewModel {
  /// Wraps an [ApiCallResponse]-producing call with busy state and error
  /// handling.
  ///
  /// - [call]: the async function performing the API call.
  /// - [onSuccess]: maps the decoded `jsonBody` into the target type [R];
  ///   if omitted, returns `null` on success.
  /// - [errorTitle] / [errorMessage]: shown via [AlertManager.showDanger]
  ///   on non-2xx responses or exceptions when [showErrorAlert] is `true`.
  /// - [showErrorAlert]: set to `false` to suppress the alert and let the
  ///   caller handle errors.
  /// - [manageBusy]: set to `false` if the caller already manages busy state.
  Future<R?> safeCall<R>({
    required Future<ApiCallResponse> Function() call,
    R Function(dynamic data)? onSuccess,
    String errorTitle = 'Errore',
    String? errorMessage,
    bool showErrorAlert = true,
    bool manageBusy = true,
  }) async {
    if (manageBusy) setBusy(true);
    try {
      final response = await call();
      if (response.succeeded) {
        return onSuccess?.call(response.jsonBody);
      }
      if (showErrorAlert) {
        final msg = errorMessage ??
            response.error?.message ??
            'Operazione non riuscita (${response.statusCode})';
        AlertManager.showDanger(errorTitle, msg);
      }
      return null;
    } catch (e) {
      if (showErrorAlert) {
        AlertManager.showDanger(errorTitle, errorMessage ?? e.toString());
      }
      return null;
    } finally {
      if (manageBusy) setBusy(false);
    }
  }
}
