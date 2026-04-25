import 'cl_auth_state.dart';

/// Process-wide accessor for the current [CLAuthState] instance.
///
/// Useful when code needs to read auth state from a context-less location
/// (background isolates, pure-Dart services, API interceptors, etc.) where
/// `Provider.of<CLAuthState>(context)` is not viable.
///
/// The singleton must be bound at app bootstrap — typically right after
/// the [CLAuthState] provider is created — by calling
/// [AuthSingleton.bind]. Reading [authState] before bind throws a
/// [StateError] to surface configuration mistakes early.
///
/// Example:
/// ```dart
/// final auth = MyAppAuthState();
/// AuthSingleton.bind(auth);
/// // ...later, anywhere:
/// final token = AuthSingleton.instance.authState.accessToken;
/// ```
class AuthSingleton {
  AuthSingleton._();

  static AuthSingleton? _instance;

  /// Returns the lazily-created singleton instance.
  static AuthSingleton get instance => _instance ??= AuthSingleton._();

  CLAuthState? _authState;

  /// The bound [CLAuthState]. Throws [StateError] if [bind] has not been
  /// called yet.
  CLAuthState get authState {
    if (_authState == null) {
      throw StateError(
        'AuthSingleton not bound. Call AuthSingleton.bind() at bootstrap.',
      );
    }
    return _authState!;
  }

  /// Binds the global [CLAuthState] instance. Must be called once at app
  /// startup before any consumer reads [authState].
  static void bind(CLAuthState state) => instance._authState = state;

  /// Whether [bind] has already been called and an auth state is available.
  static bool get isBound => instance._authState != null;
}
