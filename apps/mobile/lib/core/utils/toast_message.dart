import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Wrapper around the toastification package.
///
/// Instead of calling toastification.show() with all its parameters in every
/// widget, use this class so the style stays consistent across the app.
///
/// Usage:
///   ToastMessage().showSuccessToast(text: 'Login successful');
///   ToastMessage().showErrorToast(text: 'Invalid credentials');
class ToastMessage {
  EdgeInsets toastPadding =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  void showSuccessToast({
    required String text,
    Duration toastDuration = const Duration(seconds: 5),
  }) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: toastDuration,
      description: Text(text, maxLines: 5),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      showIcon: true,
      padding: toastPadding,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  void showInfoToast({
    required String text,
    Duration toastDuration = const Duration(seconds: 5),
  }) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: toastDuration,
      description: Text(text, maxLines: 5),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      showIcon: true,
      padding: toastPadding,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  void showErrorToast({
    required String text,
    Duration toastDuration = const Duration(seconds: 7),
  }) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: toastDuration,
      description: Text(text, maxLines: 5),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      showIcon: true,
      padding: toastPadding,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  void showWarningToast({
    required String text,
    Duration toastDuration = const Duration(seconds: 5),
  }) {
    toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: toastDuration,
      description: Text(text, maxLines: 5),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      showIcon: true,
      padding: toastPadding,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
    );
  }
}
