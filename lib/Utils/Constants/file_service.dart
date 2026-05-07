import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/Utils/Constants/userFeedback.dart';
import 'package:status_saver/config/components/status_saver_app_snack_bar.dart';

import '../../Local Database/LocalDatabase.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

/// Determines media type string from file path
String _getMediaType(String path, {bool? isVideo}) {
  if (isVideo != null) return isVideo ? 'video' : 'image';
  final lower = path.toLowerCase();
  if (lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.avi')) {
    return 'video';
  } else if (lower.endsWith('.mp3') ||
      lower.endsWith('.ogg') ||
      lower.endsWith('.opus')) {
    return 'audio';
  }
  return 'image';
}

//  GLOBAL SAFETY FLAGS (IMPORTANT FIX)
bool _isSaving = false;
DateTime? _lastSaveTap;

/// Saves any media (image/video/audio) permanently to local storage + Hive DB
Future<void> saveMedia(
  BuildContext context,
  String originalPath, {
  bool? isVideo,
  bool isAudio = false,
}) async {
  if (_isSaving) return;
  _isSaving = true;

  try {
    final file = File(originalPath);

    if (!await file.exists()) {
      showAppSnackBar(
        context: context,
        title: "Error",
        message: "File not found",
        contentType: ContentType.failure,
      );
      return;
    }

    //  Permission FIX (clean version)
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();

        if (!photos.isGranted && !videos.isGranted) {
          openAppSettings();
          return;
        }
      } else {
        final storage = await Permission.storage.request();
        if (!storage.isGranted) {
          openAppSettings();
          return;
        }
      }
    }

    final ext = originalPath.split('.').last.toLowerCase();
    final fileName =
        "status_${DateTime.now().millisecondsSinceEpoch}.$ext";

    final mediaType = _getMediaType(originalPath, isVideo: isVideo);

    //  FIX: Separate handling (NO plugin crash)
    final result = await SaverGallery.saveFile(
      filePath: originalPath,
      fileName: fileName,
      skipIfExists: false,

      //  IMPORTANT FIX
      androidRelativePath: mediaType == 'video'
          ? "Movies/StatusSaver"
          : "Pictures/StatusSaver",
    );

    if (result.isSuccess) {
      final box = Hive.box<SavedItem>('saved_items');

      final exists = box.values.any((e) => e.path == originalPath);

      if (!exists) {
        await box.add(SavedItem(
          path: originalPath,
          type: mediaType,
          dateTime: DateTime.now(),
        ));
      }

      if (context.mounted) {
  StatusSaverAppSnackBar.show(
  context,
  title: "Image & Video Saved",
  subtitle: "Saved Successfully to Gallery",
  icon: Icons.download_done,
);
      }
    } else {
      throw Exception(result.errorMessage ?? "Save failed");
    }
  } catch (e) {
    debugPrint(" SAVE ERROR: $e");

    if (context.mounted) {
      showAppSnackBar(
        context: context,
        title: "Error",
        message: "Save failed: $e",
        contentType: ContentType.failure,
      );
    }
  } finally {
    _isSaving = false;
  }
}
// ==========================repost status function==================

Future<void> repostStatus(BuildContext context, String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) {
      showAppSnackBar(
        context: context,
        title: "Error",
        message: "File not found ",
        contentType: ContentType.failure,
      );
      return;
    }

    await Share.shareXFiles(
      [XFile(path)],
      sharePositionOrigin: Rect.zero,
    );
  } catch (e) {
    showAppSnackBar(
      context: context,
      title: "Error",
      message: e.toString(),
      contentType: ContentType.failure,
    );
  }
}
/// DELETE ITEM (UNCHANGED)
Future<void> deleteItem(BuildContext context, String path,
    {bool deleteFromDisk = true}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Delete File",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text("Are you sure you want to delete this file?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    if (deleteFromDisk) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final box = Hive.box<SavedItem>('saved_items');
    final item = box.values.firstWhere(
      (element) => element.path == path,
      orElse: () => throw Exception("Item not found"),
    );

    await item.delete();

    if (context.mounted) {
      showAppSnackBar(
        context: context,
        title: "Deleted",
        message: "Successfully Deleted ",
        contentType: ContentType.success,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

/// BOTTOM BAR (UNCHANGED)
Widget mediaBottomBar({
  required BuildContext context,
  required String imagePath,
  required bool isFromSavedScreen,
  required VoidCallback onShare,
  required VoidCallback onRepost,
  required Future<void> Function() onSave,
  required Future<void> Function() onDelete,
  required Widget Function(VoidCallback, String, String) bottomButton,
  required String repostIcon,
  required String shareIcon,
  required String saveIcon,
  required String deleteIcon,
  required String repostText,
  required String shareText,
  required String saveText,
  required String deleteText,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        bottomButton(onRepost, repostIcon, repostText),
        bottomButton(onShare, shareIcon, shareText),
        isFromSavedScreen
            ? bottomButton(() async => await onDelete(), deleteIcon, deleteText)
            : bottomButton(() async => await onSave(), saveIcon, saveText),
      ],
    ),
  );
}