// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitorModelAdapter extends TypeAdapter<VisitorModel> {
  @override
  final int typeId = 0;

  @override
  VisitorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitorModel(
      id: fields[0] as int?,
      name: fields[1] as String,
      phone: fields[2] as String,
      flatNumber: fields[3] as int,
      checkInTime: fields[4] as String?,
      checkOutTime: fields[5] as String?,
      status: fields[6] as String?,
      isSynced: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VisitorModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.flatNumber)
      ..writeByte(4)
      ..write(obj.checkInTime)
      ..writeByte(5)
      ..write(obj.checkOutTime)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
