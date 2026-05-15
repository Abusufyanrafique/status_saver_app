import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Notification tap handle karne ke liye yahan logic likhein
      },
    );

    await _createChannel();
  }

  static Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'status_watcher',
      'WhatsApp Status Watcher',
      description: 'Notifies when new WhatsApp statuses are detected',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  static Future<void> showNewStatusNotification({
    required int count,
  }) async {
    await _plugin.show(
      0,
      count == 1 ? '🔔 New WhatsApp Status!' : '🔔 $count New WhatsApp Statuses!',
      count == 1
          ? 'Someone posted a new status. Tap to view.'
          : '$count new statuses available. Tap to view.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'status_watcher',
          'WhatsApp Status Watcher',
          channelDescription: 'Notifies when new WhatsApp statuses are detected',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF0000), // 🔴 Red color badge
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }
}