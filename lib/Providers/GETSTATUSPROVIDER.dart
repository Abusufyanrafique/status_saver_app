// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

// import '../Screens/Constants/Constants.dart';

// enum WhatsAppType { regular, business }

// class GetStatusProvider extends ChangeNotifier {

//   //  Lists
//   List<FileSystemEntity> _getImages = [];
//   List<FileSystemEntity> _getVideos = [];
//   List<FileSystemEntity> _getAudio = [];

//   bool _isWhatsappAvailable = false;
//   bool _isLoading = false;

//   WhatsAppType _currentType = WhatsAppType.regular;

//   //  Getters
//   List<FileSystemEntity> get getImages => _getImages;
//   List<FileSystemEntity> get getVideos => _getVideos;
//   List<FileSystemEntity> get getAudio => _getAudio;

//   bool get isWhatsappAvailable => _isWhatsappAvailable;
//   bool get isLoading => _isLoading;
//   WhatsAppType get currentType => _currentType;

//   //  Thumbnail cache
//   final Map<String, Uint8List?> _thumbnailCache = {};
//   Map<String, Uint8List?> get thumbnailCache => _thumbnailCache;

//   Future<Uint8List?> getThumbnail(String videoPath) async {
//     if (_thumbnailCache.containsKey(videoPath)) {
//       return _thumbnailCache[videoPath];
//     }

//     final thumbnail = await VideoThumbnail.thumbnailData(
//       video: videoPath,
//       imageFormat: ImageFormat.JPEG,
//       maxWidth: 300,
//       quality: 75,
//     );

//     _thumbnailCache[videoPath] = thumbnail;
//     notifyListeners();
//     return thumbnail;
//   }

//   //  Change Type
//   void setWhatsAppType(WhatsAppType type) {
//     _currentType = type;
//     getStatus();
//   }

//   //  MAIN FUNCTION
//   Future<void> getStatus() async {
//     log(" getStatus STARTED");

//     _isLoading = true;
//     _getImages = [];
//     _getVideos = [];
//     _getAudio = [];
//     notifyListeners();

//     try {
//       //  Permission
//       PermissionStatus status;

//       if (Platform.isAndroid) {
//         final androidInfo = await DeviceInfoPlugin().androidInfo;
//         log("📱 Android SDK: ${androidInfo.version.sdkInt}");

//         status = androidInfo.version.sdkInt >= 30
//             ? await Permission.manageExternalStorage.request()
//             : await Permission.storage.request();
//       } else {
//         status = await Permission.storage.request();
//       }

//       log(" Permission: $status");

//       if (!status.isGranted) {
//         log(" Permission denied");
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       //  Paths
//       List<String> paths = _currentType == WhatsAppType.regular
//           ? [
//               AppConstants.WhatsApp_Path,
//               AppConstants.WhatsApp_Old_Path,
//             ]
//           : [
//               AppConstants.WhatsApp_Business_Path,
//             ];

//       log(" Checking paths: $paths");

//       String? workingPath;

//       for (String path in paths) {
//         log(" Checking: $path");

//         if (Directory(path).existsSync()) {
//           workingPath = path;
//           log(" FOUND: $workingPath");
//           break;
//         } else {
//           log(" NOT FOUND: $path");
//         }
//       }

//       if (workingPath == null) {
//         log(" No WhatsApp folder found");
//         _isWhatsappAvailable = false;
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       log(" FINAL PATH: $workingPath");

//       final directory = Directory(workingPath);

//       final allItems = directory.listSync();

//       log("📦 TOTAL ITEMS: ${allItems.length}");

//       for (var item in allItems) {
//         log(" ${item.path}");
//       }

//       final items = allItems.whereType<File>().toList();

//       log(" FILES ONLY: ${items.length}");

//       _isWhatsappAvailable = true;

//       // 🖼 Images
//       _getImages = items.where((e) {
//         final p = e.path.toLowerCase();
//         final ok = p.endsWith(".jpg") ||
//             p.endsWith(".jpeg") ||
//             p.endsWith(".png") ||
//             p.endsWith(".webp");

//         if (ok) log(" IMAGE: $p");
//         return ok;
//       }).toList();

//       //  Videos
//       _getVideos = items.where((e) {
//         final p = e.path.toLowerCase();
//         final ok = p.endsWith(".mp4") ||
//             p.endsWith(".mkv") ||
//             p.endsWith(".3gp") ||
//             p.endsWith(".mov");

//         if (ok) log(" VIDEO: $p");
//         return ok;
//       }).toList();

//       //  Audio
//       _getAudio = items.where((e) {
//         final p = e.path.toLowerCase();
//         final ok = p.endsWith(".mp3") ||
//             p.endsWith(".opus") ||
//             p.endsWith(".aac") ||
//             p.endsWith(".ogg");

//         if (ok) log("🎵 AUDIO: $p");
//         return ok;
//       }).toList();

//       log(" FINAL -> Images: ${_getImages.length}, Videos: ${_getVideos.length}, Audio: ${_getAudio.length}");

//     } catch (e, st) {
//       log(" ERROR: $e");
//       log("STACK: $st");
//     }

//     _isLoading = false;
//     notifyListeners();

//     log(" getStatus FINISHED");
//   }
// }