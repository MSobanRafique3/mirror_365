import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

class LevelsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  
  final int currentLevel;
  final String currentLevelName;
  final String nextLevelRequirementStr;

  final bool currentDropWarningActive;
  final int? dropDaysRemaining;
  final double personalPeakAvg;
  final double latest7DayAvg;

  final List<LevelModel> timelineEvents;

  const LevelsState({
    this.isLoading = true,
    this.errorMessage,
    this.currentLevel = 1,
    this.currentLevelName = 'RAW',
    this.nextLevelRequirementStr = '',
    this.currentDropWarningActive = false,
    this.dropDaysRemaining,
    this.personalPeakAvg = 0.0,
    this.latest7DayAvg = 0.0,
    this.timelineEvents = const [],
  });

  LevelsState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? currentLevel,
    String? currentLevelName,
    String? nextLevelRequirementStr,
    bool? currentDropWarningActive,
    int? dropDaysRemaining,
    double? personalPeakAvg,
    double? latest7DayAvg,
    List<LevelModel>? timelineEvents,
  }) {
    return LevelsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelName: currentLevelName ?? this.currentLevelName,
      nextLevelRequirementStr: nextLevelRequirementStr ?? this.nextLevelRequirementStr,
      currentDropWarningActive: currentDropWarningActive ?? this.currentDropWarningActive,
      dropDaysRemaining: dropDaysRemaining ?? this.dropDaysRemaining,
      personalPeakAvg: personalPeakAvg ?? this.personalPeakAvg,
      latest7DayAvg: latest7DayAvg ?? this.latest7DayAvg,
      timelineEvents: timelineEvents ?? this.timelineEvents,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        currentLevel,
        currentLevelName,
        nextLevelRequirementStr,
        currentDropWarningActive,
        dropDaysRemaining,
        personalPeakAvg,
        latest7DayAvg,
        timelineEvents,
      ];
}
