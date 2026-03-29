import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

/// Repository for JourneyGoalModel — goals that live inside the 365-day journey.
class JourneyGoalRepository {
  final _uuid = const Uuid();

  // ─── Read ────────────────────────────────────────────────────────────────

  List<JourneyGoalModel> getAllGoals() {
    return HiveDatabase.journeyGoalsBox.values.toList();
  }

  List<JourneyGoalModel> getActiveGoals() {
    return getAllGoals().where((g) => g.isActive).toList();
  }

  List<JourneyGoalModel> getGoalsByCategory(GoalCategory category) {
    return getActiveGoals().where((g) => g.category == category).toList();
  }

  /// Goals that were active on or before [journeyDay].
  List<JourneyGoalModel> getGoalsActiveOnDay(int journeyDay) {
    return getActiveGoals()
        .where((g) => g.addedOnDay <= journeyDay)
        .toList();
  }

  JourneyGoalModel? getGoalById(String goalId) {
    try {
      return HiveDatabase.journeyGoalsBox.values
          .firstWhere((g) => g.goalId == goalId);
    } catch (_) {
      return null;
    }
  }

  // ─── Create ──────────────────────────────────────────────────────────────

  Future<JourneyGoalModel> addGoal({
    required String title,
    required String description,
    required GoalCategory category,
    required int addedOnDay,
    required String targetValue,
  }) async {
    final goal = JourneyGoalModel(
      goalId: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      addedOnDay: addedOnDay,
      isActive: true,
      targetValue: targetValue,
    );
    await HiveDatabase.journeyGoalsBox.put(goal.goalId, goal);
    return goal;
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  Future<void> updateGoal(JourneyGoalModel goal) async {
    await HiveDatabase.journeyGoalsBox.put(goal.goalId, goal);
  }

  Future<JourneyGoalModel?> updateTargetValue(
      String goalId, String newTargetValue) async {
    final goal = getGoalById(goalId);
    if (goal == null) return null;
    final updated = goal.copyWith(targetValue: newTargetValue);
    await updateGoal(updated);
    return updated;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  /// Hard delete — only used for admin/testing. In production goals are permanent.
  Future<void> deleteGoal(String goalId) async {
    await HiveDatabase.journeyGoalsBox.delete(goalId);
  }

  Future<void> clearAll() async {
    await HiveDatabase.journeyGoalsBox.clear();
  }
}
