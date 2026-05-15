import 'dart:io';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

const String kScanTask = 'status_scan_task';

const List<String> kStatusPaths = [
  '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
  '/storage/emulated/0/WhatsApp/Media/.Statuses',
  '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
];

class StatusScannerService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Testing ke liye true rakha hai, live par false kar dena
    );
  }

  static Future<void> startScanning() async {
    await Workmanager().registerPeriodicTask(
      kScanTask,
      kScanTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static Future<void> stopScanning() async {
    await Workmanager().cancelByUniqueName(kScanTask);
  }

  static Future<void> clearSeenHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seen_statuses');
  }

  static Future<void> clearNewStatusFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_new_status', false);
  }

  static Future<bool> hasNewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // 🔥 CRITICAL FIX: Background changes ko UI ke sath sync karta hai
    return prefs.getBool('has_new_status') ?? false;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 🔥 CRITICAL FIX: Background isolate ko crash hone se bachane ke liye binding zaroori hai
    WidgetsFlutterBinding.ensureInitialized();
    
    if (task == kScanTask) {
      await _scanStatuses();
    }
    return Future.value(true);
  });
}

Future<void> _scanStatuses() async {
  print('🔵 _scanStatuses() STARTED');

  try {
    String? activePath;
    for (final path in kStatusPaths) {
      final dir = Directory(path);
      final exists = await dir.exists();
      print('📁 Path check: $path => exists: $exists');
      if (exists) {
        activePath = path;
        break;
      }
    }

    if (activePath == null) {
      print('❌ Koi bhi status folder nahi mila — permission missing ya path wrong');
      return;
    }

    print('✅ Active path: $activePath');

    final dir = Directory(activePath);
    final allFiles = dir.listSync();
    print('📂 Total files in folder: ${allFiles.length}');

    final files = allFiles
        .where((f) =>
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.jpeg') ||
            f.path.endsWith('.png') ||
            f.path.endsWith('.mp4') ||
            f.path.endsWith('.opus'))
        .toList();

    print('🖼️ Media files found: ${files.length}');

    if (files.isEmpty) {
      print('⚠️ Koi media file nahi mili');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList('seen_statuses') ?? [];
    print('👁️ Already seen: ${seen.length} files');

    final newFiles = files
        .map((f) => f.path.split('/').last)
        .where((name) => !seen.contains(name))
        .toList();

    print('🆕 New files: ${newFiles.length}');

    if (newFiles.isEmpty) {
      print('⚠️ Koi naya status nahi');
      return;
    }

    // 🟢 Notification Trigger (Service main.dart mein init ho chuki hai)
    await NotificationService.showNewStatusNotification(
      count: newFiles.length,
    );
    print('🔔 Notification sent');

    // Flag true set karein
    await prefs.setBool('has_new_status', true);
    print('🔴 has_new_status = true SET');

    // Cache History Update array size limit 200 items
    final updatedSeen = [...seen, ...newFiles];
    if (updatedSeen.length > 200) {
      updatedSeen.removeRange(0, updatedSeen.length - 200);
    }
    await prefs.setStringList('seen_statuses', updatedSeen);
    print('💾 seen_statuses updated: ${updatedSeen.length} total');

  } catch (e, stack) {
    print('💥 Scan error: $e');
    print('💥 Stack: $stack');
  }
}