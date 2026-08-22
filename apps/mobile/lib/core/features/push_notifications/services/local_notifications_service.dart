import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays a push notification while the app is in the foreground — FCM only
/// auto-shows notifications when the app is backgrounded/killed. Uses the same
/// `default_channel`/`ic_notification` the Android manifest already declares
/// for background messages, so foreground and background notifications look
/// and behave identically.
class LocalNotificationsService {
  static final LocalNotificationsService _instance = LocalNotificationsService._internal();
  factory LocalNotificationsService() => _instance;
  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'default_channel',
    'Notifications',
    importance: Importance.max,
  );

  bool _isInitialized = false;
  int _notificationIdCounter = 0;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[LocalNotificationsService] init failed: $e');
    }
  }

  Future<void> showNotification(String? title, String? body) async {
    if (!_isInitialized) return;

    await _plugin.show(
      id: _notificationIdCounter++,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          icon: 'ic_notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
