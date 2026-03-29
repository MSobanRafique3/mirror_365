import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'level_model.g.dart';

/// Tracks the user's progression through 7 XP levels.
/// One record per level unlock event — latest record = current state.
@HiveType(typeId: HiveTypeIds.level)
class LevelModel extends Equatable {
  /// 1–7.
  @HiveField(0)
  final int currentLevel;

  @HiveField(1)
  final String levelName;

  /// Journey day on which this level was unlocked.
  @HiveField(2)
  final int unlockedAt;

  /// Journey day on which the user dropped from this level.
  /// -1 means they have never dropped (still holding or surpassed it).
  @HiveField(3)
  final int droppedAt;

  const LevelModel({
    required this.currentLevel,
    required this.levelName,
    required this.unlockedAt,
    this.droppedAt = -1,
  });

  bool get neverDropped => droppedAt == -1;

  LevelModel copyWith({
    int? currentLevel,
    String? levelName,
    int? unlockedAt,
    int? droppedAt,
  }) {
    return LevelModel(
      currentLevel: currentLevel ?? this.currentLevel,
      levelName: levelName ?? this.levelName,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      droppedAt: droppedAt ?? this.droppedAt,
    );
  }

  @override
  List<Object?> get props => [currentLevel, levelName, unlockedAt, droppedAt];
}

/// Maps level number → canonical name.
const Map<int, String> kLevelNames = {
  1: 'Seedling',
  2: 'Sprout',
  3: 'Sapling',
  4: 'Tree',
  5: 'Elder',
  6: 'Sage',
  7: 'Transcendent',
};
