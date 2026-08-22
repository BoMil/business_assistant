import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:business_assistant/core/features/push_notifications/api_services/device_token_api_service.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

/// Requests notification permission and registers the device's FCM token with the
/// backend. Only called when FirebaseConfig().isConfigured — see main.dart.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final DeviceTokenApiService _deviceTokenApiService = DeviceTokenApiService();

  Future<void> registerCurrentToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final response = await _deviceTokenApiService.registerDeviceToken(token);
      if (response.status != ResponseStatus.completed) {
        debugPrint('[PushNotificationService] registerCurrentToken error: ${response.message}');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] registerCurrentToken failed: $e');
    }
  }
}
