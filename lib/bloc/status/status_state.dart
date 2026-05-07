import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'status_event.dart';

class StatusState extends Equatable {
  final List<FileSystemEntity> images;
  final List<FileSystemEntity> videos;
  final List<FileSystemEntity> audio;
  final bool isLoading;
  final bool isWhatsappAvailable;
  final WhatsAppType currentType;
  final Map<String, Uint8List?> thumbnailCache;

  const StatusState({
    this.images = const [],
    this.videos = const [],
    this.audio = const [],
    this.isLoading = false,
    this.isWhatsappAvailable = false,
    this.currentType = WhatsAppType.regular,
    this.thumbnailCache = const {},
  });

  StatusState copyWith({
    List<FileSystemEntity>? images,
    List<FileSystemEntity>? videos,
    List<FileSystemEntity>? audio,
    bool? isLoading,
    bool? isWhatsappAvailable,
    WhatsAppType? currentType,
    Map<String, Uint8List?>? thumbnailCache,
  }) {
    return StatusState(
      images: images ?? this.images,
      videos: videos ?? this.videos,
      audio: audio ?? this.audio,
      isLoading: isLoading ?? this.isLoading,
      isWhatsappAvailable:
          isWhatsappAvailable ?? this.isWhatsappAvailable,
      currentType: currentType ?? this.currentType,
      thumbnailCache: thumbnailCache ?? this.thumbnailCache,
    );
  }

  @override
  List<Object?> get props => [
        images,
        videos,
        audio,
        isLoading,
        isWhatsappAvailable,
        currentType,
        thumbnailCache,
      ];
}