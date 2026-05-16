import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

const String kScanTask = 'status_scan_task';

const List<String> kStatusPaths = [
  '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
  '/storage/emulated/0/WhatsApp/Media/.Statuses',
  '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
];

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    if (task == kScanTask) {
      await _scanStatuses();
    }
    return true;
  });
}

Future<void> _scanStatuses() async {
  debugPrint('🔵 SCAN STARTED');

  try {
    String? activePath;

    for (final path in kStatusPaths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        activePath = path;
        break;
      }
    }

    if (activePath == null) {
      debugPrint('❌ NO STATUS FOLDER FOUND');
      return;
    }

    final allFiles = await Directory(activePath).list().toList();
    debugPrint('📂 TOTAL FILES: ${allFiles.length}');

    final files = await compute(
      _filterMediaFiles,
      allFiles.map((f) => f.path).toList(),
    );

    if (files.isEmpty) return;

    final fileNames = files.map((p) => p.split('/').last).toSet();
    debugPrint('📋 FILE NAMES: $fileNames');

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); //  Fresh data lo

    final baseline = (prefs.getStringList('baseline_statuses') ?? []).toSet();
    final seen = (prefs.getStringList('seen_statuses') ?? []).toSet();

    debugPrint('🔍 SCANNER BASELINE: ${baseline.length}');
    debugPrint('🔍 SCANNER SEEN: ${seen.length}');
    debugPrint('🔍 SCANNER FILES: ${fileNames.length}');

    //  FIRST RUN
    if (baseline.isEmpty && seen.isEmpty) {
      debugPrint('⚠️ FIRST RUN - saving baseline, no notification');
      await prefs.setStringList('baseline_statuses', fileNames.toList());
      await prefs.setStringList('seen_statuses', fileNames.toList());
      await prefs.setBool('has_new_status', false);
      await prefs.setInt('new_status_count', 0);
      return;
    }

    //  Naye files = jo baseline mein nahi aur seen mein bhi nahi
    final newFiles = fileNames
        .where((f) => !baseline.contains(f) && !seen.contains(f))
        .toSet();

    debugPrint('🆕 NEW FILES: ${newFiles.length} → $newFiles');

    if (newFiles.isEmpty) {
      debugPrint('⚠️ NO NEW STATUS');
      await prefs.setBool('has_new_status', false);
      await prefs.setInt('new_status_count', 0);
      return;
    }

    //  Notification bhejo
    await NotificationService.initialize();
    await NotificationService.showNewStatusNotification(
      count: newFiles.length,
    );
    debugPrint('🔔 NOTIFICATION SENT: ${newFiles.length}');

    //  Seen update karo
    final updatedSeen = seen.union(newFiles);
    await prefs.setStringList('seen_statuses', updatedSeen.toList());
    await prefs.setBool('has_new_status', true);
    await prefs.setInt('new_status_count', newFiles.length);

    debugPrint('💾 UPDATED SEEN: ${updatedSeen.length}');

  } catch (e, stack) {
    debugPrint('💥 ERROR: $e\n$stack');
  }
}

List<String> _filterMediaFiles(List<String> paths) {
  const allowed = {'.jpg', '.jpeg', '.png', '.mp4', '.opus'};
  return paths.where((path) {
    final ext = path.substring(path.lastIndexOf('.')).toLowerCase();
    return allowed.contains(ext);
  }).toList();
}

class StatusScannerService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> startScanning() async {
    await Workmanager().registerPeriodicTask(
      kScanTask,
      kScanTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
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
    await prefs.remove('baseline_statuses');
    await prefs.remove('has_new_status');
    await prefs.remove('new_status_count');
  }

  static Future<bool> hasNewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_new_status') ?? false;
  }

  static Future<int> getNewStatusCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('new_status_count') ?? 0;
  }

  static Future<void> runScanNow() async {
    await _scanStatuses();
  }
}