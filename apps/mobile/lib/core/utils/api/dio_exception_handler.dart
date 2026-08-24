import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/utils/toast_message.dart';

/// Turns a DioException into a user-friendly message and shows a toast for it.
///
/// Singleton so the 401/connection-error dedup timers below are shared across
/// every API service — without them, N simultaneous failing requests would
/// pop N identical toasts.
class DioExceptionHandler {
  DioExceptionHandler._internal();

  static final DioExceptionHandler _instance = DioExceptionHandler._internal();

  factory DioExceptionHandler() {
    return _instance;
  }

  /// Timer used to disable multiple 401 errors
  Timer? _disableMultiple401Errors;

  /// Timer used to disable multiple connection/timeout error toasts
  Timer? _disableMultipleConnectionErrors;

  String handleError(DioException error, {bool ignoreErrors = false, bool dontDisplayToast = false}) {
    final t = TranslationStorage.translation;

    // First handle internet connection error and timeouts (all treated as no internet).
    // DioExceptionType.unknown covers unstable connections where the OS throws a
    // SocketException or OSError (e.g. "Connection reset by peer") before Dio can
    // classify the failure — these should also show the no-internet toast.
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.type == DioExceptionType.unknown && _isNetworkError(error))) {
      if (!dontDisplayToast && _disableMultipleConnectionErrors == null) {
        ToastMessage().showErrorToast(text: t.apiErrorNoInternetConnection);
        _disableMultipleConnectionErrors = Timer(const Duration(seconds: 15), () {
          _disableMultipleConnectionErrors = null;
        });
      }
      return t.apiErrorNoInternetConnection;
    }

    if (ignoreErrors) {
      return '';
    }

    if (error.response?.data is String || error.response?.data == null) {
      int? statusCode = error.response?.statusCode;

      if (statusCode == 400) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus400);
        return t.apiErrorStatus400;
      } else if (statusCode == 401) {
        if (!dontDisplayToast && _disableMultiple401Errors == null) {
          ToastMessage().showWarningToast(text: t.apiErrorStatus401);

          // Disable showing multiple 401 errors for 5 seconds
          _disableMultiple401Errors = Timer(const Duration(seconds: 5), () {
            _disableMultiple401Errors = null;
          });
        }

        return t.apiErrorStatus401;
      } else if (statusCode == 403) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus403);
        return t.apiErrorStatus403;
      } else if (statusCode == 404) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus404);
        return t.apiErrorStatus404;
      } else if (statusCode == 405) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus405);
        return t.apiErrorStatus405;
      } else if (statusCode == 500) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus500);
        return t.apiErrorStatus500;
      } else if (statusCode == 501) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus501);
        return t.apiErrorStatus501;
      } else if (statusCode == 502) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus502);
        return t.apiErrorStatus502;
      } else if (statusCode == 503) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus503);
        return t.apiErrorStatus503;
      } else if (statusCode == 504) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus504);
        return t.apiErrorStatus504;
      } else if (statusCode == 505) {
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.apiErrorStatus505);
        return t.apiErrorStatus505;
      } else {
        final message = error.message?.trim() ?? '';
        final displayMessage = message.isEmpty ? t.genericErrorMessage : message;
        if (!dontDisplayToast) ToastMessage().showErrorToast(text: displayMessage);
        return displayMessage;
      }
    } else if (error.response?.data['errors'] != null) {
      dynamic errors = error.response?.data['errors'];
      // Iterate over errors map and display each error message
      try {
        String errorMessage = '';
        errors.forEach((key, value) {
          if (!dontDisplayToast) ToastMessage().showErrorToast(text: '$key: ${value[0]}');
          errorMessage = '$key: ${value[0]}';
        });
        return errorMessage;
      } catch (e) {
        return e.toString();
      }
    }
    // ASP.NET ProblemDetails puts the actual error message in 'title' (see
    // Shared.Presentation's CommonHttpErrorHandlers.HandleError).
    else if (error.response?.data['title'] != null) {
      if (!dontDisplayToast) ToastMessage().showErrorToast(text: '${error.response?.data['title']}');
      return '${error.response?.data['title']}';
    } else {
      if (!dontDisplayToast) ToastMessage().showErrorToast(text: t.genericErrorMessage);
      return t.genericErrorMessage;
    }
  }

  bool _isNetworkError(DioException error) {
    final err = error.error;
    return err is SocketException || err is OSError;
  }
}
