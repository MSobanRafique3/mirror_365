import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';
import '../../core/constants/app_constants.dart';

part 'goal_model.g.dart';

@HiveType(typeId: HiveTypeIds.goal)
class GoalModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int categoryIndex; // GoalCategory index

  @HiveField(4)
  final int priorityIndex; // GoalPriority index

  @HiveField(5)
  final int statusIndex; // GoalStatus index

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? targetDate;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final int targetDays;

  @HiveField(10)
  final List<DateTime> checkIns;

  @HiveField(11)
  final String? color; // hex string

  const GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.categoryIndex,
    required this.priorityIndex,
    required this.statusIndex,
    required this.createdAt,
    this.targetDate,
    this.completedAt,
    this.targetDays = 365,
    this.checkIns = const [],
    this.color,
  });

  GoalCategory get category => GoalCategory.values[categoryIndex];
  GoalPriority get priority => GoalPriority.values[priorityIndex];
  GoalStatus get status => GoalStatus.values[statusIndex];

  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  double get progressPercent {
    if (targetDays <= 0) return 0;
    return (daysSinceCreation / targetDays).clamp(0.0, 1.0);
  }

  bool get isCompleted => status == GoalStatus.completed;

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    int? categoryIndex,
    int? priorityIndex,
    int? statusIndex,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? completedAt,
    int? targetDays,
    List<DateTime>? checkIns,
    String? color,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      statusIndex: statusIndex ?? this.statusIndex,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      completedAt: completedAt ?? this.completedAt,
      targetDays: targetDays ?? this.targetDays,
      checkIns: checkIns ?? this.checkIns,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryIndex,
        priorityIndex,
        statusIndex,
        createdAt,
        targetDate,
        completedAt,
        targetDays,
        checkIns,
        color,
      ];
}
