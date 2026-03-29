// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_journey_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserJourneyModelAdapter extends TypeAdapter<UserJourneyModel> {
  @override
  final int typeId = 5;

  @override
  UserJourneyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserJourneyModel(
      journeyId: fields[0] as String,
      startTimestamp: fields[1] as int,
      isStarted: fields[2] as bool,
      isCompleted: fields[3] as bool,
      finalScore: fields[4] as double,
      finalLevel: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserJourneyModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.journeyId)
      ..writeByte(1)
      ..write(obj.startTimestamp)
      ..writeByte(2)
      ..write(obj.isStarted)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.finalScore)
      ..writeByte(5)
      ..write(obj.finalLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserJourneyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
