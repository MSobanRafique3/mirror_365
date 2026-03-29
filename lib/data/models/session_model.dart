import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';
import '../../core/constants/app_constants.dart';

part 'session_model.g.dart';

@HiveType(typeId: HiveTypeIds.session)
class SessionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? goalId;

  @HiveField(2)
  final int typeIndex; // SessionType index

  @HiveField(3)
  final DateTime startedAt;

  @HiveField(4)
  final DateTime? endedAt;

  @HiveField(5)
  final int durationSeconds;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final int? moodRating; // 1–5

  const SessionModel({
    required this.id,
    this.goalId,
    required this.typeIndex,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.notes,
    this.moodRating,
  });

  SessionType get type => SessionType.values[typeIndex];

  bool get isCompleted => endedAt != null;

  Duration get duration => Duration(seconds: durationSeconds);

  SessionModel copyWith({
    String? id,
    String? goalId,
    int? typeIndex,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? notes,
    int? moodRating,
  }) {
    return SessionModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      typeIndex: typeIndex ?? this.typeIndex,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      moodRating: moodRating ?? this.moodRating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        typeIndex,
        startedAt,
        endedAt,
        durationSeconds,
        notes,
        moodRating,
      ];
}
