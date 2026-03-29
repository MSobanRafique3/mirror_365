import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'journey_goal_model.g.dart';

/// Adapter for the GoalCategory enum so Hive can store it natively.
@HiveType(typeId: HiveTypeIds.goalCategory)
enum GoalCategory {
  @HiveField(0)
  daily,

  @HiveField(1)
  monthly,

  @HiveField(2)
  yearly,
}

/// A goal the user commits to during their 365-day journey.
/// Once added, isActive is always true — goals are never removed,
/// only tracked via GoalEntryModel.
@HiveType(typeId: HiveTypeIds.journeyGoal)
class JourneyGoalModel extends Equatable {
  @HiveField(0)
  final String goalId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final GoalCategory category;

  /// Journey day (1–365) on which this goal was added.
  @HiveField(4)
  final int addedOnDay;

  /// Always true once added — never set to false.
  @HiveField(5)
  final bool isActive;

  /// Human-readable target, e.g. "5 times" or "1 hour".
  @HiveField(6)
  final String targetValue;

  const JourneyGoalModel({
    required this.goalId,
    required this.title,
    required this.description,
    required this.category,
    required this.addedOnDay,
    this.isActive = true,
    required this.targetValue,
  });

  JourneyGoalModel copyWith({
    String? goalId,
    String? title,
    String? description,
    GoalCategory? category,
    int? addedOnDay,
    bool? isActive,
    String? targetValue,
  }) {
    return JourneyGoalModel(
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      addedOnDay: addedOnDay ?? this.addedOnDay,
      isActive: isActive ?? this.isActive,
      targetValue: targetValue ?? this.targetValue,
    );
  }

  @override
  List<Object?> get props => [
        goalId,
        title,
        description,
        category,
        addedOnDay,
        isActive,
        targetValue,
      ];
}
