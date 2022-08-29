// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompressDbAdapter extends TypeAdapter<CompressDb> {
  @override
  final int typeId = 1;

  @override
  CompressDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompressDb(
      filePath: fields[0] as String,
      compressedDate: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompressDb obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.compressedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
