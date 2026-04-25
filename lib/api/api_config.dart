import 'package:flutter/foundation.dart';

/// Immutable configuration object for [ApiManager].
///
/// Bundles all the parameters required to bootstrap the API layer: base URL,
/// API version prefix, request timeout, default headers and the default
/// behaviour for tenant header injection.
///
/// Prefer this over the legacy `ApiManager.configure(...)` static method —
/// it scales better when more options are added in the future and keeps the
/// configuration explicit and testable.
///
/// Example:
/// ```dart
/// const config = ApiConfig(
///   baseUrl: 'https://api.skillera.it/api/',
///   apiVersion: 'v1/',
///   timeout: Duration(seconds: 30),
///   needTenantByDefault: true,
/// );
/// ApiManager.fromConfig(config);
/// ```
@immutable
class ApiConfig {
  /// Base URL for every API request (must end with `/`).
  final String baseUrl;

  /// API version prefix injected between [baseUrl] and the call URL
  /// (e.g. `"v1/"`). Use empty string to disable.
  final String apiVersion;

  /// Maximum duration for a single HTTP request before it is aborted.
  final Duration timeout;

  /// Headers attached to every request unless overridden per call.
  final Map<String, String> defaultHeaders;

  /// When `true`, calls inject the `x-tenant-id` header by default.
  /// Individual calls can still override via their own `needTenant` flag.
  final bool needTenantByDefault;

  /// Creates an immutable [ApiConfig].
  ///
  /// [baseUrl] and [apiVersion] are required. Other fields fall back to
  /// sensible defaults: 30s timeout, no default headers, tenant header off.
  const ApiConfig({
    required this.baseUrl,
    required this.apiVersion,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
    this.needTenantByDefault = false,
  });

  /// Returns a new [ApiConfig] with the provided fields replaced.
  ///
  /// Any field left `null` keeps its current value.
  ApiConfig copyWith({
    String? baseUrl,
    String? apiVersion,
    Duration? timeout,
    Map<String, String>? defaultHeaders,
    bool? needTenantByDefault,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiVersion: apiVersion ?? this.apiVersion,
      timeout: timeout ?? this.timeout,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      needTenantByDefault: needTenantByDefault ?? this.needTenantByDefault,
    );
  }
}
