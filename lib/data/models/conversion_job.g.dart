// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_job.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversionJobAdapter extends TypeAdapter<ConversionJob> {
  @override
  final int typeId = 0;

  @override
  ConversionJob read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionJob(
      id: fields[0] as String,
      inputFormat: fields[1] as String,
      outputFormat: fields[2] as String,
      category: fields[3] as String,
      inputFileName: fields[4] as String,
      outputFilePath: fields[5] as String,
      status: fields[6] as String,
      inputSizeBytes: fields[7] as int,
      outputSizeBytes: fields[8] as int,
      durationMs: fields[9] as int,
      errorMessage: fields[10] as String?,
      createdAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ConversionJob obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inputFormat)
      ..writeByte(2)
      ..write(obj.outputFormat)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.inputFileName)
      ..writeByte(5)
      ..write(obj.outputFilePath)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.inputSizeBytes)
      ..writeByte(8)
      ..write(obj.outputSizeBytes)
      ..writeByte(9)
      ..write(obj.durationMs)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionJobAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
