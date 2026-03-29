import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

class GoalCardData extends Equatable {
  final JourneyGoalModel goal;
  final double completionRate; // e.g. 0.72 = 72%
  final int totalDaysActive;
  final int totalCompleted;
  
  // Visual specific data
  final List<bool> last14DaysSparkline; // For Daily (14 days max)
  final List<bool> currentMonthGrid;    // For Monthly (30 days max)
  final List<int> yearlyBlocks;         // For Yearly (12 blocks: 0=Grey, 1=Red, 2=Yellow, 3=Gold)

  const GoalCardData({
    required this.goal,
    required this.completionRate,
    required this.totalDaysActive,
    required this.totalCompleted,
    this.last14DaysSparkline = const [],
    this.currentMonthGrid = const [],
    this.yearlyBlocks = const [],
  });

  @override
  List<Object?> get props => [
        goal,
        completionRate,
        totalDaysActive,
        totalCompleted,
        last14DaysSparkline,
        currentMonthGrid,
        yearlyBlocks,
      ];
}

class GoalsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<GoalCardData> dailyGoals;
  final List<GoalCardData> monthlyGoals;
  final List<GoalCardData> yearlyGoals;

  const GoalsState({
    this.isLoading = true,
    this.errorMessage,
    this.dailyGoals = const [],
    this.monthlyGoals = const [],
    this.yearlyGoals = const [],
  });

  GoalsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GoalCardData>? dailyGoals,
    List<GoalCardData>? monthlyGoals,
    List<GoalCardData>? yearlyGoals,
  }) {
    return GoalsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      monthlyGoals: monthlyGoals ?? this.monthlyGoals,
      yearlyGoals: yearlyGoals ?? this.yearlyGoals,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        dailyGoals,
        monthlyGoals,
        yearlyGoals,
      ];
}
