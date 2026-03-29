import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import 'journey_time_service.dart';

class DailyCheckInService {
  final UserJourneyRepository _journeyRepo;
  final JourneyGoalRepository _goalRepo;
  final DayRecordRepository _dayRepo;
  final GoalEntryRepository _entryRepo;
  final JourneyTimeService _timeService;
  final SharedPreferences _prefs;

  static const String _keyLastAppOpen = 'lastAppOpenMs';
  static const String _keyLastOpenJourneyDay = 'lastOpenJourneyDay';

  bool _showSilencePenalty = false;
  bool _showReasonVault = false;
  int _failedDuringSilence = 0;
  List<String> _yesterdayFailedGoalNames = [];
  int _totalActiveGoalsYesterday = 0;

  bool get showSilencePenalty => _showSilencePenalty;
  int get failedDuringSilence => _failedDuringSilence;
  bool get showReasonVault => _showReasonVault;
  List<String> get yesterdayFailedGoalNames => _yesterdayFailedGoalNames;
  int get totalActiveGoalsYesterday => _totalActiveGoalsYesterday;

  DailyCheckInService({
    required UserJourneyRepository journeyRepo,
    required JourneyGoalRepository goalRepo,
    required DayRecordRepository dayRepo,
    required GoalEntryRepository entryRepo,
    required JourneyTimeService timeService,
    required SharedPreferences prefs,
  })  : _journeyRepo = journeyRepo,
        _goalRepo = goalRepo,
        _dayRepo = dayRepo,
        _entryRepo = entryRepo,
        _timeService = timeService,
        _prefs = prefs;

  /// Runs the auto-finalization logic on app launch. Returns true if the user
  /// was penalized for silence, or had a failing previous day, triggering respective UI.
  /// Result holds: { 'showSilencePenalty': bool, 'failedDuringSilence': int, 'showReasonVault': bool }
  Future<Map<String, dynamic>> runCheckOnLaunch() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check if journey exists
    final journey = _journeyRepo.getJourney();
    if (journey == null) {
      return {'showSilencePenalty': false, 'failedDuringSilence': 0, 'showReasonVault': false};
    }

    final snapshot = _timeService.snapshot(now);
    final currentDay = snapshot.journeyDay;

    final lastAppOpenMs = _prefs.getInt(_keyLastAppOpen) ?? now;
    final lastOpenDay = _prefs.getInt(_keyLastOpenJourneyDay) ?? currentDay;

    _showSilencePenalty = false;
    _failedDuringSilence = 0;
    _showReasonVault = false;
    _yesterdayFailedGoalNames = [];
    _totalActiveGoalsYesterday = 0;

    // Silence Penalty Condition: Journey days gap >= 2
    if (currentDay - lastOpenDay >= 2 && _prefs.containsKey(_keyLastOpenJourneyDay)) {
      _showSilencePenalty = true;
    }

    // Auto-finalize past days
    if (currentDay > lastOpenDay) {
      for (int d = lastOpenDay; d < currentDay; d++) {
        // Find ALL active goals for this past day (Daily, Monthly, Yearly all need check-ins)
        final activeGoals = _goalRepo.getGoalsActiveOnDay(d);
        if (activeGoals.isEmpty) continue; 

        // Create blank entries for goals that have no entry yet
        final existingIds = _entryRepo.getEntriesForDay(d).map((e) => e.goalId).toSet();
        final goalsToCreate = activeGoals.map((g) => g.goalId).where((id) => !existingIds.contains(id)).toList();
        
        if (goalsToCreate.isNotEmpty) {
          await _entryRepo.createEntriesForDay(goalIds: goalsToCreate, journeyDay: d);
        }

        // Calculate final completion rate considering ALL goals
        final completionRate = _entryRepo.completionRateForDay(d);
        
        if (_dayRepo.getRecordByDay(d) == null) {
          await _dayRepo.createDayRecord(
            journeyDay: d, 
            journeyStartTimestamp: journey.startTimestamp
          );
        }

        await _dayRepo.finaliseDay(journeyDay: d, completionRate: completionRate);
        
        // Count missed goals for silence penalty (all goals now)
        _failedDuringSilence += activeGoals.length - _entryRepo.getCompletedEntriesForDay(d).length;

        // Check if yesterday had failures
        if (d == currentDay - 1 && completionRate < 1.0) {
          _showReasonVault = true;
          _totalActiveGoalsYesterday = activeGoals.length;
          
          final completedIds = _entryRepo.getCompletedEntriesForDay(d).map((e) => e.goalId).toSet();
          _yesterdayFailedGoalNames = activeGoals
              .where((g) => !completedIds.contains(g.goalId))
              .map((g) => g.title)
              .toList();
        }
      }
    }

    // Update last app open
    await _prefs.setInt(_keyLastAppOpen, now);
    await _prefs.setInt(_keyLastOpenJourneyDay, currentDay);

    // Create today's blank record if it doesn't exist
    if (_dayRepo.getRecordByDay(currentDay) == null) {
      await _dayRepo.createDayRecord(
        journeyDay: currentDay, 
        journeyStartTimestamp: journey.startTimestamp
      );
    }
    
    // Seed today's entries for ALL active goals if missing
    final todaysActiveGoals = _goalRepo.getGoalsActiveOnDay(currentDay);
    final existingTodaysIds = _entryRepo.getEntriesForDay(currentDay).map((e) => e.goalId).toSet();
    final todaysGoalsToCreate = todaysActiveGoals.map((g) => g.goalId).where((id) => !existingTodaysIds.contains(id)).toList();
    if (todaysGoalsToCreate.isNotEmpty) {
      await _entryRepo.createEntriesForDay(goalIds: todaysGoalsToCreate, journeyDay: currentDay);
    }

    return {
      'showSilencePenalty': _showSilencePenalty,
      'failedDuringSilence': _failedDuringSilence,
      'showReasonVault': _showReasonVault,
      'yesterdayFailedGoalNames': _yesterdayFailedGoalNames,
      'totalActiveGoalsYesterday': _totalActiveGoalsYesterday,
    };
  }
}
