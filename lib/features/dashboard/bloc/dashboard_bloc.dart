import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../core/services/daily_check_in_service.dart';
import '../../../core/services/level_service.dart';
import '../../../core/services/reckoning_day_service.dart';
import '../../../core/di/service_locator.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final UserJourneyRepository _journeyRepo;
  final JourneyGoalRepository _goalRepo;
  final DayRecordRepository _dayRepo;
  final GoalEntryRepository _entryRepo;
  final LevelRepository _levelRepo;
  final JourneyTimeService _timeService;
  final SharedPreferences _prefs;

  static const String _keyLastAppOpen = 'lastAppOpenMs';
  static const String _keyLastWeeklyReport = 'lastWeeklyReportDay';

  final DailyCheckInService _checkInService;
  final LevelService _levelService;

  DashboardBloc({
    required UserJourneyRepository journeyRepo,
    required JourneyGoalRepository goalRepo,
    required DayRecordRepository dayRepo,
    required GoalEntryRepository entryRepo,
    required LevelRepository levelRepo,
    required JourneyTimeService timeService,
    required SharedPreferences prefs,
    required DailyCheckInService checkInService,
    required LevelService levelService,
  })  : _journeyRepo = journeyRepo,
        _goalRepo = goalRepo,
        _dayRepo = dayRepo,
        _entryRepo = entryRepo,
        _levelRepo = levelRepo,
        _timeService = timeService,
        _prefs = prefs,
        _checkInService = checkInService,
        _levelService = levelService,
        super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardFaceTodayClicked>(_onFaceTodayClicked);
    on<DashboardSilencePenaltyDismissed>(_onSilencePenaltyDismissed);
    on<DashboardReasonVaultDismissed>(_onReasonVaultDismissed);
    on<DashboardReckoningScreenDismissed>(_onReckoningScreenDismissed);
    on<DashboardDailyGoalToggled>(_onDailyGoalToggled);
  }

  Future<void> _onLoadRequested(
      DashboardLoadRequested event, Emitter<DashboardState> emit) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final snapshot = _timeService.snapshot(now);
      final currentDay = snapshot.journeyDay;

      // The DailyCheckInService has already processed all missed days before runApp().
      // Here we just consume its UI flags:
      final showSilencePenalty = _checkInService.showSilencePenalty;
      final failedDuringSilence = _checkInService.failedDuringSilence;
      final showReasonVault = _checkInService.showReasonVault;
      final yesterdayFailedGoals = _checkInService.yesterdayFailedGoalNames;
      final totalActiveYesterday = _checkInService.totalActiveGoalsYesterday;

      // Reckoning Service
      final reckoningService = getIt<ReckoningDayService>();
      final reckoningResult = await reckoningService.runCheckOnLaunch(currentDay);

      String? reasonText;
      if (showReasonVault) {
        final confessRepo = getIt<MonthlyConfessionRepository>();
        final dayZeroConfession = confessRepo.getAllConfessions().firstWhere((c) => c.monthNumber == 0, orElse: () => throw Exception('Missing Day 0 Reason'));
        reasonText = dayZeroConfession.content;
      }
      
      // Load all active goals for today so they can be checked off
      final todaysActiveGoals = _goalRepo.getGoalsActiveOnDay(currentDay).toList();
      final todaysEntries = _entryRepo.getEntriesForDay(currentDay);

      // 2. Load Core Data
      final overallScore = _dayRepo.overallJourneyCompletionRate;
      final currentLevel = _levelRepo.getCurrentLevelRecord();
      final allRecords = _dayRepo.getAllRecords();
      final last7Records = allRecords.where((r) => r.journeyDay >= currentDay - 7 && r.journeyDay < currentDay).toList();
      
      // Calculate missing days to ensure exactly 7 squares are returned for display (even if future/grey)
      final List<DayRecordModel> normalized7Days = [];
      for (int i = 6; i >= 0; i--) {
        final d = currentDay - 1 - i;
        if (d <= 0) continue; // Before journey started
        
        // Find existing record or supply a placeholder (future/grey representation if missing)
        final rec = _dayRepo.getRecordByDay(d);
        if (rec != null) {
          normalized7Days.add(rec);
        } else {
           normalized7Days.add(DayRecordModel(
              dayRecordId: 'missing_$d',
              journeyDay: d,
              monthNumber: 1,
              dayInMonth: 1,
              dayStartTimestamp: 0,
              dayEndTimestamp: 0,
              isSpecialDay: false,
              overallCompletionRate: 0.0,
              isFailed: false,
              isPure: false,
           ));
        }
      }

      // 3. Mirror Screen Advanced Computations
      Map<String, int> goalBreakdown = {};
      String? worstGoalId;
      int highestFailCount = -1;

      // Analyze last 7 days entries
      for (int i = 1; i <= 7; i++) {
        final d = currentDay - i;
        if (d <= 0) break;

        final entries = _entryRepo.getEntriesForDay(d);
        for (final entry in entries) {
           if (!entry.isCompleted) {
             goalBreakdown[entry.goalId] = (goalBreakdown[entry.goalId] ?? 0) + 1;
           }
        }
      }

      goalBreakdown.forEach((goalId, failCount) {
        if (failCount > highestFailCount) {
          highestFailCount = failCount;
          worstGoalId = goalId;
        }
      });

      String? worstGoalName;
      if (worstGoalId != null) {
        worstGoalName = _goalRepo.getGoalById(worstGoalId!)?.title;
      }

      // Overall Score Progression
      final prev7Records = allRecords.where((r) => r.journeyDay >= currentDay - 14 && r.journeyDay < currentDay - 7).toList();
      final last7Avg = last7Records.isEmpty ? 0.0 : last7Records.fold<double>(0, (s, r) => s + r.overallCompletionRate) / last7Records.length;
      final prev7Avg = prev7Records.isEmpty ? 0.0 : prev7Records.fold<double>(0, (s, r) => s + r.overallCompletionRate) / prev7Records.length;
      final isImproving = last7Avg >= prev7Avg;

      // 4. Weekly Report Logic
      final lastWeeklyReportDay = _prefs.getInt(_keyLastWeeklyReport) ?? 0;
      String? weeklyReport;
      
      if (currentDay >= lastWeeklyReportDay + 7 && currentDay >= 7) {
        if (worstGoalName != null) {
          weeklyReport = 'You failed $worstGoalName $highestFailCount times in the last 7 days. You are lying to yourself about your priorities.';
        } else {
          weeklyReport = 'A perfect week. Do not get comfortable. The mirror sees everything.';
        }
        await _prefs.setInt(_keyLastWeeklyReport, currentDay);
      }

      // The Wall
      final isWall = [21, 66, 100].contains(currentDay);

      // 5. Dashboard Arcs
      final dailyCompletionRate = _entryRepo.completionRateForDay(currentDay);
      // For Phase 2 simplicity, monthly/yearly arcs are approximated or placeholder since their checkin logic needs bigger windows. 
      // We'll use 0.0 or a custom logic later. Daily is most critical.
      final dailyScore = dailyCompletionRate;
      const monthlyScore = 0.0; 
      final yearlyScore = 0.0;

      emit(state.copyWith(
        isLoading: false,
        timeSnapshot: snapshot,
        showSilencePenaltyOverlay: showSilencePenalty,
        failedGoalsCountDuringSilence: failedDuringSilence,
        showReasonVault: showReasonVault,
        showReckoningScreen: reckoningResult.showReckoning,
        reckoningDayNumber: reckoningResult.reckoningDay,
        yesterdayFailedGoalNames: yesterdayFailedGoals,
        totalActiveGoalsYesterday: totalActiveYesterday,
        originalReasonText: reasonText,
        overallScore: overallScore,
        currentLevel: currentLevel,
        isDropWarningActive: _levelService.currentDropWarningActive,
        dropWarningStartDay: _levelService.dropWarningStartDay,
        last7DaysRecords: normalized7Days,
        goalBreakdownLast7Days: goalBreakdown,
        worstGoalLast7Days: worstGoalName,
        overallScoreIsImproving: isImproving,
        weeklyReportText: weeklyReport,
        isWallDay: isWall,
        todaysGoals: todaysActiveGoals,
        todaysEntries: todaysEntries,
        dailyArcScore: dailyScore,
        monthlyArcScore: monthlyScore,
        yearlyArcScore: yearlyScore,
        isCheckInWindowOpen: snapshot.isCheckInWindowOpen,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onFaceTodayClicked(
      DashboardFaceTodayClicked event, Emitter<DashboardState> emit) {
    emit(state.copyWith(showMirrorScreen: false));
  }

  void _onSilencePenaltyDismissed(
      DashboardSilencePenaltyDismissed event, Emitter<DashboardState> emit) {
    emit(state.copyWith(showSilencePenaltyOverlay: false));
  }

  void _onReasonVaultDismissed(
      DashboardReasonVaultDismissed event, Emitter<DashboardState> emit) {
    emit(state.copyWith(showReasonVault: false));
  }

  Future<void> _onReckoningScreenDismissed(
      DashboardReckoningScreenDismissed event, Emitter<DashboardState> emit) async {
    final reckoningService = getIt<ReckoningDayService>();
    await reckoningService.markReckoningShown(state.reckoningDayNumber);
    emit(state.copyWith(showReckoningScreen: false));
  }

  Future<void> _onDailyGoalToggled(
      DashboardDailyGoalToggled event, Emitter<DashboardState> emit) async {
    if (!state.isCheckInWindowOpen) return;
    
    final currentDay = state.timeSnapshot!.journeyDay;
    final entry = _entryRepo.getEntry(goalId: event.goalId, journeyDay: currentDay);
    if (entry == null) return;

    if (entry.isCompleted) {
      await _entryRepo.markIncomplete(goalId: event.goalId, journeyDay: currentDay);
    } else {
      await _entryRepo.markComplete(goalId: event.goalId, journeyDay: currentDay);
    }

    // Recalculate everything for today
    final completionRate = _entryRepo.completionRateForDay(currentDay);
    await _dayRepo.finaliseDay(journeyDay: currentDay, completionRate: completionRate);
    
    // Refresh state
    final todaysEntries = _entryRepo.getEntriesForDay(currentDay);
    final overallScore = _dayRepo.overallJourneyCompletionRate;
    
    emit(state.copyWith(
      todaysEntries: todaysEntries,
      dailyArcScore: completionRate,
      overallScore: overallScore,
    ));
  }


}
