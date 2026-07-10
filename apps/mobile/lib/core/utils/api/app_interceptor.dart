import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/config/constants/secure_storage_keys.dart';
import 'package:business_assistant/config/environment/environment.dart';

/// Singleton Dio instance that intercepts every HTTP request/response.
///
/// Responsibilities:
///   1. Inject the Bearer token from secure storage into every request header.
///   2. Detect 401 Unauthorized responses and transparently refresh the token.
///   3. Retry the original failed request with the new token.
///   4. Log out the user if the refresh token is also expired or missing.
///
/// QueuedInterceptorsWrapper is used instead of InterceptorsWrapper because it
/// serializes concurrent 401 handling — only one token refresh happens at a time
/// even if multiple requests 401 simultaneously.
class AppInterceptor {
  AppInterceptor._internal();

  static final AppInterceptor _instance = AppInterceptor._internal();

  factory AppInterceptor() => _instance;

  /// The shared Dio instance used by all repositories in the app.
  var dio = Dio(
    BaseOptions(
      contentType: Headers.jsonContentType,
      baseUrl: Environment.serverAddress,
    ),
  );

  /// Guards against starting a second refresh while one is already in progress.
  bool _isTokenRefreshing = false;

  /// Sets up the Dio HTTP client adapter (disables strict SSL for dev/staging)
  /// and registers the request/response/error interceptor.
  ///
  /// Call this once in main() before runApp().
  void initializeInterceptor() {
    _isTokenRefreshing = false;

    // Allow self-signed certificates in development (the Identity API runs over HTTP
    // locally via Docker, but we add this for staging HTTPS with self-signed certs).
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        // ── onRequest: inject the saved access token ──────────────────────────
        onRequest:
            (RequestOptions requestOptions, RequestInterceptorHandler handler) async {
          // Retry requests already have the new token injected — skip injection
          if (requestOptions.extra['isRetry'] == true) {
            debugPrint('[AppInterceptor] Retry request — skipping token injection.');
            return handler.next(requestOptions);
          }

          // Read the stored access token from secure storage
          const storage = FlutterSecureStorage();
          String? token = await storage.read(key: SecureStorageKeys.tokenKey);

          if (token != null && token.isNotEmpty) {
            requestOptions.headers.putIfAbsent(
              'Authorization',
              () => 'Bearer $token',
            );
          }

          debugPrint('[AppInterceptor] ${requestOptions.method} ${requestOptions.path}');
          handler.next(requestOptions);
        },

        // ── onResponse: pass through (log only) ──────────────────────────────
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          debugPrint('[AppInterceptor] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },

        // ── onError: handle 401 by refreshing the token ───────────────────────
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          debugPrint('[AppInterceptor] ERROR ${err.response?.statusCode} ${err.requestOptions.path}');

          // No internet — wrap in a cleaner error type
          if (err.type == DioExceptionType.connectionError) {
            return handler.reject(DioException(
              requestOptions: err.requestOptions,
              type: DioExceptionType.connectionError,
            ));
          }

          // Token expired — try to refresh once
          if (err.response?.statusCode == 401 && !_isTokenRefreshing) {
            String newAccessToken = await _refreshToken();
            _isTokenRefreshing = false;

            if (newAccessToken.isEmpty) {
              // Refresh failed — propagate the original 401 error
              return handler.next(err);
            }

            // Retry the original request with the new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            try {
              final response = await safeRetryRequest(err.requestOptions, newAccessToken);
              return handler.resolve(response);
            } catch (e) {
              if (e is DioException) return handler.next(e);
              return handler.next(
                DioException(requestOptions: err.requestOptions, error: e),
              );
            }
          }

          handler.next(err);
        },
      ),
    );
  }

  /// Calls POST /auth/refresh-token with the stored refresh token.
  ///
  /// Returns the new access token string, or '' if refresh failed.
  /// On failure, also calls _logoutUser() to clear storage and go to login.
  Future<String> _refreshToken() async {
    _isTokenRefreshing = true;

    const storage = FlutterSecureStorage();
    String? refreshToken = await storage.read(key: SecureStorageKeys.refreshTokenKey);

    if (refreshToken == null || refreshToken.isEmpty) {
      _logoutUser();
      return '';
    }

    // Use a fresh Dio instance — the main one has its interceptors locked
    // during error handling, so re-using it would deadlock.
    final refreshDio = Dio(
      BaseOptions(
        contentType: Headers.jsonContentType,
        baseUrl: Environment.serverAddress,
      ),
    );

    refreshDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient()
          ..badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    try {
      final response = await refreshDio.post(
        APIEndpoints.refreshToken,
        // The Identity API expects: { "refreshToken": "<token>" }
        data: {'refreshToken': refreshToken},
      );

      String? newAccessToken = response.data['accessToken'];

      if (newAccessToken == null || newAccessToken.isEmpty) {
        _logoutUser();
        return '';
      }

      // Persist the new access token so future requests use it
      await storage.write(
        key: SecureStorageKeys.tokenKey,
        value: newAccessToken,
      );

      // If the server also rotates the refresh token, persist that too
      String? newRefreshToken = response.data['refreshToken'];
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await storage.write(
          key: SecureStorageKeys.refreshTokenKey,
          value: newRefreshToken,
        );
      }

      debugPrint('[AppInterceptor] Token refreshed successfully.');
      return newAccessToken;
    } on DioException catch (e) {
      debugPrint('[AppInterceptor] Token refresh failed: ${e.message}');
      _logoutUser();
      return '';
    } catch (e) {
      debugPrint('[AppInterceptor] Token refresh error: $e');
      _logoutUser();
      return '';
    }
  }

  /// Clears all auth tokens from secure storage.
  /// TODO: Trigger AuthCubit.logout() once we wire up the router reference.
  void _logoutUser() {
    _isTokenRefreshing = false;
    const storage = FlutterSecureStorage();
    storage.delete(key: SecureStorageKeys.tokenKey);
    storage.delete(key: SecureStorageKeys.refreshTokenKey);
    debugPrint('[AppInterceptor] User logged out — tokens cleared.');
  }

  /// Retries a failed request with an updated Authorization header.
  ///
  /// Handles multipart/form-data by recreating the FormData (it can't be
  /// reused once finalized — Dio throws "FormData already finalized").
  Future<Response<dynamic>> safeRetryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    // Prevent recursive retry loops
    if (requestOptions.extra['isRetry'] == true) {
      throw DioException(
        requestOptions: requestOptions,
        message: 'Already retried once — aborting to prevent loop.',
      );
    }

    final newHeaders = Map<String, dynamic>.from(requestOptions.headers);
    newHeaders['Authorization'] = 'Bearer $newAccessToken';

    dynamic newData;

    if (requestOptions.contentType != null &&
        requestOptions.contentType!.contains('multipart/form-data')) {
      // FormData must be cloned — the original is finalized and unusable
      final originalFormData = requestOptions.data as FormData;
      newData = FormData();
      newData.fields.addAll(originalFormData.fields);

      for (var file in originalFormData.files) {
        final stream = file.value.finalize();
        final bytes = await _readStreamToBytes(stream);
        newData.files.add(MapEntry(
          file.key,
          MultipartFile.fromBytes(
            bytes,
            filename: file.value.filename,
            contentType: file.value.contentType,
          ),
        ));
      }
    } else {
      newData = _cloneRequestData(requestOptions.data);
    }

    final retryOptions = Options(
      method: requestOptions.method,
      headers: newHeaders,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      followRedirects: requestOptions.followRedirects,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: {
        ...requestOptions.extra,
        'isRetry': true, // prevents a second retry loop
      },
    );

    // New Dio instance to avoid using the interceptor-locked main instance
    final retryDio = Dio(
      BaseOptions(
        contentType: requestOptions.contentType,
        baseUrl: Environment.serverAddress,
      ),
    );

    retryDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient()
          ..badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    debugPrint('[AppInterceptor] Retrying: ${requestOptions.uri}');
    return retryDio.request(
      requestOptions.path,
      data: newData,
      queryParameters: requestOptions.queryParameters,
      options: retryOptions,
    );
  }

  /// Deep-clones JSON-safe request bodies to avoid mutating the original.
  dynamic _cloneRequestData(dynamic data) {
    try {
      if (data == null) return null;
      if (data is Map<String, dynamic> || data is List) {
        return json.decode(json.encode(data));
      }
    } catch (e) {
      debugPrint('[AppInterceptor] Failed to clone request data: $e');
    }
    return data;
  }

  Future<Uint8List> _readStreamToBytes(Stream<List<int>> stream) async {
    final bytes = <int>[];
    await for (var chunk in stream) {
      bytes.addAll(chunk);
    }
    return Uint8List.fromList(bytes);
  }
}
