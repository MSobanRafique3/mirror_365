import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/level_service.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import 'levels_event.dart';
import 'levels_state.dart';

export 'levels_event.dart';
export 'levels_state.dart';

class LevelsBloc extends Bloc<LevelsEvent, LevelsState> {
  final LevelRepository _levelRepo;
  final DayRecordRepository _dayRepo;
  final LevelService _levelService;
  final JourneyTimeService _timeService;

  LevelsBloc({
    required LevelRepository levelRepo,
    required DayRecordRepository dayRepo,
    required LevelService levelService,
    required JourneyTimeService timeService,
  })  : _levelRepo = levelRepo,
        _dayRepo = dayRepo,
        _levelService = levelService,
        _timeService = timeService,
        super(const LevelsState()) {
    on<LevelsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
      LevelsLoadRequested event, Emitter<LevelsState> emit) async {
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final currentDay = _timeService.currentJourneyDay(nowMs);
      
      final currentLevel = _levelRepo.currentLevel;
      final currentLevelName = _levelRepo.currentLevelName;
      final history = _levelRepo.getAllLevelEvents().reversed.toList(); // Newest first
      
      final allRecords = _dayRepo.getAllRecords(); // Sorted by day
      
      // Calculate active drops
      final isDropWarning = _levelService.currentDropWarningActive;
      int? dropRemaining;
      
      if (isDropWarning) {
        final startWarningDay = _levelService.dropWarningStartDay;
        if (startWarningDay != null) {
          dropRemaining = max(0, 3 - (currentDay - startWarningDay)); 
        }
      }

      final peakAvg = _levelService.personalPeak7DayAvg;
      
      // Compute the current 7-day average (to show how far they dropped)
      double latest7DayAvg = 0;
      if (allRecords.length >= 7) {
        // use last 7 available days
        double sum = 0;
        final start = max(0, allRecords.length - 7);
        for (int i = start; i < allRecords.length; i++) {
          sum += allRecords[i].overallCompletionRate;
        }
        latest7DayAvg = sum / 7.0;
      }

      final nextLvlStr = _computeNextLevelString(currentLevel, currentDay, allRecords);

      emit(state.copyWith(
        isLoading: false,
        currentLevel: currentLevel,
        currentLevelName: currentLevelName,
        nextLevelRequirementStr: nextLvlStr,
        timelineEvents: history,
        currentDropWarningActive: isDropWarning,
        dropDaysRemaining: dropRemaining,
        personalPeakAvg: peakAvg,
        latest7DayAvg: latest7DayAvg,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  String _computeNextLevelString(int currentLevel, int currentDay, List<DayRecordModel> records) {
    if (records.isEmpty) return 'Build data blocks. Complete today to start tracking.';
    
    switch (currentLevel) {
      case 1:
        // Level 2: 5 consecutive days > historical avg
        int consecutive = 0;
        for (int d = currentDay - 1; d >= max(1, currentDay - 5); d--) {
          final r = records.cast<DayRecordModel?>().firstWhere((x) => x?.journeyDay == d, orElse: () => null);
          if (r == null) break;
          final histAvg = _getHistoricalAvgUpTo(records, d - 1);
          if (r.overallCompletionRate > histAvg) {
            consecutive++;
          } else {
            break;
          }
        }
        final needed = max(0, 5 - consecutive);
        return 'Need $needed more consecutive days beating your personal average to reach Level 2.';
        
      case 2:
        // Level 3: 14 days >= 70%
        int consecutive = 0;
        for (int d = currentDay - 1; d >= max(1, currentDay - 14); d--) {
          final r = records.cast<DayRecordModel?>().firstWhere((x) => x?.journeyDay == d, orElse: () => null);
          if (r == null) break;
          if (r.overallCompletionRate >= 0.70) {
            consecutive++;
          } else {
            break;
          }
        }
        final needed = max(0, 14 - consecutive);
        return 'Need $needed more consecutive days at 70%+ completion to reach Level 3.';

      case 3:
        // Level 4: Worst 7-day avg >= best month 1 avg
        if (currentDay < 30) {
          return 'Requires surviving past Day 30. Keep fighting.';
        }
        return 'Current worst week must mathematically beat your best Month 1 week parameters to reach Level 4.';

      case 4:
        // Level 5: 30 consecutive pure days
        int consecutive = 0;
        for (int d = currentDay - 1; d >= max(1, currentDay - 30); d--) {
          final r = records.cast<DayRecordModel?>().firstWhere((x) => x?.journeyDay == d, orElse: () => null);
          if (r == null) break;
          if (r.isPure) {
            consecutive++;
          } else {
            break;
          }
        }
        final needed = max(0, 30 - consecutive);
        if (needed == 30) return 'Requires 30 consecutive pure days. Restart the streak today.';
        return 'Need $needed more consecutive pure days to reach Level 5.';

      case 5:
        // Level 6: > Day 180 AND absolute average > 85%
        if (currentDay <= 180) {
          final daysLeft = 180 - currentDay + 1;
          return 'Requires surviving $daysLeft more days. Maintain parameters above 85%.';
        }
        final histAvg = _getHistoricalAvgUpTo(records, currentDay - 1);
        final pctDiff = 0.85 - histAvg;
        if (pctDiff > 0) {
          return 'Need ${(pctDiff * 100).toStringAsFixed(1)}% higher overall average to reach Level 6.';
        }
        return 'Level 6 imminent. Hold parameters.';

      case 6:
        // Level 7
        final left = max(0, 365 - currentDay + 1);
        return 'Survive $left more days to claim the Mirror.';
        
      case 7:
        return 'YOU HAVE BEATEN THE MIRROR. NO HIGHER RANKS EXIST.';
        
      default:
        return 'Awaiting data check...';
    }
  }

  double _getHistoricalAvgUpTo(List<DayRecordModel> records, int limitDay) {
    if (limitDay < 1) return 0.0;
    double sum = 0;
    for (int d = 1; d <= limitDay; d++) {
      final r = records.cast<DayRecordModel?>().firstWhere((x) => x?.journeyDay == d, orElse: () => null);
      sum += r?.overallCompletionRate ?? 0.0;
    }
    return sum / limitDay;
  }
}
