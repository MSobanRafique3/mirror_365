import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

/// Repository for DayRecordModel — one record per journey day.
class DayRecordRepository {
  final _uuid = const Uuid();

  // ─── Constants ───────────────────────────────────────────────────────────

  static const int _msPerDay = 86400000; // 24 * 60 * 60 * 1000

  // ─── Read ────────────────────────────────────────────────────────────────

  List<DayRecordModel> getAllRecords() {
    return HiveDatabase.dayRecordsBox.values.toList()
      ..sort((a, b) => a.journeyDay.compareTo(b.journeyDay));
  }

  DayRecordModel? getRecordByDay(int journeyDay) {
    try {
      return HiveDatabase.dayRecordsBox.values
          .firstWhere((r) => r.journeyDay == journeyDay);
    } catch (_) {
      return null;
    }
  }

  DayRecordModel? getRecordById(String id) {
    try {
      return HiveDatabase.dayRecordsBox.values
          .firstWhere((r) => r.dayRecordId == id);
    } catch (_) {
      return null;
    }
  }

  List<DayRecordModel> getRecordsByMonth(int monthNumber) {
    return getAllRecords()
        .where((r) => r.monthNumber == monthNumber)
        .toList();
  }

  List<DayRecordModel> getPureDays() {
    return getAllRecords().where((r) => r.isPure).toList();
  }

  List<DayRecordModel> getFailedDays() {
    return getAllRecords().where((r) => r.isFailed).toList();
  }

  int get totalPureDays => getPureDays().length;
  int get totalFailedDays => getFailedDays().length;

  double get overallJourneyCompletionRate {
    final all = getAllRecords();
    if (all.isEmpty) return 0.0;
    final sum = all.fold<double>(0, (s, r) => s + r.overallCompletionRate);
    return sum / all.length;
  }

  // ─── Create ──────────────────────────────────────────────────────────────

  /// Creates the DayRecord for [journeyDay].
  /// [startTimestamp] is the journey's epoch-ms start (from UserJourneyModel).
  Future<DayRecordModel> createDayRecord({
    required int journeyDay,
    required int journeyStartTimestamp,
  }) async {
    // Derive month/day-in-month from journeyDay (1-indexed, 30 days/month)
    final monthNumber = ((journeyDay - 1) ~/ 30) + 1;
    final dayInMonth = ((journeyDay - 1) % 30) + 1;

    final dayStartTs =
        journeyStartTimestamp + (journeyDay - 1) * _msPerDay;
    final dayEndTs = dayStartTs + _msPerDay - 1;

    final record = DayRecordModel(
      dayRecordId: _uuid.v4(),
      journeyDay: journeyDay,
      monthNumber: monthNumber.clamp(1, 12),
      dayInMonth: dayInMonth.clamp(1, 30),
      dayStartTimestamp: dayStartTs,
      dayEndTimestamp: dayEndTs,
      isSpecialDay: journeyDay >= 361,
    );
    await HiveDatabase.dayRecordsBox.put(record.dayRecordId, record);
    return record;
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  Future<void> updateRecord(DayRecordModel record) async {
    await HiveDatabase.dayRecordsBox.put(record.dayRecordId, record);
  }

  Future<DayRecordModel?> finaliseDay({
    required int journeyDay,
    required double completionRate,
  }) async {
    final record = getRecordByDay(journeyDay);
    if (record == null) return null;
    final isPure = completionRate >= 1.0;
    final isFailed = completionRate == 0.0;
    final updated = record.copyWith(
      overallCompletionRate: completionRate,
      isPure: isPure,
      isFailed: isFailed,
    );
    await updateRecord(updated);
    return updated;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteRecord(String id) async {
    await HiveDatabase.dayRecordsBox.delete(id);
  }

  Future<void> clearAll() async {
    await HiveDatabase.dayRecordsBox.clear();
  }
}
