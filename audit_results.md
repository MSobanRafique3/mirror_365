# Audit Results

## Navigation / Splash
lib\features\dashboard\pages\main_shell_page.dart:71: context.go(AppRoutes.dashboard);
lib\features\dashboard\pages\main_shell_page.dart:74: context.go(AppRoutes.goals);
lib\features\dashboard\pages\main_shell_page.dart:77: context.go(AppRoutes.graphs);
lib\features\dashboard\pages\main_shell_page.dart:80: context.go(AppRoutes.levels);
lib\features\onboarding\screens\final_confirmation_screen.dart:24: context.go(AppRoutes.dashboard);
lib\features\splash\screens\splash_screen.dart:81: context.go(AppRoutes.dashboard);
lib\features\splash\screens\splash_screen.dart:83: context.go(AppRoutes.onboarding);

## Brutality Rules
lib\core\services\daily_check_in_service.dart:45: final now = DateTime.now().millisecondsSinceEpoch;
lib\core\services\journey_time_service.dart:4: /// [startTimestamp] — never on the device's local timezone or wall-clock
lib\core\services\journey_time_service.dart:5: /// date fields. This makes the service timezone-independent and deterministic.
lib\core\services\journey_time_service.dart:30: /// [nowMs] defaults to [DateTime.now().millisecondsSinceEpoch].
lib\core\services\journey_time_service.dart:32: final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
lib\core\services\journey_time_service.dart:92: final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
lib\core\services\journey_time_service.dart:104: final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
lib\core\services\journey_time_service.dart:120: final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
lib\core\services\journey_time_service.dart:138: DateTime.now().millisecondsSinceEpoch >= startTimestamp;
lib\core\services\journey_time_service.dart:149: final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
lib\core\utils\date_utils.dart:31: final now = DateTime.now();
lib\core\utils\date_utils.dart:42: final yesterday = DateTime.now().subtract(const Duration(days: 1));
lib\core\utils\date_utils.dart:49: final diff = DateTime.now().difference(date).inDays;
lib\core\utils\date_utils.dart:61: return daysBetween(DateTime.now(), date);
lib\core\utils\date_utils.dart:65: return daysBetween(date, DateTime.now());
lib\data\models\goal_model.dart:66: return DateTime.now().difference(createdAt).inDays;
lib\data\repositories\final_five_repository.dart:25: FinalFiveModel? getTodayEntry() => getEntryForDate(DateTime.now());
lib\data\repositories\final_five_repository.dart:38: date: date ?? DateTime.now(),
lib\data\repositories\goal_entry_repository.dart:115: completedAt: completedAtMs ?? DateTime.now().millisecondsSinceEpoch,
lib\data\repositories\goal_repository.dart:39: createdAt: DateTime.now(),
lib\data\repositories\goal_repository.dart:48: Future<void> updateGoal(GoalModel goal) async {
lib\data\repositories\goal_repository.dart:52: Future<void> deleteGoal(String id) async {
lib\data\repositories\goal_repository.dart:60: checkIns: [...goal.checkIns, DateTime.now()],
lib\data\repositories\goal_repository.dart:62: await updateGoal(updated);
lib\data\repositories\journey_goal_repository.dart:63: Future<void> updateGoal(JourneyGoalModel goal) async {
lib\data\repositories\journey_goal_repository.dart:72: await updateGoal(updated);
lib\data\repositories\journey_goal_repository.dart:79: Future<void> deleteGoal(String goalId) async {
lib\data\repositories\monthly_confession_repository.dart:53: writtenAt: writtenAtMs ?? DateTime.now().millisecondsSinceEpoch,
lib\data\repositories\reflection_repository.dart:38: createdAt: DateTime.now(),
lib\data\repositories\reflection_repository.dart:55: return getReflectionsForDate(DateTime.now()).isNotEmpty;
lib\data\repositories\session_repository.dart:31: startedAt: DateTime.now(),
lib\data\repositories\session_repository.dart:40: final now = DateTime.now();
lib\data\repositories\session_repository.dart:59: final today = DateTime.now();
lib\data\repositories\session_repository.dart:66: final now = DateTime.now();
lib\data\repositories\user_journey_repository.dart:28: startTimestamp ?? DateTime.now().millisecondsSinceEpoch,
lib\data\repositories\user_profile_repository.dart:22: createdAt: DateTime.now(),
lib\data\repositories\user_profile_repository.dart:42: final now = DateTime.now();
lib\features\dashboard\bloc\dashboard_bloc.dart:58: final now = DateTime.now().millisecondsSinceEpoch;
lib\features\dashboard\pages\dashboard_page.dart:48: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\goals\bloc\goals_bloc.dart:30: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\goals\widgets\add_goal_bottom_sheet.dart:174: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\graphs\bloc\graphs_bloc.dart:41: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\levels\bloc\levels_bloc.dart:35: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\mirror\bloc\confession_bloc.dart:27: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\mirror\bloc\confession_bloc.dart:76: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\features\splash\screens\splash_screen.dart:67: final nowMs = DateTime.now().millisecondsSinceEpoch;
lib\shared\extensions\extensions.dart:44: final now = DateTime.now();

