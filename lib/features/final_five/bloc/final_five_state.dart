import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

class FinalFiveState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final int currentJourneyDay;
  
  // Controls if the user swiped up to dismiss the daily confrontation screen (361, 362)
  final bool isDismissed; 

  // Day 361 - The Wound
  final DayRecordModel? worstDayRec;
  final List<String> worstDayFailedGoals;

  // Day 362 - The Peak
  final DayRecordModel? bestDayRec;
  final List<String> bestDayCompletedGoals;
  final int bestDayDistance; // days ago

  // Day 363 - The Full Mirror / Day 365
  final List<DayRecordModel> allDays;
  final int totalPureDays;
  final int totalFailedDays;
  final double finalDisciplineScore;
  
  // Day 364 - The Confessions
  final List<MonthlyConfessionModel> confessions;

  // Day 365 - The Certificate Additions
  final LevelModel? finalLevel;
  final int longestPureStreak;
  final double worstWeekAvg;
  final double bestWeekAvg;
  final int totalGoalsCompleted;
  final int totalGoalsPossible;
  final int journeyStartMs;

  const FinalFiveState({
    this.isLoading = true,
    this.errorMessage,
    this.currentJourneyDay = 361,
    this.isDismissed = false,

    this.worstDayRec,
    this.worstDayFailedGoals = const [],
    this.bestDayRec,
    this.bestDayCompletedGoals = const [],
    this.bestDayDistance = 0,
    
    this.allDays = const [],
    this.totalPureDays = 0,
    this.totalFailedDays = 0,
    this.finalDisciplineScore = 0.0,
    
    this.confessions = const [],
    
    this.finalLevel,
    this.longestPureStreak = 0,
    this.worstWeekAvg = 0.0,
    this.bestWeekAvg = 0.0,
    this.totalGoalsCompleted = 0,
    this.totalGoalsPossible = 0,
    this.journeyStartMs = 0,
  });

  FinalFiveState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? currentJourneyDay,
    bool? isDismissed,
    DayRecordModel? worstDayRec,
    List<String>? worstDayFailedGoals,
    DayRecordModel? bestDayRec,
    List<String>? bestDayCompletedGoals,
    int? bestDayDistance,
    List<DayRecordModel>? allDays,
    int? totalPureDays,
    int? totalFailedDays,
    double? finalDisciplineScore,
    List<MonthlyConfessionModel>? confessions,
    LevelModel? finalLevel,
    int? longestPureStreak,
    double? worstWeekAvg,
    double? bestWeekAvg,
    int? totalGoalsCompleted,
    int? totalGoalsPossible,
    int? journeyStartMs,
  }) {
    return FinalFiveState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentJourneyDay: currentJourneyDay ?? this.currentJourneyDay,
      isDismissed: isDismissed ?? this.isDismissed,
      worstDayRec: worstDayRec ?? this.worstDayRec,
      worstDayFailedGoals: worstDayFailedGoals ?? this.worstDayFailedGoals,
      bestDayRec: bestDayRec ?? this.bestDayRec,
      bestDayCompletedGoals: bestDayCompletedGoals ?? this.bestDayCompletedGoals,
      bestDayDistance: bestDayDistance ?? this.bestDayDistance,
      allDays: allDays ?? this.allDays,
      totalPureDays: totalPureDays ?? this.totalPureDays,
      totalFailedDays: totalFailedDays ?? this.totalFailedDays,
      finalDisciplineScore: finalDisciplineScore ?? this.finalDisciplineScore,
      confessions: confessions ?? this.confessions,
      finalLevel: finalLevel ?? this.finalLevel,
      longestPureStreak: longestPureStreak ?? this.longestPureStreak,
      worstWeekAvg: worstWeekAvg ?? this.worstWeekAvg,
      bestWeekAvg: bestWeekAvg ?? this.bestWeekAvg,
      totalGoalsCompleted: totalGoalsCompleted ?? this.totalGoalsCompleted,
      totalGoalsPossible: totalGoalsPossible ?? this.totalGoalsPossible,
      journeyStartMs: journeyStartMs ?? this.journeyStartMs,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        currentJourneyDay,
        isDismissed,
        worstDayRec,
        worstDayFailedGoals,
        bestDayRec,
        bestDayCompletedGoals,
        bestDayDistance,
        allDays,
        totalPureDays,
        totalFailedDays,
        finalDisciplineScore,
        confessions,
        finalLevel,
        longestPureStreak,
        worstWeekAvg,
        bestWeekAvg,
        totalGoalsCompleted,
        totalGoalsPossible,
        journeyStartMs,
      ];
}
