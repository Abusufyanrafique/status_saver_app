import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'status_event.dart';
import 'status_state.dart';
import '../../Screens/Constants/Constants.dart';

class StatusBloc extends Bloc<StatusEvent, StatusState> {
  StatusBloc() : super(const StatusState()) {
    on<LoadStatusEvent>(_onLoadStatus);
    on<ChangeWhatsAppTypeEvent>(_onChangeType);
    on<LoadThumbnailEvent>(_onLoadThumbnail);
  }

  //  Change Type
  Future<void> _onChangeType(
      ChangeWhatsAppTypeEvent event,
      Emitter<StatusState> emit) async {
    emit(state.copyWith(currentType: event.type));
    add(LoadStatusEvent());
  }

  //  Thumbnail
  Future<void> _onLoadThumbnail(
      LoadThumbnailEvent event,
      Emitter<StatusState> emit) async {
    if (state.thumbnailCache.containsKey(event.videoPath)) return;

    final thumbnail = await VideoThumbnail.thumbnailData(
      video: event.videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 300,
      quality: 75,
    );

    final updatedCache = Map<String, Uint8List?>.from(state.thumbnailCache);
    updatedCache[event.videoPath] = thumbnail;

    emit(state.copyWith(thumbnailCache: updatedCache));
  }

  //  MAIN FUNCTION
  Future<void> _onLoadStatus(
      LoadStatusEvent event,
      Emitter<StatusState> emit) async {
    log("BLOC getStatus STARTED");

    emit(state.copyWith(
      isLoading: true,
      images: [],
      videos: [],
      audio: [],
    ));

    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        status = androidInfo.version.sdkInt >= 30
            ? await Permission.manageExternalStorage.request()
            : await Permission.storage.request();
      } else {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      List<String> paths = state.currentType == WhatsAppType.regular
          ? [
              AppConstants.WhatsApp_Path,
              AppConstants.WhatsApp_Old_Path,
            ]
          : [
              AppConstants.WhatsApp_Business_Path,
            ];

      String? workingPath;

      for (String path in paths) {
        if (Directory(path).existsSync()) {
          workingPath = path;
          break;
        }
      }

      if (workingPath == null) {
        emit(state.copyWith(
          isWhatsappAvailable: false,
          isLoading: false,
        ));
        return;
      }

      final directory = Directory(workingPath);
      final items =
          directory.listSync().whereType<File>().toList();

      final images = items.where((e) {
        final p = e.path.toLowerCase();
        return p.endsWith(".jpg") ||
            p.endsWith(".jpeg") ||
            p.endsWith(".png") ||
            p.endsWith(".webp");
      }).toList();

      final videos = items.where((e) {
        final p = e.path.toLowerCase();
        return p.endsWith(".mp4") ||
            p.endsWith(".mkv") ||
            p.endsWith(".3gp") ||
            p.endsWith(".mov");
      }).toList();

      final audio = items.where((e) {
        final p = e.path.toLowerCase();
        return p.endsWith(".mp3") ||
            p.endsWith(".opus") ||
            p.endsWith(".aac") ||
            p.endsWith(".ogg");
      }).toList();

      emit(state.copyWith(
        images: images,
        videos: videos,
        audio: audio,
        isWhatsappAvailable: true,
        isLoading: false,
      ));
    } catch (e) {
      log("ERROR: $e");
      emit(state.copyWith(isLoading: false));
    }

    log("BLOC getStatus FINISHED");
  }
}