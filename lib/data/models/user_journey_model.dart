import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'user_journey_model.g.dart';

/// Single source of truth for the 365-day journey.
/// Only one instance ever lives in the box (key = journeyId).
@HiveType(typeId: HiveTypeIds.userJourney)
class UserJourneyModel extends Equatable {
  @HiveField(0)
  final String journeyId;

  /// Epoch milliseconds — all time calculations derive from this value.
  /// Never changes after creation.
  @HiveField(1)
  final int startTimestamp;

  @HiveField(2)
  final bool isStarted;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final double finalScore;

  @HiveField(5)
  final int finalLevel;

  const UserJourneyModel({
    required this.journeyId,
    required this.startTimestamp,
    this.isStarted = false,
    this.isCompleted = false,
    this.finalScore = 0.0,
    this.finalLevel = 1,
  });

  UserJourneyModel copyWith({
    String? journeyId,
    int? startTimestamp,
    bool? isStarted,
    bool? isCompleted,
    double? finalScore,
    int? finalLevel,
  }) {
    return UserJourneyModel(
      journeyId: journeyId ?? this.journeyId,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      isStarted: isStarted ?? this.isStarted,
      isCompleted: isCompleted ?? this.isCompleted,
      finalScore: finalScore ?? this.finalScore,
      finalLevel: finalLevel ?? this.finalLevel,
    );
  }

  @override
  List<Object?> get props => [
        journeyId,
        startTimestamp,
        isStarted,
        isCompleted,
        finalScore,
        finalLevel,
      ];
}
