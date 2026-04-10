import 'dart:convert';
import 'dart:io';
import 'dart:core';
import '../providers/error_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:provider/provider.dart';
import '../auth/cl_auth_state.dart';
import '../utils/models/pagination.model.dart';
export 'package:genai_components/utils/models/pagination.model.dart';

import '../widgets/alertmanager/alert_manager.dart';
import '../core_models/upload_file.model.dart';

enum ApiCallType { GET, POST, DELETE, PUT, PATCH }

enum BodyType { NONE, JSON, TEXT, X_WWW_FORM_URL_ENCODED, MULTIPART }

class ApiCallRecord extends Equatable {
  const ApiCallRecord(this.callName, this.apiUrl, this.headers, this.params, this.body, this.bodyType);

  final String callName;
  final String apiUrl;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> params;
  final String? body;
  final BodyType? bodyType;

  @override
  List<Object?> get props => [callName, apiUrl, headers, params, body, bodyType];
}

class ApiCallResponse {
  const ApiCallResponse(this.jsonBody, this.pagination, this.error, this.headers, this.statusCode, {this.response});

  final dynamic jsonBody;
  final Pagination? pagination;
  final Map<String, String> headers;
  final int statusCode;
  final ApiError? error;
  final http.Response? response;

  // Whether we received a 2xx status (which generally marks success).
  bool get succeeded => statusCode >= 200 && statusCode < 300;

  bool get unauthenticated => statusCode == 401;

  String getHeader(String headerName) => headers[headerName] ?? '';

  /// jsonBody come List — gestisce sia List diretta che Map con "data"/"items".
  /// Ritorna sempre una List (vuota se il body non contiene dati lista).
  List get jsonList {
    if (jsonBody is List) return jsonBody as List;
    if (jsonBody is Map) {
      final data = jsonBody["data"];
      if (data is List) return data;
      final items = jsonBody["items"];
      if (items is List) return items;
    }
    return [];
  }

  /// jsonBody come Map — sicuro, ritorna {} se il body non è un map.
  Map<String, dynamic> get jsonMap =>
      jsonBody is Map<String, dynamic> ? jsonBody as Map<String, dynamic> : {};

  // Return the raw body from the response, or if this came from a cloud call
  // and the body is not a string, then the json encoded body.
  String get bodyText => response?.body ?? (jsonBody is String ? jsonBody as String : jsonEncode(jsonBody));

  static Future<ApiCallResponse> fromHttpResponse(http.Response response, bool returnBody, bool decodeUtf8) async {
    var jsonBody;
    Pagination? pagination;
    ApiError? error;
    try {
      final responseBody = decodeUtf8 && returnBody ? const Utf8Decoder().convert(response.bodyBytes) : response.body;
      jsonBody = returnBody ? json.decode(responseBody) : null;

      if (jsonBody is Map) {
        error =
            jsonBody["error"] != null
                ? ApiError.fromJson(jsonObject: jsonBody["error"])
                : (jsonBody["statusCode"] != null ? ApiError.fromJson(jsonObject: jsonBody) : null);

        // Pagination: formato standard {meta: {total, lastPage, currentPage, perPage}}
        if (jsonBody["meta"] != null) {
          pagination = Pagination.fromJson(jsonObject: jsonBody["meta"]);
        }
        // Pagination: formato HR {total, page, limit, totalPages} a livello root
        else if (jsonBody["total"] != null && jsonBody["items"] != null) {
          final p = Pagination();
          p.total = jsonBody['total'] as int?;
          p.currentPage = jsonBody['page'] as int?;
          p.perPage = jsonBody['limit'] as int?;
          p.lastPage = jsonBody['totalPages'] as int?;
          if (p.currentPage != null && p.currentPage! > 1) {
            p.prev = p.currentPage! - 1;
          }
          if (p.currentPage != null && p.lastPage != null && p.currentPage! < p.lastPage!) {
            p.next = p.currentPage! + 1;
          }
          pagination = p;
        }
      }
    } catch (_) {}

    // Estrae i dati: se è un Map usa "data" o "items", altrimenti body intero
    final extractedBody = jsonBody is Map
        ? (jsonBody["data"] ?? jsonBody["items"] ?? jsonBody)
        : jsonBody;

    return ApiCallResponse(
      extractedBody,
      pagination,
      error,
      response.headers,
      response.statusCode,
      response: response,
    );
  }
}

class ApiError {
  int? statusCode;
  String? message;
  String? error;

  ApiError({this.statusCode, this.message, this.error});

