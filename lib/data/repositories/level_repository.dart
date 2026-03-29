import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

/// Repository for LevelModel — tracks level history and current state.
class LevelRepository {
  final _uuid = const Uuid();

  // ─── Read ────────────────────────────────────────────────────────────────

  List<LevelModel> getAllLevelEvents() {
    return HiveDatabase.levelsBox.values.toList()
      ..sort((a, b) => a.unlockedAt.compareTo(b.unlockedAt));
  }

  /// Returns the most recently unlocked level record.
  LevelModel? getCurrentLevelRecord() {
    final all = getAllLevelEvents();
    if (all.isEmpty) return null;
    return all.last;
  }

  int get currentLevel => getCurrentLevelRecord()?.currentLevel ?? 1;

  String get currentLevelName =>
      getCurrentLevelRecord()?.levelName ?? kLevelNames[1]!;

  LevelModel? getLevelById(String key) {
    return HiveDatabase.levelsBox.get(key);
  }

  List<LevelModel> getDropEvents() {
    return getAllLevelEvents().where((l) => l.droppedAt != -1).toList();
  }

  bool get hasEverDropped => getDropEvents().isNotEmpty;

  int get totalDrops => getDropEvents().length;

  // ─── Create ──────────────────────────────────────────────────────────────

  Future<LevelModel> recordLevelUnlock({
    required int level,
    required int unlockedAtDay,
  }) async {
    assert(level >= 1 && level <= 7,
        'Level must be between 1 and 7, got $level');
    final record = LevelModel(
      currentLevel: level,
      levelName: kLevelNames[level] ?? 'Level $level',
      unlockedAt: unlockedAtDay,
    );
    final key = _uuid.v4();
    await HiveDatabase.levelsBox.put(key, record);
    return record;
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  Future<void> updateLevelRecord(String key, LevelModel record) async {
    await HiveDatabase.levelsBox.put(key, record);
  }

  /// Records a level drop for the current record.
  Future<LevelModel?> recordDrop({required int droppedAtDay}) async {
    final all = HiveDatabase.levelsBox;
    if (all.isEmpty) return null;

    // Find the key → value pair for the latest record.
    String? latestKey;
    LevelModel? latestRecord;
    for (final key in all.keys) {
      final v = all.get(key);
      if (v == null) continue;
      if (latestRecord == null ||
          v.unlockedAt > latestRecord.unlockedAt) {
        latestKey = key.toString();
        latestRecord = v;
      }
    }
    if (latestKey == null || latestRecord == null) return null;
    final updated = latestRecord.copyWith(droppedAt: droppedAtDay);
    await all.put(latestKey, updated);
    return updated;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await HiveDatabase.levelsBox.clear();
  }
}
