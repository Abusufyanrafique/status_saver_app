// import 'dart:ui';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');

//     const settings = InitializationSettings(android: android);

//     await _plugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (response) {
//         // Tap on notification
//       },
//     );

//     await _createChannel();
//   }

//   static Future<void> _createChannel() async {
//     const channel = AndroidNotificationChannel(
//       'status_watcher',
//       'WhatsApp Status Watcher',
//       description: 'Notifies when new WhatsApp statuses are detected',
//       importance: Importance.high,
//     );

//     final androidPlugin =
//         _plugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     await androidPlugin?.createNotificationChannel(channel);
//   }

//   static Future<void> showNewStatusNotification({
//     required int count,
//   }) async {
//     await _plugin.show(
//       0,
//       count == 1
//           ? '🔔 New WhatsApp Status!'
//           : '🔔 $count New WhatsApp Statuses!',
//       count == 1
//           ? 'Someone posted a new status. Tap to view.'
//           : '$count new statuses available. Tap to view.',
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'status_watcher',
//           'WhatsApp Status Watcher',
//           channelDescription:
//               'Notifies when new WhatsApp statuses are detected',
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/ic_launcher',
//           color: Color(0xFFA1C4FD),
//           styleInformation: BigTextStyleInformation(''),
//         ),
//       ),
//     );
//   }
// }



// const String kScanTask = 'status_scan_task';
// const String kStatusPath = '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
// // Android 10 se neeche ke liye:
// // '/storage/emulated/0/WhatsApp/Media/.Statuses'

// // Yeh function background mein chalega
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     if (task == kScanTask) {
//       await _scanStatuses();
//     }
//     return Future.value(true);
//   });
// }

// Future<void> _scanStatuses() async {
//   try {
//     final dir = Directory(kStatusPath);

//     if (!await dir.exists()) return;

//     // Sirf image aur video files lo
//     final files = await dir
//         .list()
//         .where((f) =>
//             f.path.endsWith('.jpg') ||
//             f.path.endsWith('.jpeg') ||
//             f.path.endsWith('.png') ||
//             f.path.endsWith('.mp4') ||
//             f.path.endsWith('.opus'))
//         .toList();

//     if (files.isEmpty) return;

//     final prefs = await SharedPreferences.getInstance();

//     // Pehle se dekhe hue files ka set
//     final seen = prefs.getStringList('seen_statuses') ?? [];

//     // Naye files filter karo
//     final newFiles = files
//         .map((f) => f.path.split('/').last)
//         .where((name) => !seen.contains(name))
//         .toList();

//     if (newFiles.isEmpty) return;

//     // Notification dikhao
//     await NotificationService.init();
//     await NotificationService.showNewStatusNotification(
//       count: newFiles.length,
//     );

//     // Seen list update karo
//     final updatedSeen = [
//       ...seen,
//       ...newFiles,
//     ];

//     // Sirf last 200 files yaad rakho (memory ke liye)
//     if (updatedSeen.length > 200) {
//       updatedSeen.removeRange(0, updatedSeen.length - 200);
//     }

//     await prefs.setStringList('seen_statuses', updatedSeen);
//   } catch (e) {
//     print('Scan error: $e');
//   }
// }

// class StatusScannerService {
//   // App start hone par ek baar call karo
//   static Future<void> initialize() async {
//     await Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: false,
//     );
//   }

//   // Background task register karo — 15 min interval
//   static Future<void> startScanning() async {
//     await Workmanager().registerPeriodicTask(
//       kScanTask,
//       kScanTask,
//       frequency: const Duration(minutes: 15),
//       constraints: Constraints(
//         networkType: NetworkType.not_required,
//         requiresBatteryNotLow: false,
//       ),
//       existingWorkPolicy: ExistingWorkPolicy.keep,
//     );
//   }

//   // Scanning band karo
//   static Future<void> stopScanning() async {
//     await Workmanager().cancelByUniqueName(kScanTask);
//   }

//   // Seen history clear karo (testing ke liye)
//   static Future<void> clearSeenHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('seen_statuses');
//   }
  
// }
