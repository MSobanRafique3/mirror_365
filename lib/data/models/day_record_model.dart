import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'day_record_model.g.dart';

/// One record per journey day — aggregated at end-of-day.
@HiveType(typeId: HiveTypeIds.dayRecord)
class DayRecordModel extends Equatable {
  @HiveField(0)
  final String dayRecordId;

  /// 1-based day within the 365-day journey.
  @HiveField(1)
  final int journeyDay;

  /// Which month (1–12) this day belongs to (30 days per month).
  @HiveField(2)
  final int monthNumber;

  /// Day within the month (1–30).
  @HiveField(3)
  final int dayInMonth;

  /// Epoch ms when this journey day started (= startTimestamp + (journeyDay-1)*86400000).
  @HiveField(4)
  final int dayStartTimestamp;

  /// Epoch ms when this journey day ended (= dayStartTimestamp + 86400000 - 1).
  @HiveField(5)
  final int dayEndTimestamp;

  /// True only if ALL active goals were completed for this day.
  @HiveField(6)
  final bool isPure;

  /// True if the user explicitly marked the day as failed, or missed check-in.
  @HiveField(7)
  final bool isFailed;

  /// True for days 361–365 (the Final Five).
  @HiveField(8)
  final bool isSpecialDay;

  /// 0.0–1.0: completed goals / total active goals.
  @HiveField(9)
  final double overallCompletionRate;

  const DayRecordModel({
    required this.dayRecordId,
    required this.journeyDay,
    required this.monthNumber,
    required this.dayInMonth,
    required this.dayStartTimestamp,
    required this.dayEndTimestamp,
    this.isPure = false,
    this.isFailed = false,
    this.isSpecialDay = false,
    this.overallCompletionRate = 0.0,
  });

  DayRecordModel copyWith({
    String? dayRecordId,
    int? journeyDay,
    int? monthNumber,
    int? dayInMonth,
    int? dayStartTimestamp,
    int? dayEndTimestamp,
    bool? isPure,
    bool? isFailed,
    bool? isSpecialDay,
    double? overallCompletionRate,
  }) {
    return DayRecordModel(
      dayRecordId: dayRecordId ?? this.dayRecordId,
      journeyDay: journeyDay ?? this.journeyDay,
      monthNumber: monthNumber ?? this.monthNumber,
      dayInMonth: dayInMonth ?? this.dayInMonth,
      dayStartTimestamp: dayStartTimestamp ?? this.dayStartTimestamp,
      dayEndTimestamp: dayEndTimestamp ?? this.dayEndTimestamp,
      isPure: isPure ?? this.isPure,
      isFailed: isFailed ?? this.isFailed,
      isSpecialDay: isSpecialDay ?? this.isSpecialDay,
      overallCompletionRate:
          overallCompletionRate ?? this.overallCompletionRate,
    );
  }

  @override
  List<Object?> get props => [
        dayRecordId,
        journeyDay,
        monthNumber,
        dayInMonth,
        dayStartTimestamp,
        dayEndTimestamp,
        isPure,
        isFailed,
        isSpecialDay,
        overallCompletionRate,
      ];
}
