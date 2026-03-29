import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import 'graphs_event.dart';
import 'graphs_state.dart';

export 'graphs_event.dart';
export 'graphs_state.dart';

class GraphsBloc extends Bloc<GraphsEvent, GraphsState> {
  final DayRecordRepository _dayRepo;
  final JourneyGoalRepository _goalRepo;
  final GoalEntryRepository _entryRepo;
  final JourneyTimeService _timeService;
  final SharedPreferences _prefs;

  static const String _keyLastMirrorFlash = 'lastHonestMirrorFlashDay';

  GraphsBloc({
    required DayRecordRepository dayRepo,
    required JourneyGoalRepository goalRepo,
    required GoalEntryRepository entryRepo,
    required JourneyTimeService timeService,
    required SharedPreferences prefs,
  })  : _dayRepo = dayRepo,
        _goalRepo = goalRepo,
        _entryRepo = entryRepo,
        _timeService = timeService,
        _prefs = prefs,
        super(const GraphsState()) {
    on<GraphsLoadRequested>(_onLoadRequested);
    on<GraphsMirrorFlashed>(_onMirrorFlashed);
  }

  Future<void> _onLoadRequested(
      GraphsLoadRequested event, Emitter<GraphsState> emit) async {
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final currentDay = _timeService.currentJourneyDay(nowMs);
      
      final allRecords = _dayRepo.getAllRecords(); // Sorted by day

      // 1. Year Map (Just pass raw records)
      
      // 2. Daily Discipline Chart
      final last30DaysCount = min(30, allRecords.length);
      final last30Days = allRecords.sublist(allRecords.length - last30DaysCount);
      
      final personalLifetimeAverage = _dayRepo.overallJourneyCompletionRate;

      // 3. Weekly Rhythm — journey-relative day-of-week (not calendar)
      final mapWeekdays = <int, List<double>>{
        1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [],
      };
      
      for (final r in allRecords) {
        // Journey-relative: day 1 = position 1, day 2 = position 2, etc.
        // Weekday position = ((journeyDay - 1) % 7) + 1, giving 1-7
        final wd = ((r.journeyDay - 1) % 7) + 1;
        mapWeekdays[wd]!.add(r.overallCompletionRate);
      }

      final weekdayAverages = <int, double>{};
      int weakestWeekday = 1;
      double lowestAvg = 2.0;

      for (int i = 1; i <= 7; i++) {
        final list = mapWeekdays[i]!;
        if (list.isEmpty) {
          weekdayAverages[i] = 0.0;
        } else {
          final avg = list.reduce((a, b) => a + b) / list.length;
          weekdayAverages[i] = avg;
          if (avg < lowestAvg) {
            lowestAvg = avg;
            weakestWeekday = i;
          }
        }
      }

      // 4. Goal-by-Goal Breakdown
      final goals = _goalRepo.getAllGoals();
      final goalBreakdowns = <GoalGraphData>[];

      for (final goal in goals) {
        final entries = _entryRepo.getEntriesForGoal(goal.goalId);
        // entries are tracked per day. A streak is consecutively completed days.
        int currentStreak = 0;
        int maxStreak = 0;
        int tempStreak = 0;

        // Sort entries by day
        entries.sort((a, b) => a.journeyDay.compareTo(b.journeyDay));

        // Calculate streaks (streak requires day-over-day sequence)
        // Note: For non-daily goals, "streaks" is trickier. Assume streak implies 
        // consecutive days where they successfully hit their requirement, or just consecutive completed entries.
        // The spec implies consecutive days.
        
        int lastSuccessDay = -1;
        for (final e in entries) {
          if (e.isCompleted) {
            if (lastSuccessDay == -1 || e.journeyDay == lastSuccessDay + 1) {
              tempStreak++;
            } else {
              tempStreak = 1;
            }
            if (tempStreak > maxStreak) maxStreak = tempStreak;
            lastSuccessDay = e.journeyDay;
          } else {
            tempStreak = 0; // broke streak
          }
        }
        
        // current streak is backwards from current day
        currentStreak = 0;
        final latestEntries = entries.reversed.toList();
        for (int i = 0; i < latestEntries.length; i++) {
          // If we are on today and it's not completed, streak is 0?
          // Allow leeway if exactly today is unchecked.
          final e = latestEntries[i];
          if (i == 0 && e.journeyDay == currentDay && !e.isCompleted) {
            continue; // Give them today to hit it
          }
          if (e.isCompleted) {
            currentStreak++;
          } else {
            break;
          }
        }

        final completionRate = entries.isNotEmpty 
          ? entries.where((e) => e.isCompleted).length / entries.length 
          : 0.0;

        // Last 30 days sparkline
        final List<double> sparkline = [];
        for (int d = currentDay - 29; d <= currentDay; d++) {
          if (d < goal.addedOnDay) {
            sparkline.add(0.0);
          } else {
            final e = entries.cast<GoalEntryModel?>().firstWhere((x) => x?.journeyDay == d, orElse: () => null);
            sparkline.add(e?.isCompleted == true ? 1.0 : 0.0);
          }
        }

        goalBreakdowns.add(GoalGraphData(
          title: goal.title,
          lifetimeCompletionRate: completionRate,
          currentStreak: currentStreak,
          longestStreak: maxStreak,
          sparkline30Days: sparkline,
        ));
      }

      // 5. Velocity
      final velocitySeries = <MapEntry<int, double>>[];
      for (int i = 0; i < allRecords.length; i++) {
        final d = allRecords[i].journeyDay;
        // 7-day trailing avg
        double sum = 0;
        int count = 0;
        for (int j = max(0, i - 6); j <= i; j++) {
          sum += allRecords[j].overallCompletionRate;
          count++;
        }
        final avg = count > 0 ? sum / count : 0.0;
        velocitySeries.add(MapEntry(d, avg));
      }

      // Comfort Zone check (flat line)
      bool comfortZoneW = false;
      if (velocitySeries.length >= 14) {
        // Last 14 days diff
        final recent14 = velocitySeries.sublist(velocitySeries.length - 14);
        final slopeDiff = recent14.last.value - recent14.first.value;
        if (slopeDiff.abs() < 0.05) {
          comfortZoneW = true;
        }
      }

      // 6. Honest Mirror — milestones at 28, 56, 84, then every 30 days after
      final bool honestMirrorUnlocked = currentDay >= 28;
      bool flashMirror = false;
      if (honestMirrorUnlocked) {
        final isMilestone = currentDay == 28 || currentDay == 56 || currentDay == 84 ||
            (currentDay > 84 && (currentDay - 84) % 30 == 0);
        if (isMilestone) {
          final lastFlash = _prefs.getInt(_keyLastMirrorFlash) ?? 0;
          if (lastFlash != currentDay) {
            flashMirror = true;
          }
        }
      }

      emit(state.copyWith(
        isLoading: false,
        currentJourneyDay: currentDay,
        yearMapDays: allRecords,
        last30Days: last30Days,
        personalLifetimeAverage: personalLifetimeAverage,
        weekdayAverages: weekdayAverages,
        weakestWeekday: weakestWeekday,
        goalBreakdowns: goalBreakdowns,
        velocitySeries: velocitySeries,
        comfortZoneWarning: comfortZoneW,
        honestMirrorUnlocked: honestMirrorUnlocked,
        shouldFlashMirror: flashMirror,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMirrorFlashed(
      GraphsMirrorFlashed event, Emitter<GraphsState> emit) async {
    await _prefs.setInt(_keyLastMirrorFlash, state.currentJourneyDay);
    emit(state.copyWith(shouldFlashMirror: false));
  }
}
