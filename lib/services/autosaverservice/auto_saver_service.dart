import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoSaverService {
  static const String _tag = '[AutoSaver]';
  static const String _prefKey = 'auto_saver_enabled';
  static const String _savedFilesKey = 'auto_saver_saved_files';

  //  FIXED: correct channel name
  static const MethodChannel _channel =
      MethodChannel('com.example.status_saver/media_scanner');

  static const List<String> _statusPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
  ];

  static const List<String> _allowedExtensions = [
    'jpg', 'jpeg', 'png', 'mp4', 'gif', 'webp',
  ];

  static const String _savePath =
      '/storage/emulated/0/Pictures/StatusSaver';

  Timer? _timer;
  bool _isRunning = false;
  final Set<String> _savedFiles = {};

  int _sessionChecks = 0;
  int _sessionSaved = 0;
  int _sessionSkipped = 0;
  int _sessionErrors = 0;

  static final AutoSaverService _instance = AutoSaverService._internal();
  factory AutoSaverService() => _instance;
  AutoSaverService._internal();

  bool get isRunning => _isRunning;
  int get sessionSaved => _sessionSaved;
  int get sessionChecks => _sessionChecks;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> _setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> _loadSavedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedFilesKey) ?? [];
    _savedFiles.addAll(list);
    _log('Loaded ${list.length} previously saved paths from prefs');
  }

  Future<void> _persistSavedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedFilesKey, _savedFiles.toList());
  }

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;
    _log('Requesting permissions…');
    if (await _isAndroid13OrAbove()) {
      final results =
          await [Permission.photos, Permission.videos].request();
      final photosGranted = results[Permission.photos]?.isGranted ?? false;
      final videosGranted = results[Permission.videos]?.isGranted ?? false;
      if (photosGranted && videosGranted) return true;
    }
    final manage = await Permission.manageExternalStorage.request();
    if (manage.isGranted) return true;
    final storage = await Permission.storage.request();
    if (storage.isGranted) return true;
    _log('All permission requests failed');
    return false;
  }

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return true;
    if (await _isAndroid13OrAbove()) {
      return await Permission.photos.isGranted &&
          await Permission.videos.isGranted;
    }
    if (await Permission.manageExternalStorage.isGranted) return true;
    return await Permission.storage.isGranted;
  }

  Future<void> start() async {
    if (_isRunning) {
      _log('Already running — ignoring start()');
      return;
    }

    final granted = await requestPermissions();
    if (!granted) {
      _log('START ABORTED — permissions not granted');
      return;
    }

    await _loadSavedFiles();
    await _rescanExistingFiles();

    _isRunning = true;
    _sessionChecks = 0;
    _sessionSaved = 0;
    _sessionSkipped = 0;
    _sessionErrors = 0;
    await _setEnabled(true);
    _log('STARTED — checking every 30 s');

    await _checkAndSave();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkAndSave();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _setEnabled(false);
    _log('STOPPED — session: checks=$_sessionChecks  saved=$_sessionSaved  '
        'skipped=$_sessionSkipped  errors=$_sessionErrors');
  }

  Future<void> _rescanExistingFiles() async {
    final dir = Directory(_savePath);
    if (!await dir.exists()) {
      _log('StatusSaver folder does not exist yet — skipping re-scan');
      return;
    }

    _log('Re-scanning existing files in StatusSaver for gallery indexing…');
    int count = 0;

    try {
      final entities = await dir.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          final ext =
              entity.uri.pathSegments.last.split('.').last.toLowerCase();
          if (_allowedExtensions.contains(ext)) {
            await _scanMedia(entity.path);
            count++;
          }
        }
      }
      _log('Re-scan complete — notified MediaStore for $count file(s)');
    } catch (e) {
      _log('Re-scan error → $e');
    }
  }

  Future<void> _checkAndSave() async {
    _sessionChecks++;
    _log('── Check #$_sessionChecks ─────────────────────────────────────────');

    final saveDir = await _getSaveDirectory();
    if (saveDir == null) {
      _log('Save directory unavailable — aborting check');
      return;
    }
    _log('Save directory: ${saveDir.path}');

    bool anySourceFound = false;

    for (final sourcePath in _statusPaths) {
      final dir = Directory(sourcePath);
      final exists = await dir.exists();
      _log('exists=$exists  path=$sourcePath');
      if (!exists) continue;

      anySourceFound = true;

      List<FileSystemEntity> entities;
      try {
        entities = await dir.list().toList();
        _log('  ${entities.length} entries found');
      } catch (e) {
        _sessionErrors++;
        _log('  Cannot list directory → $e');
        continue;
      }

      for (final entity in entities) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (name.startsWith('.')) continue;

        final ext = name.split('.').last.toLowerCase();
        if (!_allowedExtensions.contains(ext)) {
          _log('  Ignored (bad ext): $name');
          continue;
        }

        if (_savedFiles.contains(entity.path)) {
          final destFile = File('${saveDir.path}/$name');
          if (await destFile.exists()) {
            _sessionSkipped++;
            _log('  Already processed (dest confirmed): $name');
            continue;
          } else {
            _log('  Was processed but dest file missing — will re-save: $name');
            _savedFiles.remove(entity.path);
            await _persistSavedFiles();
          }
        }

        await _saveFile(entity, saveDir, name);
      }
    }

    if (!anySourceFound) {
      _log('No WA status folder accessible — check permissions / WA install path');
    }

    _log('── Stats: saved=$_sessionSaved  skipped=$_sessionSkipped  '
        'errors=$_sessionErrors ─────────────────────────────────────────');
  }

  Future<void> _saveFile(File source, Directory destDir, String name) async {
    final destPath = '${destDir.path}/$name';
    _log('  → Processing: $name');

    try {
      final destFile = File(destPath);

      if (await destFile.exists()) {
        _savedFiles.add(source.path);
        await _persistSavedFiles();
        _sessionSkipped++;
        _log('  Destination exists — marking known + scanning: $name');
        await _scanMedia(destPath);
        return;
      }

      await source.copy(destPath);
      _savedFiles.add(source.path);
      await _persistSavedFiles();
      _sessionSaved++;
      _log('  SAVED: $name → $destPath');
      await _scanMedia(destPath);
    } catch (e) {
      _sessionErrors++;
      _log('  ERROR for $name → $e');
    }
  }

  Future<void> _scanMedia(String path) async {
    try {
      await _channel.invokeMethod<void>('scanFile', {'path': path});
      _log('  ✅ Gallery notified: $path');
    } on MissingPluginException {
      _log('  ❌ ERROR: MediaScanner MethodChannel not registered!');
    } catch (e) {
      _log('  Gallery notification failed → $e');
    }
  }

  Future<Directory?> _getSaveDirectory() async {
    try {
      final dir = Directory(_savePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        _log('Created public save directory: $_savePath');
      }
      return dir;
    } catch (e) {
      _log('Could not use public path → $e — trying path_provider fallback');
    }

    try {
      final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.pictures);
      if (dirs == null || dirs.isEmpty) {
        _log('getExternalStorageDirectories() returned empty');
        return null;
      }
      final fallback = Directory('${dirs.first.path}/StatusSaver');
      if (!await fallback.exists()) {
        await fallback.create(recursive: true);
      }
      _log('Using fallback directory: ${fallback.path}');
      return fallback;
    } catch (e) {
      _log('Fallback directory failed → $e');
      return null;
    }
  }

  void _log(String msg) => debugPrint('$_tag $msg');

  Future<bool> _isAndroid13OrAbove() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      final sdk = int.tryParse(result.stdout.toString().trim()) ?? 0;
      _log('Android SDK: $sdk');
      return sdk >= 33;
    } catch (_) {
      _log('Could not read SDK version — defaulting to Android 13+ behaviour');
      return true;
    }
  }
}