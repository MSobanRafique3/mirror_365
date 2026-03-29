// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_confession_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyConfessionModelAdapter
    extends TypeAdapter<MonthlyConfessionModel> {
  @override
  final int typeId = 9;

  @override
  MonthlyConfessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyConfessionModel(
      confessionId: fields[0] as String,
      monthNumber: fields[1] as int,
      writtenAt: fields[2] as int,
      content: fields[3] as String,
      isUnlocked: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyConfessionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.confessionId)
      ..writeByte(1)
      ..write(obj.monthNumber)
      ..writeByte(2)
      ..write(obj.writtenAt)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyConfessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
