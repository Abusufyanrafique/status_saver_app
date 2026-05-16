import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  //  Track karo ki init ho chuka hai ya nahi
  static bool _initialized = false;

  //  initialize() = init() ka alias - dono kaam karenge
  static Future<void> initialize() async => await init();

  static Future<void> init() async {
    if (_initialized) return; //  Double init se bachao

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {},
    );

    await _createChannel();
    _initialized = true; // ✅ Mark as done
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

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  static Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_enabled') ?? true;
  }

  static Future<void> setNotificationEnabled(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', val);
  }

  static Future<void> showNewStatusNotification({
    required int count,
  }) async {
    //  Auto-init agar background mein init nahi hua
    await initialize();

    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    final granted = await isPermissionGranted();
    if (!granted) return;

    await _plugin.show(
      0,
      count == 1
          ? '🔔 New WhatsApp Status!'
          : '🔔 $count New WhatsApp Statuses!',
      count == 1
          ? 'Someone posted a new status. Tap to view.'
          : '$count new statuses available. Tap to view.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'status_watcher',
          'WhatsApp Status Watcher',
          channelDescription:
              'Notifies when new WhatsApp statuses are detected',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF0000),
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }
}