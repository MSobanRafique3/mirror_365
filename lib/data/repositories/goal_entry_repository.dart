import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

/// Repository for GoalEntryModel — one entry per (goal × journey day).
class GoalEntryRepository {
  final _uuid = const Uuid();

  // ─── Read ────────────────────────────────────────────────────────────────

  List<GoalEntryModel> getAllEntries() {
    return HiveDatabase.goalEntriesBox.values.toList();
  }

  List<GoalEntryModel> getEntriesForDay(int journeyDay) {
    return getAllEntries()
        .where((e) => e.journeyDay == journeyDay)
        .toList();
  }

  List<GoalEntryModel> getEntriesForGoal(String goalId) {
    return getAllEntries().where((e) => e.goalId == goalId).toList();
  }

  GoalEntryModel? getEntry({required String goalId, required int journeyDay}) {
    try {
      return HiveDatabase.goalEntriesBox.values.firstWhere(
        (e) => e.goalId == goalId && e.journeyDay == journeyDay,
      );
    } catch (_) {
      return null;
    }
  }

  GoalEntryModel? getEntryById(String entryId) {
    try {
      return HiveDatabase.goalEntriesBox.values
          .firstWhere((e) => e.entryId == entryId);
    } catch (_) {
      return null;
    }
  }

  List<GoalEntryModel> getCompletedEntriesForDay(int journeyDay) {
    return getEntriesForDay(journeyDay)
        .where((e) => e.isCompleted)
        .toList();
  }

  /// 0.0–1.0 completion rate for a given journey day.
  double completionRateForDay(int journeyDay) {
    final dayEntries = getEntriesForDay(journeyDay);
    if (dayEntries.isEmpty) return 0.0;
    final completed = dayEntries.where((e) => e.isCompleted).length;
    return completed / dayEntries.length;
  }

  bool allCompletedForDay(int journeyDay) {
    final dayEntries = getEntriesForDay(journeyDay);
    if (dayEntries.isEmpty) return false;
    return dayEntries.every((e) => e.isCompleted);
  }

  // ─── Create ──────────────────────────────────────────────────────────────

  /// Creates a blank (uncompleted) entry for a goal on a given day.
  Future<GoalEntryModel> createEntry({
    required String goalId,
    required int journeyDay,
  }) async {
    final entry = GoalEntryModel(
      entryId: _uuid.v4(),
      goalId: goalId,
      journeyDay: journeyDay,
    );
    await HiveDatabase.goalEntriesBox.put(entry.entryId, entry);
    return entry;
  }

  /// Creates blank entries for all provided [goalIds] on [journeyDay].
  Future<List<GoalEntryModel>> createEntriesForDay({
    required List<String> goalIds,
    required int journeyDay,
  }) async {
    final results = <GoalEntryModel>[];
    for (final gId in goalIds) {
      // Skip if an entry already exists for this goal+day combination.
      final existing = getEntry(goalId: gId, journeyDay: journeyDay);
      if (existing != null) {
        results.add(existing);
        continue;
      }
      results.add(await createEntry(goalId: gId, journeyDay: journeyDay));
    }
    return results;
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  Future<void> updateEntry(GoalEntryModel entry) async {
    await HiveDatabase.goalEntriesBox.put(entry.entryId, entry);
  }

  /// Marks a goal entry as complete with current epoch timestamp.
  Future<GoalEntryModel?> markComplete({
    required String goalId,
    required int journeyDay,
    String notes = '',
    int? completedAtMs,
  }) async {
    final entry = getEntry(goalId: goalId, journeyDay: journeyDay);
    if (entry == null) return null;
    final updated = entry.copyWith(
      isCompleted: true,
      completedAt: completedAtMs ?? DateTime.now().millisecondsSinceEpoch,
      notes: notes,
    );
    await updateEntry(updated);
    return updated;
  }

  /// Reverts a completed entry back to incomplete.
  Future<GoalEntryModel?> markIncomplete({
    required String goalId,
    required int journeyDay,
  }) async {
    final entry = getEntry(goalId: goalId, journeyDay: journeyDay);
    if (entry == null) return null;
    final updated = entry.copyWith(
      isCompleted: false,
      completedAt: 0,
      notes: '',
    );
    await updateEntry(updated);
    return updated;
  }

  Future<GoalEntryModel?> updateNotes({
    required String entryId,
    required String notes,
  }) async {
    final entry = getEntryById(entryId);
    if (entry == null) return null;
    final updated = entry.copyWith(notes: notes);
    await updateEntry(updated);
    return updated;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteEntry(String entryId) async {
    await HiveDatabase.goalEntriesBox.delete(entryId);
  }

  Future<void> deleteEntriesForGoal(String goalId) async {
    final toDelete = getEntriesForGoal(goalId).map((e) => e.entryId).toList();
    await HiveDatabase.goalEntriesBox.deleteAll(toDelete);
  }

  Future<void> clearAll() async {
    await HiveDatabase.goalEntriesBox.clear();
  }
}
