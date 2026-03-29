// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'final_five_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinalFiveModelAdapter extends TypeAdapter<FinalFiveModel> {
  @override
  final int typeId = 4;

  @override
  FinalFiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinalFiveModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      gratitude: fields[2] as String,
      achievement: fields[3] as String,
      lesson: fields[4] as String,
      intention: fields[5] as String,
      affirmation: fields[6] as String,
      moodRating: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FinalFiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.gratitude)
      ..writeByte(3)
      ..write(obj.achievement)
      ..writeByte(4)
      ..write(obj.lesson)
      ..writeByte(5)
      ..write(obj.intention)
      ..writeByte(6)
      ..write(obj.affirmation)
      ..writeByte(7)
      ..write(obj.moodRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinalFiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
