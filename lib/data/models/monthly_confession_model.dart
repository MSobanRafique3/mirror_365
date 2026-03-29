import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'monthly_confession_model.g.dart';

/// End-of-month written reflection.
/// Unlocked (isUnlocked = true) only after Day 365.
@HiveType(typeId: HiveTypeIds.monthlyConfession)
class MonthlyConfessionModel extends Equatable {
  @HiveField(0)
  final String confessionId;

  /// Month number within the journey (1–12).
  @HiveField(1)
  final int monthNumber;

  /// Epoch ms when the confession was written.
  @HiveField(2)
  final int writtenAt;

  @HiveField(3)
  final String content;

  /// Only true after journey Day 365 is complete.
  @HiveField(4)
  final bool isUnlocked;

  const MonthlyConfessionModel({
    required this.confessionId,
    required this.monthNumber,
    required this.writtenAt,
    required this.content,
    this.isUnlocked = false,
  });

  MonthlyConfessionModel copyWith({
    String? confessionId,
    int? monthNumber,
    int? writtenAt,
    String? content,
    bool? isUnlocked,
  }) {
    return MonthlyConfessionModel(
      confessionId: confessionId ?? this.confessionId,
      monthNumber: monthNumber ?? this.monthNumber,
      writtenAt: writtenAt ?? this.writtenAt,
      content: content ?? this.content,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => [
        confessionId,
        monthNumber,
        writtenAt,
        content,
        isUnlocked,
      ];
}
