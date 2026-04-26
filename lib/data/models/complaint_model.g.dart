// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComplaintModelAdapter extends TypeAdapter<ComplaintModel> {
  @override
  final int typeId = 1;

  @override
  ComplaintModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComplaintModel(
      id: fields[0] as int?,
      flatNumber: fields[1] as int,
      description: fields[2] as String,
      status: fields[3] as String,
      isSynced: fields[4] as bool,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ComplaintModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.flatNumber)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.isSynced)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
