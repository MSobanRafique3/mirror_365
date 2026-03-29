import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../../core/constants/app_constants.dart';

class HiveDatabase {
  HiveDatabase._();

  static Future<void> init() async {
    await Hive.initFlutter();

    // ── Phase 1 adapters ──────────────────────────────────────────────────
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(SessionModelAdapter());
    Hive.registerAdapter(UserProfileModelAdapter());
    Hive.registerAdapter(ReflectionModelAdapter());
    Hive.registerAdapter(FinalFiveModelAdapter());

    // ── Phase 2 adapters ──────────────────────────────────────────────────
    // GoalCategory enum adapter must be registered BEFORE JourneyGoalModel
    Hive.registerAdapter(GoalCategoryAdapter());
    Hive.registerAdapter(UserJourneyModelAdapter());
    Hive.registerAdapter(JourneyGoalModelAdapter());
    Hive.registerAdapter(DayRecordModelAdapter());
    Hive.registerAdapter(GoalEntryModelAdapter());
    Hive.registerAdapter(MonthlyConfessionModelAdapter());
    Hive.registerAdapter(LevelModelAdapter());

    // ── Open all boxes ────────────────────────────────────────────────────
    await Future.wait([
      // Phase 1
      Hive.openBox<GoalModel>(HiveBoxes.goals),
      Hive.openBox<SessionModel>(HiveBoxes.sessions),
      Hive.openBox<UserProfileModel>(HiveBoxes.userProfile),
      Hive.openBox<ReflectionModel>(HiveBoxes.reflections),
      Hive.openBox<FinalFiveModel>(HiveBoxes.finalFive),
      Hive.openBox(HiveBoxes.settings),
      // Phase 2
      Hive.openBox<UserJourneyModel>(HiveBoxes.journey),
      Hive.openBox<JourneyGoalModel>(HiveBoxes.journeyGoals),
      Hive.openBox<DayRecordModel>(HiveBoxes.dayRecords),
      Hive.openBox<GoalEntryModel>(HiveBoxes.goalEntries),
      Hive.openBox<MonthlyConfessionModel>(HiveBoxes.confessions),
      Hive.openBox<LevelModel>(HiveBoxes.levels),
    ]);
  }

  // ── Phase 1 box accessors ──────────────────────────────────────────────────

  static Box<GoalModel> get goalsBox =>
      Hive.box<GoalModel>(HiveBoxes.goals);

  static Box<SessionModel> get sessionsBox =>
      Hive.box<SessionModel>(HiveBoxes.sessions);

  static Box<UserProfileModel> get userProfileBox =>
      Hive.box<UserProfileModel>(HiveBoxes.userProfile);

  static Box<ReflectionModel> get reflectionsBox =>
      Hive.box<ReflectionModel>(HiveBoxes.reflections);

  static Box<FinalFiveModel> get finalFiveBox =>
      Hive.box<FinalFiveModel>(HiveBoxes.finalFive);

  static Box get settingsBox => Hive.box(HiveBoxes.settings);

  // ── Phase 2 box accessors ──────────────────────────────────────────────────

  static Box<UserJourneyModel> get journeyBox =>
      Hive.box<UserJourneyModel>(HiveBoxes.journey);

  static Box<JourneyGoalModel> get journeyGoalsBox =>
      Hive.box<JourneyGoalModel>(HiveBoxes.journeyGoals);

  static Box<DayRecordModel> get dayRecordsBox =>
      Hive.box<DayRecordModel>(HiveBoxes.dayRecords);

  static Box<GoalEntryModel> get goalEntriesBox =>
      Hive.box<GoalEntryModel>(HiveBoxes.goalEntries);

  static Box<MonthlyConfessionModel> get confessionsBox =>
      Hive.box<MonthlyConfessionModel>(HiveBoxes.confessions);

  static Box<LevelModel> get levelsBox =>
      Hive.box<LevelModel>(HiveBoxes.levels);

  // ── Utility ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await Future.wait([
      // Phase 1
      goalsBox.clear(),
      sessionsBox.clear(),
      userProfileBox.clear(),
      reflectionsBox.clear(),
      finalFiveBox.clear(),
      settingsBox.clear(),
      // Phase 2
      journeyBox.clear(),
      journeyGoalsBox.clear(),
      dayRecordsBox.clear(),
      goalEntriesBox.clear(),
      confessionsBox.clear(),
      levelsBox.clear(),
    ]);
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
