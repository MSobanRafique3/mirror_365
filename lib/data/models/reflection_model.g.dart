// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReflectionModelAdapter extends TypeAdapter<ReflectionModel> {
  @override
  final int typeId = 3;

  @override
  ReflectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReflectionModel(
      id: fields[0] as String,
      content: fields[1] as String,
      promptTypeIndex: fields[2] as int,
      prompt: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      moodRating: fields[5] as int?,
      goalId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReflectionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.promptTypeIndex)
      ..writeByte(3)
      ..write(obj.prompt)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.moodRating)
      ..writeByte(6)
      ..write(obj.goalId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
