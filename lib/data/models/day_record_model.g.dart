// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayRecordModelAdapter extends TypeAdapter<DayRecordModel> {
  @override
  final int typeId = 7;

  @override
  DayRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayRecordModel(
      dayRecordId: fields[0] as String,
      journeyDay: fields[1] as int,
      monthNumber: fields[2] as int,
      dayInMonth: fields[3] as int,
      dayStartTimestamp: fields[4] as int,
      dayEndTimestamp: fields[5] as int,
      isPure: fields[6] as bool,
      isFailed: fields[7] as bool,
      isSpecialDay: fields[8] as bool,
      overallCompletionRate: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DayRecordModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.dayRecordId)
      ..writeByte(1)
      ..write(obj.journeyDay)
      ..writeByte(2)
      ..write(obj.monthNumber)
      ..writeByte(3)
      ..write(obj.dayInMonth)
      ..writeByte(4)
      ..write(obj.dayStartTimestamp)
      ..writeByte(5)
      ..write(obj.dayEndTimestamp)
      ..writeByte(6)
      ..write(obj.isPure)
      ..writeByte(7)
      ..write(obj.isFailed)
      ..writeByte(8)
      ..write(obj.isSpecialDay)
      ..writeByte(9)
      ..write(obj.overallCompletionRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
