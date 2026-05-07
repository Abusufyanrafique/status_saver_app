// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LocalDatabase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedItemAdapter extends TypeAdapter<SavedItem> {
  @override
  final int typeId = 0;

  @override
  SavedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedItem(
      path: fields[0] as String,
      type: fields[1] as String,
      dateTime: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
