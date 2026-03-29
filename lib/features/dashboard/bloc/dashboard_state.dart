import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';
import '../../../core/services/journey_time_service.dart';

class DashboardState extends Equatable {
  // Screen/Overlay visibility flow
  final bool showReasonVault;
  final List<String> yesterdayFailedGoalNames;
  final int totalActiveGoalsYesterday;
  final String? originalReasonText;
  
  final bool showSilencePenaltyOverlay;
  final bool showMirrorScreen;
  
  final bool showReckoningScreen;
  final int reckoningDayNumber;

  // Global Time & Score Data
  final JourneySnapshot? timeSnapshot;
  final double overallScore;
  final LevelModel? currentLevel;
  final bool isDropWarningActive;
  final int? dropWarningStartDay;

  // Mirror Specific Data
  final List<DayRecordModel> last7DaysRecords;
  final Map<String, int> goalBreakdownLast7Days; // goalName -> completionCount
  final String? worstGoalLast7Days;
  final bool overallScoreIsImproving;
  final String? weeklyReportText;
  final bool isWallDay;
  final int failedGoalsCountDuringSilence;

  // Dashboard Specific Data
  final double dailyArcScore;
  final double monthlyArcScore;
  final double yearlyArcScore;
  final List<JourneyGoalModel> todaysGoals;
  final List<GoalEntryModel> todaysEntries;
  final bool isCheckInWindowOpen;
  
  // Interaction Data
  final String? errorMessage;
  final bool isLoading;

  const DashboardState({
    this.showReasonVault = false,
    this.yesterdayFailedGoalNames = const [],
    this.totalActiveGoalsYesterday = 0,
    this.originalReasonText,
    this.showSilencePenaltyOverlay = false,
    this.showMirrorScreen = true,
    this.showReckoningScreen = false,
    this.reckoningDayNumber = 0,
    this.timeSnapshot,
    this.overallScore = 0.0,
    this.currentLevel,
    this.isDropWarningActive = false,
    this.dropWarningStartDay,
    this.last7DaysRecords = const [],
    this.goalBreakdownLast7Days = const {},
    this.worstGoalLast7Days,
    this.overallScoreIsImproving = false,
    this.weeklyReportText,
    this.isWallDay = false,
    this.failedGoalsCountDuringSilence = 0,
    this.dailyArcScore = 0.0,
    this.monthlyArcScore = 0.0,
    this.yearlyArcScore = 0.0,
    this.todaysGoals = const [],
    this.todaysEntries = const [],
    this.isCheckInWindowOpen = false,
    this.errorMessage,
    this.isLoading = true,
  });

  DashboardState copyWith({
    bool? showReasonVault,
    List<String>? yesterdayFailedGoalNames,
    int? totalActiveGoalsYesterday,
    String? originalReasonText,
    bool? showSilencePenaltyOverlay,
    bool? showMirrorScreen,
    bool? showReckoningScreen,
    int? reckoningDayNumber,
    JourneySnapshot? timeSnapshot,
    double? overallScore,
    LevelModel? currentLevel,
    bool? isDropWarningActive,
    int? dropWarningStartDay,
    List<DayRecordModel>? last7DaysRecords,
    Map<String, int>? goalBreakdownLast7Days,
    String? worstGoalLast7Days,
    bool? overallScoreIsImproving,
    String? weeklyReportText,
    bool? isWallDay,
    int? failedGoalsCountDuringSilence,
    double? dailyArcScore,
    double? monthlyArcScore,
    double? yearlyArcScore,
    List<JourneyGoalModel>? todaysGoals,
    List<GoalEntryModel>? todaysEntries,
    bool? isCheckInWindowOpen,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return DashboardState(
      showReasonVault: showReasonVault ?? this.showReasonVault,
      yesterdayFailedGoalNames: yesterdayFailedGoalNames ?? this.yesterdayFailedGoalNames,
      totalActiveGoalsYesterday: totalActiveGoalsYesterday ?? this.totalActiveGoalsYesterday,
      originalReasonText: originalReasonText ?? this.originalReasonText,
      showSilencePenaltyOverlay: showSilencePenaltyOverlay ?? this.showSilencePenaltyOverlay,
      showMirrorScreen: showMirrorScreen ?? this.showMirrorScreen,
      showReckoningScreen: showReckoningScreen ?? this.showReckoningScreen,
      reckoningDayNumber: reckoningDayNumber ?? this.reckoningDayNumber,
      timeSnapshot: timeSnapshot ?? this.timeSnapshot,
      overallScore: overallScore ?? this.overallScore,
      currentLevel: currentLevel ?? this.currentLevel,
      isDropWarningActive: isDropWarningActive ?? this.isDropWarningActive,
      dropWarningStartDay: dropWarningStartDay ?? this.dropWarningStartDay,
      last7DaysRecords: last7DaysRecords ?? this.last7DaysRecords,
      goalBreakdownLast7Days: goalBreakdownLast7Days ?? this.goalBreakdownLast7Days,
      worstGoalLast7Days: worstGoalLast7Days ?? this.worstGoalLast7Days,
      overallScoreIsImproving: overallScoreIsImproving ?? this.overallScoreIsImproving,
      weeklyReportText: weeklyReportText ?? this.weeklyReportText,
      isWallDay: isWallDay ?? this.isWallDay,
      failedGoalsCountDuringSilence: failedGoalsCountDuringSilence ?? this.failedGoalsCountDuringSilence,
      dailyArcScore: dailyArcScore ?? this.dailyArcScore,
      monthlyArcScore: monthlyArcScore ?? this.monthlyArcScore,
      yearlyArcScore: yearlyArcScore ?? this.yearlyArcScore,
      todaysGoals: todaysGoals ?? this.todaysGoals,
      todaysEntries: todaysEntries ?? this.todaysEntries,
      isCheckInWindowOpen: isCheckInWindowOpen ?? this.isCheckInWindowOpen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        showReasonVault,
        yesterdayFailedGoalNames,
        totalActiveGoalsYesterday,
        originalReasonText,
        showSilencePenaltyOverlay,
        showMirrorScreen,
        showReckoningScreen,
        reckoningDayNumber,
        timeSnapshot,
        overallScore,
        currentLevel,
        isDropWarningActive,
        dropWarningStartDay,
        last7DaysRecords,
        goalBreakdownLast7Days,
        worstGoalLast7Days,
        overallScoreIsImproving,
        weeklyReportText,
        isWallDay,
        failedGoalsCountDuringSilence,
        dailyArcScore,
        monthlyArcScore,
        yearlyArcScore,
        todaysGoals,
        todaysEntries,
        isCheckInWindowOpen,
        errorMessage,
        isLoading,
      ];
}
