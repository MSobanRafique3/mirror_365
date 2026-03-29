import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

class GoalGraphData extends Equatable {
  final String title;
  final double lifetimeCompletionRate;
  final int currentStreak;
  final int longestStreak;
  /// Last 30 days of completion rates (or bools mapped). 0.0 to 1.0. Allows scaling if generic.
  final List<double> sparkline30Days;

  const GoalGraphData({
    required this.title,
    required this.lifetimeCompletionRate,
    required this.currentStreak,
    required this.longestStreak,
    this.sparkline30Days = const [],
  });

  @override
  List<Object?> get props => [
        title,
        lifetimeCompletionRate,
        currentStreak,
        longestStreak,
        sparkline30Days,
      ];
}

class GraphsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  
  final int currentJourneyDay;

  // 1. Year Map
  final List<DayRecordModel> yearMapDays;

  // 2. Daily Discipline Chart
  final List<DayRecordModel> last30Days;
  final double personalLifetimeAverage;

  // 3. Weekly Rhythm
  // Tuple/Map mapping Weekday (1=Mon, 7=Sun) to Average Rate
  final Map<int, double> weekdayAverages;
  final int weakestWeekday;

  // 4. Goal Breakdown
  final List<GoalGraphData> goalBreakdowns;

  // 5. Velocity
  // Evaluated 7-day trailing average coordinates (day, average)
  final List<MapEntry<int, double>> velocitySeries;
  final bool comfortZoneWarning;

  // 6. Honest Mirror
  final bool honestMirrorUnlocked; // Day > 28
  final bool shouldFlashMirror; // Day 28, 56, 84 etc. and hasn't flashed today

  const GraphsState({
    this.isLoading = true,
    this.errorMessage,
    this.currentJourneyDay = 1,
    this.yearMapDays = const [],
    this.last30Days = const [],
    this.personalLifetimeAverage = 0.0,
    this.weekdayAverages = const {},
    this.weakestWeekday = 1,
    this.goalBreakdowns = const [],
    this.velocitySeries = const [],
    this.comfortZoneWarning = false,
    this.honestMirrorUnlocked = false,
    this.shouldFlashMirror = false,
  });

  GraphsState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? currentJourneyDay,
    List<DayRecordModel>? yearMapDays,
    List<DayRecordModel>? last30Days,
    double? personalLifetimeAverage,
    Map<int, double>? weekdayAverages,
    int? weakestWeekday,
    List<GoalGraphData>? goalBreakdowns,
    List<MapEntry<int, double>>? velocitySeries,
    bool? comfortZoneWarning,
    bool? honestMirrorUnlocked,
    bool? shouldFlashMirror,
  }) {
    return GraphsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentJourneyDay: currentJourneyDay ?? this.currentJourneyDay,
      yearMapDays: yearMapDays ?? this.yearMapDays,
      last30Days: last30Days ?? this.last30Days,
      personalLifetimeAverage: personalLifetimeAverage ?? this.personalLifetimeAverage,
      weekdayAverages: weekdayAverages ?? this.weekdayAverages,
      weakestWeekday: weakestWeekday ?? this.weakestWeekday,
      goalBreakdowns: goalBreakdowns ?? this.goalBreakdowns,
      velocitySeries: velocitySeries ?? this.velocitySeries,
      comfortZoneWarning: comfortZoneWarning ?? this.comfortZoneWarning,
      honestMirrorUnlocked: honestMirrorUnlocked ?? this.honestMirrorUnlocked,
      shouldFlashMirror: shouldFlashMirror ?? this.shouldFlashMirror,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        currentJourneyDay,
        yearMapDays,
        last30Days,
        personalLifetimeAverage,
        weekdayAverages,
        weakestWeekday,
        goalBreakdowns,
        velocitySeries,
        comfortZoneWarning,
        honestMirrorUnlocked,
        shouldFlashMirror,
      ];
}
