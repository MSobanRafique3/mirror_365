import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import 'final_five_event.dart';
import 'final_five_state.dart';

export 'final_five_event.dart';
export 'final_five_state.dart';

class FinalFiveBloc extends Bloc<FinalFiveEvent, FinalFiveState> {
  final UserJourneyRepository _userRepo;
  final DayRecordRepository _dayRepo;
  final JourneyGoalRepository _goalRepo;
  final GoalEntryRepository _entryRepo;
  final MonthlyConfessionRepository _confessRepo;
  final LevelRepository _levelRepo;

  FinalFiveBloc({
    required UserJourneyRepository userRepo,
    required DayRecordRepository dayRepo,
    required JourneyGoalRepository goalRepo,
    required GoalEntryRepository entryRepo,
    required MonthlyConfessionRepository confessRepo,
    required LevelRepository levelRepo,
  })  : _userRepo = userRepo,
        _dayRepo = dayRepo,
        _goalRepo = goalRepo,
        _entryRepo = entryRepo,
        _confessRepo = confessRepo,
        _levelRepo = levelRepo,
        super(const FinalFiveState()) {
    on<FinalFiveLoadRequested>(_onLoadRequested);
    on<FinalFiveScreenDismissed>(_onDismissed);
  }

  Future<void> _onLoadRequested(
      FinalFiveLoadRequested event, Emitter<FinalFiveState> emit) async {
    try {
      final currentDay = event.currentJourneyDay;
      final journey = _userRepo.getJourney();
      final journeyStartMs = journey?.startTimestamp ?? 0;

      final allDays = _dayRepo.getAllRecords();
      final allGoals = _goalRepo.getAllGoals();
      final allConfessions = _confessRepo.getAllConfessions()
        ..sort((a, b) => a.monthNumber.compareTo(b.monthNumber));

      // Metrics
      int totalPure = 0;
      int totalFailed = 0;
      
      DayRecordModel? worstDay;
      DayRecordModel? bestDay;

      double curWorstAvg = 2.0; 
      double curBestAvg = -1.0; 

      int tempPureStreak = 0;
      int maxPureStreak = 0;

      // 7-day tracking arrays
      final weekAverages = <double>[];

      for (int i = 0; i < allDays.length; i++) {
        final d = allDays[i];

        if (d.isPure) {
          totalPure++;
          tempPureStreak++;
          if (tempPureStreak > maxPureStreak) maxPureStreak = tempPureStreak;
        } else {
          tempPureStreak = 0;
        }

        if (d.isFailed) totalFailed++;

        // Finding Worst Day (lowest completion rate)
        if (d.overallCompletionRate < curWorstAvg) {
          curWorstAvg = d.overallCompletionRate;
          worstDay = d;
        }

        // Finding Best Day (highest completion rate)
        // Tie breaker goes to the first Pure day encountered, or most recent.
        // We will just prioritize highest rate > isPure.
        if (d.overallCompletionRate > curBestAvg) {
          curBestAvg = d.overallCompletionRate;
          bestDay = d;
        } else if (d.overallCompletionRate == curBestAvg) {
          // If tie, prefer a pure day. If both pure, keep latest (highest day number)
          if (!bestDay!.isPure && d.isPure) {
            bestDay = d;
          } else if (bestDay!.isPure == d.isPure && d.journeyDay > bestDay!.journeyDay) {
            bestDay = d;
          }
        }

        // Map Rolling 7-day average for Worst/Best Week metric
        double sum = 0;
        int maxJ = max(0, i - 6);
        for (int j = maxJ; j <= i; j++) sum += allDays[j].overallCompletionRate;
        weekAverages.add(sum / (i - maxJ + 1));
      }

      double bestWk = weekAverages.isNotEmpty ? weekAverages.reduce(max) : 0;
      double worstWk = weekAverages.isNotEmpty ? weekAverages.reduce(min) : 0;

      // Extract Goals failed/completed exactly on Worst/Best days
      List<String> wFailed = [];
      List<String> bCompleted = [];
      if (worstDay != null) {
        final entries = _entryRepo.getEntriesForDay(worstDay.journeyDay);
        for (final e in entries) {
           if (!e.isCompleted) {
             final tg = allGoals.cast<JourneyGoalModel?>().firstWhere((g) => g?.goalId == e.goalId, orElse: () => null);
             if (tg != null) wFailed.add(tg.title);
           }
        }
      }
      
      if (bestDay != null) {
        final entries = _entryRepo.getEntriesForDay(bestDay.journeyDay);
        for (final e in entries) {
           if (e.isCompleted) {
             final tg = allGoals.cast<JourneyGoalModel?>().firstWhere((g) => g?.goalId == e.goalId, orElse: () => null);
             if (tg != null) bCompleted.add(tg.title);
           }
        }
      }

      final bestDayDist = bestDay != null ? currentDay - bestDay.journeyDay : 0;

      // Calculate Total Goals vs Possible
      int completedSum = 0;
      int possibleSum = 0;

      for (final goal in allGoals) {
        final entries = _entryRepo.getEntriesForGoal(goal.goalId);
        completedSum += entries.where((e) => e.isCompleted).length;
        
        // Potential calculation: User might be on day 365, added goal on day 10.
        // Potential = min(currentDay, 365) - goal.addedOnDay + 1
        int cappedDay = min(currentDay, 365);
        if (cappedDay >= goal.addedOnDay) {
          possibleSum += (cappedDay - goal.addedOnDay + 1);
        }
      }

      emit(state.copyWith(
        isLoading: false,
        currentJourneyDay: currentDay,
        allDays: allDays,
        worstDayRec: worstDay,
        worstDayFailedGoals: wFailed,
        bestDayRec: bestDay,
        bestDayCompletedGoals: bCompleted,
        bestDayDistance: bestDayDist,
        totalPureDays: totalPure,
        totalFailedDays: totalFailed,
        finalDisciplineScore: _dayRepo.overallJourneyCompletionRate,
        confessions: allConfessions,
        finalLevel: _levelRepo.getCurrentLevelRecord(),
        longestPureStreak: maxPureStreak,
        worstWeekAvg: worstWk,
        bestWeekAvg: bestWk,
        totalGoalsCompleted: completedSum,
        totalGoalsPossible: possibleSum,
        journeyStartMs: journeyStartMs,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDismissed(
      FinalFiveScreenDismissed event, Emitter<FinalFiveState> emit) async {
    emit(state.copyWith(isDismissed: true));
  }
}
