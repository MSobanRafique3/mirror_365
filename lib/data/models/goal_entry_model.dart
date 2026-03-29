import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'goal_entry_model.g.dart';

/// One entry per (goal × journey day) — records whether a goal
/// was completed on a specific day.
@HiveType(typeId: HiveTypeIds.goalEntry)
class GoalEntryModel extends Equatable {
  @HiveField(0)
  final String entryId;

  @HiveField(1)
  final String goalId;

  /// Journey day this entry belongs to (1–365).
  @HiveField(2)
  final int journeyDay;

  @HiveField(3)
  final bool isCompleted;

  /// Epoch ms when the goal was marked complete. 0 if not yet completed.
  @HiveField(4)
  final int completedAt;

  @HiveField(5)
  final String notes;

  const GoalEntryModel({
    required this.entryId,
    required this.goalId,
    required this.journeyDay,
    this.isCompleted = false,
    this.completedAt = 0,
    this.notes = '',
  });

  GoalEntryModel copyWith({
    String? entryId,
    String? goalId,
    int? journeyDay,
    bool? isCompleted,
    int? completedAt,
    String? notes,
  }) {
    return GoalEntryModel(
      entryId: entryId ?? this.entryId,
      goalId: goalId ?? this.goalId,
      journeyDay: journeyDay ?? this.journeyDay,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        entryId,
        goalId,
        journeyDay,
        isCompleted,
        completedAt,
        notes,
      ];
}
