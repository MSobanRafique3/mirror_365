import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

class FinalFiveRepository {
  final _uuid = const Uuid();

  List<FinalFiveModel> getAllEntries() {
    return HiveDatabase.finalFiveBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  FinalFiveModel? getEntryForDate(DateTime date) {
    try {
      return HiveDatabase.finalFiveBox.values.firstWhere((e) {
        return e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day;
      });
    } catch (_) {
      return null;
    }
  }

  FinalFiveModel? getTodayEntry() => getEntryForDate(DateTime.now());

  Future<FinalFiveModel> createEntry({
    required String gratitude,
    required String achievement,
    required String lesson,
    required String intention,
    required String affirmation,
    int? moodRating,
    DateTime? date,
  }) async {
    final entry = FinalFiveModel(
      id: _uuid.v4(),
      date: date ?? DateTime.now(),
      gratitude: gratitude,
      achievement: achievement,
      lesson: lesson,
      intention: intention,
      affirmation: affirmation,
      moodRating: moodRating,
    );
    await HiveDatabase.finalFiveBox.put(entry.id, entry);
    return entry;
  }

  Future<void> updateEntry(FinalFiveModel entry) async {
    await HiveDatabase.finalFiveBox.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await HiveDatabase.finalFiveBox.delete(id);
  }

  bool hasTodayEntry() => getTodayEntry() != null;

  int get totalCompleteDays {
    return getAllEntries().where((e) => e.isComplete).length;
  }
}
