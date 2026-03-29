import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

class SessionRepository {
  final _uuid = const Uuid();

  List<SessionModel> getAllSessions() {
    return HiveDatabase.sessionsBox.values.toList();
  }

  List<SessionModel> getSessionsForGoal(String goalId) {
    return getAllSessions().where((s) => s.goalId == goalId).toList();
  }

  List<SessionModel> getSessionsForDate(DateTime date) {
    return getAllSessions().where((s) {
      final d = s.startedAt;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  Future<SessionModel> startSession({
    String? goalId,
    required int typeIndex,
  }) async {
    final session = SessionModel(
      id: _uuid.v4(),
      goalId: goalId,
      typeIndex: typeIndex,
      startedAt: DateTime.now(),
    );
    await HiveDatabase.sessionsBox.put(session.id, session);
    return session;
  }

  Future<SessionModel> endSession(String sessionId) async {
    final session = HiveDatabase.sessionsBox.values
        .firstWhere((s) => s.id == sessionId);
    final now = DateTime.now();
    final updated = session.copyWith(
      endedAt: now,
      durationSeconds: now.difference(session.startedAt).inSeconds,
    );
    await HiveDatabase.sessionsBox.put(session.id, updated);
    return updated;
  }

  Future<void> updateSession(SessionModel session) async {
    await HiveDatabase.sessionsBox.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    await HiveDatabase.sessionsBox.delete(id);
  }

  /// Total focus time in seconds for today
  int getTodayTotalSeconds() {
    final today = DateTime.now();
    return getSessionsForDate(today)
        .fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Returns per-day totals for the last [days] days
  Map<DateTime, int> getDailyTotals({int days = 7}) {
    final now = DateTime.now();
    final result = <DateTime, int>{};
    for (var i = 0; i < days; i++) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      result[day] = getSessionsForDate(day)
          .fold<int>(0, (sum, s) => sum + s.durationSeconds);
    }
    return result;
  }
}
