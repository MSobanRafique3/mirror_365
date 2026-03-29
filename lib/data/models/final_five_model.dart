import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'final_five_model.g.dart';

@HiveType(typeId: HiveTypeIds.finalFiveEntry)
class FinalFiveModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String gratitude;

  @HiveField(3)
  final String achievement;

  @HiveField(4)
  final String lesson;

  @HiveField(5)
  final String intention;

  @HiveField(6)
  final String affirmation;

  @HiveField(7)
  final int? moodRating; // 1–5

  const FinalFiveModel({
    required this.id,
    required this.date,
    required this.gratitude,
    required this.achievement,
    required this.lesson,
    required this.intention,
    required this.affirmation,
    this.moodRating,
  });

  FinalFiveModel copyWith({
    String? id,
    DateTime? date,
    String? gratitude,
    String? achievement,
    String? lesson,
    String? intention,
    String? affirmation,
    int? moodRating,
  }) {
    return FinalFiveModel(
      id: id ?? this.id,
      date: date ?? this.date,
      gratitude: gratitude ?? this.gratitude,
      achievement: achievement ?? this.achievement,
      lesson: lesson ?? this.lesson,
      intention: intention ?? this.intention,
      affirmation: affirmation ?? this.affirmation,
      moodRating: moodRating ?? this.moodRating,
    );
  }

  bool get isComplete =>
      gratitude.isNotEmpty &&
      achievement.isNotEmpty &&
      lesson.isNotEmpty &&
      intention.isNotEmpty &&
      affirmation.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        date,
        gratitude,
        achievement,
        lesson,
        intention,
        affirmation,
        moodRating,
      ];
}
