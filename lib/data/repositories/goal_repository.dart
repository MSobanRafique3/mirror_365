import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

class GoalRepository {
  final _uuid = const Uuid();

  List<GoalModel> getAllGoals() {
    return HiveDatabase.goalsBox.values.toList();
  }

  GoalModel? getGoalById(String id) {
    return HiveDatabase.goalsBox.values
        .cast<GoalModel?>()
        .firstWhere((g) => g?.id == id, orElse: () => null);
  }

  Future<void> addGoal(GoalModel goal) async {
    await HiveDatabase.goalsBox.put(goal.id, goal);
  }

  Future<GoalModel> createGoal({
    required String title,
    String? description,
    required int categoryIndex,
    int priorityIndex = 1,
    int statusIndex = 0,
    DateTime? targetDate,
    int targetDays = 365,
    String? color,
  }) async {
    final goal = GoalModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      categoryIndex: categoryIndex,
      priorityIndex: priorityIndex,
      statusIndex: statusIndex,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      targetDays: targetDays,
      color: color,
    );
    await addGoal(goal);
    return goal;
  }

  Future<void> updateGoal(GoalModel goal) async {
    await HiveDatabase.goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await HiveDatabase.goalsBox.delete(id);
  }

  Future<void> checkIn(String goalId) async {
    final goal = getGoalById(goalId);
    if (goal == null) return;
    final updated = goal.copyWith(
      checkIns: [...goal.checkIns, DateTime.now()],
    );
    await updateGoal(updated);
  }

  List<GoalModel> getActiveGoals() {
    return getAllGoals()
        .where((g) => g.statusIndex == 0) // GoalStatus.active
        .toList();
  }

  List<GoalModel> getCompletedGoals() {
    return getAllGoals()
        .where((g) => g.statusIndex == 1) // GoalStatus.completed
        .toList();
  }
}
