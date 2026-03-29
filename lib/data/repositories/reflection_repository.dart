import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

class ReflectionRepository {
  final _uuid = const Uuid();

  List<ReflectionModel> getAllReflections() {
    return HiveDatabase.reflectionsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  ReflectionModel? getReflectionById(String id) {
    return HiveDatabase.reflectionsBox.values
        .cast<ReflectionModel?>()
        .firstWhere((r) => r?.id == id, orElse: () => null);
  }

  List<ReflectionModel> getReflectionsForDate(DateTime date) {
    return getAllReflections().where((r) {
      final d = r.createdAt;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  Future<ReflectionModel> addReflection({
    required String content,
    required int promptTypeIndex,
    String? prompt,
    int? moodRating,
    String? goalId,
  }) async {
    final reflection = ReflectionModel(
      id: _uuid.v4(),
      content: content,
      promptTypeIndex: promptTypeIndex,
      prompt: prompt,
      createdAt: DateTime.now(),
      moodRating: moodRating,
      goalId: goalId,
    );
    await HiveDatabase.reflectionsBox.put(reflection.id, reflection);
    return reflection;
  }

  Future<void> updateReflection(ReflectionModel reflection) async {
    await HiveDatabase.reflectionsBox.put(reflection.id, reflection);
  }

  Future<void> deleteReflection(String id) async {
    await HiveDatabase.reflectionsBox.delete(id);
  }

  bool hasTodayReflection() {
    return getReflectionsForDate(DateTime.now()).isNotEmpty;
  }
}
