import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

/// Repository for the single UserJourneyModel record.
/// Key used: journeyId (there is always at most one journey).
class UserJourneyRepository {
  final _uuid = const Uuid();

  // ─── Read ────────────────────────────────────────────────────────────────

  UserJourneyModel? getJourney() {
    final box = HiveDatabase.journeyBox;
    if (box.isEmpty) return null;
    return box.values.first;
  }

  bool get hasJourney => HiveDatabase.journeyBox.isNotEmpty;

  // ─── Create ──────────────────────────────────────────────────────────────

  /// Creates the journey record and marks it as started.
  /// [startTimestamp] defaults to now in epoch milliseconds.
  Future<UserJourneyModel> createJourney({int? startTimestamp}) async {
    final journey = UserJourneyModel(
      journeyId: _uuid.v4(),
      startTimestamp:
          startTimestamp ?? DateTime.now().millisecondsSinceEpoch,
      isStarted: true,
    );
    await HiveDatabase.journeyBox.put(journey.journeyId, journey);
    return journey;
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  Future<void> updateJourney(UserJourneyModel journey) async {
    await HiveDatabase.journeyBox.put(journey.journeyId, journey);
  }

  Future<UserJourneyModel?> markCompleted({
    required double finalScore,
    required int finalLevel,
  }) async {
    final journey = getJourney();
    if (journey == null) return null;
    final updated = journey.copyWith(
      isCompleted: true,
      finalScore: finalScore,
      finalLevel: finalLevel,
    );
    await updateJourney(updated);
    return updated;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteJourney() async {
    await HiveDatabase.journeyBox.clear();
  }
}
