// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoticeModelAdapter extends TypeAdapter<NoticeModel> {
  @override
  final int typeId = 2;

  @override
  NoticeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoticeModel(
      id: fields[0] as int?,
      title: fields[1] as String,
      body: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      isSynced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoticeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoticeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
