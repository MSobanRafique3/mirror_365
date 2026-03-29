import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class LevelService {
  final LevelRepository _levelRepo;
  final DayRecordRepository _dayRepo;
  final SharedPreferences _prefs;

  static const String _keyPeakAvg = 'personalPeak7DayAvg';
  static const String _keyDropWarningDay = 'dropWarningStartDay';
  static const String _keyWarningActive = 'currentDropWarningActive';
  static const String _keyLastLevelCheck = 'lastLevelCheckDay';

  Map<String, dynamic>? _lastEvaluationResult;
  Map<String, dynamic>? get lastEvaluationResult => _lastEvaluationResult;

  LevelService({
    required LevelRepository levelRepo,
    required DayRecordRepository dayRepo,
    required SharedPreferences prefs,
  })  : _levelRepo = levelRepo,
        _dayRepo = dayRepo,
        _prefs = prefs;

  // State Getters for UI
  double get personalPeak7DayAvg => _prefs.getDouble(_keyPeakAvg) ?? 0.0;
  int? get dropWarningStartDay => _prefs.containsKey(_keyDropWarningDay) ? _prefs.getInt(_keyDropWarningDay) : null;
  bool get currentDropWarningActive => _prefs.getBool(_keyWarningActive) ?? false;
  int get lastLevelCheckDay => _prefs.getInt(_keyLastLevelCheck) ?? 0;

  /// Runs automatically after all past days are finalized by DailyCheckInService.
  /// Evaluates level progression and regression logic up to [currentJourneyDay] - 1.
  Future<Map<String, dynamic>> evaluatePastDays(int currentJourneyDay) async {
    final startCheckDay = lastLevelCheckDay + 1;
    final endCheckDay = currentJourneyDay - 1; // Only check completed days

    // If already checked, or no fully completed days to check yet, return.
    if (startCheckDay > endCheckDay) {
      _lastEvaluationResult = {
        'leveledUp': false,
        'droppedLevel': false,
        'newLevel': _levelRepo.currentLevel,
        'reason': null,
      };
      return _lastEvaluationResult!;
    }

    bool leveledUp = false;
    bool droppedLevel = false;
    String? dropReason;

    final allRecords = _dayRepo.getAllRecords(); // Sorted by journeyDay

    for (int day = startCheckDay; day <= endCheckDay; day++) {
      // Find the record for this day; if missing somehow, create a dummy 0 rate block for calculation.
      final record = allRecords.cast<DayRecordModel?>().firstWhere((r) => r?.journeyDay == day, orElse: () => null);
      if (record == null) continue;

      final int currentLvl = _levelRepo.currentLevel;

      // ─── Drop Logic ──────────────────────────────────────────────────
      final double today7DayAvg = _getRolling7DayAvg(allRecords, day);
      final double peak = personalPeak7DayAvg;

      // Ensure at least 7 days have passed before calculating drops
      if (day >= 7) {
        if (today7DayAvg > peak) {
          await _prefs.setDouble(_keyPeakAvg, today7DayAvg);
        }

        final bool isSlipping = today7DayAvg < (peak - 0.20);
        
        if (isSlipping && currentLvl > 1) {
          if (!currentDropWarningActive) {
            await _prefs.setBool(_keyWarningActive, true);
            await _prefs.setInt(_keyDropWarningDay, day);
          } else {
            // Check if 3 days have passed since warning started WITHOUT recovery
            final warningStart = dropWarningStartDay!;
            if (day >= warningStart + 3) {
              // DROP LEVEL
              final newLvl = max(1, currentLvl - 1);
              await _levelRepo.recordDrop(droppedAtDay: day);
              // Create a new record for the dropped-to level
              await _levelRepo.recordLevelUnlock(level: newLvl, unlockedAtDay: day);
              
              droppedLevel = true;
              dropReason = 'Your 7-day average dropped 20% below your peak ($peak) and did not recover for 3 days.';
              
              // Reset warning state
              await _prefs.setBool(_keyWarningActive, false);
              await _prefs.remove(_keyDropWarningDay);
              // reset peak to allow them to climb back safely from current level
              await _prefs.setDouble(_keyPeakAvg, today7DayAvg);
            }
          }
        } else {
          // Recovered! Reset warning
          if (currentDropWarningActive) {
            await _prefs.setBool(_keyWarningActive, false);
            await _prefs.remove(_keyDropWarningDay);
          }
        }
      }

      // ─── Progression Logic ──────────────────────────────────────────
      // Note: If they just dropped a level, they technically can't instantly level up
      // on the exact same day loop check, so skip progression check this loop iteration.
      if (droppedLevel) continue;

      int newLevelMet = currentLvl;

      // Test Level 2
      if (currentLvl == 1 && day >= 5) {
        if (_checkLevel2(allRecords, day)) newLevelMet = 2;
      }
      // Test Level 3
      else if (currentLvl == 2 && day >= 14) {
        if (_checkLevel3(allRecords, day)) newLevelMet = 3;
      }
      // Test Level 4
      else if (currentLvl == 3 && day >= 30) { // needs at least month 1
        if (_checkLevel4(allRecords, day)) newLevelMet = 4;
      }
      // Test Level 5
      else if (currentLvl == 4 && day >= 30) {
        if (_checkLevel5(allRecords, day)) newLevelMet = 5;
      }
      // Test Level 6
      else if (currentLvl == 5 && day > 180) {
        if (_checkLevel6(allRecords, day)) newLevelMet = 6;
      }
      // Test Level 7
      else if (currentLvl == 6 && day >= 365) {
        newLevelMet = 7;
      }

      if (newLevelMet > currentLvl) {
        await _levelRepo.recordLevelUnlock(level: newLevelMet, unlockedAtDay: day);
        leveledUp = true;
      }
    }

    await _prefs.setInt(_keyLastLevelCheck, endCheckDay);

    _lastEvaluationResult = {
      'leveledUp': leveledUp,
      'droppedLevel': droppedLevel,
      'newLevel': _levelRepo.currentLevel,
      'reason': dropReason,
    };
    return _lastEvaluationResult!;
  }

  // ─── Helper Mathematical Checks ─────────────────────────────────────

  /// L2: 5 consecutive days where EACH day is > the historical average up to that day.
  bool _checkLevel2(List<DayRecordModel> records, int day) {
    if (day < 5) return false;
    for (int d = day - 4; d <= day; d++) {
      final currentRate = _getCompletionRateOrZero(records, d);
      final historicalAvg = _getHistoricalAvgUpTo(records, d - 1);
      if (currentRate <= historicalAvg) return false;
    }
    return true;
  }

  /// L3: 14 consecutive days >= 0.70
  bool _checkLevel3(List<DayRecordModel> records, int day) {
    if (day < 14) return false;
    for (int d = day - 13; d <= day; d++) {
      if (_getCompletionRateOrZero(records, d) < 0.70) return false;
    }
    return true;
  }

  /// L4: Worst rolling 7-day avg within last 60 days >= Best rolling 7-day avg from Month 1 (Days 1-30).
  bool _checkLevel4(List<DayRecordModel> records, int day) {
    if (day < 30) return false; // Edge case
    
    // Find best 7-day averge in Month 1
    double bestMonth1 = 0;
    for (int d = 7; d <= 30; d++) {
      if (d > day) break;
      final avg = _getRolling7DayAvg(records, d);
      if (avg > bestMonth1) bestMonth1 = avg;
    }
    if (bestMonth1 == 0) return false;

    // Find worst 7-day rolling avg in the last 60 days (or since day 7 if less than 60)
    final startD = max(7, day - 59); // up to 60 days ago
    double worstCurrent = 2.0; // dummy max
    for (int d = startD; d <= day; d++) {
      final avg = _getRolling7DayAvg(records, d);
      if (avg < worstCurrent) worstCurrent = avg;
    }
    
    return worstCurrent >= bestMonth1;
  }

  /// L5: 30 consecutive pure days (isPure == true)
  bool _checkLevel5(List<DayRecordModel> records, int day) {
    if (day < 30) return false;
    for (int d = day - 29; d <= day; d++) {
      final r = records.cast<DayRecordModel?>().firstWhere((x) => x?.journeyDay == d, orElse: () => null);
      if (r == null || !r.isPure) return false;
    }
    return true;
  }

  /// L6: > Day 180 and overall absolute journey average > 0.85
  bool _checkLevel6(List<DayRecordModel> records, int day) {
    if (day <= 180) return false;
    final historicalAvg = _getHistoricalAvgUpTo(records, day);
    return historicalAvg > 0.85;
  }

  // ─── Base Arithmetic Utilities ───────────────────────────────────────

  double _getCompletionRateOrZero(List<DayRecordModel> records, int day) {
    final r = records.cast<DayRecordModel?>().firstWhere((x) => x?.journeyDay == day, orElse: () => null);
    return r?.overallCompletionRate ?? 0.0;
  }

  double _getHistoricalAvgUpTo(List<DayRecordModel> records, int limitDay) {
    if (limitDay < 1) return 0.0;
    double sum = 0;
    for (int d = 1; d <= limitDay; d++) {
      sum += _getCompletionRateOrZero(records, d);
    }
    return sum / limitDay;
  }

  double _getRolling7DayAvg(List<DayRecordModel> records, int endDay) {
    if (endDay < 7) return 0.0; // Technically not possible for a 7-day average if not reached
    double sum = 0;
    for (int d = endDay - 6; d <= endDay; d++) {
      sum += _getCompletionRateOrZero(records, d);
    }
    return sum / 7.0;
  }
}
