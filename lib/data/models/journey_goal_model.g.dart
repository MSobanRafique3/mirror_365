// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JourneyGoalModelAdapter extends TypeAdapter<JourneyGoalModel> {
  @override
  final int typeId = 6;

  @override
  JourneyGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JourneyGoalModel(
      goalId: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as GoalCategory,
      addedOnDay: fields[4] as int,
      isActive: fields[5] as bool,
      targetValue: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JourneyGoalModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.goalId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.addedOnDay)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.targetValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalCategoryAdapter extends TypeAdapter<GoalCategory> {
  @override
  final int typeId = 11;

  @override
  GoalCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalCategory.daily;
      case 1:
        return GoalCategory.monthly;
      case 2:
        return GoalCategory.yearly;
      default:
        return GoalCategory.daily;
    }
  }

  @override
  void write(BinaryWriter writer, GoalCategory obj) {
    switch (obj) {
      case GoalCategory.daily:
        writer.writeByte(0);
        break;
      case GoalCategory.monthly:
        writer.writeByte(1);
        break;
      case GoalCategory.yearly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
