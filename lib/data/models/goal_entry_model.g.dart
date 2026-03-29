// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalEntryModelAdapter extends TypeAdapter<GoalEntryModel> {
  @override
  final int typeId = 8;

  @override
  GoalEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalEntryModel(
      entryId: fields[0] as String,
      goalId: fields[1] as String,
      journeyDay: fields[2] as int,
      isCompleted: fields[3] as bool,
      completedAt: fields[4] as int,
      notes: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GoalEntryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.entryId)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.journeyDay)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
