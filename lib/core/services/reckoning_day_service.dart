import 'package:shared_preferences/shared_preferences.dart';

class ReckoningResult {
  final bool showReckoning;
  final int reckoningDay;

  const ReckoningResult({
    required this.showReckoning,
    required this.reckoningDay,
  });
}

class ReckoningDayService {
  final SharedPreferences _prefs;

  ReckoningDayService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<ReckoningResult> runCheckOnLaunch(int currentJourneyDay) async {
    const validDays = [30, 60, 90, 180, 270];

    if (!validDays.contains(currentJourneyDay)) {
      return const ReckoningResult(showReckoning: false, reckoningDay: 0);
    }

    final String key = 'reckoning_shown_day_$currentJourneyDay';
    final bool alreadyShown = _prefs.getBool(key) ?? false;

    if (!alreadyShown) {
      return ReckoningResult(showReckoning: true, reckoningDay: currentJourneyDay);
    }

    return const ReckoningResult(showReckoning: false, reckoningDay: 0);
  }

  Future<void> markReckoningShown(int day) async {
    await _prefs.setBool('reckoning_shown_day_$day', true);
  }
}
