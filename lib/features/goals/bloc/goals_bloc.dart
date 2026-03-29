import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import 'goals_event.dart';
import 'goals_state.dart';

export 'goals_event.dart';
export 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final JourneyGoalRepository _goalRepo;
  final GoalEntryRepository _entryRepo;
  final JourneyTimeService _timeService;

  GoalsBloc({
    required JourneyGoalRepository goalRepo,
    required GoalEntryRepository entryRepo,
    required JourneyTimeService timeService,
  })  : _goalRepo = goalRepo,
        _entryRepo = entryRepo,
        _timeService = timeService,
        super(const GoalsState()) {
    on<GoalsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
      GoalsLoadRequested event, Emitter<GoalsState> emit) async {
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final snapshot = _timeService.snapshot(nowMs);
      final currentDay = snapshot.journeyDay;

      // Fetch all goals
      final allGoals = _goalRepo.getAllGoals();
      final dailyData = <GoalCardData>[];
      final monthlyData = <GoalCardData>[];
      final yearlyData = <GoalCardData>[];

      for (final goal in allGoals) {
        final totalActive = currentDay - goal.addedOnDay + 1;
        
        // Count completions
        final entries = _entryRepo.getEntriesForGoal(goal.goalId);
        final completedCount = entries.where((e) => e.isCompleted).length;
        final floatRate = totalActive > 0 ? (completedCount / totalActive) : 0.0;
        
        // 1. Build sparklines or blocks depending on category
        List<bool> sparkline = <bool>[];
        List<bool> monthlyGrid = <bool>[];
        List<int> yearlyBlocks = <int>[];

        if (goal.category == GoalCategory.daily) {
          // Last 14 days logic
          final startDay = currentDay - 13 < 1 ? 1 : currentDay - 13;
          for (int d = startDay; d <= currentDay; d++) {
            if (d < goal.addedOnDay) {
              sparkline.add(false); // Can't be completed before added
            } else {
              final e = entries.cast<GoalEntryModel?>().firstWhere(
                  (x) => x?.journeyDay == d, orElse: () => null);
              sparkline.add(e?.isCompleted ?? false);
            }
          }
        } 
        else if (goal.category == GoalCategory.monthly) {
          // Current month grid (30 blocks). 
          // Find the start day of the current 30-day block.
          final monthStartIndex = ((currentDay - 1) ~/ 30) * 30 + 1;
          for (int d = monthStartIndex; d < monthStartIndex + 30; d++) {
            if (d > currentDay) {
              monthlyGrid.add(false);
            } else if (d < goal.addedOnDay) {
              monthlyGrid.add(false);
            } else {
              final e = entries.cast<GoalEntryModel?>().firstWhere(
                  (x) => x?.journeyDay == d, orElse: () => null);
              monthlyGrid.add(e?.isCompleted ?? false);
            }
          }
        } 
        else if (goal.category == GoalCategory.yearly) {
          // 12 blocks for the year.
          // 0=Grey/Future, 1=Red(<10), 2=Yellow(10-19), 3=Gold(20+)
          final currentCompletedMonthIndex = (currentDay - 1) ~/ 30; // 0 to 11
          for (int m = 0; m < 12; m++) {
            if (m > currentCompletedMonthIndex) {
              // Future month
              yearlyBlocks.add(0);
            } else {
              // Calculate completions in this specific month block
              int completionsThisMonth = 0;
              final startD = m * 30 + 1;
              final endD = startD + 29;
              for (int d = startD; d <= endD; d++) {
                if (d <= currentDay && d >= goal.addedOnDay) {
                  final e = entries.cast<GoalEntryModel?>().firstWhere(
                      (x) => x?.journeyDay == d, orElse: () => null);
                  if (e?.isCompleted == true) completionsThisMonth++;
                }
              }

              // Assess condition — 20/30 days threshold
              if (completionsThisMonth >= 20) {
                yearlyBlocks.add(3); // Gold
              } else if (completionsThisMonth >= 10) {
                yearlyBlocks.add(2); // Yellow
              } else {
                yearlyBlocks.add(1); // Red
              }
            }
          }
        }

        final cardData = GoalCardData(
          goal: goal,
          completionRate: floatRate,
          totalDaysActive: totalActive > 0 ? totalActive : 0,
          totalCompleted: completedCount,
          last14DaysSparkline: sparkline,
          currentMonthGrid: monthlyGrid,
          yearlyBlocks: yearlyBlocks,
        );

        if (goal.category == GoalCategory.daily) dailyData.add(cardData);
        if (goal.category == GoalCategory.monthly) monthlyData.add(cardData);
        if (goal.category == GoalCategory.yearly) yearlyData.add(cardData);
      }

      emit(state.copyWith(
        isLoading: false,
        dailyGoals: dailyData,
        monthlyGoals: monthlyData,
        yearlyGoals: yearlyData,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
