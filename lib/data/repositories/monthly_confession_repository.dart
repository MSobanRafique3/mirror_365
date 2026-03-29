import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

/// Repository for MonthlyConfessionModel.
class MonthlyConfessionRepository {
  final _uuid = const Uuid();

  // ─── Read ────────────────────────────────────────────────────────────────

  List<MonthlyConfessionModel> getAllConfessions() {
    return HiveDatabase.confessionsBox.values.toList()
      ..sort((a, b) => a.monthNumber.compareTo(b.monthNumber));
  }

  MonthlyConfessionModel? getConfessionForMonth(int monthNumber) {
    try {
      return HiveDatabase.confessionsBox.values
          .firstWhere((c) => c.monthNumber == monthNumber);
    } catch (_) {
      return null;
    }
  }

  MonthlyConfessionModel? getConfessionById(String id) {
    try {
      return HiveDatabase.confessionsBox.values
          .firstWhere((c) => c.confessionId == id);
    } catch (_) {
      return null;
    }
  }

  List<MonthlyConfessionModel> getUnlockedConfessions() {
    return getAllConfessions().where((c) => c.isUnlocked).toList();
  }

  bool hasConfessionForMonth(int monthNumber) {
    return getConfessionForMonth(monthNumber) != null;
  }

  // ─── Create ──────────────────────────────────────────────────────────────

  Future<MonthlyConfessionModel> createConfession({
    required int monthNumber,
    required String content,
    bool isUnlocked = false,
    int? writtenAtMs,
  }) async {
    if (monthNumber > 1) {
      if (!hasConfessionForMonth(monthNumber - 1)) {
        throw Exception('Cannot write confession for Month $monthNumber without completing Month ${monthNumber - 1}.');
      }
    }

    final confession = MonthlyConfessionModel(
      confessionId: _uuid.v4(),
      monthNumber: monthNumber,
      writtenAt: writtenAtMs ?? DateTime.now().millisecondsSinceEpoch,
      content: content,
      isUnlocked: isUnlocked,
    );
    await HiveDatabase.confessionsBox.put(confession.confessionId, confession);
    return confession;
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  Future<void> updateConfession(MonthlyConfessionModel confession) async {
    await HiveDatabase.confessionsBox
        .put(confession.confessionId, confession);
  }

  Future<MonthlyConfessionModel?> updateContent(
      String confessionId, String content) async {
    final c = getConfessionById(confessionId);
    if (c == null) return null;
    final updated = c.copyWith(content: content);
    await updateConfession(updated);
    return updated;
  }

  /// Unlocks all confessions (called when Day 365 is finalised).
  Future<void> unlockAllConfessions() async {
    final all = getAllConfessions();
    for (final c in all) {
      if (!c.isUnlocked) {
        await updateConfession(c.copyWith(isUnlocked: true));
      }
    }
  }

  Future<MonthlyConfessionModel?> unlockConfession(
      String confessionId) async {
    final c = getConfessionById(confessionId);
    if (c == null) return null;
    final updated = c.copyWith(isUnlocked: true);
    await updateConfession(updated);
    return updated;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteConfession(String confessionId) async {
    await HiveDatabase.confessionsBox.delete(confessionId);
  }

  Future<void> clearAll() async {
    await HiveDatabase.confessionsBox.clear();
  }
}
