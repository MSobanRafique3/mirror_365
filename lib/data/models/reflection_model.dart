import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';
import '../../core/constants/app_constants.dart';

part 'reflection_model.g.dart';

@HiveType(typeId: HiveTypeIds.reflection)
class ReflectionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final int promptTypeIndex; // MirrorPromptType index

  @HiveField(3)
  final String? prompt; // the actual prompt text shown

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int? moodRating; // 1–5

  @HiveField(6)
  final String? goalId; // linked goal if any

  const ReflectionModel({
    required this.id,
    required this.content,
    required this.promptTypeIndex,
    this.prompt,
    required this.createdAt,
    this.moodRating,
    this.goalId,
  });

  MirrorPromptType get promptType =>
      MirrorPromptType.values[promptTypeIndex];

  ReflectionModel copyWith({
    String? id,
    String? content,
    int? promptTypeIndex,
    String? prompt,
    DateTime? createdAt,
    int? moodRating,
    String? goalId,
  }) {
    return ReflectionModel(
      id: id ?? this.id,
      content: content ?? this.content,
      promptTypeIndex: promptTypeIndex ?? this.promptTypeIndex,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
      moodRating: moodRating ?? this.moodRating,
      goalId: goalId ?? this.goalId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        promptTypeIndex,
        prompt,
        createdAt,
        moodRating,
        goalId,
      ];
}