  factory ApiError.fromJson({required dynamic jsonObject}) {
    final error = ApiError();
    error.statusCode = jsonObject["statusCode"];
    error.message = jsonObject["message"];
    final rawError = jsonObject["error"];
    if (rawError is List) {
      error.error = rawError.map((e) => e.toString()).join(', ');
    } else if (rawError is Map) {
      error.error = rawError.values.expand((v) => v is List ? v : [v]).map((e) => e.toString()).join(', ');
    } else {
      error.error = rawError?.toString() ?? '';
    }
    return error;
  }
}

class ApiManager {
  ApiManager._();

  static ApiManager? _instance;

  static ApiManager get instance => _instance ??= ApiManager._();

  /// Base URL per le API. Deve essere impostato dall'app prima dell'uso.
  static String _baseUrl = '';
  static String get baseUrl => _baseUrl;
  static void configure({required String baseUrl}) {
    _baseUrl = baseUrl;
  }

  static Map<String, String> toStringMap(Map map) => map.map((key, value) => MapEntry(key.toString(), value.toString()));

  static String asQueryParams(Map<String, dynamic> map) =>
      map.entries.map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}").join('&');

  static Future<ApiCallResponse> urlRequest(
    ApiCallType callType,
    String apiUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic> params,
    bool returnBody,
    bool decodeUtf8,
  ) async {
    if (params.isNotEmpty) {
      final specifier = Uri.parse(apiUrl).queryParameters.isNotEmpty ? '&' : '?';
      apiUrl = '$apiUrl$specifier${asQueryParams(params)}';
    }
    final makeRequest = callType == ApiCallType.GET ? http.get : http.delete;
    final response = await makeRequest(Uri.parse(apiUrl), headers: toStringMap(headers));
    return ApiCallResponse.fromHttpResponse(response, returnBody, decodeUtf8);
  }

  static Future<ApiCallResponse> requestWithBody(
    ApiCallType type,
    String apiUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic> params,
    String? body,
    BodyType? bodyType,
    bool returnBody,
    bool encodeBodyUtf8,
    bool decodeUtf8,
  ) async {
    assert({ApiCallType.POST, ApiCallType.PUT, ApiCallType.PATCH}.contains(type), 'Invalid ApiCallType $type for request with body');
    final postBody = createBody(headers, params, body, bodyType, encodeBodyUtf8);

    if (bodyType == BodyType.MULTIPART) {
      return multipartRequest(type, apiUrl, headers, params, returnBody, decodeUtf8);
    }

    final requestFn = {ApiCallType.POST: http.post, ApiCallType.PUT: http.put, ApiCallType.PATCH: http.patch}[type]!;
    final response = await requestFn(Uri.parse(apiUrl), headers: toStringMap(headers), body: postBody);
    return ApiCallResponse.fromHttpResponse(response, returnBody, decodeUtf8);
  }

  static Future<ApiCallResponse> multipartRequest(
    ApiCallType? type,
    String apiUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic> params,
    bool returnBody,
    bool decodeUtf8,
  ) async {
    assert({ApiCallType.POST, ApiCallType.PUT, ApiCallType.PATCH}.contains(type), 'Invalid ApiCallType $type for request with body');
    isFile(e) => e is FFUploadedFile || e is File || e is List<FFUploadedFile> || (e is List && e.firstOrNull is FFUploadedFile);
    final nonFileParams = Map.fromEntries(params.entries.where((e) => !isFile(e.value)));
    List<http.MultipartFile> files = [];
    params.entries.where((e) => isFile(e.value)).forEach((e) {
      final param = e.value;
      final uploadedFiles = param is List ? param as List<FFUploadedFile> : [param as FFUploadedFile];
      for (var uploadedFile in uploadedFiles) {
        files.add(
          http.MultipartFile.fromBytes(
            e.key,
            uploadedFile.clMedia.file?.bytes ?? Uint8List.fromList([]),
            filename: uploadedFile.clMedia.file?.name,
            contentType: _getMediaType(uploadedFile.clMedia.file?.name),
          ),
        );
      }
    });
    final request =
        http.MultipartRequest(type.toString().split('.').last, Uri.parse(apiUrl))
          ..headers.addAll(toStringMap(headers))
          ..files.addAll(files);
    nonFileParams.forEach((key, value) => request.fields[key] = value.toString());

    final response = await http.Response.fromStream(await request.send());
    return ApiCallResponse.fromHttpResponse(response, returnBody, decodeUtf8);
  }

  static MediaType? _getMediaType(String? filename) {
    final contentType = mime(filename);
    if (contentType == null) {
      return null;
    }
    final parts = contentType.split('/');
    if (parts.length != 2) {
      return null;
    }
    return MediaType(parts.first, parts.last);
  }

  static dynamic createBody(Map<String, dynamic> headers, Map<String, dynamic>? params, String? body, BodyType? bodyType, bool encodeBodyUtf8) {
    String? contentType;
    dynamic postBody;
    switch (bodyType) {
      case BodyType.JSON:
        contentType = 'application/json';
        postBody = body ?? json.encode(params ?? {});
        break;
      case BodyType.TEXT:
        contentType = 'text/plain';
        postBody = body ?? json.encode(params ?? {});
        break;
      case BodyType.X_WWW_FORM_URL_ENCODED:
        contentType = 'application/x-www-form-urlencoded';
        postBody = toStringMap(params ?? {});
        break;
      case BodyType.MULTIPART:
        contentType = 'multipart/form-data';
        postBody = params;
        break;
      case BodyType.NONE:
      case null:
        break;
    }
    // Set "Content-Type" header if it was previously unset.
    if (contentType != null && !headers.keys.any((h) => h.toLowerCase() == 'content-type')) {
      headers['Content-Type'] = contentType;
    }
    return encodeBodyUtf8 && postBody is String ? utf8.encode(postBody) : postBody;
  }

  Future<Map<String, dynamic>> initHeader(Map<String, dynamic> headers, needAuth, needTenant, BuildContext context) async {
    Map<String, dynamic> allHeaders = {};
    allHeaders.addAll(headers);
    allHeaders.addAll({HttpHeaders.acceptHeader: "application/json"});
    if (needAuth && getAuthBearerToken(context) != null) {
      allHeaders.addAll({HttpHeaders.authorizationHeader: 'Bearer ${getAuthBearerToken(context)}'});
    }
    if (needTenant && getCurrentTenantId(context) != null) {
      allHeaders.addAll({"x-tenant-id": getCurrentTenantId(context)});
    }
    return allHeaders;
  }

  String? getAuthBearerToken(BuildContext context) {
    final authState = Provider.of<CLAuthState>(context, listen: false);
    return authState.accessToken;
  }

  String? getCurrentTenantId(BuildContext context) {
    final authState = Provider.of<CLAuthState>(context, listen: false);
    return authState.currentTenant?.id;
  }

  Map<String, dynamic> convertSearchBy(Map<String, dynamic> body) {
    Map<String, dynamic> searchBy = {};

    body.forEach((key, value) {
      // Remove spaces if key is 'fullname'
      if (key == 'employee:fullname' && value is String || key == 'fullname' && value is String) {
        value = value.replaceAll(' ', '');
      }

      // Divide key based on ':'
      List<String> parts = key.split(':');
      Map<String, dynamic> currentLevel = searchBy;

      for (int i = 0; i < parts.length; i++) {
        // Handle boolean values
        if (value is bool) {
          if (i == parts.length - 1) {
            currentLevel[parts[i]] = value;
          }
        }
        // Handle DateTimeRange values
        else if (value is DateTimeRange) {
          if (i == parts.length - 1) {
            currentLevel[parts[i]] = {
              'gte': "${value.start..toUtc().toIso8601String()}",
              'lte': value.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toUtc().toIso8601String(),
            };
          }
        }
        // Handle other types of values
        else {
          if (i == parts.length - 1) {
            // Se il valore è un Map con gte/lte (range di date già processato), usalo direttamente
            if (value is Map<String, dynamic> && (value.containsKey('gte') || value.containsKey('lte'))) {
              currentLevel[parts[i]] = value;
            } else if (value is Map && (value.containsKey('gte') || value.containsKey('lte'))) {
              currentLevel[parts[i]] = value;
            }
            // If the final key is 'id', use direct search, otherwise use 'contains'
            else if (parts[i].contains("Id")) {
              if (parts[i].contains("Ids")) {
                currentLevel[parts[i]] = {'has': value};
              } else {
                currentLevel[parts[i]] = value;
              }
            } else {
              currentLevel[parts[i]] = {'contains': value, 'mode': 'insensitive'};
            }
          } else {
            // Create a new nesting level if it does not already exist
            if (currentLevel[parts[i]] == null) {
              currentLevel[parts[i]] = <String, dynamic>{};
            }
            currentLevel = currentLevel[parts[i]] as Map<String, dynamic>;
          }
        }
      }
    });

    return searchBy;
  }

  Map<String, dynamic> convertOrderBy(Map<String, dynamic> input) {
    // Estrai columnId e mode
    if (input['columnId'] == null || input['columnId'].toString().isEmpty) {
      return {};
    }

    String columnId = input['columnId']!;
    String mode = input['mode'] == 'DESC' ? 'desc' : 'asc';

    // Dividi columnId in base ai ':'
    List<String> parts = columnId.split(':');
    Map<String, dynamic> orderBy = {};

    if (parts.length == 1) {
      // Campo diretto del modello
      orderBy[columnId] = mode;
    } else {
      // Nidificazione delle relazioni
      Map<String, dynamic> currentLevel = orderBy;

      for (int i = 0; i < parts.length; i++) {
        if (i == parts.length - 1) {
          // Ultimo elemento, aggiungi mode
          currentLevel[parts[i]] = mode;
        } else {
          // Crea un nuovo livello di nidificazione
          currentLevel[parts[i]] = <String, dynamic>{};
          currentLevel = currentLevel[parts[i]] as Map<String, dynamic>;
        }
      }
    }

    return orderBy;
  }

  void _handleResponse(ApiCallResponse response, BuildContext? context) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      final errorState = context?.read<ErrorState>();
      final currentRoute = GoRouter.of(context!).routerDelegate.currentConfiguration.uri.toString();
      errorState?.setError(response.statusCode, currentRoute);
    }
  }

  Future<ApiCallResponse> makeApiCall({
    required String apiUrl,
    required BuildContext context,
    required ApiCallType callType,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> params = const {},
    String? body,
    BodyType? bodyType = BodyType.JSON,
    bool returnBody = true,
    bool encodeBodyUtf8 = false,
    bool decodeUtf8 = false,
    bool needAuth = false,
    bool needTenant = false,
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
    String? successMessage,
    bool replaceApiUrl = false,
    String? completeApiUrl,
  }) async {
    headers = await initHeader(headers, needAuth, needTenant, context);

    // Se replaceApiUrl è true e c'è completeApiUrl, usa quello
    if (replaceApiUrl && completeApiUrl != null && completeApiUrl.isNotEmpty) {
      apiUrl = completeApiUrl;
    } else {
      apiUrl = _baseUrl + apiUrl;
      if (!apiUrl.startsWith('http')) {
        apiUrl = 'https://$apiUrl';
      }
    }
    ApiCallResponse result;

    // === DEBUG LOG: Richiesta ===
    assert(() {
      final method = callType.name;
      debugPrint('┌── API REQUEST ──────────────────────────────');
      debugPrint('│ $method $apiUrl');
      if (params.isNotEmpty) {
        final paramsStr = Map<String, dynamic>.from(params).toString();
        debugPrint('│ Params: ${paramsStr.length > 200 ? '${paramsStr.substring(0, 200)}...' : paramsStr}');
      }
      if (body != null) {
        debugPrint('│ Body: ${body.length > 200 ? '${body.substring(0, 200)}...' : body}');
      }
      debugPrint('└─────────────────────────────────────────────');
      return true;
    }());

    switch (callType) {
      case ApiCallType.GET:
      case ApiCallType.DELETE:
        result = await urlRequest(callType, apiUrl, headers, params, returnBody, decodeUtf8);
        break;
      case ApiCallType.POST:
      case ApiCallType.PUT:
      case ApiCallType.PATCH:
        result = await requestWithBody(callType, apiUrl, headers, params, body, bodyType, returnBody, encodeBodyUtf8, decodeUtf8);
        break;
    }

    // === DEBUG LOG: Risposta ===
    assert(() {
      final method = callType.name;
      final statusIcon = result.succeeded ? '✅' : '❌';
      debugPrint('┌── API RESPONSE ─────────────────────────────');
      debugPrint('│ $statusIcon $method $apiUrl');
      debugPrint('│ Status: ${result.statusCode}');
      if (result.error != null) {
        debugPrint('│ Error: ${result.error?.message ?? result.error?.error}');
      }
      if (!result.succeeded) {
        final rawBody = result.bodyText;
        debugPrint('│ Raw Body: ${rawBody.length > 500 ? '${rawBody.substring(0, 500)}...' : rawBody}');
      }
      if (result.jsonBody != null) {
        final bodyStr = result.jsonBody.toString();
        debugPrint('│ Body: ${bodyStr.length > 500 ? '${bodyStr.substring(0, 500)}...' : bodyStr}');
      }
      if (result.pagination != null) {
        debugPrint(
          '│ Pagination: page=${result.pagination?.currentPage}, total=${result.pagination?.total}, lastPage=${result.pagination?.lastPage}',
        );
      }
      debugPrint('└─────────────────────────────────────────────');
      return true;
    }());

    if (result.succeeded) {
      if (showSuccessMessage) {
        AlertManager.showSuccess("Successo", successMessage ?? "Operazione completata con successo", alertPosition: AlertPosition.bottom);
      }
    } else {
      // Gestisci 401 e 403 tramite ErrorState e redirect
      _handleResponse(result, context);

      // Non mostrare alert per 401 e 403, vengono gestiti dalla pagina di errore
      if (result.statusCode != 401 && result.statusCode != 403 && showErrorMessage) {
        AlertManager.showDanger(
          result.error?.error?.toString() ?? "Errore ${result.statusCode}",
          result.error?.message ?? "Si è verificato un errore durante l'operazione",
          alertPosition: AlertPosition.bottom,
        );
      }
    }
    return result;
  }
}

