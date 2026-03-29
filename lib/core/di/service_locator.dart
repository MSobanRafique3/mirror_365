import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/repositories.dart';
import '../services/journey_time_service.dart';
import '../services/daily_check_in_service.dart';
import '../services/level_service.dart';
import '../services/reckoning_day_service.dart';
import '../../data/local/hive_database.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> setup() async {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);

    // ─── Phase 1: Legacy repositories ─────────────────────────────────────
    getIt.registerLazySingleton<GoalRepository>(() => GoalRepository());
    getIt.registerLazySingleton<SessionRepository>(() => SessionRepository());
    getIt.registerLazySingleton<UserProfileRepository>(
        () => UserProfileRepository());
    getIt.registerLazySingleton<ReflectionRepository>(
        () => ReflectionRepository());
    getIt.registerLazySingleton<FinalFiveRepository>(
        () => FinalFiveRepository());

    // ─── Phase 2: Journey repositories ────────────────────────────────────
    getIt.registerLazySingleton<UserJourneyRepository>(
        () => UserJourneyRepository());
    getIt.registerLazySingleton<JourneyGoalRepository>(
        () => JourneyGoalRepository());
    getIt.registerLazySingleton<DayRecordRepository>(
        () => DayRecordRepository());
    getIt.registerLazySingleton<GoalEntryRepository>(
        () => GoalEntryRepository());
    getIt.registerLazySingleton<MonthlyConfessionRepository>(
        () => MonthlyConfessionRepository());
    getIt.registerLazySingleton<LevelRepository>(() => LevelRepository());

    // ─── JourneyTimeService ────────────────────────────────────────────────
    // Registered as a factory so it always reads the latest startTimestamp.
    // If no journey exists yet, a sentinel service (startTimestamp = 0) is
    // returned — callers should guard with UserJourneyRepository.hasJourney.
    getIt.registerFactory<JourneyTimeService>(() {
      final journey = HiveDatabase.journeyBox.values.isNotEmpty
          ? HiveDatabase.journeyBox.values.first
          : null;
      return JourneyTimeService(
        startTimestamp: journey?.startTimestamp ?? 0,
      );
    });

    // ─── DailyCheckInService ────────────────────────────────────────────────
    getIt.registerLazySingleton<DailyCheckInService>(() => DailyCheckInService(
      journeyRepo: getIt<UserJourneyRepository>(),
      goalRepo: getIt<JourneyGoalRepository>(),
      dayRepo: getIt<DayRecordRepository>(),
      entryRepo: getIt<GoalEntryRepository>(),
      timeService: getIt<JourneyTimeService>(),
      prefs: getIt<SharedPreferences>(),
    ));

    // ─── LevelService ───────────────────────────────────────────────────────
    getIt.registerLazySingleton<LevelService>(() => LevelService(
      levelRepo: getIt<LevelRepository>(),
      dayRepo: getIt<DayRecordRepository>(),
      prefs: getIt<SharedPreferences>(),
    ));

    // ─── ReckoningDayService ────────────────────────────────────────────────
    getIt.registerLazySingleton<ReckoningDayService>(() => ReckoningDayService(
      prefs: getIt<SharedPreferences>(),
    ));
  }

  static Future<void> reset() async {
    await getIt.reset();
  }
}
