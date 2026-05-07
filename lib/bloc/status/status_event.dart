import 'package:equatable/equatable.dart';

enum WhatsAppType { regular, business }

abstract class StatusEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStatusEvent extends StatusEvent {}

class ChangeWhatsAppTypeEvent extends StatusEvent {
  final WhatsAppType type;

  ChangeWhatsAppTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadThumbnailEvent extends StatusEvent {
  final String videoPath;

  LoadThumbnailEvent(this.videoPath);

  @override
  List<Object?> get props => [videoPath];
}