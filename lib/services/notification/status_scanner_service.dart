// import 'dart:io';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'notification_service.dart';

// const String kScanTask = 'status_scan_task';

// const String kStatusPath =
//     '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';

// class StatusScannerService {
//   static Future<void> initialize() async {
//     await Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: false,
//     );
//   }

//   static Future<void> startScanning() async {
//     await Workmanager().registerPeriodicTask(
//       kScanTask,
//       kScanTask,
//       frequency: const Duration(minutes: 15),
//       existingWorkPolicy: ExistingWorkPolicy.keep,
//     );
//   }

//   static Future<void> stopScanning() async {
//     await Workmanager().cancelByUniqueName(kScanTask);
//   }
// }

// ///  BACKGROUND ENTRY POINT
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     if (task == kScanTask) {
//       await _scanStatuses();
//     }
//     return Future.value(true);
//   });
// }

// /// 🔍 SCAN LOGIC
// Future<void> _scanStatuses() async {
//   try {
//     final dir = Directory(kStatusPath);

//     if (!await dir.exists()) return;

//     final files = dir
//         .listSync()
//         .where((f) =>
//             f.path.endsWith('.jpg') ||
//             f.path.endsWith('.jpeg') ||
//             f.path.endsWith('.png') ||
//             f.path.endsWith('.mp4') ||
//             f.path.endsWith('.opus'))
//         .toList();

//     if (files.isEmpty) return;

//     final prefs = await SharedPreferences.getInstance();

//     final seen = prefs.getStringList('seen_statuses') ?? [];

//     final newFiles = files
//         .map((f) => f.path.split('/').last)
//         .where((name) => !seen.contains(name))
//         .toList();

//     if (newFiles.isEmpty) return;

//     ///  Notification
//     await NotificationService.showNewStatusNotification(
//       count: newFiles.length,
//     );

//     ///  update seen list
//     final updated = [...seen, ...newFiles];

//     if (updated.length > 200) {
//       updated.removeRange(0, updated.length - 200);
//     }

//     await prefs.setStringList('seen_statuses', updated);
//   } catch (e) {
//     print('Scan error: $e');
//   }
// }